"""Offline HWT checks: command structure, and run the pure hwt:layout through a mini evaluator."""
from lsp_common import SOURCE, parse, read_source, walk
import lisp_mini_eval as ev


def layout(names):
    lisp = '(list ' + ' '.join('"%s"' % s for s in names) + ')'
    return ev.call(f'(hwt:layout {lisp} 0.0 0.0)')


def check():
    _, source = read_source(SOURCE)
    forms = parse(source)
    funcs = {f[1]: f for f in forms if isinstance(f, list) and f and f[0] == 'defun'}
    for name in ('c:hwt', 'hwt:row-counts', 'hwt:cable-no', 'hwt:feeder-items', 'hwt:box-items',
                 'hwt:label-items', 'hwt:layout', 'hwt:make-pline', 'hwt:fit-name', 'hwt:draw'):
        assert name in funcs, name + ' must remain top-level'
    calls = list(walk(funcs['c:hwt']))
    assert ['aa:cmd-begin', '"HWT"'] in calls and ['aa:cmd-end'] in calls
    assert ['trans', 'pt', '1', '0'] in calls
    assert 'vl-sort' not in str(funcs['c:hwt'])
    print('PASS: HWT structure')

    ev.load_defuns(source, 'hwt:')
    expect = {1: [1], 5: [5], 6: [3, 3], 9: [5, 4], 11: [4, 4, 3], 13: [5, 4, 4], 15: [5, 5, 5], 16: [4, 4, 4, 4]}
    for n, rows in expect.items():
        assert ev.call(f'(hwt:row-counts {n})') == rows, (n, rows)
    for n in (1, 2, 5, 8, 13, 15):
        items = layout([f'柜{i}' for i in range(n)])
        texts = [it[1] for it in items if it[0] in ('T', 'N')]
        assert [it[1] for it in items if it[0] == 'N'] == [f'柜{i}' for i in range(n)]
        sml = [t for t in texts if t.startswith('SML-')]
        assert sml == [f'SML-{i:02d}' for i in range(1, n)], (n, sml)
        assert texts.count('JL-01') == 1 and texts.count('JL-04') == 1
        assert sum(1 for it in items if it[0] == 'C') == 2 * n
        assert sum(1 for it in items if it[0] == 'D') == 4 * n
        # 每行居中：同一行柜中心的平均值都落在同一条竖直中线上
        rows = {}
        for it in items:
            if it[0] == 'N':
                rows.setdefault(round(it[2][1], 6), []).append(it[2][0])
        mids = {round(sum(xs) / len(xs), 6) for xs in rows.values()}
        assert len(mids) == 1, (n, mids)
    print('PASS: HWT layout rows, SML/JL numbering, terminals and symmetry')

    assert 'hwt:draw-list' in funcs and 'hwt:cable-rows' in funcs
    tail = ['2×4', '2', 'L1', 'N1']
    rows = ev.call('(hwt:cable-rows (list "A" "B" "C"))')
    assert rows == [['交流馈线柜', 'JL-01', 'A'] + tail, ['A', 'SML-01', 'B'] + tail,
                    ['B', 'SML-02', 'C'] + tail, ['C', 'JL-04', '交流馈线柜'] + tail], rows
    assert ev.call('(hwt:cable-rows (list "A"))') == [['交流馈线柜', 'JL-01', 'A'] + tail,
                                                       ['A', 'JL-04', '交流馈线柜'] + tail]
    draw = list(walk(funcs['hwt:draw-list']))
    for pair in (['quote', ['72', '.', '0']], ['quote', ['73', '.', '2']], ['quote', ['62', '.', '7']]):
        assert pair in draw or str(pair) in str(draw), pair
    assert ['hwt:draw-list', ['hwt:cable-rows', 'names'], ['car', 'lpt'], ['cadr', 'lpt'],
            ['caddr', 'pt'], 'style'] in calls
    print('PASS: HWT cable list rows (BH3 column order) and left-middle white text')


if __name__ == '__main__':
    check()
    print('ALL HWT STATIC CHECKS PASS')
