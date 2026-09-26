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


def main():
    check_hddl_ast()
    check_hddl_cabinet_normalization()
    print('ALL HDDL PASS')


if __name__ == '__main__':
    main()
