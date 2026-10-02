"""Deterministic, dependency-free repository audit. Never connects to CAD."""
import argparse
from collections import defaultdict, Counter
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from lsp_common import parse_with_locations, read_source

EXCLUDED = {'.git', 'backups', '__pycache__', 'node_modules', '.svn'}
INPUTS = {'ssget', 'entsel', 'nentsel', 'nentselp', 'getpoint', 'getcorner',
          'getdist', 'getreal', 'getint', 'getstring', 'getkword', 'getfiled'}
MUTATIONS = {'entmod', 'entdel', 'entmake', 'entmakex', 'command', 'vl-cmdf',
             'command-s', 'vla-move', 'vla-copy', 'vla-delete', 'vla-explode'}
ENTITY_TYPES = {'TEXT', 'MTEXT', 'LINE', 'LWPOLYLINE', 'POLYLINE', 'INSERT',
                'ATTRIB', 'ATTDEF', 'DIMENSION', 'LEADER', 'MLEADER', 'ARC',
                'CIRCLE', 'HATCH', 'STYLE'}


def files(root):
    return sorted((p for p in root.rglob('*') if p.is_file() and
                   p.suffix.lower() == '.lsp' and not any(
                       x.lower() in EXCLUDED for x in p.relative_to(root).parts[:-1])),
                  key=lambda p: p.relative_to(root).as_posix().lower())


def executable(node):
    """Don't treat quoted data or nested defun bodies as caller execution."""
    if not isinstance(node, list) or not node:
        return
    if node[0] in ('quote', 'defun'):
        return
    yield node
    for child in node:
        yield from executable(child)


def body_nodes(form):
    for part in form[3:]:
        yield from executable(part)


def all_lists(node):
    if isinstance(node, list):
        yield node
        for child in node:
            yield from all_lists(child)


def quoted_symbol(node):
    if isinstance(node, list) and len(node) == 2 and node[0] == 'quote' and isinstance(node[1], str):
        return node[1]
    return None


def calls(nodes):
    result = set()
    for node in nodes:
        if isinstance(node[0], str):
            result.add(node[0])
        if node[0] in ('vl-catch-all-apply', 'apply', 'mapcar', 'vl-sort', 'vl-sort-i') and len(node) > 1:
            callback = quoted_symbol(node[1])
            if callback:
                result.add(callback)
        # Project safe-apply wrappers receive a function as argument 2.
        if isinstance(node[0], str) and node[0].endswith(':safe-apply') and len(node) > 2:
            callback = quoted_symbol(node[2])
            if callback:
                result.add(callback)
    return result


def writes(nodes):
    for node in nodes:
        if node[0] == 'setq':
            yield from (v for v in node[1::2] if isinstance(v, str))
        elif node[0] == 'foreach' and len(node) > 1 and isinstance(node[1], str):
            yield node[1]
        elif node[0] == 'set' and len(node) > 1:
            name = quoted_symbol(node[1])
            if name:
                yield name


def literals(nodes):
    return {n[1:-1].upper() for node in nodes for n in node
            if isinstance(n, str) and n.startswith('"')}


def scan(root=ROOT):
    functions, findings, inventories, global_sites = [], [], [], defaultdict(list)

    def finding(rule, level, fn, evidence, line=None):
        findings.append(dict(rule=rule, level=level, file=fn['file'],
                             line=line or fn['line'], function=fn['name'], evidence=evidence))

    for path in files(root):
        rel = path.relative_to(root).as_posix()
        raw, text = read_source(path)
        forms, locations = parse_with_locations(text)
        inventory = dict(file=rel, bytes=len(raw), top_level_forms=len(forms), functions=0, commands=0)
        for form in forms:
            if not isinstance(form, list):
                continue
            if form[:1] != ['defun']:
                for node in executable(form):
                    for name in writes([node]):
                        global_sites[name].append((rel, locations[id(node)][0], '<load>'))
                continue
            assert len(form) >= 3 and isinstance(form[1], str) and isinstance(form[2], list), f'{rel}: malformed defun'
            name, args = form[1:3]
            split = args.index('/') if '/' in args else len(args)
            nodes = list(body_nodes(form))
            fn = dict(file=rel, line=locations[id(form)][0], name=name,
                      params=args[:split], locals=args[split+1:], form=form,
                      nodes=nodes, calls=calls(nodes), text=text, locations=locations)
            functions.append(fn)
            inventory['functions'] += 1
            inventory['commands'] += name.startswith('c:')
            bound = set(fn['params'] + fn['locals'])
            for node in nodes:
                for symbol in writes([node]):
                    if symbol not in bound:
                        global_sites[symbol].append((rel, locations[id(node)][0], name))
            # Lexically nested definitions are valid but command nesting is suspect.
            for node in all_lists(form[3:]):
                if node[:1] == ['defun'] and len(node) > 1 and isinstance(node[1], str) and node[1].startswith('c:'):
                    finding('nested-command', 'error', fn, f'命令 {node[1]} 不是顶层定义')
            heads = fn['calls']
            pairs = [('aa:cmd-begin', 'aa:cmd-end'), ('aa:undo-mark-on', 'aa:undo-mark-off'),
                     ('vla-startundomark', 'vla-endundomark')]
            # Include local error handler bodies for cleanup evidence, without assuming paths.
            full_heads = calls([n for n in all_lists(form[3:]) if n and n[0] != 'quote'])
            if 'vla-startundomark' in heads and 'vla-endundomark' in full_heads and '*error*' not in bound:
                finding('undo-error-path', 'review', fn, '正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证')
            for begin, end in pairs:
                if begin in heads and end not in full_heads:
                    finding('undo-close', 'review', fn, f'{begin} 出现；本函数未找到 {end}，需追踪调用方/异常路径')
            native = [n for n in nodes if n[0] in ('command', 'command-s', 'vl-cmdf') and
                      any(isinstance(x, str) and x.strip('"_.').upper() == 'UNDO' for x in n[1:])]
            if native:
                finding('native-undo', 'review', fn, '原生 UNDO 调用，需核对 Begin/End 与异常退出配对')
            if '*error*' in set(writes(nodes)) and '*error*' not in bound:
                finding('error-binding', 'review', fn, '*error* 赋值未局部声明；可能为动态作用域框架')
            for nested in all_lists(form[3:]):
                if nested[:2] == ['defun', '*error*']:
                    if '*error*' not in bound:
                        finding('error-binding', 'review', fn, '局部错误处理定义缺少 *error* 局部绑定')
                    cleanup_heads = calls(list(body_nodes(nested)))
                    if not cleanup_heads & {'aa:cmd-end', 'aa:cmd-error', 'aa:undo-mark-off',
                                            'vla-endundomark', 'setvar', 'close', 'vl-catch-all-apply'}:
                        finding('error-cleanup', 'review', fn, '专属 *error* 未见标准恢复调用；需核对间接清理')
            setvars = [n for n in nodes if n[0] == 'setvar' and len(n) > 2 and isinstance(n[1], str) and n[1].startswith('"')]
            getvars = {n[1].upper() for n in nodes if n[0] == 'getvar' and len(n) > 1 and isinstance(n[1], str)}
            for var in sorted({n[1].upper() for n in setvars}):
                restore = any(n[1].upper() == var and isinstance(n[2], str) and not n[2].startswith('"') and
                              not re.fullmatch(r'[-+]?\d+(\.\d+)?', n[2]) for n in setvars)
                if not restore:
                    finding('sysvar-restore', 'review', fn, f'{var}: 未见直接变量值恢复；getvar快照={var in getvars}，需核对框架/是否持久设置')
            for node in nodes:
                if node[0] in ('sslength', 'ssname', 'entget', 'vlax-ename->vla-object') and len(node) > 1:
                    arg = node[1]
                    if arg == 'nil' or (isinstance(arg, list) and arg and (arg[0] in INPUTS or
                       (arg[0] == 'car' and len(arg) > 1 and isinstance(arg[1], list) and arg[1] and arg[1][0] in INPUTS))):
                        finding('nil-selection', 'review', fn, f'{node[0]} 直接消费可取消输入或 nil', locations[id(node)][0])
            selected = {n[i] for n in nodes if n[0] == 'setq'
                        for i in range(1, len(n) - 1, 2)
                        if isinstance(n[i], str) and isinstance(n[i+1], list) and n[i+1][:1] == ['ssget']}
            conditions = [n[1] for n in nodes if n[0] in ('if', 'while') and len(n) > 1]
            conditions += [n for n in nodes if n[0] in ('and', 'or', 'null', 'not', 'cond')]
            def has_symbol(value, symbol):
                return any(has_symbol(x, symbol) for x in value) if isinstance(value, list) else value == symbol
            for symbol in sorted(selected):
                if any(n[0] in ('sslength', 'ssname') and len(n) > 1 and n[1] == symbol for n in nodes) and not any(has_symbol(c, symbol) for c in conditions):
                    finding('nil-selection', 'review', fn, f'{symbol}: ssget 后被选择集 API 使用，未见显式判空；需核对间接保护')
            for symbol in sorted(set(writes(nodes)) - bound):
                if not symbol.startswith('*') and name not in ('aa:cmd-begin', 'aa:cmd-end', 'aa:cmd-error', 'aa:undo-mark-on', 'aa:undo-mark-off'):
                    finding('implicit-global', 'review', fn, f'写入未声明变量 {symbol}；动态调用方局部绑定需人工确认')
        inventories.append(inventory)
    by_name = defaultdict(list)
    for fn in functions:
        by_name[fn['name']].append(fn)
    for name, defs in sorted(by_name.items()):
        if len(defs) > 1:
            finding('duplicate-function', 'error', defs[0], '同名顶层定义: ' + ', '.join(f"{f['file']}:{f['line']}" for f in defs))
    for symbol, sites in sorted(global_sites.items()):
        if len({s[0] for s in sites}) > 1:
            fn = dict(file=sites[0][0], line=sites[0][1], name=symbol)
            finding('shared-global', 'review', fn, '跨文件写入: ' + ', '.join(f'{f}:{ln} ({n})' for f, ln, n in sites))
    # Conflict evidence includes .NET registration, without claiming native aliases are known.
    registrations = defaultdict(list)
    for fn in functions:
        if fn['name'].startswith('c:'):
            registrations[fn['name'][2:]].append((fn['file'], fn['line']))
    for path in sorted(root.rglob('*.cs')):
        if any(p.lower() in EXCLUDED for p in path.relative_to(root).parts):
            continue
        for ln, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
            for match in re.finditer(r'\[CommandMethod\("([^"\n]+)"', line):
                registrations[match[1].lower()].append((path.relative_to(root).as_posix(), ln))
    for name, sites in sorted(registrations.items()):
        if len(sites) > 1:
            finding('command-conflict', 'error', dict(file=sites[0][0], line=sites[0][1], name=name), str(sites))
    return functions, findings, inventories, global_sites


def escape(value):
    return str(value).replace('|', '\\|').replace('\r', ' ').replace('\n', ' ').replace('<', '&lt;')


def outputs(root=ROOT):
    functions, findings, inventories, globals_ = scan(root)
    by_name = defaultdict(list)
    for fn in functions:
        by_name[fn['name']].append(fn)

    def reachable(fn):
        seen, pending, result = set(), [fn], []
        while pending:
            current = pending.pop()
            key = (current['file'], current['name'])
            if key in seen:
                continue
            seen.add(key)
            result.append(current)
            for name in sorted(current['calls']):
                pending.extend(by_name.get(name, []))
        return result

    hints = {}
    if root == ROOT:
        spec = importlib.util.spec_from_file_location('command_index', ROOT / 'gen_命令索引.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        _, rows = module.scan()
        hints = {(name.lower(), file): desc for name, file, _, desc in rows}
    command_lines = ['# COMMANDS', '', '> 自动生成：`python scripts/audit_lsp.py --write`。仅收录 LSP 顶层命令；.NET 命令见现有命令索引。', '',
        '参数包含函数形参与可达调用的交互输入类型。依赖列列出直接项目函数和静态发现的外部文件；间接依赖见 JSON。',
        '对象列是可达源码中出现的图元/表记录类型与修改调用的候选范围，可能包含只读取的对象；静态分析无法精确判定实际修改目标。动态函数调用和字符串内回调需人工核对。', '',
        '| 命令 | 功能（源码注释） | 参数 / 输入 | 依赖 | 修改对象类型（候选） | 位置 |',
        '| --- | --- | --- | --- | --- | --- |']
    commands = []
    for fn in sorted((f for f in functions if f['name'].startswith('c:')), key=lambda f: (f['name'], f['file'], f['line'])):
        deps = reachable(fn)
        nodes = [n for f in deps for n in f['nodes']]
        heads = set().union(*(f['calls'] for f in deps))
        strings = literals([n for f in deps for n in all_lists(f['form'][3:])])
        objects = sorted({t for s in strings for t in s.split(',') if t in ENTITY_TYPES})
        modifying = bool(heads & MUTATIONS or any(h.startswith('vla-put-') for h in heads))
        inputs = sorted(heads & INPUTS)
        prompts = sorted({n[-1][1:-1] for n in nodes if isinstance(n[0], str) and n[0] in INPUTS and len(n) > 1
                          and isinstance(n[-1], str) and n[-1].startswith('"') and not n[-1].startswith('"_')})
        external = sorted({s for s in strings if re.search(r'\.(DCL|LSP|DLL|PS1|VBS|EXE)$', s)})
        description = hints.get((fn['name'][2:], fn['file']), '') or '未提供可靠功能注释，请人工补充'
        record = dict(command=fn['name'][2:].upper(), file=fn['file'], line=fn['line'], description=description,
                      params=fn['params'], inputs=inputs, input_prompts=prompts, direct_dependencies=sorted(fn['calls'] & by_name.keys()),
                      reachable_dependencies=sorted({f['name'] for f in deps if f is not fn}),
                      external_files=external, object_candidates=objects, mutation_evidence=modifying)
        commands.append(record)
        args = ('形参: ' + ', '.join(fn['params']) if fn['params'] else '无函数形参') + '; 交互: ' + (', '.join(inputs) or '未发现 / 委托外部界面')
        if prompts:
            brief = [p.replace('\\r', '').replace('\\n', '').replace('\\t', ' ').strip() for p in prompts]
            args += '; 提示: ' + ' / '.join(brief[:3])
            if len(brief) > 3:
                args += f'（另 {len(brief) - 3} 项见 JSON）'
        dep_text = ', '.join(record['direct_dependencies'] + external) or 'CAD 内置 API'
        obj_text = (', '.join(objects) or '未静态确定') + ('；存在修改调用' if modifying else '；未发现直接/可达修改调用')
        command_lines.append('| ' + ' | '.join(escape(v) for v in [record['command'], description, args, dep_text, obj_text, f"{fn['file']}:{fn['line']}"]) + ' |')
    counts = Counter(f['rule'] for f in findings)
    report = ['# PROJECT_AUDIT', '', '> 自动生成，可用 `python scripts/audit_lsp.py --check` 检查是否过期。扫描结果与源码绑定，不包含 CAD 实机验收。', '',
              f'扫描 {len(inventories)} 个 LSP、{len(functions)} 个顶层函数、{len(commands)} 个命令入口。', '',
              '## 文件清单', '', '| 文件 | 字节 | 顶层表达式 | 函数 | 命令 |', '| --- | ---: | ---: | ---: | ---: |']
    for row in inventories:
        report.append('| ' + ' | '.join(str(row[k]) for k in ('file', 'bytes', 'top_level_forms', 'functions', 'commands')) + ' |')
    report += ['', '## 检查结论与边界', '',
               '- 编码、无 BOM、CRLF、整文件表达式解析：所有扫描文件通过，否则生成器直接失败。',
               '- 重复函数/命令：大小写归一后的顶层定义与 .NET CommandMethod 注册；不读取本机 PGP、CUI 或第三方工具，短命令别名仍需部署时核对。',
               '- 全局变量：枚举 setq / foreach / 常量 set 写入；跨文件写入不等于缺陷，AICAD 基目录是共享协议。动态作用域与计算得到的 set 名称不作自动修复。',
               '- UNDO：检查直接/引用函数调用和专属错误处理的关闭证据，并列出原生命令；只证明出现过关闭调用，不能证明每条异常路径都能关闭。',
               '- 错误处理与系统变量：检查局部绑定、恢复调用和快照；持久设置、调用方保存和间接恢复必须人工分类。',
               '- nil/选择集：标记直接消费可取消输入的危险形式；不做完整控制流/类型推断，不能保证其他路径无 nil。',
               '- review 是待核查候选，不是确认运行时故障；error 是确定的重复注册/定义或嵌套命令结构事实。', '',
               '## 分类计数', '', '| 规则 | 数量 |', '| --- | ---: |']
    for rule in ('duplicate-function', 'shared-global', 'command-conflict', 'nested-command', 'undo-close', 'undo-error-path', 'native-undo', 'error-binding', 'error-cleanup', 'sysvar-restore', 'nil-selection', 'implicit-global'):
        report.append(f'| {rule} | {counts[rule]} |')
    report += ['', '## 发现清单', '', '| 级别 | 检查 | 文件:行 | 函数 / 变量 | 证据 |', '| --- | --- | --- | --- | --- |']
    for f in sorted(findings, key=lambda f: (f['level'], f['rule'], f['file'], f['line'], f['evidence'])):
        report.append('| ' + ' | '.join(escape(v) for v in [f['level'], f['rule'], f"{f['file']}:{f['line']}", f['function'], f['evidence']]) + ' |')
    report += ['', '## 公共库与实际修复', '',
               '详见 [工程化说明](docs/ENGINEERING.md) 与 [公共库设计](common/README.md)。已抽象的纯函数使用构建时展开，运行时加载入口不变。',
               '高确定性修复、保留项与验证证据见 [人工审阅记录](docs/AUDIT_REVIEW.md)。本报告保留所有启发式候选，不以减少告警数量为目的改写正常命令。', '',
               '## 全局写入明细', '',
               '所有显式及隐式全局写入位置保存在 `docs/lsp-audit.json`，包含动态作用域辅助函数；同文件重复写入只作清单，不等同于重复声明冲突。', '']
    data = dict(schema_version=1, files=inventories, commands=commands, findings=findings,
                global_writes={k: [dict(file=f, line=l, function=n) for f, l, n in v] for k, v in sorted(globals_.items())})
    return {'COMMANDS.md': '\n'.join(command_lines) + '\n', 'PROJECT_AUDIT.md': '\n'.join(report),
            'docs/lsp-audit.json': json.dumps(data, ensure_ascii=False, indent=2) + '\n'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='regenerate documents')
    parser.add_argument('--check', action='store_true', help='fail on stale documents')
    parser.add_argument('--strict', action='store_true', help='also fail on confirmed structural findings')
    args = parser.parse_args()
    result = outputs()
    stale = []
    for name, text in result.items():
        path = ROOT / name
        raw = text.replace('\n', '\r\n').encode('utf-8')
        if args.write:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
        elif args.check and (not path.exists() or path.read_bytes() != raw):
            stale.append(name)
    data = json.loads(result['docs/lsp-audit.json'])
    errors = sum(f['level'] == 'error' for f in data['findings'])
    print(f"AUDIT: {len(data['files'])} LSP, {len(data['commands'])} commands, {errors} structural findings, {len(data['findings']) - errors} review candidates")
    if stale:
        print('STALE: ' + ', '.join(stale))
    return int(bool(stale) or (args.strict and errors > 0))


if __name__ == '__main__':
    raise SystemExit(main())
