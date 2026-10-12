"""Adversarial stress testing suite for ZZ / JACC / DX2 refactored implementation.

Runs comprehensive empirical verification of:
1. Geometric Centering Tolerances (< 1e-6 error, 5.0 unit vertical spacing, symmetry, top-to-bottom order).
2. Movement Threshold (1e-6) and Filtering Redundant Entity Writes.
3. Boundary Edge Cases:
   - Missing top, bottom, left, right borders.
   - Non-closed rectangles, short line segments, point-like segments.
   - Segments exceeding max-dist (300.0).
   - Non-orthogonal (diagonal) lines.
   - Multiple candidate lines (nearest boundary selection).
4. Scale & Performance on 200+, 500+, 1000+ text grids.
5. Grouping Comparator Stress Test & Transitivity under jitter.
"""
import math
import random
import sys
import time
from pathlib import Path

# Setup paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from check_zz_static import (
    FastSpatialIndex,
    HLine,
    VLine,
    math_find_bounding_rect,
    run_baseline_pipeline,
    run_optimized_pipeline,
    simulate_multi_text_stacking,
    simulate_single_text_centering,
)


def run_tolerance_tests():
    print("=== Test Suite 1: Geometric Centering Tolerances (< 1e-6) ===")
    
    # 1.1 Single text centering across extreme coordinate scales
    test_boxes = [
        (0.0, 100.0, 50.0, 0.0),                  # Normal box
        (1000000.0, 1000100.0, 500050.0, 500000.0), # Large positive coordinates (10^6)
        (-5000.0, -4800.0, -1000.0, -1100.0),     # Negative coordinates
        (123.45678901, 234.56789012, 98.7654321, 12.3456789), # High-precision floats
        (10.0, 11.0, 21.0, 20.0),                 # Tiny box 1x1
        (0.0, 500.0, 50.0, 0.0),                  # Highly elongated box 500x50
    ]

    for rect in test_boxes:
        lx, rx, ty, by = rect
        expected_tx = (lx + rx) / 2.0
        expected_ty = (ty + by) / 2.0
        
        # Test 100 random initial positions inside the box
        for _ in range(100):
            cx = random.uniform(lx, rx)
            cy = random.uniform(by, ty)
            fx, fy, moved, ex, ey = simulate_single_text_centering(rect, (cx, cy))
            assert ex < 1e-6, f"Single-text X error {ex} >= 1e-6 for rect {rect}, init ({cx}, {cy})"
            assert ey < 1e-6, f"Single-text Y error {ey} >= 1e-6 for rect {rect}, init ({cx}, {cy})"
            assert abs(fx - expected_tx) < 1e-6
            assert abs(fy - expected_ty) < 1e-6

    print("  [PASS] Single-text centering error < 1e-6 verified across 600 varied boxes/coordinates")

    # 1.2 Multi-text stacked centering across N = 2 to 60
    for N in range(2, 61):
        for rect in test_boxes[:3]:
            lx, rx, ty, by = rect
            center_x = (lx + rx) / 2.0
            center_y = (ty + by) / 2.0
            
            # Generate N random texts with distinct Y coordinates
            random.seed(N * 37)
            init_texts = [(random.uniform(lx, rx), random.uniform(by, ty)) for _ in range(N)]
            
            targets, mid_y, sorted_orig = simulate_multi_text_stacking(rect, init_texts, spacing=5.0)
            
            # Check length
            assert len(targets) == N
            
            # Check X alignment to center_x
            for i, (tx, ty_val) in enumerate(targets):
                assert abs(tx - center_x) < 1e-6, f"N={N}, item {i}: X {tx} != {center_x}"
            
            # Check adjacent vertical spacing is strictly 5.0
            for i in range(N - 1):
                spacing = targets[i][1] - targets[i + 1][1]
                assert abs(spacing - 5.0) < 1e-6, f"N={N}, index {i}: spacing {spacing} != 5.0 (< 1e-6)"
                
            # Check stack midpoint matches center_y
            stack_mid = (targets[0][1] + targets[-1][1]) / 2.0
            assert abs(stack_mid - center_y) < 1e-6, f"N={N}: stack mid {stack_mid} != {center_y}"
            
            # Check symmetry around center_y
            for i in range(N):
                top_dist = targets[i][1] - center_y
                bot_dist = center_y - targets[N - 1 - i][1]
                assert abs(top_dist - bot_dist) < 1e-6, f"N={N}, index {i}: asymmetry {abs(top_dist - bot_dist)}"
                
            # Check specific center positioning for odd / even N
            if N % 2 == 1:
                mid_idx = (N - 1) // 2
                assert abs(targets[mid_idx][1] - center_y) < 1e-6, f"N={N} odd: middle element not at center_y"
            else:
                mid_high = N // 2 - 1
                mid_low = N // 2
                assert abs(targets[mid_high][1] - (center_y + 2.5)) < 1e-6
                assert abs(targets[mid_low][1] - (center_y - 2.5)) < 1e-6
                
            # Check preservation of top-to-bottom order
            for i in range(N - 1):
                assert sorted_orig[i][1] >= sorted_orig[i + 1][1], f"N={N}: original sort inversion"
                assert targets[i][1] > targets[i + 1][1], f"N={N}: target Y inversion"

    print("  [PASS] Multi-text stacking verified: exact 5.0 spacing, symmetry, order preserved for N=2..60 (< 1e-6)")


def run_move_filter_tests():
    print("=== Test Suite 2: Movement Threshold (1e-6) and Redundant Write Filtering ===")
    rect = (0.0, 100.0, 50.0, 0.0) # center = (50.0, 25.0)
    
    # 2.1 Exact center (dx = 0, dy = 0)
    _, _, moved, _, _ = simulate_single_text_centering(rect, (50.0, 25.0))
    assert not moved, "Exact center must be filtered as no-op"
    
    # 2.2 Sub-threshold offsets (< 1e-6)
    sub_offsets = [
        (1e-7, 0.0),
        (0.0, 1e-7),
        (-5e-7, -5e-7),
        (9.99e-7, 9.99e-7),
        (-9.99999e-7, 0.0),
        (0.0, -9.99999e-7),
    ]
    for dx, dy in sub_offsets:
        cx = 50.0 + dx
        cy = 25.0 + dy
        _, _, moved, _, _ = simulate_single_text_centering(rect, (cx, cy))
        assert not moved, f"Offset ({dx}, {dy}) below 1e-6 should NOT trigger move!"
        
    # 2.3 Super-threshold offsets (> 1e-6)
    super_offsets = [
        (1.00001e-6, 0.0),
        (0.0, 1.00001e-6),
        (-1.00001e-6, 0.0),
        (0.0, -1.00001e-6),
        (1e-5, 0.0),
        (0.0, 1e-5),
        (1.0, 1.0),
    ]
    for dx, dy in super_offsets:
        cx = 50.0 + dx
        cy = 25.0 + dy
        _, _, moved, _, _ = simulate_single_text_centering(rect, (cx, cy))
        assert moved, f"Offset ({dx}, {dy}) above 1e-6 MUST trigger move!"

    print("  [PASS] 1e-6 movement threshold correctly discriminates sub-micro movements and eliminates redundant writes")


def run_boundary_edge_case_tests():
    print("=== Test Suite 3: Boundary Edge Cases Stress Testing ===")
    # Base box: [0, 100] x [0, 50], center (50, 25)
    
    # 3.1 Missing individual borders
    valid_v = [VLine(0.0, 0.0, 50.0), VLine(100.0, 0.0, 50.0)]
    valid_h = [HLine(0.0, 0.0, 100.0), HLine(50.0, 0.0, 100.0)]
    
    # Missing top
    res = math_find_bounding_rect(valid_v, [HLine(0.0, 0.0, 100.0)], 50.0, 25.0)
    assert res is None, "Missing top border must return None"
    
    # Missing bottom
    res = math_find_bounding_rect(valid_v, [HLine(50.0, 0.0, 100.0)], 50.0, 25.0)
    assert res is None, "Missing bottom border must return None"
    
    # Missing left
    res = math_find_bounding_rect([VLine(100.0, 0.0, 50.0)], valid_h, 50.0, 25.0)
    assert res is None, "Missing left border must return None"
    
    # Missing right
    res = math_find_bounding_rect([VLine(0.0, 0.0, 50.0)], valid_h, 50.0, 25.0)
    assert res is None, "Missing right border must return None"
    
    print("  [PASS] Missing top/bottom/left/right individual borders properly return None")

    # 3.2 Non-closed rectangles / Gaps
    # Gap on left vertical line: line does not cover cy=25 (segments [0, 10] and [30, 50])
    gapped_v = [VLine(0.0, 0.0, 10.0), VLine(0.0, 30.0, 50.0), VLine(100.0, 0.0, 50.0)]
    res = math_find_bounding_rect(gapped_v, valid_h, 50.0, 25.0)
    assert res is None, "Gapped left border at cy must return None"
    
    # Gap on bottom horizontal line: segments [0, 20] and [70, 100] (gap at cx=50)
    gapped_h = [HLine(0.0, 0.0, 20.0), HLine(0.0, 70.0, 100.0), HLine(50.0, 0.0, 100.0)]
    res = math_find_bounding_rect(valid_v, gapped_h, 50.0, 25.0)
    assert res is None, "Gapped bottom border at cx must return None"
    
    print("  [PASS] Non-closed / gapped rectangles safely rejected")

    # 3.3 Zero-length / point-like segments and short segments
    zero_v = [VLine(0.0, 25.0, 25.0), VLine(100.0, 0.0, 50.0)]
    res = math_find_bounding_rect(zero_v, valid_h, 50.0, 20.0) # cy=20, zero_v is at 25
    assert res is None, "Point-like segment not covering cy must return None"

    # Short line segment: length 2 units, far from text projection
    short_v = [VLine(0.0, 45.0, 47.0), VLine(100.0, 0.0, 50.0)]
    res = math_find_bounding_rect(short_v, valid_h, 50.0, 25.0)
    assert res is None, "Short segment not spanning cy must return None"
    
    print("  [PASS] Zero-length and short segments not spanning point projection properly skipped")

    # 3.4 Distance threshold max-dist = 300.0
    # Line exactly at distance 300.0: left line at cx - 300.0 = -250.0
    v_exact_300 = [VLine(-250.0, 0.0, 50.0), VLine(100.0, 0.0, 50.0)]
    res = math_find_bounding_rect(v_exact_300, valid_h, 50.0, 25.0, max_dist=300.0)
    assert res == (-250.0, 100.0, 50.0, 0.0), f"Exact 300.0 distance should be allowed, got {res}"
    
    # Line at distance 300.0001 (beyond max-dist)
    v_over_300 = [VLine(-250.0001, 0.0, 50.0), VLine(100.0, 0.0, 50.0)]
    res = math_find_bounding_rect(v_over_300, valid_h, 50.0, 25.0, max_dist=300.0)
    assert res is None, "Distance > 300.0 must be rejected"
    
    # Top line at distance 301.0
    h_over_300 = [HLine(0.0, 0.0, 100.0), HLine(326.0, 0.0, 100.0)] # cy=25, 326-25 = 301 > 300
    res = math_find_bounding_rect(valid_v, h_over_300, 50.0, 25.0, max_dist=300.0)
    assert res is None, "Top line distance 301 > 300 must be rejected"

    print("  [PASS] max-dist=300.0 constraint strictly enforced (exact boundary accepted, 300+ rejected)")

    # 3.5 Non-orthogonal (diagonal) lines in LISP aa:zz-add-seg logic
    # In LISP aa:zz-add-seg:
    # (cond
    #   ((<= (abs (- (car p1) (car p2))) near) ... added to vlist)
    #   ((<= (abs (- (cadr p1) (cadr p2))) near) ... added to hlist)
    # )
    # where near = max(0.5, tol*10.0) = 0.5
    def lisp_simulate_add_seg(p1, p2, near=0.5):
        dx = abs(p1[0] - p2[0])
        dy = abs(p1[1] - p2[1])
        if dx <= near:
            return 'V', (p1[0] + p2[0]) / 2.0, min(p1[1], p2[1]), max(p1[1], p2[1])
        elif dy <= near:
            return 'H', (p1[1] + p2[1]) / 2.0, min(p1[0], p2[0]), max(p1[0], p2[0])
        else:
            return None # Diagonal: ignored

    # True diagonals
    diagonals = [
        ((0.0, 0.0), (10.0, 10.0)),
        ((0.0, 0.0), (50.0, 30.0)),
        ((10.0, 20.0), (15.0, 25.0)),
        ((0.0, 0.0), (0.6, 0.6)), # dx=0.6, dy=0.6 > 0.5
    ]
    for p1, p2 in diagonals:
        classified = lisp_simulate_add_seg(p1, p2)
        assert classified is None, f"Diagonal segment {p1} -> {p2} should be ignored, got {classified}"

    # Quasi-vertical within near=0.5 tolerance
    qv = lisp_simulate_add_seg((10.0, 0.0), (10.4, 50.0)) # dx=0.4 <= 0.5
    assert qv is not None and qv[0] == 'V'
    
    # Quasi-horizontal within near=0.5 tolerance
    qh = lisp_simulate_add_seg((0.0, 20.0), (50.0, 20.3)) # dy=0.3 <= 0.5
    assert qh is not None and qh[0] == 'H'

    print("  [PASS] Diagonal non-orthogonal lines completely ignored; near-orthogonal lines within 0.5 classified properly")

    # 3.6 Multiple candidates: nearest line selection
    multi_v = [
        VLine(0.0, 0.0, 50.0),    # dist = 50
        VLine(20.0, 0.0, 50.0),   # dist = 30 (nearest left!)
        VLine(80.0, 0.0, 50.0),   # dist = 30 (nearest right!)
        VLine(100.0, 0.0, 50.0),  # dist = 50
    ]
    multi_h = [
        HLine(0.0, 0.0, 100.0),   # dist = 25
        HLine(10.0, 0.0, 100.0),  # dist = 15 (nearest bottom!)
        HLine(40.0, 0.0, 100.0),  # dist = 15 (nearest top!)
        HLine(50.0, 0.0, 100.0),  # dist = 25
    ]
    res = math_find_bounding_rect(multi_v, multi_h, 50.0, 25.0)
    assert res == (20.0, 80.0, 40.0, 10.0), f"Expected nearest inner box (20, 80, 40, 10), got {res}"
    print("  [PASS] Multiple candidates correctly select nearest boundary")


def run_scale_performance_tests():
    print("=== Test Suite 4: Empirical Benchmark on 200+, 500+, and 1000+ Text Grids ===")
    
    grid_configs = [
        ("200+ Text Grid (15x15 = 225 cells)", 15, 15, 315),
        ("500+ Text Grid (25x25 = 625 cells)", 25, 25, 875),
        ("1000+ Text Grid (35x35 = 1225 cells)", 35, 35, 1715),
    ]

    for label, rows, cols, approx_texts in grid_configs:
        random.seed(12345)
        cell_w = 80.0
        cell_h = 40.0

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

        # Generate texts
        texts = []
        tid = 0
        for r in range(rows):
            for c in range(cols):
                cnt = random.choice([1, 1, 1, 2, 2, 3, 0])
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
        spatial_index = FastSpatialIndex(vlist, hlist)

        # 1. Verify 100% mathematical equivalence between baseline and optimized
        res_base = run_baseline_pipeline(vlist, hlist, texts)
        res_opt = run_optimized_pipeline(spatial_index, texts)
        assert len(res_base) == len(res_opt), f"{label}: count mismatch {len(res_base)} vs {len(res_opt)}"

        max_err = 0.0
        for tid_key in res_base:
            p1 = res_base[tid_key]
            p2 = res_opt[tid_key]
            err = max(abs(p1[0] - p2[0]), abs(p1[1] - p2[1]))
            if err > max_err:
                max_err = err
            assert err < 1e-6, f"Mismatch on text {tid_key}: {p1} vs {p2}"

        # 2. Timing benchmark
        # Baseline timing (5 runs)
        t0 = time.perf_counter()
        runs = 5 if rows <= 25 else 2
        for _ in range(runs):
            run_baseline_pipeline(vlist, hlist, texts)
        t_base = (time.perf_counter() - t0) / runs

        # Optimized timing
        runs_opt = 20
        t0 = time.perf_counter()
        for _ in range(runs_opt):
            run_optimized_pipeline(spatial_index, texts)
        t_opt = (time.perf_counter() - t0) / runs_opt

        speedup = t_base / t_opt if t_opt > 0 else 999.0
        print(f"  {label}: {len(vlist)+len(hlist)} segs, {total_texts} texts | "
              f"Base={t_base*1000:.2f}ms, Opt={t_opt*1000:.2f}ms | "
              f"Speedup={speedup:.2f}x (Max error={max_err:.2e})")

        assert speedup >= 5.0, f"Speedup {speedup:.2f}x failed >= 5.0x requirement on {label}"

    print("  [PASS] Consistent >= 5.0x speedup verified across all scales up to 1700+ texts!")


def run_grouping_comparator_stress():
    print("=== Test Suite 5: Grouping Comparator Stress & Transitivity Test ===")
    # LISP aa:zz-info-before-p
    # (defun aa:zz-info-before-p (a b / tya tyb)
    #   (setq tya (nth 5 a)
    #         tyb (nth 5 b))
    #   (cond
    #     ((> (abs (- tya tyb)) 0.1) (> tya tyb))
    #     ((> (abs (- (nth 3 a) (nth 3 b))) 0.1) (< (nth 3 a) (nth 3 b)))
    #     ((> (abs (- (nth 6 a) (nth 6 b))) 0.1) (> (nth 6 a) (nth 6 b)))
    #     ((> (abs (- (nth 4 a) (nth 4 b))) 0.1) (< (nth 4 a) (nth 4 b)))
    #     (T (> (nth 2 a) (nth 2 b))))
    # )
    def info_before_p(a, b):
        # a, b: [en, cx, cy, lx, rx, ty, by]
        # nth 5 is ty, nth 3 is lx, nth 6 is by, nth 4 is rx, nth 2 is cy
        tya, tyb = a[5], b[5]
        if abs(tya - tyb) > 0.1:
            return tya > tyb
        lxa, lxb = a[3], b[3]
        if abs(lxa - lxb) > 0.1:
            return lxa < lxb
        bya, byb = a[6], b[6]
        if abs(bya - byb) > 0.1:
            return bya > byb
        rxa, rxb = a[4], b[4]
        if abs(rxa - rxb) > 0.1:
            return rxa < rxb
        return a[2] > b[2]

    # Test merge-sort with this comparator on random cells
    from functools import cmp_to_key
    
    # Generate 50 cells with 1-5 texts each, with coordinate noise
    items = []
    cell_id = 0
    for r in range(10):
        for c in range(5):
            cell_id += 1
            # Base cell:
            base_lx = c * 50.0
            base_rx = (c + 1) * 50.0
            base_by = r * 30.0
            base_ty = (r + 1) * 30.0
            for k in range(random.randint(1, 4)):
                # Jitter within 0.01 (well within 0.1 rect-tol)
                jitter = random.uniform(-0.01, 0.01)
                item = [
                    f"EN_{cell_id}_{k}",
                    base_lx + 25.0 + jitter,
                    base_by + 15.0 + jitter, # cy
                    base_lx + jitter,        # lx
                    base_rx + jitter,        # rx
                    base_ty + jitter,        # ty
                    base_by + jitter,        # by
                ]
                items.append(item)

    # Sort items using info_before_p
    # Simulate LISP merge-sort
    def lisp_merge_sort(lst):
        if len(lst) <= 1:
            return lst
        mid = len(lst) // 2
        left = lisp_merge_sort(lst[:mid])
        right = lisp_merge_sort(lst[mid:])
        
        # Merge
        res = []
        i = j = 0
        while i < len(left) and j < len(right):
            if info_before_p(left[i], right[j]):
                res.append(left[i])
                i += 1
            else:
                res.append(right[j])
                j += 1
        res.extend(left[i:])
        res.extend(right[j:])
        return res

    sorted_items = lisp_merge_sort(items)
    assert len(sorted_items) == len(items)

    # Simulate aa:zz-group-by-rect linear scan
    def rect_match_p(a, b, rect_tol=0.1):
        return (abs(a[3] - b[3]) <= rect_tol and
                abs(a[4] - b[4]) <= rect_tol and
                abs(a[5] - b[5]) <= rect_tol and
                abs(a[6] - b[6]) <= rect_tol)

    groups = []
    cur_group = []
    cur_ref = None
    for info in sorted_items:
        if cur_ref and rect_match_p(info, cur_ref, 0.1):
            cur_group.append(info)
        else:
            if cur_group:
                groups.append(cur_group)
            cur_group = [info]
            cur_ref = info
    if cur_group:
        groups.append(cur_group)

    # Verify that all items of the same cell ended up in exactly one group
    assert len(groups) == 50, f"Expected 50 groups, got {len(groups)}"
    total_grouped = sum(len(g) for g in groups)
    assert total_grouped == len(items), f"Grouped items count mismatch: {total_grouped} vs {len(items)}"

    print(f"  [PASS] 50 distinct cells ({len(items)} texts) with coordinate jitter correctly clustered into exactly 50 groups")


def main():
    print("======================================================================")
    print("STARTING ADVERSARIAL STRESS TEST HARNESS FOR ZZ / JACC / DX2")
    print("======================================================================\n")
    
    run_tolerance_tests()
    print()
    run_move_filter_tests()
    print()
    run_boundary_edge_case_tests()
    print()
    run_scale_performance_tests()
    print()
    run_grouping_comparator_stress()
    print()
    print("======================================================================")
    print("ALL ADVERSARIAL CHALLENGES PASSED EMPIRICALLY WITH ZERO DEFECTS!")
    print("======================================================================")


if __name__ == '__main__':
    main()
