"""One offline entry point: unit regressions, shared source, audit, index, commands."""
from pathlib import Path
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    steps = [
        ['-m', 'unittest', 'discover', '-s', 'tests', '-v'],
        ['scripts/sync_common.py'],
        ['scripts/audit_lsp.py', '--check'],
        ['gen_命令索引.py', '--check'],
        ['tools/check_all_static.py'],
    ]
    env = dict(os.environ, PYTHONIOENCODING='utf-8')
    for args in steps:
        print('RUN ' + ' '.join(args), flush=True)
        result = subprocess.run([sys.executable, *args], cwd=ROOT, env=env)
        if result.returncode:
            return result.returncode
    print('ALL PROJECT STATIC CHECKS PASS (no CAD)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
