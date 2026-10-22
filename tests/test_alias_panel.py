# -*- coding: utf-8 -*-
"""Offline regressions for alias panel PGP parsing/writing; never touch the real %AppData% PGP."""
from __future__ import annotations

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import alias_pgp
from alias_pgp import (
    AliasEntry,
    AliasError,
    FLAG_NATIVE,
    apply_master,
    apply_to_pgp,
    detect_encoding,
    discover_user_aliases,
    parse_master_bytes,
    parse_pgp,
    render_master_bytes,
    render_pgp,
    validate_master,
    override_conflicts,
    stale_target_warnings,
)

FIXTURES = ROOT / "tools" / "fixtures"
PLUGIN_COMMANDS = {"FDX", "CC", "ZTF", "DX", "QSTXT", "COPYPLUGIN"}
KNOWN_TARGETS = {"COPY", "CIRCLE", "ROTATE", "FILLET", "GROUP", "-GROUP", "QSTXT", "FIND",
                 "ARCHDWGEXPORT", "3DARRAY", "ARC", "APPLOAD", "ERASE", "LINE", "MOVE", "ZOOM",
                 "GROUPUNNAME", "REDRAW"}


def load_fixture(name):
    return (FIXTURES / name).read_bytes()


class EncodingTests(unittest.TestCase):
    def test_detect_gbk(self):
        raw = load_fixture("sample_gbk.pgp")
        self.assertEqual(detect_encoding(raw), "gbk")

    def test_detect_utf8(self):
        raw = load_fixture("sample_utf8.pgp")
        self.assertEqual(detect_encoding(raw), "utf-8")

    def test_roundtrip_unchanged_gbk(self):
        raw = load_fixture("sample_gbk.pgp")
        doc = parse_pgp(raw)
        self.assertEqual(render_pgp(doc, doc.lines), raw)

    def test_roundtrip_unchanged_utf8(self):
        raw = load_fixture("sample_utf8.pgp")
        doc = parse_pgp(raw)
        self.assertEqual(render_pgp(doc, doc.lines), raw)


class DiscoverTests(unittest.TestCase):
    def test_discovers_tail_custom_aliases(self):
        doc = parse_pgp(load_fixture("sample_gbk.pgp"))
        entries, uncertain = discover_user_aliases(doc, PLUGIN_COMMANDS)
        got = {e.alias: e.target for e in entries}
        self.assertEqual(got, {
            "TXDC": "ARCHDWGEXPORT", "CI": "CIRCLE", "C": "COPY", "FIL": "FILLET",
            "G": "GROUP", "-G": "-GROUP", "Q": "QSTXT", "R": "ROTATE",
        })
        commented = {alias for alias, _ in uncertain}
        self.assertIn("F", commented)

    def test_no_discover_when_managed_exists(self):
        doc = parse_pgp(load_fixture("sample_gbk.pgp"))
        entries = [AliasEntry("C", "COPY")]
        lines, _ = apply_master(doc, entries)
        raw = render_pgp(doc, lines)
        doc2 = parse_pgp(raw)
        self.assertEqual(discover_user_aliases(doc2, PLUGIN_COMMANDS), ([], []))


class RealStructureTests(unittest.TestCase):
    """用 sample_real.pgp（模拟真实结构：默认区含 C/G/R，用户区也含 C/G/R）。"""

    MASTER = [
        AliasEntry("TXDC", "ARCHDWGEXPORT"), AliasEntry("CI", "CIRCLE"),
        AliasEntry("C", "COPY"), AliasEntry("FIL", "FILLET"),
        AliasEntry("G", "GROUP"), AliasEntry("-G", "-GROUP"),
        AliasEntry("Q", "QSTXT"), AliasEntry("R", "ROTATE"),
    ]

    def _doc(self):
        return parse_pgp(load_fixture("sample_real.pgp"))

    def test_first_apply_comments_default_rows_and_moves_user_rows(self):
        doc = self._doc()
        lines, report = apply_master(doc, self.MASTER)
        # 默认区三条被注释而不是被删除（1-based 行号：C=14, G=19, R=24）
        commented_lines = {line_no for line_no, _ in report["commented"]}
        self.assertEqual(commented_lines, {14, 19, 24})
        for line_no, alias in report["commented"]:
            raw = lines[line_no - 1].raw
            self.assertTrue(raw.startswith("; "), f"第 {line_no} 行应在原行前加 '; ' 注释")
            self.assertIn(alias_pgp.OVERIDDEN_NOTE, raw)
        # 用户区行被移入区块（原位置不再存在）
        moved = {line_no for line_no, _ in report["moved"]}
        self.assertEqual(moved, {33, 34, 35, 36, 38, 39, 40, 41})
        # 区块外不再有任何启用的 C/G/R/-G 别名行
        begin = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_BEGIN][0]
        outside_active = [l for l in lines[:begin]
                          if l.alias and not l.comment and l.alias.upper() in ("C", "G", "R", "-G")]
        self.assertEqual(outside_active, [])
        text = "\r\n".join(l.raw for l in lines)
        # 被注释的 -G 行保持原样
        self.assertIn(";-G,        *-GROUP", text)
        # 被注释的 F 行保持原样
        self.assertIn("; F,         *FILLET", text)
        self.assertIn("; F,        *FIND", text)

    def test_first_apply_warns_only_three_overrides(self):
        doc = self._doc()
        warnings = override_conflicts(self.MASTER, doc)
        override_warns = [w for w in warnings if "覆盖中望默认" in w]
        move_warns = [w for w in warnings if "迁入托管区块" in w]
        self.assertEqual(len(override_warns), 3)
        self.assertTrue(any("CIRCLE" in w for w in override_warns))
        self.assertTrue(any("GROUPUNNAME" in w for w in override_warns))
        self.assertTrue(any("REDRAW" in w for w in override_warns))
        self.assertEqual(len(move_warns), 8)

    def test_native_flag_allows_unknown_target(self):
        entries = [AliasEntry("MP", "MATCHPROPX", "", (FLAG_NATIVE,))]
        errors, warnings = validate_master(entries, PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertEqual(errors, [])
        self.assertTrue(any("MATCHPROPX" in w for w in warnings))

    def test_non_native_unknown_target_rejected(self):
        entries = [AliasEntry("MP", "MATCHPROPX")]
        errors, _ = validate_master(entries, PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertTrue(any("MATCHPROPX" in e for e in errors))

    def test_managed_block_has_no_trailing_notes(self):
        doc = self._doc()
        entries = [AliasEntry("C", "COPY", "复制"), AliasEntry("G", "GROUP", "编组")]
        lines, _ = apply_master(doc, entries)
        begin = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_BEGIN][0]
        end = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_END][0]
        block = lines[begin + 1:end]
        for line in block:
            if line.alias:
                self.assertNotIn(" ; ", line.raw, f"别名行不得含行尾备注: {line.raw!r}")
                self.assertRegex(line.raw, r"^[A-Z0-9-]+, \*[A-Z0-9_-]+$")
        notes = [l.raw for l in block if l.comment and not l.alias]
        self.assertIn("; 复制", notes)
        self.assertIn("; 编组", notes)

    def test_legacy_managed_block_with_trailing_notes_parses(self):
        raw = load_fixture("sample_real.pgp")
        doc = parse_pgp(raw)
        legacy_block = [
            "",
            alias_pgp.MANAGED_BEGIN,
            "C, *COPY ; 复制",
            "R, *ROTATE ; 旋转",
            alias_pgp.MANAGED_END,
        ]
        text = "\r\n".join(l.raw for l in doc.lines) + "\r\n" + "\r\n".join(legacy_block) + "\r\n"
        doc2 = parse_pgp(text.encode(doc.encoding))
        begin, end = doc2.managed_start, doc2.managed_end
        self.assertIsNotNone(begin)
        block = [l for l in doc2.lines[begin + 1:end] if l.alias]
        by_alias = {l.alias: l for l in block}
        self.assertEqual(by_alias["C"].note, "复制")
        self.assertEqual(by_alias["R"].note, "旋转")
        # 再次保存时升级为独立备注行
        master = [AliasEntry("C", "COPY", "复制"), AliasEntry("R", "ROTATE", "旋转")]
        lines, _ = apply_master(doc2, master)
        begin2 = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_BEGIN][0]
        end2 = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_END][0]
        block2 = lines[begin2 + 1:end2]
        for line in block2:
            if line.alias:
                self.assertNotIn(" ; ", line.raw)

    def test_stale_target_warning(self):
        # QSTXT 只出现在历史插件命令中，不在当前插件命令里
        warnings = stale_target_warnings([AliasEntry("Q", "QSTXT")],
                                         PLUGIN_COMMANDS - {"QSTXT"}, {"QSTXT", "OLDCMD"})
        self.assertEqual(len(warnings), 1)
        self.assertIn("QSTXT", warnings[0])
        self.assertIn("可能已删除或改名", warnings[0])

    def test_stale_target_skips_native_and_native_targets(self):
        # 原生命令（不在历史集合里）不提示
        self.assertEqual(stale_target_warnings(
            [AliasEntry("C", "COPY")], PLUGIN_COMMANDS, {"QSTXT"}), [])
        # 带 native 标记的条目不参与
        self.assertEqual(stale_target_warnings(
            [AliasEntry("Q", "QSTXT", "", (FLAG_NATIVE,))], PLUGIN_COMMANDS, {"QSTXT"}), [])

    def test_history_commands_scan_and_cache(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            (folder / "old.lsp").write_bytes(
                "(defun c:QSTXT () (princ))\r\n(defun c:OLDTWO () (princ))\r\n".encode("utf-8"))
            found = alias_pgp.history_plugin_commands(folder)
            self.assertEqual(found, {"QSTXT", "OLDTWO"})
            # 缓存：文件内容变化但 mtime 不变时仍返回缓存（这里仅验证可重复调用）
            self.assertEqual(alias_pgp.history_plugin_commands(folder), found)

    def test_restore_overridden_default_after_delete(self):
        doc = self._doc()
        original_line = "C,         *CIRCLE"
        # 首次应用（主表含 C）
        lines, _ = apply_master(doc, self.MASTER)
        raw = render_pgp(doc, lines)
        doc2 = parse_pgp(raw)
        commented = [l for l in doc2.lines if l.comment and l.alias.upper() == "C" and not l.raw.strip().startswith("; F")]
        self.assertTrue(commented)
        self.assertIn(alias_pgp.OVERIDDEN_NOTE, commented[0].raw)
        # 删掉 C 再应用
        without_c = [e for e in self.MASTER if e.alias != "C"]
        warnings = alias_pgp.restore_warnings(doc2, without_c)
        self.assertTrue(any("C" in w and "恢复" in w for w in warnings))
        lines2, report2 = apply_master(doc2, without_c)
        self.assertIn((14, "C"), report2["restored"])
        self.assertEqual(lines2[13].raw, original_line)
        self.assertFalse(lines2[13].comment)
        # 其他行不变
        text = "\r\n".join(l.raw for l in lines2)
        self.assertIn("; F,         *FILLET", text)
        self.assertIn(";-G,        *-GROUP", text)
        self.assertIn("; F,        *FIND", text)

    def test_restore_does_not_touch_user_commented_lines(self):
        doc = self._doc()
        lines, _ = apply_master(doc, self.MASTER)
        doc2 = parse_pgp(render_pgp(doc, lines))
        lines2, report2 = apply_master(doc2, [])
        # 用户自己注释的 ;-G 与 ; F 不应恢复
        restored_aliases = {a for _, a in report2["restored"]}
        self.assertNotIn("-G", restored_aliases)
        self.assertNotIn("F", restored_aliases)
        # 默认区里被面板覆盖的 C/G/R 都恢复（主表为空）
        self.assertEqual(restored_aliases, {"C", "G", "R"})
        text = "\r\n".join(l.raw for l in lines2)
        self.assertIn(";-G,        *-GROUP", text)
        self.assertIn("; F,        *FIND", text)

    def test_second_machine_detects_extra_user_alias(self):
        doc = self._doc()
        master = [AliasEntry("C", "COPY")]
        discovered, _ = discover_user_aliases(doc, PLUGIN_COMMANDS)
        master_aliases = {a.alias for a in master}
        extras = [e for e in discovered if e.alias not in master_aliases]
        extra_aliases = {e.alias for e in extras}
        self.assertIn("G", extra_aliases)
        self.assertIn("R", extra_aliases)
        self.assertIn("-G", extra_aliases)
        self.assertIn("Q", extra_aliases)


class ApplyMasterTests(unittest.TestCase):
    def test_first_run_creates_managed_block_and_moves_lines(self):
        raw = load_fixture("sample_gbk.pgp")
        doc = parse_pgp(raw)
        entries = [AliasEntry("C", "COPY"), AliasEntry("R", "ROTATE")]
        lines, report = apply_master(doc, entries)
        text = "\r\n".join(line.raw for line in lines)
        self.assertIn(alias_pgp.MANAGED_BEGIN, text)
        self.assertIn(alias_pgp.MANAGED_END, text)
        begin = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_BEGIN][0]
        outside = [line.raw for line in lines[:begin] if line.alias and line.alias.upper() in ("C", "R") and not line.comment]
        self.assertEqual(outside, [])
        moved = {a for _, a in report["moved"]}
        self.assertIn("C", moved)
        self.assertIn("R", moved)
        self.assertIn("; F,        *FIND", text)
        end = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_END][0]
        block_aliases = [l.alias for l in lines[begin + 1:end] if l.alias]
        self.assertEqual(sorted(block_aliases), ["C", "R"])

    def test_update_replaces_only_managed_block(self):
        raw = load_fixture("sample_gbk.pgp")
        doc = parse_pgp(raw)
        lines, _ = apply_master(doc, [AliasEntry("C", "COPY")])
        raw2 = render_pgp(doc, lines)
        doc2 = parse_pgp(raw2)
        lines2, _ = apply_master(doc2, [AliasEntry("C", "COPY"), AliasEntry("FD", "FDX")])
        text = "\r\n".join(line.raw for line in lines2)
        self.assertEqual(text.count(alias_pgp.MANAGED_BEGIN), 1)
        self.assertIn("FD, *FDX", text)
        self.assertIn("A,         *ARC", text)

    def test_override_comments_outside_default(self):
        raw = load_fixture("sample_gbk.pgp")
        doc = parse_pgp(raw)
        entries = [AliasEntry("A", "FDX")]
        lines, report = apply_master(doc, entries)
        begin = [i for i, l in enumerate(lines) if l.raw == alias_pgp.MANAGED_BEGIN][0]
        outside = [line for line in lines[:begin]]
        commented = [line for line in outside if line.comment and line.alias.upper() == "A"]
        self.assertEqual(len(commented), 1)
        self.assertIn(alias_pgp.OVERIDDEN_NOTE, commented[0].raw)
        self.assertTrue(report["commented"])


class ValidationTests(unittest.TestCase):
    def test_duplicate_alias_rejected(self):
        errors, _ = validate_master(
            [AliasEntry("C", "COPY"), AliasEntry("C", "CIRCLE")], PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertTrue(any("重复" in e for e in errors))

    def test_alias_colliding_with_plugin_command_rejected(self):
        errors, _ = validate_master([AliasEntry("FDX", "COPY")], PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertTrue(any("插件命令" in e for e in errors))

    def test_bad_chars_rejected(self):
        errors, _ = validate_master([AliasEntry("C!", "COPY")], PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertTrue(any("非法字符" in e for e in errors))

    def test_unknown_target_rejected(self):
        errors, _ = validate_master([AliasEntry("XX", "NOSUCHCMD")], PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertTrue(any("既不是插件命令" in e for e in errors))

    def test_plugin_and_pgp_targets_accepted(self):
        errors, _ = validate_master(
            [AliasEntry("C", "COPY"), AliasEntry("FD", "FDX")], PLUGIN_COMMANDS, KNOWN_TARGETS)
        self.assertEqual(errors, [])

    def test_override_warning_mentions_original_target(self):
        doc = parse_pgp(load_fixture("sample_gbk.pgp"))
        warnings = override_conflicts([AliasEntry("A", "FDX")], doc)
        self.assertTrue(any("ARC" in w for w in warnings))


class TransactionTests(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="alias-panel-test-"))
        self.pgp = self.tmp / "ZWCAD.pgp"

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_apply_creates_backup_and_block(self):
        self.pgp.write_bytes(load_fixture("sample_gbk.pgp"))
        entries = [AliasEntry("C", "COPY"), AliasEntry("R", "ROTATE")]
        report, warnings = alias_pgp.apply_to_pgp(
            self.pgp, entries, PLUGIN_COMMANDS, KNOWN_TARGETS,
            backup_folder=self.tmp / "bak")
        text = self.pgp.read_bytes().decode("gbk")
        self.assertIn(alias_pgp.MANAGED_BEGIN, text)
        self.assertTrue(Path(report["backup"]).exists())
        self.assertTrue((Path(report["backup"]) / "ZWCAD.pgp").exists())

    def test_apply_failure_before_replace_keeps_original(self):
        """写回校验失败时（os.replace 之前），原文件根本未被修改。"""
        original = load_fixture("sample_gbk.pgp")
        self.pgp.write_bytes(original)

        class Boom(Exception):
            pass

        real_parse = alias_pgp.parse_pgp
        call_count = [0]

        def exploding_parse(raw):
            call_count[0] += 1
            if call_count[0] == 2:
                raise Boom()
            return real_parse(raw)

        alias_pgp.parse_pgp = exploding_parse
        try:
            with self.assertRaises(Boom):
                alias_pgp.apply_to_pgp(self.pgp, [AliasEntry("C", "COPY")],
                                       PLUGIN_COMMANDS, KNOWN_TARGETS,
                                       backup_folder=self.tmp / "bak")
        finally:
            alias_pgp.parse_pgp = real_parse
        self.assertEqual(self.pgp.read_bytes(), original)

    def test_apply_failure_at_replace_keeps_original(self):
        """os.replace 失败时原文件未被替换，不应触发非原子重写。"""
        original = load_fixture("sample_gbk.pgp")
        self.pgp.write_bytes(original)

        class Boom(Exception):
            pass

        real_replace = alias_pgp.os.replace

        def exploding(*args, **kwargs):
            raise Boom()

        alias_pgp.os.replace = exploding
        try:
            with self.assertRaises(Boom):
                alias_pgp.apply_to_pgp(self.pgp, [AliasEntry("C", "COPY")],
                                       PLUGIN_COMMANDS, KNOWN_TARGETS,
                                       backup_folder=self.tmp / "bak")
        finally:
            alias_pgp.os.replace = real_replace
        self.assertEqual(self.pgp.read_bytes(), original)

    def test_apply_rejects_conflicting_master(self):
        self.pgp.write_bytes(load_fixture("sample_gbk.pgp"))
        with self.assertRaises(AliasError):
            alias_pgp.apply_to_pgp(
                self.pgp, [AliasEntry("C", "COPY"), AliasEntry("C", "CIRCLE")],
                PLUGIN_COMMANDS, KNOWN_TARGETS, backup_folder=self.tmp / "bak")
        self.assertEqual(self.pgp.read_bytes(), load_fixture("sample_gbk.pgp"))


class MasterCsvTests(unittest.TestCase):
    def test_roundtrip(self):
        entries = [AliasEntry("C", "COPY", "复制"), AliasEntry("FD", "FDX", "分配")]
        raw = render_master_bytes(entries)
        self.assertTrue(raw.startswith(b"\xef\xbb\xbf"))
        self.assertIn(b"\r\n", raw)
        got = parse_master_bytes(raw)
        self.assertEqual(got, entries)

    def test_legacy_three_column_reads(self):
        legacy = "别名,目标命令,备注\r\nC,COPY,复制\r\nQ,QSTXT,\r\n".encode("utf-8-sig")
        rows = parse_master_bytes(legacy)
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[0], AliasEntry("C", "COPY", "复制"))
        self.assertEqual(rows[1], AliasEntry("Q", "QSTXT", ""))

    def test_native_flag_roundtrip(self):
        entries = [AliasEntry("MP", "MATCHPROPX", "原生", (FLAG_NATIVE,))]
        got = parse_master_bytes(render_master_bytes(entries))
        self.assertEqual(got, entries)
        self.assertIn(FLAG_NATIVE, got[0].flags)


if __name__ == "__main__":
    unittest.main()
