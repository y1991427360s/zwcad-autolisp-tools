"""Static verification for ZDDLH / ZDDLS / ZDC command."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tools'))
from lsp_common import defun_forms, parse, walk

LSP_PATH = ROOT / 'AA整合版本.lsp'

def test_syntax_and_locals():
    text = LSP_PATH.read_text(encoding='utf-8')
    forms = parse(text)
    funcs = {str(f[1]).lower(): f for f in defun_forms(forms) if isinstance(f[1], str)}
    assert 'c:zddlh' in funcs, 'c:zddlh not found'
    assert 'c:zddls' in funcs, 'c:zddls not found'
    assert 'c:zddl' not in funcs, 'c:zddl was renamed to c:zddlh'
    assert 'c:zdc' in funcs, 'c:zdc not found'
    assert 'c:zddl2' in funcs, 'c:zddl2 not found'
    assert 'zddl:parse-strip' in funcs
    assert 'zddl:parse-one-box' in funcs
    assert 'zddl:draw-one-cable' in funcs
    assert 'zddl:make-text' in funcs

    # Verify locals in c:zddl
    required = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    for command in ('c:zddlh', 'c:zddls', 'c:zddl2'):
        locals_list = funcs[command][2]
        assert '/' in locals_list
        declared_locals = set(locals_list[locals_list.index('/') + 1:])
        assert required.issubset(declared_locals), f'Missing required locals: {required - declared_locals}'

    # Check function signatures and call arities for all zddl:* functions
    arities = {}
    for name, f in funcs.items():
        if name.startswith(('zddl:', 'zddl2:')):
            args = f[2]
            param_count = len(args[:args.index('/')]) if '/' in args else len(args)
            arities[name] = param_count

    print(f"Verified {len(arities)} zddl function arities: {arities}")

    # Check all calls inside the forms
    for n in walk(forms):
        if isinstance(n, list) and n and isinstance(n[0], str):
            call_head = n[0].lower()
            if call_head in arities:
                expected = arities[call_head]
                actual = len(n) - 1
                assert actual == expected, (
                    f"Call arity mismatch for {call_head}: expected {expected} args, got {actual}: {n}"
                )

    print("PASS: ZDDL syntax, locals, and call arities verified")

def test_text_coordinates_and_strip():
    # Interpret the actual Lisp AST using DXF fixtures, without connecting to CAD.
    from check_cable_perf_static import Runner
    funcs = {str(f[1]).lower(): f for f in defun_forms(parse(
        (ROOT / 'AA整合版本.lsp').read_text(encoding='utf-8')))}
    loader = parse((ROOT / 'ZDDL_端子电缆自动出线.lsp').read_text(encoding='utf-8'))
    assert not list(defun_forms(loader)), 'Standalone file must remain a compatibility loader'
    assert any(f[0] == 'load' and 'ZW-auto_lisp/AA整合版本.lsp' in str(f[1])
               for f in loader if isinstance(f, list) and f)
    runner = Runner(funcs)
    messages = []
    transforms = []
    runner.mocks.update({
        'entget': lambda en: en,
        'assoc': lambda key, ed: ((key, ed[key]) if key in ed else None) if isinstance(ed, dict) else next((r for r in ed or [] if r[0] == key), None),
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'dx:text-string': lambda en: en.get(1, ''),
        'dx:has-hanzi-p': lambda text: any('\u4e00' <= c <= '\u9fff' for c in text),
        'ascii': lambda text: ord(text[0]),
        'textbox': lambda data: [[0.0, 0.0], [sum(1.0 if '\u4e00' <= c <= '\u9fff' else 0.5 for c in dict((row[0], row[-1]) for row in data)[1]) * dict((row[0], row[-1]) for row in data)[40] * 0.7, dict((row[0], row[-1]) for row in data)[40]]],
        'min': lambda *values: min(values), 'max': lambda *values: max(values),
        'princ': lambda text='': messages.append(text),
        'trans': lambda pt, en, dest: transforms.append((en, dest)) or pt,
    })
    p10, p11 = [3400.0, 6150.0, 0.0], [3405.0, 6150.0, 0.0]
    cases = [
        ({0: 'TEXT', 10: p10, 11: [0.0, 0.0, 0.0], 72: 0, 73: 0}, p10),
        ({0: 'TEXT', 10: p10, 11: p11, 72: 1, 73: 2}, p11),
        ({0: 'TEXT', 10: p10, 11: p11, 72: 0, 73: 2}, p11),
        ({0: 'TEXT', 10: p10, 11: p11, 72: 3, 73: 0}, p10),
        ({0: 'TEXT', 10: p10, 11: p11, 72: 5, 73: 0}, p10),
        ({0: 'TEXT', 10: p10}, p10),
        ({0: 'MTEXT', 10: p10, 11: [1.0, 0.0, 0.0]}, p10),
    ]
    for ed, expected in cases:
        transforms.clear()
        assert runner.call('zddl:text-point', [ed, ed]) == expected
        assert len(transforms) == (0 if ed[0] == 'MTEXT' else 1)

    for typ in ('TEXT', 'MTEXT'):
        def text(value, x, y):
            return {0: typ, 1: value, 10: [x, y, 0.0],
                    11: [1.0 if typ == 'MTEXT' else 0.0, 0.0, 0.0], 72: 0, 73: 0}
        entities = [
            {0: 'LINE', 10: [3390.0, 6120.0, 0.0], 11: [3450.0, 6120.0, 0.0]},
            {0: 'LINE', 10: [3390.0, 6180.0, 0.0], 11: [3450.0, 6180.0, 0.0]},
            text('ZD', 3392.0, 6150.0),
        ]
        entities += [text(str(i), 3400.0 + 5.0 * i, 6150.0) for i in range(1, 9)]
        # Include numeric principle labels outside the middle band: never terminals.
        entities += [text('999', 3400.0, 6125.0 if i % 2 else 6175.0)
                     for i in range(778)]
        assert len(entities) == 789
        result = runner.call('zddl:parse-strip', [entities])
        assert result is not None
        mapping = {r[0]: r[1:] for r in result[0]}
        assert len(mapping) == 8
        assert mapping['ZD:1'][0] == 3405.0 and mapping['ZD:8'][0] == 3440.0
        assert '999' not in mapping
        assert result[1:5] == [6120.0, 6180.0, 3390.0, 3450.0]
        # Recreate the old unconditional group 11 read: the same strip fails.
        runner.mocks['zddl:text-point'] = lambda en, ed: ed.get(11, ed.get(10))
        assert runner.call('zddl:parse-strip', [entities]) is None
        del runner.mocks['zddl:text-point']
    assert runner.call('zddl:parse-strip', [[text('1', 3405.0, 6150.0)]]) is None
    assert any('端子格' in message for message in messages)
    import json
    fixture = json.loads((ROOT / 'tests/fixtures/zddl_789_multirow.json').read_text(encoding='utf-8'))
    entities = [{int(k): v for k, v in item.items()} for item in fixture['entities']]
    runner.mocks['equal'] = lambda a, b, tol=0: abs(a-b) <= tol if isinstance(a,(int,float)) and isinstance(b,(int,float)) else a==b
    result = runner.call('zddl:parse-strip', [entities])
    mapping = {r[0]: r[1:] for r in result[0]}
    from collections import Counter
    assert Counter(key.split(':')[0] for key in mapping) == {
        'YD': 30, 'TD': 4, 'SD': 15, 'JD': 8, 'ZD': 34, '26TXD': 47}
    assert len(mapping) == len(result[0]) == 138
    assert mapping['YD:1'][:3] == [2438.2954, -8562.8858, -8487.5974]
    assert mapping['YD:1'][3:5] == [-8535.8858, -8489.5974]
    assert mapping['ZD:1'][:3] == [2438.2954, -8702.7015, -8625.2028]
    assert mapping['ZD:1'][3:5] == [-8682.6995, -8627.2028]
    assert runner.call('zddl:lookup-terminal', ['OTHER:1', result[0]]) is None
    assert runner.call('zddl:lookup-terminal', ['1', result[0]]) is None
    assert runner.call('zddl:lookup-terminal', ['47', result[0]]) == mapping['26TXD:47']
    assert runner.call('zddl:lookup-terminal', ['yd:1', result[0]]) == mapping['YD:1']
    # All compact references reported in the user's failed 9-cable run.
    groups = [
        ['ZD1', 'ZD19'], ['TD2', 'TD4'], ['ZD9', 'ZD27'],
        ['JD2', 'JD5'], ['JD1', 'JD4'], ['26TXD1', '26TXD2'],
        ['26TXD7', '26TXD8'], ['YD1'] + ['YD' + str(i) for i in range(15, 23)],
        ['SD1'] + ['SD' + str(i) for i in range(5, 16)],
    ]
    for refs in groups:
        for ref in refs:
            assert runner.call('zddl:lookup-terminal', [ref, result[0]]) is not None, ref
    for ref in [' ZD1 ', 'zd1', 'ZD:1', 'ZD：1']:
        assert runner.call('zddl:lookup-terminal', [ref, result[0]]) == mapping['ZD:1']
    for ref in ['OTHER1', 'ZD999', '26TXD', 'OTHER:1']:
        assert runner.call('zddl:lookup-terminal', [ref, result[0]]) is None, ref
    ambiguous = [['A:11', 1.0], ['A1:1', 2.0]]
    assert runner.call('zddl:lookup-terminal', ['A11', ambiguous]) is None
    assert runner.call('zddl:lookup-terminal', ['A1:1', ambiguous]) == [2.0]
    import random
    shuffled = entities.copy()
    random.Random(20261014).shuffle(shuffled)
    again = runner.call('zddl:parse-strip', [shuffled])
    assert {r[0]: r[1:] for r in again[0]} == mapping
    lines, labels = [], []
    runner.mocks.update({
        'zddl:make-line': lambda *args: lines.append(args) or True,
        'zddl:make-text': lambda *args: labels.append(args) or True,
        'zddl:make-triangle': lambda *args: True,
    })
    for ref in ['YD:1', 'ZD:1']:
        for direction in ['S', 'X']:
            lines.clear(); labels.clear()
            assert runner.call('zddl:draw-one-cable', [
                [[(ref, '+KM')], '目标柜', ''], 0, 0, 99999., direction,
                'WL', 1, 2946., 'Y', 99999., result[0], 'HZ', None], {'pi': 3.141592653589793})
            rec = mapping[ref]
            pin = rec[1 if direction == 'X' else 2]
            cell = rec[3 if direction == 'X' else 4]
            end_y = pin + (-10. if direction == 'X' else 10.)
            assert lines[0][0] == [rec[0], pin, 0.0]
            assert lines[0][1] == [rec[0], end_y, 0.0]
            principles = [label for label in labels if label[1] == '+KM']
            if rec[7 if direction == 'X' else 8]:
                assert not principles  # Existing inner-side text is preserved.
            else:
                principle = principles[0]
                assert principle[0] == [rec[0], cell, 0.0]
                assert principle[-3:-1] == (0 if direction == 'X' else 2, 2)
            assert any(label[1] == '未填写' for label in labels)
            assert any(label[1] == 'WL-01' for label in labels)
    # Check actual TEXT DXF output: short and long principles share an endpoint,
    # aligned to upper/lower outer frame edges with a 2mm inset.
    text_mock = runner.mocks.pop('zddl:make-text')
    made = []
    runner.mocks['entmake'] = lambda data: made.append(data) or True
    empty_map = [[item[0]] + item[1:8] + [None, None] + item[10:] for item in result[0]]
    for direction in ['S', 'X']:
        for text_value in ['B+', 'L1', 'YD-917']:
            made.clear()
            runner.call('zddl:draw-one-cable', [
                [[('YD1', text_value)], '目标柜', ''], 0, 0, 99999., direction,
                'WL', 1, 2946., 'Y', 99999., empty_map, 'HZ', None], {'pi': 3.141592653589793})
            texts = [{pair[0]: pair[1] if isinstance(pair, tuple) else pair[1:]
                      for pair in data if isinstance(pair[0], int)} for data in made]
            entity = next(data for data in texts if data.get(1) == text_value)
            assert entity[72] == (0 if direction == 'X' else 2)
            assert entity[73] == 2 and entity[50] == 3.141592653589793 / 2.0
            assert entity[11] == [mapping['YD:1'][0], mapping['YD:1'][3 if direction == 'X' else 4], 0.0]
            assert entity[10] == entity[11]
    runner.mocks['zddl:make-text'] = text_mock
    print('PASS: actual principle TEXT DXF: short/long strings share 2mm endpoint anchors; outside the number band, aligned to the outer frame')
    # Execute c:ZDDL2 with mocked CAD boundaries: verify 9 successes, all-failed,
    # and failed-then-success numbering using actual lookup/draw/command AST.
    command_cables = [[[(ref, '+KM') for ref in refs], '目标柜', ''] for refs in groups]
    runner.mocks.update({
        'aa:cmd-begin': lambda *args: None, 'aa:cmd-end': lambda: None,
        'vl-load-com': lambda: None, 'vlax-get-acad-object': lambda: 'app',
        'vla-get-activedocument': lambda app: 'doc',
        'ssget': lambda *args: None if args else 'selection',
        'zddl:parse-strip': lambda ss: result,
        'getkword': lambda *args: 'Shang', 'initget': lambda *args: None,
        'zddl:ensure-layer': lambda *args: None, 'tblsearch': lambda *args: True,
        'redraw': lambda: None, 'sssetfirst': lambda *args: None,
    })
    for cables, expected in [(command_cables, 9),
                             ([[[('UNKNOWN1', '+KM')], '目标柜', '']], 0),
                             ([[[('UNKNOWN1', '+KM')], '目标柜', ''], command_cables[0]], 1)]:
        messages.clear(); labels.clear(); lines.clear()
        runner.mocks['zddl:parse-wiring-ss'] = lambda *args: cables
        runner.call('c:zddl2', [], {'pi': 3.141592653589793})
        cable_labels = [label[1] for label in labels if label[1].startswith('WL-')]
        assert sorted(cable_labels) == ['WL-' + str(i).zfill(2) for i in range(1, expected+1)]
        assert not any('WL-00' in message for message in messages)
        if not expected:
            assert any('未生成电缆' in message for message in messages)
            assert not any('绘制完成' in message for message in messages)
    # Geometry is determined by leftmost terminal, not box order or global ordinal.
    for direction in ['S', 'X']:
        for cables in [command_cables, list(reversed(command_cables))]:
            messages.clear(); labels.clear(); lines.clear()
            runner.mocks['getkword'] = lambda *args: 'Xia' if direction == 'X' else 'Shang'
            runner.mocks['zddl:parse-wiring-ss'] = lambda *args: cables
            runner.call('c:zddl2', [], {'pi': 3.141592653589793})
            expected_rows = {}
            for cable in cables:
                matches = [runner.call('zddl:lookup-terminal', [pr[0], result[0]]) for pr in cable[0]]
                key = (min if direction == 'X' else max)(rec[1 if direction == 'X' else 2] for rec in matches)
                expected_rows.setdefault(key, []).append(min(rec[0] for rec in matches))
            expected_geometry = []
            for pin, xs in expected_rows.items():
                for rank, x in enumerate(sorted(xs)):
                    y = pin + (-1 if direction == 'X' else 1) * (10. + rank * 7.)
                    expected_geometry.append((x, y))
            trunks = [(line[0][0], line[0][1]) for line in lines if line[3] == 3]
            assert sorted(trunks) == sorted(expected_geometry), (direction, trunks, expected_geometry)
            # Both rows restart at 10 units even though labels keep their original numbers.
            assert len(trunks) == 9
    print('PASS: leftmost-to-rightmost cable geometry, independent row lanes, reversed box order, both directions, original cable identity retained')
    print('PASS: 35 compact references / 9 cable command AST; optional/fullwidth colon, digits in block names, ambiguity, zero-result message and continuous success numbering')
    print('PASS: user QW3 789 objects -> 138 terminals / 6 strips / 2 rows; cell centers, both directions, row-specific writeback, strict references, shuffled selection')
    assert runner.call('zddl:format-cable-no', ['WL', 1]) == 'WL-01'
    assert runner.call('zddl:format-cable-no', ['WL', 12]) == 'WL-12'
    print('PASS: actual AST coordinate cases, 789-entity strip fixtures, old failure reproduction')

    # Actual QW3 sample: small 7.1429-unit pin band and bottom header names.
    del runner.mocks['zddl:parse-strip']
    xt_fixture = json.loads((ROOT / 'tests/fixtures/zddl_959_xt.json').read_text(encoding='utf-8'))
    xt_entities = [{int(k): v for k, v in item.items()} for item in xt_fixture['entities']]
    xt_result = runner.call('zddl:parse-strip', [xt_entities])
    xt_mapping = {item[0]: item[1:] for item in xt_result[0]}
    print('XT fixture:', Counter(k.split(':')[0] for k in xt_mapping), len(xt_result[0]))
    assert Counter(k.split(':')[0] for k in xt_mapping) == {
        'XT1': 33, 'XT2': 10, 'XT3': 18, 'XT4': 4, 'XT5': 10, 'XT6': 6, 'XT7': 6}
    assert len(xt_mapping) == len(xt_result[0]) == 87
    # 用户 4 带端子排：端子号带在第 3 带，纯数字原理号带与端子号带关于排名格中线对称。
    # 原理号（800、881…）不得被当成端子；各排上下外缘都应是整排最外缘。
    band_fixture = json.loads((ROOT / 'tests/fixtures/zddl_4band_yuanlihao.json').read_text(encoding='utf-8'))
    band_entities = [{int(k): v for k, v in item.items()} for item in band_fixture['entities']]
    band_result = runner.call('zddl:parse-strip', [band_entities])
    band_mapping = {item[0]: item[1:] for item in band_result[0]}
    assert Counter(k.split(':')[0] for k in band_mapping) == {
        'Q1D': 27, 'YD': 21, 'BSD': 14, 'TD': 29, 'XD': 5, 'JRD': 11, 'BD': 8, 'XMX': 20}
    assert not any(k.split(':')[1] in ('800', '700', '881', '600') for k in band_mapping)
    assert {(round(v[1], 1), round(v[2], 1)) for v in band_mapping.values()} == {(439.9, 499.9)}
    print('PASS: 4-band strips -> 135 terminals; numeric principle band ignored; outer edges 439.9~499.9 for every strip')
    refs = ['XT3:11', 'XT3:12', 'XT3:4', 'XT3:7', 'XT3:8', 'XT3:9',
            'XT1:23', 'XT1:19', 'XT2:1', 'XT2:2', 'XT5:1', 'XT5:3',
            'XT5:5', 'XT5:8', 'XT7:1', 'XT7:2']
    for ref in refs:
        assert runner.call('zddl:lookup-terminal', [ref, xt_result[0]]) == xt_mapping[ref]
    # Header indices 1..7 and RS485A/B are excluded; ground terminals are retained.
    assert 'XT1:33' in xt_mapping and not any(k.startswith('RS485') for k in xt_mapping)
    xt_shuffled = xt_entities.copy()
    random.Random(959).shuffle(xt_shuffled)
    again = runner.call('zddl:parse-strip', [xt_shuffled])
    assert {item[0]: item[1:] for item in again[0]} == xt_mapping
    xt_groups = [refs[:6], refs[6:8], refs[8:10], refs[10:14], refs[14:]]
    xt_cables = [[[(ref, '+KM') for ref in group], '目标柜', ''] for group in xt_groups]
    for direction in ('S', 'X'):
        plans = runner.call('zddl:plan-cables', [xt_cables, xt_result[0], direction])
        assert len(plans) == 5
        messages.clear(); labels.clear(); lines.clear()
        runner.mocks['zddl:parse-strip'] = lambda ss: xt_result
        runner.mocks['zddl:parse-wiring-ss'] = lambda *args: xt_cables
        runner.mocks['getkword'] = lambda *args: 'Xia' if direction == 'X' else 'Shang'
        runner.call('c:zddl2', [], {'pi': 3.141592653589793})
        assert sorted(label[1] for label in labels if label[1].startswith('WL-')) == [
            'WL-01', 'WL-02', 'WL-03', 'WL-04', 'WL-05']
        assert len([line for line in lines if line[0][0] == line[1][0]]) == 16
        assert not any('未匹配' in message or '未找到' in message for message in messages)
    print('PASS: 959-object XT fixture -> 87 unique terminals / 7 strips; all 16 failed references matched, shuffled selection, header/principle exclusions and ground terminals')


def check_layout_fixture():
    """Actual DXF placement, measured font extents and original diagram obstacles."""
    import json
    import math
    from fnmatch import fnmatchcase
    from collections import Counter
    from check_cable_perf_static import Runner
    fixture = json.loads((ROOT / 'tests/fixtures/zddl_686_layout.json').read_text(encoding='utf-8'))
    source = [{int(k) if k.isdigit() else k: v for k, v in e.items()} for e in fixture['entities']]
    funcs = {str(f[1]).lower(): f for f in defun_forms(parse(
        (ROOT / 'AA整合版本.lsp').read_text(encoding='utf-8')))}
    runner = Runner(funcs)
    measured = {}
    for e in source:
        if e[0] == 'TEXT' and e.get('bbox'):
            axis = 1 if abs(math.sin(e[50])) > 0.9 else 0
            measured[e[1]] = (e['bbox'][1][axis] - e['bbox'][0][axis]) / e[40]
    def text_span(value, height):
        return height * measured.get(value, sum(1 if '\u4e00' <= c <= '\u9fff' else 0.7 for c in value))
    def dxf(data):
        return {pair[0]: pair[1] if isinstance(pair, tuple) else
                (pair[2] if len(pair) == 3 and pair[1] == '.' else pair[1:]) for pair in data}
    made, lines, triangles, messages = [], [], [], []
    runner.mocks.update({
        'entget': lambda en: en,
        'assoc': lambda k, ed: ((k, ed[k]) if k in ed else None) if isinstance(ed, dict) else next((r for r in ed or [] if r[0] == k), None),
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'dx:text-string': lambda en: en.get(1, ''),
        'dx:has-hanzi-p': lambda value: any('\u4e00' <= c <= '\u9fff' for c in value),
        'ascii': lambda value: ord(value[0]), 'min': min, 'max': max,
        'princ': lambda value='': messages.append(value), 'trans': lambda pt, *args: pt,
        'equal': lambda a, b, tol=0: abs(a-b) <= tol if isinstance(a, (int,float)) and isinstance(b, (int,float)) else a == b,
        'wcmatch': fnmatchcase,
        'textbox': lambda data: [[0.,0.], [text_span(dxf(data)[1], dxf(data)[40]), dxf(data)[40]]],
        'entmake': lambda data: made.append(dxf(data)) or True,
        'zddl:make-line': lambda *args: lines.append(args) or True,
        'zddl:make-triangle': lambda point: triangles.append(point) or True,
    })
    parsed = runner.call('zddl:parse-strip', [source])
    mapping = {e[0]: e[1:] for e in parsed[0]}
    assert Counter(k.split(':')[0] for k in mapping) == {'XT1':33, 'XT2':10, 'XT3':18}
    originals = [e for e in source if e.get(8) not in ('电缆-接线','电缆-文字','接线-原理号')]
    clean = runner.call('zddl:parse-strip', [originals])
    assert clean == parsed, 'Generated lines/principles changed original terminal geometry'
    # Band/outer boundaries come independently from the supplied DXF, not source formulas.
    assert mapping['XT3:4'][3:5] == [6668.1116, 6714.1116]
    assert abs(mapping['XT3:4'][6] - 17.4285) < 0.0001
    assert mapping['XT3:4'][7] and not mapping['XT3:4'][8]  # LD:5 exists only below.
    old_numbers = [e for e in source if e.get(8) == '接线-原理号' and e.get(1) == '701']
    assert any(e['bbox'][0][1] < 6694.6831 and e['bbox'][1][1] > 6687.5402 for e in old_numbers)
    long_dest = next(e[1] for e in source if e[0] == 'TEXT' and e[1].startswith('至35'))
    cables = [
        [[('XT3:11','485+'),('XT3:12','485-')], '至网络通信柜', ''],
        [[('XT3:4','701'),('XT3:7','1(2)ZYB-901'),('XT3:8','1(2)ZYB-903'),
          ('XT3:9','1(2)ZYB-905'),('XT1:23','1(2)ZYB-907'),('XT1:19','701')], long_dest, ''],
        [[('XT2:1','801'),('XT2:2','803')], long_dest, ''],
    ]
    up_snapshot = None
    for direction in ('S','X'):
        made.clear(); lines.clear(); triangles.clear(); messages.clear()
        plans = runner.call('zddl:plan-cables', [cables, parsed[0], direction])
        for lane, plan in enumerate(plans):
            runner.call('zddl:draw-one-cable', [plan[3], plan[2], lane, 0., direction,
                'WL', 1, max(mapping[pr[0]][0] for cable in cables for pr in cable[0])+70., 'Y', 0., parsed[0], 'HZ', None], {'pi':math.pi})
        principles = [e for e in made if e[8] == '接线-原理号']
        if direction == 'S':
            assert len(principles) == 10
            assert any(e[40] < 3.0 for e in principles if 'ZYB-' in e[1]), 'Long principles were not fitted'
        for e in principles:
            width = text_span(e[1], e[40])
            low = e[11][1] - (width if e[72] == 2 else 0.)
            high = e[11][1] + (width if e[72] == 0 else 0.)
            if direction == 'S':
                assert low >= 6696.6831 - 0.0001 and high <= 6714.1116 + 0.0001, (e, low, high)
            else:
                assert high <= 6685.5402 + 0.0001 and low >= 6668.1116 - 0.0001, (e, low, high)
        if direction == 'X':
            assert len(principles) < 10 and any('保留原内容' in msg for msg in messages)
        labels = [e for e in made if e[8] == '电缆-文字']
        assert not any(e[1].startswith('至至') for e in labels)
        for level in set(e[10][1] for e in labels):
            row = sorted((e for e in labels if e[10][1] == level), key=lambda e:e[10][0])
            for left, right in zip(row, row[1:]):
                assert left[10][0] + text_span(left[1], left[40]) + 1.0 <= right[10][0]
            trunk = next(line for line in lines if line[3] == 3 and abs(line[0][1]+1.0-level)<0.0001)
            assert row[-1][10][0] + text_span(row[-1][1], row[-1][40]) < trunk[1][0]
        levels = sorted(p[1] for p in triangles)
        assert all(b-a >= 7.-0.0001 for a,b in zip(levels,levels[1:]))
        if direction == 'S':
            up_snapshot = {'source':source, 'texts':made.copy(), 'lines':lines.copy(),
                           'triangles':triangles.copy(), 'measured':measured}
    # A short contact bridge crossing the text center is not a grid boundary.
    slot = runner.call('zddl:write-slots', [[[0.,0.,5.],[10.,0.,5.],
        [20.,0.,5.],[30.,0.,5.],[19.,1.,4.]], [], 2.5,15.,0.,30.,0.,5.])
    assert slot[:4] == [2.,28.,6.,6.]
    # Native font measurement failure uses a conservative, finite fallback.
    runner.mocks['textbox'] = lambda *args: None
    assert runner.call('zddl:text-width', ['长编号123','HZ',3.]) == 18.
    print('PASS: actual 686-entity drawing: 61 original terminals, all 10 upper principles outside number band, long text fitted; occupied inner text retained, labels separated, lane/triangle clearance, generated geometry excluded')
    # User's 646-object sample includes bridges across multiple complete columns.
    # Their ends lie at pin centers rather than vertical grid boundaries.
    fresh = json.loads((ROOT / 'tests/fixtures/zddl_646_slots.json').read_text(encoding='utf-8'))
    sample = [{int(k): v for k, v in e.items()} for e in fresh['entities']]
    parsed646 = runner.call('zddl:parse-strip', [sample])
    map646 = {e[0]: e[1:] for e in parsed646[0]}
    assert len(map646) == 58, len(map646)
    for ref in ('11UD:1','11UD:3','11UD:5','11UD:7',
                '11ID:1','11ID:3','11ID:5','11ID:10',
                '12UD:1','12UD:3','12UD:5','12UD:7'):
        rec = map646[ref]
        assert abs(rec[3] - 5474.0795) < 0.0001, (ref, rec)
        assert abs(rec[5] - 16.) < 0.0001 and not rec[7], (ref, rec)
    # A real lower-side label must still be preserved.
    occupied = dict(next(e for e in sample if e.get(1) == '11UD'))
    occupied.update({1: 'EXISTING', 10: [-86.8095,5482.0795,0.],
                     11: [-86.8095,5482.0795,0.]})
    protected = runner.call('zddl:parse-strip', [sample + [occupied]])
    assert runner.call('zddl:lookup-terminal', ['11UD:1', protected[0]])[7]
    assert not runner.call('zddl:grid-edge-p', [[5493.0795,-86.8095,-56.8095],
        [[-89.5244,5472.0795,5522.0795],[-84.5244,5472.0795,5522.0795]]])
    runner.mocks['textbox'] = lambda data: [[0.,0.], [text_span(dxf(data)[1], dxf(data)[40]), dxf(data)[40]]]
    # Execute the real command with short/long/missing specifications, both directions.
    cables646 = [
        [[('11UD:1','A1'),('11UD:3','A3')], '相邻屏柜', ''],
        [[('11ID:1','L1'),('11ID:10','N1')], '110kV线路间隔GIS汇控柜', 'KVVP-4x2.5'],
        [[('12UD:1','B1'),('12UD:7','B7')], '电压转接柜', ''],
    ]
    runner.mocks.update({
        'aa:cmd-begin': lambda *args: None, 'aa:cmd-end': lambda: None,
        'vl-load-com': lambda: None, 'vlax-get-acad-object': lambda: 'app',
        'vla-get-activedocument': lambda app: 'doc',
        'ssget': lambda *args: None if args else 'selection',
        'zddl:parse-strip': lambda ss: parsed646,
        'zddl:parse-wiring-ss': lambda *args: cables646,
        'initget': lambda *args: None, 'zddl:ensure-layer': lambda *args: None,
        'tblsearch': lambda *args: True, 'redraw': lambda: None,
        'sssetfirst': lambda *args: None,
    })
    for direction in ('Shang', 'Xia'):
        made.clear(); lines.clear(); triangles.clear(); messages.clear()
        runner.mocks['getkword'] = lambda *args: direction
        runner.call('c:zddl2', [], {'pi': math.pi})
        trunks = [line for line in lines if line[3] == 3]
        assert len(trunks) == 3 and len({line[1][0] for line in trunks}) == 1
        assert len({round(point[0], 6) for point in triangles}) == 1, triangles
        for e in (e for e in made if e[8] == '电缆-文字'):
            assert e[10][0] + text_span(e[1], e[40]) < trunks[0][1][0]
        if direction == 'Xia':
            assert len([e for e in made if e[8] == '接线-原理号']) == 6
            assert not any('空间不足' in message for message in messages)
    print('PASS: user 646 objects -> 58 terminals, cross-column bridges and 1mm double borders handled; 12 reported lower slots have 16mm capacity; occupied text preserved; both cable directions share one right endpoint')
    return up_snapshot

if __name__ == '__main__':
    test_syntax_and_locals()
    test_text_coordinates_and_strip()
    check_layout_fixture()
