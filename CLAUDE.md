# ZW-auto_lisp 项目规则（强制遵守）

本项目是 AutoCAD 2018 的 AutoLISP 插件集合。以下规则是**硬性要求**，不可省略、不可自行判断。

## 一、文件编码（最重要）

1. **所有 AutoLISP 文件（`.lsp`）必须保存为 ANSI / GBK 编码**，绝对不允许 UTF-8、UTF-8 BOM、UTF-16。
2. **CAD 相关文本文件**（`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat`）同样优先 ANSI / GBK。
3. **换行符必须是 Windows CRLF（`\r\n`）**，不允许 LF-only。
4. **中文字符串必须在 AutoCAD 2018 中正常显示**，出现任何 `\xef\xbf\xbd`、`?`、方块都视为严重 bug。
5. C# 源码可以 UTF-8，但与 CAD 交互的字符串要验证在 2018 中不乱码。

## 二、编辑 GBK 文件的正确方式（强制）

**重要教训**：Claude Code 的 `Edit` 和 `Write` 工具按 UTF-8 处理文件。直接用它们编辑 GBK 文件，会把所有无法用 UTF-8 解码的中文字节替换成 `\xef\xbf\xbd`，**整个文件的中文会全部损坏，不可逆**（曾经发生过一次，损坏 438 行）。

因此：

- **禁止** 对 `.lsp` / `.dcl` / `.scr` / `.mnl` 等 GBK 文件直接使用 `Edit` 或 `Write` 工具。
- **必须** 用 Python 做字节级读写，且显式指定 `encoding='gbk'`：
  ```python
  # 读
  text = open(path, 'rb').read().decode('gbk')
  # 写
  out_bytes = text.replace('\n', '\r\n').encode('gbk')  # 确保 CRLF + GBK
  open(path, 'wb').write(out_bytes)
  ```
- **必须** 在写入后立即验证：
  ```python
  back = open(path, 'rb').read()
  assert b'\xef\xbf\xbd' not in back     # 无替换字符
  back.decode('gbk')                      # strict 解码不抛错
  assert b'\r\n' in back                  # 有 CRLF
  ```
- **只用 ASCII 补丁**：如果改动内容本身不含中文，可以直接在 Python 里做字符串替换；**如果补丁内容含中文**，用 GBK 字节字面量（`b'\xb8\xfc\xd0\xc2'`）或先写到独立 `.gbk` 临时文件再 `.decode('gbk')` 合并，绝不在 Edit 工具里粘贴中文。

## 三、PowerShell / Python 生成文件

- **Python**：写入 CAD 相关文件必须显式 `encoding='gbk'`，不能用默认编码。
- **PowerShell**：禁止默认写入（PS5 默认 UTF-8 BOM，PS7 默认 UTF-8 无 BOM，都不行）。必须用 `[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::GetEncoding(936))` 或 `Out-File -Encoding Default`（中文 Windows 下是 GBK）。

## 四、测试环境

- **插件必须在 Windows 原生环境中测试**（AutoCAD 2018）。
- **不以 WSL2 测试结果为最终依据**（路径、编码、COM 行为都会不一致）。

## 五、Git 与备份

- 修改 `.lsp` 主文件前，先用 `cp` 复制一份 `.bak_YYYYMMDD` 备份（不要走 Edit 工具触发编码转换）。
- 如发现文件已被 UTF-8 化，立刻停手，从最近的干净备份恢复，不要在损坏的文件上继续打补丁。

## 六、项目结构要点

- 主文件：`E:\366256\ZW-auto_lisp\AA整合版本.lsp`（所有命令整合版）
- 加载器：`E:\366256\ZW-auto_lisp\aa-loader.lsp`
- 历史备份命名：`<原名>.bak_YYYYMMDD` 或 `<原名>.bak-encoding-YYYYMMDD-HHMMSS`

以上规则优先于 Claude Code 的默认工具选择偏好。
