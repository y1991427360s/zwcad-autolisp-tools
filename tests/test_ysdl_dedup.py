"""Offline YSDL2 dedup regression; executes the real LISP AST, never connects to CAD."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from lsp_common import defun_forms, parse, read_source, walk  # noqa: E402
from test_ss_mm_ortho_osnap import Lisp, base_builtins  # noqa: E402


def strict_nth(i, lst):
    """用户在中望 2026 实测：YSDL2 报“参数类型错误: consp nil”，按取空表或越界就报错来测。"""
    if not lst or i >= len(lst):
        raise TypeError('参数类型错误: consp nil')
    return lst[i]


def build():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    b = base_builtins()
    b.update({
        'nth': strict_nth,
        'length': lambda l: len(l) if l else 0,
        'assoc': lambda k, l: next((p for p in (l or []) if p[0] == k), None),
        'vl-string-search': lambda pat, s, start=0: (lambda r: None if r < 0 else r)(s.find(pat, start)),
        'strlen': len,
        'substr': lambda s, i, n=None: s[i - 1:i - 1 + n] if n is not None else s[i - 1:],
        'strcase': lambda s: s.upper(),
        'chr': chr,
        'vl-list->string': lambda codes: bytes(codes).decode('utf-8'),
        'vl-string-subst': lambda new, old, s: s.replace(old, new, 1),
    })
    return Lisp(funcs, b), funcs


def dedup(lisp, rows, state=None):
    return lisp.call('aa:ysdl-dedup-rows', [rows, state], {})


# 用户截图：GTY 整理后的 4 列表（起点、编号、终点、规格），1ZYB-999 只有一行
SCREENSHOT = [
    ['35kV 故障录波柜', '2ZYB-103', '至35kV 2#站用变进线柜', '4×4'],
    ['35kV 2#站用变进线柜', '2ZYB-103', '至35kV 故障录波柜', '4×4'],
    ['宽频同步相量测量采集柜', '1ZYB-104', '至35kV 1#站用变进线柜', '4×4'],
    ['35kV 1#站用变进线柜', '1ZYB-104', '至宽频同步相量测量采集柜', '4×4'],
    ['35kV 1#站用变', '1ZYB-999', '至35kV 1#站用变进线柜', '4×4'],
    ['35kV 1#站用变进线柜', '1ZYB-105B', '至35kV 1#站用变', '7×1.5'],
    ['35kV 1#站用变', '1ZYB-105B', '至35kV 1#站用变进线柜', '7×1.5'],
]


class YsdlDedup(unittest.TestCase):
    def setUp(self):
        self.lisp, self.funcs = build()

    def test_mirror_pairs_keep_first_row_and_single_rows_stay(self):
        kept, _, odd, skipped = dedup(self.lisp, SCREENSHOT)
        self.assertEqual(kept, [SCREENSHOT[0], SCREENSHOT[2], SCREENSHOT[4], SCREENSHOT[5]])
        self.assertIsNone(odd)
        self.assertEqual(skipped, 3)

    def test_row_with_more_columns_keeps_its_tail(self):
        rows = [['A柜', 'K-1', '至B柜', '4×4', '2', '101', '103'],
                ['B柜', 'K-1', '至A柜', '4×4', '2', '101', '103']]
        kept, _, odd, skipped = dedup(self.lisp, rows)
        self.assertEqual(kept, rows[:1])
        self.assertIsNone(odd)
        self.assertEqual(skipped, 1)

    def test_non_adjacent_rows_and_state_across_boxes(self):
        first = dedup(self.lisp, [SCREENSHOT[0], SCREENSHOT[2]])
        second = dedup(self.lisp, [SCREENSHOT[3], SCREENSHOT[1], SCREENSHOT[4]], first)
        self.assertEqual(second[0], [SCREENSHOT[4]])
        self.assertEqual(second[3], 2)

    def test_conflicting_rows_are_reported(self):
        rows = [['A柜', 'K-1', '至B柜', '4×4'],
                ['C柜', 'K-1', '至D柜', '4×4'],     # 两端对不上
                ['A柜', 'K-2', '至B柜', '4×4'],
                ['B柜', 'K-2', '至A柜', '7×1.5'],   # 规格对不上
                ['A柜', 'K-1', '至E柜', '4×4']]     # 同编号第三行，只记一次
        kept, _, odd, skipped = dedup(self.lisp, rows)
        self.assertEqual(kept, [rows[0], rows[2]])
        self.assertEqual(sorted(odd), ['K-1', 'K-2'])
        self.assertEqual(skipped, 3)

    def test_spaces_and_zhi_do_not_count_as_a_mismatch(self):
        # 用户实测 1B-102A：起点写 GIS1#，对端写 GIS 1#，曾被误报
        rows = [['110kV GIS1#主变汇控柜', '1B-102A', '至1#主变测控柜', '4×4', '4'],
                ['1#主变测控柜', '1B-102A', '至110kV GIS 1#主变汇控柜', '4×4', '4'],
                ['A　柜', 'K-1', '至 B柜', '4 × 4'],
                ['至B柜', ' K-1 ', 'A柜', '4×4']]
        kept, _, odd, skipped = dedup(self.lisp, rows)
        self.assertEqual(kept, [rows[0], rows[2]])
        self.assertIsNone(odd)
        self.assertEqual(skipped, 2)

    def test_rows_without_a_cable_number_stay(self):
        rows = [['备注'], ['备注'], ['A柜', '', '至B柜'], ['A柜', '', '至B柜']]
        kept, _, odd, skipped = dedup(self.lisp, rows)
        self.assertEqual(kept, rows)
        self.assertIsNone(odd)
        self.assertEqual(skipped, 0)

    def test_commands_share_the_run_function(self):
        self.assertEqual(self.funcs['c:ysdl'][3:], [['aa:ysdl-run', '"YSDL"', 'nil']])
        self.assertEqual(self.funcs['c:ysdl2'][3:], [['aa:ysdl-run', '"YSDL2"', 't']])

    def test_rows_are_deduped_before_numbering_and_export(self):
        body = self.funcs['aa:ysdl-run'][3:]
        calls = [n for n in walk(body) if n[0] == 'aa:ysdl-dedup-rows']
        self.assertEqual([c[1] for c in calls], ['box-rows', 'all-rows'])
        for rows in ('box-rows', 'all-rows'):
            with self.subTest(rows=rows):
                block = next(n for n in walk(body) if ['foreach', 'raw-row', rows] in
                             [x[:3] for x in n if isinstance(x, list)])
                order = [x[:3] for x in block if isinstance(x, list)]
                loop = order.index(['foreach', 'raw-row', rows])
                self.assertEqual(order[loop - 1][:2], ['if', 'once'])


if __name__ == '__main__':
    unittest.main()
