"""电缆编号命令 BH1 / BH2 / BHG 离线检查：结构检查 + 用小型求值器实际执行命令源码（CAD 函数用桩替代）。

场景模拟一根电缆两端分两次框选：
  1. 起点柜“1号主变保护柜”首次编号（前缀 1B、从 101 开始），含录波 130、公用测控 131、
     同终点多根 A/B、已手工编号的记入、芯线缺原理号的无法编号；
  2. 对端“主变测控柜1”：按记录填号、两端编号不一致标红、编号被另一根电缆占用标红、
     顺序号排到 130/131 时询问（跳过 130、照常使用 131）；
  3. 两位数起始号 01 → DS-01、DS-02；
  4. 记录文件写入失败时不改图。
  5. BHG 以图为准改记录（原编号存为旧编号）、“未编号”删除记录、编号原属选择外的电缆时删原记录改给这根；
  6. 另一端 BH2 把旧编号自动改为新编号；
  7. 旧版 6 列记录文件、旧编号累积、旧编号不再分配。
  8. 图上只改了某一端柜名（起点或终点）或原理号时，BHG 判定为同一根电缆并更正记录。
  9. 提速后的文字索引顺扫、旧原因文字一次清理，用随机场景与逐线窗口查询结果对照。
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lsp_common import ARITY, SOURCE, defun_forms, parse, read_source, walk  # noqa: E402

_, TEXT = read_source(SOURCE)
FORMS = parse(TEXT)
FUNCS = {f[1]: f for f in defun_forms(FORMS) if isinstance(f[1], str)}

# ---------------------------------------------------------------- 结构检查
CMD_LOCALS = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
BH = {k: v for k, v in FUNCS.items() if k.startswith('bh:') or k in ('c:bh1', 'c:bh2', 'c:bh3', 'c:bhg')}
for cmd in ('c:bh1', 'c:bh2', 'c:bh3', 'c:bhg'):
    assert cmd in BH, f'{cmd} not found'
    assert CMD_LOCALS <= set(FUNCS[cmd][2]), f'{cmd} 局部变量缺少命令框架变量'
for name, form in BH.items():
    sig = form[2]
    declared = set(x for x in sig if x != '/')
    for node in walk(form[3:]):
        head = node[0]
        if not isinstance(head, str):
            continue
        if head == 'lambda':
            declared |= set(node[1])
        if head in ARITY:
            low, high = ARITY[head]
            assert low <= len(node) - 1 <= high, (name, head, len(node) - 1)
        if head == 'setq':
            assert (len(node) - 1) % 2 == 0, (name, 'odd setq')
            for var in node[1::2]:
                assert var in declared or var.startswith('*'), f'{name}: 未声明的 setq 变量 {var}'
        if head == 'foreach':
            assert node[1] in declared, f'{name}: 未声明的循环变量 {node[1]}'
        assert head != 'vl-sort', f'{name}: 禁止 vl-sort'


def calls(form):
    return [n[0] for n in walk(form) if isinstance(n[0], str)]


for cmd in ('c:bh2', 'c:bhg'):
    cmd_calls = calls(FUNCS[cmd])
    assert cmd_calls.count('aa:cmd-begin') == 1 and cmd_calls.count('aa:cmd-end') == 1, cmd
    assert 'bh:prepare' in cmd_calls, f'{cmd} 应复用 bh:prepare'
    assert cmd_calls.index('bh:write-records') < cmd_calls.index('bh:finish'), f'{cmd} 必须先写记录再改图'
assert calls(FUNCS['c:bh2']).index('bh:write-records') < calls(FUNCS['c:bh2']).index('jm:set-text')
assert 'bh:ask-prefix' not in calls(FUNCS['c:bh2']) and 'bh:special' not in calls(FUNCS['c:bh2']), 'BH2 只记录和填写，不分配新编号'
_bh2 = calls(FUNCS['c:bh1'])
assert _bh2.count('aa:cmd-begin') == 1 and _bh2.count('aa:cmd-end') == 1
assert _bh2.index('bh:write-records') < _bh2.index('bh:set-num'), 'BH1 必须先写记录再改图'
for f in ('bh:x-vlines', 'bh:x-texts', 'xy:get-vrecs-for-hline-ed', 'xy:build-text-meta-list'):
    assert f in calls(FUNCS['bh:analyze-pass']) + calls(FUNCS['bh:x-vlines']), f'BH1 识别应走全图查询 {f}'
assert 'xy:window-wcs' not in calls(FUNCS['bh:analyze-pass']) + calls(FUNCS['bh:x-texts']) + calls(FUNCS['bh:x-vlines']), 'BH1 不能依赖视口'
assert calls(FUNCS['bh:x-texts']).count('bh:query') == 1 and 'bh:query' in calls(FUNCS['bh:x-vlines']), 'BH1 每类只查一次'
assert '"_X"' in str(FUNCS['bh:query']) and '"_C"' in str(FUNCS['bh:query']), 'bh:query 应有视图内快速查询和全图查询'
assert calls(FUNCS['bh:analyze-one']).count('bh:analyze-pass') == 2, '快速查询没识别成功时应改用全图再识别一次'
assert not [n for n in walk(FUNCS['c:bh1']) if n == ['redraw']], 'BH1 不应整图 redraw（只允许单个对象高亮）'
assert 'bh:analyze-picked' in calls(FUNCS['c:bh1']) and 'bh:view-restore' in calls(FUNCS['c:bh1']), 'BH1 应批量识别并恢复视图'
assert calls(FUNCS['bh:analyze-picked']).count('bh:zoom-box') == 2, 'BH1 先缩放到电缆线、再缩放到原理号区域'
for f in ('jm:line-principles', 'xy:filter-green-hlines', 'xyg:dedup-hlines', 'xyg:find-prefix-text'):
    assert f in calls(FUNCS['bh:prepare']) + calls(FUNCS['bh:analyze']), f'BH2 应复用 {f}'
print('PASS: BH1/BH2/BHG 结构检查')


# ---------------------------------------------------------------- 求值器（动态作用域）
class Env:
    def __init__(self, parent=None, names=()):
        self.vars = {n: None for n in names}
        self.parent = parent

    def find(self, k):
        e = self
        while e is not None:
            if k in e.vars:
                return e
            e = e.parent
        return None

    def get(self, k):
        e = self.find(k)
        return e.vars[k] if e else None

    def set(self, k, v):
        e = self.find(k) or GLOBAL
        e.vars[k] = v


GLOBAL = Env()


def unescape(s):
    return re.sub(r'\\(.)', lambda m: {'n': '\n', 'r': '\r', 't': '\t'}.get(m.group(1), m.group(1)), s[1:-1])


def strip_quote(v):
    if isinstance(v, list):
        if v and v[0] == 'lambda':
            return v
        if len(v) == 3 and v[1] == '.':
            return (strip_quote(v[0]), strip_quote(v[2]))
        return [strip_quote(x) for x in v]
    if isinstance(v, str) and v.startswith('"'):
        return unescape(v)
    if isinstance(v, str) and re.fullmatch(r'-?\d+', v):     # 引用列表里的整数（如组码 '(10 11)）
        return int(v)
    return v


class Sym(str):
    pass


def lt(v):
    """LISP 真值：只有 nil（None/空表/False）为假，0 和空串为真。"""
    return v is not None and v is not False and v != []


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
            return int(v) if v.is_integer() and '.' not in node else v
        except ValueError:
            return env.get(node)
    if not node:
        return None
    op, *args = node
    if op == 'quote':
        return strip_quote(args[0])
    if op == 'setq':
        val = None
        for k, v in zip(args[::2], args[1::2]):
            val = evaluate(v, env)
            env.set(k, val)
        return val
    if op == 'if':
        if lt(evaluate(args[0], env)):
            return evaluate(args[1], env)
        return evaluate(args[2], env) if len(args) > 2 else None
    if op == 'cond':
        for br in args:
            test = evaluate(br[0], env)
            if lt(test):
                res = test
                for e in br[1:]:
                    res = evaluate(e, env)
                return res
        return None
    if op == 'while':
        n = 0
        while lt(evaluate(args[0], env)):
            n += 1
            assert n < 100000, 'while 死循环'
            for b in args[1:]:
                evaluate(b, env)
        return None
    if op in ('and', 'or'):
        res = op == 'and'
        for a in args:
            res = evaluate(a, env)
            if (op == 'and' and not lt(res)) or (op == 'or' and lt(res)):
                return res if lt(res) else None
        return res if lt(res) else None
    if op == 'repeat':
        res = None
        for _ in range(evaluate(args[0], env) or 0):
            for b in args[1:]:
                res = evaluate(b, env)
        return res
    if op == 'foreach':
        for v in evaluate(args[1], env) or []:
            env.set(args[0], v)
            for b in args[2:]:
                evaluate(b, env)
        return None
    if op == 'progn':
        res = None
        for a in args:
            res = evaluate(a, env)
        return res
    if op == 'defun':
        return None
    vals = [evaluate(a, env) for a in args]
    return call(op, vals, env)


def call(fn, args, env):
    if isinstance(fn, list) and fn[0] == 'lambda':
        params = fn[1]
        cut = params.index('/') if '/' in params else len(params)
        local = Env(env, params[:cut] + params[cut + 1:])
        for k, v in zip(params[:cut], args):
            local.vars[k] = v
        res = None
        for b in fn[2:]:
            res = evaluate(b, local)
        return res
    if fn in SPECIAL:
        return SPECIAL[fn](args, env)
    if fn in NATIVE:
        return NATIVE[fn](*args)
    form = FUNCS[fn]
    return call(['lambda', form[2]] + form[3:], args, env)


def lisp_less_sort(lst, fn, env):
    from functools import cmp_to_key

    def cmp(a, b):
        if lt(call(fn, [a, b], env)):
            return -1
        if lt(call(fn, [b, a], env)):
            return 1
        return 0
    return sorted(lst or [], key=cmp_to_key(cmp)) or None


def wcmatch(s, pat):
    def one(p):
        rx, i = '', 0
        while i < len(p):
            c = p[i]
            if c == '`' and i + 1 < len(p):
                i += 1
                rx += re.escape(p[i])
            elif c == '#':
                rx += '[0-9]'
            elif c == '@':
                rx += '[A-Za-z]'
            elif c == '*':
                rx += '.*'
            elif c == '?':
                rx += '.'
            elif c == '[':
                j = p.index(']', i)
                body = p[i + 1:j]
                esc = lambda b: re.sub(r'([\\\]\^])', r'\\\1', b)  # 保留 0-9 这类范围
                rx += '[^' + esc(body[1:]) + ']' if body.startswith('~') else '[' + esc(body) + ']'
                i = j
            else:
                rx += re.escape(c)
            i += 1
        return re.fullmatch(rx, s, re.S) is not None
    return any(one(p) for p in pat.split(',')) or None


def cabinet(s):
    s = re.sub(r'[\s\u3000\xa0]', '', s or '')
    while s.startswith('至'):
        s = s[1:]
    return s.upper()


def substr(s, start, n=None):
    return s[start - 1:] if n is None else s[start - 1:start - 1 + n]


def lcons(a, b):
    return [a] + b if isinstance(b, list) else [a] if b is None else (a, b)


def truth(v):
    return True if v else None


NATIVE = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) else a / b,
    'equal': lambda a, b, tol=0: truth(abs(a - b) <= tol if isinstance(a, (int, float)) else a == b),
    '*': lambda *a: __import__('math').prod(a),
    'float': float, 'abs': abs, 'rem': lambda a, b: a % b, 'min': lambda *a: min(a), 'max': lambda *a: max(a), '1+': lambda x: x + 1, '1-': lambda x: x - 1,
    '<': lambda *a: truth(all(a[i] < a[i + 1] for i in range(len(a) - 1))), '<=': lambda *a: truth(all(a[i] <= a[i + 1] for i in range(len(a) - 1))),
    '>': lambda a, b: truth(a > b), '>=': lambda a, b: truth(a >= b),
    '=': lambda a, b: truth(a == b), '/=': lambda a, b: truth(a != b), 'eq': lambda a, b: truth(a == b),
    'not': lambda x: truth(not lt(x)), 'null': lambda x: truth(not lt(x)),
    'car': lambda a: a[0] if a else None,
    'cdr': lambda a: a[1] if isinstance(a, tuple) else ((a[1:] or None) if a else None),
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'caddr': lambda a: a[2] if a and len(a) > 2 else None,
    'cadddr': lambda a: a[3] if a and len(a) > 3 else None,
    'cddr': lambda a: (a[2:] or None) if a else None,
    'cdddr': lambda a: (a[3:] or None) if a else None,
    'nth': lambda i, a: a[i] if a and 0 <= i < len(a) else None,
    'logand': lambda *a: __import__('functools').reduce(lambda x, y: x & y, a, -1),
    'list': lambda *a: list(a) or None, 'cons': lcons,
    'append': lambda *a: [x for p in a for x in (p or [])] or None,
    'reverse': lambda a: list(reversed(a or [])) or None,
    'length': lambda a: len(a or []),
    'member': lambda x, a: a[a.index(x):] if a and x in a else None,
    'assoc': lambda k, a: next((v for v in (a or []) if isinstance(v, (list, tuple)) and v[0] == k), None),
    'subst': lambda new, old, a: [new if x == old else x for x in a],
    'strcat': lambda *a: ''.join(a), 'strlen': lambda s: len(s), 'substr': substr,
    'strcase': lambda s: s.upper(), 'itoa': lambda n: str(n), 'chr': lambda n: chr(n),
    'atoi': lambda s: int(re.match(r'\s*-?\d*', s).group(0) or 0) if re.match(r'\s*-?\d', s) else 0,
    'rtos': lambda x, *a: f'{x:.2f}',
    'vl-string-search': lambda p, s, st=0: (s.find(p, st) if s.find(p, st) >= 0 else None),
    'vl-string-trim': lambda chars, s: s.strip(chars),
    'vl-string-right-trim': lambda chars, s: s.rstrip(chars),
    'wcmatch': wcmatch,
    'hddl:cabinet': cabinet,
    'aa:str-replace-all': lambda old, new, s: s.replace(old, new),
    'vl-catch-all-error-p': lambda x: None,
    'ascii': lambda s: ord(s[0]),
    'vl-remove': lambda x, a: [v for v in (a or []) if v != x] or None,
    'vl-position': lambda x, a: a.index(x) if a and x in a else None,
    'vl-string-position': lambda code, s, start=None, from_end=None:
        (s.rfind(chr(code)) if from_end else s.find(chr(code), start or 0)) if chr(code) in s else None,
}


def sp_merge_sort(args, env):
    return lisp_less_sort(args[0], args[1], env)


def sp_mapcar(args, env):
    fn, lists = args[0], args[1:]
    n = min(len(x or []) for x in lists)
    return [call(fn, [l[i] for l in lists], env) for i in range(n)] or None


def sp_every(args, env):
    return truth(all(lt(call(args[0], [x], env)) for x in args[1] or []))


def sp_some(args, env):
    for x in args[1] or []:
        r = call(args[0], [x], env)
        if lt(r):
            return r
    return None


def sp_catch(args, env):
    return call(args[0], args[1] or [], env)


def sp_remove_if(args, env):
    return [x for x in (args[1] or []) if not lt(call(args[0], [x], env))] or None


SPECIAL = {'apply': lambda args, env: call(args[0], args[1] or [], env), 'vl-remove-if': sp_remove_if, 'aa:merge-sort': sp_merge_sort, 'mapcar': sp_mapcar, 'vl-every': sp_every,
           'vl-some': sp_some, 'vl-catch-all-apply': sp_catch}


# ---------------------------------------------------------------- CAD 桩
class Cad:
    def __init__(self, files):
        self.files = files          # 路径 → 行列表（模拟同一文件夹共享记录）
        self.ents = {}
        self.lines = []
        self.answers = []
        self.out = []
        self.markers = []
        self.alerts = []
        self.selected = []
        self.write_fail = False
        self.prompts = []
        self.reports = []

    def text(self, en, s, color=7):
        self.ents[en] = {'text': s, 'color': color}

    def add_line(self, ln, y, dest, num, prins, miss=0, lead=10.0):
        num_en = ln + '_num'
        self.text(num_en, num)
        if dest is not None:
            self.text(ln + '_dest', '至' + dest)
        self.ents[ln] = {'hinfo': [0.0, 100.0, y, [100.0, y, 0.0]], 'dest': dest,
                         'num_en': num_en, 'prins': prins, 'miss': miss, 'lead': lead}
        self.lines.append(ln)

    def ed(self, en):
        e = self.ents[en]
        if 'hinfo' in e:
            return [['_line', en]]
        return [(0, 'TEXT'), (1, e['text']), (62, e['color'])] + ([(5, e['handle'])] if 'handle' in e else [])

    def install(self, start_name):
        cad = self
        self.text('start', start_name)

        def line_texts(hinfo):
            ln = next(l for l in cad.lines if cad.ents[l]['hinfo'] is hinfo)
            e = cad.ents[ln]
            out = [[60.0, e['num_en'], cad.ents[e['num_en']]['text']]]
            if e['dest'] is not None:                  # None：线上没有“至…”（不是电缆）
                out.append([81.5, ln + '_dest', cad.ents[ln + '_dest']['text']])
            return out

        def line_prins(ed, *a):
            e = cad.ents[ed[0][1]]
            return [e['prins'] or None, e['miss']]

        def set_text(en, v):
            cad.ents[en]['text'] = v

        def color(en, c):
            cad.ents[en]['color'] = c

        def getstring(*a):
            cad.prompts.append(a[-1])
            return cad.answers.pop(0)

        def getkword(p):
            cad.prompts.append(p)
            return cad.answers.pop(0)

        class F:
            def __init__(self, path, mode):
                self.path, self.mode = path, mode
                self.buf = list(cad.files.get(path, [])) if mode == 'r' else []

        def lopen(path, mode):
            if mode == 'w' and cad.write_fail:
                return None
            return F(path, mode)

        def read_line(f):
            return f.buf.pop(0) if f.buf else None

        def write_line(s, f):
            f.buf.append(s)
            return s

        def close(f):
            if f.mode == 'w':
                cad.files[f.path] = f.buf

        def ssadd(*a):
            if not a:
                return []
            if a[0] not in a[1]:                # 与真实 ssadd 一致：已在选择集里的不重复加入
                a[1].append(a[0])
            return a[1]

        def sssetfirst(_, ss):
            cad.selected = list(ss or [])

        NATIVE.update({
            'aa:cmd-begin': lambda tag: None, 'aa:cmd-end': lambda: None,
            'getvar': lambda v: {'DWGTITLED': 1, 'DWGPREFIX': 'D:\\proj\\', 'DWGNAME': 'a.dwg', 'DATE': 2461000.5,
                                 'TEMPPREFIX': 'C:\\T\\'}[v],
            # 结果卡片文件：改名成 report.txt 时把内容并入 out，断言可以照常在输出里找明细和完整统计
            'getenv': lambda v: 'C:\\T', 'vl-mkdir': lambda d: True,
            'vl-file-delete': lambda f: cad.files.pop(f, None) and True,
            'vl-file-rename': lambda a, b: (cad.files.__setitem__(b, cad.files.pop(a)),
                                            cad.reports.append(list(cad.files[b])),
                                            cad.out.extend(cad.files[b]))[-1] or True,
            'menucmd': lambda s: '2026-10-24 15:00:00',
            'princ': lambda *a: cad.out.append(a[0] if a else '') or (a[0] if a else None),
            'alert': lambda s: cad.alerts.append(s),
            'ssget': lambda *a: 'SS', 'xy:ss->list': lambda ss: ss,
            'xy:filter-green-hlines': lambda ss: list(cad.lines),
            'xyg:dedup-hlines': lambda lst, tol: lst or None,
            'xyg:find-prefix-text': lambda ss: 'start',
            'entget': cad.ed,
            'aa:ysdl-get-plain-text': lambda ed: ed[1][1],
            'xy:collect-vlines': lambda lines: None, 'xy:build-vline-buckets': lambda v: None,
            'xy:collect-texts': lambda *a: None, 'xy:build-text-meta-list': lambda v: None,
            'xy:get-vrecs-for-hline-ed': lambda ed, v: [[0.0, 'up', [0.0, cad.ents[ed[0][1]]['hinfo'][2] + cad.ents[ed[0][1]]['lead'], 0.0], 'v']],
            'xyg:sort-lines-desc': lambda lines: lines, 'aa:link-clock': lambda: 0.0, 'bh:text-index': lambda ss: None,
            'xy:hline-info-ed': lambda ed: cad.ents[ed[0][1]]['hinfo'],
            'bh:line-texts': line_texts,
            'jm:line-principles': line_prins,
            'jm:set-text': set_text, 'hddl:color': color,
            'bh:clear-markers': lambda h: None,
            'bh:make-marker': lambda h, t: cad.markers.append((h[2], t)),
            'getstring': getstring, 'getkword': getkword, 'initget': lambda *a: None,
            'ssadd': ssadd, 'sssetfirst': sssetfirst, 'sslength': lambda ss: len(ss or []), 'redraw': lambda *a: None,
            'findfile': lambda p: p if p in cad.files else None,
            'aa:link-open': lopen, 'read-line': read_line, 'write-line': write_line, 'close': close,
        })

    def run(self, cmd='c:bh2'):
        call(cmd, [], GLOBAL)

    def dest(self, ln):
        return self.ents[ln + '_dest']['text']

    def num(self, ln):
        return self.ents[self.ents[ln]['num_en']]['text']

    def color(self, ln):
        return self.ents[self.ents[ln]['num_en']]['color']


# 顶层全局（*bh-record-name* 等）
for f in FORMS:
    if isinstance(f, list) and f[:1] == ['setq'] and str(f[1]).startswith('*bh-'):
        evaluate(f, GLOBAL)
assert GLOBAL.get('*bh-record-name*') == '电缆编号记录.txt'
PATH = 'D:\\proj\\电缆编号记录.txt'
FILES = {}

# ---- 场景 1：1号主变保护柜首次编号
c = Cad(FILES)
c.add_line('a1', 50, '主变测控柜1', '未编号', ['101', '103'])
c.add_line('a2', 45, '主变测控柜1', '未编号', ['105', '107'])
c.add_line('a3', 40, '主变及110kV故障录波柜', '未编号', ['501', '-503'])
c.add_line('a4', 35, '公用测控柜', '未编号', ['701', '-901'])
c.add_line('a5', 30, '公用测控柜', '未编号', ['+KM', '-KM'])
c.add_line('a6', 25, '10kV 分段开关柜', '未编号', ['A4253'])
c.add_line('a7', 20, '直流馈线柜', '1B-120', ['+KM1', '-KM1'])
c.add_line('a8', 15, '主变测控柜2', '未编号', ['133'], miss=1)
c.install('1号主变保护柜')
c.run()
got = {ln: c.num(ln) for ln in c.lines}
assert got == {'a1': '未编号', 'a2': '未编号', 'a3': '未编号', 'a4': '未编号',
               'a5': '未编号', 'a6': '未编号', 'a7': '1B-120', 'a8': '未编号'}, got   # BH2 不分配新编号
assert c.selected == ['a8_num'] and c.markers == [(15, '[无法编号] 有 1 根芯线未找到原理号')], (c.selected, c.markers)
assert not any('专用号' in p or '前面的部分' in p for p in c.prompts), c.prompts            # 不问前缀和起始号
assert any('未编号且没有记录 6 根' in o and '已编号新记入 1 根' in o for o in c.out), c.out
rec = FILES[PATH]
assert rec[0].startswith('电缆编号\t') and len(rec) == 1 + 1, rec
assert '1B-120\t1号主变保护柜\t直流馈线柜\t+KM1 -KM1\ta.dwg\t2026-10-24 15:00:00\t' in rec, rec
print('PASS: 场景1 BH2 只记录已编号的电缆，未编号且无记录的不动、无法识别的标出')
# 预置 BH1 给这个柜编出来的记录，供后续场景使用
FILES[PATH] += ['1B-101A\t1号主变保护柜\t主变测控柜1\t101 103\ta.dwg\tt\t',
                '1B-101B\t1号主变保护柜\t主变测控柜1\t105 107\ta.dwg\tt\t',
                '1B-130\t1号主变保护柜\t主变及110kV故障录波柜\t-503 501\ta.dwg\tt\t',
                '1B-131\t1号主变保护柜\t公用测控柜\t-901 701\ta.dwg\tt\t',
                '1B-102\t1号主变保护柜\t公用测控柜\t+KM -KM\ta.dwg\tt\t',
                '1B-103\t1号主变保护柜\t10kV 分段开关柜\tA4253\ta.dwg\tt\t']

# ---- 场景 2：对端 主变测控柜1
c = Cad(FILES)
c.add_line('b1', 50, '1号主变保护柜', '未编号', ['103', '101'])        # 按记录填 1B-101A
c.add_line('b2', 45, '1号 主变保护柜', '1B-101C', ['107', '105'])     # 记录是 1B-101B → 冲突
c.add_line('b3', 40, '直流馈线柜', '1B-101A', ['+KM9'])               # 编号已被另一根占用 → 冲突
c.add_line('b4', 35, '柜X', '未编号', ['133'])
c.add_line('b5', 30, '柜Y', '未编号', ['135'])
c.add_line('b6', 25, '柜Z', '未编号', ['137'])
c.install('主变测控柜1')
c.ents['b3_num']['color'] = 7
c.run()
got = {ln: c.num(ln) for ln in c.lines}
assert got == {'b1': '1B-101A', 'b2': '1B-101C', 'b3': '1B-101A',
               'b4': '未编号', 'b5': '未编号', 'b6': '未编号'}, got
assert c.color('b2') == 1 and c.color('b3') == 1 and c.color('b1') == 7
assert sorted(c.selected) == ['b2_num', 'b3_num'], c.selected
assert any('与另一端记录编号 1B-101B 不一致' in t for _, t in c.markers), c.markers
assert any('编号已被另一根电缆使用' in t for _, t in c.markers), c.markers
assert c.prompts == [] and any('未编号且没有记录 3 根' in o for o in c.out), (c.prompts, c.out)
assert len(FILES[PATH]) == 1 + 7, FILES[PATH]
print('PASS: 场景2 BH2 对端按记录填号、冲突标红、无记录的未编号不动')

# ---- 场景 2 再跑一次：冲突修正后恢复颜色，不再新增记录
c2_files_before = list(FILES[PATH])
c = Cad(FILES)
c.add_line('b2', 45, '1号主变保护柜', '1B-101B', ['107', '105'])
c.install('主变测控柜1')
c.ents['b2_num']['color'] = 1
c.run()
assert c.color('b2') == 7 and c.selected == [] and FILES[PATH] == c2_files_before
print('PASS: 场景2b 改正后恢复白色、记录不变')

# ---- 场景 3：两位数起始号
FILES3 = {}
c = Cad(FILES3)
c.add_line('d1', 50, '甲柜', '未编号', ['101'])
c.add_line('d2', 45, '乙柜', '未编号', ['101'])
c.add_line('d3', 40, '乙柜', '未编号', ['103'])
c.add_line('d4', 35, None, '其他文字', [])          # 绿色直线但没有“至…”：静默跳过
c.install('丙柜')
c.run()
assert [c.num(l) for l in c.lines] == ['未编号', '未编号', '未编号', '其他文字'], [c.num(l) for l in c.lines]
assert c.markers == [] and c.selected == [] and c.color('d4') == 7, (c.markers, c.selected)
assert any('跳过没有“至…”去向文字的绿色直线 1 根' in o for o in c.out), c.out
assert any('无法识别 0 根' in o and '未编号且没有记录 3 根' in o for o in c.out), c.out
print('PASS: 场景3 BH2 没有“至…”的绿色直线静默跳过')

# ---- 场景 4：记录写不进去时不改图
c = Cad({})
c.add_line('e1', 50, '甲柜', '1B-777', ['101'])
c.install('丙柜')
c.write_fail = True
c.run()
assert c.num('e1') == '1B-777' and c.alerts and c.files == {}, (c.num('e1'), c.alerts)
print('PASS: 场景4 记录写入失败不改图')
# ---- 场景 5：BHG 以图为准改记录，另一端 BH2 自动跟改
def rec_of(files, num):
    return [l.split('\t') for l in files[PATH][1:] if l.split('\t')[0] == num]


c = Cad(FILES)
c.add_line('b2', 45, '1号主变保护柜', '1B-101C', ['107', '105'])   # 以图为准：正确的是 1B-101C
c.add_line('b4', 35, '柜X', '未编号', ['133'])                      # 未编号 → 删除记录
c.add_line('b5', 30, '柜Y', '1B-101A', ['135'])                     # 编号属于选择外的另一根 → 以本次选择为准，删原记录、改给这根
c.install('主变测控柜1')
c.ents['b2_num']['color'] = 1
c.run('c:bhg')
assert rec_of(FILES, '1B-101C') and rec_of(FILES, '1B-101C')[0][6] == '1B-101B', FILES[PATH]
assert not rec_of(FILES, '1B-101B'), FILES[PATH]
assert c.color('b2') == 7 and c.color('b5') == 7 and c.selected == ['b5_num'] and c.markers == [], (c.color('b2'), c.selected, c.markers)
r = rec_of(FILES, '1B-101A')
assert len(r) == 1 and sorted(r[0][1:3]) == ['主变测控柜1', '柜Y'] and r[0][3] == '135', FILES[PATH]
assert any('原属 1号主变保护柜—主变测控柜1 的记录已删除' in o for o in c.out), c.out
assert any('编号从别的电缆改过来 1 根' in o and '编号冲突 0 根' in o for o in c.out), c.out
assert all(len(l.split('\t')) == 7 for l in FILES[PATH]), FILES[PATH]
print('PASS: 场景5 BHG 改记录、存旧编号、删记录、以本次选择为准占用选择外电缆的编号')

before = list(FILES[PATH])
c = Cad(FILES)
c.add_line('a2', 45, '主变测控柜1', '1B-101B', ['105', '107'])     # 另一端仍是旧编号
c.add_line('a9', 40, '主变测控柜1', '1B-101Z', ['109'])            # 无记录的新编号照常记入
c.install('1号主变保护柜')
c.ents['a2_num']['color'] = 1
c.run()
assert c.num('a2') == '1B-101C' and c.color('a2') == 7 and c.selected == [], (c.num('a2'), c.selected)
assert any('旧编号改为新编号 1 根' in o for o in c.out), c.out
assert FILES[PATH][:len(before)] == before and len(FILES[PATH]) == len(before) + 1
print('PASS: 场景6 另一端 BH2 把旧编号自动改为新编号')

# ---- 场景 7：旧版 6 列记录文件可直接读写；再改一次时旧编号累积
OLD = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间', 'X-01\t甲柜\t乙柜\t101\tb.dwg\t2026-10-24 15:02:57']}
for num, prev_olds in (('X-02', 'X-01'), ('X-03', 'X-01 X-02')):
    c = Cad(OLD)
    c.add_line('f1', 50, '乙柜', num, ['101'])
    c.install('甲柜')
    c.run('c:bhg')
    assert OLD[PATH][0].endswith('\t旧编号') and rec_of(OLD, num)[0][6] == prev_olds, OLD[PATH]
c = Cad(OLD)
c.add_line('f2', 50, '甲柜', '未编号', ['102'])
c.add_line('f3', 45, '甲柜', '未编号', ['103'])
c.install('乙柜')
c.run()
assert [c.num('f2'), c.num('f3')] == ['未编号', '未编号'], [c.num('f2'), c.num('f3')]
print('PASS: 场景7 旧版 6 列文件、旧编号累积；BH2 不分配')
# ---- 场景 8：图上改了终点柜名（相邻屏柜 → 公用测控柜），BHG 按同一根电缆更正记录
GW = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间',
             'SML-20\tI区通信网关机柜\t相邻屏柜\tL1 N1\tg.dwg\t2026-10-24 15:02:57',
             'SML-21\tI区通信网关机柜\t保护信息子站柜\tL1 N1\tg.dwg\t2026-10-24 15:06:00',
             'DS-06\tI区通信网关机柜\t同步时钟主机柜\tB+ B-\tg.dwg\t2026-10-24 15:02:57']}
c = Cad(GW)
c.add_line('g1', 50, '公用测控柜', 'SML-20', ['L1', 'N1'])        # 只改了终点柜名
c.add_line('g2', 45, '公用测控柜2', 'DS-06', ['L2', 'N2'])        # 终点和原理号都变了 → 另一根电缆，按本次选择改给这根
c.install('I区通信网关机柜')
c.ents['g1_num']['color'] = 1
c.run('c:bhg')
assert rec_of(GW, 'SML-20') and rec_of(GW, 'SML-20')[0][2] == '公用测控柜' and rec_of(GW, 'SML-20')[0][6] == '', GW[PATH]
assert len(rec_of(GW, 'SML-20')) == 1 and rec_of(GW, 'SML-21') and len(rec_of(GW, 'DS-06')) == 1     and sorted(rec_of(GW, 'DS-06')[0][1:3]) == ['I区通信网关机柜', '公用测控柜2'], GW[PATH]
assert c.color('g1') == 7 and c.selected == ['g2_num'], (c.color('g1'), c.selected)
assert any('按图更正柜名/原理号 1 根' in o for o in c.out), c.out
c = Cad(GW)                                                        # 另一端：公用测控柜填入 SML-20
c.add_line('h1', 50, 'I区通信网关机柜', '未编号', ['N1', 'L1'])
c.install('公用测控柜')
c.run()
assert c.num('h1') == 'SML-20', c.num('h1')
print('PASS: 场景8 改了终点柜名的同一根电缆由 BHG 更正记录，另一端随后按记录填号')

# ---- 场景 8b：起点柜改名（有功智能控制柜 → 智能有功控制装置柜），记录在对端登记
YG = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
             'SML-25\t电能质量监测柜\t有功智能控制柜\tL1 N1\tz.dwg\t2026-10-24 15:29:36\t',
             'DS-08\t电能质量监测柜\t同步时钟主机柜\tB+ B-\tz.dwg\t2026-10-24 15:29:36\t']}
c = Cad(YG)
c.add_line('y1', 50, '电能质量监测柜', 'SML-25', ['L1', 'N1'])
c.add_line('y2', 45, '同步时钟主机柜', 'DS-08', ['L2', 'N2'])    # 起点柜和原理号都不同 → 另一根电缆，按本次选择改给这根
c.install('智能有功控制装置柜')
c.ents['y1_num']['color'] = 1
c.run('c:bhg')
r = rec_of(YG, 'SML-25')
assert len(r) == 1 and sorted(r[0][1:3]) == sorted(['智能有功控制装置柜', '电能质量监测柜']), YG[PATH]
assert c.color('y1') == 7 and c.selected == ['y2_num'] and len(rec_of(YG, 'DS-08')) == 1     and sorted(rec_of(YG, 'DS-08')[0][1:3]) == ['同步时钟主机柜', '智能有功控制装置柜'], (c.selected, YG[PATH])
print('PASS: 场景8b 起点柜改名的同一根电缆由 BHG 更正记录；两样都变的按本次选择改给新电缆')
# ---- 场景 9：提速后的文字索引顺扫 / 旧标记清理，与原逐线窗口查询结果逐一对照（执行真实 LISP 源码）
import random

for name in ('bh:line-texts', 'bh:clear-markers', 'bh:text-index'):
    NATIVE.pop(name, None)


def band(x, y, h):
    return h[0] - 0.1 <= x <= h[1] + 2.0 and h[2] < y < h[2] + 3.0


def complete(idx, ents):
    # 与 bh:texts-complete-p 相同：最左边的“至…”及其左侧 40 以内有文字
    rows = sorted((dict(ents[en])[10][0], dict(ents[en])[1]) for en in idx)
    dest = next((r for r in rows if r[1].startswith('至') and len(r[1]) > 1), None)
    return bool(dest) and any(r[0] < dest[0] and dest[0] - r[0] <= 40.0 for r in rows)


rng = random.Random(20261024)
for scene in range(40):
    ents, sel, lines = {}, [], []
    for i in range(rng.randint(5, 25)):                       # 电缆线，Y 有重复
        y = round(rng.uniform(0, 200) / 2.5) * 2.5
        x0 = rng.uniform(0, 50)
        lines.append([x0, x0 + rng.uniform(60, 150), y, None])
    for i in range(rng.randint(20, 120)):                     # 文字：贴近某根线或随机
        h = rng.choice(lines)
        if rng.random() < 0.7:
            x, y = rng.uniform(h[0] - 1, h[1] + 3), h[2] + rng.choice([0.1, 0.5, 1.0, 2.99, 3.0, -0.2, rng.uniform(-1, 4)])
        else:
            x, y = rng.uniform(-10, 210), rng.uniform(-5, 210)
        en = f't{scene}_{i}'
        txt = rng.choice(['至甲柜', '未编号', '4×1.5', '1B-101', '至乙柜'])
        layer = 'BH_MARK' if rng.random() < 0.1 else '电缆-文字'
        ents[en] = [(0, rng.choice(['TEXT', 'MTEXT'])), (8, layer), (10, [x, y, 0.0]), (1, txt)]
        if rng.random() < 0.9:
            sel.append(en)                                    # 少数文字没框进选择集
    marks = {}
    for i in range(rng.randint(0, 15)):                       # 旧原因文字
        h = rng.choice(lines)
        en = f'm{scene}_{i}'
        marks[en] = [(0, 'TEXT'), (8, 'BH_MARK'), (10, [h[1] + rng.choice([1.0, 2.0, 4.0, 4.5]), h[2] + rng.choice([0.5, 0.1, 3.0]), 0.0])]
    ents.update(marks)
    deleted = []

    def window(mode, p1, p2, flt, ents=ents):
        out = []
        if mode == '_X' and not any(isinstance(x, tuple) and x == (8, 'BH_MARK') for x in flt):
            # bh:query 的全图补查：按过滤里的矩形筛插入点，排除 BH_MARK
            bx = [x for x in flt if isinstance(x, list) and x and x[0] == 10]
            bx = [(bx[i][1], bx[i][2], bx[i + 1][1], bx[i + 1][2]) for i in range(0, len(bx), 2)]
            for en, ed in ents.items():
                d = dict(ed)
                if d[0] in ('TEXT', 'MTEXT') and d[8] != 'BH_MARK' and \
                        any(b[0] <= d[10][0] <= b[2] and b[1] <= d[10][1] <= b[3] for b in bx):
                    out.append(en)
            return out or None
        for en, ed in ents.items():
            d = dict(ed)
            if mode == '_C':                                   # 视图内交叉查询：按文字外框（宽 10、高 3）相交判断
                x, y = d[10][0], d[10][1]
                if not (x <= p2[0] and x + 10 >= p1[0] and y <= p2[1] and y + 3 >= p1[1]):
                    continue
            if d[0] not in (('TEXT',) if mode == '_X' else ('TEXT', 'MTEXT')) or (mode == '_X') != (d[8] == 'BH_MARK'):
                continue
            out.append(en)
        return out or None

    NATIVE.update({
        'ssget': lambda mode, *a: window(mode, a[0] if a else None, a[1] if len(a) > 1 else None, a[-1] if a else None),
        'getvar': lambda v: {'WORLDUCS': 0}[v],
        'trans': lambda p, a, b: p,
        'entget': lambda en: ents[en],
        'ssname': lambda ss, i: ss[i], 'sslength': lambda ss: len(ss or []),
        'xy:ss->list': lambda ss: list(ss or []),
        'aa:ysdl-get-plain-text': lambda ed: dict(ed)[1],
        'entdel': lambda en: deleted.append(en),
    })
    env = Env(GLOBAL, ['*bh-tail*'])
    env.vars['*bh-tail*'] = call('bh:text-index', [sel], env)
    for h in sorted(lines, key=lambda h: -h[2]):              # bh:prepare 从上到下调用
        got = [r[1] for r in call('bh:line-texts', [h], env) or []]
        idx = [en for en in sel if dict(ents[en])[8] != 'BH_MARK' and band(*dict(ents[en])[10][:2], h)]
        if not complete(idx, ents):                            # 选择集里没能同时找到“至…”和它左边的编号时补查
            idx = [en for en, ed in ents.items() if dict(ed)[0] in ('TEXT', 'MTEXT')
                   and dict(ed)[8] != 'BH_MARK' and band(*dict(ed)[10][:2], h)]
        want = [en for en in sorted(idx, key=lambda en: dict(ents[en])[10][0])]
        assert sorted(got) == sorted(want), (scene, h, got, want)
        xs = [dict(ents[en])[10][0] for en in got]
        assert xs == sorted(xs), (scene, xs)
    call('bh:clear-markers', [lines], env)
    want = [en for en, ed in ents.items() if dict(ed)[0] == 'TEXT' and dict(ed)[8] == 'BH_MARK'
            and
            any(h[1] + 1.0 <= dict(ed)[10][0] <= h[1] + 4.0 and h[2] < dict(ed)[10][1] < h[2] + 3.0 for h in lines)]
    assert sorted(deleted) == sorted(want) and len(deleted) == len(set(deleted)), (scene, deleted, want)
# 用户实例：只点选了“至相邻屏柜”，没选中左边的“未编号” → 补查后两者都在
ents = {'n1': [(0, 'TEXT'), (8, '电缆-文字'), (10, [5641.7868, -1488.0382, 0.0]), (1, '未编号')],
        'd1': [(0, 'TEXT'), (8, '电缆-文字'), (10, [5663.2868, -1488.0382, 0.0]), (1, '至相邻屏柜')],
        's1': [(0, 'TEXT'), (8, '电缆-文字'), (10, [5693.7868, -1488.0382, 0.0]), (1, '2×4')]}
NATIVE['entget'] = lambda en: ents[en]
NATIVE['ssget'] = lambda mode, *a: ['n1', 'd1', 's1'] if mode == '_X' else None
env = Env(GLOBAL, ['*bh-tail*'])
env.vars['*bh-tail*'] = call('bh:text-index', [['d1']], env)
got = [r[1] for r in call('bh:line-texts', [[5482.2868, 5701.7868, -1488.5382, None]], env)]
assert got == ['n1', 'd1', 's1'], got
print('PASS: 场景9 文字索引顺扫与旧标记清理，40 个随机场景与逐线查询结果一致；只选中“至…”时补查到编号')
# ---- 场景 10：BH1 逐根点选（真实 c:BH1 源码；线的识别结果由桩提供，同前面场景）
def bh2_cad(files, start_name):
    c = Cad(files)
    c.picks = []
    c.made = []
    c.batches = []
    c.view_restored = 0

    def entsel(prompt):
        c.prompts.append(prompt)
        v = c.picks.pop(0)
        return v if v in (None, 'U') else [v, [0.0, 0.0, 0.0]]

    def analyze_one(en, start):
        e = c.ents[en]
        h = e['hinfo']
        texts = [[60.0, e['num_en'], c.ents[e['num_en']]['text']]]
        if e['dest'] is not None:
            texts.append([81.5, en + '_dest', '至' + e['dest']])
        return call('bh:analyze', [[['_line', en]], h, start, texts, None, None], GLOBAL)

    def marker(h, t):
        c.markers.append((h[2], t))
        c.made.append('mk%d' % len(c.made))
        return c.made[-1]

    c.install(start_name)
    c.ents['start']['height'] = 100.0
    NATIVE.update({
        'entsel': entsel, 'setvar': lambda *a: None,
        'getvar': lambda v: {'DWGTITLED': 1, 'DWGPREFIX': 'D:\\proj\\', 'DWGNAME': 'a.dwg', 'ERRNO': 0, 'WORLDUCS': 0,
                             'DATE': 2461000.5, 'TEMPPREFIX': 'C:\\T\\'}[v],
        'xy:is-green-hline-p': lambda en: True,
        'bh:analyze-one': analyze_one,
        'bh:analyze-picked': lambda lines, start: (c.batches.append(list(lines)), [analyze_one(en, start) for en in lines])[1],
        'bh:view-save': lambda: 'view',
        'bh:view-restore': lambda v: setattr(c, 'view_restored', c.view_restored + 1),
        'bh:mark-list': lambda: None,
        'bh:make-marker': marker,
        'entdel': lambda en: c.made.remove(en) if en in c.made else c.made.append(en),
    })
    return c


_ed_orig = Cad.ed


def _ed(self, en):
    e = self.ents[en]
    if 'hinfo' in e:
        return [['_line', en]]
    return [(0, 'TEXT'), (1, e['text']), (62, e['color']), (40, e.get('height', 3.0))]


Cad.ed = _ed

F10 = {}
c = bh2_cad(F10, '1号主变保护柜')
c.add_line('p1', 90, '柜甲', '未编号', ['101'])
c.add_line('p2', 85, '柜乙', '未编号', ['103'])
c.add_line('p3', 80, '柜甲', '未编号', ['105'])
c.add_line('p4', 75, '柜甲', '未编号', ['107'])
c.add_line('p5', 70, '35kV故障录波柜', '未编号', ['501', '-503'])
c.add_line('p6', 65, '35kV故障录波柜', '未编号', ['501', '-505'])
c.add_line('p7', 60, '柜丙', '未编号', ['109'])
c.add_line('p8', 55, None, '其他', [])
c.answers = ['1B', '101', '', '']
# 第一批：p1..p6，中途点错 p7 再撤掉、重复点 p2 被拒；回车编号 → 回车继续
# 第二批：p7、p1（上一批已编，只核对）、p8（不是电缆）；回车编号 → 回车继续；空批回车结束
c.picks = ['start', 'p1', 'p2', 'p7', 'U', 'p2', 'p3', 'p4', 'p5', 'p6', None,
           'p7', 'p1', 'p8', None, None]
c.run('c:bh1')
got = {l: c.num(l) for l in c.lines}
assert got == {'p1': '1B-101A', 'p2': '1B-102', 'p3': '1B-101B', 'p4': '1B-101C',
               'p5': '1B-130A', 'p6': '1B-130B', 'p7': '1B-103', 'p8': '其他'}, got
nums = sorted(l.split('\t')[0] for l in F10[PATH][1:])
assert nums == ['1B-101A', '1B-101B', '1B-101C', '1B-102', '1B-103', '1B-130A', '1B-130B'], nums
assert c.batches == [['p1', 'p2', 'p3', 'p4', 'p5', 'p6'], ['p7', 'p1', 'p8']], c.batches   # 按点选顺序
assert any('已经选过' in o for o in c.out) and any('已去掉最后一根' in o for o in c.out), c.out
assert any('第 3 根' in o and '不是电缆' in o for o in c.out) and any('本次共编 7 根' in o for o in c.out), c.out
assert c.view_restored == 2, c.view_restored
c10_out = c.out
c = bh2_cad(OLD, '乙柜')
c.add_line('f2', 50, '甲柜', '未编号', ['102'])
c.add_line('f3', 45, '甲柜', '未编号', ['103'])
c.answers = ['X', '01', '', '']                                # 沿用已有记录；本批回车继续
c.picks = ['start', 'f2', 'f3', None, None]
c.run('c:bh1')
assert [c.num('f2'), c.num('f3')] == ['X-04A', 'X-04B'], [c.num('f2'), c.num('f3')]   # 01 现行、02/03 旧编号都算已用
print('PASS: 场景10b BH1 两位数起始号；记录里的旧编号不再分配')
c.out = c10_out
print('PASS: 场景10 BH1 先点选后编号：按点选顺序、同终点第一根改 A、录波 130A/130B、点选撤销与去重、跳过非电缆、恢复视图')

# ---- 场景 11：130 跳过、131 照常；按记录填号；冲突标红；撤销整批（图面和记录一起恢复）
before = list(F10[PATH])
c = bh2_cad(F10, '柜甲')
c.add_line('q1', 90, '1号主变保护柜', '未编号', ['105'])          # 记录里是 1B-101B → 直接填
c.add_line('q2', 85, '柜X', '未编号', ['201'])
c.add_line('q3', 80, '柜Y', '未编号', ['203'])
c.add_line('q4', 75, '柜Z', '未编号', ['205'])
c.add_line('q5', 70, '1号主变保护柜', '1B-999', ['107'])          # 记录是 1B-101C → 冲突标红
c.answers = ['2B', '129', 'S', 'U', 'U', '']
c.picks = ['start', 'q1', 'q2', 'q3', 'q4', 'q5', None, 'q5', None, None]
c.run('c:bh1')
got = {l: c.num(l) for l in c.lines}
assert got == {'q1': '未编号', 'q2': '未编号', 'q3': '未编号', 'q4': '未编号', 'q5': '1B-999'}, got
assert c.color('q5') == 1 and len(c.made) == 1, (c.color('q5'), c.made)   # 撤销后第二批重新标红：仍只有一个标记
assert F10[PATH] == before, F10[PATH]
assert sum('专用号' in p for p in c.prompts) == 2, c.prompts
assert any('已撤销本批' in o and '2B-129' in o for o in c.out), c.out
print('PASS: 场景11 BH1 130/131 询问、按记录填号、冲突标红、撤销整批恢复图面与记录')

# ---- 场景 12：起点柜字高不足要求重选；撤销整批恢复冲突标记
c = bh2_cad({}, '柜甲')
c.text('small', '柜甲')
c.add_line('r1', 90, '柜乙', '1B-555', ['101'])
c.answers = ['DS', '01', 'U']
c.files[PATH] = ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号', '1B-444\t柜甲\t柜乙\t101\tz.dwg\tt\t']
c.picks = ['small', 'start', 'r1', None, None]
c.run('c:bh1')
assert c.color('r1') == 7 and c.made == [] and any('小于 80' in o for o in c.out), (c.color('r1'), c.made)
print('PASS: 场景12 BH1 撤销冲突标记、起点柜字高检查')

# ---- 场景 13：BH1 重新编号（本柜本前缀的旧记录清掉重编，旧号记为旧编号，另一端自动跟改）
F13 = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
              '2PMU-119\t宽频采集柜\t1#风机柜\t101\tz.dwg\tt\t',
              '2PMU-120\t宽频采集柜\t2#风机柜\t103\tz.dwg\tt\t',
              '2PMU-121\t宽频采集柜\t3#风机柜\t105\tz.dwg\tt\t',
              'SML-11\t录波柜\t宽频采集柜\tL1 N1\tz.dwg\tt\t',
              '2PMU-131\t公用测控柜\t宽频采集柜\t701 901\tz.dwg\tt\t']}
c = bh2_cad(F13, '宽频采集柜')
c.add_line('s1', 90, '1#风机柜', '未编号', ['101'])
c.add_line('s2', 85, '2#风机柜', '2PMU-120', ['103'])          # 图上还是旧号，也重新编
c.add_line('s3', 80, '录波柜', '未编号', ['L1', 'N1'])         # 别的柜登记的号不受影响：按记录填 SML-11
c.answers = ['2PMU', '101', 'R', '']
c.picks = ['start', 's1', 's2', 's3', None, None]
c.run('c:bh1')
got = {l: c.num(l) for l in c.lines}
assert got == {'s1': '2PMU-101', 's2': '2PMU-102', 's3': 'SML-11'}, got
assert rec_of(F13, '2PMU-101')[0][6] == '2PMU-119' and rec_of(F13, '2PMU-102')[0][6] == '2PMU-120', F13[PATH]
assert not rec_of(F13, '2PMU-121') and not rec_of(F13, '2PMU-131') and rec_of(F13, 'SML-11'), F13[PATH]   # 本柜本前缀的都清掉
assert any('识别' in o and '编号' in o and '秒' in o for o in c.out), c.out
c = bh2_cad(F13, '1#风机柜')                                  # 另一端还写着旧号 2PMU-119 → 自动改为 2PMU-101
c.add_line('t1', 90, '宽频采集柜', '2PMU-119', ['101'])
c.answers = ['X', '01', '']
c.picks = ['start', 't1', None, None]
c.run('c:bh1')
assert c.num('t1') == '2PMU-101', c.num('t1')
c = bh2_cad(F13, '宽频采集柜')                                 # 选“沿用”：记录不动，按记录填号
c.add_line('s4', 90, '2#风机柜', '未编号', ['103'])
c.answers = ['2PMU', '101', '', '']
c.picks = ['start', 's4', None, None]
c.run('c:bh1')
assert c.num('s4') == '2PMU-102', c.num('s4')
print('PASS: 场景13 BH1 重新编号：清本柜本前缀记录、旧号转旧编号、别柜编号不动、另一端自动跟改、沿用不动')
Cad.ed = _ed_orig
# ---- 场景 14：bh:x-texts 一次全图查询的分类（真实源码；ssget "_X" 桩按过滤里的矩形和类型/图层实际筛选）
import random


def _boxes(flt):
    pts = [x for x in flt if isinstance(x, list) and x and x[0] == 10]
    return [(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]) for i in range(0, len(pts), 2)]


GLOBAL.vars['*xy-ray-len*'] = 20.0                         # 与源码 (setq *xy-ray-len* 20.0) 一致
rng = random.Random(14)
for scene in range(30):
    ents = {}
    hinfo = [0.0, rng.uniform(80, 150), 100.0, None]
    vrecs = []
    for i in range(rng.randint(1, 6)):
        ax = rng.uniform(5, 75)
        side = rng.choice(['up', 'down'])
        ay = 100.0 + (10.0 if side == 'up' else -10.0) + rng.choice([0, 5, 10])
        vrecs.append([ax, side, [ax, ay, 0.0], 'v%d' % i])
    for i in range(rng.randint(30, 120)):
        if rng.random() < 0.4:
            v = rng.choice(vrecs)
            x, y = v[2][0] + rng.uniform(-8, 8), v[2][1] + rng.uniform(-45, 45)
        elif rng.random() < 0.5:
            x, y = rng.uniform(-5, hinfo[1] + 6), 100.0 + rng.uniform(-1, 4)
        else:
            x, y = rng.uniform(-50, 250), rng.uniform(0, 200)
        lay = 'BH_MARK' if rng.random() < 0.15 else '电缆-文字'
        ents['e%d' % i] = [(0, rng.choice(['TEXT', 'MTEXT'])), (8, lay), (10, [x, y, 0.0]), (1, 'x%d' % i)]

    def ssget_x(mode, flt, ents=ents):
        assert mode == '_X'
        out = []
        for en, ed in ents.items():
            d = dict(ed)
            x, y = d[10][:2]
            if d[0] in ('TEXT', 'MTEXT') and any(b[0] <= x <= b[2] and b[1] <= y <= b[3] for b in _boxes(flt)):
                out.append(en)
        return out or None

    NATIVE.update({'ssget': ssget_x, 'entget': lambda en: ents[en], 'xy:ss->list': lambda ss: list(ss or []),
                   'aa:ysdl-get-plain-text': lambda ed: dict(ed)[1], 'abs': abs})
    vr = [[v[0], 'up' if v[1] == 'up' else 'down', v[2], v[3]] for v in vrecs]
    lines, prins, marks = call('bh:x-texts', [hinfo, vr], GLOBAL)
    D = {en: dict(ed) for en, ed in ents.items()}
    want_lines = sorted([en for en, d in D.items() if d[8] != 'BH_MARK' and band(d[10][0], d[10][1], hinfo)],
                        key=lambda en: D[en][10][0])
    assert [r[1] for r in lines or []] == want_lines, (scene, lines, want_lines)
    want_marks = {en for en, d in D.items() if d[8] == 'BH_MARK' and d[0] == 'TEXT'
                  and hinfo[1] + 1 <= d[10][0] <= hinfo[1] + 4 and 100 < d[10][1] < 103}
    assert set(marks or []) == want_marks, (scene, marks, want_marks)
    for en, d in D.items():                                  # 芯线正上/正下搜索区内的文字一个不漏
        for v in vrecs:
            lo, hi = (v[2][1], v[2][1] + 20) if v[1] == 'up' else (v[2][1] - 20, v[2][1])
            if d[8] != 'BH_MARK' and abs(d[10][0] - v[2][0]) <= 1.5 and lo <= d[10][1] <= hi:
                assert en in (prins or []), (scene, en)
    assert all(D[en][8] != 'BH_MARK' for en in prins or [])
print('PASS: 场景14 bh:x-texts 一次全图查询：线上文字、原理号候选、旧标记分类正确（30 个随机场景）')

# ---- 场景 15：视图内快速查询（_C）与全图查询（_X）结果一致；视图外 / 缩得太小时自动走全图
rng = random.Random(15)
VIEW = {'WORLDUCS': 1, 'VIEWTWIST': 0.0, 'VIEWCTR': [100.0, 100.0, 0.0], 'VIEWSIZE': 400.0, 'SCREENSIZE': [1000, 800]}
for scene in range(30):
    ents = {}
    hinfo = [0.0, rng.uniform(80, 150), 100.0, None]
    vrecs = []
    for i in range(rng.randint(1, 6)):
        ax = rng.uniform(5, 75)
        side = rng.choice(['up', 'down'])
        vrecs.append([ax, side, [ax, 100.0 + (10.0 if side == 'up' else -10.0), 0.0], 'v%d' % i])
    for i in range(rng.randint(30, 120)):
        v = rng.choice(vrecs)
        x, y = (v[2][0] + rng.uniform(-8, 8), v[2][1] + rng.uniform(-45, 45)) if rng.random() < 0.5 else \
               (rng.uniform(-5, hinfo[1] + 6), 100.0 + rng.uniform(-1, 4))
        lay = 'BH_MARK' if rng.random() < 0.15 else '电缆-文字'
        ents['e%d' % i] = [(0, rng.choice(['TEXT', 'MTEXT'])), (8, lay), (10, [x, y, 0.0]), (1, 'x%d' % i)]
    used = []

    def ssget_any(mode, *a, ents=ents):
        used.append(mode)
        out = []
        for en, ed in ents.items():
            d = dict(ed)
            x, y = d[10][:2]
            if d[0] not in ('TEXT', 'MTEXT'):
                continue
            if mode == '_X':
                hit = any(b[0] <= x <= b[2] and b[1] <= y <= b[3] for b in _boxes(a[0]))
            else:                                              # _C：按文字外框（宽 10、高 3）与窗口相交
                p1, p2 = a[0], a[1]
                hit = x <= p2[0] and x + 10 >= p1[0] and y <= p2[1] and y + 3 >= p1[1]
            if hit:
                out.append(en)
        return out or None

    NATIVE.update({'ssget': ssget_any, 'entget': lambda en, ents=ents: ents[en]})
    vr = [[v[0], v[1], v[2], v[3]] for v in vrecs]
    NATIVE['getvar'] = lambda k: {**VIEW, 'WORLDUCS': 0}[k]
    slow = call('bh:x-texts', [hinfo, vr], GLOBAL)
    assert set(used) == {'_X'}, used
    used.clear()
    NATIVE['getvar'] = lambda k: VIEW[k]
    fast = call('bh:x-texts', [hinfo, vr], GLOBAL)
    assert set(used) == {'_C'}, used
    assert [r[1] for r in fast[0] or []] == [r[1] for r in slow[0] or []], scene
    assert set(fast[1] or []) == set(slow[1] or []) and set(fast[2] or []) == set(slow[2] or []), scene
    used.clear()
    NATIVE['getvar'] = lambda k: {**VIEW, 'VIEWSIZE': 2000.0}[k]     # 缩得太小（每像素 2.5 单位）→ 全图
    call('bh:x-texts', [hinfo, vr], GLOBAL)
    assert set(used) == {'_X'}, used
    used.clear()
    NATIVE['getvar'] = lambda k: {**VIEW, 'VIEWCTR': [900.0, 100.0, 0.0]}[k]   # 不在视图内 → 全图
    call('bh:x-texts', [hinfo, vr], GLOBAL)
    assert set(used) == {'_X'}, used
print('PASS: 场景15 视图内快速查询与全图查询结果一致；视图外或缩得太小时自动全图查询（30 个随机场景）')
# ---- 场景 16：bh:analyze-picked 真实源码：两次缩放的范围、从上到下识别、结果按点选顺序返回
saved = {k: NATIVE.get(k) for k in ('bh:zoom-box', 'xy:collect-vlines', 'xy:build-vline-buckets',
                                    'xy:get-vrecs-for-hline-ed', 'xy:collect-texts', 'xy:build-text-meta-list',
                                    'ssget', 'trans', 'bh:line-texts', 'bh:analyze', 'entget',
                                    'xy:hline-info-ed', 'xyg:sort-lines-desc', 'bh:text-index', 'bh:analyze-picked')}
NATIVE.pop('bh:analyze-picked', None)                       # 用真实源码
L16 = {'u1': [10.0, 120.0, 50.0], 'u2': [10.0, 130.0, 80.0], 'u3': [20.0, 110.0, 65.0]}   # (xmin xmax y)
zooms, order = [], []
NATIVE.update({
    'bh:zoom-box': lambda b: zooms.append(list(b)),
    'entget': lambda en: [['_line', en]],
    'xy:hline-info-ed': lambda ed: [L16[ed[0][1]][0], L16[ed[0][1]][1], L16[ed[0][1]][2], None],
    'xy:collect-vlines': lambda lines: ['vl'], 'xy:build-vline-buckets': lambda v: None,
    'xy:get-vrecs-for-hline-ed': lambda ed, v: [[30.0, 'down', [30.0, L16[ed[0][1]][2] - 85.0, 0.0], 'v']],
    'xy:collect-texts': lambda lines, v: [], 'xy:build-text-meta-list': lambda t: [],
    'ssget': lambda *a: None, 'trans': lambda p, a, b: p,
    'xyg:sort-lines-desc': lambda lines: sorted(lines, key=lambda e: -L16[e][2]),
    'bh:line-texts': lambda h: order.append(h[2]) or [],
    'bh:analyze': lambda ed, h, start, texts, v, t: ['OK', ed[0][1]],
})
GLOBAL.vars['*xy-ray-len*'] = 20.0
res = call('bh:analyze-picked', [['u3', 'u1', 'u2'], 'X'], GLOBAL)
assert [r[1] for r in res] == ['u3', 'u1', 'u2'], res                      # 按点选顺序
assert order == [80.0, 65.0, 50.0], order                                    # 从上到下识别（bh:line-texts 顺扫要求）
assert len(zooms) == 2 and zooms[0] == [9.9, 50.0, 134.0, 83.0], zooms        # 先缩放到电缆线及其文字带
assert zooms[1][1] <= 50.0 - 85.0 - 20.0 - 30.0 and zooms[1][3] >= 83.0, zooms   # 再包含芯线远端原理号搜索区
NATIVE.update({k: v for k, v in saved.items() if v is not None})
for k, v in saved.items():
    if v is None:
        NATIVE.pop(k, None)
print('PASS: 场景16 bh:analyze-picked 两次缩放范围正确、从上到下识别、结果按点选顺序')
# ---- 场景 17：BH3 从电缆清册表格记录（真实源码，含 HDDL 分行）
T17 = {}
rows17 = [
    ['低压柜', '***', '电压转接柜', '2', '2×4', 'L1', 'N1'],
    ['电压转接柜', 'SML-01', '110kV线路保护测控柜', '2', '2×4', 'L1', 'N1'],
    ['110kV线路保护测控柜', 'SML-02', '110kV母线保护测控柜', '2', '2×4', 'L1', 'N1'],
    ['1#主变保护柜', 'SML-04', '1#主变测控柜', '2', '2×4', 'L1', 'N1'],        # 记录里已有，一致
    ['2#主变保护柜', 'SML-06', '2#主变测控柜', '2', '2×4', 'L1', 'N1'],        # 记录里同一根是 SML-60 → 强制改为 SML-06
    ['AGC服务器柜', 'SML-11', 'AVC服务器柜', '2', '2×4', 'L1', 'N1'],          # SML-11 已属于另一根 → 以清册为准，删掉原记录
    ['网络通信柜', '***', '低压柜', '2', '2×4', 'L1', 'N1'],                    # 第二根 ***：占位编号可共用
    ['网络通信柜', 'SML-15', '低压柜', '2', '2×4'],                              # 没有原理号 → 跳过
    ['电缆编号', '起点', '终点'],                                               # 表头 → 跳过
]
xs = [0.0, 36.0, 57.0, 104.0, 124.0, 160.0, 180.0]
for r, row in enumerate(rows17):
    for col, txt in enumerate(row):
        T17['t%d_%d' % (r, col)] = [(0, 'TEXT'), (1, txt), (8, '0'), (10, [xs[col] + (0.3 if col == 2 else 0.0), 100.0 - 5 * r, 0.0]), (62, 4)]
FB = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
             'SML-04\t1#主变测控柜\t1#主变保护柜\tN1 L1\tz.dwg\tt\t',
             'SML-60\t2#主变保护柜\t2#主变测控柜\tL1 N1\tz.dwg\tt\t',
             'SML-11\t宽频同步相量测量采集柜\t35kV故障录波柜\tL1 N1\tz.dwg\tt\t']}
c = Cad(FB)
c.install('x')
colors = {}
N17 = {
    'ssget': lambda *a: list(T17),
    'entget': lambda en: T17[en],
    'type': lambda v: 'list' if isinstance(v, (list, tuple)) else 'str' if isinstance(v, str) else
                      'int' if isinstance(v, int) else 'real' if isinstance(v, float) else None,
    'numberp': lambda v: truth(isinstance(v, (int, float))),
    'aa:ysdl-get-plain-text': lambda ed: dict(ed)[1],
    'hddl:color': lambda en, col: colors.__setitem__(en, col),
}
NATIVE.update(N17)
c.run('c:bh3')
nums = [l.split('\t')[0] for l in FB[PATH][1:]]
assert nums == ['SML-04', '***', 'SML-01', 'SML-02', 'SML-06', 'SML-11', '***'], nums
assert rec_of(FB, 'SML-01')[0][1:4] == ['电压转接柜', '110kV线路保护测控柜', 'L1 N1'], FB[PATH]
assert rec_of(FB, 'SML-06')[0][6] == 'SML-60' and not rec_of(FB, 'SML-60'), FB[PATH]     # 强制更新，原号存为旧编号
assert [r[1:3] for r in rec_of(FB, 'SML-11')] == [['AGC服务器柜', 'AVC服务器柜']], FB[PATH]   # 以清册为准，原记录删除
assert [r[1:3] for r in rec_of(FB, '***')] == [['低压柜', '电压转接柜'], ['网络通信柜', '低压柜']], FB[PATH]
assert colors == {} and c.selected == ['t5_1'], (colors, c.selected)
assert any('新记入 5 根' in o and '记录改为清册编号 1 根' in o and '与记录一致 1 根' in o and '编号从别的电缆改过来 1 根' in o
           and '跳过 2 行' in o for o in c.out), c.out
assert any('SML-11 原属 宽频同步相量测量采集柜—35kV故障录波柜 的记录已删除，按清册改给 AGC服务器柜—AVC服务器柜' in o for o in c.out), c.out
before17 = list(FB[PATH])
c = Cad(FB)                                                   # 再跑一次：全部一致，记录不变
c.install('x')
colors.clear()
NATIVE.update(N17)
c.run('c:bh3')
assert FB[PATH] == before17 and any('与记录一致 7 根' in o for o in c.out), (c.out, FB[PATH])
# 清册内重复：同一起终点+原理号两个编号、同一编号两根电缆、完全相同的行；上一版标红的恢复白色
T17.clear()
rows17b = [
    ['1#风机回路进线柜', 'DB-101', '2#风机回路进线柜', '2', '2×4', 'L1', 'N1'],
    ['1#风机回路进线柜', 'DB-201', '2#风机回路进线柜', '2', '2×4', 'L1', 'N1'],   # 同一起终点、原理号 → 两根都记
    ['3#风机回路进线柜', 'DB-101', '4#风机回路进线柜', '2', '2×4', 'L1', 'N1'],   # 同一编号另一根 → 两根都记
    ['1#风机回路进线柜', 'DB-101', '2#风机回路进线柜', '2', '2×4', 'L1', 'N1'],   # 与第一行完全相同 → 只记一次
]
for r, row in enumerate(rows17b):
    for col, txt in enumerate(row):
        T17['t%d_%d' % (r, col)] = [(0, 'TEXT'), (1, txt), (8, '0'), (10, [xs[col] + (0.3 if col == 2 else 0.0), 100.0 - 5 * r, 0.0]), (62, 1 if (r, col) == (0, 1) else 4)]
FC = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号']}
c = Cad(FC)
c.install('x')
colors.clear()
NATIVE.update(N17)
c.run('c:bh3')
assert [l.split('\t')[0] for l in FC[PATH][1:]] == ['DB-101', 'DB-201', 'DB-101'], FC[PATH]
assert colors == {'t0_1': 7} and sorted(c.selected) == ['t1_1', 't2_1', 't3_1'], (colors, c.selected)
assert any('两端柜名和原理号都相同，两根都已记入' in o for o in c.out) and any('在本次选择中也用于 1#风机回路进线柜—2#风机回路进线柜' in o for o in c.out) \
    and any('与本次选择中前面一行完全相同' in o for o in c.out), c.out
assert any('新记入 3 根' in o and '重复 2 根' in o for o in c.out), c.out
beforeC = list(FC[PATH])
c = Cad(FC)                                                   # 再跑一次：不重复记入
c.install('x')
NATIVE.update(N17)
c.run('c:bh3')
assert FC[PATH] == beforeC and any('新记入 0 根' in o and '与记录一致 3 根' in o for o in c.out), (c.out, FC[PATH])
# 用户实例：通讯线清册没有规格列（芯数后面直接是 B+ B-），上一版把 B+ 当规格丢掉、只记了 B-；重跑后按清册改正
T17.clear()
rows17c = [[(36534.01, '同步时钟主机柜'), (36570.78, 'DS-02'), (36591.63, '35kV1#PT柜'), (36648.76, '2'), (36673.72, 'B+'), (36688.43, 'B-')],
           [(36534.32, '35kV1#PT柜'), (36570.78, 'DS-201'), (36591.63, '35kV1#备用柜'), (36648.76, '2'), (36673.72, 'B+'), (36688.43, 'B-')]]
for r, row in enumerate(rows17c):
    for col, (x, txt) in enumerate(row):
        T17['t%d_%d' % (r, col)] = [(0, 'TEXT'), (1, txt), (8, '0'), (10, [x, 19196.96 - 5 * r, 0.0]), (62, 7)]
FD = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
             'DS-02\t同步时钟主机柜\t35kV1#PT柜\tB-\tz.dwg\tt\t',
             'DS-201\t35kV1#PT柜\t35kV1#备用柜\tB-\tz.dwg\tt\t']}
c = Cad(FD)
c.install('x')
NATIVE.update(N17)
c.run('c:bh3')
assert [l.split('\t')[:4] for l in FD[PATH][1:]] == [['DS-02', '同步时钟主机柜', '35kV1#PT柜', 'B+ B-'],
                                                    ['DS-201', '35kV1#PT柜', '35kV1#备用柜', 'B+ B-']], FD[PATH]
assert all(l.split('\t')[6] == '' for l in FD[PATH][1:]), FD[PATH]          # 编号没变，不产生旧编号
assert any('提醒：2 行没写规格' in o and 'DS-02、DS-201' in o for o in c.out) and sorted(c.selected) == ['t0_1', 't1_1'], (c.out, c.selected)
assert call('bh:spec-cell-p', ['KVVP2-22 4x1.5'], GLOBAL) and call('bh:spec-cell-p', ['2×4'], GLOBAL) \
    and not call('bh:spec-cell-p', ['B+'], GLOBAL) and not call('bh:spec-cell-p', ['TX-901'], GLOBAL)
# 用户实例：清册列为 规格 芯数（通讯线 2 B+ B-，同 HDDL）；上一版把芯数 2 当原理号记入并误报没写规格，重跑后改正
T17.clear()
rows17d = [[(36534.01, '同步时钟主机柜'), (36570.78, 'DS-01'), (36591.1, '35kV1#风机回路进线柜'), (36646.12, '通讯线'), (36669.15, '2'), (36694.12, 'B+'), (36708.83, 'B-')],
           [(36534.32, '35kV1#风机回路进线柜'), (36570.78, 'DS-101'), (36591.63, '35kV2#风机回路进线柜'), (36646.12, '通讯线'), (36669.15, '2'), (36694.12, 'B+'), (36708.83, 'B-')],
           [(36534.32, '1#柜'), (36570.78, 'DS-102'), (36591.63, '2#柜'), (36646.12, '4×2.5'), (36669.15, '4'), (36694.12, '101'), (36708.83, '103')]]
for r, row in enumerate(rows17d):
    for col, (x, txt) in enumerate(row):
        T17['t%d_%d' % (r, col)] = [(0, 'TEXT'), (1, txt), (8, '0'), (10, [x, 19216.96 - 5 * r, 0.0]), (62, 7)]
FE = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
             'DS-01\t同步时钟主机柜\t35kV1#风机回路进线柜\t2 B+ B-\tz.dwg\tt\t']}
c = Cad(FE)
c.install('x')
NATIVE.update(N17)
c.run('c:bh3')
assert [l.split('\t')[:4] for l in FE[PATH][1:]] == [['DS-01', '同步时钟主机柜', '35kV1#风机回路进线柜', 'B+ B-'],
                                                    ['DS-101', '35kV1#风机回路进线柜', '35kV2#风机回路进线柜', 'B+ B-'],
                                                    ['DS-102', '1#柜', '2#柜', '101 103']], FE[PATH]
assert not any('没写规格' in o for o in c.out) and c.selected == [], (c.out, c.selected)
assert call('bh:core-cell-p', ['2'], GLOBAL) and call('bh:core-cell-p', ['10'], GLOBAL) and not call('bh:core-cell-p', ['101'], GLOBAL)
c = Cad(FD)                                   # 端子排上两根“至相邻屏柜”的未编号通讯线：BH2 按记录定出前后柜
c.add_line('p1', 50, '相邻屏柜', '未编号', ['B+', 'B-'], lead=20.0)
c.add_line('p2', 45, '相邻屏柜', '未编号', ['B+', 'B-'], lead=25.0)
c.install('35kV 1#PT柜')
c.run('c:bh2')
assert (c.num('p1'), c.dest('p1'), c.num('p2'), c.dest('p2')) == \
       ('DS-02', '至同步时钟主机柜', 'DS-201', '至35kV1#备用柜'), (c.num('p1'), c.dest('p1'), c.num('p2'), c.dest('p2'), c.out)
# 用户实例：环网清单第一次把链头写成“交流馈线柜 JL-01/JL-04”，更正为“低压柜 ***”后重跑 BH3；
# 上一版旧记录留着，风功率预测系统柜、网络通信柜各有 3 根 L1 N1，BH2 无法确定相邻柜。重跑应询问后删掉本图的两条旧记录
T17.clear()
rows17e = [
    ['低压柜', '***', '风功率预测系统柜', '2', '2×4', 'L1', 'N1'],
    ['风功率预测系统柜', 'SML-01', '关口计量柜', '2', '2×4', 'L1', 'N1'],
    ['网络通信柜', '***', '低压柜', '2', '2×4', 'L1', 'N1'],
    ['低压柜', '未编号', '关口计量柜', '2', '2×4', 'L1', 'N1'],          # 跳过行：这根的旧记录不当作已经没有
]
for r, row in enumerate(rows17e):
    for col, txt in enumerate(row):
        T17['t%d_%d' % (r, col)] = [(0, 'TEXT'), (1, txt), (8, '0'), (10, [xs[col] + (0.3 if col == 2 else 0.0), 100.0 - 5 * r, 0.0]), (62, 4)]
RINGOLD = ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
           'JL-01\t交流馈线柜\t风功率预测系统柜\tL1 N1\ta.dwg\tt\t',           # 本图旧记录 → 删
           'SML-01\t风功率预测系统柜\t关口计量柜\tL1 N1\ta.dwg\tt\t',
           'JL-04\t网络通信柜\t交流馈线柜\tL1 N1\ta.dwg\tt\t',                 # 本图旧记录 → 删
           'DS-06\t风功率预测系统柜\t同步时钟主机柜\tB+ B-\ta.dwg\tt\t',       # 原理号不同 → 不动
           'JL-09\t低压柜\t关口计量柜\tL1 N1\ta.dwg\tt\t',               # 清册里改成未编号（跳过行）→ 不动
           'SML-90\t关口计量柜\t主变电度表柜\tL1 N1\tz.dwg\tt\t',              # 别的图登记 → 不动
           'SML-91\t风功率预测系统柜\t电压转接柜\tL1 N1\ta.dwg\tt\t',          # 本图旧记录，但别的图也登记过 → 不删，提醒
           'SML-91\t电压转接柜\t风功率预测系统柜\tN1 L1\tz.dwg\tt\t']
FR = {PATH: list(RINGOLD)}
c = Cad(FR)
c.install('x')
c.answers = [None]                                            # 回车：删除
NATIVE.update(N17)
c.run('c:bh3')
assert [l.split('\t')[0] for l in FR[PATH][1:]] == ['SML-01', 'DS-06', 'JL-09', 'SML-90', 'SML-91', 'SML-91', '***', '***'], FR[PATH]
assert any('删除这些旧记录' in p for p in c.prompts) and any('本图以前登记的 2 条记录' in o for o in c.out), (c.prompts, c.out)
assert any('JL-01 交流馈线柜—风功率预测系统柜 L1 N1，已删除' in o for o in c.out) \
    and any('SML-91 风功率预测系统柜—电压转接柜 L1 N1，但别的图纸也登记过' in o for o in c.out), c.out
assert any('删除本图以前登记、清册里已经没有的旧记录 2 根' in o for o in c.out), c.out
afterR = list(FR[PATH])
c = Cad(FR)                                                   # 再跑一次：没有可删的，不再询问，记录不变
c.install('x')
NATIVE.update(N17)
c.run('c:bh3')
assert FR[PATH] == afterR and not any('删除这些旧记录' in p for p in c.prompts), (c.prompts, FR[PATH])
FR = {PATH: list(RINGOLD)}                                    # 选“保留”：旧记录不删，结果卡片说明
c = Cad(FR)
c.install('x')
c.answers = ['K']
NATIVE.update(N17)
c.run('c:bh3')
assert [l.split('\t')[0] for l in FR[PATH][1:]][:4] == ['JL-01', 'SML-01', 'JL-04', 'DS-06'] and FR[PATH].count(RINGOLD[1]) == 1, FR[PATH]
assert any('按你的选择保留了这条记录' in o for o in c.out) and any('旧记录 0 根' in o for o in c.out), c.out
print('PASS: 场景17 BH3 以本次清册为准：新记入、强制更新存旧编号、*** 可多根共用、编号属于别的电缆时删原记录改给清册、清册内重复都记入并说明、无原理号/表头跳过、重跑不变、重跑时询问后删掉本图清册里已经没有的旧记录')
# ---- 场景 18：BH2 处理“至相邻屏柜”的环网电缆（按 BH3 登记的环网清单）
RING = ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
        '***\t低压柜\t电压转接柜\tL1 N1\tz.dwg\tt\t',
        'SML-01\t电压转接柜\t110kV线路保护测控柜\tL1 N1\tz.dwg\tt\t',
        'SML-02\t110kV线路保护测控柜\t110kV母线保护测控柜\tL1 N1\tz.dwg\tt\t']
F18 = {PATH: list(RING)}
c = Cad(F18)                                   # 向下引线：上面一根引线短 → 前一个柜
c.add_line('n1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('n2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('110kV线路保护测控柜')
c.run('c:bh2')
assert (c.num('n1'), c.dest('n1'), c.num('n2'), c.dest('n2')) == \
       ('SML-01', '至电压转接柜', 'SML-02', '至110kV母线保护测控柜'), (c.num('n1'), c.dest('n1'), c.num('n2'), c.dest('n2'))
assert F18[PATH] == RING and any('按记录改为实际柜名 2 根' in o for o in c.out), c.out
F18 = {PATH: list(RING)}
c = Cad(F18)                                   # 向上引线：下面一根引线短 → 前一个柜
c.add_line('u1', 60, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.add_line('u2', 55, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.install('110kV线路保护测控柜')
c.run('c:bh2')
assert (c.num('u1'), c.num('u2')) == ('SML-02', 'SML-01'), (c.num('u1'), c.num('u2'))
c = Cad(F18)                                   # 链尾：只有前一个柜
c.add_line('e1', 50, '相邻屏柜', '未编号', ['N1', 'L1'], lead=20.0)
c.install('110kV母线保护测控柜')
c.run('c:bh2')
assert (c.num('e1'), c.dest('e1')) == ('SML-02', '至110kV线路保护测控柜'), (c.num('e1'), c.dest('e1'))
c = Cad(F18)                                   # 只有一根但前后都有记录 → 无法确定；L2 N2 没有记录 → 无法确定
c.add_line('m1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('m2', 45, '相邻屏柜', '未编号', ['L2', 'N2'], lead=20.0)
c.install('电压转接柜')
c.run('c:bh2')
assert (c.num('m1'), c.dest('m1'), c.num('m2')) == ('未编号', '至相邻屏柜', '未编号'), (c.num('m1'), c.num('m2'))
assert sorted(c.selected) == ['m1_num', 'm2_num'], c.selected
assert any('有 2 根，只有一根无法确定' in o for o in c.out) and any('记录里没有本柜的相邻屏柜电缆' in o for o in c.out), c.out
assert any('（查记录用：柜名 电压转接柜，原理号 L1 N1，找到 *** SML-01）' in o for o in c.out) and not any('疑似' in o for o in c.out), c.out
assert F18[PATH] == RING
F18 = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
              '***\t低压柜\t风功率预测系统柜\tL1 N1\tz.dwg\tt\t',
              'SML-16\t风功率预测系统柜\t关口计量柜\tL1 N1\tz.dwg\tt\t']}
c = Cad(F18)                                   # 用户实例：柜名大字“风功率预测柜”与清单“风功率预测系统柜”对不上
c.add_line('w1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('w2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('风功率预测柜')
c.ents['w2_num']['color'] = 1                  # 上一版误判“重复”时标成了红色
c.run('c:bh2')
assert (c.num('w1'), c.num('w2'), c.color('w2')) == ('未编号', '未编号', 7), (c.num('w1'), c.num('w2'), c.color('w2'))
assert not any('重复' in o for o in c.out) and c.markers == [], (c.out, c.markers)
assert sorted(c.selected) == ['w1_num', 'w2_num'], c.selected
assert any('记录里没有本柜的相邻屏柜电缆' in o for o in c.out) and any('未编号且没有记录 0 根' in o for o in c.out), c.out
F18 = {PATH: ['电缆编号	柜名1	柜名2	原理号	图纸	时间	旧编号',
              'SML-21	I区通信网关机柜	保护信息子站柜	L1 N1	z.dwg	t	',
              'SML-22	保护信息子站柜	新能源快速调频控制柜	L1 N1	z.dwg	t	',
              'TP-131	公用测控柜	新能源快速调频控制柜	701 TP-901 TP-903	z.dwg	t	',
              'SML-23	同步时钟主机柜	新能源快速调频控制柜	L1 N1	z.dwg	t	',
              'SML-24	同步时钟主机柜	电能质量监测柜	L1 N1	z.dwg	t	']}
REC18 = list(F18[PATH])
c = Cad(F18)                                   # 用户实例：两条记录都以本柜作柜名2（各自起点柜记的），按编号顺序分前后
c.add_line('x1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('x2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('新能源快速调频控制柜')
c.run('c:bh2')
assert (c.num('x1'), c.dest('x1'), c.num('x2'), c.dest('x2')) ==        ('SML-22', '至保护信息子站柜', 'SML-23', '至同步时钟主机柜'), (c.num('x1'), c.dest('x1'), c.num('x2'), c.dest('x2'))
assert F18[PATH] == REC18 and c.selected == [], (c.selected, c.out)
c = Cad(F18)                                   # 两条记录都以本柜作柜名1，同样按编号顺序
c.add_line('y1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.add_line('y2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.install('同步时钟主机柜')
c.run('c:bh2')
assert (c.dest('y1'), c.dest('y2')) == ('至电能质量监测柜', '至新能源快速调频控制柜'), (c.dest('y1'), c.dest('y2'))
F18 = {PATH: ['电缆编号	柜名1	柜名2	原理号	图纸	时间	旧编号',
              'SML-27	安全稳定控制装置A柜	安全稳定控制装置B柜	L1 N1	z.dwg	t	',
              '***	安全稳定控制装置B柜	低压柜	L1 N1	z.dwg	t	']}
c = Cad(F18)                                   # 编号“***”不能比较时看记录方向
c.add_line('z1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('z2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('安全稳定控制装置B柜')
c.run('c:bh2')
assert (c.num('z1'), c.dest('z1'), c.num('z2'), c.dest('z2')) ==        ('SML-27', '至安全稳定控制装置A柜', '***', '至低压柜'), (c.num('z1'), c.dest('z1'), c.num('z2'), c.dest('z2'))
print('PASS: 场景18 BH2 相邻屏柜：按引线长短和编号顺序定前后柜、改为实际柜名、链尾单根、无法确定时选中提示且不误报重复')
# ---- 场景 19：原理号只差 I/II 后缀时写出疑似编号和原因，不填
F19 = {PATH: ['电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号',
              'YYH-136\t电压转接柜\t主变电度表柜\tA610I B610I C610I N600\tD0202.dwg\tt\tYYH-136B YYH-136A',
              'YYH-132A\t电压转接柜\t安全稳定控制装置A柜\tA610I B610I C610I N600\tD0202.dwg\tt\t',
              'YYH-132B\t电压转接柜\t安全稳定控制装置A柜\tA610II B610II C610II N600\tD0202.dwg\tt\t',
              'DB-131\t公用测控柜\t主变电度表柜\t701 DB-901\tD0202.dwg\tt\t']}
REC19 = list(F19[PATH])
c = Cad(F19)                                   # 用户实例：图上 A610 B610 C610 N600，记录是 A610I…
c.add_line('s1', 50, '电压转接柜', '未编号', ['N600', 'A610', 'B610', 'C610'])
c.add_line('s2', 45, '公用测控柜', '未编号', ['701', 'DB-903'])            # 原理号不同，不算疑似
c.install('主变电度表柜')
c.run('c:bh2')
assert (c.num('s1'), c.num('s2'), c.color('s1')) == ('未编号', '未编号', 7), (c.num('s1'), c.num('s2'))
assert F19[PATH] == REC19 and c.selected == ['s1_num'], (c.selected, F19[PATH])
assert c.markers == [(50, '[疑似 YYH-136] 原理号不一致，无法填入：图上 A610 B610 C610，记录 A610I B610I C610I'
                          '（D0202.dwg）；统一两张图的原理号后再运行 BH2')], c.markers
assert any('未编号且没有记录 2 根' in o and '其中 1 根有疑似记录' in o for o in c.out), c.out
c = Cad(F19)                                   # 两根都疑似（I 和 II）：都列出，不能确定是哪一根
c.add_line('t1', 50, '电压转接柜', '未编号', ['A610', 'B610', 'C610', 'N600'])
c.install('安全稳定控制装置A柜')
c.run('c:bh2')
assert c.num('t1') == '未编号' and c.selected == ['t1_num'], (c.num('t1'), c.selected)
assert c.markers[0][1].startswith('[疑似 YYH-132A YYH-132B] 原理号不一致且有 2 根疑似，无法填入：YYH-132A 图上'), c.markers
c = Cad(F19)                                   # 全角罗马数字 Ⅰ 与记录 I 只算疑似
c.add_line('w1', 50, '电压转接柜', '未编号', ['A610Ⅰ', 'B610Ⅰ', 'C610Ⅰ', 'N600'])
c.install('主变电度表柜')
c.run('c:bh2')
assert c.num('w1') == '未编号' and c.markers[0][1].startswith('[疑似 YYH-136] '), c.markers
c = Cad(F19)                                   # 原理号完全一致：照常按记录填入
c.add_line('v1', 50, '电压转接柜', '未编号', ['A610I', 'B610I', 'C610I', 'N600'])
c.install('主变电度表柜')
c.run('c:bh2')
assert c.num('v1') == 'YYH-136' and c.markers == [] and c.selected == [], (c.num('v1'), c.markers)
print('PASS: 场景19 BH2 原理号只差 I/II 后缀：写出疑似编号和原因并选中、不填不改记录；多根疑似全部列出；一致时照常填入')
# ---- 场景 20：BHG 同一次框选里两根电缆互换编号、挪用编号
SW_HEAD = '电缆编号\t柜名1\t柜名2\t原理号\t图纸\t时间\t旧编号'
SW = [SW_HEAD,
      '2PMU-145\t宽频同步相量测量采集柜\t35kV 2#SVG进线柜\t2SVG-A442 2SVG-N441\tz.dwg\tt\t',
      '2PMU-146\t宽频同步相量测量采集柜\t35kV 2#站用变进线柜\t2ZYB-A442 2ZYB-N441\tz.dwg\tt\t',
      '2PMU-147\t宽频同步相量测量采集柜\t35kV 2#主变进线柜\t2B-A4252 2B-N4251\tz.dwg\tt\t']
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 用户实例：图上 145、146 互换
c.add_line('p1', 50, '35kV 2#站用变进线柜', '2PMU-145', ['2ZYB-A442', '2ZYB-N441'])
c.add_line('p2', 45, '35kV 2#SVG进线柜', '2PMU-146', ['2SVG-A442', '2SVG-N441'])
c.install('宽频同步相量测量采集柜')
c.ents['p1_num']['color'] = 1
c.run('c:bhg')
r145, r146 = rec_of(F20, '2PMU-145'), rec_of(F20, '2PMU-146')
assert len(r145) == 1 and r145[0][2] == '35kV 2#站用变进线柜' and r145[0][6] == '2PMU-146', F20[PATH]
assert len(r146) == 1 and r146[0][2] == '35kV 2#SVG进线柜' and r146[0][6] == '2PMU-145', F20[PATH]
assert rec_of(F20, '2PMU-147') and len(F20[PATH]) == 4, F20[PATH]
assert c.selected == [] and c.markers == [] and c.color('p1') == 7, (c.selected, c.markers)
assert any('记录改为图上编号 2 根' in o and '编号冲突 0 根' in o for o in c.out), c.out
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 挪用：146 给了 SVG 电缆，站用变电缆改回“未编号”
c.add_line('q1', 50, '35kV 2#站用变进线柜', '未编号', ['2ZYB-A442', '2ZYB-N441'])
c.add_line('q2', 45, '35kV 2#SVG进线柜', '2PMU-146', ['2SVG-A442', '2SVG-N441'])
c.install('宽频同步相量测量采集柜')
c.run('c:bhg')
assert rec_of(F20, '2PMU-146')[0][2] == '35kV 2#SVG进线柜' and not rec_of(F20, '2PMU-145') and len(F20[PATH]) == 3, F20[PATH]
assert c.selected == [], c.selected
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 原主人仍是这个编号 → 都不改记录，标冲突
c.add_line('s1', 50, '35kV 2#SVG进线柜', '2PMU-146', ['2SVG-A442', '2SVG-N441'])
c.add_line('s2', 45, '35kV 2#站用变进线柜', '2PMU-146', ['2ZYB-A442', '2ZYB-N441'])
c.install('宽频同步相量测量采集柜')
c.run('c:bhg')
assert F20[PATH] == SW and sorted(c.selected) == ['s1_num', 's2_num'], (c.selected, F20[PATH])
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 用户实例：原主人的新编号属于选择外的电缆 → 以本次选择为准，连锁都改成功
c.add_line('t1', 50, '35kV 2#站用变进线柜', '2PMU-145', ['2ZYB-A442', '2ZYB-N441'])
c.add_line('t2', 45, '35kV 2#SVG进线柜', '2PMU-147', ['2SVG-A442', '2SVG-N441'])
c.install('宽频同步相量测量采集柜')
c.run('c:bhg')
assert rec_of(F20, '2PMU-145')[0][2] == '35kV 2#站用变进线柜' and rec_of(F20, '2PMU-147')[0][2] == '35kV 2#SVG进线柜', F20[PATH]
assert not any('2#主变进线柜' in l for l in F20[PATH]) and len(F20[PATH]) == 3, F20[PATH]
assert c.selected == ['t2_num'] and c.markers == [], (c.selected, c.markers)
assert any('记录改为图上编号 2 根' in o and '编号从别的电缆改过来 1 根' in o and '编号冲突 0 根' in o for o in c.out), c.out
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 用户实例：两根“至相邻屏柜”的未编号通讯线 → 未编号不核对，不报重复
c.add_line('h1', 50, '相邻屏柜', '未编号', ['B+', 'B-'])
c.add_line('h2', 45, '相邻屏柜', '未编号', ['B+', 'B-'])
c.add_line('h3', 40, '35kV 2#主变进线柜', '2PMU-147', ['2B-A4252', '2B-N4251'])
c.install('宽频同步相量测量采集柜')
c.ents['h2_num']['color'] = 1                  # 上一版误报“重复”时标成了红色
c.run('c:bhg')
assert F20[PATH] == SW and c.selected == [] and c.markers == [] and c.color('h2') == 7, (c.selected, c.markers, c.out)
assert not any('重复' in o for o in c.out) \
    and any('未编号 2 根（不核对，其中有记录的已删除 0 根）' in o and '已与记录一致 1 根' in o and '编号冲突 0 根' in o for o in c.out), c.out
F20 = {PATH: list(SW)}
c = Cad(F20)                                   # 同一根电缆两处都写“未编号”：记录只删一次，不报重复；已编号的重复仍报冲突
c.add_line('k1', 50, '35kV 2#SVG进线柜', '未编号', ['2SVG-A442', '2SVG-N441'])
c.add_line('k2', 45, '35kV 2#SVG进线柜', '未编号', ['2SVG-A442', '2SVG-N441'])
c.add_line('k3', 40, '35kV 2#主变进线柜', '2PMU-147', ['2B-A4252', '2B-N4251'])
c.add_line('k4', 35, '35kV 2#主变进线柜', '2PMU-147', ['2B-A4252', '2B-N4251'])
c.install('宽频同步相量测量采集柜')
c.run('c:bhg')
assert not rec_of(F20, '2PMU-145') and len(F20[PATH]) == 3 and c.selected == ['k4_num'], (F20[PATH], c.selected)
assert any('未编号 2 根（不核对，其中有记录的已删除 1 根）' in o and '编号冲突 1 根' in o for o in c.out), c.out
print('PASS: 场景20 BHG 同次框选互换/挪用编号：记录按图互换并存旧编号；原主人没改号时撤回并标冲突；选择外的编号按本次选择改过来（含连锁）')
# ---- 场景 21：JM 截面规则（jm:classify 也决定 BH 的专用号）与已填写截面核对
JM_CASES = [
    (['L', 'N'], '2×4'), (['+KM', '-KM'], '2×4'), (['+BM', '-BM'], '2×4'), (['+HM', '-HM'], '2×4'), (['+ZM', '-ZM'], '2×4'),
    (['B+', 'B-'], '通讯线'), (['485+', '485-'], '通讯线'), (["485+'", "485-'"], '通讯线'), (['RS485+’', 'B-′'], '通讯线'), (['A610', 'B610', 'C610', 'N600'], '4×4'), (['B411'], '4×4'),
    (['L640', 'N600'], '4×4'), (['L610', 'N600'], '4×4'), (['L601', 'L620', 'L630', 'N600'], '4×4'), (['L1', 'N1'], '2×4'),
    (['UA1', 'UB1', 'UC1', 'UN1'], '4×4'), (['UA2', 'UB2', 'UC2', 'UN2'], '4×4'), (['IA1', 'IB1', 'IC1', 'IN1'], '4×4'), (['IA2', 'IB2', 'IC2', 'IN2'], '4×4'),
    (['R133', '101'], '4×2.5'), (['1UYHD-01', '1UYHD-33', '1UYHD-03'], '4×2.5'), (['201', '233'], '4×2.5'), (['301', '333', '337'], '4×2.5'),
    (['107', '107A'], '4×1.5'), (['107A', '901'], '4×1.5'), (['501', '503B'], '4×1.5'),
    (['801', '803', '805'], '4×1.5'), (['8010', '8013', '8015'], '4×1.5'),
    (['B01', 'B03'], '4×1.5'), (['BL01', 'BL03'], '4×1.5'), (['BT01'], '4×1.5'), (['BS01', 'BS03'], '4×1.5'),
    (['BS-01', 'BS-03'], '4×1.5'), (['BS-05', 'BS-07'], '4×1.5'), (['BL-01', 'BT-03', 'B-05'], '4×1.5'),
    (['101', '103', '105', '107'], '7×2.5'),
]
for prins, want in JM_CASES:
    got = call('jm:decide', [prins], GLOBAL)
    assert got and got[0] == want, (prins, got, want)
for prins in (['33'], ['607A'], ['107', '701']):
    assert not call('jm:decide', [prins], GLOBAL)[0], prins
# 合画柜合并写法拆开逐个判断（2026-10-27）
for prins, want in ((['A63(4)0I', 'B63(4)0I', 'C63(4)0I', 'N600'], '4×4'), (['A630I(640I)', 'B630I（640I）'], '4×4'),
                    (['107(8)', '133'], '4×2.5'), (['1(2)UBY-901', '701'], '4×1.5')):
    got = call('jm:decide', [prins], GLOBAL)
    assert got and got[0] == want, (prins, got, want)
# 括号里是完整柜名：整段替换，保留“至”和空格前的前缀
for s, de2 in (('至2#主变保护柜(1#35kV母线保护柜)', '至1#35kV母线保护柜'), ('至2#主变保护柜（1#35kV母线保护柜）', '至1#35kV母线保护柜'),
               ('2#主变保护柜(1#母线保护柜)', '1#母线保护柜'), ('至甲柜(至乙柜)', '至乙柜'), ('35kV 1#SVG控制柜(2#SVG控制柜)', '35kV 2#SVG控制柜'),
               ('至110kV GIS 1#主变汇控柜(2#主变汇控柜)', '至110kV GIS 2#主变汇控柜'), ('至110kV 1#柜(35kV 2#柜)', '至35kV 2#柜')):
    assert call('de:strip', [s, 1], GLOBAL) == de2, (s, call('de:strip', [s, 1], GLOBAL))
assert call('de:strip', ['至2#主变保护柜(1#35kV母线保护柜)', 0], GLOBAL) == '至2#主变保护柜'
# 括号里是完整编号：只有数字不同才整段替换
for s, de2 in (('12ZL-20(12ZL-22)', '12ZL-22'), ('22ZL-20(22ZL-22)', '22ZL-22'), ('11ZL-41(21ZL-41)', '21ZL-41'),
               ('至12ZL-20（12ZL-22）柜', '至12ZL-22柜'), ('DS-10(DS-11)', 'DS-11'), ('DS-10(11)', 'DS-11'),
               ('A630I(640I)', 'A640I'), ('至1-1#(2-1)直流馈线柜', '至2-1#直流馈线柜'), ('DS-1-1#(2-1)', 'DS-2-1#')):
    assert call('de:strip', [s, 1], GLOBAL) == de2, (s, call('de:strip', [s, 1], GLOBAL))
for s, de2 in (('1(2)UYH-141(140)A', '2UYH-140A'), ('1(2)UYH-141(140)B', '2UYH-140B'), ('(备用)1(2)#柜', '(备用)2#柜')):
    assert call('de:strip', [s, 1], GLOBAL) == de2, (s, call('de:strip', [s, 1], GLOBAL))
for s, de in (('1(2)UYH-142(141)A', '1UYH-142A'), ('1(2)UYH-142(141)B', '1UYH-142B'), ('(备用)1(2)#柜', '(备用)1#柜')):
    assert call('de:strip', [s, 0], GLOBAL) == de, (s, call('de:strip', [s, 0], GLOBAL))
assert not call('jm:decide', [['1(5)01']], GLOBAL)[0]           # 拆开 101、501 类型不同时不判
# DE / DE2 括号处理与 BH 拆分一致：括号里的数字只换括号前同样位数
for s, de, de2 in (('DS-10(11)', 'DS-10', 'DS-11'), ('A630I(640I)', 'A630I', 'A640I'), ('A63(4)0I', 'A630I', 'A640I'),
                   ('B63（4）0I', 'B630I', 'B640I'), ('DS-101(2)', 'DS-101', 'DS-102'), ('DS-9(10)', 'DS-9', 'DS-10'),
                   ('1(2)#主变保护柜', '1#主变保护柜', '2#主变保护柜'), ('至1-1#(2-1)直流馈线柜', '至1-1#直流馈线柜', '至2-1#直流馈线柜'),
                   ('至1-1#（2-1#）直流馈线柜', '至1-1#直流馈线柜', '至2-1#直流馈线柜'), ('1#(2)主变保护柜', '1#主变保护柜', '2#主变保护柜'),
                   ('至1-1(2-1)#直流馈线柜', '至1-1#直流馈线柜', '至2-1#直流馈线柜'), ('1#(2#)柜', '1#柜', '2#柜'),
                   ('至DS-1-1#(2-1)柜', '至DS-1-1#柜', '至DS-2-1#柜')):
    assert call('de:strip', [s, 0], GLOBAL) == de, (s, call('de:strip', [s, 0], GLOBAL))
    assert call('de:strip', [s, 1], GLOBAL) == de2, (s, call('de:strip', [s, 1], GLOBAL))
for have, prins, ok in (('4x2.5', ['101', '103'], True), ('4×2.5', ['101', '103'], True), ('4 X 1.5', ['501'], True),
                        ('4×2.5', ['107', '107A'], False), ('4×1.5', ['101', '103', '105', '107'], False),
                        ('2×4', ['+BM', '-BM'], True), ('4×4', ['+KM', '-KM'], False)):
    r = call('jm:check-spec', [have, call('jm:decide', [prins], GLOBAL), len(prins)], GLOBAL)
    assert (r is None) == ok, (have, prins, r)
r = call('jm:check-spec', ['4×2.5', call('jm:decide', [['101', '103', '105', '107']], GLOBAL), 4], GLOBAL)
assert r == '芯数不足：原理号 4 个，须留备用芯，应为 7×2.5', r
assert call('jm:check-spec', ['4×1.5', ['4×2.5'], 2], GLOBAL) == '应为 4×2.5'
for s, like in (('未填写', True), ('通讯线', True), ('4×2.5', True), ('7x1.5', True), ('至公用测控柜', False), ('1B-101', False), ('未编号', False)):
    assert bool(call('jm:spec-like-p', [s], GLOBAL)) == like, s
print('PASS: 场景21 JM 截面规则表（控母/合母、L/N、8xx、BL/BT/BS/B、107A 测控信号、2xx/3xx 等）与已填写截面核对')
# ---- 场景 22：结果卡片文件格式；命令行只留一两行
F22 = {PATH: list(SW)}
c = Cad(F22)
c.add_line('r1', 50, '35kV 2#SVG进线柜', '2PMU-146', ['2SVG-A442', '2SVG-N441'])   # 编号属于另一根 → 冲突
c.add_line('r2', 45, '35kV 2#主变进线柜', '未编号', ['2B-A4252', '2B-N4251'])       # 按记录填入
c.install('宽频同步相量测量采集柜')
c.ents['r1_num']['handle'] = 'A1B2'
c.run('c:bh2')
rep22 = c.reports[-1]
assert rep22[0] == 'AAREPORT\t1' and 'CMD\tBH2' in rep22 and 'DWG\tD:\\proj\\a.dwg' in rep22, rep22
assert 'SHORT\t完成：填入 1，冲突 1' in rep22, rep22
assert any(l.startswith('SUM\t完成：已编号新记入 0 根；按记录填入 1 根') for l in rep22), rep22
items22 = [l.split('\t') for l in rep22 if l.startswith('ITEM\t')]
assert items22 == [['ITEM', 'err', '编号冲突', 'A1B2', '2PMU-146：与另一端记录编号 2PMU-145 不一致']], items22
printed = [o for o in c.out if o.startswith('\r\n[')]
assert printed[-1] == '\r\n[BH2] 完成：填入 1，冲突 1；1 条问题已选中，明细见结果卡片' and len(printed) <= 3, printed
assert call('aa:rep-counts', [[('填入', 0), ('冲突', 0)]], GLOBAL) == '没有变化'
print('PASS: 场景22 结果卡片：文件头/汇总/明细（级别、类别、句柄、文字）正确，命令行只留一行汇总')
# ---- 场景 23：合画柜（两张图合画一张，柜名写成 1(2)#）：按各张图的记录合成 DS-24(25)
H23 = '电缆编号	柜名1	柜名2	原理号	图纸	时间	旧编号'
R24 = 'DS-24	同步时钟主机柜	35kV 1#SVG控制柜	B+ B-	D0202.dwg	t	'
R25 = 'DS-25	同步时钟主机柜	35kV 2#SVG控制柜	B+ B-	D0202.dwg	t	'
alts = lambda s: call('bh:combo-alts', [s], GLOBAL)
join = lambda *n: call('bh:combo-join', [list(n)], GLOBAL)
assert alts('35kV 1(2)#SVG控制柜') == ['35kV 1#SVG控制柜', '35kV 2#SVG控制柜']
assert alts('35kV 1（2）#站用变') == ['35kV 1#站用变', '35kV 2#站用变']
assert alts('DS-24(25)') == ['DS-24', 'DS-25'] and alts('1(2,3)#柜') == ['1#柜', '2#柜', '3#柜']
assert alts('35kV(Ⅰ段)柜') is None and alts('同步时钟主机柜') is None and alts('(2)#柜') is None
assert join('DS-24', 'DS-25') == 'DS-24(25)' and join('1UBY-105', '2UBY-105') == '1(2)UBY-105'
assert join('DS-24', 'DS-24') == 'DS-24' and join('1B-101A', '1B-101B') is None and join('DS-24', 'TX-25') is None
assert join('1UYH-141A', '2UYH-140A') == '1(2)UYH-141(140)A' and alts('1(2)UYH-141(140)A') == ['1UYH-141A', '2UYH-140A']
assert alts('1(2)UYH-141(140,139)A') is None and alts('1(2)#柜(备用)') == ['1#柜(备用)', '2#柜(备用)']
F23 = {PATH: [H23, '1UYH-141A	1#主变保护柜	电压转接柜	A630I N600	x.dwg	t	',
              '2UYH-140A	2#主变保护柜	电压转接柜	A640I N600	x.dwg	t	']}
c = Cad(F23)                                   # 用户实例：两张图编号差两段数字 → 1(2)UYH-141(140)A；重跑核对一致
c.add_line('k1', 50, '电压转接柜', '未编号', ['A63(4)0I', 'N600'])
c.install('1(2)#主变保护柜')
c.run('c:bh2')
assert c.num('k1') == '1(2)UYH-141(140)A' and c.markers == [], (c.num('k1'), c.markers)
c = Cad(F23)
c.add_line('k1', 50, '电压转接柜', '1(2)UYH-141(140)A', ['A63(4)0I', 'N600'])
c.install('1(2)#主变保护柜')
c.run('c:bh2')
assert c.markers == [] and any('已编号且与记录一致 1 根' in o for o in c.out), (c.markers, c.out)
for start in ('35kV 1(2)#SVG控制柜', '35kV 1（2）#SVG控制柜'):      # 用户实例：两张记录都在 → 合成填入，记录不变
    F23 = {PATH: [H23, R24, R25]}
    c = Cad(F23)
    c.add_line('k1', 50, '同步时钟主机柜', '未编号', ['B+', 'B-'])
    c.install(start)
    c.run('c:bh2')
    assert c.num('k1') == 'DS-24(25)' and F23[PATH] == [H23, R24, R25] and c.selected == [], (c.num('k1'), c.selected)
    assert any('按记录填入 1 根' in o for o in c.out) and any('合成编号填入 1 根' in o for o in c.out), c.out
F23 = {PATH: [H23, R24]}                       # 只有一张图的记录：不填，选中写原因，不算“未编号无记录”
c = Cad(F23)
c.add_line('k1', 50, '同步时钟主机柜', '未编号', ['B+', 'B-'])
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert c.num('k1') == '未编号' and c.selected == ['k1_num'] and F23[PATH] == [H23, R24], (c.num('k1'), c.selected)
assert c.markers == [(50, '[合画柜] 合画柜只找到部分记录：35kV 1#SVG控制柜—同步时钟主机柜 记录 DS-24；'
                          '35kV 2#SVG控制柜—同步时钟主机柜 没有记录；另一张图编号记录后再运行 BH2')], c.markers
assert any('未编号且没有记录 0 根' in o and '合画柜无法填入 1 根' in o for o in c.out), c.out
F23 = {PATH: [H23]}                            # 已编号 DS-24(25)、记录里没有：拆开分别记入；重跑一致
c = Cad(F23)
c.add_line('k1', 50, '同步时钟主机柜', 'DS-24(25)', ['B-', 'B+'])
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert [l.split('	')[:4] for l in F23[PATH][1:]] == [['DS-24', '35kV 1#SVG控制柜', '同步时钟主机柜', 'B+ B-'],
                                                     ['DS-25', '35kV 2#SVG控制柜', '同步时钟主机柜', 'B+ B-']], F23[PATH]
assert any('已编号新记入 1 根' in o for o in c.out), c.out
REC23 = list(F23[PATH])
c = Cad(F23)
c.add_line('k1', 50, '同步时钟主机柜', 'DS-24(25)', ['B+', 'B-'])
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert F23[PATH] == REC23 and c.num('k1') == 'DS-24(25)' and any('已编号且与记录一致 1 根' in o for o in c.out), c.out
F23 = {PATH: [H23, R24, R25.replace('	t	', '	t	DS-27')]}  # 另一张图用 BHG 把 DS-27 改成了 DS-25：跟着改
c = Cad(F23)
c.add_line('k1', 50, '同步时钟主机柜', 'DS-24(27)', ['B+', 'B-'])
c.add_line('k2', 45, '公用测控柜', 'DS-24(26)', ['B+', 'B-'])        # DS-24 已属于别的电缆 → 冲突
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert c.num('k1') == 'DS-24(25)' and c.color('k2') == 1, (c.num('k1'), c.color('k2'))
assert any(m[1].startswith('[编号冲突] 35kV 1#SVG控制柜—公用测控柜 DS-24：编号已被另一根电缆使用') for m in c.markers), c.markers
F23 = {PATH: [H23, '1UBY-105	35kV 1#站用变进线柜	35kV 1#PT柜	1UBY-901 701	x.dwg	t	',
              '2UBY-105	35kV 2#站用变进线柜	35kV 2#PT柜	2UBY-901 701	x.dwg	t	',
              'UTB-101B	35kV 调相机变压器出线柜	1(2)#35kV母线保护柜	101 133	x.dwg	t	']}
c = Cad(F23)                                   # 两端柜名和原理号都是合并写法；记录本身就是合并柜名的照常直接填
c.add_line('k1', 50, '35kV 1(2)#PT柜', '未编号', ['1(2)UBY-901', '701'])
c.install('35kV 1(2)#站用变进线柜')
c.run('c:bh2')
assert c.num('k1') == '1(2)UBY-105', c.num('k1')
c = Cad(F23)
c.add_line('k1', 50, '1(2)#35kV母线保护柜', '未编号', ['101', '133'])
c.install('35kV调相机变压器出线柜')
c.run('c:bh2')
assert c.num('k1') == 'UTB-101B' and c.markers == [], (c.num('k1'), c.markers)
assert alts('A630I(640I)') == ['A630I', 'A640I'] and alts('A630II(640II)') == ['A630II', 'A640II']
assert alts('A630I(640)') is None and alts('A630I(640II)') is None and alts('XX(640I)') is None
F23 = {PATH: [H23, '1UYH-138	电压转接柜	35kV 1#SVG控制柜	A630I B630I C630I N600	D0202.dwg	t	',
              '2UYH-138	电压转接柜	35kV 2#SVG控制柜	A640I B640I C640I N600	D0202.dwg	t	']}
c = Cad(F23)                                   # 用户实例：原理号带字母尾缀的合并写法 A630I(640I)
c.add_line('k1', 50, '电压转接柜', '未编号', ['A630I(640I)', 'B630I(640I)', 'C630I（640I）', 'N600'])
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert c.num('k1') == '1(2)UYH-138' and c.markers == [], (c.num('k1'), c.markers)
assert alts('A63(4)0I') == ['A630I', 'A640I'] and alts('B63（4）0I') == ['B630I', 'B640I']      # 括号在数字中间
assert alts('DS-101(2)') == ['DS-101', 'DS-102'] and alts('DS-9(10)') == ['DS-9', 'DS-10'] and alts('A63(4,5)0') == ['A630', 'A640', 'A650']
c = Cad(F23)                                   # 用户写法：A63(4)0I 等同 A630I(640I)
c.add_line('k1', 50, '电压转接柜', '未编号', ['A63(4)0I', 'B63(4)0I', 'C63(4)0I', 'N600'])
c.install('35kV 1(2)#SVG控制柜')
c.run('c:bh2')
assert c.num('k1') == '1(2)UYH-138' and c.markers == [], (c.num('k1'), c.markers)
R103 = '1(2)ZYB-103	35kV 1(2)#站用变进线柜	35kV故障录波柜	1(2)ZYB-A421 1(2)ZYB-B421 1(2)ZYB-C421 1(2)ZYB-N421	D0206.dwg	t	'
F23 = {PATH: [H23, R103, '1ZYB-130	35kV故障录波柜	35kV 1#站用变进线柜	1ZYB-503 501	D0202.dwg	t	']}
REC23 = list(F23[PATH])
c = Cad(F23)                                   # 用户实例（反方向）：记录在合画图那端，录波柜这端分开画 → 拆开填
c.add_line('k1', 50, '35kV 1#站用变进线柜', '未编号', ['1ZYB-A421', '1ZYB-B421', '1ZYB-C421', '1ZYB-N421'])
c.add_line('k2', 45, '35kV 2#站用变进线柜', '未编号', ['2ZYB-N421', '2ZYB-A421', '2ZYB-B421', '2ZYB-C421'])
c.add_line('k3', 40, '35kV 1#站用变进线柜', '未编号', ['1ZYB-503', '501'])               # 分开的记录照常
c.install('35kV故障录波柜')
c.run('c:bh2')
assert (c.num('k1'), c.num('k2'), c.num('k3')) == ('1ZYB-103', '2ZYB-103', '1ZYB-130'), (c.num('k1'), c.num('k2'))
assert F23[PATH] == REC23 and any('拆开后填入 2 根' in o for o in c.out), c.out
c = Cad(F23)                                   # 已编号：和拆开的编号一致不另记，不一致标红
c.add_line('k1', 50, '35kV 1#站用变进线柜', '1ZYB-103', ['1ZYB-A421', '1ZYB-B421', '1ZYB-C421', '1ZYB-N421'])
c.add_line('k2', 45, '35kV 2#站用变进线柜', '2ZYB-109', ['2ZYB-A421', '2ZYB-B421', '2ZYB-C421', '2ZYB-N421'])
c.install('35kV故障录波柜')
c.run('c:bh2')
assert F23[PATH] == REC23 and c.color('k1') == 7 and c.color('k2') == 1, F23[PATH]
assert c.markers == [(45, '[编号冲突] 与合画图记录 1(2)ZYB-103 拆开后的编号 2ZYB-103 不一致')], c.markers
print('PASS: 场景23 BH2 合画柜 1(2)#：各张图记录合成 DS-24(25) 填入；只有部分记录时选中说明；已编号合并写法拆开记入/核对/旧号跟改；原理号合并写法（含 A630I(640I) 字母尾缀）；合并柜名的记录照常；反方向：合画图那端的记录拆开填 1ZYB-103 / 核对')
# ---- 场景 24：合画柜上的“至相邻屏柜”环网线：拆成 1#、2# 分别定前后柜，再合成编号和去向
H24 = '电缆编号	柜名1	柜名2	原理号	图纸	时间	旧编号'
RING24 = [H24, 'SML-15	110kV母线保护测控柜	1#主变保护柜	L1 N1	h.dwg	t	',
          'SML-16	1#主变保护柜	1#主变测控柜	L1 N1	h.dwg	t	',
          'SML-17	1#主变测控柜	2#主变保护柜	L1 N1	h.dwg	t	',
          'SML-18	2#主变保护柜	2#主变测控柜	L1 N1	h.dwg	t	']
nalts = lambda s: call('bh:name-alts', [s], GLOBAL)
assert nalts('110kV母线保护测控柜(1#主变测控柜)') == ['110kV母线保护测控柜', '1#主变测控柜']
assert nalts('甲柜（乙柜、丙柜）') == ['甲柜', '乙柜', '丙柜'] and nalts('DS-24(25)') is None and nalts('同步时钟主机柜') is None
F24 = {PATH: list(RING24)}
c = Cad(F24)                                   # 用户实例：D0205 1(2)#主变保护柜，两根“至相邻屏柜”的 L1 N1
c.add_line('a1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('a2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('1(2)#主变保护柜')
c.run('c:bh2')
assert (c.num('a1'), c.dest('a1'), c.num('a2'), c.dest('a2')) == \
       ('SML-15(17)', '至110kV母线保护测控柜(1#主变测控柜)', 'SML-16(18)', '至1(2)#主变测控柜'), \
       (c.num('a1'), c.dest('a1'), c.num('a2'), c.dest('a2'), c.out)
assert F24[PATH] == RING24 and c.selected == [] and c.markers == [], (c.selected, c.markers)
c = Cad(F24)                                   # 填好后重跑：拆开核对一致，记录不变
c.add_line('a1', 50, '110kV母线保护测控柜(1#主变测控柜)', 'SML-15(17)', ['L1', 'N1'], lead=20.0)
c.add_line('a2', 45, '1(2)#主变测控柜', 'SML-16(18)', ['L1', 'N1'], lead=25.0)
c.install('1(2)#主变保护柜')
c.run('c:bh2')
assert F24[PATH] == RING24 and c.markers == [] and any('已编号且与记录一致 2 根' in o for o in c.out), (c.markers, c.out)
F24 = {PATH: RING24[:3]}                       # 只有 1# 的环网记录：两根都不填，注明是哪一张定不了
c = Cad(F24)
c.add_line('a1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('a2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('1(2)#主变保护柜')
c.run('c:bh2')
assert (c.num('a1'), c.dest('a1'), c.num('a2')) == ('未编号', '至相邻屏柜', '未编号'), (c.num('a1'), c.num('a2'))
assert sorted(c.selected) == ['a1_num', 'a2_num'] and any('合画柜拆开后 2#主变保护柜：记录里没有本柜的相邻屏柜电缆' in o for o in c.out), c.out
F24 = {PATH: list(RING24)}
c = Cad(F24)                                   # 用户实例：1(2)#主变测控柜图上原理号是 L N，环网清单登记的是 L1 N1 → 不填，提示疑似
c.add_line('a1', 50, '相邻屏柜', '未编号', ['L', 'N'], lead=20.0)
c.add_line('a2', 45, '相邻屏柜', '未编号', ['L', 'N'], lead=25.0)
c.install('1(2)#主变测控柜')
c.run('c:bh2')
assert (c.num('a1'), c.num('a2')) == ('未编号', '未编号') and F24[PATH] == RING24, (c.num('a1'), c.num('a2'))
assert any('合画柜拆开后 1#主变测控柜：记录里没有本柜的相邻屏柜电缆；疑似 SML-16 SML-17 原理号写的是 L1 N1，统一图上和清册（记录）的原理号后再运行 BH2（查记录用：柜名 1#主变测控柜，原理号 L N）' in o
           for o in c.out), c.out
c = Cad(F24)                                   # 原理号统一成 L1 N1 后：1# 前 SML-16 后 SML-17，2# 前 SML-18
c.add_line('a1', 50, '相邻屏柜', '未编号', ['L1', 'N1'], lead=20.0)
c.add_line('a2', 45, '相邻屏柜', '未编号', ['L1', 'N1'], lead=25.0)
c.install('1(2)#主变测控柜')
c.run('c:bh2')
assert any('合画柜拆开后 2#主变测控柜：记录里本柜的相邻屏柜电缆有 1 根，应为 2 根，无法确定（查记录用：柜名 2#主变测控柜，原理号 L1 N1，找到 SML-18）' in o for o in c.out), c.out
c = Cad({PATH: list(RING24)})                  # 非合画柜不认“甲柜(乙柜)”：普通电缆照常记入
c.add_line('b1', 50, '主变测控柜(备用)', 'TX-101', ['101', '133'])
c.install('公用测控柜')
c.run('c:bh2')
assert any('已编号新记入 1 根' in o for o in c.out), c.out
# ---- 场景 25：BDL 补画电缆时，编号/截面文字照搬上下电缆同位置文字的对齐方式（纯函数部分）
gt = call('zddl2:e-text', ['未编号', 80.0, 30.5, '电缆-文字', 0, 0, 3.0, 0.0, 7], GLOBAL)
def dxf(g, code):
    return next(e[1] for e in g if e[0] == code)
left_ref = [(0, 'TEXT'), (72, 0), (73, 0), (10, [70.0, 35.6, 0.0]), (11, [0.0, 0.0, 0.0])]      # 左基线编号，所在电缆线 Y=35
right_ref = [(0, 'TEXT'), (72, 2), (73, 0), (10, [120.0, 35.5, 0.0]), (11, [131.0, 35.5, 0.0])]  # 右对齐截面
m = call('bdl:match-text', [gt, left_ref, -5.0], GLOBAL)
assert (dxf(m, 72), dxf(m, 73), dxf(m, 10)[:2], dxf(m, 11)[:2]) == (0, 0, [70.0, 30.6], [70.0, 30.6]), m
m = call('bdl:match-text', [gt, right_ref, -5.0], GLOBAL)
assert (dxf(m, 72), dxf(m, 11)[:2], dxf(m, 1)) == (2, [131.0, 30.5], '未编号'), m
assert call('bdl:match-text', [gt, [(72, 5), (73, 0)], 0.0], GLOBAL) == gt and call('bdl:match-text', [gt, None, 0.0], GLOBAL) == gt
mref = [(0, 'MTEXT'), (71, 3), (10, [131.0, 38.0, 0.0])]                                     # 右上附着的多行文字
m = call('bdl:match-text', [gt, mref, -5.0], GLOBAL)
assert (dxf(m, 72), dxf(m, 73), dxf(m, 11)[:2]) == (2, 3, [131.0, 33.0]), m
mref = [(0, 'MTEXT'), (71, 7), (10, [70.0, 35.5, 0.0])]                                      # 左下附着
m = call('bdl:match-text', [gt, mref, 0.0], GLOBAL)
assert (dxf(m, 72), dxf(m, 73), dxf(m, 11)[:2]) == (0, 1, [70.0, 35.5]), m
# ZUO/YOU/SHANG/XIA 按视觉方向定对正：逆时针 90° 的竖排文字上对齐用“右中”(11)，改内容后顶端不动
import math
GLOBAL.vars['pi'] = math.pi
NATIVE.setdefault('atan', lambda a, b=None: math.atan(a) if b is None else math.atan2(a, b))
NATIVE.setdefault('fix', lambda x: int(x))
q = lambda ed: call('aa:text-quadrant', [ed], GLOBAL)
assert [q([(0, 'TEXT'), (50, a)]) for a in (0.0, math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi - 0.01, -math.pi / 2)] == [0, 1, 2, 3, 0, 3]
assert q([(0, 'MTEXT'), (11, [0.0, 1.0, 0.0])]) == 1 and q([(0, 'MTEXT')]) == 0
code = lambda typ, qq, d: call('aa:visual-align-code', [typ, qq, d], GLOBAL)
assert [code('TEXT', 0, d) for d in 'TBLRC'] == [7, 13, 9, 11, 10]                           # 不旋转与原来相同
assert [code('MTEXT', 0, d) for d in 'TBLRC'] == [2, 8, 4, 6, 5]
assert [code('TEXT', 1, d) for d in 'TBLR'] == [11, 9, 7, 13]                                # 逆时针 90°
assert [code('TEXT', 2, d) for d in 'TBLR'] == [13, 7, 11, 9] and [code('TEXT', 3, d) for d in 'TBLR'] == [9, 11, 13, 7]
assert code('MTEXT', 1, 'T') == 6
# ---- 场景 26：XZYL 修正原理号：对面已有的原地保留，其余按从左到右换成录入的
plan = lambda src, dst: call('zyl:plan', [src, dst], GLOBAL)
assert plan(['101', '133', '102'], ['101', '133', '102']) is None                        # 已一致
assert plan(['101', '133'], ['133', '101']) is None                                      # 只是顺序不同，不动
assert plan(['A630I', 'B630I', 'N600'], ['A631', 'B630I', 'N600']) == [[0, 'A630I']]     # 只改错的那个
assert plan(['L1', 'N1'], ['L', 'N']) == [[0, 'L1'], [1, 'N1']]
assert plan(['101', '101', '133'], ['101', '102', '103']) == [[1, '101'], [2, '133']]    # 重复原理号各用一次
assert call('zyl:remove1', ['a', ['b', 'a', 'a']], GLOBAL) == ['b', 'a']
# 替换后靠近电缆线的一端回到原位：竖排原理号在电缆线上方，下边不动；在下方，上边不动
dy = lambda ob, nb, y: call('zyl:near-dy', [ob, nb, y], GLOBAL)
assert abs(dy([[0, 50], [3, 80]], [[0, 47], [3, 80]], 0.0) - 3) < 1e-9                  # 往下长了 3 → 上移 3
assert abs(dy([[0, 50], [3, 80]], [[0, 50], [3, 83]], 0.0)) < 1e-9                      # 往上长，下边没动
assert abs(dy([[0, -80], [3, -50]], [[0, -80], [3, -47]], 0.0) + 3) < 1e-9              # 电缆线在上方，上边回原位
assert calls(FUNCS['zyl:replace']).count('zyl:set-place') == 1 and 'jm:set-text' not in calls(FUNCS['zyl:replace'])
# 替换后按 ZDDL 原理号放置：向上出线（芯线远端在电缆下方）右对齐、边线往下 2；向下出线左对齐、边线往上 2
place = lambda side, pin: call('zyl:zddl-place', [Sym(side.lower()), pin], GLOBAL)
assert place('DOWN', 175.0) == [2, 173.0] and place('UP', 100.0) == [0, 102.0]
# 先选后执行与先运行后点选都可以：预选里有绿色电缆线就直接用它，不再提示点选
def xzyl_run(pre, rec):
    log, keep = [], {k: NATIVE.get(k) for k in ('ssget', 'sslength', 'ssname', 'sssetfirst', 'xy:is-green-hline-p',
                                               'zyl:load', 'zyl:pick', 'zyl:record', 'zyl:replace', 'princ', 'vl-filename-base')}
    NATIVE.update({'ssget': lambda *a: list(pre) if pre and a and a[0] == '_I' else None,
                   'sslength': lambda ss: len(ss or []), 'ssname': lambda ss, i: ss[i],
                   'sssetfirst': lambda *a: log.append('unselect'), 'xy:is-green-hline-p': lambda en: en.startswith('g'),
                   'zyl:load': lambda: rec, 'zyl:pick': lambda *a: log.append('pick') or 'gpicked',
                   'zyl:record': lambda en: log.append(('record', en)), 'zyl:replace': lambda en, r: log.append(('replace', en)),
                   'princ': lambda *a: None, 'vl-filename-base': lambda f: f})
    try:
        call('zyl:work', [], GLOBAL)
    finally:
        for k, v in keep.items():
            if v is None:
                NATIVE.pop(k, None)
            else:
                NATIVE[k] = v
    return log
REC = [['L1', 'N1'], 'SML-16', 'x.dwg', 'A1']
assert xzyl_run(['t1', 'g2', 'g3'], None) == ['unselect', ('record', 'g2')]           # 先选：录入预选的第一根绿色电缆线
assert xzyl_run(['g5'], REC) == ['unselect', ('replace', 'g5')]                       # 先选：已录入时直接替换
assert xzyl_run(None, None) == ['pick', ('record', 'gpicked')]                       # 先运行后点选：录入
assert xzyl_run(None, REC) == ['pick', ('replace', 'gpicked')]                       # 先运行后点选：替换
assert xzyl_run(['t1'], REC) == ['unselect', 'pick', ('replace', 'gpicked')]         # 预选里没有绿色电缆线：清预选后照常点选
# 合画图那端录入（1(2)B-105、1(2)YB-A4161）：按对面电缆去向里的 1#/2# 拆成对应那一张，原理号取拆开的、“未编号”填拆开的编号；用后清除录入
REC2 = [['1(2)YB-A4161', '1(2)YB-B4161', '1(2)YB-N4161a'], '1(2)B-105', 'D0205.dwg', 'A1']
vt = call('zyl:variants', [REC2], GLOBAL)
assert vt == [[['1B-105', ['1YB-A4161', '1YB-B4161', '1YB-N4161a']], ['2B-105', ['2YB-A4161', '2YB-B4161', '2YB-N4161a']]], ['1', '2']], vt
assert call('zyl:variants', [[['L1', 'N1'], 'SML-16', 'x', 'h']], GLOBAL) is None
assert call('zyl:variants', [[['1(2)YB-A4161', 'A4(5,6)'], '1(2)B-105', 'x', 'h']], GLOBAL) is None   # 拆开个数对不上
has = lambda d, t: lt(call('zyl:dest-has-p', [d, t], GLOBAL))
assert has('至110kV GIS1#主变汇控柜', '1') and not has('至110kV GIS1#主变汇控柜', '2') and not has('至11#柜', '1') and has('至2＃主变汇控柜', '2')
def xzyl_replace(rec, dest, tnum, dst, ask=None):
    log, keep = [], {k: NATIVE.get(k) for k in ('zyl:read', 'zyl:texts', 'zyl:dwg', 'entget', 'zyl:set-place', 'bh:set-num',
                                               'princ', 'getint', 'getkword', 'zyl:clear')}
    ents = ['p%d' % i for i in range(len(dst))]
    NATIVE.update({'zyl:read': lambda en: [ents, 0, tnum, ['v'] * len(dst), 'numEnt', dest],
                   'zyl:texts': lambda es: [dict(zip(ents, dst)).get(e, e) for e in es], 'zyl:dwg': lambda: 'other.dwg',
                   'entget': lambda en: [[5, 'B2'], [10, [0.0, 0.0, 0.0]]],
                   'zyl:set-place': lambda en, val, vrec, y: (log.append((en, val)), dst.__setitem__(ents.index(en), val)),
                   'bh:set-num': lambda en, val: log.append(('num', val)), 'princ': lambda *a: None,
                   'getint': lambda *a: log.append('ask') or ask, 'getkword': lambda *a: log.append('kw') or 'N',
                   'zyl:clear': lambda: log.append('clear')})
    try:
        call('zyl:replace', ['en', rec], GLOBAL)
    finally:
        for k, v in keep.items():
            if v is None:
                NATIVE.pop(k, None)
            else:
                NATIVE[k] = v
    return log
# 1# 柜：去向含 1#，原理号换成括号外的，“未编号”填 1B-105，用后清除录入
assert xzyl_replace(REC2, '至110kV GIS1#主变汇控柜', '未编号', ['1B-A4161', '1B-B4161', '1B-N4161']) == \
    [('p0', '1YB-A4161'), ('p1', '1YB-B4161'), ('p2', '1YB-N4161a'), ('num', '1B-105'), 'clear']
# 2# 柜：重新录入后拆成 2 开头
assert xzyl_replace(REC2, '至110kV GIS2#主变汇控柜', '未编号', ['2B-A4161', '2B-B4161', '2B-N4161']) == \
    [('p0', '2YB-A4161'), ('p1', '2YB-B4161'), ('p2', '2YB-N4161a'), ('num', '2B-105'), 'clear']
# 去向看不出：已有正式编号 2B-105 → 第 2 张；原理号已一致只是没编号 → 只填编号
assert xzyl_replace(REC2, '至主变电度表柜', '2B-105', ['2B-A4161', '2B-B4161', '2B-N4161'])[-2:] == [('p2', '2YB-N4161a'), 'clear']
assert xzyl_replace(REC2, '至某柜', '未编号', ['1YB-A4161', '1YB-B4161', '1YB-N4161a']) == [('num', '1B-105'), 'clear']
# 都判断不了时让用户选序号；取消则不改
assert xzyl_replace(REC2, '至某柜', '未编号', ['L', 'N', 'X'], ask=2) == ['ask', ('p0', '2YB-A4161'), ('p1', '2YB-B4161'), ('p2', '2YB-N4161a'), ('num', '2B-105'), 'clear']
assert xzyl_replace(REC2, '至某柜', '未编号', ['L', 'N', 'X'], ask=None) == ['ask']
# 非合画录入：未编号也填录入的编号；对面已有不同正式编号仍先询问
assert xzyl_replace([['L1', 'N1'], 'SML-16', 'x.dwg', 'A1'], '至甲柜', '未编号', ['L', 'N']) == [('p0', 'L1'), ('p1', 'N1'), ('num', 'SML-16'), 'clear']
assert xzyl_replace([['L1', 'N1'], 'SML-16', 'x.dwg', 'A1'], '至甲柜', 'SML-17', ['L', 'N']) == ['kw']
# BH2：编号相同、两端柜名相同、原理号不同 → 直接说明原理号不一致并写出两边原理号；柜名不同的仍按“编号已被另一根电缆使用”
F26 = {PATH: [H23, 'SML-16\t1#主变测控柜\t公用测控柜\tL1 N1\tx.dwg\tt\t']}
c = Cad(F26)
c.add_line('m1', 50, '公用测控柜', 'SML-16', ['L', 'N'])
c.add_line('m2', 45, '直流馈线柜', 'SML-16', ['L1', 'N1'])
c.install('1#主变测控柜')
c.run('c:bh2')
assert c.color('m1') == 1 and c.color('m2') == 1 and F26[PATH][1:] == ['SML-16\t1#主变测控柜\t公用测控柜\tL1 N1\tx.dwg\tt\t'], (c.markers, F26)
assert any('两端原理号不一致：记录里 1#主变测控柜—公用测控柜 的这根电缆原理号是 L1 N1，本图是 L N；统一两端原理号（可用 XZYL 修正）后再运行' in t for _, t in c.markers), c.markers
assert any('编号已被另一根电缆使用（1#主变测控柜—公用测控柜）' in t for _, t in c.markers), c.markers
print('PASS: 场景26 XZYL 修正原理号：一致不动、顺序不同不动、只换不一致的、重复原理号各用一次；先选后执行与先运行后点选都可用；合画图录入按去向 1#/2# 拆开替换并填编号、用后清除录入；BH2 编号相同、柜名相同、原理号不同时说明原理号不一致并提示 XZYL')
print('PASS: 场景25 BDL 文字对齐：左基线照搬插入点、右对齐照搬对齐点并平移到新电缆高度；布满/无参考时保持默认')
print('PASS: 场景24 BH2 合画柜相邻屏柜：拆成 1#、2# 分别定前后柜，合成 SML-15(17) 至甲柜(乙柜) / SML-16(18) 至 1(2)#柜；重跑核对一致；只有一张有记录时选中说明；非合画柜不误拆')
# ---- 场景 27：竖直绿色电缆线（D0204 QW3 实例）JM / BH / XZYL 全链路支持
for _k in ('xy:hline-info-ed', 'bh:line-texts', 'bh:text-index'):
    NATIVE.pop(_k, None)
NATIVE.update({'ssname': lambda ss, i: ss[i], 'sslength': lambda ss: len(ss or [])})
vhinfo = call('xy:hline-info-ed', [[(0, 'LINE'), (10, [68674.2242, 23664.4575, 0.0]), (11, [68674.2242, 23224.1392, 0.0])]], GLOBAL)
assert vhinfo == [23224.1392, 23664.4575, 68674.2242, [68674.2242, 23224.1392, 0.0], Sym('v')], vhinfo
assert lt(call('xy:vline-hinfo-p', [vhinfo], GLOBAL))
assert lt(call('bh:in-band-p', [68675.0529, 23300.8849, vhinfo], GLOBAL))  # 1YYH-102B
assert lt(call('bh:in-band-p', [68674.7242, 23275.1816, vhinfo], GLOBAL))  # 至110kV母线保护测控柜
assert lt(call('bh:in-band-p', [68675.0529, 23236.0855, vhinfo], GLOBAL))  # 10×1.5
assert not lt(call('bh:in-band-p', [68690.2783, 23662.9575, vhinfo], GLOBAL))  # 端子排内原理号 827 不在线旁文字带内

# bh:line-texts 在竖直电缆线上按 -Y 排序提取编号与去向，bh:texts-complete-p 判定完整
v_ents = {
    'vn': [(0, 'TEXT'), (8, '0'), (10, [68675.0529, 23300.8849, 0.0]), (1, '1YYH-102B')],
    'vd': [(0, 'TEXT'), (8, '0'), (10, [68674.7242, 23275.1816, 0.0]), (1, '至110kV母线保护测控柜')],
    'vs': [(0, 'TEXT'), (8, '0'), (10, [68675.0529, 23236.0855, 0.0]), (1, '10×1.5')],
}
NATIVE['entget'] = lambda en: v_ents[en]
NATIVE['aa:ysdl-get-plain-text'] = lambda ed: dict(ed)[1]
venv = Env(GLOBAL, ['*bh-tail*'])
venv.vars['*bh-tail*'] = call('bh:text-index', [['vn', 'vd', 'vs']], venv)
v_ltexts = call('bh:line-texts', [vhinfo], venv)
assert [r[1] for r in v_ltexts] == ['vn', 'vd', 'vs'], v_ltexts
assert lt(call('bh:texts-complete-p', [v_ltexts], venv))

# XZYL 水平原理号替换后靠端子排边线一端保持原位
dx = lambda ob, nb, x: call('zyl:near-dx', [ob, nb, x], GLOBAL)
assert abs(dx([[68690.0, 23662.0], [68695.0, 23665.0]], [[68688.0, 23662.0], [68695.0, 23665.0]], 68684.2242) - 2.0) < 1e-9

# BDL 竖向端子排方向判定与竖向电缆文字对齐参考（bdl:direction-v / bdl:match-vtext）
vitems = [
    [23664.4575, 68690.2783, 68695.8783, [[6.0541, 68684.2242], None]],
    [23534.4575, 68690.6283, 68695.5283, [[6.4041, 68684.2242], None]],
]
assert call('bdl:direction-v', [vitems, [[68674.2242, 23224.1392, 23664.4575]]], GLOBAL) == -1
# 原理号左端对齐（贴左边线）时向左，即使右侧 200 内有相邻端子排的绿色竖向电缆，也不被它带偏
aligned = [
    [23664.4575, 68690.2783, 68695.8783, [[6.0541, 68684.2242], None]],
    [23534.4575, 68690.2783, 68695.5283, [[6.0541, 68684.2242], None]],
]
assert call('bdl:direction-v', [aligned, [[68780.0, 23224.1392, 23664.4575]]], GLOBAL) == -1
# 挡位判断与横排 bdl:slot-line 一样只看 400 以内
assert call('bdl:vslot-line', [[[100.0, 0.0, 500.0]], 100.0, 600.0], GLOBAL)
assert not lt(call('bdl:vslot-line', [[[100.0, 0.0, 150.0]], 100.0, 600.0], GLOBAL))
vgt = [[0, 'TEXT'], [1, '未编号'], [10, [68669.7242, 23296.5634, 0.0]], [11, [68669.7242, 23296.5634, 0.0]], [50, 4.712389], [72, 0], [73, 0]]
vref = [(0, 'TEXT'), (1, '1YYH-102B'), (10, [68675.0529, 23300.8849, 0.0]), (11, [68675.0529, 23284.4349, 0.0]), (50, 4.712389), (72, 2), (73, 0)]
vm = dict(call('bdl:match-vtext', [vgt, vref, -5.0], GLOBAL))
assert vm[72] == 2 and vm[73] == 0 and abs(vm[11][0] - (68675.0529 - 5.0)) < 1e-6 and abs(vm[11][1] - 23284.4349) < 1e-6, vm

# 端到端执行 bdl:work（选中 2 个水平原理号，模拟 D0204 竖排端子排补画竖向电缆）
bdl_ents = {
    'p1': [(0, 'TEXT'), (1, '827'), (8, '0'), (10, [68690.2783, 23662.9575, 0.0]), (50, 0.0)],
    'p2': [(0, 'TEXT'), (1, '829'), (8, '0'), (10, [68690.2783, 23647.9575, 0.0]), (50, 0.0)],
    'edgeL': [(0, 'LINE'), (8, '0'), (10, [68684.2242, 23700.0, 0.0]), (11, [68684.2242, 23500.0, 0.0])],
    'g1': [(0, 'LINE'), (8, '0'), (62, 3), (10, [68674.2242, 23664.4575, 0.0]), (11, [68674.2242, 23224.1392, 0.0])],
    'tip1': [(0, 'LWPOLYLINE'), (90, 3), [10, 68674.2242, 23276.5634], [10, 68676.7978, 23281.021], [10, 68671.6506, 23281.021]],
    'vn': [(0, 'TEXT'), (1, '1YYH-102B'), (8, '0'), (10, [68675.0529, 23300.8849, 0.0]), (11, [68675.0529, 23284.4349, 0.0]), (50, 4.712389), (72, 2), (73, 0)],
    'vs': [(0, 'TEXT'), (1, '10×1.5'), (8, '0'), (10, [68675.0529, 23236.0855, 0.0]), (11, [68675.0529, 23227.3355, 0.0]), (50, 4.712389), (72, 2), (73, 0)],
}
bdl_bboxes = {
    'p1': [[68690.2783, 23662.9575, 0.0], [68695.8783, 23665.9575, 0.0]],
    'p2': [[68690.2783, 23647.9575, 0.0], [68695.8783, 23650.9575, 0.0]],
    'vn': [[68675.0529, 23284.4349, 0.0], [68678.0529, 23300.8849, 0.0]],
    'vs': [[68675.0529, 23227.3355, 0.0], [68678.0529, 23236.0855, 0.0]],
}
made = []
def mock_bdl_ssget(*args):
    if len(args) == 1:
        return ['p1', 'p2']
    mode = args[0]
    if mode == '_X':
        flt = dict(args[1])
        if flt.get(0) == 'LINE':
            return ['g1']
        if flt.get(0) == 'LWPOLYLINE':
            return ['tip1']
    if mode == '_C':
        p1, p2, flt = args[1], args[2], dict(args[3])
        if flt.get(0) == 'LINE,LWPOLYLINE':
            xlo, xhi = min(p1[0], p2[0]), max(p1[0], p2[0])
            if xlo <= 68684.2242 <= xhi:
                return ['edgeL']
            return []
        if flt.get(0) == 'TEXT,MTEXT':
            return ['vn', 'vs']
    return []
NATIVE.update({
    'ssget': mock_bdl_ssget,
    'entget': lambda en: bdl_ents[en],
    'aa:safe-get-bbox': lambda doc, en: bdl_bboxes.get(en),
    'aa:bbox-left-x': lambda bb: bb[0][0],
    'aa:bbox-right-x': lambda bb: bb[1][0],
    'aa:bbox-bottom-y': lambda bb: bb[0][1],
    'aa:bbox-top-y': lambda bb: bb[1][1],
    'aa:text-quadrant': lambda ed: 3 if abs(dict(ed).get(50, 0.0) - 4.712389) < 0.1 else 0,
    'getvar': lambda k: 'Model',
    'trans': lambda p, a, b: p,
    'tblsearch': lambda t, n: True,
    'aa:layer-locked-p': lambda l: None,
    'zddl:ensure-layer': lambda l, c: None,
    'entmake': lambda dxf: made.append({x[0]: (x[1] if isinstance(x, tuple) or len(x) == 2 else x[1:]) for x in dxf}) or True,
    'redraw': lambda: None,
    'sqrt': __import__('math').sqrt,
    'rtos': lambda v, m=2, p=2: f'{v:.{p}f}',
    'princ': lambda *a: None,
})
call('bdl:work', [], GLOBAL)
# 应生成：2 根水平引线 + 2 根短斜线 + 1 根竖向绿色电缆线（X=68669.2242）+ 1 个箭头 + 3 个 270° 文字 = 9 个图元
assert len(made) == 9, len(made)
vgreen = [m for m in made if m.get(0) == 'LINE' and m.get(62) == 3]
assert len(vgreen) == 1 and abs(vgreen[0][10][0] - 68669.2242) < 1e-4 and abs(vgreen[0][11][1] - 23224.1392) < 1e-4, vgreen
vtxts = [m for m in made if m.get(0) == 'TEXT']
assert [m[1] for m in vtxts] == ['未编号', '至未填写', '未填写'], vtxts
# 端子排边框是矩形闭合多段线（用户 QW3：双电源切换箱）时，bdl:cross-lines 拆出与窗口相交的直线段，圆弧段跳过
rect_ents = {
    'rect': [(0, 'LWPOLYLINE'), (90, 4), (70, 1),
             [10, -6629.4749, 6095.2374], [10, -6599.1674, 6095.2374],
             [10, -6599.1674, 6080.9937], [10, -6629.4749, 6080.9937]],
    'arc': [(0, 'LWPOLYLINE'), (90, 2), (70, 0), [10, -6625.0, 6070.0], (42, 1.0), [10, -6615.0, 6070.0]],
    'ln': [(0, 'LINE'), (10, [-6620.0, 6000.0, 0.0]), (11, [-6620.0, 6200.0, 0.0])],
}
old_ssget2, old_entget2 = NATIVE['ssget'], NATIVE['entget']
NATIVE['ssget'] = lambda *a: ['rect', 'arc', 'ln'] if a[0] == '_C' and dict(a[3]).get(0) == 'LINE,LWPOLYLINE' else []
NATIVE['entget'] = lambda en: rect_ents[en]
segs = call('bdl:cross-lines', [[-6622.4, 6052.3, 0.0], [-6622.3, 6115.8, 0.0]], GLOBAL)
segs = sorted((round(a[0], 4), round(a[1], 4), round(b[0], 4), round(b[1], 4)) for a, b in (list(s) for s in segs))
assert segs == sorted([(-6620.0, 6000.0, -6620.0, 6200.0),
                       (-6629.4749, 6095.2374, -6599.1674, 6095.2374),
                       (-6599.1674, 6080.9937, -6629.4749, 6080.9937)]), segs
edges = call('bdl:edge', [-6622.3949, 6082.2869, 6085.7869], GLOBAL)
assert abs(edges[0][1] - 6080.9937) < 1e-4 and abs(edges[1][1] - 6095.2374) < 1e-4, edges
NATIVE['ssget'], NATIVE['entget'] = old_ssget2, old_entget2
# BDL 绿线与箭头只在当前视图内交叉选择；视图扭转/非世界 UCS 时退回全图
view_calls = []
old_ssget, old_getvar = NATIVE['ssget'], NATIVE['getvar']
view_vars = {'WORLDUCS': 1, 'VIEWTWIST': 0.0, 'VIEWCTR': [100.0, 50.0, 0.0], 'VIEWSIZE': 40.0,
             'SCREENSIZE': [800.0, 400.0], 'CTAB': 'Model'}
NATIVE['getvar'] = lambda k: view_vars[k]
NATIVE['ssget'] = lambda *a: view_calls.append(a) or None
call('bdl:view-ss', [[(0, 'LINE'), (62, 3)]], GLOBAL)
mode, c1, c2, flt = view_calls[-1]
assert mode == '_C' and list(c1)[:2] == [60.0, 30.0] and list(c2)[:2] == [140.0, 70.0], view_calls[-1]
assert dict(flt).get(62) == 3 and dict(flt).get(410) == 'Model', flt
view_vars['VIEWTWIST'] = 0.5
call('bdl:view-ss', [[(0, 'LWPOLYLINE'), (90, 3)]], GLOBAL)
assert view_calls[-1][0] == '_X' and dict(view_calls[-1][1]).get(90) == 3, view_calls[-1]
NATIVE['ssget'], NATIVE['getvar'] = old_ssget, old_getvar
print('PASS: 场景27b BDL 绿线与箭头只在当前视图内查找，视图扭转时退回全图')
print('PASS: 场景27 D0204 竖直绿色电缆线 QW3 实例（xy:hline-info-ed / bh:in-band-p / bh:line-texts / zyl:near-dx / bdl:work 竖向端到端）')
# 场景31：原理号居中（D0206 UA3 实例：文字左端 36465.8196，端子排边线 X=36455.6653，相距 10.15）
# 边线查找范围放宽到 30 后两侧都能找到，各取最近一根；更远的绿色电缆线 X=36445.6653 不会被当成边线
old_cross = NATIVE.get('bdl:cross-lines')
cross_calls = []
d0206_lines = [
    [[36455.6653, 513.9077, 0.0], [36455.6653, 508.9077, 0.0]],   # 端子排左边线（白色短段）
    [[36445.6653, 616.4077, 0.0], [36445.6653, 93.8785, 0.0]],    # 已有绿色竖向电缆线
    [[36481.4196, 513.9077, 0.0], [36481.4196, 508.9077, 0.0]],   # 端子格右边线
]
def mock_cross(p1, p2):
    cross_calls.append((p1, p2))
    xlo, xhi = min(p1[0], p2[0]), max(p1[0], p2[0])
    return [ln for ln in d0206_lines if xlo <= ln[0][0] <= xhi]
NATIVE['bdl:cross-lines'] = mock_cross
ev = call('bdl:edge-v', [511.4077, 36465.8196, 36471.4196], GLOBAL)
assert abs(cross_calls[-1][0][0] - (36465.8196 - 30.0)) < 1e-6 and abs(cross_calls[-1][1][0] - (36471.4196 + 30.0)) < 1e-6, cross_calls[-1]
assert abs(ev[0][1] - 36455.6653) < 1e-6 and abs(ev[0][0] - 10.1543) < 1e-3, ev
assert abs(ev[1][1] - 36481.4196) < 1e-6, ev
# 居中：两侧边线都有、距离相同，靠左侧已有绿色竖向电缆定为向左
items_c = [[511.4077, 36465.8196, 36471.4196, ev], [501.4077, 36465.8196, 36471.4196, ev]]
assert call('bdl:direction-v', [items_c, [[36445.6653, 93.8785, 616.4077]]], GLOBAL) == -1
# 横排同样放宽到 30
d0206_lines = [[[0.0, 10.0, 0.0], [20.0, 10.0, 0.0]], [[0.0, 44.0, 0.0], [20.0, 44.0, 0.0]]]
def mock_cross_h(p1, p2):
    cross_calls.append((p1, p2))
    ylo, yhi = min(p1[1], p2[1]), max(p1[1], p2[1])
    return [ln for ln in d0206_lines if ylo <= ln[0][1] <= yhi]
NATIVE['bdl:cross-lines'] = mock_cross_h
eh = call('bdl:edge', [10.0, 22.0, 32.0], GLOBAL)
assert abs(cross_calls[-1][0][1] - (22.0 - 30.0)) < 1e-6 and abs(cross_calls[-1][1][1] - (32.0 + 30.0)) < 1e-6, cross_calls[-1]
assert abs(eh[0][0] - 12.0) < 1e-6 and abs(eh[1][0] - 12.0) < 1e-6, eh
# 横排居中：上下距离相同，靠已有绿色电缆的一侧定方向；没有绿色电缆时同旧规则默认向下
items_h = [[10.0, 22.0, 32.0, eh], [15.0, 22.0, 32.0, eh]]
assert call('bdl:direction', [items_h, [[60.0, -50.0, 300.0]]], GLOBAL) == 1
assert call('bdl:direction', [items_h, [[0.0, -50.0, 300.0]]], GLOBAL) == -1
assert call('bdl:direction', [items_h, []], GLOBAL) == -1
# 原理号对齐方式仍优先于已有电缆
items_al = [[10.0, 22.0, 32.0, eh], [15.0, 22.0, 30.0, eh]]
assert call('bdl:direction', [items_al, [[60.0, -50.0, 300.0]]], GLOBAL) == -1
if old_cross is None: NATIVE.pop('bdl:cross-lines', None)
else: NATIVE['bdl:cross-lines'] = old_cross
# 场景31b：D0206 实机反馈——视图内取到 5 根绿竖线，右侧 200 内也有别列的绿线，左右边线距离只差 1e-4。
# 应看“哪侧边线外的电缆位上有绿线”：左边线外 10 有 36445.6653，右侧 36500 不在右边线 36481.5738 的电缆位上 → 向左
ev2 = [[10.1543, 36455.6653], [10.1542, 36481.5738]]
items_d = [[511.4077, 36465.8196, 36471.4196, ev2], [501.4077, 36465.8196, 36471.4196, ev2]]
greens_d = [[36445.6653, 93.8785, 616.4077], [36500.0, 93.8785, 616.4077]]
assert call('bdl:direction-v', [items_d, greens_d], GLOBAL) == -1
# 右侧绿线若正好在右边线外 15 的电缆位上、左侧没有 → 向右
assert call('bdl:direction-v', [items_d, [[36496.5738, 93.8785, 616.4077], [36302.5, 93.8785, 616.4077]]], GLOBAL) == 1
# 没有绿线、两侧边线只差 1e-4 时算一样近，默认向左（原先会因 1e-4 判成向右）
assert call('bdl:direction-v', [items_d, []], GLOBAL) == -1
assert call('bdl:slot-hits', [[36445.6653, 36440.6653, 36500.0, 36446.9], 36455.6653, -1], GLOBAL) == 2
assert call('bdl:slot-hits', [[36445.6653], None, -1], GLOBAL) == 0
# 实机反馈：右侧距边线 10 有电缆，左侧远处另一列的绿线距左边线 160 碰巧在 5 的网格上，不应算作左侧电缆组 → 向右
assert call('bdl:slot-hits', [[36295.6653], 36455.6653, -1], GLOBAL) == 0
assert call('bdl:direction-v', [items_d, [[36295.6653, 93.8785, 616.4077], [36491.5738, 93.8785, 616.4077]]], GLOBAL) == 1
# 横排同理：下边线外 10 有绿线，上方 120 内另有不在电缆位上的绿线 → 向下
eh2 = [[12.0001, 10.0], [12.0, 44.0]]
items_h2 = [[10.0, 22.0, 32.0, eh2], [15.0, 22.0, 32.0, eh2]]
assert call('bdl:direction', [items_h2, [[0.0, -50.0, 300.0], [100.0, -50.0, 300.0]]], GLOBAL) == -1
assert call('bdl:direction', [items_h2, [[59.0, -50.0, 300.0], [-147.5, -50.0, 300.0]]], GLOBAL) == 1
assert call('bdl:direction', [items_h2, []], GLOBAL) == -1
print('PASS: 场景31b BDL 居中原理号按边线外电缆位上的绿线定方向，边线远近相差 0.5 内算一样近')
print('PASS: 场景31 BDL 原理号居中：边线查找放宽到 30 取最近一根，横/竖排靠已有绿色电缆定方向')
# ---- 场景32：并入（一根电缆分画两处，另一根编号写“并入X”）：与主电缆算同一根，原理号合并后核对、记录
H32 = '电缆编号	柜名1	柜名2	原理号	图纸	时间	旧编号'
assert call('bh:join-target', ['并入1(2)B-208'], GLOBAL) == '1(2)B-208' and call('bh:join-target', ['1B-208'], GLOBAL) is None
assert call('bh:join-target', ['并入：1B-208'], GLOBAL) == '1B-208' and call('bh:join-target', ['并入'], GLOBAL) is None
# 用户实例 1：主电缆 1B-208（1YB-801 1YB-803）+ 并入1B-208（BS01 BS03）= 记录里另一端的 4 芯；以前误记的“并入1B-208”并掉
F32 = {PATH: [H32, '1B-208	1#35kV接地电阻柜	110kV GIS1#主变汇控柜	1YB-801 1YB-803 BS01 BS03	d.dwg	t	',
              '并入1B-208	110kV GIS1#主变汇控柜	1#35kV接地电阻柜	BS01 BS03	a.dwg	t	']}
c = Cad(F32)
c.add_line('m1', 50, '1#35kV接地电阻柜', '1B-208', ['1YB-801', '1YB-803'])
c.add_line('j1', 45, '1#35kV接地电阻柜', '并入1B-208', ['BS01', 'BS03'])
c.install('110kV GIS1#主变汇控柜')
c.ents['m1_num']['color'] = 1
c.ents['j1_num']['color'] = 1
c.run('c:bh2')
assert c.markers == [] and c.selected == [] and c.color('m1') == 7 and c.color('j1') == 7, (c.markers, c.selected)
assert [l.split('	')[0] for l in F32[PATH][1:]] == ['1B-208'], F32[PATH]
assert any('已编号且与记录一致 1 根' in o and '编号冲突 0 根' in o for o in c.out), c.out
assert any('“并入”电缆 1 根已和主电缆算作同一根' in o for o in c.out) and any('“并入”记录 1 条已并到主电缆记录' in o for o in c.out), c.out
# 合画柜写法（用户图纸原样）：1(2)B-208 / 并入1(2)B-208，记录在分开画的两端
F32 = {PATH: [H32, '1B-208	1#35kV接地电阻柜	110kV GIS1#主变汇控柜	1YB-801 1YB-803 BS01 BS03	d.dwg	t	',
              '2B-208	2#35kV接地电阻柜	110kV GIS2#主变汇控柜	2YB-801 2YB-803 BS01 BS03	d.dwg	t	']}
REC32 = list(F32[PATH])
c = Cad(F32)
c.add_line('m1', 50, '1(2)#35kV接地电阻柜', '1(2)B-208', ['1(2)YB-801', '1(2)YB-803'])
c.add_line('j1', 45, '1(2)#35kV接地电阻柜', '并入1(2)B-208', ['BS01', 'BS03'])
c.install('110kV GIS1(2)#主变汇控柜')
c.run('c:bh2')
assert c.markers == [] and F32[PATH] == REC32 and any('已编号且与记录一致 1 根' in o for o in c.out), (c.markers, F32[PATH])
# 用户实例 2：两端分芯不同，另一端以前把“并入1B-102D”单独记了；并到主记录后两端一致
F32 = {PATH: [H32, '1B-102D	1#主变测控柜	110kV GIS1#主变汇控柜	851 853 855 857	c.dwg	t	',
              '并入1B-102D	1#主变测控柜	110kV GIS1#主变汇控柜	843 845 847 849 859 861	c.dwg	t	']}
c = Cad(F32)
c.add_line('m1', 50, '1#主变测控柜', '1B-102D', ['843', '845', '847', '849', '859', '861'])
c.add_line('j1', 45, '1#主变测控柜', '并入1B-102D', ['851', '853', '855', '857'])
c.install('110kV GIS1#主变汇控柜')
c.run('c:bh2')
assert c.markers == [] and [l.split('	')[:4] for l in F32[PATH][1:]] == [
    ['1B-102D', '1#主变测控柜', '110kV GIS1#主变汇控柜', '843 845 847 849 851 853 855 857 859 861']], F32[PATH]
# 主电缆记录是画并入线之前登记的（原理号正好是主电缆自己的）：改成合并后的原理号；重跑一致
F32 = {PATH: [H32, '1B-300	甲柜	乙柜	101 103	a.dwg	t	']}
c = Cad(F32)
c.add_line('m1', 50, '乙柜', '1B-300', ['101', '103'])
c.add_line('j1', 45, '乙柜', '并入1B-300', ['105'])
c.install('甲柜')
c.run('c:bh2')
assert c.markers == [] and rec_of(F32, '1B-300')[0][3] == '101 103 105' and len(F32[PATH]) == 2, F32[PATH]
REC32 = list(F32[PATH])
c = Cad(F32)
c.add_line('m1', 50, '乙柜', '1B-300', ['101', '103'])
c.add_line('j1', 45, '乙柜', '并入1B-300', ['105'])
c.install('甲柜')
c.run('c:bh2')
assert F32[PATH] == REC32 and c.markers == [], F32[PATH]
# 另一端记录少芯（不是主电缆自己的原理号）：仍报两端原理号不一致
F32 = {PATH: [H32, '1B-301	甲柜	乙柜	101	a.dwg	t	']}
c = Cad(F32)
c.add_line('m1', 50, '乙柜', '1B-301', ['101', '103'])
c.add_line('j1', 45, '乙柜', '并入1B-301', ['105'])
c.install('甲柜')
c.run('c:bh2')
assert c.color('m1') == 1 and any('两端原理号不一致' in t and '101 103 105' in t for _, t in c.markers), c.markers
# 主电缆不在本次选择 / 去向不同 / 并入后面写的是“未编号”：无法编号，不记录
F32 = {PATH: [H32]}
c = Cad(F32)
c.add_line('j1', 50, '乙柜', '并入1B-400', ['105'])
c.add_line('m2', 45, '丙柜', '1B-401', ['101'])
c.add_line('j2', 40, '丁柜', '并入1B-401', ['103'])
c.add_line('j3', 35, '丙柜', '并入未编号', ['107'])
c.install('甲柜')
c.run('c:bh2')
assert [l.split('	')[0] for l in F32[PATH][1:]] == ['1B-401'] and rec_of(F32, '1B-401')[0][3] == '101', F32[PATH]
assert sorted(c.selected) == ['j1_num', 'j2_num', 'j3_num'], c.selected
assert any('并入的主电缆 1B-400 不在本次选择里' in t for _, t in c.markers), c.markers
assert any('主电缆 1B-401 去向是 丙柜，这根是 丁柜，不能并入' in t for _, t in c.markers), c.markers
assert any('“并入”后面要写主电缆的编号' in t for _, t in c.markers), c.markers
# 主电缆旧编号改新编号时，并入线跟着改
F32 = {PATH: [H32, '1B-500	甲柜	乙柜	101 103	a.dwg	t	1B-499']}
c = Cad(F32)
c.add_line('m1', 50, '乙柜', '1B-499', ['101'])
c.add_line('j1', 45, '乙柜', '并入1B-499', ['103'])
c.install('甲柜')
c.run('c:bh2')
assert (c.num('m1'), c.num('j1')) == ('1B-500', '并入1B-500'), (c.num('m1'), c.num('j1'))
# BHG：画并入线前登记的主记录按图更正为合并后的原理号，旧“并入”记录并掉
F32 = {PATH: [H32, '1B-600	甲柜	乙柜	101	a.dwg	t	', '并入1B-600	甲柜	乙柜	109	a.dwg	t	']}
c = Cad(F32)
c.add_line('m1', 50, '乙柜', '1B-600', ['101'])
c.add_line('j1', 45, '乙柜', '并入1B-600', ['103'])
c.install('甲柜')
c.run('c:bhg')
assert [l.split('	')[:4] for l in F32[PATH][1:]] == [['1B-600', '甲柜', '乙柜', '101 103']], F32[PATH]
# BH3 清册：并入行并到主电缆行（原理号接在后面），找不到主行的不记入并说明
trs = [['1B-208', '110kV GIS1#主变汇控柜', '1#35kV接地电阻柜', ['1YB-801', '1YB-803'], 'e1', None],
       ['并入1B-208', '110kV GIS1#主变汇控柜', '1#35kV接地电阻柜', ['BS01', 'BS03'], 'e2', None],
       ['并入1B-209', '甲柜', '乙柜', ['101'], 'e3', None]]
r32 = call('bh:merge-table-joins', [trs], GLOBAL)
assert [list(x[:4]) for x in r32[0]] == [['1B-208', '110kV GIS1#主变汇控柜', '1#35kV接地电阻柜', ['1YB-801', '1YB-803', 'BS01', 'BS03']]], r32
assert len(r32[1]) == 1 and r32[1][0][0] == 'e3' and '找不到同两端柜名的主电缆行 1B-209' in r32[1][0][1] and list(r32[2]) == ['e2'], r32
# BH1：点选里的并入线并到主电缆一起记录；没有主电缆可并的不单独编号、记录
F32 = {}
Cad.ed = _ed                                   # BH1 要读起点柜名字高
c = bh2_cad(F32, '甲柜')
c.add_line('m1', 50, '乙柜', '1B-700', ['101'])
c.add_line('j1', 45, '乙柜', '并入1B-700', ['103'])
c.add_line('j2', 40, '乙柜', '并入1B-701', ['105'])
c.answers = ['1B', '101', '', '']
c.picks = ['start', 'm1', 'j1', 'j2', None, None]
c.run('c:bh1')
Cad.ed = _ed_orig
assert [l.split('	')[:4] for l in F32[PATH][1:]] == [['1B-700', '甲柜', '乙柜', '101 103']], F32[PATH]
assert any('并入 1B-700' in o and '不单独编号' in o for o in c.out), c.out
assert any('并入的主电缆 1B-701 不在本批点选里' in o for o in c.out), c.out
print('PASS: 场景32 并入：与主电缆算同一根，原理号合并核对/记录；旧“并入”记录并到主记录；画并入线前的主记录改为合并原理号；找不到主电缆时无法编号；旧号改新时并入线跟改；BH1/BHG/BH3 同样合并')
print('ALL PASS: check_bh_static')

