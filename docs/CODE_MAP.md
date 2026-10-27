# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，24741 行，1037 个函数，其中 171 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 330-379 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:702, aa:ys-line:253, aa:ys-ring:322, aa:ys-rim:311, aa:ys-snowflake:279, aa:ys-detail:304, aa:cmd-end:715 |
| `YS1` | 508-534 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:702, aa:ys-line:253, aa:ys1-t:408, aa:ys1-g:425, aa:ys1-o:445, aa:ys1-d:482, aa:cmd-end:715 |
| `DES` | 568-633 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:702, des:key-less-p:537, aa:merge-sort:790, des:record-less-p:542, des:x-less-p:546, des:overlap-p:552, aa:cmd-end:715 |
| `YSTEMP` | 646-700 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:702, aa:merge-sort:790, ystemp:y-less-p:636, ystemp:pair-p:640, aa:cmd-end:715 |
| `ZTF` | 1050-1063 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:702, ztf:collect-font-records:920, ztf:run-dialog:1020, aa:cmd-end:715 |
| `YSDL` | 1606-1807 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:741, aa:undo-mark-on:733, aa:ysdl-get-plain-text:1387, aa:ysdl-get-lwpoly-rect:1441, aa:ysdl-sort-boxes:1508, aa:ysdl-desktop-dir:1584, aa:merge-sort:790, aa:ysdl-parse-rows-from-text-data:1536, aa:ysdl-clean-text:1411, aa:ysdl-format-categorized-row:1576, aa:ysdl-build-csv-field:1402, aa:ysdl-reorder-row:1419 …共 13 个 |
| `Q` | 1819-1845 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `T` | 2019-2023 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:702, txt:run:2004, aa:cmd-end:715 |
| `ZHU` | 2075-2119 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:702, aa:ysdl-get-plain-text:1387, zhu:classify:2044, zhu:trim:2032, zhu:pick-name:2063, zhu:build-note:2054, aa:cmd-end:715 |
| `HWT` | 2342-2393 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:702, aa:ysdl-get-plain-text:1387, aa:merge-sort:790, hwt:counts-text:2265, hwt:row-counts:2127, hwt:draw:2290, hwt:layout:2171, hwt:cable-no:2137, hwt:draw-list:2319, hwt:cable-rows:2252, aa:cmd-end:715 |
| `T2` | 2887-2906 | 20 | 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。 | aa:cmd-begin:702, txt2:process-selection:2813, aa:cmd-end:715 |
| `ABCN` | 2922-2973 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:702, aa:safe-get-bbox:1098, aa:safe-move-entity:1144, aa:cmd-end:715 |
| `H` | 2975-3102 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:702, aa:normalize-text-horizontal-align:3870, aa:merge-sort:790, aa:cmd-end:715 |
| `H2` | 3109-3233 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:702, aa:normalize-text-horizontal-align:3870, aa:merge-sort:790, aa:cmd-end:715 |
| `Y` | 3259-3263 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `DZ` | 3303-3337 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:702, aa:ysdl-get-plain-text:1387, aa:dz-number-p:3269, aa:dz-color-text:3285, aa:cmd-end:715 |
| `YY` | 3343-3347 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `RR` | 3353-3357 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `WW` | 3363-3367 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `WWW` | 3373-3379 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:702, aa:deep-color-cmd:3698, aa:cmd-end:715 |
| `XU` | 3385-3459 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3465-3469 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `PP` | 3475-3479 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `HH` | 3485-3489 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:702, aa:color-cmd:3240, aa:cmd-end:715 |
| `HUI` | 3755-3760 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:702, aa:deep-color-cmd:3698, aa:cmd-end:715 |
| `ZHONG` | 3814-3818 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3763, aa:find-ref-by-top-bbox:1210, aa:bbox-center-x:1122, aa:normalize-text-horizontal-align:3870, aa:align-text-horizontal-by-bbox:1250 |
| `ZUO` | 3899-3903 | 5 | 将选中文字统一为左中对正，并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3763, aa:find-ref-by-left-bbox:1170, aa:bbox-left-x:1128, aa:normalize-text-horizontal-align:3870, aa:align-text-horizontal-by-bbox:1250 |
| `AZUO` | 3909-4028 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:702, aa:cmd-end:715, aa:safe-get-bbox:1098, aa:bbox-left-x:1128, aa:safe-move-entity:1144 |
| `HP` | 4034-4171 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:702, aa:cmd-end:715, aa:safe-get-bbox:1098, aa:bbox-left-x:1128, aa:bbox-top-y:1136, aa:merge-sort:790, aa:bbox-right-x:1132, aa:safe-move-entity:1144 |
| `HP2` | 4177-4320 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:702, aa:cmd-end:715, aa:normalize-text-horizontal-align:3870, aa:safe-get-bbox:1098, aa:bbox-center-x:1122, aa:bbox-top-y:1136, aa:bbox-bottom-y:1140, aa:merge-sort:790, aa:safe-move-entity:1144 |
| `YOU` | 4323-4327 | 5 | 将选中文字统一为右中对正，并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3763, aa:find-ref-by-right-bbox:1190, aa:bbox-right-x:1132, aa:normalize-text-horizontal-align:3870, aa:align-text-horizontal-by-bbox:1250 |
| `AYOU` | 4332-4451 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:702, aa:cmd-end:715, aa:safe-get-bbox:1098, aa:bbox-right-x:1132, aa:safe-move-entity:1144 |
| `SHANG` | 4454-4458 | 5 | 将选中文字统一为中上对正，并以最上方文字为基准上对齐。 | aa:align-text-cmd:3763, aa:find-ref-by-top-bbox:1210, aa:bbox-top-y:1136, aa:normalize-text-vertical-align:3884, aa:align-text-vertical-by-bbox:1264 |
| `ASHANG` | 4464-4583 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:702, aa:cmd-end:715, aa:safe-get-bbox:1098, aa:bbox-top-y:1136, aa:safe-move-entity:1144 |
| `XIA` | 4586-4590 | 5 | 将选中文字统一为中下对正，并以最下方文字为基准下对齐。 | aa:align-text-cmd:3763, aa:find-ref-by-bottom-bbox:1230, aa:bbox-bottom-y:1140, aa:normalize-text-vertical-align:3884, aa:align-text-vertical-by-bbox:1264 |
| `AXIA` | 4595-4714 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:702, aa:cmd-end:715, aa:safe-get-bbox:1098, aa:bbox-bottom-y:1140, aa:safe-move-entity:1144 |
| `HE` | 4716-4809 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:702, aa:insert-sort:762, aa:cmd-end:715 |
| `QR` | 4844-4889 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:702, qr:last-height:4820, qr:height-str:4839, qr:save-height:4832, aa:cmd-end:715 |
| `QR2` | 4895-4925 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:702, qr:last-height:4820, qr:height-str:4839, qr:save-height:4832, aa:cmd-end:715 |
| `DEA` | 4931-4954 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `DEK` | 4961-4981 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `DEH` | 5024-5054 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:702, aa:has-chinese:5002, aa:ysdl-get-plain-text:1387, aa:layer-locked-p:4987, aa:cmd-end:715 |
| `DET` | 5084-5125 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:702, det:split-values:5064, aa:ysdl-get-raw-text:1302, aa:layer-locked-p:4987, aa:cmd-end:715 |
| `A2T` | 5164-5201 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:702, a2t:pick-string:5142, a2t:layer-locked-p:5137, a2t:text-dxf:5154, aa:cmd-end:715 |
| `WI` | 5207-5247 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `ATW` | 5254-5338 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:702, aa:safe-get-bbox:1098, aa:bbox-right-x:1132, aa:bbox-left-x:1128, aa:safe-move-entity:1144, aa:cmd-end:715 |
| `XB` | 5344-5397 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `YAN` | 5403-5519 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:762 |
| `LL` | 5530-5559 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5685, aa:undo-mark-off:741, aa:undo-mark-on:733 |
| `MM` | 5708-5740 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5685, aa:undo-mark-off:741, aa:undo-mark-on:733, aa:ortho-report:5674, aa:ortho-drag:5634 |
| `SS` | 5746-5778 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5685, aa:undo-mark-off:741, aa:undo-mark-on:733, aa:ortho-report:5674, aa:ortho-drag:5634 |
| `SW` | 5867-5922 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:702, aa:cmd-error:231, aa:ss-format-vec:5786, aa:ss-do-interactive-stretch:5832, aa:cmd-end:715 |
| `SYI` | 6032-6032 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5965 |
| `XYI` | 6033-6033 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5965 |
| `SSS` | 6125-6196 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:6087, aa:sss-lowest-row-line:6113, aa:sss-find-pair:6060, aa:sss-horizontal-segments:6039, aa:cmd-begin:702, aa:cmd-end:715 |
| `SYAN` | 6239-6239 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6199 |
| `XYAN` | 6242-6242 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6199 |
| `SJ` | 6256-6282 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `XJ` | 6284-6310 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `SYJ` | 6353-6353 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6311 |
| `XYJ` | 6354-6354 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6311 |
| `GTX` | 6484-6664 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:741, aa:undo-mark-on:733, aa:gtx-select-prefix-text:6468, aa:ysdl-get-plain-text:1387, aa:try-get-bbox:1087, aa:merge-sort:790, aa:gtx-rows:6427, aa:gtx-key:6396, aa:gtx-find-last-char:6384, aa:gtx-natural-less:6404, aa:gtx-create-text-entity:6444 |
| `GTY` | 6907-7054 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6898, aa:gty-get-text-width:6735, aa:gty-separated-rows:6770, aa:gty-add-row:6804, aa:merge-sort:790, aa:gty-get-item-x:6703, aa:gty-order-rows:6854, aa:gty-column-widths:6866, aa:gty-row-tree:6816, aa:gty-build-sort-key:6711, aa:gty-tree-item:6827, aa:gty-copy-text:6878 …共 14 个 |
| `GTZ` | 7060-7217 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6735, aa:merge-sort:790, aa:gty-move-entity:6757 |
| `HWD` | 7244-7317 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:702, aa:safe-get-bbox:1098, aa:gty-get-text-width:6735, aa:merge-sort:790, aa:hwd-rows:7223, aa:hwd-make-text:7230, aa:cmd-end:715 |
| `BIAN` | 7373-7403 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:702, bian-draw-one:7345, aa:cmd-end:715 |
| `LAN` | 7443-7591 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:702, lan-vert-mode:7414, lan-get-option:7428, aa:cmd-end:715 |
| `XIN` | 7598-7672 | 75 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `XY` | 8544-8558 | 15 | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | aa:cmd-begin:702, xy:run-xin:7967, xy:run-yuan:8362, aa:cmd-end:715 |
| `XYG` | 8958-9153 | 196 | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:702, aa:cmd-end:715, xy:filter-green-hlines:8524, xyg:dedup-hlines:8739, xy:ss->list:7717, xyg:find-prefix-text:8565, aa:ysdl-get-plain-text:1387, aa:gtx-select-prefix-text:6468, aa:link-xdata:9163, xy:run-xin:7967, xy:run-yuan:8362, xyg:sort-lines-desc:8780 …共 22 个 |
| `SX0` | 9419-9458 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:702, aa:link-dwg-id:9180, aa:link-info:9168, aa:link-root-p:9176, aa:cmd-end:715 |
| `YSSX0` | 9465-9505 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:702, aa:link-dwg-id:9180, aa:link-info:9168, aa:link-root-p:9176, aa:cmd-end:715 |
| `SX` | 9512-9545 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:702, aa:link-dwg-id:9180, aa:link-info:9168, aa:link-root-p:9176, aa:cmd-end:715 |
| `SXC` | 9565-9654 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:702, aa:rep-begin:18989, aa:link-dwg-id:9180, aa:link-info:9168, aa:rep-item:19000, aa:link-txt:9560, aa:link-root-p:9176, aa:link-root-ed:9661, aa:link-dwg-label:9552, aa:merge-sort:790, aa:rep-info:19006, aa:rep-counts:19055 …共 14 个 |
| `SX1` | 9680-9748 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:702, aa:link-clock:9656, aa:link-dwg-id:9180, aa:link-info:9168, aa:link-root-p:9176, aa:link-root-ed:9661, aa:link-text-for:9198, aa:link-file-path:9230, aa:link-export:9269, aa:cmd-end:715 |
| `SX2` | 9756-9821 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:702, aa:link-dwg-id:9180, aa:link-info:9168, aa:link-ask-folder:9401, aa:link-collect-files:9335, aa:merge-sort:790, aa:link-file-time:9326, aa:link-read-file:9314, aa:link-uid<:9220, aa:link-count-conflicts:9363, aa:link-join:9351, aa:link-text-from-rec:9210 …共 13 个 |
| `HBDL` | 10128-10233 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:702, aa:cmd-end:715, aa:ysdl-get-plain-text:1387, hb:cluster-rows:9898, hb:parse-row:9927, hb:apply-merge-in-place:10043 |
| `NU` | 10529-10580 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:10478, aa:num-int-target-p:10459 |
| `KAI` | 10771-10854 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:10710, aa:kai-process-text:10728 |
| `ZHENG` | 10925-11055 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:10863, aa:safe-get-bbox:1098, aa:zheng-align-text-to-rect-center:10912, aa:zheng-line-mid-x:10878, aa:zheng-add-texts-after-explode:10885, aa:zheng-align-text-center-x:10903 |
| `AAE` | 11472-11557 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:702, aae:split-lines:11426, aae:locate-dcl:11559, aae:resolve-val:11455, aa:cmd-end:715 |
| `HAO` | 11576-11580 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:702, fillframes-run:11280, aa:cmd-end:715 |
| `HAO2` | 11822-11979 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:702, blk-insertpt:11101, hao2:block-name:11593, hao2:sort-blocks:11607, zdml2:collect-all-texts:11655, hao2:format-num:11586, hao2:find-existing-text-fast:11789, tktj:current-space:16464, tktj:ensure-text-style:16474, aa:cmd-end:715 |
| `MING` | 12124-12288 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:702, ming:find-title-attrib:11988, blk-insertpt:11101, ming:get-block-height:12025, ming:get-text-info:12041, ming:cluster-and-sort:12073, aa:cmd-end:715 |
| `FIVE` | 12297-12338 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `JZ` | 12358-12500 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1098, aa:jz-line-center-y:12346, aa:bbox-center-x:1122, aa:bbox-top-y:1136, aa:bbox-bottom-y:1140, aa:safe-move-entity:1144 |
| `FKX` | 12670-12741 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:702, fdx:poly-rect:12530, fdx:add-rect:12744, fkx:choose-frame:12565, fdx:rect-from-points:12508, fkx:collect:12602, fkx:title-rect:12632, fkx:point-in-p:12556, fkx:filter:12659, aa:cmd-end:715 |
| `FDX` | 12924-12962 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:12820, aa:undo-mark-off:741, fdx:frames:12782, fdx:sort-frames:12801, fdx:show-frame:12813, aa:undo-mark-on:733, fdx:place:12848 |
| `DX` | 13173-13242 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:741, aa:zz-filter-text-ss:13462, aa:zz-harvest-lines:13580, aa:zz-build-spatial-index:13605, aa:zz-text-info:13671, aa:zz-group-by-rect:13722, aa:undo-mark-on:733, dx:apply-group:13084 |
| `DX2` | 13386-13445 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:702, aa:zz-filter-text-ss:13462, aa:zz-harvest-lines:13580, aa:zz-build-spatial-index:13605, aa:zz-text-info:13671, aa:zz-group-by-rect:13722, dx2:sort-groups:13283, dx2:export-group:13371, zi:to-clip:15417, aa:cmd-end:715 |
| `ZZ` | 13868-13870 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:13816 |
| `ZZ2` | 13991-14087 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:13978, aa:safe-get-bbox:1098, aa:zz2-frame:13958, aa:zz-build-spatial-index:13605, aa:zz-text-info:13671, aa:zz-group-by-rect:13722, aa:zz2-plan:13873, aa:zz2-plan-ok:13882, aa:cmd-begin:702, aa:zz2-map-edge:13913, aa:bbox-top-y:1136, aa:bbox-bottom-y:1140 …共 16 个 |
| `JACC` | 14090-14092 | 3 | ZZ 的同功能入口。 | aa:zz-run:13816 |
| `MJ` | 14235-14322 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:14095, aa:mj-collect-text-data:14114, aa:mj-horizontal-ys:14142, aa:mj-scale-line-x:14215, aa:mj-move-cached-texts:14225 |
| `FIVE2` | 14386-14493 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1087, aa:tbhb-segment:14498, aa:tbhb-merge-segments:14516, aa:hg5-rows:14328, aa:tbhb-border-p:14508, aa:hg5-side-p:14355, aa:hg5-text-y:14377, aa:cmd-begin:702, aa:hg5-point:14373, aa:hg5-y:14340, aa:cmd-end:715 |
| `HBBG` | 14693-14781 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:741, aa:tbhb-collect:14645, aa:tbhb-boxes:14537, aa:tbhb-groups:14610, aa:tbhb-group-problem:14585, aa:merge-sort:790, aa:tbhb-before-p:14557, aa:tbhb-item-inside-p:14569, aa:undo-mark-on:733, aa:tbhb-offset:14621, aa:tbhb-shift-point:14627, aa:tbhb-seen-line-p:14631 …共 14 个 |
| `HZBG` | 14849-14913 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1098, aa:hzbg-plan:14798, aa:cmd-begin:702, aa:hzbg-move:14828, aa:hzbg-line:14841, aa:cmd-end:715 |
| `ZDWI` | 15103-15207 | 105 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:14964, aa:zdwi-vertices:15039, aa:zdwi-unique:15022, aa:zdwi-add-span:15027, aa:merge-sort:790, aa:safe-get-bbox:1098, aa:zdwi-column:15052, aa:zdwi-set-nth:15061, aa:cmd-begin:702, aa:zdwi-map-entity:15078, aa:zz-move-text:13690, aa:zz-center-texts:13797 …共 13 个 |
| `FF` | 15332-15373 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:702, aa:ysdl-get-raw-text:1302, aa:str-replace-all:1279, aa:ff-text-data:15313, aa:cmd-end:715 |
| `DB` | 15376-15380 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:702, db:del:15243, aa:cmd-end:715 |
| `DF` | 15382-15386 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:702, db:del:15243, aa:cmd-end:715 |
| `AB` | 15388-15392 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:702, db:add:15276, aa:cmd-end:715 |
| `AF` | 15394-15398 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:702, db:add:15276, aa:cmd-end:715 |
| `QE` | 15466-15547 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:15435, qe:zhi-prefix:15456 |
| `CC` | 15550-15624 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:702, aa:cmd-error:231, qe:get-clip-text:15435, aa:cmd-end:715 |
| `QW` | 15693-15729 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:702, aa:ysdl-get-plain-text:1387, zi:pt:15412, qw:join:15628, zi:to-clip:15417, aa:cmd-end:715 |
| `QW2` | 15735-15796 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:702, aa:ysdl-get-plain-text:1387, zi:pt:15412, aa:merge-sort:790, zi:to-clip:15417, aa:cmd-end:715 |
| `QW3` | 16020-16058 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:702, aa:qw3-record:15993, aa:merge-sort:790, zi:to-clip:15417, aa:cmd-end:715 |
| `DX1` | 16062-16132 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:702, zi:pt:15412, dx:color-kind:12989, aa:merge-sort:790, zi:to-clip:15417, aa:cmd-end:715 |
| `CE` | 16163-16193 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:702, ce-redraw:16147, aa:cmd-end:715 |
| `AW` | 16380-16422 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:16372, aw:process-one:16346 |
| `ZDML` | 16790-16868 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:702, tktj:safe-vla-object:16492, tktj:collect-one-block:16616, tktj:sort-by-page:16733, tktj:sort-by-position:16744, tktj:take:16688, tktj:draw-table:16705, tktj:drop:16697, aa:cmd-end:715 |
| `ZDML2` | 16932-17103 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:702, blk-insertpt:11101, hao2:block-name:11593, hao2:sort-blocks:11607, zdml2:collect-all-texts:11655, zdml2:build-spatial-index:11703, zdml2:extract-rect-text-fast:16874, zdml2:query-rect-index:11756, tktj:take:16688, tktj:draw-table:16705, tktj:drop:16697, aa:cmd-end:715 |
| `ZDMLDEBUG` | 17106-17140 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:702, tktj:get-attributes:16565, aa:cmd-end:715 |
| `DUMP` | 17144-17168 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `C1` | 17386-17388 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17318 |
| `C2` | 17390-17392 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17318 |
| `C3` | 17394-17396 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17318 |
| `DE` | 17581-17581 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:17536 |
| `DE2` | 17582-17582 | 1 | 用最右侧括号内容替换括号前连续数字（数字带相同尾缀时一并替换）。 | de:run:17536 |
| `GE` | 17669-17771 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:17593, ge:get-item:17607, ge:sort-items:17644, ge:make-line:17651 |
| `UT` | 17882-17994 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:741, ut:horizontal-line-p:17799, ut:get-bbox:17821, ut:line-y:17814, ut:sort-desc:17858, aa:undo-mark-on:733, aa:normalize-text-horizontal-align:3870, ut:bbox-bottom:17838, ut:bbox-left:17834, ut:move:17866 |
| `0` | 18005-18039 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `9` | 18088-18097 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:702, aa:rotate-90-run:18046, aa:cmd-end:715 |
| `99` | 18100-18109 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:702, aa:rotate-90-run:18046, aa:cmd-end:715 |
| `QZ` | 18116-18164 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 18192-18209 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:702, dl1:make-layer:18176, aa:cmd-end:715 |
| `REP` | 18233-18327 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:702, rep-trim:18223, aa:cmd-end:715 |
| `KMZ` | 18620-18622 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `KMY` | 18626-18628 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `LNZ` | 18632-18634 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `LNY` | 18638-18640 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `UPSZ` | 18644-18646 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `UPSY` | 18650-18652 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `BZ` | 18656-18658 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `BY` | 18662-18664 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `ZJ` | 18696-18698 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18671 |
| `YJ` | 18702-18704 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18671 |
| `YDZ` | 18906-18908 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18712 |
| `YDY` | 18912-18914 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18712 |
| `LBZ` | 18918-18920 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18712 |
| `LBY` | 18924-18926 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18712 |
| `485Z` | 18930-18932 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `485Y` | 18936-18938 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18412 |
| `XX` | 18949-18977 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `JM` | 19320-19395 | 76 | 按绿色电缆线所连原理号，把 ZDDL 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:702, aa:rep-begin:18989, xyg:dedup-hlines:8739, xy:ss->list:7717, xy:filter-green-hlines:8524, xy:collect-vlines:7932, xy:build-vline-buckets:7861, xy:build-text-meta-list:8150, xy:collect-texts:7948, xy:hline-info-ed:7785, jm:find-spec-text:19294, aa:ysdl-get-plain-text:1387 …共 24 个 |
| `BH2` | 20143-20301 | 159 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:702, aa:rep-begin:18989, aa:link-clock:9656, bh:prepare:19670, bh:record-path:19509, bh:now:19513, bh:read-records:19540, bh:rec-key:19448, bh:kmap:19459, bh:nmap:19472, bh:split-map:20128, bh:resolve-neighbors:19858 …共 31 个 |
| `BHG` | 20304-20404 | 101 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:702, aa:rep-begin:18989, aa:link-clock:9656, bh:prepare:19670, bh:record-path:19509, bh:now:19513, bh:read-records:19540, bh:rec-key:19448, bh:kmap:19459, bh:nmap:19472, bh:clean:19428, hddl:color:21529 …共 24 个 |
| `BH1` | 20684-20889 | 206 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:702, bh:pick-start:20586, bh:ask-prefix:19744, bh:ask-start:19754, bh:record-path:19509, bh:read-records:19540, bh:rec-key:19448, bh:kmap:19459, bh:nmap:19472, bh:own-records:20543, bh:write-records:19560, bh:clean:19428 …共 39 个 |
| `BH3` | 20942-21106 | 165 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:702, aa:rep-begin:18989, hddl:text:21526, hddl:point:21544, aa:merge-sort:790, hddl:sort-rows:21608, hddl:rows:21598, hddl:coord:21538, bh:record-path:19509, bh:now:19513, bh:read-records:19540, bh:rec-key:19448 …共 30 个 |
| `ZDAO` | 21226-21230 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:702, dao:run:21164, aa:cmd-end:715 |
| `HDAO` | 21233-21237 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:702, dao:run:21164, aa:cmd-end:715 |
| `QH` | 21242-21393 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:790 |
| `BK` | 21423-21466 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:17530, de:get-text:17514, bk:extract-inner:21404, de:set-text:17523 |
| `HDDL` | 21754-21844 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:741, aa:undo-mark-on:733, hddl:ensure-layer:21475, hddl:clear-markers:21515, hddl:text:21526, hddl:point:21544, hddl:sort-rows:21608, hddl:rows:21598, hddl:group-rows:21613, hddl:mirror-p:21748, hddl:cell:21658, hddl:tail-count:21664 …共 20 个 |
| `CU` | 21918-21919 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:21850 |
| `CD` | 21922-21923 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:21850 |
| `CZ` | 21926-21927 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:21850 |
| `CY` | 21930-21931 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:21850 |
| `HS` | 21984-22156 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:702, aa:hs-filter-unlocked:21938, aa:cmd-end:715, aa:hs-get-ss-bbox:21958 |
| `ZS` | 22165-22337 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:702, aa:hs-filter-unlocked:21938, aa:cmd-end:715, aa:hs-get-ss-bbox:21958 |
| `SC3` | 22369-22436 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:702, aa:sc3-layer-locked-p:22343, aa:sc3-entity-bbox:22351, aa:cmd-end:715 |
| `Z0` | 22503-22546 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:702, aa:z0-layer-locked-p:22442, aa:z0-data-flat-p:22460, aa:z0-polyline-flat-p:22493, aa:z0-one:22473, aa:z0-polyline-verts:22485, aa:cmd-end:715 |
| `VPO1` | 22552-22557 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `VPO2` | 22560-22565 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:702, aa:cmd-end:715 |
| `TONG` | 22571-22655 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:702, aa:cmd-end:715, aa:merge-sort:790, aa:gtx-natural-less:6404 |
| `ZDDL2` | 23275-23366 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:702, aa:cmd-end:715, zddl:parse-strip:22824, zddl:parse-wiring-ss:23027, zddl:ensure-layer:23087, zddl:plan-cables:23164, zddl:lookup-terminal:22756, zddl:label-layout:23189, zddl:draw-one-cable:23196, zddl:format-cable-no:23154 |
| `ZDC` | 23368-23370 | 3 | ZDDL 命令的简写别名。 | c:zddl:24733 |
| `ZDDLD` | 24424-24452 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:702, zddl2:xdata-app:24407, aa:layer-locked-p:4987, zddl2:set-layer-lock:24410, aa:cmd-end:715 |
| `BDL` | 24721-24727 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行。 | aa:cmd-begin:702, bdl:work:24590, aa:cmd-end:715 |
| `ZDDL` | 24733-24740 | 8 | 两次选择文字并指定插入点，按网页规则生成端子排与电缆。 | aa:cmd-begin:702, zddl2:work:24332, aa:cmd-end:715 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 292 | 231-328, 382-505, 702-814, 1065-1599, 3240-3301, 3495-3896 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 159 个 |
| `des:` | 5 | 537-565 | DES |
| `ystemp:` | 2 | 636-643 | YSTEMP |
| `ztf:` | 13 | 816-1048 | ZTF |
| `txt:` | 6 | 1854-2017 | T, T2 |
| `zhu:` | 5 | 2032-2073 | ZHU |
| `hwt:` | 14 | 2127-2340 | HWT |
| `txt2:` | 14 | 2400-2885 | T2 |
| `qr:` | 3 | 4820-4842 | QR, QR2 |
| `det:` | 1 | 5064-5082 | DET |
| `a2t:` | 3 | 5137-5162 | A2T |
| `(无前缀):` | 22 | 7319-7371, 7414-7441, 11077-11348, 16147-16160, 18223-18231 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 39 | 7704-8539 | BH1, BH2, BHG, JM, XY, XYG |
| `xyg:` | 15 | 8565-8956 | BH1, BH2, BHG, JM, XYG |
| `hb:` | 9 | 9829-10126 | HBDL |
| `aae:` | 4 | 11351-11470, 11559-11574 | AAE, HAO2, MING, ZDC, ZDDL, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 11586-11653, 11789-11820 | HAO2, ZDML2 |
| `zdml2:` | 4 | 11655-11786, 16874-16930 | HAO2, ZDML2 |
| `ming:` | 4 | 11988-12122 | MING |
| `fdx:` | 11 | 12508-12550, 12744-12922 | FDX, FKX |
| `fkx:` | 10 | 12556-12666 | FKX |
| `dx:` | 12 | 12965-13171 | DX, DX1, DX2, FDX, ZDC, ZDDL, ZDDL2 |
| `dx2:` | 12 | 13249-13384 | DX2, ZDC, ZDDL, ZDDL2 |
| `db:` | 5 | 15223-15310 | AB, AF, DB, DF |
| `zi:` | 2 | 15412-15432 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 15435-15463 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 15628-15689 | QW |
| `aw:` | 17 | 16208-16378 | AW |
| `tktj:` | 24 | 16452-16787 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 17186-17384 | C1, C2, C3 |
| `de:` | 11 | 17413-17579 | BK, DE, DE2 |
| `ge:` | 6 | 17593-17667 | GE |
| `ut:` | 10 | 17778-17880 | UT |
| `dl1:` | 1 | 18176-18190 | DL1 |
| `jm:` | 18 | 19108-19317 | BH1, BH2, BH3, BHG, JM |
| `bh:` | 86 | 19420-20140, 20409-20681, 20890-20939 | BH1, BH2, BH3, BHG |
| `dao:` | 4 | 21116-21223 | HDAO, ZDAO |
| `bk:` | 1 | 21404-21421 | BK |
| `hddl:` | 29 | 21475-21752 | BH1, BH2, BH3, BHG, HDDL |
| `cu:` | 1 | 21850-21915 | CD, CU, CY, CZ |
| `zddl:` | 25 | 22664-23273 | BDL, ZDC, ZDDL, ZDDL2 |
| `zddl2:` | 93 | 23378-24418 | BDL, ZDC, ZDDL, ZDDLD |
| `bdl:` | 13 | 24458-24715 | BDL |
