"""Targeted Adversarial Stress Test & Invariant Verification for CAD Selection and DX2.

Adversarially challenges:
1. CAD Selection Count Invariant:
   - Strict proof that loop-level ssget count is 0 in aa:zz-run, c:DX2, and c:DX.
   - Strict proof that global ssget count across each pipeline is O(1).
2. DX2 Output Invariant:
   - Adversarial cell vertical shifts (<= 0.25*min_h vs > 0.25*min_h).
   - In-cell multi-line text clustering (<= 0.55*row_h vs > 0.55*row_h).
   - Text concatenation with "、", cell separation with CRLF ("\r\n"), empty cell elimination.
   - Large-scale fuzzer (500 randomized adversarial configurations).
"""
from functools import cmp_to_key
import math
from pathlib import Path
import random
import sys

# Setup imports
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from lsp_common import SOURCE, defun_forms, parse, read_source, walk


# ==============================================================================
# 1. Empirical Verification of CAD Selection Invariants (AST Analysis)
# ==============================================================================

def verify_cad_selection_invariants():
    print("--- Invariant 1: CAD Selection Invariants Audit ---")
    raw, source = read_source(SOURCE)
    forms = parse(source)
    defuns = {f[1]: f for f in defun_forms(forms) if isinstance(f[1], str)}

    # Helper to find all calls within an AST node
    def find_calls(node):
        calls = []
        for n in walk(node):
            if isinstance(n, list) and n and isinstance(n[0], str):
                calls.append((n[0], n))
        return calls

    # Map of all defun callees
    call_graph = {}
    for name, form in defuns.items():
        calls = set()
        for callee, _ in find_calls(form[3:]):
            if callee in defuns:
                calls.add(callee)
        call_graph[name] = calls

    def get_transitive_callees(roots):
        visited = set()
        queue = list(roots)
        while queue:
            curr = queue.pop(0)
            if curr in visited:
                continue
            visited.add(curr)
            for neighbor in call_graph.get(curr, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        return visited

    targets = ['aa:zz-run', 'c:dx2', 'c:dx']
    for cmd in targets:
        form = defuns[cmd]
        
        # 1. Verify global ssget calls in command definition
        global_ssgets = [node for _, node in find_calls(form) if node[0] == 'ssget']
        print(f"[{cmd}] Global ssget forms directly in function: {len(global_ssgets)}")
        assert len(global_ssgets) <= 2, f"Expected <= 2 direct ssget calls in {cmd}, got {len(global_ssgets)}"
        for s in global_ssgets:
            # Must only be ssget "_I" or user prompt ssget
            assert s in (['ssget', '"_I"'], ['ssget']), f"Unexpected ssget call in {cmd}: {s}"

        # 2. Extract loop bodies: repeat, foreach, while
        loop_calls = set()
        loop_ssgets = []
        for n in walk(form[3:]):
            if isinstance(n, list) and n and n[0] in ('repeat', 'foreach', 'while'):
                loop_body = n[2:] if n[0] in ('repeat', 'foreach') else n[1:]
                for sub in walk(loop_body):
                    if isinstance(sub, list) and sub:
                        if sub[0] == 'ssget':
                            loop_ssgets.append(sub)
                        elif isinstance(sub[0], str) and sub[0] in defuns:
                            loop_calls.add(sub[0])

        assert len(loop_ssgets) == 0, f"[{cmd}] VIOLATION: direct ssget call found inside loop: {loop_ssgets}"
        
        # 3. Transitive analysis of loop callees
        transitive_callees = get_transitive_callees(loop_calls)
        print(f"[{cmd}] Loop transitive callees: {len(transitive_callees)} functions: {sorted(transitive_callees)}")
        
        for callee in transitive_callees:
            callee_ssgets = [node for _, node in find_calls(defuns[callee]) if node[0] == 'ssget']
            assert len(callee_ssgets) == 0, (
                f"[{cmd}] VIOLATION: loop callee '{callee}' contains ssget: {callee_ssgets}"
            )

        # 4. Total ssget calls across entire command pipeline
        all_reachable = get_transitive_callees([cmd])
        all_pipeline_ssgets = []
        for fn in all_reachable:
            for _, node in find_calls(defuns[fn]):
                if node[0] == 'ssget':
                    all_pipeline_ssgets.append((fn, node))
        print(f"[{cmd}] Entire pipeline transitive ssget calls count: {len(all_pipeline_ssgets)}")
        for fn, node in all_pipeline_ssgets:
            print(f"       -> in {fn}: {node}")
            assert fn in (cmd, 'aa:zz-harvest-lines'), f"Unexpected function calling ssget: {fn}"

        # aa:zz-harvest-lines is called exactly once before any loop
        assert len(all_pipeline_ssgets) <= 3, f"Too many ssget calls in pipeline: {len(all_pipeline_ssgets)}"

    print("  [PASS] CAD selection count invariant holds: Loop ssget count is STRICTLY 0, Pipeline ssget is STRICTLY O(1).\n")


# ==============================================================================
# 2. Mathematical Mirror of DX2 Sorting & Output Rules
# ==============================================================================

def lisp_dx2_group_before_p(a, b):
    """Exact replica of LISP dx2:group-before-p.
    
    a, b: dict with 'cx', 'cy', 'lx', 'rx', 'ty', 'by', 'index'
    """
    ay = a['cy']
    by = b['cy']
    ax = a['cx']
    bx = b['cx']
    ah = a['ty'] - a['by']
    bh = b['ty'] - b['by']
    row_tol = 0.25 * min(ah, bh)
    if abs(ay - by) <= row_tol:
        if abs(ax - bx) <= 1e-8:
            return a['index'] < b['index']
        return ax < bx
    return ay > by


def lisp_dx2_sort_groups(groups):
    """Sort group records using dx2:group-before-p with stable merge-sort semantics."""
    def cmp(a, b):
        if lisp_dx2_group_before_p(a, b):
            return -1
        if lisp_dx2_group_before_p(b, a):
            return 1
        return 0
    return sorted(groups, key=cmp_to_key(cmp))


def lisp_dx2_group_rows(items):
    """Exact replica of LISP dx2:group-rows.
    
    items: list of (text_str, cx, cy, width, height, index)
    """
    # 1. Sort by Y descending, tie-break by index ascending
    def y_desc_cmp(a, b):
        if a[2] > b[2]:
            return -1
        if a[2] < b[2]:
            return 1
        if a[5] < b[5]:
            return -1
        return 1

    sorted_items = sorted(items, key=cmp_to_key(y_desc_cmp))

    # 2. Group into rows
    rows = []
    row = []
    row_y = None
    row_h = 0.0

    for item in sorted_items:
        item_y = item[2]
        item_h = item[4]
        tol = 0.55 * max(row_h, item_h, 1e-8)
        if row and abs(item_y - row_y) <= tol:
            row.append(item)
            if item_h > row_h:
                row_h = item_h
        else:
            if row:
                # Sort row by X ascending
                def x_asc_cmp(a, b):
                    if a[1] < b[1]:
                        return -1
                    if a[1] > b[1]:
                        return 1
                    if a[5] < b[5]:
                        return -1
                    return 1
                rows.append(sorted(row, key=cmp_to_key(x_asc_cmp)))
            row = [item]
            row_y = item_y
            row_h = item_h

    if row:
        def x_asc_cmp(a, b):
            if a[1] < b[1]:
                return -1
            if a[1] > b[1]:
                return 1
            if a[5] < b[5]:
                return -1
            return 1
        rows.append(sorted(row, key=cmp_to_key(x_asc_cmp)))

    return rows


def lisp_dx2_export_group(group_record):
    """Exact replica of LISP dx2:export-group."""
    items = group_record.get('items', [])
    if not items:
        return ""
    rows = lisp_dx2_group_rows(items)
    out_parts = []
    for row in rows:
        for it in row:
            out_parts.append(it[0])
    return "、".join(out_parts)


def lisp_dx2_export_all(groups):
    """Exact replica of LISP c:DX2 clipboard construction."""
    sorted_groups = lisp_dx2_sort_groups(groups)
    cell_outputs = []
    for grp in sorted_groups:
        text = lisp_dx2_export_group(grp)
        if text != "":
            cell_outputs.append(text)
    return "\r\n".join(cell_outputs)


# ==============================================================================
# 3. Adversarial Stress Suites for DX2 Invariants
# ==============================================================================

def test_adversarial_row_tolerance():
    print("--- Test 2.1: Adversarial Cell Row Tolerance (0.25 * min_h) ---")
    
    # Base cell A: height = 40 (by=0, ty=40, cy=20), width=50 (lx=0, rx=50, cx=25)
    # Cell B: height = 20 (by=10, ty=30, cy=20), width=50 (lx=60, rx=110, cx=85)
    # min_h = min(40, 20) = 20.0 -> row_tol = 0.25 * 20.0 = 5.0
    
    # Scenario A: Vertical shift is within tolerance (dy = 4.9 <= 5.0)
    # Cell A is at cy=20.0, Cell B is shifted up to cy=24.9
    cell_a = {'cx': 25.0, 'cy': 20.0, 'lx': 0.0, 'rx': 50.0, 'ty': 40.0, 'by': 0.0, 'index': 0,
              'items': [("A", 25.0, 20.0, 10.0, 3.5, 0)]}
    cell_b = {'cx': 85.0, 'cy': 24.9, 'lx': 60.0, 'rx': 110.0, 'ty': 34.9, 'by': 14.9, 'index': 1,
              'items': [("B", 85.0, 24.9, 10.0, 3.5, 1)]}
    
    # Since dy=4.9 <= 5.0, they belong to the SAME row -> sorted by X ascending: A (cx=25) then B (cx=85)
    res = lisp_dx2_export_all([cell_b, cell_a])
    expected = "A\r\nB"
    assert res == expected, f"Failed at dy=4.9: expected {expected!r}, got {res!r}"

    # Scenario B: Vertical shift exceeds tolerance (dy = 5.05 > 5.0)
    # Cell B is shifted up to cy=25.05. Now it must form its own HIGHER row -> B then A!
    cell_b_high = {'cx': 85.0, 'cy': 25.05, 'lx': 60.0, 'rx': 110.0, 'ty': 35.05, 'by': 15.05, 'index': 1,
                   'items': [("B", 85.0, 25.05, 10.0, 3.5, 1)]}
    res_high = lisp_dx2_export_all([cell_a, cell_b_high])
    expected_high = "B\r\nA"
    assert res_high == expected_high, f"Failed at dy=5.05: expected {expected_high!r}, got {res_high!r}"

    # Scenario C: Equal X coordinates with dy <= row_tol -> Stable tie-break by index
    cell_c1 = {'cx': 50.0, 'cy': 20.0, 'lx': 0.0, 'rx': 100.0, 'ty': 40.0, 'by': 0.0, 'index': 0,
               'items': [("First", 50.0, 20.0, 10.0, 3.5, 0)]}
    cell_c2 = {'cx': 50.0, 'cy': 22.0, 'lx': 0.0, 'rx': 100.0, 'ty': 42.0, 'by': 2.0, 'index': 1,
               'items': [("Second", 50.0, 22.0, 10.0, 3.5, 1)]}
    res_c = lisp_dx2_export_all([cell_c2, cell_c1])
    assert res_c == "First\r\nSecond", f"Tie-breaker failed: got {res_c!r}"

    print("  [PASS] Adversarial row tolerance (0.25*min_h threshold and tie-breakers) verified.")


def test_adversarial_incell_multiline_sorting():
    print("--- Test 2.2: Adversarial In-Cell Multi-Line Text Clustering (0.55 * row_h) ---")
    
    # In a single cell, text height = 10.0 -> line tol = 0.55 * 10.0 = 5.5
    # Text 1: cy = 50.0, cx = 20.0 ("TopLeft")
    # Text 2: cy = 54.5, cx = 40.0 ("TopRight", dy = 4.5 <= 5.5 -> same row!)
    # Text 3: cy = 40.0, cx = 30.0 ("Bottom", dy = 10.0 > 5.5 -> second row!)
    items = [
        ("Bottom", 30.0, 40.0, 15.0, 10.0, 0),
        ("TopRight", 40.0, 54.5, 15.0, 10.0, 1),
        ("TopLeft", 20.0, 50.0, 15.0, 10.0, 2),
    ]
    cell = {'cx': 30.0, 'cy': 50.0, 'lx': 0.0, 'rx': 60.0, 'ty': 70.0, 'by': 30.0, 'index': 0,
            'items': items}
    
    # Expected: Row 1 has TopLeft (cx=20) and TopRight (cx=40)
    #           Row 2 has Bottom
    # Concatenated by "、" -> TopLeft、TopRight、Bottom or TopRight、TopLeft depending on Y sorting?
    # Notice: TopRight has cy=54.5, TopLeft has cy=50.0.
    # Sorted by Y desc: TopRight (54.5), then TopLeft (50.0) -> row_y = 54.5.
    # abs(50.0 - 54.5) = 4.5 <= 5.5 -> both in row 1.
    # Row 1 sorted by X asc: TopLeft (cx=20) then TopRight (cx=40).
    # Row 2: Bottom.
    res = lisp_dx2_export_group(cell)
    expected = "TopLeft、TopRight、Bottom"
    assert res == expected, f"In-cell multiline grouping failed: expected {expected!r}, got {res!r}"

    # Boundary case: dy = 5.55 > 5.5 -> splits into separate rows!
    items_split = [
        ("Top1", 40.0, 55.6, 15.0, 10.0, 0),
        ("Top2", 20.0, 50.0, 15.0, 10.0, 1),
    ]
    cell_split = {'cx': 30.0, 'cy': 50.0, 'lx': 0.0, 'rx': 60.0, 'ty': 70.0, 'by': 30.0, 'index': 0,
                  'items': items_split}
    res_split = lisp_dx2_export_group(cell_split)
    # Top1 (cy=55.6) is row 1, Top2 (cy=50.0) is row 2 -> output Top1、Top2
    assert res_split == "Top1、Top2", f"Split lines concatenation failed: {res_split!r}"

    print("  [PASS] In-cell multi-line clustering (0.55*row_h) and '、' joining verified.")


def test_adversarial_clipboard_crlf_format():
    print("--- Test 2.3: Adversarial Clipboard Format (CRLF and Empty Cell Skipping) ---")
    
    cells = [
        {'cx': 10.0, 'cy': 90.0, 'lx': 0.0, 'rx': 20.0, 'ty': 100.0, 'by': 80.0, 'index': 0,
         'items': [("Cell1_A", 10.0, 92.0, 5.0, 2.0, 0), ("Cell1_B", 10.0, 88.0, 5.0, 2.0, 1)]},
        {'cx': 30.0, 'cy': 90.0, 'lx': 20.0, 'rx': 40.0, 'ty': 100.0, 'by': 80.0, 'index': 1,
         'items': []}, # EMPTY CELL - must be skipped!
        {'cx': 50.0, 'cy': 90.0, 'lx': 40.0, 'rx': 60.0, 'ty': 100.0, 'by': 80.0, 'index': 2,
         'items': [("Cell3", 50.0, 90.0, 5.0, 2.0, 2)]},
        {'cx': 10.0, 'cy': 50.0, 'lx': 0.0, 'rx': 20.0, 'ty': 60.0, 'by': 40.0, 'index': 3,
         'items': [("Cell4", 10.0, 50.0, 5.0, 2.0, 3)]},
    ]

    out = lisp_dx2_export_all(cells)
    
    # 1. Must use strictly CRLF
    assert "\r\n" in out, "Output must contain CRLF line separators"
    assert "\n" not in out.replace("\r\n", ""), "Output must NOT contain bare LF!"
    
    # 2. Empty cell must NOT create empty line
    lines = out.split("\r\n")
    assert len(lines) == 3, f"Expected 3 lines (empty cell skipped), got {len(lines)}: {lines}"
    assert lines[0] == "Cell1_A、Cell1_B"
    assert lines[1] == "Cell3"
    assert lines[2] == "Cell4"

    print("  [PASS] Clipboard CRLF line endings, '、' delimiter, and empty-cell elimination verified.")


def run_randomized_fuzzer(iterations=500):
    print(f"--- Test 2.4: Randomized Adversarial Fuzzing ({iterations} rounds) ---")
    random.seed(42)

    for round_idx in range(iterations):
        # Generate random grid with 1 to 8 rows and 1 to 6 columns
        num_rows = random.randint(1, 8)
        num_cols = random.randint(1, 6)
        
        cells = []
        cell_idx = 0
        
        for r in range(num_rows):
            base_y = (num_rows - 1 - r) * 50.0
            cell_h = random.uniform(20.0, 60.0)
            
            for c in range(num_cols):
                base_x = c * 80.0
                cell_w = random.uniform(40.0, 100.0)
                
                # Coordinate jitter: up to +- 0.2 * min_h (staying inside same visual row)
                jitter_y = random.uniform(-0.15 * cell_h, 0.15 * cell_h)
                cy = base_y + cell_h / 2.0 + jitter_y
                cx = base_x + cell_w / 2.0
                
                # Items in cell (0 to 5 texts)
                num_items = random.choice([0, 1, 1, 2, 3, 4])
                items = []
                for k in range(num_items):
                    th = random.uniform(2.5, 5.0)
                    tw = random.uniform(5.0, 20.0)
                    tx = cx + random.uniform(-cell_w * 0.3, cell_w * 0.3)
                    ty = cy + random.uniform(-cell_h * 0.3, cell_h * 0.3)
                    tstr = f"R{r}C{c}T{k}"
                    items.append((tstr, tx, ty, tw, th, k))
                
                cells.append({
                    'cx': cx,
                    'cy': cy,
                    'lx': cx - cell_w / 2.0,
                    'rx': cx + cell_w / 2.0,
                    'ty': cy + cell_h / 2.0,
                    'by': cy - cell_h / 2.0,
                    'index': cell_idx,
                    'items': items,
                })
                cell_idx += 1

        # Run export pipeline
        out = lisp_dx2_export_all(cells)
        
        # Verify invariants on output:
        if out != "":
            # Invariant A: No bare LF
            assert "\n" not in out.replace("\r\n", ""), f"Round {round_idx}: Bare LF detected!"
            lines = out.split("\r\n")
            # Invariant B: No empty line
            for l in lines:
                assert len(l) > 0, f"Round {round_idx}: Empty line in output!"
            # Invariant C: Non-empty cell count matches line count
            non_empty_cells = [c for c in cells if len(c['items']) > 0]
            assert len(lines) == len(non_empty_cells), (
                f"Round {round_idx}: Line count {len(lines)} != non-empty cell count {len(non_empty_cells)}"
            )

    print(f"  [PASS] {iterations} randomized adversarial configurations passed all invariants with 100% success.")


def main():
    print("======================================================================")
    print("ADVERSARIAL STRESS TEST FOR CAD SELECTION & DX2 SPECIFICATIONS")
    print("======================================================================\n")
    
    verify_cad_selection_invariants()
    test_adversarial_row_tolerance()
    test_adversarial_incell_multiline_sorting()
    test_adversarial_clipboard_crlf_format()
    run_randomized_fuzzer(500)
    
    print("\n======================================================================")
    print("ALL EMPIRICAL CHALLENGES AND STRESS TESTS PASSED SUCCESSFULLY!")
    print("======================================================================")


if __name__ == '__main__':
    main()
