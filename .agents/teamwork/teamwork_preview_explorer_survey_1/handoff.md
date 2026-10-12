# Handoff Report — ZZ / JACC / DX2 Performance Diagnosis & Refactoring Survey

## 1. Observation
1. **Entry Point Locations**:
   - `AA整合版本.lsp` Line 11380: `(defun c:ZZ () (aa:zz-run))`
   - `AA整合版本.lsp` Line 11384: `(defun c:JACC () (aa:zz-run))`
   - `AA整合版本.lsp` Line 10972: `(defun c:DX2 (/ *error* ...))`
   - `AA整合版本.lsp` Line 10772: `(defun c:DX (/ *error* ...))`
2. **Inner-Loop CAD Spatial Queries**:
   - `AA整合版本.lsp` Lines 11353-11361:
     ```lisp
     (repeat (sslength text-ss)
       (setq en (ssname text-ss i)
             alignment-ok (aa:normalize-text-vertical-align doc en 3)
             info (aa:zz-text-info doc en tol))
     ```
   - `AA整合版本.lsp` Lines 11192-11200 inside `aa:zz-text-info`:
     ```lisp
     line-ss (ssget "_CP"
                (mapcar '(lambda (pt) (trans pt 0 1))
                  (list pt1 (list (+ cx margin) (- cy margin))
                        pt2 (list (- cx margin) (+ cy margin))))
                '((-4 . "<OR")
                  (0 . "LINE")
                  (0 . "LWPOLYLINE")
                  (0 . "POLYLINE")
                  (-4 . "OR>")))
     ```
     For $N$ texts, CAD executes $N$ separate `(ssget "_CP" ...)` spatial queries on the active drawing database.
3. **Repeated Line Parsing & Cache Regeneration**:
   - `AA整合版本.lsp` Line 11203: `(setq line-cache (aa:zz-build-line-cache line-ss tol))` is executed inside `aa:zz-text-info` for every text.
4. **Quadratic Grouping Loop**:
   - `AA整合版本.lsp` Lines 11242-11260 in `aa:zz-group-by-rect`:
     For each `info` in `infos`, iterates over existing groups, rebuilds `new-groups`, and calls `(setq groups (reverse new-groups))`, causing $O(M^2)$ cons and list reverse operations.
5. **Multi-Text Vertical Spacing Math**:
   - `AA整合版本.lsp` Lines 11304-11314 in `aa:zz-apply-group`:
     ```lisp
     spacing 5.0
     center-y (/ (+ ty by) 2.0)
     start-y (+ center-y (* 0.5 (1- n) spacing))
     ...
     (foreach info sorted
       (setq y (- start-y (* i spacing)))
       (if (aa:zz-move-text (nth 0 info) (nth 1 info) (nth 2 info) tx y) ...)
     ```
6. **Tolerance & Movement Check**:
   - `AA整合版本.lsp` Lines 11229-11231 in `aa:zz-move-text`:
     ```lisp
     (if (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6))
       T
       (aa:safe-move-entity en (vlax-3d-point (list dx dy 0.0))))
     ```
7. **Verification Base Run**:
   - `python tools/check_all_static.py` executed successfully with code 0:
     `PASS parse: 725 top-level forms, 639 defuns, 135 c: commands`
     `PASS modules: 22 command-specific static checks`
     `ALL PASS`

## 2. Logic Chain
1. Based on Observation 2, `aa:zz-text-info` executes a native CAD `(ssget "_CP" ...)` query per text entity. In a drawing with 200~1000 texts, this makes 200~1000 CAD ObjectARX cross-boundary calls, which is the dominant cause of the multi-second or freeze delay reported by users.
2. Based on Observation 3, the same table grid lines are repeatedly fetched, parsed, and converted to segments $N$ times, creating severe memory churn and redundant CPU work.
3. Based on Observation 4, `aa:zz-group-by-rect` uses quadratic list rebuilding with repeated `reverse`, degrading performance further as the cell count increases.
4. Based on Observation 5 and Observation 6, the existing centering and spacing math is mathematically well-defined:
   - Horizontal center: $tx = (lx + rx) / 2.0$.
   - Vertical center: $center\_y = (ty + by) / 2.0$.
   - Top start Y: $start\_y = center\_y + 0.5 \times (n - 1) \times 5.0$.
   - Stepping: $y_i = start\_y - i \times 5.0$.
   - Tolerance threshold: `1e-6` for skipping movement.
   A refactored implementation can keep this exact math and tolerance while optimizing the surrounding extraction pipeline.
5. Based on Observation 1, `DX2` and `DX` rely directly on `aa:zz-text-info` and `aa:zz-group-by-rect`. Accelerating these core routines will simultaneously accelerate `DX2` and `DX`, but must maintain identical return signatures and cell coordinate precision to preserve `DX2` export ordering.

## 3. Caveats
- No CAD live process interaction was conducted in accordance with `AGENTS.md` rules (static and offline investigation only).
- Non-orthogonal lines (e.g. diagonal borders) are intentionally ignored by the current algorithm (`near` line tolerance of 0.5 in `aa:zz-add-seg`); the refactored design should preserve this behavior.
- Text vertical normalization (`aa:normalize-text-vertical-align`) is currently invoked on all selected texts before bounding box matching; changing this to lazy evaluation (only normalizing matched texts) will improve safety and performance, but the implementer must ensure texts that are already bottom-center aligned are not needlessly rewritten.

## 4. Conclusion
The root cause of `ZZ` / `JACC` slowness is the $O(N \times \text{CAD\_SSGET})$ per-text spatial query loop, combined with redundant line caching and quadratic group aggregation.
The refactoring strategy should adopt:
1. **One-shot CAD entity harvesting** ($O(1)$ `ssget` calls for the entire selection area).
2. **In-memory spatial grid binning** (Y-bins for vertical lines, X-bins for horizontal lines) to achieve sub-linear / $O(1)$ boundary line lookups.
3. **Sort-and-sweep linear group bucketing** ($O(N \log N)$ via `aa:merge-sort` instead of $O(M^2)$ nested loop).
4. **Preserved exact mathematical centering** ($5.0$ spacing, symmetric around rectangle center, `1e-6` move threshold).
5. **Offline test suite** `tools/check_zz_static.py` integrated into `tools/check_all_static.py`.

## 5. Verification Method
1. **Inspect Report**: Read `d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_1\report.md` for full technical specifications.
2. **Offline Static Checks**: Run `python tools/check_all_static.py` from project root to ensure full repository integrity and no syntax/encoding regressions.
3. **Invalidation Conditions**: If CAD `ssget` is still called inside a loop over text entities, or if `DX2` output sorting alters, this survey's conclusions and recommendations would be invalidated.
