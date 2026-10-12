## 2026-10-12T02:29:32Z
You are a Worker subagent (ID: teamwork_preview_worker_m2_1).
Your dedicated working directory is: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_worker_m2_1
Original request file (MANDATORY TO READ FIRST): d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\ORIGINAL_REQUEST.md
Project root: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp
Project rules: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\AGENTS.md
Project plan: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\orchestrator_1\PROJECT.md
Testing Suite: `tools/check_zz_static.py` and `tools/check_all_static.py`
Survey Reports:
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_1\report.md
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_2\report.md
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_3\report.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

File Write Ownership:
You EXCLUSIVELY own:
- `AA整合版本.lsp` (and byte-level backup before editing)
DO NOT edit `tools/` or `scripts/` in this milestone.

Your Task (Milestone 2: Refactoring AA整合版本.lsp for ZZ / JACC / DX2):
1. Read `AGENTS.md` and make a byte-level backup of `AA整合版本.lsp` before editing. Maintain UTF-8 no BOM and pure CRLF (`\r\n`).
2. Eliminate the per-text `ssget "_CP"` loop in `aa:zz-run`, `c:DX2`, and `c:DX`:
   - Compute the global union bounding box of all selected texts with an appropriate buffer (>= 300.0).
   - Perform a single `ssget "_C"` query to harvest all candidate boundary lines / polylines once ($O(1)$ CAD calls).
3. In-memory spatial index & interval matching:
   - Extract orthogonal horizontal segments `(y x1 x2)` and vertical segments `(x y1 y2)` once.
   - Implement fast in-memory spatial lookup (`aa:zz-find-rect-in-index` or equivalent) to locate the 4 enclosing borders (left, bottom, right, top) within `max-dist = 300.0` and orthogonal tolerance `0.5`.
   - Maintain exact fallback behavior: non-enclosed / missing-border cases must be safely skipped and counted.
4. Fast cell grouping and sorting:
   - Group texts into cells using memory coordinates with tolerance `0.1`, eliminating quadratic nested list reversals.
   - Use `aa:merge-sort` (defined at line 754) instead of recursive insertion sorting. Ban `vl-sort`.
5. Exact centering math & move tolerance filter:
   - Single text: center coordinates $tx = (lx + rx) / 2.0$, $ty = (by + ty) / 2.0$.
   - Multiple texts: preserve original top-to-bottom order, vertical spacing 5.0, symmetric distribution around cell center $(by + ty) / 2.0$:
     $start\_y = center\_y + 0.5 \times (n - 1) \times 5.0$, $y_i = start\_y - i \times 5.0$.
   - Retain `aa:zz-move-text` with 1e-6 movement threshold and exact signature `(aa:zz-move-text en cx cy tx ty)` (used by `c:MJ` and `c:ZDWI`).
6. Synchronize `c:DX2` and `c:DX`:
   - Use the fast spatial index while preserving 100% of cell sorting (row tolerance `0.25 * min(ah, bh)`), text line sorting (`0.55 * max(row_h, text_h)`), "、" text joining, CRLF cell separation, and clipboard export (`zi:to-clip`).
7. Verify your implementation:
   - Run `python tools/check_zz_static.py`
   - Run `python tools/check_zz_static.py --strict-refactored` (MUST PASS exit code 0)
   - Run `python tools/check_all_static.py` (MUST PASS exit code 0)
   - Run `python scripts/check_project.py` (MUST PASS exit code 0)
8. Write your detailed handoff report to `d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_worker_m2_1\handoff.md` and notify parent orchestrator via send_message.
