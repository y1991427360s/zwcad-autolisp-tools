# E2E & Offline Test Suite Ready

## Test Runner
- Primary command: `python tools/check_zz_static.py`
- Post-refactoring strict verification command: `python tools/check_zz_static.py --strict-refactored`
- Global static integration: `python tools/check_all_static.py`
- Whole-project offline gate: `python scripts/check_project.py`
- Expected: All tests pass with exit code 0

## Coverage Summary
| Tier / Module | Test Count | Description |
|---------------|-----------:|-------------|
| Module 1: AST & Code Invariants | 8 checks | UTF-8 CRLF, command exports, no vl-sort, merge-sort, loop ssget audit |
| Module 2: Geometric Simulation | 10 tests | Single text (<1e-6), multi-text 5.0 stack, 6 boundary exceptions, DX2 row & text formatting |
| Module 3: 225-cell / 315-text Benchmark | 315 tests | 100% target coordinate equivalence, >=5.0x speedup assertion |
| Integration: check_all_static.py | 23 modules | Automated regression gate for all project commands |
| **Total** | **356+ checks** | Complete offline safety net |
