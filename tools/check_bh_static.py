"""电缆编号命令 BH1 / BH2 / BHG 离线检查：结构检查 + 用小型求值器实际执行命令源码（CAD 函数用桩替代）。

场景模拟一根电缆两端分两次框选：
  1. 起点柜“1号主变保护柜”首次编号（前缀 1B、从 101 开始），含录波 130、公用测控 131、
     同终点多根 A/B、已手工编号的记入、芯线缺原理号的无法编号；
  2. 对端“主变测控柜1”：按记录填号、两端编号不一致标红、编号被另一根电缆占用标红、
     顺序号排到 130/131 时询问（跳过 130、照常使用 131）；
  3. 两位数起始号 01 → DS-01、DS-02；
  4. 记录文件写入失败时不改图。
  5. BHG 以图为准改记录（原编号存为旧编号）、“未编号”删除记录、拒绝占用他人编号；
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
            if c == '#':
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
    'nth': lambda i, a: a[i] if a and 0 <= i < len(a) else None,
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


SPECIAL = {'vl-remove-if': sp_remove_if, 'aa:merge-sort': sp_merge_sort, 'mapcar': sp_mapcar, 'vl-every': sp_every,
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
c.add_line('b5', 30, '柜Y', '1B-101A', ['135'])                     # 编号属于另一根 → 冲突，不改记录
c.install('主变测控柜1')
c.ents['b2_num']['color'] = 1
c.run('c:bhg')
assert rec_of(FILES, '1B-101C') and rec_of(FILES, '1B-101C')[0][6] == '1B-101B', FILES[PATH]
assert not rec_of(FILES, '1B-101B'), FILES[PATH]
assert c.color('b2') == 7 and c.color('b5') == 1 and c.selected == ['b5_num'], (c.color('b2'), c.selected)
assert any('编号已被另一根电缆使用' in t for _, t in c.markers), c.markers
assert all(len(l.split('\t')) == 7 for l in FILES[PATH]), FILES[PATH]
print('PASS: 场景5 BHG 改记录、存旧编号、删记录、拒绝占用他人编号')

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
c.add_line('g2', 45, '公用测控柜2', 'DS-06', ['L2', 'N2'])        # 终点和原理号都变了 → 仍算冲突
c.install('I区通信网关机柜')
c.ents['g1_num']['color'] = 1
c.run('c:bhg')
assert rec_of(GW, 'SML-20') and rec_of(GW, 'SML-20')[0][2] == '公用测控柜' and rec_of(GW, 'SML-20')[0][6] == '', GW[PATH]
assert len(rec_of(GW, 'SML-20')) == 1 and rec_of(GW, 'SML-21') and rec_of(GW, 'DS-06')[0][2] == '同步时钟主机柜', GW[PATH]
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
c.add_line('y2', 45, '同步时钟主机柜', 'DS-08', ['L2', 'N2'])    # 起点柜和原理号都不同 → 仍是冲突
c.install('智能有功控制装置柜')
c.ents['y1_num']['color'] = 1
c.run('c:bhg')
r = rec_of(YG, 'SML-25')
assert len(r) == 1 and sorted(r[0][1:3]) == sorted(['智能有功控制装置柜', '电能质量监测柜']), YG[PATH]
assert c.color('y1') == 7 and c.selected == ['y2_num'] and rec_of(YG, 'DS-08')[0][1] == '电能质量监测柜', (c.selected, YG[PATH])
print('PASS: 场景8b 起点柜改名的同一根电缆由 BHG 更正记录；两样都变的仍报冲突')
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
c = Cad(F20)                                   # 原主人的新编号属于选择外的电缆（冲突）→ 连锁撤回
c.add_line('t1', 50, '35kV 2#站用变进线柜', '2PMU-145', ['2ZYB-A442', '2ZYB-N441'])
c.add_line('t2', 45, '35kV 2#SVG进线柜', '2PMU-147', ['2SVG-A442', '2SVG-N441'])
c.install('宽频同步相量测量采集柜')
c.run('c:bhg')
assert F20[PATH] == SW and sorted(c.selected) == ['t1_num', 't2_num'], (c.selected, F20[PATH])
assert any('那根电缆本次没有改用别的编号' in t for _, t in c.markers), c.markers
assert any('记录改为图上编号 0 根' in o and '编号冲突 2 根' in o for o in c.out), c.out
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
print('PASS: 场景20 BHG 同次框选互换/挪用编号：记录按图互换并存旧编号；原主人没改号时撤回并标冲突（含连锁）')
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
print('ALL PASS: check_bh_static')

