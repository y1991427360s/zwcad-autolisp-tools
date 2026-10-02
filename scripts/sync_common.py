"""Expand shared pure functions in place, keeping both LSP files standalone."""
import argparse
from datetime import datetime
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from lsp_common import parse_with_locations, read_source

TARGETS = {'V6/aicad_extension.lsp': 'aicad:', 'V6/aicad_aa_loader.lsp': 'aicadloader:'}


def rendered(text, template, namespace):
    forms, loc = parse_with_locations(text)
    original = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
    shared, shared_loc = parse_with_locations(template)
    edits = []
    for form in shared:
        assert form[:1] == ['defun'] and form[1].startswith('common:')
        name = form[1].replace('common:', namespace, 1)
        assert name in original, f'Missing target {name}'
        start, end = shared_loc[id(form)][1:]
        source = template[start:end].replace('common:', namespace)
        a, b = loc[id(original[name])][1:]
        marker = f';;; Generated from common/aicad_pure.lsp: {name}; run scripts/sync_common.py.\n'
        # Consume a prior generated marker, so regeneration is idempotent.
        prior_start = text.rfind('\n', 0, max(a - 1, 0)) + 1
        if text[prior_start:a] == marker:
            a = prior_start
        edits.append((a, b, marker + source))
    for a, b, value in sorted(edits, reverse=True):
        text = text[:a] + value + text[b:]
    parse_with_locations(text)
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    _, template = read_source(ROOT / 'common/aicad_pure.lsp')
    template = template.replace('\r\n', '\n')
    stale = []
    for name, namespace in TARGETS.items():
        path = ROOT / name
        raw, text = read_source(path)
        value = rendered(text.replace('\r\n', '\n'), template, namespace)
        output = value.replace('\n', '\r\n').encode('utf-8')
        if output == raw:
            continue
        stale.append(name)
        if args.write:
            backup = ROOT / 'backups' / ('common-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f')) / name
            backup.parent.mkdir(parents=True, exist_ok=True)
            backup.write_bytes(raw)
            path.write_bytes(output)
            read_source(path)
    print(('UPDATED' if args.write else 'STALE') + ': ' + ', '.join(stale) if stale else 'PASS common expansion')
    return int(bool(stale) and not args.write)


if __name__ == '__main__':
    raise SystemExit(main())
