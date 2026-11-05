"""HDDZ（核对原理图与端子图的端子—原理号对应）离线检查。

1. 结构：命令顶层定义、命令框架局部变量、undo 配对、setq 变量均已声明、不用 vl-sort。
2. 用小型求值器实际执行 hddz:analyze / hddz:findings（CAD 函数不涉及），场景：
   - ZDDLH 横排：原理号与端子号上下对应，端子名 YD 在左侧；
   - ZDDLS 竖排：同一份数据整体顺时针转 90°，结果必须和横排一致；
   - 同一排两块端子排 YD、ZD 端子号相同，靠端子名区分；
   - 端子图没框端子名时按端子号对应，同号多块时报缺；
   - 原理图上下排列（整行只有原理号）、原理号在端子左边、全角冒号和空格。
"""
import math
import re
import sys
from functools import cmp_to_key
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lsp_common import ARITY, SOURCE, defun_forms, parse, read_source, walk  # noqa: E402

_, TEXT = read_source(SOURCE)
FORMS = parse(TEXT)
FUNCS = {f[1]: f for f in defun_forms(FORMS) if isinstance(f[1], str)}

# ---------------------------------------------------------------- 结构检查
CMD_LOCALS = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
HD = {k: v for k, v in FUNCS.items() if k.startswith('hddz:') or k == 'c:hddz'}
assert 'c:hddz' in HD, 'c:HDDZ 必须是顶层定义'
assert CMD_LOCALS <= set(FUNCS['c:hddz'][2]), 'c:HDDZ 局部变量缺少命令框架变量'
for name, form in HD.items():
    declared = set(x for x in form[2] if x != '/')
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
calls = [n[0] for n in walk(FUNCS['c:hddz']) if isinstance(n[0], str)]
assert calls.count('aa:cmd-begin') == 1 and calls.count('aa:cmd-end') == 1
assert ';;;   - HDDZ  :' in TEXT, '文件开头命令清单缺少 HDDZ'
assert re.search(r';;; 功能: [^\r\n]+\r?\n\(defun c:HDDZ ', TEXT), 'c:HDDZ 上方缺少功能说明'
run_calls = [n[0] for n in walk(FUNCS['hddz:run']) if isinstance(n[0], str)]
for f in ('aa:rep-begin', 'aa:rep-item', 'aa:rep-end', 'hddz:clear-marks', 'hddz:draw-mark'):
    assert f in run_calls, f'hddz:run 应调用 {f}'
assert 'entmod' not in str(HD) and 'vla-put-textstring' not in str(HD).lower(), 'HDDZ 只读，不能改原文字'
print('PASS: HDDZ 结构检查')


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
        return [strip_quote(x) for x in v]
    if isinstance(v, str) and v.startswith('"'):
        return unescape(v)
    return v


def lt(v):
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
            return int(v) if v.is_integer() and '.' not in node and 'e' not in node.lower() else v
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
    if op in ('and', 'or'):
        for a in args:
            res = evaluate(a, env)
            if op == 'and' and not lt(res):
                return None
            if op == 'or' and lt(res):
                return True
        return True if op == 'and' else None
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
    assert len(args) == len([p for p in form[2][:form[2].index('/')] ] if '/' in form[2] else form[2]), (fn, args)
    return call(['lambda', form[2]] + form[3:], args, env)


def truth(v):
    return True if v else None


def lcons(a, b):
    return [a] + b if isinstance(b, list) else [a] if b is None else (a, b)


def wcmatch(s, pat):
    def one(p):
        rx = ''.join('.*' if c == '*' else '.' if c == '?' else re.escape(c) for c in p)
        return re.fullmatch(rx, s, re.S) is not None
    return truth(any(one(p) for p in pat.split(',')))


def vl_string_position(code, s, start=None, from_end=None):
    i = s.rfind(chr(code)) if from_end else s.find(chr(code), start or 0)
    return i if i >= 0 else None


NATIVE = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda *a: math.prod(a), '/': lambda a, b: a / b,
    'abs': abs, 'min': lambda *a: min(a), 'max': lambda *a: max(a), '1+': lambda x: x + 1,
    '<': lambda *a: truth(all(a[i] < a[i + 1] for i in range(len(a) - 1))),
    '<=': lambda *a: truth(all(a[i] <= a[i + 1] for i in range(len(a) - 1))),
    '>': lambda a, b: truth(a > b), '>=': lambda a, b: truth(a >= b),
    '=': lambda a, b: truth(a == b), '/=': lambda a, b: truth(a != b),
    'not': lambda x: truth(not lt(x)), 'null': lambda x: truth(not lt(x)),
    'car': lambda a: a[0] if a else None,
    'cdr': lambda a: a[1] if isinstance(a, tuple) else ((a[1:] or None) if a else None),
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'caddr': lambda a: a[2] if a and len(a) > 2 else None,
    'cadddr': lambda a: a[3] if a and len(a) > 3 else None,
    'nth': lambda i, a: a[i] if a and 0 <= i < len(a) else None,
    'last': lambda a: a[-1] if a else None,
    'list': lambda *a: list(a) or None, 'cons': lcons,
    'append': lambda *a: [x for p in a for x in (p or [])] or None,
    'reverse': lambda a: list(reversed(a or [])) or None,
    'length': lambda a: len(a or []),
    'member': lambda x, a: a[a.index(x):] if a and x in a else None,
    'assoc': lambda k, a: next((v for v in (a or []) if isinstance(v, (list, tuple)) and v[0] == k), None),
    'subst': lambda new, old, a: [new if x == old else x for x in a],
    'vl-remove': lambda x, a: [v for v in (a or []) if v != x] or None,
    'strcat': lambda *a: ''.join(a), 'substr': lambda s, i, n=None: s[i - 1:] if n is None else s[i - 1:i - 1 + n],
    'strcase': lambda s: s.upper(), 'itoa': lambda n: str(n), 'chr': lambda n: chr(n),
    'vl-string-position': vl_string_position,
    'aa:str-replace-all': lambda old, new, s: s.replace(old, new),
    'wcmatch': wcmatch,
    'distance': lambda p, q: math.dist(p[:2], q[:2]),
}


def sp_sort(args, env):
    fn = args[1]

    def cmp(a, b):
        if lt(call(fn, [a, b], env)):
            return -1
        if lt(call(fn, [b, a], env)):
            return 1
        return 0
    return sorted(args[0] or [], key=cmp_to_key(cmp)) or None


SPECIAL = {
    'aa:merge-sort': sp_sort,
    'mapcar': lambda args, env: [call(args[0], [x], env) for x in (args[1] or [])] or None,
    'vl-every': lambda args, env: truth(all(lt(call(args[0], [x], env)) for x in (args[1] or []))),
}


# ---------------------------------------------------------------- 场景
def item(en, x, y, s, kind, w=3.0, h=3.0, th=3.0):
    return [en, float(x), float(y), th, s, kind, float(w), float(h)]


def run(sitems, titems):
    an = call('hddz:analyze', [sitems, titems], GLOBAL)
    fs = call('hddz:findings', [an], GLOBAL)
    found = {(f[1], f[3].split('：')[0]) for f in fs[0] or []}
    counts = dict(fs[1])
    return an, fs, found, counts


def zddlh_tb(prefix='', name='YD', x0=0.0, y0=0.0, wires=None, with_name=True):
    """模拟 ZDDLH：端子号竖写在 y0+37.5，名称在左端 x0+5，端子格宽 5；wires {端子号: [(原理号, 上/下)]}。"""
    out = []
    if with_name:
        out.append(item(prefix + 'N', x0 + 5, y0 + 37.5, name, 'N', w=3, h=6))
    for k in range(1, 15):
        x = x0 + 10 + 2.5 + 5 * (k - 1)
        out.append(item(f'{prefix}t{k}', x, y0 + 37.5, str(k), 'T', w=3, h=2 + len(str(k))))
        for j, (p, up) in enumerate((wires or {}).get(k, [])):
            dx = 1.5 * j - 0.75 * (len(wires[k]) - 1) if len(wires[k]) > 1 else 0.0
            plen = 2.0 * len(p)
            cy = y0 + 75 - 2 - plen / 2 if up else y0 + 2 + plen / 2
            out.append(item(f'{prefix}p{k}_{j}', x + dx, cy, p, 'P', w=3, h=plen))
    return out


def rotate_cw(items):
    """ZDDLS = ZDDLH 整体顺时针转 90°：(x, y) → (y, -x)，包围盒宽高互换。"""
    return [[it[0], it[2], -it[1], it[3], it[4], it[5], it[7], it[6]] for it in items]


def sch_rows(rows, x0=-300.0, y0=200.0, gap=8.0):
    """原理图剔出的文字：每行 (端子, 原理号...)，端子在左。"""
    out = []
    for i, row in enumerate(rows):
        y = y0 - gap * i
        out.append(item(f's{i}', x0, y, row[0], 'T', w=12))
        for j, p in enumerate(row[1:]):
            out.append(item(f's{i}p{j}', x0 + 25 + 25 * j, y, p, 'P', w=20))
    return out


WIRES = {4: [('2AW-901', True)], 5: [('2AW-903', True)], 6: [('2AW-905', True)],
         7: [('2AW-907', False)], 8: [('2AW-909', True), ('2AW-909', False)],
         9: [('2AW-911', True)], 10: [('2AW-913', True)], 12: [('2AW-999', True)]}
SCH = sch_rows([('YD:4', '2AW-901'), ('YD:5', '2AW-903'), ('YD:6', '2AW-905'), ('YD：7', '2aw-907'),
                ('YD:8', '2AW-909'), ('YD : 9', '2AW-911'), ('YD:10', '2AW-915'), ('YD:11', '2AW-917'),
                ('YD:13',)])

# 1. 横排
an, fs, found, counts = run(SCH, zddlh_tb(wires=WIRES))
assert ('原理号不一致', 'YD:10') in found, found
assert ('原理图没有', 'YD:12') in found, found
assert counts['一致'] == 7, counts                      # 4 5 6 7 8 9 13（13 两边都没有原理号）
assert counts['不一致'] == 2 and counts['原理号未对应端子'] == 0, counts   # YD:10 不一致、YD:11 未接线
print('PASS: 横排 ZDDLH 上下对应', counts)
H_FOUND = found

# 端子 11 在端子图里存在但没有原理号：应报“端子图未接线”，不是“缺端子”
assert ('端子图未接线', 'YD:11') in found, '端子图有这个端子但没原理号时应报未接线'

# 2. 竖排：整体顺时针转 90°，结果一致
an2, fs2, found2, counts2 = run(SCH, rotate_cw(zddlh_tb(wires=WIRES)))
assert found2 == H_FOUND and counts2 == counts, (found2 ^ H_FOUND, counts2)
print('PASS: 竖排 ZDDLS 左右对应，与横排结果一致')

# 3. 同一排两块端子排 YD、ZD 同号，靠端子名区分
tb = zddlh_tb('a', 'YD', 0, 0, {1: [('101', True)], 2: [('103', True)]}) + \
     zddlh_tb('b', 'ZD', 100, 0, {1: [('201', True)], 2: [('203', False)]})
sch = sch_rows([('YD:1', '101'), ('YD:2', '103'), ('ZD:1', '201'), ('ZD:2', '205')])
an, fs, found, counts = run(sch, tb)
assert counts['一致'] == 3 and ('原理号不一致', 'ZD:2') in found, (counts, found)
assert counts['原理号未对应端子'] == 0
print('PASS: 同排两块端子排按端子名区分')

# 4. 端子图没框端子名：按端子号对应；同号两块时无法区分 → 报缺
an, fs, found, counts = run(sch_rows([('YD:1', '101'), ('YD:2', '103')]),
                            zddlh_tb('a', 'YD', 0, 0, {1: [('101', True)], 2: [('104', True)]}, with_name=False))
assert counts['一致'] == 1 and ('原理号不一致', 'YD:2') in found, (counts, found)
an, fs, found, counts = run(sch_rows([('YD:1', '101')]),
                            zddlh_tb('a', 'YD', 0, 0, {1: [('101', True)]}, with_name=False) +
                            zddlh_tb('b', 'ZD', 0, 200, {1: [('101', True)]}, with_name=False))
assert ('端子图缺端子', 'YD:1') in found, found
print('PASS: 无端子名按端子号对应，同号不唯一时报缺')

# 5. 原理图：上下排列、原理号在端子左边、一行两组
s = [item('u1', 0, 100, 'YD:4', 'T'), item('u1p', 0, 95, '2AW-901', 'P'),
     item('u2', 0, 90, 'YD:5', 'T'), item('u2p', 0, 85, '2AW-903', 'P'),
     item('l1p', 100, 100, '2AW-905', 'P', w=20), item('l1', 130, 100, 'YD:6', 'T', w=12),
     item('r1', 200, 100, 'YD:7', 'T', w=12), item('r1p', 225, 100, '2AW-907', 'P', w=20),
     item('r2', 260, 100, 'YD:8', 'T', w=12), item('r2p', 285, 100, '2AW-909', 'P', w=20),
     item('far', 0, -500, '2AW-777', 'P')]
an, fs, found, counts = run(s, zddlh_tb(wires={k: WIRES[k] for k in (4, 5, 6, 7, 8)}))
assert counts['一致'] == 5 and counts['原理号未对应端子'] == 1, (counts, found)
assert ('原理号未对应端子', '原理图原理号 2AW-777 同一行和上方都没有端子号') in found, found
print('PASS: 原理图上下排列、原理号在左、一行多组；离群原理号报未对应')

# 6. 端子图里离开端子排的原理号报未对应；标记都有位置
tb = zddlh_tb(wires={4: [('2AW-901', True)]}) + [item('lone', 500, 500, '2AW-888', 'P')]
an, fs, found, counts = run(sch_rows([('YD:4', '2AW-901')]), tb)
assert counts['原理号未对应端子'] == 1 and counts['一致'] == 1, counts
for f in fs[0]:
    for m in f[4] or []:
        assert m[0] in ('T', 'C') and all(isinstance(v, float) for v in m[1:4]), m
print('PASS: 端子图离群原理号报未对应，标记数据完整')

# 7. 仿用户图2：两块 IB1D、IB2D 同号 1~8，原理号竖写在上方较远处，旁边有汉字说明“#1主变高压侧”（不参与），
#    原比例与整体放大 10 倍结果一致
PH = ['A4131', 'B4131', 'C4131', 'N4131', 'A4132', 'B4132', 'C4132', 'N4131']


def fig2(scale):
    out = []
    for b, (name, pre) in enumerate((('IB1D', '1YB'), ('IB2D', '2YB'))):
        x0 = b * 60.0
        out.append(item(f'n{b}', (x0 + 2) * scale, 0, name, 'N', w=3 * scale, h=8 * scale, th=3 * scale))
        for k, ph in enumerate(PH, 1):
            x = (x0 + 5 + 5 * k) * scale
            out.append(item(f't{b}{k}', x, 0, str(k), 'T', w=3 * scale, h=2 * scale, th=3 * scale))
            out.append(item(f'p{b}{k}', x, 23 * scale, f'{pre}-{ph}', 'P', w=3 * scale, h=18 * scale, th=3 * scale))
    return out


def fig1(scale):
    rows = [(f'{name}:{k}', f'{pre}-{ph}') for name, pre in (('IB1D', '1YB'), ('IB2D', '2YB'))
            for k, ph in enumerate(PH, 1)]
    rows[12] = ('IB2D:5', '2YB-A4133')               # 故意写错一个
    return [[it[0], it[1] * scale, it[2] * scale, 3.0 * scale, it[4], it[5], it[6] * scale, it[7] * scale]
            for it in sch_rows(rows)]


for sc in (1.0, 10.0):
    an, fs, found, counts = run(fig1(sc), fig2(sc))
    assert counts['一致'] == 15 and counts['不一致'] == 1 and ('原理号不一致', 'IB2D:5') in found, (sc, counts, found)
    assert counts['原理号未对应端子'] == 0 and counts['原理图没有'] == 0 and counts['端子图缺端子'] == 0, (sc, counts)
assert '(not (aa:has-chinese s))' in str(FUNCS['hddz:name-like-p']).replace("'", '').replace(',', '') or     'aa:has-chinese' in str(FUNCS['hddz:name-like-p']), '汉字说明不能当端子名'
print('PASS: 仿图2 两块同号端子排 IB1D/IB2D，原比例与放大 10 倍结果一致')
print('ALL HDDZ STATIC CHECKS PASS')
