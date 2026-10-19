"""Offline SS/MM snap + ortho-correction regression; executes the real LISP AST, never connects to CAD."""
import math
import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from lsp_common import defun_forms, parse, read_source  # noqa: E402


class Lisp:
    def __init__(self, funcs, builtins):
        self.funcs, self.builtins = funcs, builtins

    def atom(self, x, env):
        if not isinstance(x, str):
            return x
        if x.startswith('"'):
            return x[1:-1]
        if x == 'nil':
            return None
        if x == 't':
            return True
        try:
            return float(x) if any(c in x for c in '.e') else int(x)
        except ValueError:
            return env[x]

    def quoted(self, x):
        if isinstance(x, list):
            return [self.quoted(i) for i in x] or None
        if x.startswith('"'):
            return x[1:-1]
        try:
            return float(x) if any(c in x for c in '.e') else int(x)
        except ValueError:
            return x

    def ev(self, x, env):
        if not isinstance(x, list):
            return self.atom(x, env)
        h, *a = x
        if h == 'quote':
            return self.quoted(a[0])
        if h == 'setq':
            v = None
            for n, e in zip(a[::2], a[1::2]):
                v = env[n] = self.ev(e, env)
            return v
        if h == 'if':
            if self.ev(a[0], env) is not None:
                return self.ev(a[1], env)
            return self.ev(a[2], env) if len(a) > 2 else None
        if h == 'cond':
            for c in a:
                v = self.ev(c[0], env)
                if v is not None:
                    for e in c[1:]:
                        v = self.ev(e, env)
                    return v
            return None
        if h == 'progn':
            v = None
            for e in a:
                v = self.ev(e, env)
            return v
        if h == 'and':
            v = True
            for e in a:
                v = self.ev(e, env)
                if v is None:
                    return None
            return True
        if h == 'or':
            for e in a:
                if self.ev(e, env) is not None:
                    return True
            return None
        if h == 'while':
            while self.ev(a[0], env) is not None:
                for e in a[1:]:
                    self.ev(e, env)
            return None
        if h == 'repeat':
            for _ in range(int(self.ev(a[0], env))):
                for e in a[1:]:
                    self.ev(e, env)
            return None
        if h == 'foreach':
            for item in self.ev(a[1], env) or []:
                env[a[0]] = item
                for e in a[2:]:
                    self.ev(e, env)
            return None
        if h == 'function' or h == 'lambda':
            return x
        args = [self.ev(e, env) for e in a]
        return self.call(h, args, env)

    def call(self, h, args, env):
        if isinstance(h, list):  # quoted lambda
            params = [p for p in h[1] if p != '/']
            for p, v in zip(params, args):
                env[p] = v
            v = None
            for e in h[2:]:
                v = self.ev(e, env)
            return v
        if h in self.builtins:
            return self.builtins[h](*args)
        if h in self.funcs:
            f = self.funcs[h]
            local = dict(env)  # dynamic scope approximation: copy caller env
            params = f[2]
            names = params[:params.index('/')] if '/' in params else params
            for n in params:
                if n != '/':
                    local[n] = None
            for n, v in zip(names, args):
                local[n] = v
            v = None
            for e in f[3:]:
                v = self.ev(e, local)
            return v
        if h == 'mapcar':
            fn, *lists = args
            return [self.call(fn, list(t), env) for t in zip(*[l or [] for l in lists])] or None
        raise AssertionError('unsupported ' + h)


def nil(v):
    return None if v is False or v == [] else v


def equal(a, b, tol=0):
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(a - b) <= tol
    if isinstance(a, (list, tuple)) and isinstance(b, (list, tuple)):
        return len(a) == len(b) and all(equal(x, y, tol) for x, y in zip(a, b))
    return a == b


def base_builtins():
    return {
        'car': lambda x: x[0] if x else None,
        'cdr': lambda x: (x[1] if isinstance(x, tuple) else (x[1:] or None)) if x else None,
        'cadr': lambda x: x[1] if x and len(x) > 1 else None,
        'caddr': lambda x: x[2] if x and len(x) > 2 else None,
        'cons': lambda a, b: [a] + (b or []) if isinstance(b, list) or b is None else (a, b),
        'list': lambda *a: list(a) or None,
        'reverse': lambda x: list(reversed(x)) if x else None,
        'member': lambda a, l: nil([i for i in (l or []) if i == a] and l[l.index(a):]),
        'assoc': lambda k, l: next((p for p in (l or []) if isinstance(p, tuple) and p[0] == k), None),
        'listp': lambda x: True if x is None or isinstance(x, list) else None,
        'null': lambda x: True if x is None else None,
        'not': lambda x: True if x is None else None,
        'equal': lambda a, b, t=0: True if equal(a, b, t) else None,
        'abs': abs,
        '-': lambda *a: a[0] - sum(a[1:]) if len(a) > 1 else -a[0],
        '+': lambda *a: sum(a),
        '1+': lambda x: x + 1,
        '>': lambda a, b: True if a > b else None,
        '<': lambda a, b: True if a < b else None,
        '>=': lambda a, b: True if a >= b else None,
        '=': lambda a, b: True if a == b else None,
        '/=': lambda a, b: True if a != b else None,
        'distance': lambda p, q: math.dist(p[:2] + [p[2] if len(p) > 2 else 0], q[:2] + [q[2] if len(q) > 2 else 0]),
        'logand': lambda a, b: a & b,
        'strcat': lambda *a: ''.join(a),
        'princ': lambda *a: None,
        'trans': lambda p, a, b, disp=None: list(p),
    }


class World:
    """Tiny drawing: entities with points; native commands translate/stretch them."""

    def __init__(self, ents, user_pick):
        self.ents = ents          # name -> dict(type, pts, inside flags)
        self.user_pick = user_pick
        self.active = 0
        self.pending = None
        self.lastpoint = None
        self.log = []
        self.vars = {'CMDACTIVE': 0}

    def entget(self, n):
        e = self.ents[n]
        ed = [(-1, n), (0, e['type'])]
        for code, p in e['pts']:
            ed.append((code, list(p)))
        return ed

    def entmod(self, ed):
        n = dict((p[0], p[1]) for p in ed if isinstance(p, tuple))[-1]
        self.ents[n]['pts'] = [(p[0], list(p[1])) for p in ed if isinstance(p, tuple) and p[0] in (10, 11, 12, 13, 14)]
        return ed

    def apply(self, cmd, ss, d):
        for n in ss:
            e = self.ents[n]
            new = []
            for i, (code, p) in enumerate(e['pts']):
                moved = cmd == '_.MOVE' or e['inside'][i]
                if moved and e.get('half') == i:
                    new.append((code, [p[k] + d[k] / 2 for k in range(3)]))
                elif moved:
                    new.append((code, [p[k] + d[k] for k in range(3)]))
                else:
                    new.append((code, p))
            e['pts'] = new

    def command(self, *args):
        if args == ('PAUSE',):
            pick = self.user_pick
            base = self.pending[1]
            p2 = [base[k] + pick[k] for k in range(3)] if pick != 'enter' else None
            d = pick if pick != 'enter' else base
            self.apply(self.pending[0], self.pending[2], d)
            self.lastpoint = p2 or base
            self.active = 0
            self.log.append(('drag', d))
            return None
        cmd, ss, _, _, p1, *rest = args
        if rest:
            p2 = rest[1]
            d = [p2[k] - p1[k] for k in range(3)]
            self.apply(cmd, ss, d)
            self.log.append((cmd, d))
            return None
        self.pending = (cmd, p1, ss)
        self.active = 1
        return None


def run(cmdname, ents, pick, base=(10.0, 20.0, 0.0)):
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    w = World(ents, pick)
    b = base_builtins()
    ss = list(ents)
    b.update({
        'sslength': lambda s: len(s), 'ssname': lambda s, i: s[i],
        'entget': w.entget, 'entmod': w.entmod, 'entnext': lambda n: None, 'entupd': lambda n: n,
        'setvar': lambda k, v: w.vars.__setitem__(k, v) if k != 'LASTPOINT' else setattr(w, 'lastpoint', v),
        'getvar': lambda k: w.active if k == 'CMDACTIVE' else (w.lastpoint if k == 'LASTPOINT' else w.vars.get(k)),
        'command': w.command,
    })
    lisp = Lisp(funcs, b)
    env = {'pause': 'PAUSE'}
    res = lisp.call('aa:ortho-drag', [cmdname, ss, list(base)], env)
    return res, w


def line(p, q, inside=(True, True), half=None):
    d = {'type': 'LINE', 'pts': [(10, list(p)), (11, list(q))], 'inside': inside}
    if half is not None:
        d['half'] = half
    return d


def pts(w, n):
    return [p for _, p in w.ents[n]['pts']]


def check():
    # MOVE exactly horizontal: no correction
    res, w = run('_.MOVE', {'a': line([0, 0, 0], [5, 0, 0])}, [30.0, 0.0, 0.0])
    assert res == 'ok' and len(w.log) == 1
    assert equal(pts(w, 'a'), [[30, 0, 0], [35, 0, 0]], 1e-9)
    # MOVE onto skewed snap point: dominant X kept, Y removed
    res, w = run('_.MOVE', {'a': line([0, 0, 0], [5, 0, 0]), 'b': line([1, 1, 0], [2, 2, 0])}, [30.0, 4.0, 0.0])
    assert res == 'fixed', res
    assert equal(pts(w, 'a'), [[30, 0, 0], [35, 0, 0]], 1e-9) and equal(pts(w, 'b'), [[31, 1, 0], [32, 2, 0]], 1e-9)
    # MOVE dominant Y, plus Z from 3D snap removed
    res, w = run('_.MOVE', {'a': line([0, 0, 0], [5, 0, 0])}, [3.0, -40.0, 2.0])
    assert res == 'fixed' and equal(pts(w, 'a'), [[0, -40, 0], [5, -40, 0]], 1e-9)
    # MOVE Enter at second point (base used as displacement) is undone
    res, w = run('_.MOVE', {'a': line([0, 0, 0], [5, 0, 0])}, 'enter')
    assert res == 'enter' and equal(pts(w, 'a'), [[0, 0, 0], [5, 0, 0]], 1e-9)
    # STRETCH partial (only end point inside crossing), skewed snap -> restore + re-stretch projected
    ents = {'a': line([0, 0, 0], [5, 0, 0], (False, True)), 'c': line([5, 0, 0], [5, 9, 0], (True, True))}
    res, w = run('_.STRETCH', ents, [12.0, 3.0, 0.0])
    assert res == 'fixed', res
    assert equal(pts(w, 'a'), [[0, 0, 0], [17, 0, 0]], 1e-9) and equal(pts(w, 'c'), [[17, 0, 0], [17, 9, 0]], 1e-9)
    assert w.log[-1] == ('_.STRETCH', [12.0, 0.0, 0.0]), w.log
    # STRETCH with a half-shift point (dimension text) still detects true vector by majority
    ents = {'a': line([0, 0, 0], [5, 0, 0], (True, True)), 'b': line([0, 1, 0], [5, 1, 0], (True, True)),
            'd': line([0, 2, 0], [5, 2, 0], (True, True), half=1)}
    res, w = run('_.STRETCH', ents, [-2.0, 18.0, 0.0])
    assert res == 'fixed' and w.log[-1] == ('_.STRETCH', [0.0, 18.0, 0.0]), w.log
    # STRETCH vertical exact, typed distance: unchanged
    res, w = run('_.STRETCH', {'a': line([0, 0, 0], [0, 5, 0], (False, True))}, [0.0, 25.0, 0.0])
    assert res == 'ok' and equal(pts(w, 'a'), [[0, 0, 0], [0, 30, 0]], 1e-9)
    # STRETCH Enter: restored, no re-stretch
    res, w = run('_.STRETCH', {'a': line([0, 0, 0], [0, 5, 0], (False, True))}, 'enter')
    assert res == 'enter' and equal(pts(w, 'a'), [[0, 0, 0], [0, 5, 0]], 1e-9) and len(w.log) == 1
    # Zero displacement
    res, w = run('_.MOVE', {'a': line([0, 0, 0], [5, 0, 0])}, [0.0, 0.0, 0.0])
    assert res is None
    print('PASS SS/MM ortho osnap: 9 actual-AST scenarios (exact axis, skew projection X/Y/Z, '
          'stretch restore+redo, majority vector, Enter guard, zero move)')


def restore_case(orig, model):
    """model 'strip': AUTOSNAP polar bit is dropped while ortho on; 'flip': setting polar turns ortho off."""
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    state = {'CMDECHO': 0, 'DRAGMODE': 2, 'OSMODE': orig['OSMODE'], 'AUTOSNAP': orig['AUTOSNAP'] & ~8,
             'SNAPMODE': 0, 'SNAPANG': 0.0, 'ORTHOMODE': 1}

    def setvar(k, v):
        if k == 'ORTHOMODE' and v == 1:
            state['AUTOSNAP'] &= ~8
        if k == 'AUTOSNAP' and v & 8 and state['ORTHOMODE'] == 1:
            if model == 'strip':
                v &= ~8
            else:
                state['ORTHOMODE'] = 0
        state[k] = v
    b = base_builtins()
    b['vl-catch-all-apply'] = lambda f, args: setvar(*args)
    saved = [(k, orig[k]) for k in ('CMDECHO', 'DRAGMODE', 'OSMODE', 'AUTOSNAP', 'SNAPMODE', 'SNAPANG', 'ORTHOMODE')]
    Lisp(funcs, b).call('aa:ortho-restore-vars', [saved], {})
    assert state == orig, (orig, model, state)


def check_restore():
    for model in ('strip', 'flip'):
        restore_case({'CMDECHO': 1, 'DRAGMODE': 0, 'OSMODE': 4133, 'AUTOSNAP': 63,
                      'SNAPMODE': 1, 'SNAPANG': 0.3, 'ORTHOMODE': 0}, model)
        restore_case({'CMDECHO': 1, 'DRAGMODE': 2, 'OSMODE': 0, 'AUTOSNAP': 55,
                      'SNAPMODE': 0, 'SNAPANG': 0.0, 'ORTHOMODE': 1}, model)
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    for c in ('c:ss', 'c:mm', 'c:ll'):
        body = repr(funcs[c])
        assert body.count("'aa:ortho-restore-vars', 'saved-vars'") == 2, c
        assert "'setvar', ['list', ['car', 'item'], ['cdr', 'item']]" not in body, c
    print('PASS SS/MM/LL restore: polar tracking (AUTOSNAP bit 8) and ORTHOMODE restored under both interlock models')


class SsMmOrthoOsnapTests(unittest.TestCase):
    def test_ss_mm_ortho_osnap(self):
        check()
        check_restore()


if __name__ == '__main__':
    check()
    check_restore()
