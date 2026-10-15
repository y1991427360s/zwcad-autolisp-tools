# 向 Codex 提出插件更新的常用话术

在 `D:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp` 项目中开始对话即可。默认中望 CAD 2026 优先，AutoCAD 2018 等用户要求时再补齐；完成中望功能更新后记录更新时间及待同步项。

## 优先开发中望

> 帮我给中望 CAD 增加/修改 XXX 功能，AutoCAD 暂时不更新。只做静态检查。

将 XXX 换成具体命令或需求，说明希望得到的效果；有例子时附上修改前后的内容。

## 补齐 AutoCAD 的积压更新

> 根据双平台同步台账，把 AutoCAD 2018 更新到中望当前版本，保留平台差异，只做静态检查。

智能体应读取台账、核对两边最新源码，移植需要同步的功能，保留 AutoCAD 的 GBK 编码、SDK 和加载路径；完成检查后更新同步状态与完成时间。

## 只同步一个功能

> 把中望的 XXX 命令同步到 AutoCAD 2018，其他功能先不动。只做静态检查。

## 查看尚未同步的功能

> 看一下同步台账，告诉我 AutoCAD 还有哪些功能没跟上中望；历史待核对项请核对源码后再下结论，先不修改代码。

## 同时更新两版

> 这次 XXX 功能请同时更新中望 CAD 2026 和 AutoCAD 2018，保留各自平台差异，分别做静态检查并更新同步台账。

## 在其他目录或新对话中开始

> 请先读取 D:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\AGENTS.md、docs\DUAL_PLATFORM.md 和 docs\PLATFORM_SYNC_LOG.md，再按项目规范处理以下需求：……

上述两份 docs 文件均指该项目目录内的文件。未明确要求 CAD 实机验证时，智能体不得连接、加载或操作 CAD。源码更新、静态检查通过和 CAD 实机验证是不同状态，交付时需分别说明。

关联文档：[双平台开发说明](DUAL_PLATFORM.md)、[更新与待同步台账](PLATFORM_SYNC_LOG.md)。
