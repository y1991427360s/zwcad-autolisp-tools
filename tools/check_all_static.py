"""Full-repo offline static checks for AA整合版本.lsp (no CAD)."""
import argparse
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from code_map import GENERIC_PREFIXES, CodeMap, is_fresh  # noqa: E402
from lsp_common import SOURCE, command_names, defun_forms, parse, read_source, walk  # noqa: E402

ROOT = SOURCE.parent


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


MODULE_CHECKS = [
    'check_t_static.py',
    'check_zhu_static.py',
    'check_hwt_static.py',
    'check_color_cmds_static.py',
    'check_fdx_static.py',
    'check_fkx_static.py',
    'check_cc_static.py',
    'check_c1c2_static.py',
    'check_nu_c1c2_target_static.py',
    'check_des_static.py',
    'check_gtx_static.py',
    'check_hwd_static.py',
    'check_link_static.py',
    'check_xy_static.py',
    'check_hddl_static.py',
    'check_bh_static.py',
    'check_cable_perf_static.py',
    'check_gty_copy_static.py',
    'check_xyg_static.py',
    'check_hb_static.py',
    'check_ys1_static.py',
    'check_aicad_static.py',
    'check_ming_static.py',
    'check_atw_static.py',
    'check_zdwi_static.py',
    'check_hzbg_static.py',
    'check_sss_static.py',
    'check_tbhb_static.py',
    'check_hg5_static.py',
    'check_zj_static.py',
    'check_ysdl_static.py',
    'check_zz_static.py',
    'check_zz2_static.py',
    'check_zddl_static.py',
    'check_lbz_lby_static.py',
    'check_cabinet_panel_static.py',
    'check_alias_panel_static.py',
]


def _boundary_re(name):
    return re.compile(r'(?<![A-Za-z0-9_:*\-])' + re.escape(name) + r'(?![A-Za-z0-9_:*\-])', re.I)


def _git(*args):
    try:
        res = subprocess.run(['git', *args], cwd=ROOT, capture_output=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired):
        return None
    return res.stdout.decode('utf-8', 'replace') if res.returncode == 0 else None


def changed_defuns(cm):
    """相对 HEAD 改动（含未提交）的 LISP 函数名；无 Git 时返回 None。"""
    diff = _git('diff', '-U0', 'HEAD', '--', SOURCE.name)
    if diff is None:
        return None
    ranges, names = [], set()
    for line in diff.splitlines():
        m = re.match(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@', line)
        if m:
            start, count = int(m.group(1)), int(m.group(2) or 1)
            ranges.append((start, start + max(count, 1) - 1))
            continue
        m = re.match(r'^-\s*\(defun\s+([^\s()]+)', line, re.I)
        if m:
            names.add(m.group(1).lower())
    names.update(cm.defuns_touching(ranges))
    return names


def changed_tool_scripts():
    out = _git('status', '--porcelain', '--', 'tools')
    if not out:
        return set()
    return {Path(l[3:].strip().strip('"')).name for l in out.splitlines()}


def select_module_checks(cm, quick, only):
    tools = Path(__file__).resolve().parent
    if only:
        keys = [k.strip() for k in only.split(',') if k.strip()]
        picked = []
        for name in MODULE_CHECKS:
            body = (tools / name).read_text(encoding='utf-8')
            for k in keys:
                if k.lower() in name.lower() or _boundary_re(k).search(body) or _boundary_re('c:' + k).search(body):
                    picked.append(name)
                    break
        return picked, f'--only {only}'
    if not quick:
        return list(MODULE_CHECKS), 'full'
    changed = changed_defuns(cm)
    if changed is None:
        return [], 'quick（无 Git，只跑核心检查）'
    affected = set(changed) | cm.transitive_callers(changed)
    needles = set()
    for n in affected:
        needles.add(n)
        if n.startswith('c:'):
            needles.add(n[2:])
        elif ':' in n and n.split(':', 1)[0] not in GENERIC_PREFIXES:
            needles.add(n.split(':', 1)[0] + ':')
    pats = [_boundary_re(n) if not n.endswith(':') else re.compile(re.escape(n), re.I) for n in needles]
    touched_scripts = changed_tool_scripts()
    picked = []
    for name in MODULE_CHECKS:
        body = (tools / name).read_text(encoding='utf-8')
        if name in touched_scripts or any(p.search(body) for p in pats):
            picked.append(name)
    shown = ', '.join(sorted(changed)[:12]) + (' …' if len(changed) > 12 else '')
    return picked, f'quick（改动函数 {len(changed)} 个：{shown or "无"}）'


def _run_one(path):
    env = dict(os.environ, PYTHONUTF8='1', PYTHONIOENCODING='utf-8')
    res = subprocess.run([sys.executable, str(path)], cwd=path.parent, capture_output=True, env=env)
    out = (res.stdout + res.stderr).decode('utf-8', 'replace')
    return res.returncode, out


def run_command_checks(names, serial=False):
    tools = Path(__file__).resolve().parent
    if serial:
        import runpy
        for name in names:
            print(f'-- {name} --')
            runpy.run_path(str(tools / name), run_name='__main__')
    else:
        # 每个检查独立进程并行；耗时主要在 ZDDL / 电缆性能两个解释器回归，并行后总时长约等于最慢的那个
        failed = []
        workers = min(len(names), os.cpu_count() or 4) or 1
        with ThreadPoolExecutor(max_workers=workers) as pool:
            results = list(pool.map(lambda n: (n, *_run_one(tools / n)), names))
        for name, code, out in results:
            print(f'-- {name} --')
            print(out.rstrip())
            if code:
                failed.append(name)
        if failed:
            raise AssertionError('module checks failed: ' + ', '.join(failed))
    print(f'PASS modules: {len(names)} command-specific static checks')


def check_code_map(cm):
    assert is_fresh(cm), 'docs/CODE_MAP.md 已过期，请运行 python tools/code_map.py write（或 python gen_命令索引.py）'
    print('PASS code-map: docs/CODE_MAP.md 与源码行号一致')


def main(argv=None):
    ap = argparse.ArgumentParser(description='AA整合版本.lsp 离线静态检查（不连 CAD）')
    ap.add_argument('--quick', action='store_true',
                    help='开发中使用：核心检查 + 只跑与本次改动函数（相对 HEAD）相关的专项检查')
    ap.add_argument('--only', metavar='KEYS',
                    help='核心检查 + 指定专项，逗号分隔，按脚本名/命令名/函数名匹配，如 NU,ZDDL')
    ap.add_argument('--serial', action='store_true', help='专项检查按旧方式在同一进程内串行运行')
    a = ap.parse_args(argv)
    t0 = time.time()
    text = check_encoding()
    forms, funcs, cmds = check_full_parse(text)
    check_header_list(text, cmds)
    check_index_consistency(cmds)
    check_undo_pairing(forms)
    check_banned_patterns(text, forms)
    cm = CodeMap(text)
    check_code_map(cm)
    names, mode = select_module_checks(cm, a.quick, a.only)
    print(f'MODE {mode}：运行 {len(names)}/{len(MODULE_CHECKS)} 个专项检查')
    if names:
        run_command_checks(names, a.serial)
    elapsed = time.time() - t0
    if len(names) < len(MODULE_CHECKS):
        print(f'PARTIAL PASS（{elapsed:.1f}s）：交付前必须再跑一次不带参数的全量检查')
    else:
        print(f'ALL PASS（{elapsed:.1f}s）')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except AssertionError as exc:
        print(f'FAIL: {exc}')
        sys.exit(1)
