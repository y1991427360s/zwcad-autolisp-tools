"""Offline regressions for cabinet command editing; never connect to CAD."""
from dataclasses import replace
from pathlib import Path
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from cabinet_panel import Entry, discover, read_source, render
import cabinet_panel
from lsp_common import parse_with_locations


SOURCE = ''';;; 包含以下命令:
;;;
;;;   - KMZ   : 选中两条水平线后向左标注直流馈线柜。
;;;   - OTHER : 保留其他命令。
;;;
;;; unrelated sentinel 中文 \\ untouched
(defun helper (x) (list x "unrelated string"))
;;; Command: KMZ
;;; Function: 选中两条水平线后向左标注直流馈线柜。
(defun c:KMZ ()
  (aa:km-ln-cmd "KMZ" T "+KM" "-KM" "直流馈线柜")
)
;;; Command: OTHER
;;; Function: 保留其他命令。
(defun c:OTHER () (princ "keep me"))
'''.replace('\n', '\r\n')


def form_texts(text):
    forms, locations = parse_with_locations(text)
    return {form[1]: text[locations[id(form)][1]:locations[id(form)][2]]
            for form in forms if isinstance(form, list) and form[:1] == ['defun']}


class CabinetPanelTests(unittest.TestCase):
    def test_real_source_discovers_entire_family(self):
        entries = discover(read_source(ROOT / 'AA整合版本.lsp'))
        expected = {'KMZ', 'KMY', 'LNZ', 'LNY', 'UPSZ', 'UPSY', 'BZ', 'BY', 'ZJ', 'YJ'}
        self.assertTrue(expected.issubset({entry.name for entry in entries}))
        self.assertEqual(len(entries), len({entry.name for entry in entries}))
        by_name = {entry.name: entry for entry in entries}
        self.assertTrue(all(isinstance(by_name[name].cabinet, str) for name in expected))
        self.assertEqual({entry.name for entry in discover(render(read_source(ROOT / 'AA整合版本.lsp'), entries))},
                         {entry.name for entry in entries})

    def test_discovery_requires_top_level_exact_wrapper(self):
        text = SOURCE + '''
; (defun c:COMMENT () (aa:km-ln-cmd "COMMENT" T "a" "b" "c"))
'(defun c:QUOTED () (aa:km-ln-cmd "QUOTED" T "a" "b" "c"))
(defun outer () (defun c:NESTED () (aa:km-ln-cmd "NESTED" T "a" "b" "c")))
(defun c:WITHARGS (x) (aa:km-ln-cmd "WITHARGS" T "a" "b" "c"))
(defun c:EXTRA () (aa:km-ln-cmd "EXTRA" T "a" "b" "c") (princ))
'''.replace('\n', '\r\n')
        self.assertEqual([entry.name for entry in discover(text)], ['KMZ'])

    def test_edit_text_direction_and_escape_roundtrip(self):
        original = discover(SOURCE)[0]
        edited = replace(original, left=False, upper='上"端', lower=r'C:\panel\下端',
                         cabinet='直流电源柜 "1号"; (测试)')
        output = render(SOURCE, [edited])
        self.assertEqual(discover(output), [edited])
        self.assertNotIn('\n', output.replace('\r\n', ''))
        forms, _ = parse_with_locations(output)
        wrapper = next(form for form in forms if isinstance(form, list) and form[:2] == ['defun', 'c:kmz'])
        self.assertEqual(wrapper[3][2], 'nil')
        self.assertEqual(len(wrapper), 4)

    def test_add_command_is_top_level_and_indexed(self):
        entries = discover(SOURCE)
        new = Entry('CUSTOM_Z', True, 'L', 'N', '1号电源馈线柜')
        output = render(SOURCE, entries + [new])
        self.assertEqual(discover(output), entries + [new])
        forms = form_texts(output)
        self.assertIn('c:custom_z', forms)
        self.assertRegex(output, r'(?m)^;;;\s+- CUSTOM_Z\s*:')
        self.assertIn(';;; Command: CUSTOM_Z', output)
        self.assertEqual(output.count('(defun c:CUSTOM_Z'), 1)
        self.assertEqual(render(output, discover(output)), output)

    def test_edit_updates_description_and_preserves_unrelated_source(self):
        edited = replace(discover(SOURCE)[0], cabinet='直流电源柜')
        output = render(SOURCE, [edited])
        self.assertNotIn('直流馈线柜', output)
        self.assertRegex(output, r'(?m)^;;;\s+- KMZ\s*:.*直流电源柜')
        self.assertRegex(output, r'(?m)^;;; Function: .*直流电源柜')
        before, after = form_texts(SOURCE), form_texts(output)
        self.assertEqual(before['helper'], after['helper'])
        self.assertEqual(before['c:other'], after['c:other'])
        self.assertIn(';;; unrelated sentinel 中文 \\ untouched', output)
        self.assertIn(';;; Command: OTHER\r\n;;; Function: 保留其他命令。', output)

    def test_reject_delete_duplicate_and_command_conflict(self):
        entries = discover(SOURCE)
        for candidate in ([], entries + entries, entries + [Entry('OTHER', True, 'L', 'N', '柜')]):
            with self.subTest(candidate=candidate), self.assertRaises(ValueError):
                render(SOURCE, candidate)

    def test_reject_invalid_names(self):
        entries = discover(SOURCE)
        for name in ('', 'abc', '1ABC', 'A-B', 'A B', '中文', 'A' * 33, 'OTHER'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                render(SOURCE, entries + [Entry(name, True, 'L', 'N', '柜')])

    def test_reject_control_characters_in_all_text_fields(self):
        original = discover(SOURCE)[0]
        for field in ('upper', 'lower', 'cabinet'):
            for char in ('\x00', '\t', '\n', '\r', '\x1b', '\x7f'):
                with self.subTest(field=field, char=repr(char)), self.assertRaises(ValueError):
                    render(SOURCE, [replace(original, **{field: '文本' + char})])

    def test_reader_rejects_bad_encoding_bom_and_mixed_newlines(self):
        invalid = (b'\xef\xbb\xbf' + SOURCE.encode('utf-8'), b'\xff\xfeBAD',
                   SOURCE.encode('utf-8') + b'\n', SOURCE.encode('utf-8') + '\ufffd'.encode('utf-8'))
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'test.lsp'
            path.write_bytes(SOURCE.encode('utf-8'))
            self.assertEqual(read_source(path), SOURCE)
            for raw in invalid:
                with self.subTest(raw=raw[:8]), self.assertRaises((ValueError, UnicodeError, AssertionError)):
                    path.write_bytes(raw)
                    read_source(path)

    def test_malformed_lisp_is_rejected(self):
        for text in (SOURCE + '(princ', SOURCE + '"unterminated', SOURCE + ';| unclosed'):
            with self.subTest(tail=text[-20:]), self.assertRaises((ValueError, AssertionError)):
                discover(text)

    def test_save_backs_up_and_runs_checks_with_new_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'AA整合版本.lsp'
            source.write_bytes(SOURCE.encode('utf-8'))
            edited = replace(discover(SOURCE)[0], cabinet='新柜名')
            observed = []

            def successful_check(args, **kwargs):
                observed.append((args, read_source(source)))
                return SimpleNamespace(returncode=0, stdout='PASS', stderr='')

            with patch.object(cabinet_panel, 'ROOT', root), patch.object(cabinet_panel, 'SOURCE', source), \
                    patch.object(cabinet_panel.subprocess, 'run', side_effect=successful_check):
                saved, message = cabinet_panel.save([edited], SOURCE)
            self.assertEqual(read_source(source), saved)
            self.assertEqual(discover(saved), [edited])
            self.assertGreaterEqual(len(observed), 3)
            self.assertTrue(all(text == saved for args, text in observed))
            self.assertEqual(len(list((root / 'backups').glob('*/AA整合版本.lsp'))), 1)
            backup = next((root / 'backups').glob('*/AA整合版本.lsp'))
            self.assertEqual(backup.read_bytes(), SOURCE.encode('utf-8'))
            self.assertFalse((root / '.cabinet-panel.tmp').exists())
            self.assertFalse(source.with_suffix('.lsp.tmp').exists())

    def test_failed_checks_restore_all_touched_artifacts(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'AA整合版本.lsp'
            source.write_bytes(SOURCE.encode('utf-8'))
            index = root / '命令索引.md'
            index.write_bytes(b'original-index')
            added = root / '命令索引.html'
            edited = replace(discover(SOURCE)[0], cabinet='新柜名')

            def failing_check(args, **kwargs):
                index.write_bytes(b'changed-index')
                added.write_bytes(b'new-index')
                return SimpleNamespace(returncode=1, stdout='', stderr='deliberate check failure')

            with patch.object(cabinet_panel, 'ROOT', root), patch.object(cabinet_panel, 'SOURCE', source), \
                    patch.object(cabinet_panel.subprocess, 'run', side_effect=failing_check):
                with self.assertRaises(ValueError):
                    cabinet_panel.save([edited], SOURCE)
            self.assertEqual(source.read_bytes(), SOURCE.encode('utf-8'))
            self.assertEqual(index.read_bytes(), b'original-index')
            self.assertFalse(added.exists())
            self.assertFalse((root / '.cabinet-panel.tmp').exists())
            self.assertFalse(source.with_suffix('.lsp.tmp').exists())

    def test_external_changes_are_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'AA整合版本.lsp'
            changed = SOURCE + '; external change\r\n'
            source.write_bytes(changed.encode('utf-8'))
            with patch.object(cabinet_panel, 'ROOT', root), patch.object(cabinet_panel, 'SOURCE', source), \
                    patch.object(cabinet_panel.subprocess, 'run') as checks:
                with self.assertRaises(ValueError):
                    cabinet_panel.save(discover(SOURCE), SOURCE)
                checks.assert_not_called()
            self.assertEqual(read_source(source), changed)
            self.assertFalse((root / '.cabinet-panel.tmp').exists())
            self.assertFalse((root / 'backups').exists())

    def test_lock_contention_preserves_existing_lock_and_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'AA整合版本.lsp'
            source.write_bytes(SOURCE.encode('utf-8'))
            lock = root / '.cabinet-panel.tmp'
            lock.write_bytes(b'other-panel-lock')
            with patch.object(cabinet_panel, 'ROOT', root), patch.object(cabinet_panel, 'SOURCE', source), \
                    patch.object(cabinet_panel.subprocess, 'run') as checks:
                with self.assertRaises(ValueError):
                    cabinet_panel.save(discover(SOURCE), SOURCE)
                checks.assert_not_called()
            self.assertEqual(lock.read_bytes(), b'other-panel-lock')
            self.assertEqual(read_source(source), SOURCE)


if __name__ == '__main__':
    unittest.main()
