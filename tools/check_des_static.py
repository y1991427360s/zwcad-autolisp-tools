"""Offline DES geometry regression using the actual LISP predicate (no CAD)."""
import math
import operator
from functools import reduce

from check_fdx_static import ARITY, SOURCE, parse, walk


FORMS = {f[1]: f for f in parse(SOURCE.read_text(encoding='utf-8'))
         if isinstance(f, list) and f[:1] == ['defun']
         and (f[1].startswith('des:') or f[1] == 'c:des')}


def call(fn, args, env):
    if isinstance(fn, list) and fn[0] == 'lambda':
        scope = env | dict(zip(fn[1], args))
        return evaluate(fn[2], scope)
    if fn in FORMS:
        form = FORMS[fn]
        signature = form[2]
        split = signature.index('/') if '/' in signature else len(signature)
        scope = env | dict.fromkeys(signature[split + 1:])
        scope.update(zip(signature[:split], args))
        value = None
        for expr in form[3:]:
            value = evaluate(expr, scope)
        return value
    builtins = {
        '+': lambda *xs: sum(xs),
        '-': lambda *xs: reduce(operator.sub, xs),
        '*': operator.mul, '/': operator.truediv,
        '>': operator.gt, '<=': operator.le,
        'min': min, 'max': max,
        'nth': lambda i, xs: xs[i], 'car': lambda xs: xs[0],
        'cdddr': lambda xs: xs[3:],
        'equal': lambda a, b, tol: a == b,
        'distance': math.dist,
        'apply': lambda f, xs: call(f, xs, env),
        'mapcar': lambda f, *xs: [call(f, list(v), env) for v in zip(*xs)],
    }
    return builtins[fn](*args)


def evaluate(expr, env):
    if not isinstance(expr, list):
        if expr in env:
            return env[expr]
        if expr == 'nil':
            return None
        try:
            return float(expr) if any(c in expr for c in '.e') else int(expr)
        except ValueError:
            return expr
    head, *args = expr
    if head == 'quote':
        return args[0]
    if head == 'if':
        return evaluate(args[1] if evaluate(args[0], env) else args[2], env)
    if head == 'and':
        return all(evaluate(a, env) for a in args)
    if head == 'setq':
        value = None
        for name, val in zip(args[::2], args[1::2]):
            value = env[name] = evaluate(val, env)
        return value
    if head == 'progn':
        value = None
        for arg in args:
            value = evaluate(arg, env)
        return value
    return call(head, [evaluate(a, env) for a in args], env)


def record(p, q, thickness=0):
    return [p + q + [thickness, 0, 0, 1], None, p, q, math.dist(p, q)]


def check():
    for form in FORMS.values():
        for node in walk(form[3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                low, high = ARITY[node[0]]
                assert low <= len(node) - 1 <= high, node
    a = record([0, 0, 0], [10, 0, 0])
    cases = [
        ('contained', a, record([2, 0, 0], [5, 0, 0]), True),
        ('partial', a, record([8, 0, 0], [12, 0, 0]), True),
        ('reversed', a, record([5, 0, 0], [2, 0, 0]), True),
        ('endpoint', a, record([10, 0, 0], [12, 0, 0]), False),
        ('disjoint', a, record([11, 0, 0], [12, 0, 0]), False),
        ('crossing', a, record([5, -1, 0], [5, 1, 0]), False),
        ('parallel', a, record([2, 0.01, 0], [5, 0.01, 0]), False),
        ('elevation', a, record([2, 0, 1], [5, 0, 1]), False),
        ('thickness', a, record([2, 0, 0], [5, 0, 0], 1), False),
        ('zero', a, record([2, 0, 0], [2, 0, 0]), False),
        ('vertical', record([0, 0, 0], [0, 10, 0]),
         record([0, 2, 0], [0, 5, 0]), True),
        ('diagonal3d', record([-5, -5, -5], [5, 5, 5]),
         record([-2, -2, -2], [2, 2, 2]), True),
    ]
    for name, first, second, expected in cases:
        for left, right in ((first, second), (second, first)):
            result = call('des:overlap-p', [left, right, 1e-8], {})
            assert bool(result) == expected, (name, result)
    print(f'PASS: DES syntax and {len(cases)} geometry cases in both directions')


if __name__ == '__main__':
    check()
