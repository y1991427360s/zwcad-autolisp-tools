"""极简 AutoLISP 子集解释器，只用于离线跑 HWT 的纯布局函数。"""
import math
import re

TOK = re.compile(r'"(?:[^"\\]|\\.)*"|;[^\n]*|[()\']|[^\s()\'";]+')


class Sym(str):
    pass


def tokenize(s):
    return [t for t in TOK.findall(s) if not t.startswith(';')]


def parse(toks):
    pos = 0

    def datum():
        nonlocal pos
        t = toks[pos]
        pos += 1
        if t == '(':
            out = []
            while toks[pos] != ')':
                out.append(datum())
            pos += 1
            return out
        if t == "'":
            return [Sym('quote'), datum()]
        if t.startswith('"'):
            return t[1:-1].replace('\\"', '"')
        if re.fullmatch(r'-?\d+', t):
            return int(t)
        if re.fullmatch(r'-?(\d+\.\d*|\.\d+)([eE]-?\d+)?', t):
            return float(t)
        return Sym(t.lower())

    out = []
    while pos < len(toks):
        out.append(datum())
    return out


FUN = {}
G = {}


def truthy(v):
    return v is not None and v != [] and v is not False


def lisp_div(*a):
    r = a[0]
    for b in a[1:]:
        r = int(r / b) if isinstance(r, int) and isinstance(b, int) else r / b
    return r


def lisp_rem(a, b):
    r = math.fmod(a, b)
    return r if isinstance(a, float) or isinstance(b, float) else int(r)


B = {
    '+': lambda *a: sum(a), '-': lambda a, *b: (-a if not b else a - sum(b)),
    '*': lambda *a: math.prod(a), '/': lisp_div, '1+': lambda a: a + 1, '1-': lambda a: a - 1,
    'rem': lisp_rem, '=': lambda a, b: a == b, '<': lambda a, b: a < b, '>': lambda a, b: a > b,
    '<=': lambda a, b: a <= b, '>=': lambda a, b: a >= b, 'list': lambda *a: list(a),
    'cons': lambda a, b: [a] + (b or []) if isinstance(b, (list, type(None))) else (a, b),
    'car': lambda a: a[0] if a else None, 'cdr': lambda a: a[1:] if a else [],
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'append': lambda *a: sum([list(x or []) for x in a], []),
    'reverse': lambda a: list(reversed(a or [])), 'length': lambda a: len(a or []),
    'strcat': lambda *a: ''.join(a), 'itoa': lambda a: str(a),
    'null': lambda a: not truthy(a), 'not': lambda a: not truthy(a), 'abs': abs, 'float': float,
}


def setvar(name, v, env):
    for e in env:
        if name in e:
            e[name] = v
            return
    G[name] = v


def ev(x, env):
    if isinstance(x, Sym):
        if x == 't':
            return True
        if x == 'nil':
            return None
        for e in env:
            if x in e:
                return e[x]
        return G.get(x)
    if not isinstance(x, list):
        return x
    if not x:
        return None
    h = x[0]
    if h == 'quote':
        return x[1]
    if h == 'setq':
        v = None
        for i in range(1, len(x), 2):
            v = ev(x[i + 1], env)
            setvar(x[i], v, env)
        return v
    if h == 'if':
        if truthy(ev(x[1], env)):
            return ev(x[2], env)
        return ev(x[3], env) if len(x) > 3 else None
    if h == 'cond':
        for c in x[1:]:
            v = ev(c[0], env)
            if truthy(v):
                for f in c[1:]:
                    v = ev(f, env)
                return v
        return None
    if h == 'while':
        v = None
        while truthy(ev(x[1], env)):
            for f in x[2:]:
                v = ev(f, env)
        return v
    if h == 'foreach':
        v = None
        for it in (ev(x[2], env) or []):
            fr = {x[1]: it}
            for f in x[3:]:
                v = ev(f, [fr] + env)
        return v
    if h == 'progn':
        v = None
        for f in x[1:]:
            v = ev(f, env)
        return v
    if h == 'and':
        for f in x[1:]:
            if not truthy(ev(f, env)):
                return None
        return True
    if h == 'or':
        for f in x[1:]:
            if truthy(ev(f, env)):
                return True
        return None
    if h == 'defun':
        params = x[2]
        sl = params.index('/') if '/' in params else len(params)
        FUN[x[1]] = (params[:sl], params[sl + 1:], x[3:])
        return x[1]
    args = [ev(a, env) for a in x[1:]]
    if h in FUN:
        ps, ls, body = FUN[h]
        if len(args) != len(ps):
            raise TypeError(f'{h}: expected {len(ps)} args, got {len(args)}')
        fr = {p: a for p, a in zip(ps, args)}
        fr.update({l: None for l in ls})
        v = None
        for f in body:
            v = ev(f, [fr])  # AutoLISP 动态作用域：这里只需要本函数和全局
        return v
    if h in B:
        return B[h](*args)
    raise NameError('undefined function ' + h)


def load_defuns(src, prefix=''):
    """只加载 defun / 顶层 setq，跳过命令本体等需要 CAD 的代码。"""
    for f in parse(tokenize(src)):
        if isinstance(f, list) and f and f[0] == 'defun' and str(f[1]).startswith(prefix):
            ev(f, [])


def call(expr):
    return ev(parse(tokenize(expr))[0], [])
