"""Reader and audit regressions built from deliberate bad/good LISP fixtures."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / 'scripts'), str(ROOT / 'tools')]
from lsp_common import parse, parse_with_locations, read_source, defun_forms
from audit_lsp import scan, outputs
from sync_common import rendered


class ReaderTests(unittest.TestCase):
    def test_strings_comments_quotes_and_locations(self):
        text = '; (defun c:FAKE ())\n;| " ) ;| nested |; |;\n(defun c:X () (princ "中文; (\\\" )"))\n\'c:X'
        forms, loc = parse_with_locations(text)
        self.assertEqual(forms[0][1], 'c:x')
        self.assertEqual(loc[id(forms[0])][0], 3)
        self.assertEqual(text[slice(*loc[id(forms[0])][1:])], '(defun c:X () (princ "中文; (\\\" )"))')
        self.assertEqual(forms[1], ['quote', 'c:x'])

    def test_reject_malformed_input(self):
        for text in ('(a', ')', "'", '"unterminated', '"escaped\\"', ';| unterminated', '(princ "\\'):
            with self.subTest(text=text), self.assertRaises(AssertionError):
                parse(text)


class AuditTests(unittest.TestCase):
    def audit(self, sources):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, value in sources.items():
                (root / name).write_bytes(value.replace('\n', '\r\n').encode('utf-8'))
            return scan(root)

    def test_duplicate_case_and_quote_data(self):
        _, findings, _, _ = self.audit({'one.lsp': '(defun c:X () nil)\n',
                                      'two.LSP': "'(defun c:FAKE () nil)\n(defun c:x () nil)\n"})
        self.assertEqual(sum(f['rule'] == 'duplicate-function' for f in findings), 1)
        self.assertEqual(sum(f['rule'] == 'command-conflict' for f in findings), 1)

    def test_guards_scopes_and_restore_candidates(self):
        _, findings, _, globals_ = self.audit({'one.lsp': '''
(defun c:bad (/ ss old)
  (setq ss (ssget) old (getvar "OSMODE"))
  (sslength ss) (setvar "OSMODE" 0) (vla-startundomark doc))
(defun c:good (/ ss old item)
  (setq ss (ssget) old (getvar "OSMODE"))
  (if ss (sslength ss)) (foreach item '(1 2) (princ item))
  (setvar "OSMODE" 0) (setvar "OSMODE" old))
(defun c:direct () (entget (car (entsel))))
(defun c:fragile () (vla-startundomark doc) (entdel en) (vla-endundomark doc))
(defun helper (arg / local) (setq arg 1 local 2 shared 3))
''', 'two.lsp': '(setq shared 4)\n'})
        bad = {f['rule'] for f in findings if f['function'] == 'c:bad'}
        self.assertTrue({'nil-selection', 'sysvar-restore', 'undo-close'} <= bad)
        self.assertFalse(any(f['function'] == 'c:good' for f in findings))
        self.assertTrue(any(f['function'] == 'c:direct' and f['rule'] == 'nil-selection' for f in findings))
        self.assertTrue(any(f['function'] == 'c:fragile' and f['rule'] == 'undo-error-path' for f in findings))
        self.assertEqual(set(globals_), {'shared'})
        self.assertTrue(any(f['rule'] == 'shared-global' for f in findings))

    def test_nested_command_and_error_handler(self):
        _, findings, _, _ = self.audit({'a.lsp': '(defun c:X () (defun *error* (m) (princ m)) (defun c:Y () nil))'})
        self.assertTrue({'nested-command', 'error-binding', 'error-cleanup'} <= {f['rule'] for f in findings})

    def test_encoding_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / 'a.lsp').write_bytes(b'\xef\xbb\xbf(princ)\r\n')
            with self.assertRaises(AssertionError):
                scan(Path(directory))

    def test_common_expansion_is_idempotent_and_preserves_ast(self):
        template = (ROOT / 'common/aicad_pure.lsp').read_text(encoding='utf-8')
        for namespace in ('aicad:', 'aicadloader:'):
            source = template.replace('common:', namespace)
            output = rendered(source, template, namespace)
            self.assertEqual(parse(source), parse(output))
            self.assertEqual(rendered(output, template, namespace), output)

    def test_document_generation_with_cond_and_quoted_filter(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = '(defun c:X (/ ss) (setq ss (ssget \'((0 . "TEXT,MTEXT")))) (cond (ss (getpoint "指定点: ") (entdel (ssname ss 0)))))\r\n'
            (root / 'a.lsp').write_bytes(source.encode('utf-8'))
            generated = outputs(root)
            self.assertIn('TEXT, MTEXT', generated['COMMANDS.md'].replace('MTEXT, TEXT', 'TEXT, MTEXT'))
            self.assertIn('指定点:', generated['COMMANDS.md'])
            self.assertEqual(outputs(root), generated)

    def test_affected_functions_keep_top_level_entries_and_locals(self):
        expected = {
            'AA整合版本.lsp': {'c:ysdl': {'row'}, 'txt2:lwpoly-segments': {'item'},
                             'txt2:modify-text': {'seg'}, 'qw:join': {'it', 'r'},
                             'hddl:tail-count': {'rec'}, 'c:tong': {'txt'}},
            'V6/aicad_aa_loader.lsp': {'aicadloader:show-replace-panel': {'replace-panel-result'}},
            'V6/aicad_extension.lsp': {'aicad:join': {'item'}, 'aicad:replace-pairs-preview': {'pair'},
                                     'aicad:selection-summary': {'item'}},
        }
        for path, names in expected.items():
            _, text = read_source(ROOT / path)
            functions = {f[1]: f for f in defun_forms(parse(text))}
            for name, required in names.items():
                with self.subTest(function=name):
                    args = functions[name][2]
                    self.assertIn('/', args)
                    self.assertTrue(required <= set(args[args.index('/')+1:]))


if __name__ == '__main__':
    unittest.main()
