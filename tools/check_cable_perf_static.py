"""Execute GTY/HDDL source AST offline; deterministic work counts, never CAD."""
from collections import Counter
import operator
import random

from lsp_common import defun_forms, parse, read_source, walk


# Frozen pre-optimization helpers. Kept here so the ignored backups directory
# is not required on another checkout; definitions match the byte backup.
BASELINE = """
(defun hddl:coord (rec axis / p)
  (setq p (if (and rec (= (type rec) 'LIST)) (caddr rec) nil))
  (if (and p (= (type p) 'LIST) (numberp (car p)) (numberp (cadr p)))
    (if (= axis 0) (car p) (cadr p)) 0.0))
(defun hddl:row-sort (a b / ya yb xa xb)
  (setq ya (hddl:coord a 1) yb (hddl:coord b 1)
        xa (hddl:coord a 0) xb (hddl:coord b 0))
  (if (> ya (+ yb 1.0)) T (if (< ya (- yb 1.0)) nil (< xa xb))))
(defun hddl:insert-sorted (rec sorted / head)
  (if (null sorted) (list rec)
    (if (hddl:row-sort rec (car sorted)) (cons rec sorted)
      (cons (car sorted) (hddl:insert-sorted rec (cdr sorted))))))
(defun hddl:sort (items / result rec)
  (setq result nil)
  (foreach rec items (setq result (hddl:insert-sorted rec result))) result)
(defun hddl:add-row (rec rows / y out hit row)
  (setq y (hddl:coord rec 1) out '() hit nil)
  (foreach row rows
    (if (and (not hit) (<= (abs (- y (hddl:coord (car row) 1))) 1.0))
      (progn (setq out (append out (list (append row (list rec)))) hit T))
      (setq out (append out (list row)))))
  (if hit out (append out (list (list rec)))))
"""


def truth(x):
    return x is not None and x is not False and x != []


def literal(x):
    if isinstance(x, list):
        return [literal(v) for v in x]
    if x.startswith('"'):
        return x[1:-1].replace('\\t', '\t').replace('\\r', '\r').replace('\\n', '\n')
    try:
        return float(x) if '.' in x or 'e' in x else int(x)
    except ValueError:
        return x


class Runner:
    """Small source evaluator with AutoLISP integer division and stable merging.

    Counts logical Lisp list visits/copies, excluding Python's list slicing costs.
    It interprets the repository's actual aa:merge-sort and comparison lambdas.
    """
    def __init__(self, funcs):
        self.funcs = funcs
        self.counts = Counter()
        self.mocks = {}

    def seq(self, forms, env):
        result = None
        for form in forms:
            result = self.eval(form, env)
        return result

    def call(self, name, values, env=None):
        env = {} if env is None else env
        if isinstance(name, list):
            assert name[0] == 'lambda', name
            signature, body = name[1], name[2:]
        elif name in self.mocks:
            return self.mocks[name](*values)
        elif name in self.funcs:
            self.counts['call:' + name] += 1
            signature, body = self.funcs[name][2], self.funcs[name][3:]
        else:
            return self.builtin(name, values, env)
        split = signature.index('/') if '/' in signature else len(signature)
        assert len(values) == split, (name, values, signature)
        scope = env | dict.fromkeys(signature[split + 1:])
        scope.update(zip(signature[:split], values))
        return self.seq(body, scope)

    def eval(self, expr, env):
        if not isinstance(expr, list):
            if expr == 'nil':
                return None
            if expr == 't':
                return True
            val = literal(expr)
            if expr.startswith('"') or isinstance(val, (int, float)):
                return val
            assert expr in env, ('Unsupported symbol', expr)
            return env[expr]
        if not expr:
            return None
        head, *args = expr
        if head in ('quote', 'function'):
            return literal(args[0])
        if head == 'setq':
            val = None
            for name, arg in zip(args[::2], args[1::2]):
                val = env[name] = self.eval(arg, env)
            return val
        if head == 'if':
            branch = 1 if truth(self.eval(args[0], env)) else 2
            return self.eval(args[branch], env) if branch < len(args) else None
        if head in ('and', 'or'):
            return (all if head == 'and' else any)(truth(self.eval(x, env)) for x in args)
        if head == 'cond':
            for clause in args:
                value = self.eval(clause[0], env)
                if truth(value):
                    return self.seq(clause[1:], env) if len(clause) > 1 else value
            return None
        if head == 'progn':
            return self.seq(args, env)
        if head == 'foreach':
            for item in self.eval(args[1], env) or []:
                self.counts['visits'] += 1
                env[args[0]] = item
                value = self.seq(args[2:], env)
            return None
        if head == 'while':
            guard = 0
            while truth(self.eval(args[0], env)):
                guard += 1
                assert guard < 100000, 'Nonterminating loop'
                self.seq(args[1:], env)
            return None
        values = [self.eval(arg, env) for arg in args]
        if isinstance(head, list):
            return self.call(head, values, env)
        return self.call(head, values, env)

    def builtin(self, name, v, env):
        def car(x):
            self.counts['visits'] += 1
            return x[0] if x else None

        def cdr(x):
            self.counts['visits'] += 1
            return x[1] if isinstance(x, tuple) else x[1:] if x else None

        if name == 'apply':
            return self.call(v[0], v[1], env)
        if name == 'vl-catch-all-apply':
            try:
                return self.call(v[0], v[1], env)
            except RuntimeError as exc:
                return exc
        if name == 'mapcar':
            self.counts['copies'] += len(v[1] or [])
            return [self.call(v[0], list(xs), env) for xs in zip(*(x or [] for x in v[1:]))]
        if name == 'cons':
            self.counts['copies'] += 1
            return [v[0]] + (v[1] or []) if v[1] is None or isinstance(v[1], list) else tuple(v)
        if name == 'append':
            self.counts['copies'] += sum(len(x or []) for x in v[:-1])
            return [item for xs in v for item in xs or []]
        if name == 'reverse':
            self.counts['copies'] += len(v[0] or [])
            return list(reversed(v[0] or []))
        if name == 'length':
            self.counts['visits'] += len(v[0] or [])
            return len(v[0] or [])
        if name == 'nth':
            self.counts['visits'] += min(v[0] + 1, len(v[1] or []))
            return v[1][v[0]] if v[1] and v[0] < len(v[1]) else None
        if name in ('car', 'cdr'):
            return (car if name == 'car' else cdr)(*v)
        if name.startswith('c') and name.endswith('r') and set(name[1:-1]) <= {'a', 'd'}:
            x = v[0]
            for step in reversed(name[1:-1]):
                x = (car if step == 'a' else cdr)(x)
            return x
        builtins = {
            '=': lambda a, b: a == b or not truth(a) and not truth(b), '/=': operator.ne,
            '<': operator.lt, '>': operator.gt, '<=': operator.le, '>=': operator.ge,
            '+': lambda *xs: sum(xs), '-': lambda a, *xs: a - sum(xs) if xs else -a,
            '*': operator.mul, '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) else a / b,
            '1+': lambda a: a + 1, '1-': lambda a: a - 1,
            'abs': abs, 'min': min, 'max': max, 'list': lambda *xs: list(xs),
            'not': lambda x: not truth(x), 'null': lambda x: not truth(x),
            'equal': lambda a, b, *tol: a == b,
            'numberp': lambda x: isinstance(x, (int, float)) and not isinstance(x, bool),
            'type': lambda x: 'list' if isinstance(x, list) else 'str' if isinstance(x, str) else 'real',
            'member': lambda x, xs: (xs[xs.index(x):] if x in (xs or []) else None),
            'strcase': lambda x: x.upper(), 'vl-string-trim': lambda chars, x: x.strip(chars),
            'chr': chr, 'vl-list->string': lambda xs: ''.join(map(chr, xs)),
            'vl-string-search': lambda sub, x: x.find(sub) if sub in x else None,
            'vl-string-subst': lambda new, old, x: x.replace(old, new, 1),
            'strlen': len, 'substr': lambda x, i, *n: x[i - 1:i - 1 + n[0]] if n else x[i - 1:],
            'strcat': lambda *xs: ''.join(xs), 'itoa': str, 'atoi': int,
            'wcmatch': lambda x, pat: x.isdigit() if pat == '#' else False,
            'vl-string-position': lambda char, x, start=None, reverse=False: x.rfind(chr(char)) if reverse else x.find(chr(char)),
            'assoc': lambda key, xs: next((x for x in xs or [] if x[0] == key), None),
            'subst': lambda new, old, xs: [new if x == old else x for x in xs],
            'vl-catch-all-error-p': lambda x: isinstance(x, Exception),
        }
        assert name in builtins, ('Unsupported call', name)
        return builtins[name](*v)


def item(i, x, y, text=None):
    return [str(i), str(i) if text is None else text, [x, y, 0.0], 2.5]


def legacy_gty_rows(items, tol):
    rows = []
    for rec in items:
        for i, row in enumerate(rows):
            if abs(rec[2][1] - row[0][2][1]) <= tol:
                rows[i] = [rec] + row
                break
        else:
            rows.insert(0, [rec])
    return rows


def legacy_hddl_rows(items, tol):
    rows = []
    for rec in items:
        for row in rows:
            if abs(rec[2][1] - row[0][2][1]) <= tol:
                row.append(rec)
                break
        else:
            rows.append([rec])
    return rows


def hddl_rows(runner, items):
    rows = []
    for rec in items:
        rows = runner.call('hddl:add-row', [rec, rows])
    return rows


def check():
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    old = Runner({f[1]: f for f in defun_forms(parse(BASELINE))})
    new = Runner(funcs)
    rng = random.Random(20261013)
    trials = 0
    for offset in (-10000.0, -1.0, 0.0, 10000.0):
        for tol in (0.0, 0.5, 1.0, 2.5):
            for _ in range(10):
                data = [item(i, rng.randint(-25, 25), offset + r * (tol + 3) + rng.random() * tol)
                        for r in range(12) for i in range(r * 5, r * 5 + 5)]
                rng.shuffle(data)
                for newest in (True, False):
                    packed = new.call('aa:gty-separated-rows', [data, tol, newest])
                    assert packed and packed[0]
                    expected = legacy_gty_rows(data, tol) if newest else legacy_hddl_rows(data, tol)
                    assert packed[1] == expected, (offset, tol, newest)
                trials += 1
    for data in ([item(0, 0, 0), item(1, 0, 1)],
                 [item(0, 0, -1), item(1, 0, 0)],
                 [item(0, 0, 0), item(1, 0, 1.0000001)]):
        for newest in (True, False):
            packed = new.call('aa:gty-separated-rows', [data, 1.0, newest])
            assert packed[1] == (legacy_gty_rows(data, 1) if newest else hddl_rows(old, data))
    for offset in (-10000, 0, 10000):
        chain = [item(i, i, offset + y) for i, y in enumerate((0.0, .75, 1.5))]
        assert new.call('aa:gty-separated-rows', [chain, 1.0, False]) is None
        for newest in (True, False):
            assert new.call('aa:gty-separated-rows', [chain, 1.0, newest]) is None
    for _ in range(100):
        data = [item(i, rng.randint(-10, 10), rng.uniform(-6, 6)) for i in range(25)]
        assert hddl_rows(new, data) == hddl_rows(old, data)
        assert new.call('hddl:sort', [data]) == old.call('hddl:sort', [data])
        rows = []
        for rec in data:
            rows = new.call('aa:gty-add-row', [rec, rows, 1.0])
        assert rows == legacy_gty_rows(data, 1.0)
    counterexample = [item('B', 1, 1.2), item('A', 2, 2), item('C', 0, .4)]
    assert [r[0] for r in new.call('hddl:sort', [counterexample])] == ['C', 'B', 'A']
    assert hddl_rows(new, counterexample) == hddl_rows(old, counterexample)
    for n in (1, 2, 3, 4, 5, 17, 32, 129):
        rows = [[item(i, i, 0)] for i in range(n)]
        tree = new.call('aa:gty-row-tree', [rows, n])
        for i, row in enumerate(rows):
            assert new.call('aa:gty-tree-item', [tree, i]) == row
    lookup = next(node for node in walk(funcs['c:gty'])
                  if node[:1] == ['aa:gty-tree-item'])
    for idx in (0, 999999, 1000000, 123456789):
        row = [item(i, i, 0, '1B|103' if i == 1 else '') for i in range(4)]
        key = new.call('aa:gty-build-sort-key', [row, idx])
        assert new.eval(lookup[2], {'key': key}) == idx
    rows = [[item(0, 0, i), item(1, 1, i, ident)]
            for i, ident in enumerate(('b', 'A', ' B ', '', 'a', 'C', 'b'))]
    expected = {}
    for row in rows:
        key = row[1][1].strip().upper()
        if key:
            expected.setdefault(key, []).append(row)
    groups = new.call('hddl:group-rows', [rows])
    assert {group[0]: group[1:] for group in groups} == expected
    check_gty_layout(new, funcs)
    check_principle_order(new)
    check_moves(new)
    check_issue_loop(new, funcs)
    check_spec_fixture(new, funcs)
    check_work(new, old)
    print(f'PASS: GTY/HDDL actual source AST; {trials} safe-row randomized cases, 100 fallback cases; '
          'tolerance boundaries, sort stability, row tree, long suffix, grouping, DXF/COM fallback and issue priorities.')


def check_moves(runner):
    calls = []
    runner.mocks['aa:gty-move-entity'] = lambda *xs: calls.append('com') or True
    ed = [(0, 'TEXT'), (10, [0, 0, 0]), (72, 0), (73, 0), (210, [0., 0., 1.])]
    runner.mocks['entget'] = lambda _: ed
    runner.mocks['entmod'] = lambda xs: calls.append(('entmod', xs)) or xs
    assert runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
    assert calls[0][0] == 'entmod' and [10, 1, 2, 0] in calls[0][1]
    assert len(calls) == 1
    calls.clear()
    assert runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [0, 0, 0]])
    assert not calls
    for code, value in ((0, 'MTEXT'), (72, 1), (72, 2), (72, 3), (72, 4), (72, 5),
                        (73, 1), (73, 2), (73, 3), (210, [0, 1, 0]), (210, [0, 0, -1]),
                        (360, 'dictionary'), (102, '{ACAD_REACTORS')):
        altered = [pair for pair in ed if pair[0] != code] + [(code, value)]
        runner.mocks['entget'] = lambda _, data=altered: data
        calls.clear()
        assert runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
        assert calls == ['com'], (code, value, calls)
    runner.mocks['entget'] = lambda _: [(0, 'TEXT'), (10, [0, 0, 0])]
    calls.clear()
    runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
    assert calls[0][0] == 'entmod' and len(calls) == 1
    runner.mocks['entmod'] = lambda xs: calls.append('locked-entmod') or None
    calls.clear()
    assert runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
    assert calls == ['locked-entmod', 'com']
    def fail(_):
        calls.append('failed-entmod')
        raise RuntimeError('locked layer mock')
    runner.mocks['entmod'] = fail
    calls.clear()
    assert runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
    assert calls == ['failed-entmod', 'com']
    runner.mocks['entget'] = lambda _: None
    calls.clear()
    runner.call('aa:gty-move-text-fast', ['e', [0, 0, 0], [1, 2, 0]])
    assert calls == ['com']


def check_principle_order(runner):
    for cable_id in ('1B-103', '2B-103'):
        a = [item(i, i, 0, txt) for i, txt in enumerate(
            ('柜A', cable_id, '柜B', 'KVVP', '3', 'X1:1', 'X2:2', 'X3:3'))]
        b = [item(i, i, -10, txt) for i, txt in enumerate(
            ('柜B', cable_id, '柜A', 'KVVP', '3', 'x3:3', ' X1:1 ', 'X2:2'))]
        assert not runner.call('hddl:tail-different-p', [a, b]), cable_id
        assert not runner.call('hddl:tail-duplicate-p', [a])
        assert not runner.call('hddl:tail-duplicate-p', [b])
        changed = [rec[:] for rec in b]
        changed[-1][1] = 'X9:9'
        assert runner.call('hddl:tail-different-p', [a, changed]), cable_id
        assert runner.call('hddl:tail-different-p', [a, b[:-1]]), cable_id
        repeated = [rec[:] for rec in b]
        repeated[-1][1] = repeated[-2][1]
        assert runner.call('hddl:tail-duplicate-p', [repeated]), cable_id


def check_issue_loop(runner, funcs):
    loop = next(node for node in walk(funcs['c:hddl']) if node[:3] == ['foreach', 'group', 'groups'])
    calls, marks = [], []
    for name in ('hddl:color-tail-duplicates', 'hddl:color-core-count-diff',
                 'hddl:color-tail-diffs', 'hddl:color-cabinet-diffs', 'hddl:color-cell'):
        runner.mocks[name] = lambda *args, name=name: calls.append(name) or True
    runner.mocks['hddl:make-marker'] = lambda rec, txt: marks.append(txt) or True
    row_a, row_b = [item('a', 0, 0)], [item('b', 0, 0)]
    for kind, mirror, count_diff, principles_diff, dup, nrows, color, label in (
        ('valid', True, False, False, False, 2, None, None),
        ('core', True, True, True, False, 2, 'hddl:color-core-count-diff', '[原理号数量不一致]'),
        ('principle', True, False, True, False, 2, 'hddl:color-tail-diffs', '[原理号不一致]'),
        ('cabinet', False, True, True, False, 2, 'hddl:color-cabinet-diffs', '[柜名不一致]'),
        ('id', False, False, False, False, 3, 'hddl:color-cell', '[电缆编号重复]'),
        ('duplicate', True, True, True, True, 2, 'hddl:color-tail-duplicates', '[原理号重复]'),
    ):
        runner.mocks['hddl:mirror-p'] = lambda *xs, result=mirror: result
        runner.mocks['hddl:tail-count'] = lambda row: 1 if row == row_a or not count_diff else 2
        runner.mocks['hddl:tail-different-p'] = lambda *xs, result=principles_diff: result
        runner.mocks['hddl:tail-duplicate-p'] = lambda *xs, result=dup: result
        calls.clear()
        marks.clear()
        members = [row_a, row_b] if nrows == 2 else [row_a, row_b, row_a]
        env = {'groups': [['ID'] + members], 'bad': 0, 'made': 0}
        runner.eval(loop, env)
        expected_calls = 0 if color is None else nrows if kind in ('id', 'duplicate') else 1
        assert calls == [color] * expected_calls, (kind, calls)
        assert marks == ([] if label is None else [label] * nrows), (kind, marks)
        assert env['bad'] == env['made'] == len(marks)
    for name in list(runner.mocks):
        if name.startswith('hddl:'):
            del runner.mocks[name]


def check_spec_fixture(runner, funcs):
    import json
    from pathlib import Path
    from copy import deepcopy
    data = json.loads((Path(__file__).resolve().parents[1] /
                       'tests/fixtures/hddl_spec_qw3.json').read_text(encoding='utf-8'))
    loop = next(node for node in walk(funcs['c:hddl']) if node[:3] == ['foreach', 'group', 'groups'])
    colors, marks = [], []
    runner.mocks['hddl:color'] = lambda entity, color: colors.append((entity, color)) or True
    runner.mocks['hddl:make-marker'] = lambda rec, text: marks.append((rec[0], text)) or True
    def run(records):
        colors.clear()
        marks.clear()
        rows = runner.call('hddl:sort-rows', [runner.call('hddl:rows', [records])])
        groups = runner.call('hddl:group-rows', [rows])
        env = {'groups': groups, 'bad': 0, 'made': 0}
        runner.eval(loop, env)
        return env
    env = run(data)
    assert set(colors) == {(handle, 1) for handle in ('3038C', '30391', '30398', '3039D')}, colors
    assert len(colors) == 4 and env['bad'] == env['made'] == 4
    assert len(marks) == 4 and all(text == '[电缆规格不一致]' for _, text in marks), marks
    equal = deepcopy(data)
    for rec in equal:
        if rec[1] == '2×16':
            rec[1] = ' 2×10 '
    env = run(equal)
    assert not colors and not marks and env['bad'] == env['made'] == 0
    combined = deepcopy(data)
    next(rec for rec in combined if rec[0] == '30393')[1] = '+XX'
    env = run(combined)
    assert set(colors) == {(handle, 1) for handle in
                           ('3038C', '30391', '30398', '3039D', '303A4', '30393')}, colors
    assert env['bad'] == env['made'] == 4
    assert sum(text == '[原理号不一致][电缆规格不一致]' for _, text in marks) == 2
    for name in ('hddl:color', 'hddl:make-marker'):
        del runner.mocks[name]
    print('PASS: QW3 28-text fixture: four spec cells red, equal specs clean, concurrent principle differences preserved')


def check_gty_layout(runner, funcs):
    rng = random.Random(136)
    for _ in range(50):
        rows = []
        for r in range(rng.randrange(1, 20)):
            row = [item(i, i, r * 5.) for i in range(rng.randrange(1, 15))]
            for rec in row:
                rec[3] = rng.uniform(.1, 25.)
            rows.append(row)
        for gap in (0., 2.5, 15.):
            expected = [max([gap] + [row[i][3] for row in rows if i < len(row)])
                        for i in range(max(map(len, rows)))]
            assert runner.call('aa:gty-column-widths', [rows, gap]) == expected
        rng.shuffle(rows)
        assert runner.call('aa:gty-order-rows', [rows, 1., True]) == runner.call('aa:gty-order-rows', [rows, 1., False])
    rows = [[item('B', 1, 1.2)], [item('A', 2, 2.)], [item('C', 0, .4)]]
    assert runner.call('aa:gty-order-rows', [rows, 1., False]) == runner.call(
        'aa:insert-sort', [rows, funcs['aa:gty-order-rows'][3][2][1]], {'row-tol': 1.})
    segment_loop = next(node for node in walk(funcs['c:gty'])
                        if node[:3] == ['foreach', 'row', 'rows'] and 'split-rows' in str(node))
    rows = [[item(i, x, 0) for i, x in enumerate((0., 0., 200., 401., 500., 701., 901.))],
            [item('last', 1, -10)]]
    env = {'rows': rows, 'split-rows': [], 'split-gap': 200.}
    runner.eval(segment_loop, env)
    actual = list(reversed(env['split-rows']))
    assert actual == [rows[0][:3], rows[0][3:5], rows[0][5:], rows[1]]


def check_work(new, old):
    rows = [[item(i, 0, 0)] for i in range(1000)]
    new.counts.clear()
    tree = new.call('aa:gty-row-tree', [rows, len(rows)])
    for i, row in enumerate(rows):
        assert new.call('aa:gty-tree-item', [tree, i]) == row
    tree_count = new.counts['visits'] + new.counts['copies']
    assoc_count = len(rows) * (len(rows) + 1) // 2
    assert tree_count < assoc_count, (tree_count, assoc_count)
    print(f'LIST_WORK GTY lookup 1000 rows: baseline assoc visits={assoc_count}, '
          f'optimized tree build+lookup visits/copies={tree_count}')
    data = [item(i, i % 8, (i // 8) * 5.) for i in range(1000)]
    random.Random(42).shuffle(data)
    old.counts.clear()
    expected = hddl_rows(old, data)
    old_count = old.counts['visits'] + old.counts['copies']
    new.counts.clear()
    packed = new.call('aa:gty-separated-rows', [data, 1., False])
    assert packed[1] == expected
    new_count = new.counts['visits'] + new.counts['copies']
    assert new_count < old_count, (old_count, new_count)
    print(f'LIST_WORK HDDL separated 1000 texts: baseline={old_count}, optimized={new_count}; '
          'logical Lisp visits/copies only, not CAD elapsed time')
    data = [item(i, i, 0.) for i in range(128)]
    old.counts.clear()
    expected = old.call('hddl:sort', [data])
    old_count = old.counts['visits'] + old.counts['copies']
    new.counts.clear()
    assert new.call('hddl:sort', [data]) == expected
    new_count = new.counts['visits'] + new.counts['copies']
    assert new_count < old_count, (old_count, new_count)
    print(f'LIST_WORK HDDL flat row 128 texts: baseline={old_count}, optimized={new_count}; '
          'actual merge-sort AST, not Python sorted')


if __name__ == '__main__':
    check()
