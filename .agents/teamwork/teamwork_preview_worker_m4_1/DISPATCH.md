## 2026-10-12T03:00:31Z
You are Worker subagent M4 (ID: teamwork_preview_worker_m4_1).
Your dedicated working directory is: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_worker_m4_1
Original request file (MANDATORY TO READ FIRST): d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\ORIGINAL_REQUEST.md
Project root: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp
Project rules: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\AGENTS.md
Project plan: d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\orchestrator_1\PROJECT.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

File Write Ownership:
You own:
- `COMMANDS.md`, `PROJECT_AUDIT.md`, `docs/lsp-audit.json` (via running `python scripts/audit_lsp.py --write`)
- `命令索引.md`, `命令索引.html` (via running `python gen_命令索引.py`)

Your Task (Milestone 4: Final Verification, Benchmark, Audit & Documentation Sync):
1. Run `python scripts/audit_lsp.py --write` to update `COMMANDS.md`, `PROJECT_AUDIT.md`, and `docs/lsp-audit.json` with the latest defuns and commands from `AA整合版本.lsp`.
2. Run `python gen_命令索引.py` to regenerate and sync `命令索引.md` and `命令索引.html`.
3. Run `python tools/check_zz_static.py --strict-refactored --runs 20` to verify and record the final benchmark speedup across 20 runs (confirming >= 5.0x speedup).
4. Run `python tools/check_all_static.py` to confirm that all static checks pass cleanly with exit code 0.
5. Run `python scripts/check_project.py` to confirm that the full 5-step project-level quality gate passes with exit code 0.
6. Verify file encodings and git status:
   - Ensure `AA整合版本.lsp` is strictly UTF-8 no BOM and CRLF.
   - Ensure all documentation indexes are synchronized.
7. Write your detailed handoff report to `d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_worker_m4_1\handoff.md` summarizing the final state and all verification metrics. Notify parent orchestrator via send_message.
