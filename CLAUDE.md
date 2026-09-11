# ZW-auto_lisp 项目规则

本项目是 ZWCAD 2026 AutoLISP 插件集合。以下是必须遵守的项目级约束。

## 文件与编码

- `.lsp`、`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat` 以及项目源码统一使用 UTF-8 无 BOM；CAD 文本使用 Windows CRLF。
- 写入后必须严格按 UTF-8 解码检查，确认无 BOM、无替换字符、无乱码；禁止使用隐式 ANSI 编码。
- 经用户明确要求进行 CAD 验证时，加载 UTF-8 LISP 前确认 `LISPSYS=1` 并已重启，中文字符串在实际 CAD 环境验证；未获明确要求时只做静态检查，不连接或操作 CAD。
- 修改 `AA整合版本.lsp` 前先做字节级备份；发现编码、乱码或换行异常时立即停止，从干净备份恢复。
- 修改 LISP 后必须实际执行整文件表达式解析和受影响命令的结构检查；编码检查、索引生成成功不代表语法通过。不得只数括号字符，必须区分字符串与注释，并检查命令是否仍是顶层定义。

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
- AutoLISP 的 `last` 直接返回最后一个元素，不是末尾子列表；取最后一个坐标点使用 `(last pts)`，不得误写成 `(car (last pts))`。
- `FDX` 分配后直接复用 `dx:apply-group`，不得调用交互式 `c:DX` 造成二次选择或嵌套撤销组；保留本批恢复逻辑。离线检查运行 `python tools/check_fdx_static.py`。
- `CC` 读取已有剪贴板，预选单个文字后按两点位移复制，仅替换副本完整内容；不得改回提取源文字到剪贴板或调用 `c:QE`。离线检查运行 `python tools/check_cc_static.py`，使用说明见 `docs/CC.md`。
- 改动 AA整合版本.lsp 后，交付前优先运行一键静态检查 python tools/check_all_static.py（编码、整文件解析、命令清单、undo 配对，并串跑 FDX/CC/DES/GTX/XY 专项检查）。
- `ZHONG`、`ZUO`、`YOU`、`SHANG`、`XIA` 共用 `aa:align-text-cmd`；`SYAN`、`XYAN` 共用 `aa:extend-line-cmd`。
- 文字对齐优先使用 COM 的 `Alignment` / `AttachmentPoint`，用 `vl-catch-all-error-p` 判断结果，并补偿外包框位置。

## 批处理性能

- 大批量处理优先使用选择集过滤和 `entmod`，循环结束后统一 `redraw`；不要逐对象调用原生命令或 `entupd`，除非必须立即读取更新后几何。
- 附近邻居查询优先使用逐实体 `ssget "_C"`，不要先用 `ssget "_X"` 扫描全图；斜 UCS 下按需使用 `(trans pt 0 1)`。
- `MJ` 单列表格的文字包围盒和横线位置各采集一次并缓存，表格线用 `entmod` 批量修改，文字按缓存行中心移动。

## ZTF 与验收

- `ZTF` 位于 `AA整合版本.lsp`，界面文件为根目录 `ZTF.dcl`；修改后的整合文件需重新加载才生效，未经用户明确要求不得主动操作 CAD 加载。
- `ZTF.dcl` 控件标签保持 ASCII；SHX 用 `findfile` 从 CAD 支持路径查找，不得把 DCL 内嵌到 LISP。
- 默认只做静态检查。只有用户明确要求使用 CAD 验证时，才可连接或操作 Windows 原生 ZWCAD 2026；修复命令不等于授权验证，禁止主动新建测试图、发送命令、重新加载或通过 COM/界面自动化测试。未验证必须如实说明，WSL 结果不能替代 CAD 验证。CAD 卡死时不得擅自关闭、结束进程或重启。
- 交付前核对编码、换行、命令清单、整合文件及两份命令索引均已同步。
