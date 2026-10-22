# -*- coding: utf-8 -*-
"""GUI 级回归：编辑框连续输入、修改后删除、native 标记；不连接 CAD，不碰真实 PGP。

用 tk.Tk() + withdraw() 隐藏窗口，只操作内存中的 Panel 状态。
Panel 初始化会读取本机 PGP（只读）并扫描源码；不会写入任何文件。
"""
from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import alias_pgp
from alias_pgp import AliasEntry, FLAG_NATIVE

try:
    import tkinter as tk
    HAS_TK = True
except ImportError:  # pragma: no cover
    HAS_TK = False


def make_panel(root):
    import alias_panel
    return alias_panel.Panel(root)


@unittest.skipUnless(HAS_TK, "需要 tkinter")
class PanelEditTests(unittest.TestCase):
    def setUp(self):
        self.root = tk.Tk()
        self.root.withdraw()
        self.panel = make_panel(self.root)

    def tearDown(self):
        try:
            self.root.destroy()
        except tk.TclError:
            pass

    def _select_copy(self):
        panel = self.panel
        # 确保有一个指向 COPY 的条目（不写文件）
        panel.entries = [e for e in panel.entries if e.target.upper() != "COPY"]
        panel.entries.append(AliasEntry("CP", "COPY", "复制"))
        panel.baseline = list(panel.entries)
        panel.selected = "COPY"
        panel._refresh_detail()
        return panel

    def test_consecutive_alias_edits_accumulate(self):
        panel = self._select_copy()
        row = panel.alias_rows[0]
        row["alias_var"].set("CP")
        row["alias_var"].set("CPY")
        row["note_var"].set("复制2")
        got = [(e.alias, e.target, e.note) for e in panel.entries if e.target.upper() == "COPY"]
        self.assertEqual(got, [("CPY", "COPY", "复制2")])

    def test_edit_then_delete_removes_row(self):
        panel = self._select_copy()
        row = panel.alias_rows[0]
        row["alias_var"].set("CPX")
        row["note_var"].set("改过")
        # 走与删除按钮相同的代码路径
        panel._delete_row(row)
        remaining = [e for e in panel.entries if e.target.upper() == "COPY"]
        self.assertEqual(remaining, [])

    def test_flags_preserved_on_edit(self):
        panel = self.panel
        panel.entries = [AliasEntry("MP", "MATCHPROPX", "原生", (FLAG_NATIVE,))]
        panel.selected = "MATCHPROPX"
        panel._refresh_detail()
        row = panel.alias_rows[0]
        row["alias_var"].set("MPX")
        row["note_var"].set("改备注")
        kept = [e for e in panel.entries if e.target.upper() == "MATCHPROPX"]
        self.assertEqual(len(kept), 1)
        self.assertEqual(kept[0].alias, "MPX")
        self.assertEqual(kept[0].note, "改备注")
        self.assertIn(FLAG_NATIVE, kept[0].flags)


@unittest.skipUnless(HAS_TK, "需要 tkinter")
class PanelValidationTests(unittest.TestCase):
    def setUp(self):
        self.root = tk.Tk()
        self.root.withdraw()
        self.panel = make_panel(self.root)

    def tearDown(self):
        try:
            self.root.destroy()
        except tk.TclError:
            pass

    def test_native_unknown_target_only_warns(self):
        panel = self.panel
        entries = [AliasEntry("MP", "MATCHPROPX", "原生", (FLAG_NATIVE,))]
        errors, warnings = alias_pgp.validate_master(
            entries, set(panel.plugin_commands), panel.known_targets)
        self.assertEqual(errors, [])
        self.assertTrue(any("MATCHPROPX" in w for w in warnings))

    def test_master_roundtrip_keeps_native_flag(self):
        panel = self.panel
        panel.entries = [AliasEntry("MP", "MATCHPROPX", "原生", (FLAG_NATIVE,))]
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "aliases.csv"
            panel._write_master(path)
            got = alias_pgp.read_master(path)
        self.assertEqual(got, panel.entries)
        self.assertIn(FLAG_NATIVE, got[0].flags)

    def test_add_native_entry_marks_flag_and_only_warns(self):
        panel = self.panel
        panel.entries = []
        panel.baseline = []
        self.assertTrue(panel.add_native_entry("MP", "MATCHPROPX"))
        added = [e for e in panel.entries if e.target.upper() == "MATCHPROPX"]
        self.assertEqual(len(added), 1)
        self.assertEqual(added[0].alias, "MP")
        self.assertIn(FLAG_NATIVE, added[0].flags)
        # 保存校验：只警告不出错
        errors, warnings = alias_pgp.validate_master(
            panel.entries, set(panel.plugin_commands), panel.known_targets)
        self.assertEqual(errors, [])
        self.assertTrue(any("MATCHPROPX" in w for w in warnings))
        # 主表第四列写出 native，重新读取标记仍在
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "aliases.csv"
            panel._write_master(path)
            raw = path.read_bytes().decode("utf-8-sig")
            self.assertIn("native", raw.splitlines()[1])
            got = alias_pgp.read_master(path)
        self.assertIn(FLAG_NATIVE, got[0].flags)


if __name__ == "__main__":
    unittest.main()
