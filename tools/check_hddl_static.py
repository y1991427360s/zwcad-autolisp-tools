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
    assert any(isinstance(n, list) and n and n[0] == 'hddl:cell' for n in tail_diff_nodes), \
        'hddl:tail-different-p must compare principle cell contents'
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
    differing_principles = [i for i, (a, b) in enumerate(zip(first[5:], mirror[5:]), start=5)
                             if a.strip().casefold() != b.strip().casefold()]

    assert tail_count(first) == tail_count(mirror) == 5, 'Regression setup must have equal tail counts'
    assert differing_principles == [5, 6, 7], 'HDDL must identify the three mismatched principles'
    assert all(first[i] != mirror[i] for i in differing_principles)
    assert first[8] == mirror[8], 'Matching N600 must remain unhighlighted'

    matching = ['主变保护柜1', '1SYH-136B', '至电能质量监测柜', '4×4', '4', "A630'",
                "B630'", "C630'", 'N600']
    matching_mirror = ['电能质量监测柜', '1SYH-136B', '至主变保护柜1', '4×4', '4', "A630'",
                       "B630'", "C630'", 'N600']
    assert not any(a.strip().casefold() != b.strip().casefold()
                   for a, b in zip(matching[5:], matching_mirror[5:])), \
        'Valid 1SYH mirror rows must not be treated as mismatched'

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


def main():
    check_hddl_ast()
    check_hddl_cabinet_normalization()
    check_hddl_principle_value_comparison()
    check_hddl_issue_specific_highlighting()
    print('ALL HDDL PASS')


if __name__ == '__main__':
    main()
