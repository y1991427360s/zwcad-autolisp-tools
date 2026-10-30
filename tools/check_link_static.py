from pathlib import Path
"""Offline checks for AA_LINK text linking (SX / SX1 / SX2), no CAD.

Structure: command locals, declared setq/foreach variables, no vl-sort,
UTF-8 open, files closed. Behaviour: the delivered LISP helpers are run in a
small interpreter (value-file write/read round trip, line parsing, UID join,
newest-file priority, conflict count, text choice for TEXT/MTEXT targets).
"""
from functools import cmp_to_key

from lsp_common import SOURCE, parse, read_source, walk

raw, text = read_source(SOURCE)
forms = parse(text)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}

LINK = sorted(k for k in functions if k.startswith('aa:link-'))
COMMANDS = ['c:sx0', 'c:sx', 'c:sx1', 'c:sx2']
for name in COMMANDS:
    assert name in functions, f'{name} not defined at top level'
for name in ('aa:link-export', 'aa:link-read-file', 'aa:link-join', 'aa:link-parse-line',
             'aa:link-write-records', 'aa:link-read-lines', 'aa:link-text-from-rec',
             'aa:link-collect-files', 'aa:link-ask-folder'):
    assert name in functions, f'{name} missing'

CMD_LOCALS = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
BUILTINS_NOT_VARS = {'last', 'list', 'type', 'length', 'open', 'close', 'read', 'min', 'max',
                     'apply', 'member', 'assoc', 'subst', 'append', 'reverse', 'set', 'eval'}

for name in LINK + COMMANDS:
    form = functions[name]
    signature = form[2]
    declared = set(signature) - {'/'}
    clash = declared & BUILTINS_NOT_VARS
    assert not clash, f'{name}: local shadows builtin {clash}'
    if name.startswith('c:'):
        missing = CMD_LOCALS - declared
        assert not missing, f'{name}: missing command locals {missing}'
        body = form[3:]
        assert body[0][:2] == ['aa:cmd-begin', f'"{name[2:].upper()}"'], f'{name}: no aa:cmd-begin'
        assert body[-1] == ['aa:cmd-end'], f'{name}: aa:cmd-end must be last'
    for node in walk(form[3:]):
        head = node[0]
        assert head != 'vl-sort', f'{name}: vl-sort is banned'
        if head == 'setq':
            assert (len(node) - 1) % 2 == 0, f'{name}: odd setq'
            for var in node[1::2]:
                assert var in declared or var.startswith('*'), f'{name}: undeclared setq {var}'
        if head == 'foreach':
            assert node[1] in declared, f'{name}: undeclared foreach var {node[1]}'

# 值文件按 UTF-8 打开，打开后总会关闭
opens = [n for n in walk(functions['aa:link-open']) if n[:2] == ['vl-catch-all-apply', ['quote', 'open']]]
assert any('"utf8"' in n[2] for n in opens), 'aa:link-open must request utf8'
for name in ('aa:link-export', 'aa:link-read-file'):
    flat = list(walk(functions[name]))
    assert any(n[:2] == ['close', 'f'] for n in flat), f'{name}: file not closed'
    assert any(n[0] == 'vl-catch-all-apply' for n in flat), f'{name}: writer/reader not guarded'
# SX1 导出，SX2 读取
assert any(n[0] == 'aa:link-export' for n in walk(functions['c:sx1'])), 'SX1 must export'
assert any(n[0] == 'aa:link-read-file' for n in walk(functions['c:sx2'])), 'SX2 must read'
assert any(n[0] == 'aa:merge-sort' for n in walk(functions['c:sx2'])), 'SX2 must use aa:merge-sort'


# ---------------------------------------------------------------- mini interpreter
class Sym(str):
    """Quoted symbol (e.g. 'STR); compared case-insensitively like AutoLISP."""


def unescape(token):
    body, out, i = token[1:-1], [], 0
    while i < len(body):
        ch = body[i]
        if ch == '\\' and i + 1 < len(body):
            nxt = body[i + 1]
            out.append({'n': '\n', 'r': '\r', 't': '\t', '\\': '\\', '"': '"'}.get(nxt, nxt))
            i += 2
        else:
            out.append(ch)
            i += 1
    return ''.join(out)


def quoted(v):
    if isinstance(v, list):
        return [quoted(x) for x in v]
    if v.startswith('"'):
        return unescape(v)
    return Sym(v.lower())


def lcons(a, b):
    if b is None:
        return [a]
    if isinstance(b, list):
        return [a] + b
    return (a, b)


def car(x):
    return x[0] if x else None


def cdr(x):
    if not x:
        return None
    if isinstance(x, tuple):
        return x[1]
    return x[1:] or None


def lisp_type(v):
    if isinstance(v, str):
        return Sym('str')
    if isinstance(v, int):
        return Sym('int')
    if isinstance(v, float):
        return Sym('real')
    if isinstance(v, list):
        return Sym('list')
    return None


def eq(a, b):
    if isinstance(a, list) and not a:
        a = None
    if isinstance(b, list) and not b:
        b = None
    return a == b


class Port:
    def __init__(self, lines=None):
        self.lines = list(lines or [])
        self.out = []

    def read(self):
        return self.lines.pop(0) if self.lines else None


native = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda a, b: a * b,
    '<': lambda a, b: a < b, '>': lambda a, b: a > b,
    '<=': lambda a, b: a <= b, '>=': lambda a, b: a >= b,
    '=': lambda a, b: eq(a, b), '/=': lambda a, b: not eq(a, b),
    'equal': lambda a, b, *f: eq(a, b),
    'null': lambda x: not x, 'not': lambda x: not x,
    'car': car, 'cdr': cdr,
    'cadr': lambda x: car(cdr(x)), 'caddr': lambda x: car(cdr(cdr(x))),
    'caar': lambda x: car(car(x)), 'cdar': lambda x: cdr(car(x)),
    'cons': lcons, 'list': lambda *a: list(a) or None,
    'append': lambda *ls: [y for l in ls if l for y in l] or None,
    'reverse': lambda l: list(reversed(l or [])) or None,
    'length': lambda l: len(l or []),
    'member': lambda x, l: next((l[i:] for i, y in enumerate(l or []) if eq(x, y)), None),
    'assoc': lambda k, l: next((p for p in (l or []) if p and eq(p[0], k)), None),
    '1+': lambda x: x + 1, '1-': lambda x: x - 1,
    'chr': chr, 'strlen': len, 'type': lisp_type,
    'strcat': lambda *a: ''.join(a),
    'substr': lambda s, start, n=None: s[start - 1:] if n is None else s[start - 1:start - 1 + n],
    'vl-string-search': lambda pat, s, start=0: (lambda r: None if r < 0 else r)(s.find(pat, start)),
    'write-line': lambda s, port: port.out.append(s) or s,
    'read-line': lambda port: port.read(),
}


def call(fn, args, env):
    if isinstance(fn, str) and fn in native:
        return native[fn](*args)
    if isinstance(fn, list) and fn[0] == 'lambda':
        signature, body = fn[1], fn[2:]
    else:
        form = functions[fn]
        signature, body = form[2], form[3:]
    cut = signature.index('/') if '/' in signature else len(signature)
    local = dict(env)
    local.update({v: None for v in signature[cut + 1:]})
    local.update(zip(signature[:cut], args))
    result = None
    for expr in body:
        result = evaluate(expr, local)
    return result


def merge_sort(items, cmp_fn, env=None):
    def cmp(a, b):
        if call(cmp_fn, [a, b], {}):
            return -1
        if call(cmp_fn, [b, a], {}):
            return 1
        return 0
    return sorted(items or [], key=cmp_to_key(cmp)) or None  # Python sort is stable


native['aa:merge-sort'] = merge_sort


def evaluate(node, env):
    if not isinstance(node, list):
        if node == 't':
            return True
        if node == 'nil':
            return None
        if node.startswith('"'):
            return unescape(node)
        try:
            v = float(node)
            return int(v) if v.is_integer() and '.' not in node and 'e' not in node else v
        except ValueError:
            return env.get(node)
    op, *args = node
    if op == 'quote':
        return quoted(args[0])
    if op == 'function':
        return args[0]
    if op == 'setq':
        val = None
        for key, expr in zip(args[::2], args[1::2]):
            val = env[key] = evaluate(expr, env)
        return val
    if op == 'if':
        if evaluate(args[0], env):
            return evaluate(args[1], env)
        return evaluate(args[2], env) if len(args) > 2 else None
    if op == 'cond':
        for branch in args:
            test = evaluate(branch[0], env)
            if test:
                for expr in branch[1:]:
                    test = evaluate(expr, env)
                return test
        return None
    if op == 'while':
        while evaluate(args[0], env):
            for expr in args[1:]:
                evaluate(expr, env)
        return None
    if op == 'and':
        result = True
        for a in args:
            result = evaluate(a, env)
            if not result:
                return None
        return True
    if op == 'or':
        for a in args:
            if evaluate(a, env):
                return True
        return None
    if op == 'foreach':
        for v in evaluate(args[1], env) or []:
            env[args[0]] = v
            for expr in args[2:]:
                evaluate(expr, env)
        return None
    if op == 'progn':
        result = None
        for a in args:
            result = evaluate(a, env)
        return result
    return call(op, [evaluate(a, env) for a in args], env)


def run(name, *args):
    return call(name, list(args), {})


# ---------------------------------------------------------------- behaviour
TAB = '\t'

# 1. 文字选择：TEXT 取纯文本；MTEXT→MTEXT 取原文；超长原文不处理；含组码 3 的目标不处理
rec_text = ['D1|2A', '1-4n', None]
rec_mtext = ['D1|2B', 'A B', '{\\fSimSun;A}\\PB']
text_ed = [(0, 'TEXT'), (1, 'old')]
mtext_ed = [(0, 'MTEXT'), (1, 'old')]
assert run('aa:link-text-from-rec', text_ed, rec_text) == '1-4n'
assert run('aa:link-text-from-rec', text_ed, rec_mtext) == 'A B'
assert run('aa:link-text-from-rec', mtext_ed, rec_mtext) == '{\\fSimSun;A}\\PB'
assert run('aa:link-text-from-rec', mtext_ed, rec_text) == '1-4n'
assert run('aa:link-text-from-rec', mtext_ed, ['u', 'p', 'x' * 251]) is None
assert run('aa:link-text-from-rec', [(0, 'MTEXT'), (3, 'x' * 250), (1, 'y')], rec_text) is None

# 2. 行解析：UID 含中文图名与 |，内容可含 TAB；表头、空行、坏行忽略；行尾 \r 去掉
assert run('aa:link-parse-line', f'P{TAB}2026.1017-卷册A.dwg|2A{TAB}电缆 1-4n') == ['P', '2026.1017-卷册A.dwg|2A', '电缆 1-4n']
assert run('aa:link-parse-line', f'M{TAB}D|2A{TAB}a{TAB}b\r') == ['M', 'D|2A', f'a{TAB}b']
assert run('aa:link-parse-line', f'P{TAB}D|2A{TAB}') == ['P', 'D|2A', '']
assert run('aa:link-parse-line', f'AA_LINK_VALUES{TAB}1') is None
assert run('aa:link-parse-line', '') is None
assert run('aa:link-parse-line', f'X{TAB}D|2A{TAB}v') is None
assert run('aa:link-parse-line', f'P{TAB}{TAB}v') is None

# 3. 写出 → 读回往返；含换行的内容不写出
roots = [
    ('D1|2A', [(0, 'TEXT'), (5, '2A'), (1, '电缆1')]),
    ('D1|2B', [(0, 'MTEXT'), (5, '2B'), (1, '{\\fSimSun;A}\\PB')]),
    ('D1|2C', [(0, 'TEXT'), (5, '2C'), (1, 'bad\nline')]),
]
port = Port()
assert run('aa:link-write-records', port, roots) == 2
assert port.out[0] == f'AA_LINK_VALUES{TAB}1'
assert port.out[1:] == [f'P{TAB}D1|2A{TAB}电缆1', f'P{TAB}D1|2B{TAB}A B', f'M{TAB}D1|2B{TAB}{{\\fSimSun;A}}\\PB']
recs = run('aa:link-read-lines', Port(port.out), None)
assert recs == [['D1|2B', 'A B', '{\\fSimSun;A}\\PB'], ['D1|2A', '电缆1', None]], recs
# 孤立 M 行（无紧邻同 UID 的 P 行）不生效
recs_orphan = run('aa:link-read-lines', Port([f'P{TAB}U1{TAB}a', f'M{TAB}U2{TAB}m', f'M{TAB}U1{TAB}late']), None)
assert recs_orphan == [['U1', 'a', None]], recs_orphan

# 4. 较新文件优先：先读旧文件、后读新文件，稳定排序后同 UID 首条为新值
old_file = [f'P{TAB}A|1{TAB}旧值', f'P{TAB}A|2{TAB}同值']
new_file = [f'P{TAB}A|1{TAB}新值', f'P{TAB}A|2{TAB}同值']
recs = run('aa:link-read-lines', Port(old_file), None)
recs = run('aa:link-read-lines', Port(new_file), recs)
recs = merge_sort(recs, 'aa:link-uid<')
assert recs[0] == ['A|1', '新值', None], recs
assert run('aa:link-count-conflicts', recs) == 1

# 5. 归并匹配：多个副本共用 UID、缺失 UID、首尾边界
items = merge_sort([('A|1', 'e1'), ('B|9', 'e2'), ('A|1', 'e3'), ('A|0', 'e4'), ('Z|1', 'e5')], 'aa:link-uid<')
pairs = run('aa:link-join', items, recs)
got = {car(p): (lambda r: r[1] if r else None)(cdr(p)) for p in pairs}
assert got == {'e1': '新值', 'e3': '新值', 'e2': None, 'e4': None, 'e5': None}, got
assert [car(p) for p in pairs] == ['e4', 'e1', 'e3', 'e2', 'e5'], pairs
assert all(cdr(p) is None for p in run('aa:link-join', items, None))

# 6. SX1 按句柄直接定位原件（handent），不在原件列表里逐个比对
def xd(dwg, h):
    return [-3, ['AA_LINK', (1000, dwg), (1000, h)]]
ents = {
    'e2A': [(0, 'TEXT'), (5, '2A'), (1, '原件'), xd('D1', '2A')],     # 原件
    'e3F': [(0, 'TEXT'), (5, '3F'), (1, '副本'), xd('D1', '2A')],     # 句柄 3F 处是副本
    'e4C': [(0, 'LINE'), (5, '4C'), xd('D1', '4C')],                  # 非文字
}
handles = {'2A': 'e2A', '3F': 'e3F', '4C': 'e4C'}
native['mapcar'] = lambda fn, lst: [call(fn, [x], {}) for x in (lst or [])] or None
native['handent'] = lambda h: handles.get(h)
native['entget'] = lambda en, apps=None: ents.get(en)
assert run('aa:link-info', ents['e2A']) == ['D1', '2A']
assert run('aa:link-root-ed', ['D1', '2A'], 'D1') == ents['e2A']
assert run('aa:link-root-ed', ['D1', '2A'], 'D2') is None          # 原件在其他图纸
assert run('aa:link-root-ed', ['D1', '99'], 'D1') is None          # 原件已删除
assert run('aa:link-root-ed', ['D1', '3F'], 'D1') is None          # 句柄处不是原件
assert run('aa:link-root-ed', ['D1', '4C'], 'D1') is None          # 句柄处不是文字
assert run('aa:link-root-ed', None, 'D1') is None
assert not any(n[0] == 'assoc' and 'roots' in n for n in walk(functions['c:sx1'])), 'SX1 must not scan roots per copy'

# 7. SX0 清除标记：副本删除 AA_LINK，原件与无标记文字跳过
ents = {
    'root': [(-1, 'root'), (0, 'TEXT'), (5, '2A'), (1, '原件'), xd('D1', '2A')],
    'copy': [(-1, 'copy'), (0, 'TEXT'), (5, '3F'), (1, '副本'), xd('D1', '2A')],
    'paste': [(-1, 'paste'), (0, 'TEXT'), (5, '2A'), (1, '外图副本'), xd('D9', '2A')],
    'plain': [(-1, 'plain'), (0, 'MTEXT'), (5, '50'), (1, '普通')],
}
modded, said = [], []
native.update({
    'aa:cmd-begin': lambda tag: None, 'aa:cmd-end': lambda: None,
    'princ': lambda s: said.append(s) or s, 'itoa': str,
    'ssget': lambda flt: ['root', 'copy', 'paste', 'plain'],
    'sslength': len, 'ssname': lambda ss, i: ss[i],
    'subst': lambda new, old, lst: [new if x == old else x for x in lst],
    'entmod': lambda ed: modded.append(ed) or ed,
    'dictsearch': lambda d, name: [(1, 'D1')], 'namedobjdict': lambda: 'NOD',
})
run('c:sx0')
assert [ed[0][1] for ed in modded] == ['copy', 'paste'], modded
# 解释器把引用表中的 -3 读作符号，按文本比较；真实 LISP 中为整数 -3
assert all(str(ed[-1][0]) == '-3' and ed[-1][1:] == [['AA_LINK']] for ed in modded), modded
assert any('清除副本标记 2 个，跳过原件 1 个，无标记 1 个' in s for s in said), said

# SXD：值文件名换成图纸名；目标图表达式纯 ASCII、带图名校验和完成标记
assert run('aa:link-dwg-of', 'E:\\卷册\\A图.aalink.txt') == 'E:\\卷册\\A图.dwg'
source = (Path(__file__).resolve().parents[1] / 'AA整合版本.lsp').read_bytes().decode('utf-8')
assert '(aa:link-export-roots dwg-id)' in source[source.index('(defun c:SX ('):source.index('(defun c:SXC')]  # SX 标记后直接更新值文件
assert '(aa:link-locate-dwg info dir)' in source[source.index('(defun c:SXD'):source.index('(defun aa:link-clock')]  # 跳转不依赖值文件
sxd_src = source[source.index('(defun aa:link-vbs-str'):source.index('(defun aa:link-pick-text')]
assert 'vla-Activate' not in sxd_src and 'vla-Open' not in sxd_src  # LISP 切文档后命令会挂起，切换和打开都交给 VBS
assert 'a.Documents.Open' in sxd_src and 't.Activate' in sxd_src and 'USERS5' in sxd_src and 'wscript.exe' in sxd_src
assert '(min (- (cadr b) (cadr a)) (- (car b) (car a)))' in sxd_src  # 竖排文字按短边定缩放
assert '(aa:cmd-begin' not in source[source.index('(defun c:SXD'):source.index('(defun aa:link-clock')]  # 只读命令不开撤销组

print(f'PASS link: {len(LINK)} aa:link helpers + SX/SX1/SX2 structure; utf8 open/close; '
      'SX0 clears copies only; value-file round trip; handent root lookup; line parsing; newest-file priority; UID join; TEXT/MTEXT choice')
