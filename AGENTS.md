# ZW-auto_lisp 项目规则（必须遵守）

本项目是 ZWCAD 2026（中望 CAD 2026）AutoLISP 插件集合。以下规则是硬性要求，优先于各工具的默认编辑习惯。

本项目根目录的 `AGENTS.md` 与 `CLAUDE.md` 必须永远保持完全同步。更新其中任意一份后，必须立即把同样内容写入另一份。

## 一、文件编码（最重要）

1. 所有 AutoLISP 文件（`.lsp`）必须保存为 **UTF-8 无 BOM**，不再使用 ANSI / GBK / UTF-16。
2. CAD 相关文本文件（`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat`）以及项目内 Markdown、Python、PowerShell、VBScript、C# 等文本源码统一使用 **UTF-8 无 BOM**。
3. `.lsp` 及 CAD 相关文本文件必须使用 Windows CRLF（`\r\n`）；其他项目文本保持各自既有换行风格。
4. 中文字符串必须在 ZWCAD 2026 中正常显示。出现任何 `\xef\xbf\xbd`、`?`、方块都视为严重 bug。
5. ZWCAD 2026 必须将 `LISPSYS` 设为 `1` 并重启后再加载 UTF-8 LISP；与 CAD 交互的中文字符串仍须实际验证不乱码。

## 二、编辑 UTF-8 文件的正确方式（强制）

项目文本已经统一迁移到 UTF-8 无 BOM。Codex、Claude Code 等工具可直接按 UTF-8 编辑，但必须避免写入 BOM、UTF-16 或回退到系统默认 ANSI 编码。

因此：

- `.lsp` / `.dcl` / `.scr` / `.mnl` / `.lin` / `.pat` 可使用普通 UTF-8 文本补丁编辑。
- 脚本读写时必须显式指定 `utf-8`；需要严格检查时使用拒绝无效字节的 UTF-8 解码器。
- 写入后必须验证文件可被严格 UTF-8 解码、没有 BOM、没有替换字符，CAD 文本仍为 CRLF。
- 禁止使用 PowerShell 旧版默认编码或任何隐式 ANSI 编码写入项目文本。

推荐 Python 方式：

```python
from pathlib import Path

path = Path(r"E:\366256\ZW-auto_lisp\AA整合版本.lsp")

# 读
text = path.read_bytes().decode("utf-8")

# 修改 text 后写回，确保 CRLF + UTF-8 无 BOM
out = text.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")
path.write_bytes(out.encode("utf-8"))

# 验证
back = path.read_bytes()
assert b"\xef\xbf\xbd" not in back
assert not back.startswith(b"\xef\xbb\xbf")
back.decode("utf-8", errors="strict")
assert b"\r\n" in back
```

PowerShell 写 UTF-8 无 BOM 文件时应显式指定编码，例如：

```powershell
[System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
```

不要依赖 PowerShell 版本相关的默认编码写入 CAD 相关文件。

## 三、修改前备份

修改 `.lsp` 主文件前，必须先复制一份备份，命名格式建议：

- `<原名>.bak_YYYYMMDD`
- `<原名>.bak-encoding-YYYYMMDD-HHMMSS`

备份必须通过字节级复制完成，不能触发编码转换。

## 四、测试环境

1. 插件必须在 Windows 原生 CAD 环境中测试。
2. ZWCAD 2026 是主要日常使用和当前工作流验证环境。
3. 不以 WSL2 测试结果作为最终依据，因为路径、编码、COM 行为都可能不一致。

## 五、项目结构要点

- 主整合文件：`E:\366256\ZW-auto_lisp\AA整合版本.lsp`
- 启动加载：`AA整合版本.lsp` 直接加入 APPLOAD 启动组；AICAD 面板由 `E:\366256\ZW-auto_lisp\V6\aicad_aa_loader.lsp` 加载。
- 全部常用 AutoLISP 命令均已整合到 `E:\366256\ZW-auto_lisp\AA整合版本.lsp`，不再保留独立小命令目录。
- Markdown 命令索引：`E:\366256\ZW-auto_lisp\命令索引.md`
- HTML 命令索引：`E:\366256\ZW-auto_lisp\命令索引.html`
- Claude 规则文件：`E:\366256\ZW-auto_lisp\CLAUDE.md`
- Codex 规则文件：`E:\366256\ZW-auto_lisp\AGENTS.md`

## 六、发现编码异常时

如果发现文件不是 UTF-8、带 BOM、出现 `\xef\xbf\xbd`、中文乱码或换行异常，必须立刻停手：

1. 不要在损坏文件上继续打补丁。
2. 从最近的干净备份恢复。
3. 恢复后重新按 UTF-8 无 BOM 方式修改。
4. 再次执行 UTF-8 / 无 BOM / CRLF / 无替换字符验证。

## 七、命令清单维护（强制）

1. `AA整合版本.lsp` 文件开头的 `;;; 包含以下命令:` 清单必须覆盖当前文件内所有 `(defun c:命令名 ...)` 入口。
2. 每次新增、删除、改名命令，必须同步更新该清单，不能只改函数本体。
3. 更新清单时优先以实际存在的 `(defun c:...)` 为准，不保留已经不存在的旧命令。
4. 命令说明要简短写清用途，新增命令至少写明触发命令名和核心功能。

## 八、批量处理性能

1. 批量处理大量实体时，不要在循环中逐对象调用原生命令或 `entupd`；优先把选择集一次性交给原生命令，使用 `entmod` 完成逐实体数据修改后再统一 `redraw`。
2. `MJ` 处理单列表格时，文字包围盒和横线位置必须各采集一次后缓存复用；禁止在收窄前后重复调用 `ZZ` 的逐文字邻边搜索。表格线用 `entmod` 批量修改 X 坐标，文字按缓存的行中心一次移动，最后统一 `redraw`。

## 九、整合版本与命令索引同步（强制）

1. 每次新增、修改、删除或改名 AutoLISP 命令后，必须重新更新 `AA整合版本.lsp`，确保整合版本包含本次完成的最新脚本内容；不得只修改独立脚本而遗漏整合版本。
2. 整合版本更新完成后，必须在项目根目录运行 `python gen_命令索引.py`，同时重新生成 `命令索引.md` 和 `命令索引.html`。
3. Markdown 与 HTML 两份命令索引必须保持内容一致，均以生成器扫描到的实际 `.lsp` 命令为准，禁止只更新其中一份。
4. 交付前必须核对 `AA整合版本.lsp`、`命令索引.md`、`命令索引.html` 均已反映本次脚本修改。

## 十、ZWCAD 文字对正兼容性

1. 在 ZWCAD 2026 中统一 `TEXT` / `MTEXT` 对正方式时，优先使用 COM 属性 `Alignment` / `AttachmentPoint` 设置完整对正枚举，不要只修改 DXF 72、73 或 71 的单个方向分量。
2. `vla-put-Alignment`、`vla-put-AttachmentPoint` 等 COM 属性写入成功时可能返回 `nil`；必须用 `vl-catch-all-error-p` 判断是否报错，不能把空返回值当成失败。
3. 改变对正方式前后应读取外包框并补偿位置，再执行最终对齐，避免文字因锚点变化先发生跳位。

## 十一、CAD 启动加载边界

1. CADTools/YS-Tools 已从 ZWCAD 支持目录、启动文件和 APPLOAD 注册表中卸载，不得重新部署，以免覆盖整合版本中的同名命令。
2. ZWCAD 启动套件只保留 `E:\366256\ZW-auto_lisp\AA整合版本.lsp` 和 `E:\366256\ZW-auto_lisp\V6\aicad_aa_loader.lsp`。
3. AICAD 的固定目录为 `E:\366256\ZW-auto_lisp\V6`；`aicad_aa_loader.lsp`、`aicad_extension.lsp`、`acaddoc.lsp` 和 `AICADAA_BASEDIR` 不得再引用桌面旧路径。
4. `ZJ`、`YJ` 等命令必须直接内嵌在 `AA整合版本.lsp` 中，不得依赖已删除的独立小命令文件或目录。

## 十二、ZTF 字体搜索器维护要点

1. `ZTF` 命令位于 `AA整合版本.lsp`，DCL 界面文件为项目根目录的 `ZTF.dcl`；修改主 LISP 后必须重新加载整合文件，CAD 内存不会自动更新旧函数定义。
2. ZWCAD 2026 对 DCL 中文 UTF-8 控件文本存在解析乱码风险，`ZTF.dcl` 控件标签保持 ASCII；中文提示放在 LISP 的 `alert` 或命令行中。
3. ZWCAD 2026 中不要用 `vl-sort` / `acad_strlsort` 对 ZTF 样式名排序；当前使用手写插入排序，避免出现 `stringp: T`。
4. Windows 字体在 `Fonts` 目录，`txt.shx` 等 SHX 字体在 CAD 支持路径；SHX 必须用 `findfile` 从支持路径查找，不能只扫描 Windows Fonts。
5. `ZTF.dcl` 不在支持路径时，代码会按支持路径、主 LISP 加载目录和项目固定目录依次定位；不要把 DCL 内容直接内嵌到 LISP。
