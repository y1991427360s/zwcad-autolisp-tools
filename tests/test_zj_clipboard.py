"""离线执行实际 ZJ/YJ LISP AST，CAD/输入/剪贴板均用桩替代。"""
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from lsp_common import parse, read_source, defun_forms
from check_zdwi_static import evaluate


class InputCancelled(Exception):
    pass


class ZjClipboardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        _, text = read_source()
        cls.functions = {f[1]: f for f in defun_forms(parse(text))}

    def run_command(self, name, mode=None, manual='', clipboard='网络通信柜', cancel=None):
        calls = {'draw': [], 'clipboard': [], 'restore': [], 'messages': []}
        self.last_calls = calls
        selection = ['line1', 'line2']
        def keyword(prompt):
            if cancel == 'mode':
                raise InputCancelled()
            return mode
        def getstring(*args):
            if cancel == 'text':
                raise InputCancelled()
            return manual
        def clip(*args):
            calls['clipboard'].append(args)
            return clipboard
        def chars(text):
            return text.replace(r'\t', '\t').replace(r'\r', '\r').replace(r'\n', '\n')
        env = {'__functions': {n: self.functions[n] for n in ('aa:zj-cmd', 'aa:zj-clean-text')},
               '__builtins': {
                   'vl-load-com': lambda: None,
                   'ssget': lambda *args: selection,
                   'sssetfirst': lambda *args: calls['restore'].append(args),
                   'initget': lambda *args: None,
                   'getkword': keyword, 'getstring': getstring,
                   'vl-catch-all-apply': clip,
                   'vl-catch-all-error-p': lambda value: isinstance(value, Exception),
                   'type': lambda value: 'str' if isinstance(value, str) else 'nil',
                   'vl-string-trim': lambda trim, text: text.strip(chars(trim)),
                   'vl-string-translate': lambda old, new, text: text.translate(str.maketrans(chars(old), new)),
                   'aa:km-ln-cmd': lambda *args: calls['draw'].append(args),
                   'princ': lambda *args: calls['messages'].extend(args),
               }}
        for expr in self.functions['c:' + name.lower()][3:]:
            evaluate(expr, env)
        return calls

    def test_default_clipboard_and_preselection_both_directions(self):
        for name, left in [('ZJ', True), ('YJ', None)]:
            result = self.run_command(name, clipboard='  控制楼\r\n网络通信柜\t ')
            self.assertEqual(result['draw'], [(name, left, '原理号', '原理号', '控制楼  网络通信柜')])
            self.assertEqual(len(result['clipboard']), 1)
            self.assertEqual(result['restore'], [(None, ['line1', 'line2'])])

    def test_manual_text_keeps_spaces_and_never_reads_clipboard(self):
        for name in ('ZJ', 'YJ'):
            result = self.run_command(name, mode='Manual', manual='  110kV 网络通信柜  ', clipboard=RuntimeError())
            self.assertEqual(result['draw'][0][-1], '110kV 网络通信柜')
            self.assertEqual(result['clipboard'], [])

    def test_manual_empty_uses_configured_default(self):
        self.assertEqual(self.run_command('ZJ', mode='Manual')['draw'][0][-1], '终点柜名')

    def test_empty_nontext_and_clipboard_failure_do_not_draw(self):
        for value in (None, '', ' \t\r\n ', 42, RuntimeError('unavailable')):
            with self.subTest(value=value):
                result = self.run_command('ZJ', clipboard=value)
                self.assertEqual(result['draw'], [])
                self.assertEqual(result['restore'], [])
                self.assertTrue(result['messages'])
        self.assertEqual(self.run_command('YJ', mode='Manual', manual='   ')['draw'], [])

    def test_cancellation_stops_before_geometry(self):
        for where in ('mode', 'text'):
            with self.subTest(where=where), self.assertRaises(InputCancelled):
                self.run_command('ZJ', mode='Manual', cancel=where)
            self.assertEqual(self.last_calls['draw'], [])
            self.assertEqual(self.last_calls['clipboard'], [])


if __name__ == '__main__':
    unittest.main()
