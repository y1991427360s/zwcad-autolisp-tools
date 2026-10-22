# -*- coding: utf-8 -*-
"""命令别名设置面板的离线静态检查；不连接 CAD，不读取真实 %AppData% PGP。"""
import os
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT))

import alias_pgp


def check_files_exist():
    required = [
        ROOT / "tools" / "alias_pgp.py",
        ROOT / "tools" / "alias_panel.py",
        ROOT / "tools" / "start-alias-panel.ps1",
        ROOT / "命令别名设置.cmd",
        ROOT / "tools" / "fixtures" / "sample_gbk.pgp",
        ROOT / "tools" / "fixtures" / "sample_utf8.pgp",
        ROOT / "tools" / "fixtures" / "sample_real.pgp",
        ROOT / "tests" / "test_alias_panel.py",
        ROOT / "tests" / "test_alias_panel_gui.py",
        ROOT / "docs" / "命令别名设置.md",
    ]
    missing = [str(p) for p in required if not p.exists()]
    assert not missing, "缺少文件：\n- " + "\n- ".join(missing)
    print(f"PASS files: {len(required)} 个面板相关文件齐全")


def check_master_schema():
    if not alias_pgp.MASTER.exists():
        print("PASS master: config/aliases.csv 尚未创建（首次运行时自动生成）")
        return
    entries = alias_pgp.read_master()
    assert isinstance(entries, list)
    print(f"PASS master: config/aliases.csv 可解析，{len(entries)} 条别名")


def check_command_scan():
    """面板与命令索引必须得到同一份命令、说明；且每条说明有效。"""
    sys.path.insert(0, str(ROOT))
    import gen_命令索引 as indexer
    import importlib
    panel = importlib.import_module("tools.alias_panel")
    commands, skipped = panel.scan_plugin_commands()
    assert not skipped, "扫描插件命令时跳过文件：" + "、".join(skipped)
    fs, rows, index_skipped = indexer.scan_with_skipped()
    assert not index_skipped, "命令索引扫描时跳过文件：" + "、".join(index_skipped)
    index_map = {}
    for name, file, line, desc in rows:
        index_map.setdefault(name, (file, line, desc))
    # 命令集合一致
    missing = sorted(set(index_map) - set(commands))
    extra = sorted(set(commands) - set(index_map))
    assert not missing and not extra, (
        "面板与命令索引命令集合不一致：面板缺少 " + "、".join(missing or ["—"]) +
        "；面板多出 " + "、".join(extra or ["—"]))
    # 文件、行号、说明逐条一致
    mismatched = []
    for name, (file, line, desc) in index_map.items():
        got = commands[name]
        if (got["file"], got["line"], got["desc"]) != (file, line, desc):
            mismatched.append(f"{name}（索引 {file}:{line} {desc!r}；面板 {got['file']}:{got['line']} {got['desc']!r}）")
    assert not mismatched, "面板与命令索引说明不一致：\n- " + "\n- ".join(mismatched)
    # 说明质量：非空、非纯分隔线、不等于命令名、至少 6 个字
    bad = []
    for name, info in sorted(commands.items()):
        desc = info["desc"].strip()
        if not desc:
            bad.append(f"{name}: 说明为空")
        elif set(desc) <= set("=-*#_~` "):
            bad.append(f"{name}: 说明为分隔线")
        elif desc.upper() == name:
            bad.append(f"{name}: 说明等于命令名")
        elif len(desc) < 6:
            bad.append(f"{name}: 说明过短（{desc!r}）")
    assert not bad, "命令说明不合格（请在源码写 ;;; 功能: 注释头）：\n- " + "\n- ".join(bad)
    print(f"PASS scan: 面板扫描 {len(commands)} 条命令，说明全部有效，"
          f"与命令索引（{len(index_map)} 条）的命令/文件/行号/说明完全一致")


def check_real_pgp_readonly():
    """只读解析真实 PGP（如果存在），验证导入逻辑能跑通，不写入。"""
    path = alias_pgp.resolve_pgp_path()
    if path is None or not Path(path).exists():
        print("SKIP real PGP: 本机未找到 PGP，跳过只读检查")
        return
    doc = alias_pgp.read_pgp(path)
    entries, uncertain = alias_pgp.discover_user_aliases(doc, set())
    print(f"PASS real PGP (只读): {path}，编码 {doc.encoding}，"
          f"识别自定义别名 {len(entries)} 条，被注释 {len(uncertain)} 条")


def _run(pattern):
    suite = unittest.defaultTestLoader.discover(str(ROOT / "tests"), pattern=pattern)
    result = unittest.TextTestRunner(verbosity=0, stream=open(os.devnull, "w")).run(suite)
    assert result.wasSuccessful(), f"tests/{pattern} 失败：{result.failures + result.errors}"
    return result.testsRun


def check_unit_tests():
    core = _run("test_alias_panel.py")
    gui = _run("test_alias_panel_gui.py")
    print(f"PASS unit tests: test_alias_panel.py {core} 个用例、test_alias_panel_gui.py {gui} 个用例全部通过")


def main():
    check_files_exist()
    check_master_schema()
    check_command_scan()
    check_real_pgp_readonly()
    check_unit_tests()
    print("PASS alias-panel static checks")


if __name__ == "__main__":
    main()
