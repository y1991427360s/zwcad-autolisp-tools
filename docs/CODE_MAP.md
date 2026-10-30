# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，26647 行，1129 个函数，其中 175 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 334-383 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:706, aa:ys-line:257, aa:ys-ring:326, aa:ys-rim:315, aa:ys-snowflake:283, aa:ys-detail:308, aa:cmd-end:719 |
| `YS1` | 512-538 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:706, aa:ys-line:257, aa:ys1-t:412, aa:ys1-g:429, aa:ys1-o:449, aa:ys1-d:486, aa:cmd-end:719 |
| `DES` | 572-637 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:706, des:key-less-p:541, aa:merge-sort:794, des:record-less-p:546, des:x-less-p:550, des:overlap-p:556, aa:cmd-end:719 |
| `YSTEMP` | 650-704 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:706, aa:merge-sort:794, ystemp:y-less-p:640, ystemp:pair-p:644, aa:cmd-end:719 |
| `ZTF` | 1054-1067 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:706, ztf:collect-font-records:924, ztf:run-dialog:1024, aa:cmd-end:719 |
| `YSDL` | 1610-1811 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:745, aa:undo-mark-on:737, aa:ysdl-get-plain-text:1391, aa:ysdl-get-lwpoly-rect:1445, aa:ysdl-sort-boxes:1512, aa:ysdl-desktop-dir:1588, aa:merge-sort:794, aa:ysdl-parse-rows-from-text-data:1540, aa:ysdl-clean-text:1415, aa:ysdl-format-categorized-row:1580, aa:ysdl-build-csv-field:1406, aa:ysdl-reorder-row:1423 …共 13 个 |
| `Q` | 1823-1849 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `T` | 2064-2068 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:706, txt:run:2047, aa:cmd-end:719 |
| `ZHU` | 2120-2164 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:706, aa:ysdl-get-plain-text:1391, zhu:classify:2089, zhu:trim:2077, zhu:pick-name:2108, zhu:build-note:2099, aa:cmd-end:719 |
| `HWT` | 2387-2438 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:706, aa:ysdl-get-plain-text:1391, aa:merge-sort:794, hwt:counts-text:2310, hwt:row-counts:2172, hwt:draw:2335, hwt:layout:2216, hwt:cable-no:2182, hwt:draw-list:2364, hwt:cable-rows:2297, aa:cmd-end:719 |
| `T2` | 2595-2599 | 5 | 把文字及ATTDEF属性定义刷为宋体样式，高度3，宽度0.8；按可见范围保持对齐文字位置。 | aa:cmd-begin:706, txt2:run:2582, aa:cmd-end:719 |
| `ABCN` | 2615-2666 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:706, aa:safe-get-bbox:1102, aa:safe-move-entity:1148, aa:cmd-end:719 |
| `H` | 2668-2795 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:706, aa:normalize-text-horizontal-align:3563, aa:merge-sort:794, aa:cmd-end:719 |
| `H2` | 2802-2926 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:706, aa:normalize-text-horizontal-align:3563, aa:merge-sort:794, aa:cmd-end:719 |
| `Y` | 2952-2956 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `DZ` | 2996-3030 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:706, aa:ysdl-get-plain-text:1391, aa:dz-number-p:2962, aa:dz-color-text:2978, aa:cmd-end:719 |
| `YY` | 3036-3040 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `RR` | 3046-3050 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `WW` | 3056-3060 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `WWW` | 3066-3072 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:706, aa:deep-color-cmd:3391, aa:cmd-end:719 |
| `XU` | 3078-3152 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3158-3162 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `PP` | 3168-3172 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `HH` | 3178-3182 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:706, aa:color-cmd:2933, aa:cmd-end:719 |
| `HUI` | 3448-3453 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:706, aa:deep-color-cmd:3391, aa:cmd-end:719 |
| `ZHONG` | 3507-3511 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3456, aa:find-ref-by-top-bbox:1214, aa:bbox-center-x:1126, aa:normalize-visual-h:3650, aa:align-text-horizontal-by-bbox:1254 |
| `ZUO` | 3661-3665 | 5 | 将选中文字按视觉左侧统一对正（旋转文字按方向换算），并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3456, aa:find-ref-by-left-bbox:1174, aa:bbox-left-x:1132, aa:normalize-visual-h:3650, aa:align-text-horizontal-by-bbox:1254 |
| `AZUO` | 3671-3790 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:706, aa:cmd-end:719, aa:safe-get-bbox:1102, aa:bbox-left-x:1132, aa:safe-move-entity:1148 |
| `HP` | 3796-3933 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:706, aa:cmd-end:719, aa:safe-get-bbox:1102, aa:bbox-left-x:1132, aa:bbox-top-y:1140, aa:merge-sort:794, aa:bbox-right-x:1136, aa:safe-move-entity:1148 |
| `HP2` | 3939-4082 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:706, aa:cmd-end:719, aa:normalize-text-horizontal-align:3563, aa:safe-get-bbox:1102, aa:bbox-center-x:1126, aa:bbox-top-y:1140, aa:bbox-bottom-y:1144, aa:merge-sort:794, aa:safe-move-entity:1148 |
| `YOU` | 4085-4089 | 5 | 将选中文字按视觉右侧统一对正（旋转文字按方向换算），并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3456, aa:find-ref-by-right-bbox:1194, aa:bbox-right-x:1136, aa:normalize-visual-h:3650, aa:align-text-horizontal-by-bbox:1254 |
| `AYOU` | 4094-4213 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:706, aa:cmd-end:719, aa:safe-get-bbox:1102, aa:bbox-right-x:1136, aa:safe-move-entity:1148 |
| `SHANG` | 4216-4220 | 5 | 将选中文字按视觉上方统一对正（竖排文字定位点在顶端），并以最上方文字为基准上对齐。 | aa:align-text-cmd:3456, aa:find-ref-by-top-bbox:1214, aa:bbox-top-y:1140, aa:normalize-visual-v:3655, aa:align-text-vertical-by-bbox:1268 |
| `ASHANG` | 4226-4345 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:706, aa:cmd-end:719, aa:safe-get-bbox:1102, aa:bbox-top-y:1140, aa:safe-move-entity:1148 |
| `XIA` | 4348-4352 | 5 | 将选中文字按视觉下方统一对正（竖排文字定位点在底端），并以最下方文字为基准下对齐。 | aa:align-text-cmd:3456, aa:find-ref-by-bottom-bbox:1234, aa:bbox-bottom-y:1144, aa:normalize-visual-v:3655, aa:align-text-vertical-by-bbox:1268 |
| `AXIA` | 4357-4476 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:706, aa:cmd-end:719, aa:safe-get-bbox:1102, aa:bbox-bottom-y:1144, aa:safe-move-entity:1148 |
| `HE` | 4478-4571 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:706, aa:insert-sort:766, aa:cmd-end:719 |
| `QR` | 4606-4651 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:706, qr:last-height:4582, qr:height-str:4601, qr:save-height:4594, aa:cmd-end:719 |
| `QR2` | 4657-4687 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:706, qr:last-height:4582, qr:height-str:4601, qr:save-height:4594, aa:cmd-end:719 |
| `DEA` | 4693-4716 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `DEK` | 4723-4743 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `DEH` | 4786-4816 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:706, aa:has-chinese:4764, aa:ysdl-get-plain-text:1391, aa:layer-locked-p:4749, aa:cmd-end:719 |
| `DET` | 4846-4887 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:706, det:split-values:4826, aa:ysdl-get-raw-text:1306, aa:layer-locked-p:4749, aa:cmd-end:719 |
| `A2T` | 4926-4963 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:706, a2t:pick-string:4904, a2t:layer-locked-p:4899, a2t:text-dxf:4916, aa:cmd-end:719 |
| `WI` | 4969-5009 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `ATW` | 5016-5100 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:706, aa:safe-get-bbox:1102, aa:bbox-right-x:1136, aa:bbox-left-x:1132, aa:safe-move-entity:1148, aa:cmd-end:719 |
| `XB` | 5106-5159 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `YAN` | 5165-5281 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:766 |
| `LL` | 5292-5321 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5447, aa:undo-mark-off:745, aa:undo-mark-on:737 |
| `MM` | 5470-5502 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5447, aa:undo-mark-off:745, aa:undo-mark-on:737, aa:ortho-report:5436, aa:ortho-drag:5396 |
| `SS` | 5508-5540 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5447, aa:undo-mark-off:745, aa:undo-mark-on:737, aa:ortho-report:5436, aa:ortho-drag:5396 |
| `SW` | 5629-5684 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:706, aa:cmd-error:235, aa:ss-format-vec:5548, aa:ss-do-interactive-stretch:5594, aa:cmd-end:719 |
| `SYI` | 5794-5794 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5727 |
| `XYI` | 5795-5795 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5727 |
| `ZYI` | 5926-5926 | 1 | 预选对象中非水平对象向左移动 5X，水平直线向左拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:5838 |
| `YYI` | 5932-5932 | 1 | 预选对象中非水平对象向右移动 5X，水平直线向右拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:5838 |
| `SSS` | 6024-6095 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:5986, aa:sss-lowest-row-line:6012, aa:sss-find-pair:5959, aa:sss-horizontal-segments:5938, aa:cmd-begin:706, aa:cmd-end:719 |
| `SYAN` | 6138-6138 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6098 |
| `XYAN` | 6141-6141 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6098 |
| `SJ` | 6155-6181 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `XJ` | 6183-6209 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `SYJ` | 6252-6252 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6210 |
| `XYJ` | 6253-6253 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6210 |
| `GTX` | 6383-6563 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:745, aa:undo-mark-on:737, aa:gtx-select-prefix-text:6367, aa:ysdl-get-plain-text:1391, aa:try-get-bbox:1091, aa:merge-sort:794, aa:gtx-rows:6326, aa:gtx-key:6295, aa:gtx-find-last-char:6283, aa:gtx-natural-less:6303, aa:gtx-create-text-entity:6343 |
| `GTY` | 6806-6953 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6797, aa:gty-get-text-width:6634, aa:gty-separated-rows:6669, aa:gty-add-row:6703, aa:merge-sort:794, aa:gty-get-item-x:6602, aa:gty-order-rows:6753, aa:gty-column-widths:6765, aa:gty-row-tree:6715, aa:gty-build-sort-key:6610, aa:gty-tree-item:6726, aa:gty-copy-text:6777 …共 14 个 |
| `GTZ` | 6959-7116 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6634, aa:merge-sort:794, aa:gty-move-entity:6656 |
| `HWD` | 7143-7216 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:706, aa:safe-get-bbox:1102, aa:gty-get-text-width:6634, aa:merge-sort:794, aa:hwd-rows:7122, aa:hwd-make-text:7129, aa:cmd-end:719 |
| `BIAN` | 7272-7302 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:706, bian-draw-one:7244, aa:cmd-end:719 |
| `LAN` | 7342-7490 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:706, lan-vert-mode:7313, lan-get-option:7327, aa:cmd-end:719 |
| `XIN` | 7497-7587 | 91 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `XY` | 8740-8754 | 15 | 处理所选电缆线（水平线，或绿色竖直线），先运行 XIN 统计芯数，再运行 YUAN 提取原理号；水平线横向输出，竖直线在底端下方输出 270° 文字。 | aa:cmd-begin:706, xy:run-xin:7966, xy:run-yuan:8548, aa:cmd-end:719 |
| `XYG` | 9358-9568 | 211 | 一次框选，自动提取绿色水平/竖直电缆线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:706, aa:cmd-end:719, xy:filter-green-hlines:8714, xyg:dedup-hlines:8982, xy:ss->list:7632, xy:hline-info-ed:7728, xyg:find-prefix-text:8761, aa:ysdl-get-plain-text:1391, aa:gtx-select-prefix-text:6367, aa:link-xdata:9578, xy:run-xin:7966, xy:run-yuan:8548 …共 27 个 |
| `SX0` | 9834-9873 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:706, aa:link-dwg-id:9595, aa:link-info:9583, aa:link-root-p:9591, aa:cmd-end:719 |
| `YSSX0` | 9880-9920 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:706, aa:link-dwg-id:9595, aa:link-info:9583, aa:link-root-p:9591, aa:cmd-end:719 |
| `SX` | 9927-9960 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:706, aa:link-dwg-id:9595, aa:link-info:9583, aa:link-root-p:9591, aa:cmd-end:719 |
| `SXC` | 9980-10069 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:706, aa:rep-begin:19505, aa:link-dwg-id:9595, aa:link-info:9583, aa:rep-item:19516, aa:link-txt:9975, aa:link-root-p:9591, aa:link-root-ed:10076, aa:link-dwg-label:9967, aa:merge-sort:794, aa:rep-info:19522, aa:rep-counts:19571 …共 14 个 |
| `SX1` | 10095-10163 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:706, aa:link-clock:10071, aa:link-dwg-id:9595, aa:link-info:9583, aa:link-root-p:9591, aa:link-root-ed:10076, aa:link-text-for:9613, aa:link-file-path:9645, aa:link-export:9684, aa:cmd-end:719 |
| `SX2` | 10171-10236 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:706, aa:link-dwg-id:9595, aa:link-info:9583, aa:link-ask-folder:9816, aa:link-collect-files:9750, aa:merge-sort:794, aa:link-file-time:9741, aa:link-read-file:9729, aa:link-uid<:9635, aa:link-count-conflicts:9778, aa:link-join:9766, aa:link-text-from-rec:9625 …共 13 个 |
| `HBDL` | 10543-10648 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:706, aa:cmd-end:719, aa:ysdl-get-plain-text:1391, hb:cluster-rows:10313, hb:parse-row:10342, hb:apply-merge-in-place:10458 |
| `NU` | 10944-10995 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:10893, aa:num-int-target-p:10874 |
| `KAI` | 11186-11269 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:11125, aa:kai-process-text:11143 |
| `ZHENG` | 11340-11470 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:11278, aa:safe-get-bbox:1102, aa:zheng-align-text-to-rect-center:11327, aa:zheng-line-mid-x:11293, aa:zheng-add-texts-after-explode:11300, aa:zheng-align-text-center-x:11318 |
| `AAE` | 11887-11972 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:706, aae:split-lines:11841, aae:locate-dcl:11974, aae:resolve-val:11870, aa:cmd-end:719 |
| `HAO` | 11991-11995 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:706, fillframes-run:11695, aa:cmd-end:719 |
| `HAO2` | 12237-12394 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:706, blk-insertpt:11516, hao2:block-name:12008, hao2:sort-blocks:12022, zdml2:collect-all-texts:12070, hao2:format-num:12001, hao2:find-existing-text-fast:12204, tktj:current-space:16972, tktj:ensure-text-style:16982, aa:cmd-end:719 |
| `MING` | 12539-12703 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:706, ming:find-title-attrib:12403, blk-insertpt:11516, ming:get-block-height:12440, ming:get-text-info:12456, ming:cluster-and-sort:12488, aa:cmd-end:719 |
| `FIVE` | 12712-12753 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `JZ` | 12773-12915 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1102, aa:jz-line-center-y:12761, aa:bbox-center-x:1126, aa:bbox-top-y:1140, aa:bbox-bottom-y:1144, aa:safe-move-entity:1148 |
| `FKX` | 13085-13156 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:706, fdx:poly-rect:12945, fdx:add-rect:13159, fkx:choose-frame:12980, fdx:rect-from-points:12923, fkx:collect:13017, fkx:title-rect:13047, fkx:point-in-p:12971, fkx:filter:13074, aa:cmd-end:719 |
| `FDX` | 13339-13377 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:13235, aa:undo-mark-off:745, fdx:frames:13197, fdx:sort-frames:13216, fdx:show-frame:13228, aa:undo-mark-on:737, fdx:place:13263 |
| `DX` | 13588-13657 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:745, aa:zz-filter-text-ss:13877, aa:zz-harvest-lines:13995, aa:zz-build-spatial-index:14020, aa:zz-text-info:14086, aa:zz-group-by-rect:14137, aa:undo-mark-on:737, dx:apply-group:13499 |
| `DX2` | 13801-13860 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:706, aa:zz-filter-text-ss:13877, aa:zz-harvest-lines:13995, aa:zz-build-spatial-index:14020, aa:zz-text-info:14086, aa:zz-group-by-rect:14137, dx2:sort-groups:13698, dx2:export-group:13786, zi:to-clip:15925, aa:cmd-end:719 |
| `ZZ` | 14283-14285 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:14231 |
| `ZZ2` | 14406-14502 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:14393, aa:safe-get-bbox:1102, aa:zz2-frame:14373, aa:zz-build-spatial-index:14020, aa:zz-text-info:14086, aa:zz-group-by-rect:14137, aa:zz2-plan:14288, aa:zz2-plan-ok:14297, aa:cmd-begin:706, aa:zz2-map-edge:14328, aa:bbox-top-y:1140, aa:bbox-bottom-y:1144 …共 16 个 |
| `JACC` | 14505-14507 | 3 | ZZ 的同功能入口。 | aa:zz-run:14231 |
| `MJ` | 14650-14737 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:14510, aa:mj-collect-text-data:14529, aa:mj-horizontal-ys:14557, aa:mj-scale-line-x:14630, aa:mj-move-cached-texts:14640 |
| `FIVE2` | 14801-14908 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1091, aa:tbhb-segment:14913, aa:tbhb-merge-segments:14931, aa:hg5-rows:14743, aa:tbhb-border-p:14923, aa:hg5-side-p:14770, aa:hg5-text-y:14792, aa:cmd-begin:706, aa:hg5-point:14788, aa:hg5-y:14755, aa:cmd-end:719 |
| `HBBG` | 15108-15196 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:745, aa:tbhb-collect:15060, aa:tbhb-boxes:14952, aa:tbhb-groups:15025, aa:tbhb-group-problem:15000, aa:merge-sort:794, aa:tbhb-before-p:14972, aa:tbhb-item-inside-p:14984, aa:undo-mark-on:737, aa:tbhb-offset:15036, aa:tbhb-shift-point:15042, aa:tbhb-seen-line-p:15046 …共 14 个 |
| `HZBG` | 15264-15328 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1102, aa:hzbg-plan:15213, aa:cmd-begin:706, aa:hzbg-move:15243, aa:hzbg-line:15256, aa:cmd-end:719 |
| `ZDWI` | 15598-15715 | 118 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:15411, aa:zdwi-table-groups:15471, aa:zdwi-vertices:15534, aa:zdwi-unique:15517, aa:zdwi-add-span:15522, aa:merge-sort:794, aa:safe-get-bbox:1102, aa:zdwi-column:15547, aa:zdwi-set-nth:15556, aa:cmd-begin:706, aa:zdwi-map-entity:15573, aa:zz-move-text:14105 …共 14 个 |
| `FF` | 15840-15881 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:706, aa:ysdl-get-raw-text:1306, aa:str-replace-all:1283, aa:ff-text-data:15821, aa:cmd-end:719 |
| `DB` | 15884-15888 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:706, db:del:15751, aa:cmd-end:719 |
| `DF` | 15890-15894 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:706, db:del:15751, aa:cmd-end:719 |
| `AB` | 15896-15900 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:706, db:add:15784, aa:cmd-end:719 |
| `AF` | 15902-15906 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:706, db:add:15784, aa:cmd-end:719 |
| `QE` | 15974-16055 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:15943, qe:zhi-prefix:15964 |
| `CC` | 16058-16132 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:706, aa:cmd-error:235, qe:get-clip-text:15943, aa:cmd-end:719 |
| `QW` | 16201-16237 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:706, aa:ysdl-get-plain-text:1391, zi:pt:15920, qw:join:16136, zi:to-clip:15925, aa:cmd-end:719 |
| `QW2` | 16243-16304 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:706, aa:ysdl-get-plain-text:1391, zi:pt:15920, aa:merge-sort:794, zi:to-clip:15925, aa:cmd-end:719 |
| `QW3` | 16528-16566 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:706, aa:qw3-record:16501, aa:merge-sort:794, zi:to-clip:15925, aa:cmd-end:719 |
| `DX1` | 16570-16640 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:706, zi:pt:15920, dx:color-kind:13404, aa:merge-sort:794, zi:to-clip:15925, aa:cmd-end:719 |
| `CE` | 16671-16701 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:706, ce-redraw:16655, aa:cmd-end:719 |
| `AW` | 16888-16930 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:16880, aw:process-one:16854 |
| `ZDML` | 17298-17376 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:706, tktj:safe-vla-object:17000, tktj:collect-one-block:17124, tktj:sort-by-page:17241, tktj:sort-by-position:17252, tktj:take:17196, tktj:draw-table:17213, tktj:drop:17205, aa:cmd-end:719 |
| `ZDML2` | 17440-17611 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:706, blk-insertpt:11516, hao2:block-name:12008, hao2:sort-blocks:12022, zdml2:collect-all-texts:12070, zdml2:build-spatial-index:12118, zdml2:extract-rect-text-fast:17382, zdml2:query-rect-index:12171, tktj:take:17196, tktj:draw-table:17213, tktj:drop:17205, aa:cmd-end:719 |
| `ZDMLDEBUG` | 17614-17648 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:706, tktj:get-attributes:17073, aa:cmd-end:719 |
| `DUMP` | 17652-17676 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `C1` | 17894-17896 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17826 |
| `C2` | 17898-17900 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17826 |
| `C3` | 17902-17904 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17826 |
| `DE` | 18097-18097 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:18052 |
| `DE2` | 18098-18098 | 1 | 用最右侧括号内容替换括号前同样位数的数字（数字带相同尾缀时一并替换，A63(4)0I → A640I）。 | de:run:18052 |
| `GE` | 18185-18287 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:18109, ge:get-item:18123, ge:sort-items:18160, ge:make-line:18167 |
| `UT` | 18398-18510 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:745, ut:horizontal-line-p:18315, ut:get-bbox:18337, ut:line-y:18330, ut:sort-desc:18374, aa:undo-mark-on:737, aa:normalize-text-horizontal-align:3563, ut:bbox-bottom:18354, ut:bbox-left:18350, ut:move:18382 |
| `0` | 18521-18555 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `9` | 18604-18613 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:706, aa:rotate-90-run:18562, aa:cmd-end:719 |
| `99` | 18616-18625 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:706, aa:rotate-90-run:18562, aa:cmd-end:719 |
| `QZ` | 18632-18680 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 18708-18725 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:706, dl1:make-layer:18692, aa:cmd-end:719 |
| `REP` | 18749-18843 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:706, rep-trim:18739, aa:cmd-end:719 |
| `KMZ` | 19136-19138 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `KMY` | 19142-19144 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `LNZ` | 19148-19150 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `LNY` | 19154-19156 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `UPSZ` | 19160-19162 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `UPSY` | 19166-19168 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `BZ` | 19172-19174 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `BY` | 19178-19180 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `ZJ` | 19212-19214 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:19187 |
| `YJ` | 19218-19220 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:19187 |
| `YDZ` | 19422-19424 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:19228 |
| `YDY` | 19428-19430 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:19228 |
| `LBZ` | 19434-19436 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:19228 |
| `LBY` | 19440-19442 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:19228 |
| `485Z` | 19446-19448 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `485Y` | 19452-19454 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18928 |
| `XX` | 19465-19493 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `JM` | 19872-19947 | 76 | 按绿色电缆线（水平或竖直）所连原理号，把 ZDDLH/ZDDLS 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:706, aa:rep-begin:19505, xyg:dedup-hlines:8982, xy:ss->list:7632, xy:filter-green-hlines:8714, xy:collect-vlines:7913, xy:build-vline-buckets:7841, xy:build-text-meta-list:8170, xy:collect-texts:7938, xy:hline-info-ed:7728, jm:find-spec-text:19834, aa:ysdl-get-plain-text:1391 …共 24 个 |
| `BH2` | 20957-21132 | 176 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:706, aa:rep-begin:19505, aa:link-clock:10071, bh:prepare:20351, bh:record-path:20063, bh:now:20067, bh:fold-joins:20303, bh:read-records:20094, bh:rec-key:20002, bh:kmap:20013, bh:nmap:20026, bh:split-map:20942 …共 34 个 |
| `BHG` | 21135-21250 | 116 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:706, aa:rep-begin:19505, aa:link-clock:10071, bh:prepare:20351, bh:record-path:20063, bh:now:20067, bh:fold-joins:20303, bh:read-records:20094, bh:rec-key:20002, bh:kmap:20013, bh:nmap:20026, bh:clean:19982 …共 26 个 |
| `BH1` | 21563-21774 | 212 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:706, bh:pick-start:21458, bh:ask-prefix:20431, bh:ask-start:20441, bh:record-path:20063, bh:fold-joins:20303, bh:read-records:20094, bh:rec-key:20002, bh:kmap:20013, bh:nmap:20026, bh:own-records:21415, bh:write-records:20114 …共 42 个 |
| `BH3` | 21853-22029 | 177 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:706, aa:rep-begin:19505, hddl:text:22449, hddl:point:22467, aa:merge-sort:794, hddl:sort-rows:22531, hddl:rows:22521, hddl:coord:22461, bh:record-path:20063, bh:now:20067, bh:fold-joins:20303, bh:read-records:20094 …共 32 个 |
| `ZDAO` | 22149-22153 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:706, dao:run:22087, aa:cmd-end:719 |
| `HDAO` | 22156-22160 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:706, dao:run:22087, aa:cmd-end:719 |
| `QH` | 22165-22316 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:794 |
| `BK` | 22346-22389 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:18046, de:get-text:18030, bk:extract-inner:22327, de:set-text:18039 |
| `HDDL` | 22677-22767 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:745, aa:undo-mark-on:737, hddl:ensure-layer:22398, hddl:clear-markers:22438, hddl:text:22449, hddl:point:22467, hddl:sort-rows:22531, hddl:rows:22521, hddl:group-rows:22536, hddl:mirror-p:22671, hddl:cell:22581, hddl:tail-count:22587 …共 20 个 |
| `CU` | 22841-22842 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:22773 |
| `CD` | 22845-22846 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:22773 |
| `CZ` | 22849-22850 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:22773 |
| `CY` | 22853-22854 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:22773 |
| `HS` | 22907-23079 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:706, aa:hs-filter-unlocked:22861, aa:cmd-end:719, aa:hs-get-ss-bbox:22881 |
| `ZS` | 23088-23260 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:706, aa:hs-filter-unlocked:22861, aa:cmd-end:719, aa:hs-get-ss-bbox:22881 |
| `SC3` | 23292-23359 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:706, aa:sc3-layer-locked-p:23266, aa:sc3-entity-bbox:23274, aa:cmd-end:719 |
| `Z0` | 23426-23469 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:706, aa:z0-layer-locked-p:23365, aa:z0-data-flat-p:23383, aa:z0-polyline-flat-p:23416, aa:z0-one:23396, aa:z0-polyline-verts:23408, aa:cmd-end:719 |
| `VPO1` | 23475-23480 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `VPO2` | 23483-23488 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:706, aa:cmd-end:719 |
| `TONG` | 23494-23578 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:706, aa:cmd-end:719, aa:merge-sort:794, aa:gtx-natural-less:6303 |
| `ZDDL2` | 24239-24330 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:706, aa:cmd-end:719, zddl:parse-strip:23770, zddl:parse-wiring-ss:23991, zddl:ensure-layer:24051, zddl:plan-cables:24128, zddl:lookup-terminal:23679, zddl:label-layout:24153, zddl:draw-one-cable:24160, zddl:format-cable-no:24118 |
| `ZDC` | 24332-24334 | 3 | ZDDLH 命令的简写别名。 | c:zddlh:26626 |
| `ZDDLD` | 25424-25452 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:706, zddl2:xdata-app:25407, aa:layer-locked-p:4749, zddl2:set-layer-lock:25410, aa:cmd-end:719 |
| `XZYL` | 26602-26608 | 7 | 修正原理号：先点原理号正确的电缆录入，再运行点对面一端的同一根电缆，替换不一致的原理号并补填未编号；合画图录入按 1#/2# 拆开；可先选电缆线再运行。 | aa:cmd-begin:706, zyl:work:26570, aa:cmd-end:719 |
| `BDL` | 26614-26620 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行；选水平原理号时按竖排端子排补画竖直电缆线。 | aa:cmd-begin:706, bdl:work:26048, aa:cmd-end:719 |
| `ZDDLH` | 26626-26633 | 8 | 两次选择文字并指定左下基点，生成横排端子排与水平绿色电缆线（原 ZDDL）。 | aa:cmd-begin:706, zddl2:work:25321, aa:cmd-end:719 |
| `ZDDLS` | 26639-26646 | 8 | 两次选择文字并指定左上基点，生成竖排端子排、水平引线与竖直绿色电缆线（向下箭头、文字 270°）。 | aa:cmd-begin:706, zddl2:work:25321, aa:cmd-end:719 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 303 | 235-332, 386-509, 706-818, 1069-1603, 2933-2994, 3188-3658 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 163 个 |
| `des:` | 5 | 541-569 | DES |
| `ystemp:` | 2 | 640-647 | YSTEMP |
| `ztf:` | 13 | 820-1052 | ZTF |
| `txt:` | 7 | 1858-2060 | T, T2 |
| `zhu:` | 5 | 2077-2118 | ZHU |
| `hwt:` | 14 | 2172-2385 | HWT |
| `txt2:` | 5 | 2446-2593 | T2 |
| `qr:` | 3 | 4582-4604 | QR, QR2 |
| `det:` | 1 | 4826-4844 | DET |
| `a2t:` | 3 | 4899-4924 | A2T |
| `(无前缀):` | 22 | 7218-7270, 7313-7340, 11492-11763, 16655-16668, 18739-18747 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 47 | 7619-8735 | BH1, BH2, BHG, JM, XY, XYG, XZYL |
| `xyg:` | 18 | 8761-9356 | BH1, BH2, BHG, JM, XYG |
| `hb:` | 9 | 10244-10541 | HBDL |
| `aae:` | 4 | 11766-11885, 11974-11989 | AAE, HAO2, MING, ZDC, ZDDLH, ZDDLS, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 12001-12068, 12204-12235 | HAO2, ZDML2 |
| `zdml2:` | 4 | 12070-12201, 17382-17438 | HAO2, ZDML2 |
| `ming:` | 4 | 12403-12537 | MING |
| `fdx:` | 11 | 12923-12965, 13159-13337 | FDX, FKX |
| `fkx:` | 10 | 12971-13081 | FKX |
| `dx:` | 12 | 13380-13586 | DX, DX1, DX2, FDX, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `dx2:` | 12 | 13664-13799 | DX2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `db:` | 5 | 15731-15818 | AB, AF, DB, DF |
| `zi:` | 2 | 15920-15940 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 15943-15971 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 16136-16197 | QW |
| `aw:` | 17 | 16716-16886 | AW, XZYL |
| `tktj:` | 24 | 16960-17295 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 17694-17892 | C1, C2, C3 |
| `de:` | 11 | 17921-18095 | BK, DE, DE2 |
| `ge:` | 6 | 18109-18183 | GE |
| `ut:` | 10 | 18294-18396 | UT |
| `dl1:` | 1 | 18692-18706 | DL1 |
| `jm:` | 20 | 19624-19869 | BH1, BH2, BH3, BHG, JM, XZYL |
| `bh:` | 101 | 19974-20954, 21255-21560, 21775-21850 | BDL, BH1, BH2, BH3, BHG, JM, XZYL |
| `dao:` | 4 | 22039-22146 | HDAO, ZDAO |
| `bk:` | 1 | 22327-22344 | BK |
| `hddl:` | 29 | 22398-22675 | BH1, BH2, BH3, BHG, HDDL, XZYL |
| `cu:` | 1 | 22773-22838 | CD, CU, CY, CZ |
| `zddl:` | 27 | 23587-24237 | BDL, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `zddl2:` | 96 | 24342-25418 | BDL, ZDC, ZDDLD, ZDDLH, ZDDLS |
| `bdl:` | 34 | 25459-26208 | BDL, XZYL |
| `zyl:` | 31 | 26217-26596 | XZYL |
