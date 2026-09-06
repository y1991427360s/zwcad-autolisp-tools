# ZW-auto_lisp 项目规则

本项目是 ZWCAD 2026 AutoLISP 插件集合。以下是必须遵守的项目级约束。

## 文件与编码

- `.lsp`、`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat` 以及项目源码统一使用 UTF-8 无 BOM；CAD 文本使用 Windows CRLF。
- 写入后必须严格按 UTF-8 解码检查，确认无 BOM、无替换字符、无乱码；禁止使用隐式 ANSI 编码。
- ZWCAD 加载 UTF-8 LISP 前确认 `LISPSYS=1` 并已重启；中文字符串必须在实际 CAD 环境验证。
- 修改 `AA整合版本.lsp` 前先做字节级备份；发现编码、乱码或换行异常时立即停止，从干净备份恢复。

## 项目结构与同步

- 主整合文件：`AA整合版本.lsp`；启动加载只保留它和 `V6/aicad_aa_loader.lsp`，不得重新部署已卸载的 CADTools/YS-Tools。
- `ZJ`、`YJ` 等命令必须内嵌在整合文件中，不得依赖已删除的小命令目录。
- 新增、删除、修改或改名命令后，必须同步整合文件并运行 `python gen_命令索引.py`，核对 `命令索引.md` 与 `命令索引.html`。
- 文件开头的命令清单必须覆盖所有实际 `(defun c:...)` 入口，不保留已删除命令。
- 本文件与 `CLAUDE.md` 必须完全一致。

## 命令实现规范

- 常规命令使用 `aa:cmd-begin` / `aa:cmd-end`，局部变量必须包含 `*error* aa:tag aa:doc aa:undo-open aa:old-cmdecho`。
- 有专属 `*error*` 的命令使用 `aa:undo-mark-on` / `aa:undo-mark-off`，不得覆盖资源清理逻辑。
- 所有修改图形的命令必须位于一个 undo 分组内，使一次 `U` 整体撤销。
- 排序统一使用 `aa:merge-sort`；禁止大列表使用 `vl-sort`。ZTF 小列表沿用 `aa:insert-sort`。
- `ZHONG`、`ZUO`、`YOU`、`SHANG`、`XIA` 共用 `aa:align-text-cmd`；`SYAN`、`XYAN` 共用 `aa:extend-line-cmd`。
- 文字对齐优先使用 COM 的 `Alignment` / `AttachmentPoint`，用 `vl-catch-all-error-p` 判断结果，并补偿外包框位置。

## 批处理性能

- 大批量处理优先使用选择集过滤和 `entmod`，循环结束后统一 `redraw`；不要逐对象调用原生命令或 `entupd`，除非必须立即读取更新后几何。
- 附近邻居查询优先使用逐实体 `ssget "_C"`，不要先用 `ssget "_X"` 扫描全图；斜 UCS 下按需使用 `(trans pt 0 1)`。
- `MJ` 单列表格的文字包围盒和横线位置各采集一次并缓存，表格线用 `entmod` 批量修改，文字按缓存行中心移动。

## ZTF 与验收

- `ZTF` 位于 `AA整合版本.lsp`，界面文件为根目录 `ZTF.dcl`；修改后必须重新加载整合文件。
- `ZTF.dcl` 控件标签保持 ASCII；SHX 用 `findfile` 从 CAD 支持路径查找，不得把 DCL 内嵌到 LISP。
- 最终测试必须在 Windows 原生 ZWCAD 2026 中完成；WSL 结果不能替代 CAD 验证。
- 交付前核对编码、换行、命令清单、整合文件及两份命令索引均已同步。
