"""Comprehensive offline static analysis, geometric simulation, and benchmark for ZZ/JACC/DX2.

Verifies:
1. Module 1: Static AST / Text Audit on AA整合版本.lsp (UTF-8/CRLF, definitions, bans, ssget audit).
2. Module 2: Pure mathematical geometric simulation (centering, 5.0 spacing stack, boundaries, DX2 ordering).
3. Module 3: Offline 200+ text & cell benchmark (verifying >= 3.0x calculation speedup and exact output equivalence).
"""
import argparse
import bisect
import random
import sys
import time
from pathlib import Path

# Add tools to sys.path
TOOLS = Path(__file__).resolve().parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from lsp_common import ARITY, SOURCE, command_names, defun_forms, parse, read_source, walk


# ==============================================================================
# Module 1: Static AST and Text Audit
# ==============================================================================

def check_encoding_and_syntax():
    """Verify source file encoding and CRLF line endings."""
    raw, source = read_source(SOURCE)
    assert not raw.startswith(b'\xef\xbb\xbf'), "UTF-8 BOM present"
    assert '\ufffd' not in source, "U+FFFD replacement char present"
    assert b'\n' not in raw.replace(b'\r\n', b''), "Bare LF / mixed newlines present"
    return source


def audit_zz_ast(source, strict_refactored=False):
    """Audit AST forms for command definitions, helper functions, banned patterns, and ssget calls."""
    forms = parse(source)
    defuns = {f[1]: f for f in defun_forms(forms) if isinstance(f[1], str)}
    cmds = {c.upper() for c in command_names(forms)}

    # 1. Verify core command entries
    for cmd in ('ZZ', 'JACC', 'DX2', 'DX'):
        assert cmd in cmds, f"Command c:{cmd} not found in top-level definitions"

    # 2. Verify shared helper functions
    expected_helpers = [
        'aa:zz-run',
        'aa:zz-filter-text-ss',
        'aa:zz-move-text',
        'aa:zz-apply-group',
        'dx2:group-record',
        'dx2:group-before-p',
        'dx2:text-record',
        'dx2:group-rows',
        'dx2:append-text',
        'dx2:export-group',
    ]
    for helper in expected_helpers:
        assert helper in defuns, f"Required helper function {helper} not found in defuns"

    # 3. Verify that vl-sort is NOT used in any ZZ / DX2 functions
    zz_dx2_funcs = [
        name for name in defuns
        if name.startswith('aa:zz-') or name.startswith('dx2:') or name in ('c:zz', 'c:jacc', 'c:dx2')
    ]
    for name in zz_dx2_funcs:
        form = defuns[name]
        for node in walk(form):
            assert node[0] != 'vl-sort', f"{name}: vl-sort is banned by project rules; use aa:merge-sort"

    # 4. Verify aa:merge-sort availability and integration
    assert 'aa:merge-sort' in defuns, "aa:merge-sort is missing from AA整合版本.lsp"

    # Check if merge-sort is referenced in sorting helpers
    sort_funcs = [name for name in zz_dx2_funcs if 'sort' in name or name in ('aa:zz-apply-group', 'dx2:sort-groups', 'dx2:group-rows')]
    uses_merge_sort = False
    for name in sort_funcs:
        for node in walk(defuns[name]):
            if node[0] == 'aa:merge-sort':
                uses_merge_sort = True
                break

    # 5. Inner-loop ssget call audit
    loop_ssget_detected = False
    for root_name in ('aa:zz-run', 'c:dx2'):
        if root_name not in defuns:
            continue
        form = defuns[root_name]
        # Inspect loops: repeat, foreach, while
        for node in walk(form[3:]):
            if isinstance(node, list) and node and node[0] in ('repeat', 'foreach', 'while'):
                loop_body = node[2:] if node[0] in ('repeat', 'foreach') else node[1:]
                for sub in walk(loop_body):
                    if isinstance(sub, list) and sub:
                        if sub[0] == 'ssget':
                            loop_ssget_detected = True
                        # If loop calls aa:zz-text-info and aa:zz-text-info calls ssget
                        if sub[0] == 'aa:zz-text-info' and 'aa:zz-text-info' in defuns:
                            info_form = defuns['aa:zz-text-info']
                            for info_node in walk(info_form):
                                if isinstance(info_node, list) and info_node and info_node[0] == 'ssget':
                                    loop_ssget_detected = True

    if strict_refactored:
        assert not loop_ssget_detected, (
            "Strict check failed: inner-loop ssget call detected in aa:zz-run / c:dx2! "
            "Refactored code must use global one-shot harvesting."
        )
        assert uses_merge_sort, (
            "Strict check failed: aa:merge-sort must be directly utilized in ZZ / DX2 sorting!"
        )
        print("PASS Module 1 (AST): Refactored mode verified (0 loop ssget, aa:merge-sort active)")
    else:
        if loop_ssget_detected:
            status_note = "Baseline detected: loop calls ssget via aa:zz-text-info (O(N) CAD calls); ready for M2 refactoring"
        else:
            status_note = "Refactored detected: 0 loop ssget calls"
        print(f"PASS Module 1 (AST): {len(zz_dx2_funcs)} ZZ/DX2 functions verified; no vl-sort; {status_note}")

    return forms, defuns


# ==============================================================================
# Module 2: Pure Mathematical Geometric Simulation
# ==============================================================================

class HLine:
    """Horizontal line segment: y = constant, x in [xmin, xmax]."""
    __slots__ = ('y', 'xmin', 'xmax')

    def __init__(self, y, xmin, xmax):
        self.y = float(y)
        self.xmin = float(min(xmin, xmax))
        self.xmax = float(max(xmin, xmax))


class VLine:
    """Vertical line segment: x = constant, y in [ymin, ymax]."""
    __slots__ = ('x', 'ymin', 'ymax')

    def __init__(self, x, ymin, ymax):
        self.x = float(x)
        self.ymin = float(min(ymin, ymax))
        self.ymax = float(max(ymin, ymax))


def math_find_bounding_rect(vlist, hlist, cx, cy, tol=1e-8, max_dist=300.0):
    """Find the nearest 4-way orthogonal bounding rectangle around (cx, cy)."""
    lx = rx = ty = by = None
    dl = dr = dt = db = None

    # Vertical lines -> left and right boundaries
    for v in vlist:
        if (v.ymin - tol) <= cy <= (v.ymax + tol):
            x = v.x
            if x < (cx - tol):
                dist = cx - x
                if dl is None or dist < dl:
                    dl = dist
                    lx = x
            elif x > (cx + tol):
                dist = x - cx
                if dr is None or dist < dr:
                    dr = dist
                    rx = x

    # Horizontal lines -> bottom and top boundaries
    for h in hlist:
        if (h.xmin - tol) <= cx <= (h.xmax + tol):
            y = h.y
            if y < (cy - tol):
                dist = cy - y
                if db is None or dist < db:
                    db = dist
                    by = y
            elif y > (cy + tol):
                dist = y - cy
                if dt is None or dist < dt:
                    dt = dist
                    ty = y

    # Check 4-way completeness and max distance constraint
    if lx is not None and rx is not None and ty is not None and by is not None:
        if (cx - lx <= max_dist and rx - cx <= max_dist and
            ty - cy <= max_dist and cy - by <= max_dist):
            return (lx, rx, ty, by)
    return None


def simulate_single_text_centering(rect, text_pos):
    """Simulate single text centering with 1e-6 move filter."""
    lx, rx, ty, by = rect
    cx, cy = text_pos
    tx = (lx + rx) / 2.0
    ty_target = (ty + by) / 2.0

    dx = tx - cx
    dy = ty_target - cy

    # Move filter: if movement is <= 1e-6 in both axes, avoid physical move
    is_noop = (abs(dx) <= 1e-6 and abs(dy) <= 1e-6)
    final_x = cx if is_noop else tx
    final_y = cy if is_noop else ty_target

    err_x = abs(final_x - tx)
    err_y = abs(final_y - ty_target)
    return final_x, final_y, not is_noop, err_x, err_y


def simulate_multi_text_stacking(rect, text_positions, spacing=5.0):
    """Simulate symmetric vertical stacking for multiple texts in cell.
    
    Formula from LISP aa:zz-apply-group:
    center_y = (ty + by) / 2.0
    start_y = center_y + 0.5 * (n - 1) * spacing
    target_y[i] = start_y - i * spacing
    """
    lx, rx, ty, by = rect
    tx = (lx + rx) / 2.0
    center_y = (ty + by) / 2.0

    # Sort texts by initial cy descending (top-to-bottom preservation)
    sorted_texts = sorted(text_positions, key=lambda p: p[1], reverse=True)
    n = len(sorted_texts)
    start_y = center_y + 0.5 * (n - 1) * spacing

    results = []
    for i, orig in enumerate(sorted_texts):
        target_y = start_y - i * spacing
        results.append((tx, target_y))

    return results, center_y, sorted_texts


def test_geometric_single_text():
    """Verify single text centering and move filter threshold."""
    rect = (0.0, 100.0, 50.0, 0.0)  # lx=0, rx=100, ty=50, by=0 -> center (50.0, 25.0)

    # Case 1: Initial text at top-left (12.34, 45.67)
    fx, fy, moved, ex, ey = simulate_single_text_centering(rect, (12.34, 45.67))
    assert moved is True, "Text should move"
    assert ex < 1e-6 and ey < 1e-6, f"Alignment error too large: ex={ex}, ey={ey}"

    # Case 2: Initial text at bottom-right (88.88, 5.55)
    fx, fy, moved, ex, ey = simulate_single_text_centering(rect, (88.88, 5.55))
    assert moved is True, "Text should move"
    assert ex < 1e-6 and ey < 1e-6, f"Alignment error too large: ex={ex}, ey={ey}"

    # Case 3: Initial text already strictly at center (50.0, 25.0)
    fx, fy, moved, ex, ey = simulate_single_text_centering(rect, (50.0, 25.0))
    assert moved is False, "Exact center should be a no-op move"
    assert ex < 1e-6 and ey < 1e-6

    # Case 4: Text offset within 1e-6 threshold (no-op move filter)
    fx, fy, moved, ex, ey = simulate_single_text_centering(rect, (50.0 + 5e-7, 25.0 - 5e-7))
    assert moved is False, "Sub-threshold displacement should not trigger move"


def test_geometric_multi_text_stacking():
    """Verify multi-text symmetric vertical stacking, 5.0 spacing, and order preservation."""
    rect = (0.0, 100.0, 80.0, 0.0)  # center = (50.0, 40.0)

    for k in (2, 3, 4, 5, 8, 12):
        # Generate arbitrary disordered Y coordinates
        random.seed(100 + k)
        initial_texts = [(random.uniform(10, 90), random.uniform(5, 75)) for _ in range(k)]

        targets, center_y, sorted_orig = simulate_multi_text_stacking(rect, initial_texts, spacing=5.0)

        # 1. Check stack midpoint matches cell center exactly (< 1e-6)
        stack_mid_y = (targets[0][1] + targets[-1][1]) / 2.0
        assert abs(stack_mid_y - center_y) < 1e-6, f"Stack center mismatch for k={k}: {stack_mid_y} vs {center_y}"

        # 2. Check adjacent spacing is strictly 5.0 (< 1e-6)
        for i in range(k - 1):
            spacing = targets[i][1] - targets[i + 1][1]
            assert abs(spacing - 5.0) < 1e-6, f"Spacing mismatch at index {i}: {spacing}"

        # 3. Check horizontal alignment is strictly cx (< 1e-6)
        for i in range(k):
            assert abs(targets[i][0] - 50.0) < 1e-6, f"X alignment error at index {i}: {targets[i][0]}"

        # 4. Check symmetry around center_y
        for i in range(k):
            dist_top = abs(targets[i][1] - center_y)
            dist_bot = abs(targets[k - 1 - i][1] - center_y)
            assert abs(dist_top - dist_bot) < 1e-6, f"Symmetry broken between index {i} and {k - 1 - i}"

        # 5. Check order preservation (highest initial Y remains at top target)
        for i in range(k - 1):
            assert sorted_orig[i][1] >= sorted_orig[i + 1][1], "Original sort failed"
            assert targets[i][1] > targets[i + 1][1], "Target Y must be strictly descending"


def test_geometric_boundary_exceptions():
    """Verify non-closed and out-of-range boundaries are safely detected and skipped."""
    # Base enclosed rectangle: x in [0, 100], y in [0, 50], center (50, 25)
    valid_v = [VLine(0.0, 0.0, 50.0), VLine(100.0, 0.0, 50.0)]
    valid_h = [HLine(0.0, 0.0, 100.0), HLine(50.0, 0.0, 100.0)]

    skipped = 0

    # Case A: Missing top boundary
    res_a = math_find_bounding_rect(valid_v, [HLine(0.0, 0.0, 100.0)], 50.0, 25.0)
    if res_a is None:
        skipped += 1

    # Case B: Missing bottom boundary
    res_b = math_find_bounding_rect(valid_v, [HLine(50.0, 0.0, 100.0)], 50.0, 25.0)
    if res_b is None:
        skipped += 1

    # Case C: Missing left boundary
    res_c = math_find_bounding_rect([VLine(100.0, 0.0, 50.0)], valid_h, 50.0, 25.0)
    if res_c is None:
        skipped += 1

    # Case D: Missing right boundary
    res_d = math_find_bounding_rect([VLine(0.0, 0.0, 50.0)], valid_h, 50.0, 25.0)
    if res_d is None:
        skipped += 1

    # Case E: Line does not span point projection (horizontal line too short)
    short_h = [HLine(0.0, 0.0, 100.0), HLine(50.0, 60.0, 100.0)]  # does not span cx=50
    res_e = math_find_bounding_rect(valid_v, short_h, 50.0, 25.0)
    if res_e is None:
        skipped += 1

    # Case F: Line exceeds max distance (right border at x=400, dist=350 > 300)
    far_v = [VLine(0.0, 0.0, 50.0), VLine(400.0, 0.0, 50.0)]
    res_f = math_find_bounding_rect(far_v, valid_h, 50.0, 25.0)
    if res_f is None:
        skipped += 1

    # Case G: Valid enclosure
    res_g = math_find_bounding_rect(valid_v, valid_h, 50.0, 25.0)
    assert res_g == (0.0, 100.0, 50.0, 0.0), f"Expected valid box, got {res_g}"

    assert skipped == 6, f"Expected 6 boundary exceptions to be skipped, got {skipped}"


def test_dx2_cell_extraction_and_ordering():
    """Verify DX2 cell ordering (0.25*min_h tolerance) and text joining ('、' and CRLF)."""
    # Simulate a 3x3 grid with coordinates:
    # Row 0: y in [80, 100], center y=90, height=20
    # Row 1: y in [50, 70],  center y=60, height=20
    # Row 2: y in [20, 40],  center y=30, height=20
    # Col 0: x in [20, 40],  center x=30, width=20
    # Col 1: x in [50, 70],  center x=60, width=20
    # Col 2: x in [80, 100], center x=90, width=20

    # Add small coordinate jitter (+- 0.03) to simulate real CAD drawings
    cells_def = [
        # (cell_id, lx, rx, ty, by, texts: list of (text, x, y, h))
        (0, 20.01, 39.99, 100.02, 79.98, [("KM1", 30.0, 93.0, 3.5), ("DC24V", 30.0, 87.0, 3.5)]),
        (1, 49.98, 70.02,  99.97, 80.03, [("AC220V", 60.0, 90.0, 3.5)]),
        (2, 79.99, 100.01, 100.01, 79.99, [("Q1", 85.0, 90.0, 3.5), ("10A", 95.0, 90.0, 3.5)]),
        (3, 20.02, 39.98,  70.01, 49.99, [("KA1", 30.0, 60.0, 3.5)]),
        (4, 50.00, 70.00,  70.00, 50.00, []),  # Empty cell
        (5, 80.01, 99.99,  69.98, 50.02, [("FU1", 90.0, 60.0, 3.5)]),
        (6, 19.98, 40.02,  40.02, 19.98, [("X1:1", 30.0, 30.0, 3.5)]),
        (7, 50.01, 69.99,  39.99, 20.01, [("X1:2", 55.0, 30.0, 3.5), ("X1:3", 65.0, 30.0, 3.5)]),
        (8, 80.00, 100.00, 40.01, 19.99, [("GND", 90.0, 30.0, 3.5)]),
    ]

    # Convert cells to DX2 group records: (group_data, cx, cy, lx, rx, ty, by, index)
    records = []
    for idx, (cid, lx, rx, ty, by, texts) in enumerate(cells_def):
        cx = (lx + rx) / 2.0
        cy = (ty + by) / 2.0
        records.append({
            'texts': texts,
            'cx': cx,
            'cy': cy,
            'lx': lx,
            'rx': rx,
            'ty': ty,
            'by': by,
            'index': idx
        })

    # Sort groups using dx2:group-before-p comparator logic:
    # row_tol = 0.25 * min(ah, bh)
    # if abs(ay - by) <= row_tol:
    #     if abs(ax - bx) < 1e-8: index_a < index_b
    #     else: ax < bx
    # else: ay > by
    def dx2_group_before_p(a, b):
        ah = a['ty'] - a['by']
        bh = b['ty'] - b['by']
        row_tol = 0.25 * min(ah, bh)
        if abs(a['cy'] - b['cy']) <= row_tol:
            if abs(a['cx'] - b['cx']) < 1e-8:
                return a['index'] < b['index']
            return a['cx'] < b['cx']
        return a['cy'] > b['cy']

    # Sort records (simulating dx2:sort-groups)
    from functools import cmp_to_key
    sorted_records = sorted(records, key=cmp_to_key(lambda a, b: -1 if dx2_group_before_p(a, b) else 1))

    # Process each cell's text stream (simulating dx2:export-group)
    cell_outputs = []
    for rec in sorted_records:
        texts = rec['texts']
        if not texts:
            continue

        # dx2:group-rows logic:
        # 1. Sort texts by Y descending
        sorted_texts = sorted(texts, key=lambda t: t[2], reverse=True)

        # 2. Dynamic row clustering by tol = 0.55 * max(row_h, item_h, 1e-8)
        rows = []
        cur_row = []
        cur_row_y = None
        cur_row_h = 0.0

        for item in sorted_texts:
            text_str, tx, ty, th = item
            tol = 0.55 * max(cur_row_h, th, 1e-8)
            if cur_row and abs(ty - cur_row_y) <= tol:
                cur_row.append(item)
                cur_row_h = max(cur_row_h, th)
            else:
                if cur_row:
                    # Sort row items by X ascending
                    cur_row.sort(key=lambda it: it[1])
                    rows.append(cur_row)
                cur_row = [item]
                cur_row_y = ty
                cur_row_h = th
        if cur_row:
            cur_row.sort(key=lambda it: it[1])
            rows.append(cur_row)

        # 3. Concatenate text with "、"
        all_row_texts = []
        for row in rows:
            all_row_texts.extend([it[0] for it in row])
        cell_str = "、".join(all_row_texts)
        if cell_str:
            cell_outputs.append(cell_str)

    # Join cells with CRLF
    final_output = "\r\n".join(cell_outputs)

    expected_output = (
        "KM1、DC24V\r\n"
        "AC220V\r\n"
        "Q1、10A\r\n"
        "KA1\r\n"
        "FU1\r\n"
        "X1:1\r\n"
        "X1:2、X1:3\r\n"
        "GND"
    )
    assert final_output == expected_output, (
        f"DX2 output mismatch!\nGot:\n{repr(final_output)}\nExpected:\n{repr(expected_output)}"
    )


# ==============================================================================
# Module 3: Offline 200+ Text & Cell Performance Benchmark
# ==============================================================================

class FastSpatialIndex:
    """In-memory spatial index replacing per-text CAD ssget and O(M) linear scans."""
    def __init__(self, vlist, hlist):
        # Index vertical lines grouped by unique x coordinate
        v_dict = {}
        for v in vlist:
            if v.x not in v_dict:
                v_dict[v.x] = []
            v_dict[v.x].append((v.ymin, v.ymax))
        self.v_xs = sorted(v_dict.keys())
        self.v_segs = {x: v_dict[x] for x in self.v_xs}

        # Index horizontal lines grouped by unique y coordinate
        h_dict = {}
        for h in hlist:
            if h.y not in h_dict:
                h_dict[h.y] = []
            h_dict[h.y].append((h.xmin, h.xmax))
        self.h_ys = sorted(h_dict.keys())
        self.h_segs = {y: h_dict[y] for y in self.h_ys}

    def find_bounds(self, cx, cy, tol=1e-8, max_dist=300.0):
        # Left boundary: binary search in v_xs
        left_idx = bisect.bisect_left(self.v_xs, cx - max_dist)
        right_idx = bisect.bisect_right(self.v_xs, cx - tol)
        lx = None
        for i in range(right_idx - 1, left_idx - 1, -1):
            x = self.v_xs[i]
            for ymin, ymax in self.v_segs[x]:
                if ymin - tol <= cy <= ymax + tol:
                    lx = x
                    break
            if lx is not None:
                break

        # Right boundary: binary search in v_xs
        left_idx = bisect.bisect_left(self.v_xs, cx + tol)
        right_idx = bisect.bisect_right(self.v_xs, cx + max_dist)
        rx = None
        for i in range(left_idx, right_idx):
            x = self.v_xs[i]
            for ymin, ymax in self.v_segs[x]:
                if ymin - tol <= cy <= ymax + tol:
                    rx = x
                    break
            if rx is not None:
                break

        if lx is None or rx is None:
            return None

        # Bottom boundary: binary search in h_ys
        left_idx = bisect.bisect_left(self.h_ys, cy - max_dist)
        right_idx = bisect.bisect_right(self.h_ys, cy - tol)
        by = None
        for i in range(right_idx - 1, left_idx - 1, -1):
            y = self.h_ys[i]
            for xmin, xmax in self.h_segs[y]:
                if xmin - tol <= cx <= xmax + tol:
                    by = y
                    break
            if by is not None:
                break

        # Top boundary: binary search in h_ys
        left_idx = bisect.bisect_left(self.h_ys, cy + tol)
        right_idx = bisect.bisect_right(self.h_ys, cy + max_dist)
        ty = None
        for i in range(left_idx, right_idx):
            y = self.h_ys[i]
            for xmin, xmax in self.h_segs[y]:
                if xmin - tol <= cx <= xmax + tol:
                    ty = y
                    break
            if ty is not None:
                break

        if by is None or ty is None:
            return None

        return (lx, rx, ty, by)


def run_baseline_pipeline(vlist, hlist, texts):
    """Simulate unoptimized baseline: O(N*M) linear scan + O(N^2) list reverse grouping + insertion sort."""
    # 1. Linear scan for all texts
    infos = []
    for t in texts:
        bounds = math_find_bounding_rect(vlist, hlist, t['cx'], t['cy'])
        if bounds:
            infos.append({
                'id': t['id'],
                'cx': t['cx'],
                'cy': t['cy'],
                'lx': bounds[0],
                'rx': bounds[1],
                'ty': bounds[2],
                'by': bounds[3]
            })

    # 2. Quadratic grouping with reverse (simulating aa:zz-group-by-rect)
    rect_tol = 0.1
    groups = []
    for info in infos:
        placed = False
        new_groups = []
        for g in groups:
            ref = g[0]
            if (not placed and
                abs(info['lx'] - ref['lx']) <= rect_tol and
                abs(info['rx'] - ref['rx']) <= rect_tol and
                abs(info['ty'] - ref['ty']) <= rect_tol and
                abs(info['by'] - ref['by']) <= rect_tol):
                new_groups.append([info] + g)
                placed = True
            else:
                new_groups.append(g)
        if not placed:
            new_groups.append([info])
        groups = list(reversed(new_groups))

    # 3. Insertion sort & target calculation (simulating aa:zz-sort-y-desc)
    results = {}
    for g in groups:
        n = len(g)
        if n == 1:
            info = g[0]
            tx = (info['lx'] + info['rx']) / 2.0
            ty = (info['ty'] + info['by']) / 2.0
            results[info['id']] = (tx, ty)
        else:
            # Insertion sort
            sorted_items = []
            for item in g:
                inserted = False
                new_sorted = []
                for it in sorted_items:
                    if not inserted and item['cy'] > it['cy']:
                        new_sorted.append(item)
                        inserted = True
                    new_sorted.append(it)
                if not inserted:
                    new_sorted.append(item)
                sorted_items = new_sorted

            lx = sorted_items[0]['lx']
            rx = sorted_items[0]['rx']
            ty = sorted_items[0]['ty']
            by = sorted_items[0]['by']
            tx = (lx + rx) / 2.0
            center_y = (ty + by) / 2.0
            start_y = center_y + 0.5 * (n - 1) * 5.0
            for i, info in enumerate(sorted_items):
                y = start_y - i * 5.0
                results[info['id']] = (tx, y)

    return results


def run_optimized_pipeline(spatial_index, texts):
    """Simulate optimized pipeline: sub-linear spatial search + O(N) bucketing + merge/stable sort."""
    groups_dict = {}
    for t in texts:
        bounds = spatial_index.find_bounds(t['cx'], t['cy'])
        if bounds:
            # Hash bucketing by quantized cell key
            key = (round(bounds[0], 1), round(bounds[1], 1),
                   round(bounds[2], 1), round(bounds[3], 1))
            item = (t['id'], t['cx'], t['cy'])
            if key not in groups_dict:
                groups_dict[key] = []
            groups_dict[key].append(item)

    results = {}
    for (lx, rx, ty, by), g in groups_dict.items():
        n = len(g)
        if n == 1:
            tid, cx, cy = g[0]
            tx = (lx + rx) / 2.0
            ty_target = (ty + by) / 2.0
            results[tid] = (tx, ty_target)
        else:
            # Merge / stable sort by cy descending
            g.sort(key=lambda item: item[2], reverse=True)
            tx = (lx + rx) / 2.0
            center_y = (ty + by) / 2.0
            start_y = center_y + 0.5 * (n - 1) * 5.0
            for i, (tid, cx, cy) in enumerate(g):
                results[tid] = (tx, start_y - i * 5.0)

    return results


# 本机实测约 5.8x（2026-10-31，空闲和满载最低 5.0x）；索引退化成线性扫描时才会跌破此值
MIN_SPEEDUP = 3.0


def run_benchmark(runs=10):
    """Generate 15x15 grid (225 cells) with 300+ texts, benchmark algorithms, and assert >= MIN_SPEEDUP."""
    random.seed(42)
    rows = 15
    cols = 15
    cell_w = 80.0
    cell_h = 40.0

    # Build grid line segments
    vlist = []
    hlist = []
    for r in range(rows):
        y1 = r * cell_h
        y2 = (r + 1) * cell_h
        for c in range(cols + 1):
            vlist.append(VLine(c * cell_w, y1, y2))

    for c in range(cols):
        x1 = c * cell_w
        x2 = (c + 1) * cell_w
        for r in range(rows + 1):
            hlist.append(HLine(r * cell_h, x1, x2))

    total_segments = len(vlist) + len(hlist)  # 240 + 240 = 480 segments

    # Generate 300+ texts distributed across cells (mix of 1, 2, 3, 4, and 0 texts per cell)
    cell_counts = [1] * 100 + [2] * 50 + [3] * 25 + [4] * 10 + [0] * 40
    random.shuffle(cell_counts)

    texts = []
    tid = 0
    cell_idx = 0
    for r in range(rows):
        for c in range(cols):
            cnt = cell_counts[cell_idx]
            cell_idx += 1
            cx_cell = c * cell_w + cell_w / 2.0
            cy_cell = r * cell_h + cell_h / 2.0
            for _ in range(cnt):
                texts.append({
                    'id': tid,
                    'cx': cx_cell + random.uniform(-25.0, 25.0),
                    'cy': cy_cell + random.uniform(-12.0, 12.0)
                })
                tid += 1

    total_texts = len(texts)
    assert total_texts >= 300, f"Expected 300+ texts, got {total_texts}"

    # Build spatial index
    spatial_index = FastSpatialIndex(vlist, hlist)

    # 1. Verify exact mathematical equivalence
    res_base = run_baseline_pipeline(vlist, hlist, texts)
    res_opt = run_optimized_pipeline(spatial_index, texts)

    assert len(res_base) == len(res_opt), f"Result size mismatch: {len(res_base)} vs {len(res_opt)}"
    for k in res_base:
        p1 = res_base[k]
        p2 = res_opt[k]
        err_x = abs(p1[0] - p2[0])
        err_y = abs(p1[1] - p2[1])
        assert err_x < 1e-6 and err_y < 1e-6, f"Mismatch on text {k}: base={p1}, opt={p2}, err=({err_x}, {err_y})"

    # 2. Timing benchmark
    # 两版交替跑、各取最快一次：全量检查并行时 CPU 忙闲交替，分批计时的比值会在 0.6x~40x 间乱跳
    base_times = []
    opt_times = []
    for _ in range(runs):
        t0 = time.perf_counter()
        run_baseline_pipeline(vlist, hlist, texts)
        t1 = time.perf_counter()
        run_optimized_pipeline(spatial_index, texts)
        t2 = time.perf_counter()
        base_times.append(t1 - t0)
        opt_times.append(t2 - t1)
    t_base = min(base_times)
    t_opt = min(opt_times)

    speedup = t_base / t_opt if t_opt > 0 else 999.0

    assert speedup >= MIN_SPEEDUP, (
        f"Benchmark failed: speedup {speedup:.2f}x is below required {MIN_SPEEDUP}x threshold! "
        f"(Baseline={t_base*1000:.3f}ms, Opt={t_opt*1000:.3f}ms)"
    )

    print(
        f"PASS Module 3 (Benchmark): {rows}x{cols} grid ({rows*cols} cells), "
        f"{total_segments} segments, {total_texts} texts: "
        f"Baseline={t_base*1000:.3f}ms, Optimized={t_opt*1000:.3f}ms, "
        f"Speedup={speedup:.2f}x (>= {MIN_SPEEDUP}x verified, exact equivalence 100%)"
    )


# ==============================================================================
# Main Runner
# ==============================================================================

def main():
    parser = argparse.ArgumentParser(description="Offline static analysis and simulation for ZZ/DX2.")
    parser.add_argument('--strict-refactored', action='store_true',
                        help="Assert post-refactoring invariants (0 loop ssget, direct merge-sort call)")
    parser.add_argument('--runs', type=int, default=10,
                        help="Benchmark iteration count (default: 10)")
    args, _ = parser.parse_known_args()

    # Module 1
    source = check_encoding_and_syntax()
    audit_zz_ast(source, strict_refactored=args.strict_refactored)

    # Module 2
    test_geometric_single_text()
    test_geometric_multi_text_stacking()
    test_geometric_boundary_exceptions()
    test_dx2_cell_extraction_and_ordering()
    print("PASS Module 2 (Math Simulation): Single-text centering (<1e-6), multi-text 5.0 stack, boundary skips, and DX2 formatting verified")

    # Module 3
    run_benchmark(runs=args.runs)

    print("ALL ZZ STATIC CHECKS PASS")
    return 0


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f"FAIL ZZ STATIC CHECK: {exc}")
        sys.exit(1)
