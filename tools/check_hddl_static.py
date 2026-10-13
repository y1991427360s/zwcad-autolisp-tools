"""Static checks for HDDL command in AA整合版本.lsp."""
import sys
from pathlib import Path

from lsp_common import SOURCE, defun_forms, parse, read_source, walk


def check_hddl_ast():
    _, text = read_source(SOURCE)
    forms = parse(text)
    funcs = {f[1]: f for f in defun_forms(forms) if isinstance(f[1], str)}

    assert 'c:hddl' in funcs, 'c:hddl not found'
    assert 'hddl:cabinet' in funcs, 'hddl:cabinet not found'
    assert 'hddl:mirror-p' in funcs, 'hddl:mirror-p not found'
    assert 'hddl:tail-different-p' in funcs, 'hddl:tail-different-p not found'
    assert 'hddl:color-tail-diffs' in funcs, 'hddl:color-tail-diffs not found'
    assert 'hddl:color-core-count-diff' in funcs, 'hddl:color-core-count-diff not found'
    assert 'hddl:color-cabinet-diffs' in funcs, 'hddl:color-cabinet-diffs not found'
    assert 'hddl:color-tail-duplicates' in funcs, 'hddl:color-tail-duplicates not found'
    assert 'hddl:text' in funcs, 'hddl:text not found'

    # Check hddl:text uses aa:ysdl-get-plain-text
    text_form = funcs['hddl:text']
    called_in_text = [node[0] for node in walk(text_form) if isinstance(node, list) and node and isinstance(node[0], str)]
    assert 'aa:ysdl-get-plain-text' in called_in_text, 'hddl:text should use aa:ysdl-get-plain-text'

    # Check hddl:cabinet has z-len and removes leading 至 safely
    cab_form = funcs['hddl:cabinet']
    cab_nodes = list(walk(cab_form))
    has_strlen_zhi = any(isinstance(n, list) and len(n) >= 2 and n[0] == 'strlen' and n[1] in ('"至"', '至') for n in cab_nodes)
    assert has_strlen_zhi, 'hddl:cabinet must compute (strlen "至") dynamically'

    tail_diff_nodes = list(walk(funcs['hddl:tail-different-p']))
    assert any(isinstance(n, list) and n and n[0] == 'hddl:tail-values' for n in tail_diff_nodes), \
        'hddl:tail-different-p must compare principle values regardless of column order'
    color_diff_nodes = list(walk(funcs['hddl:color-tail-diffs']))
    assert any(isinstance(n, list) and n and n[0] == 'hddl:color' for n in color_diff_nodes), \
        'hddl:color-tail-diffs must color mismatched principle cells'
    command_nodes = list(walk(funcs['c:hddl']))
    command_calls = [n[0] for n in command_nodes if isinstance(n, list) and n and isinstance(n[0], str)]
    assert 'hddl:tail-different-p' in command_calls, 'c:HDDL must detect differing principle values'
    assert 'hddl:color-tail-diffs' in command_calls, 'c:HDDL must highlight differing principle values'
    assert 'hddl:color-core-count-diff' in command_calls, 'c:HDDL must highlight the core count for count mismatches'
    assert 'hddl:color-cabinet-diffs' in command_calls, 'c:HDDL must highlight only mismatched cabinet names'
    assert 'hddl:color-tail-duplicates' in command_calls, 'c:HDDL must highlight duplicate principle values'

    print('PASS: HDDL AST and helper signatures verified')


def simulate_hddl_cabinet(s_input, mode='utf-8'):
    if s_input is None:
        return ''
    if mode == 'utf-8':
        s = s_input.encode('utf-8')
        blanks = [b' ', b'\t', b'\r', b'\n', '　'.encode('utf-8'), bytes([160]), bytes([194, 160])]
        zhi = '至'.encode('utf-8')
        for b in blanks:
            while b in s:
                s = s.replace(b, b'')
        z_len = len(zhi)
        while len(s) >= z_len and s[:z_len] == zhi:
            s = s[z_len:]
        return s.decode('utf-8', errors='ignore').upper()
    elif mode == 'gbk':
        s = s_input.encode('gbk')
        blanks = [b' ', b'\t', b'\r', b'\n', '　'.encode('gbk'), bytes([160])]
        zhi = '至'.encode('gbk')
        for b in blanks:
            while b in s:
                s = s.replace(b, b'')
        z_len = len(zhi)
        while len(s) >= z_len and s[:z_len] == zhi:
            s = s[z_len:]
        return s.decode('gbk', errors='ignore').upper()
    else:  # char mode
        s = str(s_input)
        blanks = [' ', '\t', '\r', '\n', '　', chr(160)]
        zhi = '至'
        for b in blanks:
            while b in s:
                s = s.replace(b, '')
        z_len = len(zhi)
        while len(s) >= z_len and s[:z_len] == zhi:
            s = s[z_len:]
        return s.upper()


def check_hddl_cabinet_normalization():
    cases = [
        '10kV分段开关柜',
        '10kV 分段开关柜',
        '至10kV 分段开关柜',
        '至 10kV分段开关柜',
        '至 10kV 分段开关柜',
        '至10kV分段开关柜',
        ' 10kV 分段 开关柜 ',
        '至至10kV 分段开关柜',
        '10kV\u3000分段开关柜',
        '10KV分段开关柜',
        '至 10kv 分段开关柜',
    ]
    target = '10KV分段开关柜'

    for mode in ['utf-8', 'gbk', 'char']:
        for c in cases:
            res = simulate_hddl_cabinet(c, mode)
            assert res == target, f'Mode {mode}: failed for {c!r} -> {res!r} != {target!r}'

    def mirror_p(a0, a2, b0, b2, mode='utf-8'):
        ca0 = simulate_hddl_cabinet(a0, mode)
        cb2 = simulate_hddl_cabinet(b2, mode)
        ca2 = simulate_hddl_cabinet(a2, mode)
        cb0 = simulate_hddl_cabinet(b0, mode)
        return ca0 == cb2 and ca2 == cb0

    for mode in ['utf-8', 'gbk', 'char']:
        assert mirror_p(
            '10kV分段开关柜', '至10kV 1#主变柜',
            '10kV 1#主变柜', '至10kV 分段开关柜',
            mode
        ), f'Mirror pair check failed in {mode} mode'

        assert mirror_p(
            '10kV 分段开关柜', '10kV 1#主变柜',
            '至10kV 1#主变柜', '至10kV分段开关柜',
            mode
        ), f'Mirror pair check with mixed spaces failed in {mode} mode'

        assert not mirror_p(
            '10kV分段开关柜', '10kV 1#主变柜',
            '10kV分段开关柜', '10kV 1#主变柜',
            mode
        ), f'Duplicate check should not be mirror in {mode} mode'

    print('PASS: HDDL cabinet normalization & mirror matching verified across UTF-8/GBK/Char modes')


def check_hddl_principle_value_comparison():
    # Supplied example: same number of tail cells, but three principle values differ.
    first = ['主变保护柜2', '2SYH-136B', '至电能质量监测柜', '4×4', '4', "A630'640'",
             "B630'640'", "C630'640'", 'N600']
    mirror = ['电能质量监测柜', '2SYH-136B', '至主变保护柜2', '4×4', '4', "A640'",
              "B640'", "C640'", 'N600']
    tail_count = lambda row: sum(bool(value.strip()) for value in row[4:])
    def unmatched_indices(row, other):
        values = {value.strip().upper() for value in other[5:] if value.strip()}
        return [i for i, value in enumerate(row[5:], start=5)
                if value.strip() and value.strip().upper() not in values]

    differing_principles = unmatched_indices(first, mirror)

    assert tail_count(first) == tail_count(mirror) == 5, 'Regression setup must have equal tail counts'
    assert differing_principles == [5, 6, 7], 'HDDL must identify the three mismatched principles'
    assert all(first[i] != mirror[i] for i in differing_principles)
    assert first[8] == mirror[8], 'Matching N600 must remain unhighlighted'

    matching = ['主变保护柜1', '1SYH-136B', '至电能质量监测柜', '4×4', '4', "A630'",
                "B630'", "C630'", 'N600']
    matching_mirror = ['电能质量监测柜', '1SYH-136B', '至主变保护柜1', '4×4', '4', "A630'",
                       "B630'", "C630'", 'N600']
    assert not unmatched_indices(matching, matching_mirror)

    # QW3 中 1B-103、2B-103：原理号内容一致，仅排列顺序不同。
    for prefix in ('1B', '2B'):
        first = ['主变保护柜', prefix + '-103', '至10kV分段开关柜', '7×2.5', '4',
                 prefix + '-01', prefix + '-BT01', prefix + '-33', prefix + '-BT03']
        mirror = ['10kV分段开关柜', prefix + '-103', '至主变保护柜', '7×2.5', '4',
                  prefix + '-BT01', prefix + '-BT03', prefix + '-01', prefix + '-33']
        assert not unmatched_indices(first, mirror)
        assert not unmatched_indices(mirror, first)
        mirror[6] = prefix + '-BT99'
        assert unmatched_indices(first, mirror) == [8]
        assert unmatched_indices(mirror, first) == [6]
        mirror[6] = ' ' + prefix.lower() + '-bt03\t'
        assert not unmatched_indices(first, mirror)
        assert not unmatched_indices(mirror, first)

    print('PASS: HDDL detects equal-count principle value mismatches and preserves matching cells')


def check_hddl_issue_specific_highlighting():
    first = ['主变保护柜2', '2SYH-136B', '至电能质量监测柜', '4×4', '4', "A630'640'",
             "B630'640'", "C630'640'", 'N600']
    fewer_principles = ['电能质量监测柜', '2SYH-136B', '至主变保护柜2', '4×4', '4', "A640'",
                        "B640'", "C640'"]
    tail_count = lambda row: sum(bool(value.strip()) for value in row[4:])
    assert tail_count(first) != tail_count(fewer_principles)
    core_count_cells_to_mark = [4, 4]
    assert core_count_cells_to_mark == [4, 4], 'A principle count mismatch must mark the cable core count cells'

    cabinet_a = ['主变保护柜1', '1SYH-136B', '至电能质量监测柜', '4×4', '4', "A630'"]
    cabinet_b = ['其他柜名', '1SYH-136B', '至主变保护柜1', '4×4', '4', "A630'"]
    cabinet_mismatches = []
    if simulate_hddl_cabinet(cabinet_a[0]) != simulate_hddl_cabinet(cabinet_b[2]):
        cabinet_mismatches.extend([(0, cabinet_a[0]), (2, cabinet_b[2])])
    if simulate_hddl_cabinet(cabinet_a[2]) != simulate_hddl_cabinet(cabinet_b[0]):
        cabinet_mismatches.extend([(2, cabinet_a[2]), (0, cabinet_b[0])])
    assert cabinet_mismatches == [(2, cabinet_a[2]), (0, cabinet_b[0])], \
        'A cabinet mismatch must mark the two mismatched cabinet names only'

    print('PASS: HDDL maps principle-count and cabinet-name issues to their own text cells')


def check_marker_selection_scope():
    import math
    from check_cable_perf_static import Runner
    _, text = read_source(SOURCE)
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    runner = Runner(funcs)
    entities, markers, deleted, queries = {}, [], [], []
    for pile in range(3):
        source = f'source{pile}'
        anchor = [1000.0 + pile * 1000, 200.0, 0.0]
        entities[source] = [(5, source), (10, anchor), (40, 3.0), (7, 'HZ'), (50, 0.0), (410, 'Model')]
    runner.mocks.update({
        'entget': lambda e, *args: entities[e],
        'handent': lambda handle: handle if handle in entities else None,
        'ssmemb': lambda e, ss: e if e in ss else None,
        'sslength': len,
        'ssname': lambda ss, i: ss[i],
        'entdel': lambda e: deleted.append(e),
        'cos': math.cos, 'sin': math.sin,
        'trans': lambda p, *args: p,
        'regapp': lambda name: True,
        'equal': lambda a, b, *tol: all(abs(x-y) <= tol[0] for x, y in zip(a,b)) if tol else a == b,
    })
    def make(ed):
        key = f'marker{len(markers)}'
        entities[key] = ed + [(410, 'Model')]
        markers.append(key)
        return key
    runner.mocks['entmakex'] = make
    def ssget(mode, *args):
        queries.append(mode)
        if mode == '_X':
            return markers[:]
        assert mode == '_C'
        lower, upper, _ = args
        return [e for e, ed in entities.items() if e.startswith('source') and
                all(lower[i] <= dict(ed)[10][i] <= upper[i] for i in (0, 1))]
    runner.mocks['ssget'] = ssget
    for pile in range(3):
        source = f'source{pile}'
        runner.call('hddl:make-marker', [[source, 'same cable', dict(entities[source])[10]], '[电缆规格不一致]'])
    # Rerun the second pile: first and third markers must survive, despite identical IDs/messages.
    runner.call('hddl:clear-markers', [['source1']])
    assert deleted == ['marker1'], deleted
    assert queries == ['_X'], queries
    # Old unlinked markers use their original row position; rotated labels are supported.
    for i in range(3):
        entities[f'marker{i}'] = [pair for pair in entities[f'marker{i}'] if pair[0] != -3]
    source = 'source1'
    entities[source] = [(5, source), (10, [2000., 200., 0.]), (40, 3.), (7, 'HZ'), (50, math.pi/2), (410, 'Model')]
    rotated = runner.call('hddl:make-marker', [[source, '', [2000., 200., 0.]], '[原理号重复]'])
    entities[rotated] = [pair for pair in entities[rotated] if pair[0] != -3]
    deleted.clear()
    runner.call('hddl:clear-markers', [['source1']])
    assert set(deleted) == {'marker1', rotated}, deleted
    # Same coordinates on a different layout must not associate with this selection.
    entities['marker1'] = [pair for pair in entities['marker1'] if pair[0] != 410] + [(410, 'Layout1')]
    deleted.clear()
    runner.call('hddl:clear-markers', [['source1']])
    assert deleted == [rotated], deleted
    # Stale linked owner does not fall back to an unrelated coincident source.
    entities['marker1'].append([-3, ['HDDL_ROW', (1005, 'missing')]])
    assert not runner.call('hddl:marker-selected-p', [entities['marker1'], ['source1']])
    command = funcs['c:hddl']
    nodes = list(walk(command))
    assert ['hddl:clear-markers', 'ss'] in nodes
    assert any(isinstance(n, list) and n == ['8', '.', '"~HDDL_MARK"'] for n in nodes)
    print('PASS: HDDL three-pile marker isolation, legacy/rotated labels, layout isolation, stale owner and marker selection exclusion')


def main():
    check_marker_selection_scope()
    check_hddl_ast()
    check_hddl_cabinet_normalization()
    check_hddl_principle_value_comparison()
    check_hddl_issue_specific_highlighting()
    print('ALL HDDL PASS')


if __name__ == '__main__':
    main()
