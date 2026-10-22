# -*- coding: utf-8 -*-
"""命令别名主表与 ZWCAD.pgp 的解析、写回逻辑；与界面分离，不连接 CAD。

主表：config/aliases.csv（UTF-8 带 BOM、CRLF），列为 别名,目标命令,备注[,标记]。
PGP：本机 %AppData% 下的 ZWCAD.pgp，面板只重写末尾托管区块内的内容。
"""
from __future__ import annotations

import csv
import io
import os
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MASTER = ROOT / "config" / "aliases.csv"
BACKUP_ROOT = ROOT / "backups"
LOCAL_SETTINGS = Path(os.environ.get("LOCALAPPDATA", str(Path.home() / "AppData/Local"))) / "ZW-auto_lisp" / "alias_panel.ini"

MANAGED_BEGIN = "; ===== BEGIN ZW-auto_lisp aliases (由 命令别名设置 面板管理，请勿手改此区块) ====="
MANAGED_END = "; ===== END ZW-auto_lisp aliases ====="
OVERIDDEN_NOTE = "已由面板覆盖"
ALIAS_LINE = re.compile(r"^\s*(?P<alias>[^;\s,]+)\s*,\s*\*(?P<target>[^,\s;]+)")
ALIAS_NAME = re.compile(r"^[A-Za-z0-9-]+$")
# 托管区块内行的备注（行尾 "; 备注"）只在解析旧格式时兜底读取。
MANAGED_LINE_NOTE = re.compile(r"^(?P<alias>[A-Z0-9-]+)\s*,\s*\*(?P<target>[A-Z0-9_-]+)\s*;\s*(?P<note>.+)$")

# 主表第四列“标记”可选值
FLAG_NATIVE = "native"  # 通过“原生命令”分组登记，目标未知时只警告不拦截


@dataclass(frozen=True)
class AliasEntry:
    alias: str
    target: str
    note: str = ""
    flags: tuple = ()  # 例如 (FLAG_NATIVE,)


@dataclass(frozen=True)
class PgpLine:
    raw: str
    alias: str = ""
    target: str = ""
    comment: bool = False
    note: str = ""  # 托管区块里下一行的 "; 备注" 或旧格式行尾备注


@dataclass
class PgpDocument:
    encoding: str
    newline: str
    lines: list[PgpLine]
    managed_start: int | None = None
    managed_end: int | None = None

    def active_entries(self):
        return [(l.alias.upper(), l.target.upper()) for l in self.lines if l.alias and not l.comment]

    def alias_map(self):
        result = {}
        for alias, target in self.active_entries():
            result.setdefault(alias, []).append(target)
        return result


class AliasError(ValueError):
    pass


def default_pgp_path():
    return Path(os.environ.get("APPDATA", "")) / "ZWSOFT" / "ZWCAD" / "2026" / "zh-CN" / "Support" / "ZWCAD.pgp"


def load_local_pgp_path():
    try:
        text = LOCAL_SETTINGS.read_text(encoding="utf-8")
    except OSError:
        return None
    for line in text.splitlines():
        key, _, value = line.partition("=")
        if key.strip().lower() == "pgp" and value.strip():
            return Path(value.strip())
    return None


def save_local_pgp_path(path):
    LOCAL_SETTINGS.parent.mkdir(parents=True, exist_ok=True)
    LOCAL_SETTINGS.write_text(f"pgp={path}\r\n", encoding="utf-8")


def resolve_pgp_path():
    custom = load_local_pgp_path()
    if custom and custom.exists():
        return custom
    path = default_pgp_path()
    if path.exists():
        return path
    return custom


def detect_encoding(raw: bytes) -> str:
    """按 utf-8-sig → utf-8 → GBK 顺序判定，能无损往返才算成功。"""
    for encoding in ("utf-8-sig", "utf-8", "gbk"):
        try:
            text = raw.decode(encoding)
        except UnicodeDecodeError:
            continue
        if text.encode(encoding) != raw:
            continue
        return encoding
    raise AliasError("无法判定 PGP 文件编码（utf-8/GBK 均不能无损往返），已停止。")


def _parse_alias_target(line: str):
    match = ALIAS_LINE.match(line)
    if not match:
        return None, None
    return match.group("alias").strip(), match.group("target").strip()


def parse_line(line: str) -> PgpLine:
    stripped = line.strip()
    if not stripped:
        return PgpLine(raw=line)
    if stripped.startswith(";"):
        alias, target = _parse_alias_target(stripped[1:])
        return PgpLine(raw=line, comment=True, alias=alias or "", target=target or "")
    alias, target = _parse_alias_target(line)
    if alias:
        return PgpLine(raw=line, alias=alias, target=target)
    return PgpLine(raw=line)


def parse_pgp(raw: bytes) -> PgpDocument:
    encoding = detect_encoding(raw)
    text = raw.decode(encoding)
    newline = "\r\n" if "\r\n" in text else "\n"
    lines = [parse_line(line) for line in text.split(newline)]
    if lines and lines[-1].raw == "":
        lines.pop()
    doc = PgpDocument(encoding=encoding, newline=newline, lines=lines)
    for index, line in enumerate(lines):
        if line.raw.strip() == MANAGED_BEGIN:
            doc.managed_start = index
        elif line.raw.strip() == MANAGED_END:
            doc.managed_end = index
    if (doc.managed_start is None) != (doc.managed_end is None):
        raise AliasError("PGP 托管区块标记不完整（BEGIN/END 只剩一个），请人工检查后重试。")
    if doc.managed_start is not None and doc.managed_start >= doc.managed_end:
        raise AliasError("PGP 托管区块 BEGIN/END 顺序异常，请人工检查后重试。")
    if doc.managed_start is not None:
        _absorb_managed_notes(doc)
    return doc


def _absorb_managed_notes(doc: PgpDocument):
    """把托管区块里“上一行 ; 备注”或旧格式“行尾 ; 备注”挂到对应别名行的 note 字段。"""
    start, end = doc.managed_start + 1, doc.managed_end
    lines = doc.lines
    for index in range(start, end):
        line = lines[index]
        if not line.alias:
            continue
        # 旧格式：行尾带备注
        note = ""
        match = MANAGED_LINE_NOTE.match(line.raw)
        if match:
            note = match.group("note").strip()
        # 上一行是独立 "; 备注"
        if not note and index > start:
            prev = lines[index - 1]
            if prev.comment and not prev.alias and prev.raw.strip().startswith(";") \
                    and prev.raw.strip() != MANAGED_BEGIN:
                candidate = prev.raw.strip().lstrip(";").strip()
                if candidate:
                    note = candidate
        if note:
            lines[index] = PgpLine(raw=line.raw, alias=line.alias, target=line.target, note=note)


def read_pgp(path) -> PgpDocument:
    path = Path(path)
    try:
        raw = path.read_bytes()
    except OSError as error:
        raise AliasError(f"无法读取 PGP 文件：{path}\n{error}")
    return parse_pgp(raw)


def managed_alias_set(doc: PgpDocument) -> set[str]:
    if doc.managed_start is None:
        return set()
    return {line.alias.upper() for line in doc.lines[doc.managed_start + 1:doc.managed_end] if line.alias}


def default_marker_index(doc: PgpDocument) -> int | None:
    """中望出厂别名区域结束标志：从文件末尾反向找到的第一个空行。"""
    for index in range(len(doc.lines) - 1, -1, -1):
        if not doc.lines[index].raw.strip():
            return index
    return None


def _in_managed(doc: PgpDocument, index: int) -> bool:
    return (doc.managed_start is not None and doc.managed_start < index < doc.managed_end)


def user_region_start(doc: PgpDocument) -> int:
    """用户自定义区起始行（默认区空行之后）；无空行返回 len(lines)。"""
    marker = default_marker_index(doc)
    return (marker + 1) if marker is not None else len(doc.lines)


def discover_user_aliases(doc: PgpDocument, plugin_commands: set[str]):
    """找出疑似用户手工添加的自定义别名（区块外、默认区之后的目标行）。

    返回 (entries, uncertain)。无托管区块时以文件末尾空行之后的行为准；
    已有托管区块时区块外一律视为中望默认，不再导入。
    """
    if doc.managed_start is not None:
        return [], []
    marker = default_marker_index(doc)
    if marker is None:
        raise AliasError("PGP 文件没有空行分隔，无法区分中望默认别名，已停止导入。")
    entries, uncertain = [], []
    for line in doc.lines[marker + 1:]:
        if line.comment and line.alias:
            uncertain.append((line.alias, line.target))
        elif line.alias:
            entries.append(AliasEntry(line.alias.upper(), line.target.upper()))
    return entries, uncertain


def normalize_alias(alias: str) -> str:
    return alias.strip().upper()


def validate_master(entries, plugin_commands, known_targets):
    """主表冲突校验；返回 (errors, warnings)。errors 非空时禁止保存。

    标记为 native 的条目在目标未知时只警告；其他来源的未知目标仍拦截。
    """
    errors, warnings = [], []
    plugin_upper = {c.upper() for c in plugin_commands}
    known_upper = {t.upper() for t in known_targets} | plugin_upper
    seen = {}
    for row, entry in enumerate(entries, 1):
        alias = normalize_alias(entry.alias)
        target = entry.target.strip().upper()
        is_native = FLAG_NATIVE in (entry.flags or ())
        if not alias:
            errors.append(f"第 {row} 行：别名为空。")
            continue
        if not ALIAS_NAME.fullmatch(alias):
            errors.append(f"第 {row} 行：别名 {alias!r} 含非法字符（只允许字母、数字、-）。")
        if alias in plugin_upper:
            errors.append(f"第 {row} 行：别名 {alias} 与插件命令名相同，会造成命令无法输入。")
        if not target:
            errors.append(f"第 {row} 行：{alias} 的目标命令为空。")
        elif target not in known_upper:
            if is_native:
                warnings.append(f"第 {row} 行：{alias} → {target} 已标记为原生命令，"
                                f"离线无法核对中望是否存在该命令，保存后请自行在 CAD 验证。")
            else:
                errors.append(f"第 {row} 行：{alias} 的目标 {target} 既不是插件命令，"
                              f"也未在本机 PGP 中出现过；如确为中望原生命令，请用“原生命令”分组登记。")
        if alias in seen:
            errors.append(f"第 {row} 行：别名 {alias} 重复（已指向 {seen[alias]}，不能再指向 {target}）。")
        else:
            seen[alias] = target
    return errors, warnings


def stale_target_warnings(entries, plugin_commands, history_commands):
    """目标在历史插件命令里、但不在当前插件命令里的条目；只警告不拦截。

    带 native 标记的条目不参与；目标是中望原生命令的也不参与（不在历史集合中即视为原生）。
    """
    warnings = []
    plugin_upper = {c.upper() for c in plugin_commands}
    history_upper = {c.upper() for c in history_commands}
    for entry in entries:
        if FLAG_NATIVE in (entry.flags or ()):
            continue
        target = entry.target.strip().upper()
        if not target or target in plugin_upper:
            continue
        if target in history_upper:
            warnings.append(f"{normalize_alias(entry.alias)} → {target}：该插件命令可能已删除或改名；"
                            f"保存后请自行在 CAD 验证。")
    return warnings


_history_cache: tuple[float, set[str]] | None = None


def history_plugin_commands(backups_dir=None, ttl=60):
    """扫描 backups/ 下历史 .lsp 的 defun c:XXX，带 60 秒缓存避免重复扫描。"""
    global _history_cache
    backups_dir = Path(backups_dir or BACKUP_ROOT)
    try:
        newest = max((p.stat().st_mtime for p in backups_dir.rglob("*.lsp")), default=0.0)
    except OSError:
        newest = 0.0
    if _history_cache and _history_cache[0] >= newest:
        return _history_cache[1]
    found = set()
    for path in backups_dir.rglob("*.lsp"):
        try:
            text = path.read_bytes().decode("utf-8", errors="strict")
        except (OSError, UnicodeDecodeError):
            continue
        for match in re.finditer(r"\(defun\s+c:([A-Za-z0-9_]+)", text, re.I):
            found.add(match.group(1).upper())
    _history_cache = (newest, found)
    return found


def override_conflicts(entries, doc: PgpDocument):
    """主表别名与中望默认 PGP 区块外条目的覆盖/迁入关系；返回警告文本列表。

    无托管区块时，默认区之后的用户手工行会被迁入托管区块，不算“覆盖”；
    默认区里的同名启用行才是真正会被注释掉的覆盖。
    """
    warnings = []
    aliases = {normalize_alias(e.alias) for e in entries}
    user_start = user_region_start(doc)
    for entry in entries:
        alias = normalize_alias(entry.alias)
        for index, line in enumerate(doc.lines):
            if _in_managed(doc, index) or not line.alias or line.alias.upper() != alias:
                continue
            if line.comment:
                continue  # 已注释行不提示
            if doc.managed_start is None and index >= user_start:
                warnings.append(f"{alias}：原 PGP 第 {index + 1} 行的自定义别名"
                                f"（{line.alias}→{line.target}）将迁入托管区块。")
            else:
                warnings.append(f"{alias}：将覆盖中望默认 PGP 第 {index + 1} 行的别名"
                                f"（原指向 {line.target}）。")
    return warnings


def restore_warnings(doc: PgpDocument, entries):
    """已有托管区块时，找出区块外带“已由面板覆盖”标记、但别名已不在主表里的行。

    这些行会被恢复原样。返回提示文本列表。
    """
    if doc.managed_start is None:
        return []
    master_aliases = {normalize_alias(e.alias) for e in entries}
    warnings = []
    for index, line in enumerate(doc.lines[:doc.managed_start]):
        if not line.comment or OVERIDDEN_NOTE not in line.raw:
            continue
        if not line.alias or line.alias.upper() in master_aliases:
            continue
        # 还原后的目标：从 raw 中解析原始目标
        restored = _restore_overridden_raw(line.raw)
        if restored is not None:
            warnings.append(f"{line.alias.upper()}：将恢复中望默认别名（{restored}）。")
    return warnings


def _restore_overridden_raw(raw: str):
    """把 '; C,         *CIRCLE    ; 已由面板覆盖' 还原为 'C,         *CIRCLE'。"""
    if not raw.startswith("; ") or OVERIDDEN_NOTE not in raw:
        return None
    body = raw[len("; "):]
    marker = f"    ; {OVERIDDEN_NOTE}"
    if marker not in body:
        return None
    return body[:body.index(marker)]


def render_managed_lines(entries):
    """托管区块内每条别名一行；备注写在上一行独立 '; 备注'，不写行尾。"""
    lines = [MANAGED_BEGIN]
    for entry in entries:
        alias = normalize_alias(entry.alias)
        target = entry.target.strip().upper()
        note = entry.note.strip()
        if note:
            lines.append(f"; {note}")
        lines.append(f"{alias}, *{target}")
    lines.append(MANAGED_END)
    return lines


def apply_master(doc: PgpDocument, entries):
    """根据主表生成新 PGP 行序列；不重写区块外内容。返回 (lines, report)。

    规则：
    - 已有托管区块：整体替换区块；区块外与主表同名的启用行在原行前加 "; " 注释掉；
      区块外带“已由面板覆盖”标记、但别名已不在主表里的行恢复为原样（report.restored）。
    - 首次运行：仅默认区之后（marker 之后）的用户手工行被移入新区块；
      默认区里的同名启用行一律注释，不删除。
    """
    aliases = {normalize_alias(e.alias) for e in entries}
    report = {"commented": [], "moved": [], "kept_commented": [], "restored": []}
    if doc.managed_start is not None:
        lines = list(doc.lines)
        for index, line in enumerate(lines[:doc.managed_start]):
            if line.alias and not line.comment and line.alias.upper() in aliases:
                lines[index] = PgpLine(raw=f"; {line.raw}    ; {OVERIDDEN_NOTE}", comment=True,
                                       alias=line.alias, target=line.target)
                report["commented"].append((index + 1, line.alias.upper()))
            elif line.comment and OVERIDDEN_NOTE in line.raw:
                # 别名已不在主表里：恢复原始行
                if line.alias and line.alias.upper() not in aliases:
                    restored = _restore_overridden_raw(line.raw)
                    if restored is not None:
                        restored_alias, restored_target = _parse_alias_target(restored)
                        lines[index] = PgpLine(raw=restored, alias=restored_alias or "",
                                               target=restored_target or "")
                        report["restored"].append((index + 1, line.alias.upper()))
        block = [PgpLine(raw=raw) for raw in render_managed_lines(entries)]
        lines = lines[:doc.managed_start] + block + lines[doc.managed_end + 1:]
        return lines, report
    # 首次运行
    marker = default_marker_index(doc)
    if marker is None:
        raise AliasError("PGP 文件没有空行分隔，无法区分中望默认别名，已停止。")
    user_start = marker + 1
    lines = []
    for index, line in enumerate(doc.lines):
        if line.alias and not line.comment and line.alias.upper() in aliases:
            if index >= user_start:
                report["moved"].append((index + 1, line.alias.upper()))
            else:
                lines.append(PgpLine(raw=f"; {line.raw}    ; {OVERIDDEN_NOTE}", comment=True,
                                     alias=line.alias, target=line.target))
                report["commented"].append((index + 1, line.alias.upper()))
            continue
        if line.alias and line.comment and line.alias.upper() in aliases:
            report["kept_commented"].append((index + 1, line.alias.upper()))
        lines.append(line)
    block = [PgpLine(raw=""), PgpLine(raw=MANAGED_BEGIN)]
    for entry in entries:
        alias = normalize_alias(entry.alias)
        target = entry.target.strip().upper()
        if entry.note.strip():
            block.append(PgpLine(raw=f"; {entry.note.strip()}", comment=True))
        block.append(PgpLine(raw=f"{alias}, *{target}", alias=alias, target=target,
                             note=entry.note.strip()))
    block.append(PgpLine(raw=MANAGED_END))
    lines.extend(block)
    return lines, report


def render_pgp(doc: PgpDocument, lines) -> bytes:
    text = doc.newline.join(line.raw for line in lines) + doc.newline
    return text.encode(doc.encoding)


# ---------- 主表 CSV ----------

def parse_master_bytes(raw: bytes):
    """向后兼容：三列（别名,目标命令,备注）与四列（+标记）都能读。"""
    text = raw.decode("utf-8-sig")
    rows = []
    for record in csv.reader(io.StringIO(text)):
        if not record or all(not cell.strip() for cell in record):
            continue
        head = record[0].strip().lstrip("﻿").upper()
        if head == "别名" or head.startswith("#"):
            continue
        alias = head
        target = record[1].strip().upper() if len(record) > 1 else ""
        note = record[2].strip() if len(record) > 2 else ""
        flags_field = record[3].strip().lower() if len(record) > 3 else ""
        flags = tuple(f for f in re.split(r"[|;\s]+", flags_field) if f)
        rows.append(AliasEntry(alias, target, note, flags))
    return rows


def read_master(path=None):
    path = Path(path or MASTER)
    if not path.exists():
        return []
    return parse_master_bytes(path.read_bytes())


def render_master_bytes(entries) -> bytes:
    buffer = io.StringIO(newline="")
    writer = csv.writer(buffer, lineterminator="\r\n")
    writer.writerow(["别名", "目标命令", "备注", "标记"])
    for entry in entries:
        writer.writerow([normalize_alias(entry.alias), entry.target.strip().upper(),
                         entry.note, "|".join(entry.flags or ())])
    return buffer.getvalue().encode("utf-8-sig")


# ---------- 事务 ----------

def backup_paths(folder: Path, files: dict[Path, bytes | None]):
    folder.mkdir(parents=True, exist_ok=False)
    for path, raw in files.items():
        if raw is None:
            continue
        name = path.name
        target = folder / name
        counter = 1
        while target.exists():
            target = folder / f"{path.stem}-{counter}{path.suffix}"
            counter += 1
        target.write_bytes(raw)


def apply_to_pgp(pgp_path, entries, plugin_commands, known_targets, expect_doc=None,
                 backup_folder=None):
    """事务式把主表应用到 PGP。成功返回 (report, warnings)；失败抛 AliasError。

    只在 os.replace 已经成功后才需要回滚；之前的阶段失败时原文件未被修改。
    """
    pgp_path = Path(pgp_path)
    raw_before = pgp_path.read_bytes()
    doc = parse_pgp(raw_before)
    if expect_doc is not None and raw_before != expect_doc:
        raise AliasError("PGP 文件在面板打开后被其他程序修改，请重新打开面板后再保存。")
    errors, _ = validate_master(entries, plugin_commands, known_targets)
    if errors:
        raise AliasError("主表存在冲突，禁止保存：\n- " + "\n- ".join(errors))
    warnings = override_conflicts(entries, doc)
    lines, report = apply_master(doc, entries)
    raw_after = render_pgp(doc, lines)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    folder = Path(backup_folder) if backup_folder else BACKUP_ROOT / f"alias-panel-{stamp}"
    backups = {pgp_path: raw_before}
    if MASTER.exists():
        backups[MASTER] = MASTER.read_bytes()
    backup_paths(folder, backups)
    temporary = pgp_path.with_name(pgp_path.name + ".tmp-alias")
    try:
        temporary.write_bytes(raw_after)
        verify = parse_pgp(temporary.read_bytes())
        if verify.managed_start is None:
            raise AliasError("写回后未找到托管区块。")
        block = verify.lines[verify.managed_start + 1:verify.managed_end]
        got = sorted((l.alias.upper(), l.target.upper()) for l in block if l.alias)
        expected = sorted((normalize_alias(e.alias), e.target.strip().upper()) for e in entries)
        if got != expected:
            raise AliasError("写回后托管区块内容与主表不一致。")
        os.replace(temporary, pgp_path)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise
    report["backup"] = str(folder)
    return report, warnings


def master_note_map(entries):
    return {normalize_alias(e.alias): e.note for e in entries if e.note}


def pgp_default_targets(doc: PgpDocument) -> set[str]:
    """本机 PGP 默认区（不含用户自定义行和托管区块）里出现过的目标命令集合。"""
    if doc.managed_start is not None:
        scope = doc.lines[:doc.managed_start]
    else:
        marker = default_marker_index(doc)
        scope = doc.lines[:marker + 1] if marker is not None else doc.lines
    return {line.target.upper() for line in scope if line.target and not line.comment}
