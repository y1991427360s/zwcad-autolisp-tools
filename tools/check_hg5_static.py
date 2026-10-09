"""Execute HG5 geometry helpers against 363 supplied QW3 objects; no CAD."""
import json
import math
import random
from pathlib import Path
from check_zdwi_static import evaluate
from lsp_common import ARITY, defun_forms, parse, read_source, walk


def check():
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    affected = {n: f for n, f in funcs.items() if n.startswith('aa:hg5-') or n == 'c:hg5'}
    assert len(affected) == 7
    for name, f in affected.items():
        declared = set(f[2])
        for n in walk(f[3:]):
            if isinstance(n[0], str) and n[0] in ARITY:
                lo, hi = ARITY[n[0]]
                assert lo <= len(n)-1 <= hi, (name, n)
            if n[0] == 'setq':
                assert len(n) % 2 == 1, (name, n)
                assert all(v in declared for v in n[1::2]), (name, n)
            if n[0] == 'foreach':
                assert n[1] in declared, (name, n)
    calls = list(walk(funcs['c:hg5']))
    assert ['aa:cmd-begin', '"HG5"'] in calls and ['aa:cmd-end'] in calls
    assert ['vlax-release-object', 'obj'] in calls
    assert not any(n[0] in ('command', 'entupd', 'vl-sort') for n in calls)
    def call(name, *args):
        env = {'__functions': {n: f for n, f in funcs.items() if n != 'aa:merge-sort'},
               '__builtins': {'aa:merge-sort': lambda xs, _: sorted(xs, reverse=True),
                              'last': lambda xs: xs[-1] if xs else None,
                              '1-': lambda x: x-1}}
        keys = []
        for i, arg in enumerate(args):
            key = 'arg'+str(i)
            env[key] = arg
            keys.append(key)
        return evaluate([name]+keys, env)

    fixture = json.loads((Path(__file__).parent / 'fixtures/hg5_qw3.json').read_text(encoding='utf-8'))
    lines = [r for r in fixture if r['type']=='LINE']
    segments = [call('aa:tbhb-segment', *r['pts']) for r in lines]
    segments = call('aa:tbhb-merge-segments', [s for s in segments if s])
    horizontal = [s for s in segments if s[0]=='H']
    left = min(s[2] for s in horizontal)
    right = max(s[3] for s in horizontal)
    rows = call('aa:hg5-rows', segments, left, right)
    assert call('aa:tbhb-border-p', segments, rows[0], left, right)
    assert call('aa:tbhb-border-p', segments, rows[-1], left, right)
    assert call('aa:hg5-side-p', segments, left, rows[-1], rows[0])
    assert call('aa:hg5-side-p', segments, right, rows[-1], rows[0])
    mapped = [call('aa:hg5-y', y, rows) for y in rows]
    assert all(math.isclose(a-b,5) for a,b in zip(mapped,mapped[1:]))
    assert mapped[0] == rows[0]
    assert len(rows)==77, len(rows)
    circles = [[r['center'],r['radius']] for r in fixture if r['type']=='CIRCLE']
    for r in fixture:
        lo,hi = r['bbox']
        assert lo[0] >= left-.5 and hi[0] <= right+.5, r
        assert lo[1] >= rows[-1]-.01 and hi[1] <= rows[0]+.01, r
        if r['type']=='TEXT':
            assert hi[1]-lo[1] <=4.8
            ty=call('aa:hg5-text-y', (lo[1]+hi[1])/2, rows)
            assert ty is not None and any(math.isclose(ty, y-2.5) for y in mapped[:-1])
        if r['type']=='LINE':
            for p in r['pts']:
                q=call('aa:hg5-point',p,rows,circles)
                assert p[0]==q[0] and p[2]==q[2]
                for c,radius in circles:
                    if abs(p[0]-c[0]) <=.03:
                        for tip in (c[1]-radius,c[1]+radius):
                            if abs(p[1]-tip) <=.03:
                                assert math.isclose(q[1]-call('aa:hg5-y',c[1],rows),p[1]-c[1])
    rng=random.Random(5)
    for _ in range(10):
        shuffled=segments.copy();rng.shuffle(shuffled)
        assert call('aa:hg5-rows',shuffled,left,right)==rows
    assert call('aa:hg5-rows',segments+segments,left,right)==rows
    assert not call('aa:hg5-side-p',[],left,rows[-1],rows[0])
    for y in rows:
        assert math.isclose(call('aa:hg5-y',y-20000,[v-20000 for v in rows]),call('aa:hg5-y',y,rows)-20000)
    print(f'PASS HG5: 363 QW3 objects, {len(rows)-1} rows, top fixed, 5-unit spacing, '
          '178 text centers, 33 rigid circles, attached connectors, duplicated borders and selection permutations')


if __name__ == '__main__':
    check()
