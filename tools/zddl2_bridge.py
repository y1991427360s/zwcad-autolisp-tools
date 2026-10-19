"""ZDDL2 本机绘图桥：复用 2ci 核心，输出供 AutoLISP read 读取的纯 DXF 数据。"""
from __future__ import annotations

import math
import re
import sys
import tempfile
from pathlib import Path

import zddl2_engine as engine


def prepare(terminals, wiring, direction):
    blocks, errors = engine.parse_terminals(terminals)
    if errors:
        raise ValueError("；".join(errors[:10]))
    # 先用完整接线引用建立解析域，再过滤到所选端子，避免丢掉未选端子上的
    # 去向文字而把前后两根电缆误并，也保留原始电缆序号。
    universe = [dict(block, terminals=list(block["terminals"])) for block in blocks]
    candidates = []
    for unit in engine.RECORD_SPLIT.split(wiring):
        fields = engine.split_fields(unit)
        candidates.extend(fields[i] for i in range(0, len(fields) - 1, 2))
    for token in candidates:
        token = token.strip()
        if engine.reference_matches(token, universe)[0]:
            continue
        match = re.fullmatch(r"([^:：\s]+)[:：]([^:：\s]+)", token)
        if not match:
            match = re.fullmatch(r"([0-9A-Za-z-]*[A-Za-z])([0-9]+)", token)
        if match:
            name, number = match.groups()
            block = next((b for b in universe if b["name"] == name), None)
            if block is None:
                block = {"name": name, "terminals": []}
                universe.append(block)
            if number not in block["terminals"]:
                block["terminals"].append(number)
    connections, cables, errors, warnings = engine.parse_wiring(wiring, universe, "", "WL")
    if errors:
        raise ValueError("；".join(errors[:10]))
    selected = {(b["name"], str(n)) for b in blocks for n in b["terminals"]}
    kept = [c for c in connections if (c["terminalBlock"], c["terminal"]) in selected]
    skipped = len(connections) - len(kept)
    return dict(projectName="端子排接线图", terminalBlocks=blocks, connections=kept,
                direction=direction, firstDistance=10, distanceStep=5, textHeight=3), skipped


def atom(value):
    if isinstance(value, str):
        return '"' + value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ').replace('\r', ' ') + '"'
    value = float(value)
    if not math.isfinite(value):
        raise ValueError("绘图坐标不是有限数值")
    return str(int(value)) if value.is_integer() else repr(value)


def entity_data(entity):
    typ = entity.dxftype()
    pairs = [(0, typ), (8, entity.dxf.layer), (62, entity.dxf.color)]
    points = []
    if typ == "LINE":
        points = [(10, entity.dxf.start), (11, entity.dxf.end)]
    elif typ == "TEXT":
        pairs += [(1, entity.dxf.text), (7, entity.dxf.style), (40, entity.dxf.height),
                  (41, entity.dxf.width), (50, math.radians(entity.dxf.rotation)),
                  (72, entity.dxf.halign), (73, entity.dxf.valign)]
        points = [(10, entity.dxf.insert), (11, entity.dxf.align_point or entity.dxf.insert)]
    elif typ == "LWPOLYLINE":
        pairs = [(0, typ), (100, "AcDbEntity"), (8, entity.dxf.layer),
                 (62, entity.dxf.color), (100, "AcDbPolyline"), (90, len(entity)), (70, 1)]
        points = [(10, (x, y)) for x, y, *_ in entity.get_points()]
    else:
        raise ValueError("不支持的绘图图元：" + typ)
    return "(" + " ".join("(%d . %s)" % (code, atom(value)) for code, value in pairs) + " " + " ".join(
        "(%d %s)" % (code, " ".join(atom(v) for v in point)) for code, point in points) + ")"


def generate(terminal_path, wiring_path, output_path, direction):
    import ezdxf
    params, skipped = prepare(Path(terminal_path).read_text(encoding="utf-8-sig"),
                              Path(wiring_path).read_text(encoding="utf-8-sig"), direction)
    with tempfile.TemporaryDirectory(prefix="zddl2-") as folder:
        path = Path(folder) / "drawing.dxf"
        result = engine.build_dxf(params, engine.DRAWING, path)
        entities = list(ezdxf.readfile(path).modelspace())
        message = "生成 %d 个端子、%d 组电缆；跳过未选端子的 %d 条接线。" % (
            result["terminals"], result["cables"], skipped)
        rows = ['(T %d %s)' % (len(entities), atom(message))]
        rows.extend(entity_data(entity) for entity in entities)
    Path(output_path).write_text("\n".join(rows) + "\n", encoding="utf-8")


def main():
    terminal, wiring, output, direction = sys.argv[1:]
    try:
        generate(terminal, wiring, output, direction)
        return 0
    except Exception as error:
        Path(output).write_text('(nil 0 %s)\n' % atom(str(error)), encoding="utf-8")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
