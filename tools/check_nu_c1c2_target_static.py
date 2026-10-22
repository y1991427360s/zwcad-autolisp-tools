"""NU / C1 / C2 / C3 目标数字选择规则离线检查（执行真实 LISP AST，不连接 CAD）。

规则 A：井号（半角 #、全角 ＃）相邻数字；规则 B：最后一个减号（半角 -、全角 －）后的
第一段连续数字；规则 C：兜底第一段连续整数。NU 与 C1/C2/C3 共用 aa:num-target-span。

1. 用 Python 独立实现同一规则作为参照，逐条比对 LISP 实际结果；
2. 在仓库自带的离线 LISP 解释器（tests/test_ss_mm_ortho_osnap.py）里执行真实的
   aa:num-target-span / aa:num-int-target-p / aa:num-pad-int / aa:nu-rewrite-text /
   aa:nu-find-first-number / aa:nu-format-number / c1c2:first-number-span /
   c1c2:change-number，核对任务列出的全部用例；
3. 核对源码结构：新函数存在、NU 与 C1/C2/C3 都调用它、旧的“只看减号”分支已移除。
"""
import re
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOLS))
sys.path.insert(0, str(TOOLS.parent / 'tests'))

from lsp_common import SOURCE, defun_forms, parse, read_source  # noqa: E402
from test_ss_mm_ortho_osnap import Lisp, base_builtins  # noqa: E402

FW_HASH = '\uff03'
FW_HYPHEN = '\uff0d'

# 任务要求的用例：输入、期望路径、NU +2 结果、NU -1 结果（None 表示不修改）。
# C3 为 +2、C1 为 +1、C2 为 -1（以源码 c1c2:run 调用为准）。
NU_CASES = [
    ('501', 'FIRST', '503', '500'),
    ('1(2)SVG-501', 'HYPHEN', '1(2)SVG-503', '1(2)SVG-500'),
    ('1(2)SVG-503', 'HYPHEN', '1(2)SVG-505', '1(2)SVG-502'),
    ('1(2)SVG-505', 'HYPHEN', '1(2)SVG-507', '1(2)SVG-504'),
    ('35kV 1#风机回路进线柜', 'HASH', '35kV 3#风机回路进线柜', '35kV 0#风机回路进线柜'),
    ('35kV 4#风机回路进线柜', 'HASH', '35kV 6#风机回路进线柜', '35kV 3#风机回路进线柜'),
    ('35kV 1#主变进线柜', 'HASH', '35kV 3#主变进线柜', '35kV 0#主变进线柜'),
    ('35kV #1风机回路进线柜', 'HASH', '35kV #3风机回路进线柜', '35kV #0风机回路进线柜'),
    ('35kV #3风机回路进线柜', 'HASH', '35kV #5风机回路进线柜', '35kV #2风机回路进线柜'),
    ('35kV ' + FW_HASH + '2风机', 'HASH', '35kV ' + FW_HASH + '4风机', '35kV ' + FW_HASH + '1风机'),
    ('#09', 'HASH', '#11', '#08'),
    ('SVG-099', 'HYPHEN', 'SVG-101', 'SVG-098'),
    ('1.5', 'FIRST', '3.5', '0.5'),
    ('无数字文字', None, None, None),
    # 结果小于 0：NU 不修改（跳过后在命令行提示）。
    ('SVG-000', 'HYPHEN', 'SVG-002', None),
    # 前导零宽度与进位。
    ('#01', 'HASH', '#03', '#00'),
    ('SVG-009', 'HYPHEN', 'SVG-011', 'SVG-008'),
    ('SVG-99', 'HYPHEN', 'SVG-101', 'SVG-98'),
    ('SVG' + FW_HYPHEN + '009', 'HYPHEN', 'SVG' + FW_HYPHEN + '011', 'SVG' + FW_HYPHEN + '008'),
]

# 补充用例：多个井号、井号/减号后无数字、小数、正负号、纯符号等边界。
REFERENCE_CASES = [
    '12#主变', '#12', '35kV x#y 3#风机', 'A#B', 'A#B 5', '3-4#7', '##', '1#2#3',
    'ABC-', '-', '#', '1-2-3', 'W10-20', 'TAG-99', 'NO_NUMBER', 'A-01',
    '35kV 10kV 20kV', '1.5#2', '#1.5', 'Q1-2.5', 'Z-9#8', 'X#9-8',
    '000', '0#0', 'a#1b' + FW_HASH + '2c', '+2', '-3', '-1.5', 'A+2', 'A-0.5',
    '35kV 1#…', '1(2)SVG-501 (备用)', '#3 SVG-9',
]

DELTAS = [('C1', 1), ('C2', -1), ('C3', 2)]


# --------------------------------------------------------------------------------------
# Python 参照实现
# --------------------------------------------------------------------------------------
def is_digit(ch):
    return len(ch) == 1 and '0' <= ch <= '9'


def py_target_span(s):
    """返回 (start, end, kind)，start/end 为 0 起闭区间；没有整数位返回 None。"""
    first_s = first_e = None
    for i, ch in enumerate(s):
        if is_digit(ch):
            if first_s is None:
                first_s = i
            first_e = i
    for i, ch in enumerate(s):
        if ch in ('#', FW_HASH):
            if i > 0 and is_digit(s[i - 1]):
                start = i - 1
                while start > 0 and is_digit(s[start - 1]):
                    start -= 1
                return (start, i - 1, 'HASH')
            if i + 1 < len(s) and is_digit(s[i + 1]):
                end = i + 1
                while end + 1 < len(s) and is_digit(s[end + 1]):
                    end += 1
                return (i + 1, end, 'HASH')
    hyphen = None
    for i, ch in enumerate(s):
        if ch in ('-', FW_HYPHEN):
            hyphen = i
    if hyphen is not None:
        for i in range(hyphen + 1, len(s)):
            if is_digit(s[i]):
                end = i
                while end + 1 < len(s) and is_digit(s[end + 1]):
                    end += 1
                return (i, end, 'HYPHEN')
    if first_s is not None:
        return (first_s, first_e, 'FIRST')
    return None


def py_find_first_number(s):
    """模拟 aa:nu-find-first-number：返回 (start, end, token)，1 起含端点；无则 None。"""
    i = 0
    while i < len(s):
        ch = s[i]
        starts = is_digit(ch) or (ch == '.' and i + 1 < len(s) and is_digit(s[i + 1])) or (
            ch in '+-' and i + 1 < len(s) and (
                is_digit(s[i + 1]) or (s[i + 1] == '.' and i + 2 < len(s) and is_digit(s[i + 2]))))
        if starts:
            j = i + 1 if ch in '+-' else i
            end = None
            while j < len(s) and is_digit(s[j]):
                end = j
                j += 1
            if end is not None and j < len(s) and s[j] == '.' and j + 1 < len(s) and is_digit(s[j + 1]):
                j += 1
                while j < len(s) and is_digit(s[j]):
                    end = j
                    j += 1
            if end is not None:
                return (i + 1, end + 1, s[i:end + 1])
        i += 1
    return None


def rtos(value, mode=2, prec=4):
    """AutoLISP rtos 模拟（DIMZIN=0）：去末尾 0，保留末尾小数点。"""
    text = ('%.' + str(int(prec)) + 'f') % value
    return text.rstrip('0') if '.' in text else text


def trim_number(value):
    """模拟 aa:nu-trim-number-string。"""
    text = value if isinstance(value, str) else rtos(value)
    if '.' in text:
        text = text.rstrip('0')
        if text.endswith('.'):
            text = text[:-1]
    return '0' if text in ('', '-0', '+0') else text


def pad_int(value, width):
    """模拟 aa:num-pad-int：整数按原位数补前导零。"""
    return str(int(value)).rjust(width, '0')


def py_format_number(value, old_token):
    """模拟 aa:nu-format-number（兜底路径的数值格式）。"""
    raw = trim_number(rtos(value))
    body = old_token
    keep_plus = False
    if body.startswith('+'):
        keep_plus, body = True, body[1:]
    elif body.startswith('-'):
        body = body[1:]
    if value == int(value) and len(body) > 1 and body.startswith('0') and body.isdigit():
        raw = ('-' if value < 0 else ('+' if keep_plus else '')) + str(abs(int(value))).rjust(len(body), '0')
    elif keep_plus and value >= 0 and raw != '':
        raw = '+' + raw
    return raw


def py_nu_rewrite(s, delta):
    """模拟 aa:nu-rewrite-text：HASH/HYPHEN 按整数与位宽，FIRST 沿用原第一个数字流程。"""
    span = py_target_span(s)
    if span and span[2] in ('HASH', 'HYPHEN'):
        start, end, _ = span
        value = int(s[start:end + 1]) + delta
        if value < 0:
            return None
        return s[:start] + pad_int(value, end - start + 1) + s[end + 1:]
    token = py_find_first_number(s)
    if not token:
        return None
    start, end, text = token
    return s[:start - 1] + py_format_number(float(text) + delta, text) + s[end:]


def py_c1c2(s, delta):
    span = py_target_span(s)
    if not span:
        return None
    start, end, _ = span
    length = end - start + 1
    # c1c2:change-number 用 atoi 取整段：AutoLISP atoi 遇到小数点即停止，只取前面整数位。
    lead = re.match(r'[+-]?[0-9]*', s[start:end + 1].lstrip()).group(0)
    value = (int(lead) if lead else 0) + delta
    text = str(value).zfill(length) if value >= 0 else str(value)
    return s[:start] + text + s[end + 1:]


# --------------------------------------------------------------------------------------
# 离线 LISP 解释器
# --------------------------------------------------------------------------------------
def build_lisp():
    _, text = read_source()
    forms = parse(text)
    wanted = ('aa:nu', 'aa:num-', 'aa:digit-char-p', 'c1c2:')
    funcs = {f[1]: f for f in defun_forms(forms)
             if isinstance(f[1], str) and f[1].startswith(wanted)}
    builtins = base_builtins()
    builtins.update({
        'strlen': len,
        'substr': lambda s, i, n=None: s[i - 1:i - 1 + n] if n is not None else s[i - 1:],
        'ascii': lambda c: ord(c[0]) if isinstance(c, str) and c else 0,
        # AutoLISP atoi：跳过前导空白，接受一个前导符号，遇到非数字（含小数点）即停止。
        'atoi': lambda s: int(re.match(r'[+-]?[0-9]*', s.lstrip()).group(0) or 0) if s else 0,
        'itoa': lambda n: str(int(n)),
        'fix': lambda x: int(x),
        'distof': lambda s, m=None: float(s),
        'rtos': rtos,
        'vl-string-search': lambda p, s, st=0: (lambda r: None if r < 0 else r)(s.find(p, st)),
        'numberp': lambda x: True if isinstance(x, (int, float)) else None,
        'type': lambda x: 'STR' if isinstance(x, str) else 'REAL',
        '1+': lambda x: x + 1,
        '1-': lambda x: x - 1,
        '>': lambda a, b: True if a > b else None,
        '<': lambda a, b: True if a < b else None,
        '>=': lambda *a: True if all(x >= y for x, y in zip(a, a[1:])) else None,
        '<=': lambda *a: True if all(x <= y for x, y in zip(a, a[1:])) else None,
        # 离线解释器差异（仅模拟用，不改源码）：
        # 1) and 会短路，真实 AutoLISP 的 aa:digit-char-p 依赖 (setq code ...) 在 and 内求值；
        # 2) while 中对 str 变量重新 setq 不生效，aa:nu-trim-number-string 依赖这一行为。
        # 两处都以同语义 Python 实现注入，保证比对的是真实 LISP 控制流。
        'aa:digit-char-p': lambda c: (True if is_digit(c) else None) if isinstance(c, str) else None,
        'aa:nu-trim-number-string': trim_number,
    })
    return Lisp(funcs, builtins), funcs


def truthy(v):
    return v is not None and v is not False and v != []


# --------------------------------------------------------------------------------------
# 源码结构检查
# --------------------------------------------------------------------------------------
def check_structure(source, funcs):
    problems = []

    def calls(name, callee):
        f = funcs.get(name)
        return f is not None and callee in repr(f[3:])

    for name in ('aa:num-target-span', 'aa:num-next-digit-pos', 'aa:num-digit-run-len',
                 'aa:num-pad-int', 'aa:num-int-target-p', 'aa:nu-rewrite-text',
                 'c1c2:first-number-span', 'c:nu', 'c:c1', 'c:c2', 'c:c3'):
        if name not in funcs:
            problems.append(f'缺少 {name}')
    if 'aa:num-target-span' in funcs:
        body = repr(funcs['aa:num-target-span'])
        if 'vl-sort' in body:
            problems.append('aa:num-target-span 不得使用 vl-sort')
        if 'wcmatch' in body or 'vl-string-search' in body:
            problems.append('aa:num-target-span 应只逐字符判断，不用模式匹配/搜索')
    if not calls('aa:nu-rewrite-text', 'aa:num-target-span'):
        problems.append('aa:nu-rewrite-text 未调用 aa:num-target-span')
    if not calls('aa:nu-rewrite-text', 'aa:nu-find-first-number'):
        problems.append('aa:nu-rewrite-text 兜底未保留 aa:nu-find-first-number')
    if not calls('aa:nu-rewrite-text', 'aa:num-pad-int'):
        problems.append('aa:nu-rewrite-text 未按 aa:num-pad-int 保留前导零')
    if not calls('c:nu', 'aa:nu-rewrite-text'):
        problems.append('c:NU 未调用 aa:nu-rewrite-text')
    if not calls('c:nu', 'aa:num-int-target-p'):
        problems.append('c:NU 未按 aa:num-int-target-p 统计跳过')
    if not calls('c1c2:first-number-span', 'aa:num-target-span'):
        problems.append('c1c2:first-number-span 未调用 aa:num-target-span')
    if 'c1c2:first-number-span' in funcs:
        params = funcs['c1c2:first-number-span'][2]
        for legacy in ('last-hyphen', 'after'):
            if legacy in params:
                problems.append(f'c1c2:first-number-span 残留旧局部变量 {legacy}')
    if not calls('c1c2:run', 'c1c2:first-number-span'):
        problems.append('c1c2:run 未调用 c1c2:first-number-span')
    for cmd, delta in [('c:c1', '1'), ('c:c2', '-1'), ('c:c3', '2')]:
        if cmd in funcs and ['c1c2:run', delta] not in funcs[cmd][3:]:
            problems.append(f'{cmd} 未调用 c1c2:run {delta}')
    # 旧的“只看最后一个减号”实现必须已移除。
    span_body = repr(funcs.get('c1c2:first-number-span', []))
    if 'last-hyphen' in span_body or 'c1c2:is-digit' in span_body:
        problems.append('c1c2:first-number-span 仍为旧的只看减号实现')
    if '优先把减号后的连续数字' in source:
        problems.append('C1/C2/C3 旧注释未更新')
    if '优先井号相邻数字，其次减号后数字' not in source:
        problems.append('C1/C2/C3 注释未写“优先井号相邻数字，其次减号后数字”')
    # 文件头命令清单。
    header = source.split('(defun', 1)[0]
    expect = {
        'NU': ['井号', '减号', '第一个数字'],
        'C1': ['井号', '减号', '加 1'],
        'C2': ['井号', '减号', '减 1'],
        'C3': ['井号', '减号', '加 2'],
    }
    for cmd, words in expect.items():
        m = re.search(r'^;;;\s*-\s*' + cmd + r'\s*:.*$', header, re.M)
        if not m:
            problems.append(f'头部命令清单缺少 {cmd}')
            continue
        for word in words:
            if word not in m.group(0):
                problems.append(f'头部命令清单 {cmd} 说明缺少“{word}”')
    return problems


# --------------------------------------------------------------------------------------
# 主检查
# --------------------------------------------------------------------------------------
def check(path=None):
    source_path = Path(path) if path else SOURCE
    data = source_path.read_bytes()
    assert not data.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM'
    source = data.decode('utf-8', errors='strict')
    assert '\ufffd' not in source, 'U+FFFD present'
    assert b'\n' not in data.replace(b'\r\n', b''), 'bare LF present'

    forms = parse(source)
    defs, all_defs = {}, {}
    for f in defun_forms(forms):
        if isinstance(f[1], str):
            all_defs.setdefault(f[1].lower(), f)
            defs[f[1]] = f
    problems = check_structure(source, all_defs)
    if problems:
        print('FAIL 结构检查：')
        for p in problems:
            print('  -', p)
        raise AssertionError(f'{len(problems)} 项结构问题')
    print('PASS 结构：aa:num-target-span 存在；NU 与 C1/C2/C3 均调用；旧“只看减号”分支已移除；'
          '头部命令清单 NU/C1/C2/C3 已更新')

    lisp, _ = build_lisp()
    failures, total = [], 0

    def compare(label, got, want):
        nonlocal total
        total += 1
        got = [got[0], got[1], str(got[2]).upper()] if isinstance(got, list) and len(got) == 3 else got
        if (got if got not in (False, []) else None) != (want if want not in (False, []) else None):
            failures.append(f'{label}: LISP {got!r} != 期望 {want!r}')

    # 1) 参照实现 vs LISP 实际实现，逐条比对全部用例。
    for s in [c[0] for c in NU_CASES] + REFERENCE_CASES:
        span = py_target_span(s)
        want = None if span is None else [span[0] + 1, span[1] + 1, span[2]]
        got = lisp.call('aa:num-target-span', [s], {})
        got = [got[0], got[1], str(got[2]).upper()] if got else None
        compare(f'aa:num-target-span {s!r}', got, want)
        compare(f'aa:num-int-target-p {s!r}', lisp.call('aa:num-int-target-p', [s], {}),
                True if span and span[2] in ('HASH', 'HYPHEN') else None)
        for delta in (2, -1, 1):
            got = lisp.call('aa:nu-rewrite-text', [s, delta], {})
            compare(f'aa:nu-rewrite-text {s!r} {delta:+}', got, py_nu_rewrite(s, delta))
        for cmd, delta in DELTAS:
            got = lisp.call('c1c2:change-number', [s, delta], {})
            compare(f'c1c2:change-number({cmd}) {s!r}', got, py_c1c2(s, delta))

    # 2) 任务用例的显式期望 + NU 与 C1/C2/C3 目标位置一致性。
    for text, kind, nu_plus2, nu_minus1 in NU_CASES:
        span = py_target_span(text)
        compare(f'{text!r} 参照路径', span[2] if span else None, kind)

        got = lisp.call('aa:nu-rewrite-text', [text, 2], {})
        compare(f'NU {text!r} +2', got, nu_plus2)
        got = lisp.call('aa:nu-rewrite-text', [text, -1], {})
        compare(f'NU {text!r} -1', got, nu_minus1)
        skipped = truthy(lisp.call('aa:num-int-target-p', [text], {})) and got is None
        compare(f'NU {text!r} 跳过判定', skipped, kind in ('HASH', 'HYPHEN') and nu_minus1 is None)

        nu_span = lisp.call('aa:num-target-span', [text], {})
        c_span = lisp.call('c1c2:first-number-span', [text], {})
        compare(f'C1/C2/C3 {text!r} 目标位置',
                [c_span[0], c_span[0] + c_span[1] - 1] if c_span else None,
                [nu_span[0], nu_span[1]] if nu_span else None)
        for cmd, delta in DELTAS:
            got = lisp.call('c1c2:change-number', [text, delta], {})
            compare(f'{cmd} {text!r} {delta:+}', got, py_c1c2(text, delta))

    # 3) 数值格式细节（前导零、进位、减号原样保留、小数增量只取整数位）。
    format_cases = [
        ('#01', 1, '#02'),
        ('SVG-009', 1, 'SVG-010'),
        ('SVG-99', 1, 'SVG-100'),
        ('#09', 2, '#11'),
        ('#09', -0.5, '#08'),
        ('SVG-009', 0.5, 'SVG-009'),
        ('#01', 0.5, '#01'),
        ('SVG-50', -1.5, 'SVG-48'),
    ]
    for text, delta, want in format_cases:
        compare(f'NU 格式 {text!r} {delta:+}', lisp.call('aa:nu-rewrite-text', [text, delta], {}), want)
    compare('aa:num-pad-int 72,3', lisp.call('aa:num-pad-int', [72, 3], {}), '072')
    compare('aa:num-pad-int 100,2', lisp.call('aa:num-pad-int', [100, 2], {}), '100')

    if failures:
        print(f'FAIL 用例：{len(failures)} 项不符（共 {total} 次断言）')
        for f in failures:
            print('  -', f)
        raise AssertionError(f'{len(failures)}/{total} 用例不符')

    print(f'PASS 用例：{len(NU_CASES)} 条任务用例 + {len(REFERENCE_CASES)} 条补充用例，'
          f'{total} 次断言全部与 Python 参照一致')
    print('PASS: NU/C1/C2/C3 目标数字规则（井号 > 减号 > 兜底）、前导零宽度、结果小于 0 跳过')
    return 0


if __name__ == '__main__':
    check(Path(sys.argv[1]) if len(sys.argv) > 1 else SOURCE)
