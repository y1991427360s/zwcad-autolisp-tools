"""Full-repo offline static checks for AA整合版本.lsp (no CAD)."""
import re
import sys
from pathlib import Path

from lsp_common import SOURCE, command_names, defun_forms, parse, read_source, walk

ROOT = SOURCE.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))


def check_encoding():
    raw, text = read_source(SOURCE)
    print(f'PASS encoding: {SOURCE.name} {len(raw)} bytes, UTF-8 no BOM, pure CRLF')
    return text


def check_full_parse(text):
    forms = parse(text)
    funcs = defun_forms(forms)
    cmds = command_names(forms)
    assert funcs, 'No defun forms parsed'
    print(f'PASS parse: {len(forms)} top-level forms, {len(funcs)} defuns, {len(cmds)} c: commands')
    return forms, funcs, cmds


def check_header_list(text, cmds):
    header = text.split('(defun', 1)[0]
    listed = {m.group(1).upper() for m in re.finditer(r'^;;;\s*-\s*([A-Za-z0-9_]+)\s*[:：]', header, re.M)}
    actual = set(cmds)
    missing = sorted(actual - listed)
    stale = sorted(listed - actual)
    assert not missing, 'Header list missing: ' + ', '.join(missing)
    assert not stale, 'Header list stale: ' + ', '.join(stale)
    print(f'PASS header: {len(listed)} commands listed and defined')


def check_index_consistency(cmds):
    md = ROOT / '命令索引.md'
    html = ROOT / '命令索引.html'
    assert md.exists() and html.exists(), 'Run python gen_命令索引.py first'
    md_commands = set()
    for line in md.read_text(encoding='utf-8').splitlines():
        m = re.match(r'^\| `([^`]+)`(?: ⚠️)? \|', line)
        if m:
            md_commands.add(m.group(1).upper())
    actual = set(cmds)
    missing = sorted(actual - md_commands)
    assert not missing, '命令索引.md missing: ' + ', '.join(missing)
    html_bytes = html.read_bytes()
    assert not html_bytes.startswith(b'\xef\xbb\xbf')
    assert b'\xef\xbf\xbd' not in html_bytes
    print(f'PASS index: 命令索引 covers all {len(actual)} c: commands')


def _func_local_names(form):
    """Return (has_locals_list, local_names_set)."""
    args = form[2]
    if not isinstance(args, list):
        return False, set()
    if '/' in args:
        idx = args.index('/')
        return True, set(args[idx + 1:])
    return True, set()


def check_undo_pairing(forms):
    """cmd-begin should pair with cmd-end; undo-mark-on with undo-mark-off nearby."""
    errors = []
    warnings = []
    for form in defun_forms(forms):
        name = form[1]
        if not isinstance(name, str):
            continue
        calls = [n for n in walk(form) if isinstance(n, list) and n and isinstance(n[0], str)]
        heads = [n[0] for n in calls]
        begins = heads.count('aa:cmd-begin')
        ends = heads.count('aa:cmd-end')
        mark_on = heads.count('aa:undo-mark-on')
        mark_off = heads.count('aa:undo-mark-off')
        if begins and not ends:
            errors.append(f'{name}: aa:cmd-begin without aa:cmd-end')
        if ends and not begins:
            warnings.append(f'{name}: aa:cmd-end without aa:cmd-begin (cleanup-only?)')
        if mark_on and not mark_off:
            errors.append(f'{name}: aa:undo-mark-on without aa:undo-mark-off')
        # multiple cmd-end is fine (early-exit cleanup); fewer ends than begins is not
        if begins and ends < begins:
            warnings.append(f'{name}: cmd-begin={begins} but cmd-end={ends}')
        # conventional commands should declare required locals when using cmd-begin
        if begins == 1 and ends == 1:
            _, locals_ = _func_local_names(form)
            need = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
            lack = sorted(need - locals_)
            # one-line wrappers call shared helpers that manage undo themselves
            body_heads = set(heads)
            if lack and 'aa:cmd-begin' in body_heads and len(form) > 4:
                # still ok if the function body is essentially just begin/helper/end
                non_helper = [h for h in heads if h not in (
                    'aa:cmd-begin', 'aa:cmd-end', 'aa:color-cmd', 'aa:deep-color-cmd',
                    'aa:align-text-cmd', 'aa:extend-line-cmd', 'aa:move-stretch-vertical-cmd',
                    'princ')]
                if len(non_helper) > 2:
                    warnings.append(f'{name}: cmd-begin missing locals {lack}')
    if errors:
        raise AssertionError('undo pairing errors:\n- ' + '\n- '.join(errors))
    if warnings:
        print('WARN undo pairing (informational):')
        for w in warnings[:20]:
            print('  -', w)
        if len(warnings) > 20:
            print(f'  ... and {len(warnings) - 20} more')
    print(f'PASS undo: no cmd-begin/undo-mark leaks across {len(defun_forms(forms))} defuns')


def check_banned_patterns(text, forms):
    # large-list vl-sort is banned by project rules; comments mentioning it are fine
    live_vl_sort = []
    for form in defun_forms(forms):
        for node in walk(form):
            if isinstance(node, list) and node and node[0] == 'vl-sort':
                live_vl_sort.append(form[1])
    assert not live_vl_sort, 'vl-sort used in: ' + ', '.join(sorted(set(live_vl_sort)))
    print('PASS bans: no live (vl-sort ...) in defuns')


def run_command_checks():
    import runpy
    tools = Path(__file__).resolve().parent
    checks = [
        'check_fdx_static.py',
        'check_cc_static.py',
        'check_c1c2_static.py',
        'check_des_static.py',
        'check_gtx_static.py',
        'check_xy_static.py',
        'check_hddl_static.py',
        'check_xyg_static.py',
        'check_hb_static.py',
        'check_ys1_static.py',
        'check_aicad_static.py',
        'check_ming_static.py',
        'check_atw_static.py',
        'check_zdwi_static.py',
        'check_sss_static.py',
    ]
    for name in checks:
        path = tools / name
        print(f'-- {name} --')
        runpy.run_path(str(path), run_name='__main__')
    print(f'PASS modules: {len(checks)} command-specific static checks')


def main():
    text = check_encoding()
    forms, funcs, cmds = check_full_parse(text)
    check_header_list(text, cmds)
    check_index_consistency(cmds)
    check_undo_pairing(forms)
    check_banned_patterns(text, forms)
    run_command_checks()
    print('ALL PASS')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except AssertionError as exc:
        print(f'FAIL: {exc}')
        sys.exit(1)
