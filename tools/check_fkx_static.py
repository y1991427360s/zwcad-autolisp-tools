"""Run actual FKX helpers and command against 271 QW3 title objects; no CAD."""
import copy
import json
from pathlib import Path

from check_zdwi_static import evaluate
from lsp_common import ARITY, defun_forms, parse, read_source, walk


class LispIndex(int):
    # AutoLISP treats index 0 from vl-string-search as true.
    def __bool__(self):
        return True


def search(needle, value):
    index = value.find(needle)
    return None if index < 0 else LispIndex(index)


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    affected = {n: f for n, f in funcs.items() if n.startswith('fkx:') or n == 'c:fkx'}
    assert len(affected) == 11
    for name, form in affected.items():
        signature = form[2]
        declared = set(signature)
        for node in walk(form[3:]):
            head = node[0]
            if isinstance(head, str) and head in ARITY:
                lo, hi = ARITY[head]
                assert lo <= len(node) - 1 <= hi, (name, node)
            if head == 'setq':
                assert len(node) % 2 == 1, (name, node)
                assert all(k in declared for k in node[1::2]), (name, node)
            if head == 'foreach':
                assert node[1] in declared, (name, node)
    heads = [n[0] for n in walk(affected['c:fkx']) if isinstance(n[0], str)]
    assert heads.count('aa:cmd-begin') == heads.count('aa:cmd-end') == 1
    assert '"_X"' not in text[text.index('(defun fkx:point-in-p'):text.index('(defun fdx:add-rect')]
    for name in affected:
        calls = [n[0] for n in walk(affected[name]) if isinstance(n[0], str)]
        assert not set(calls) & {'entmod', 'entdel', 'command', 'entupd', 'vla-regen'}
    assert 'vlax-release-object' in [n[0] for n in walk(affected['fkx:box'])]

    builtins = {'strcase': str.upper, 'vl-string-search': search,
                'float': float, 'itoa': str, 'strcat': lambda *s: ''.join(s)}

    def call(name, *args, functions=None, extra=None):
        env = {'__functions': affected if functions is None else functions,
               '__builtins': builtins | (extra or {})}
        keys = []
        for i, value in enumerate(args):
            key = 'arg' + str(i)
            env[key] = value
            keys.append(key)
        return evaluate([name] + keys, env)

    rows = json.loads((Path(__file__).parent / 'fixtures/fkx_title_qw3.json').read_text(encoding='utf-8'))
    assert len(rows) == 271
    assert call('fkx:label-kind', '图样名称') == 1
    assert call('fkx:label-kind', 'DWG NO.') == 2
    assert call('fkx:label-kind', '保护电流') is None
    outer = [36294.8244, 7607.5508, 36714.8244, 7904.5508, 0]
    inner = [36319.8244, 7612.5508, 36709.8244, 7899.5508, 0]
    pt = [36400, 7800, 0]
    assert call('fkx:choose-frame', [outer, inner, inner], pt) == inner
    assert call('fkx:choose-frame', [outer, inner], [40000, 7800, 0]) is None
    assert not call('fkx:point-in-p', [inner[0], 7800], inner, 1e-6)

    def geometry(records):
        items = [[r['handle'], r['type'], r['bbox'], r['text']] for r in records]
        tops = [[min(p[0], q[0]), p[1], max(p[0], q[0])]
                for r in records if r['type'] == 'LINE'
                for p, q in [r['pts']] if abs(p[1] - q[1]) < 1e-6]
        return items, tops

    items, tops = geometry(rows)
    title = call('fkx:title-rect', inner, items, tops)
    assert title == [36529.8244, 7612.5508, 36709.8244, 7662.5508], title
    assert all(call('fkx:overlap-p', r['bbox'], title, 1e-4) for r in rows)
    assert call('fkx:filter', items, inner, title) == []  # every one of the 271 is excluded
    circuit = ['circuit', 'LINE', [[36400, 7800], [36500, 7800]], '']
    annotation = ['label', 'TEXT', [[36400, 7770], [36430, 7780]], '']
    cross_title = ['cross-title', 'LINE', [[36500, 7660], [36600, 7670]], '']
    on_frame = ['frame', 'LINE', [[inner[0], 7700], [inner[0], 7750]], '']
    neighbor = ['neighbor', 'LINE', [[36720, 7800], [36800, 7800]], '']
    mixed = items + [circuit, annotation, cross_title, on_frame, neighbor]
    assert call('fkx:filter', mixed, inner, title) == ['circuit', 'label']
    no_labels = [[r[0], r[1], r[2], ''] for r in items]
    assert call('fkx:title-rect', inner, no_labels, tops) is None
    assert call('fkx:title-rect', inner, items, []) is None

    shifted = copy.deepcopy(rows)
    dx, dy = -40000, 1600
    for row in shifted:
        for point in row['bbox'] + row.get('pts', []):
            point[0] += dx
            point[1] += dy
    translated_frame = [inner[0]+dx, inner[1]+dy, inner[2]+dx, inner[3]+dy, 0]
    translated_items, translated_tops = geometry(shifted)
    translated_title = call('fkx:title-rect', translated_frame, translated_items, translated_tops)
    assert translated_title == [title[0]+dx, title[1]+dy, title[2]+dx, title[3]+dy]
    assert call('fkx:filter', translated_items, translated_frame, translated_title) == []

    # Actual collection uses the cached bbox once per entity; CAD access is mocked.
    reads = []
    def entget(row):
        return {'0': row['type'], 'text': row['text'],
                '10': row.get('pts', [[0, 0, 0]])[0],
                '11': row.get('pts', [[0, 0, 0], [0, 0, 0]])[-1]}
    collect_extra = {'entget': entget,
                     'assoc': lambda key, ed: (key, ed.get(str(key))),
                     'cdr': lambda pair: pair[1],
                     'fkx:box': lambda r: reads.append(r['handle']) or r['bbox'],
                     'aa:ysdl-get-plain-text': lambda ed: ed['text']}
    collect_functions = {n: f for n, f in affected.items() if n != 'fkx:box'}
    collected = call('fkx:collect', rows, functions=collect_functions, extra=collect_extra)
    assert len(reads) == len(set(reads)) == 271
    assert call('fkx:title-rect', inner, *collected) == title
    assert call('fkx:filter', collected[0], inner, title) == []

    released = []
    box_extra = {'vl-load-com': lambda: None,
                 'vl-catch-all-apply': lambda _fn, args: args[0],
                 'vl-catch-all-error-p': lambda obj: obj.get('error', False),
                 'aa:try-get-bbox': lambda obj: obj.get('bbox'),
                 'vlax-release-object': lambda obj: released.append(obj),
                 'mapcar': lambda fn, xs: [p[0 if fn == 'car' else 1] for p in xs],
                 'apply': lambda fn, xs: (min if fn == 'min' else max)(xs)}
    assert call('fkx:box', rows[0], extra=box_extra) == [p[:2] for p in rows[0]['bbox']]
    assert released == [rows[0]]
    assert call('fkx:box', {'bbox': None}, extra=box_extra) is None
    assert len(released) == 2  # release even when bbox is unavailable
    assert call('fkx:box', {'error': True}, extra=box_extra) is None
    assert len(released) == 2  # conversion failed, so there is no object to release

    # Exercise actual point-mode command with CAD I/O mocked at the boundary.
    functions = {n: f for n, f in affected.items() if n not in ('fkx:box', 'fkx:collect')}
    selections = []
    messages = []
    queries = []
    def ssget(mode, *_args):
        queries.append(mode)
        return [outer, inner] if len(queries) == 1 else ['cached']
    extra = {'getpoint': lambda _: pt, 'getvar': lambda k: {
                 'SCREENSIZE': [1920, 1080], 'VIEWSIZE': 400, 'PICKFIRST': 1}[k],
             'ssget': ssget, 'fdx:poly-rect': lambda en: en,
             'fdx:add-rect': lambda r, rs: [r] + (rs or []),
             'fkx:collect': lambda _: [mixed, tops],
             'sssetfirst': lambda _, ss: selections.append(ss),
             'aa:cmd-begin': lambda _: None, 'aa:cmd-end': lambda: None,
             'princ': lambda *s: messages.extend(s)}
    call('c:fkx', functions=functions, extra=extra)
    assert selections[-1] == ['circuit', 'label'], selections
    assert queries == ['_C', '_C'], queries
    selections.clear()
    queries.clear()
    pt = [36600, 7640, 0]  # click in the title must not select its contents
    call('c:fkx', functions=functions, extra=extra)
    assert selections == [None]
    assert any('标题栏内' in m for m in messages)

    selections.clear()
    queries.clear()
    manual_extra = extra | {'getpoint': lambda _: None, 'entsel': lambda _: [inner],
                            'entget': lambda _: {'0': 'LWPOLYLINE'}}
    call('c:fkx', functions=functions, extra=manual_extra)
    assert selections[-1] == ['circuit', 'label']
    assert queries == ['_C']

    selections.clear()
    queries.clear()
    prompts = iter([[36400, 7800, 0], None])
    missing_extra = extra | {'getpoint': lambda _: next(prompts),
                             'fkx:collect': lambda _: [no_labels, tops]}
    call('c:fkx', functions=functions, extra=missing_extra)
    assert selections == [None]  # failed recognition + user cancel never includes titles
    print('PASS FKX: 271 title objects excluded; actual helpers/point command; nested frames,')
    print('  body retention, boundary/cross-title/neighbor exclusion, translation, title click, manual/cancel')


if __name__ == '__main__':
    check()
