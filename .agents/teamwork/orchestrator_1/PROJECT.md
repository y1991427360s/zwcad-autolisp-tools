# Project: ZZ / JACC / DX2 Performance Optimization and Refactoring

## Architecture
- **Problem Domain**: CAD AutoLISP performance optimization and geometric algorithm refactoring in ZWCAD 2026.
- **Core Components**:
  1. `AA整合版本.lsp`:
     - `c:ZZ` (line 11380), `c:JACC` (line 11384): entry points for batch text centering.
     - `c:DX2` (line 10972), `c:DX` (line 10772): grid cell text extraction and export.
     - Shared geometric core:
       - Global one-shot entity harvesting (`ssget "_C"`) replacing per-text `(ssget "_CP" ...)` calls.
       - In-memory orthogonal line segment spatial index (sub-linear boundary search).
       - $O(N \log N)$ cell bucketing and `aa:merge-sort` sorting.
       - Exact mathematical vertical centering (5.0 spacing, 1e-6 move filter).
       - `DX2` invariant preservation (row tolerance 0.25*min_h, text row tolerance 0.55*max_h, "、" join, CRLF clipboard).
  2. `tools/check_zz_static.py`:
     - Standalone offline static & pure mathematical simulation and benchmark test suite.
     - AST compliance check: UTF-8 no BOM, pure CRLF, no `vl-sort` in defuns, undo mark/cmd-begin pairing, 0 `ssget` inside loops, local variables declared.
     - Mathematical simulation: single text centering (< 1e-6), multiple text 5.0 vertical spacing (< 1e-6), boundary exception handling (missing top/bottom/left/right skipped), DX2 cell extraction and text ordering invariants.
     - Offline benchmark on 200+ texts and grid cells verifying >= 5x algorithm calculation speedup.
  3. `tools/check_all_static.py`:
     - Integration of `check_zz_static.py` into project one-click check runner.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Global One-Shot CAD Entity Harvesting | Eliminate per-text `ssget "_CP"`, replace with single macro bounding box query | M2 | Survey 1 & 2 |
| 2 | In-Memory Spatial Index for Line Segments | Fast sub-linear 4-way orthogonal boundary search with 300.0 max distance and tolerance handling | M2 | Survey 1 & 2 |
| 3 | Fast Cell Bucketing & Merge Sort | Eliminate $O(M^2)$ nested loop & repeated reverse; replace insertion sort with `aa:merge-sort` | M2 | Survey 1 & 3 |
| 4 | Precise Multi-Text Centering & Move Filter | Exact 5.0 unit vertical spacing, symmetric distribution, 1e-6 move threshold | M2 | Survey 1 |
| 5 | DX2 & DX Compatibility & Speedup | Retain exact text ordering and formatting (clipboard, "、", CRLF), share fast spatial index | M2 | Survey 2 |
| 6 | Offline Test Suite & Benchmark | `tools/check_zz_static.py` with AST checks, math simulation, and 200+ entity >=5x benchmark | M1 | Survey 3 |
| 7 | Full Engineering Verification & Sync | All checks pass (`check_all_static.py`, `check_project.py`), audit and docs updated (`gen_命令索引.py`) | M4 | Survey 3 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Offline Test Suite Track | Implement `tools/check_zz_static.py`, integrate into `tools/check_all_static.py`, publish `TEST_READY.md` | none | DONE |
| 2 | M2: Implementation in AA整合版本.lsp | One-shot CAD harvesting ($O(1)$ ssget), in-memory segment index, merge-sort bucketing, centering math, DX2 compatibility | M1 | DONE |
| 3 | M3: Review, Challenge & Forensic Audit | 2 Reviewers, 2 Challengers, Forensic Auditor verification and gate check | M2 | DONE |
| 4 | M4: Final Benchmark, Audit & Sync | Strict refactored checks, >=5x benchmark validation, audit_lsp.py, gen_命令索引.py | M3 | DONE |

## Interface Contracts
### `aa:zz-build-spatial-index`
- **Input**: `(line-ss tol)` or collection of orthogonal lines/polylines from single macro `ssget`.
- **Output**: Fast spatial structure `(list h-segs v-segs)` where segments are sorted/indexed for fast binary search or interval lookup.
- **Contract**: Replaces per-text `aa:zz-build-line-cache` calls.

### `aa:zz-find-rect-in-index`
- **Input**: `(spatial-index center-pt tol)`
- **Output**: `(list left-x bottom-y right-x top-y)` or `nil` if not enclosed within `max-dist = 300.0`.
- **Contract**: Mathematical equivalent to existing 4-way boundary search, but operating in-memory in sub-linear time.

### `aa:zz-move-text`
- **Input**: `(en cx cy tx ty)`
- **Output**: Boolean (T if moved or already at target, nil on error).
- **Contract**: Retains exact signature and 1e-6 tolerance check for compatibility with `c:MJ` and `c:ZDWI`.

### `c:DX2` / `c:DX`
- **Contract**: Exported text content, ordering, cell order, and clipboard format must be 100% identical to baseline.

## Code Layout
- `AA整合版本.lsp`: Main consolidated LISP file (lines 10772-11387). UTF-8 no BOM, CRLF.
- `tools/check_zz_static.py`: Standalone offline testing & benchmark script.
- `tools/check_all_static.py`: Whole-repo static check orchestrator.
- `scripts/check_project.py`: Project-level test pipeline.
