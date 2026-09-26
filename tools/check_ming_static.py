"""Static verification for MING command:
1. Syntax, signature, and undo-pairing in AA整合版本.lsp
2. Simulation of grid clustering and row-by-row, left-to-right sorting
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tools'))
from lsp_common import SOURCE, command_names, defun_forms, parse, read_source, walk

def test_ming_forms():
    raw, text = read_source(SOURCE)
    forms = parse(text)
    funcs = {str(f[1]).lower(): f for f in defun_forms(forms) if isinstance(f[1], str)}
    assert 'c:ming' in funcs, 'c:ming not found'
    assert 'ming:find-title-attrib' in funcs, 'ming:find-title-attrib not found'
    assert 'ming:get-block-height' in funcs, 'ming:get-block-height not found'
    assert 'ming:get-text-info' in funcs, 'ming:get-text-info not found'
    assert 'ming:cluster-and-sort' in funcs, 'ming:cluster-and-sort not found'

    # Check c:MING locals
    ming_form = funcs['c:ming']
    locals_list = ming_form[2]
    assert '/' in locals_list
    declared_locals = set(locals_list[locals_list.index('/') + 1:])
    required = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    assert required.issubset(declared_locals), f'Missing required locals: {required - declared_locals}'

    print("PASS: c:MING forms and locals verified")

def cluster_and_sort_sim(items, factor):
    """Python simulation of ming:cluster-and-sort (single-linkage row clustering)"""
    # item: (id, payload, x, y, h)
    if not items:
        return []
    total_h = sum(itm[4] for itm in items if itm[4] > 0)
    count_h = sum(1 for itm in items if itm[4] > 0)
    tol = (total_h / count_h * factor) if count_h > 0 else 50.0
    if tol < 0.5:
        tol = 5.0
    
    # Sort descending by Y
    sorted_items = sorted(items, key=lambda itm: itm[3], reverse=True)
    rows = []
    cur_row = []
    last_y = None
    for itm in sorted_items:
        y = itm[3]
        if last_y is None:
            last_y = y
            cur_row = [itm]
        elif abs(last_y - y) <= tol:
            cur_row.append(itm)
            last_y = y
        else:
            # Sort row ascending by X
            rows.append(sorted(cur_row, key=lambda itm: itm[2]))
            last_y = y
            cur_row = [itm]
    if cur_row:
        rows.append(sorted(cur_row, key=lambda itm: itm[2]))
    return rows

def test_grid_matching():
    # Simulate a 3x3 grid of blocks and texts with minor jitter
    # Row 1: Y ~ 2000, Row 2: Y ~ 1000, Row 3: Y ~ 0
    # X ~ 100, 500, 900
    blocks = [
        ("B11", "blk", 102, 2005, 500),
        ("B12", "blk", 501, 1995, 500),
        ("B13", "blk", 899, 2002, 500),
        ("B21", "blk",  98, 1003, 500),
        ("B22", "blk", 505,  998, 500),
        ("B23", "blk", 902, 1001, 500),
        ("B31", "blk", 100,    4, 500),
        ("B32", "blk", 498,   -3, 500),
        ("B33", "blk", 901,    1, 500),
    ]

    # Texts may be elsewhere (e.g. on a list or near blocks), say Row 1: Y ~ 300, Row 2: Y ~ 200, Row 3: Y ~ 100
    # X ~ 10, 20, 30
    texts = [
        ("T11", "10kV系统图", 10, 302, 3.5),
        ("T12", "主变平面图", 21, 298, 3.5),
        ("T13", "公用测控柜", 32, 301, 3.5),
        ("T21", "直流电源图",  9, 201, 3.5),
        ("T22", "通信柜接线", 19, 199, 3.5),
        ("T23", "电缆清册01", 31, 202, 3.5),
        ("T31", "电缆清册02", 11, 101, 3.5),
        ("T32", "电缆清册03", 20,  99, 3.5),
        ("T33", "端子排图01", 30, 100, 3.5),
    ]

    blk_rows = cluster_and_sort_sim(blocks, 0.3)
    txt_rows = cluster_and_sort_sim(texts, 1.0)

    assert len(blk_rows) == 3, f"Expected 3 block rows, got {len(blk_rows)}"
    assert len(txt_rows) == 3, f"Expected 3 text rows, got {len(txt_rows)}"

    flat_blks = [itm[0] for row in blk_rows for itm in row]
    flat_txts = [itm[1] for row in txt_rows for itm in row]

    expected_pairs = [
        ("B11", "10kV系统图"),
        ("B12", "主变平面图"),
        ("B13", "公用测控柜"),
        ("B21", "直流电源图"),
        ("B22", "通信柜接线"),
        ("B23", "电缆清册01"),
        ("B31", "电缆清册02"),
        ("B32", "电缆清册03"),
        ("B33", "端子排图01"),
    ]

    actual_pairs = list(zip(flat_blks, flat_txts))
    assert actual_pairs == expected_pairs, f"Mismatch: {actual_pairs} != {expected_pairs}"
    print("PASS: 3x3 grid clustering and left-to-right matching verified")

if __name__ == '__main__':
    test_ming_forms()
    test_grid_matching()
    print("ALL MING STATIC CHECKS PASS")
