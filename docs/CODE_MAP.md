# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，27338 行，1168 个函数，其中 178 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 337-386 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:709, aa:ys-line:260, aa:ys-ring:329, aa:ys-rim:318, aa:ys-snowflake:286, aa:ys-detail:311, aa:cmd-end:722 |
| `YS1` | 515-541 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:709, aa:ys-line:260, aa:ys1-t:415, aa:ys1-g:432, aa:ys1-o:452, aa:ys1-d:489, aa:cmd-end:722 |
| `DES` | 575-640 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:709, des:key-less-p:544, aa:merge-sort:797, des:record-less-p:549, des:x-less-p:553, des:overlap-p:559, aa:cmd-end:722 |
| `YSTEMP` | 653-707 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:709, aa:merge-sort:797, ystemp:y-less-p:643, ystemp:pair-p:647, aa:cmd-end:722 |
| `ZTF` | 1057-1070 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:709, ztf:collect-font-records:927, ztf:run-dialog:1027, aa:cmd-end:722 |
| `YSDL` | 1613-1814 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:748, aa:undo-mark-on:740, aa:ysdl-get-plain-text:1394, aa:ysdl-get-lwpoly-rect:1448, aa:ysdl-sort-boxes:1515, aa:ysdl-desktop-dir:1591, aa:merge-sort:797, aa:ysdl-parse-rows-from-text-data:1543, aa:ysdl-clean-text:1418, aa:ysdl-format-categorized-row:1583, aa:ysdl-build-csv-field:1409, aa:ysdl-reorder-row:1426 …共 13 个 |
| `Q` | 1826-1852 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `T` | 2067-2071 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:709, txt:run:2050, aa:cmd-end:722 |
| `ZHU` | 2123-2167 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:709, aa:ysdl-get-plain-text:1394, zhu:classify:2092, zhu:trim:2080, zhu:pick-name:2111, zhu:build-note:2102, aa:cmd-end:722 |
| `HWT` | 2390-2441 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:709, aa:ysdl-get-plain-text:1394, aa:merge-sort:797, hwt:counts-text:2313, hwt:row-counts:2175, hwt:draw:2338, hwt:layout:2219, hwt:cable-no:2185, hwt:draw-list:2367, hwt:cable-rows:2300, aa:cmd-end:722 |
| `T2` | 2598-2602 | 5 | 把文字及ATTDEF属性定义刷为宋体样式，高度3，宽度0.8；按可见范围保持对齐文字位置。 | aa:cmd-begin:709, txt2:run:2585, aa:cmd-end:722 |
| `ABCN` | 2618-2669 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:709, aa:safe-get-bbox:1105, aa:safe-move-entity:1151, aa:cmd-end:722 |
| `H` | 2671-2798 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:709, aa:normalize-text-horizontal-align:3566, aa:merge-sort:797, aa:cmd-end:722 |
| `H2` | 2805-2929 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:709, aa:normalize-text-horizontal-align:3566, aa:merge-sort:797, aa:cmd-end:722 |
| `Y` | 2955-2959 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `DZ` | 2999-3033 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:709, aa:ysdl-get-plain-text:1394, aa:dz-number-p:2965, aa:dz-color-text:2981, aa:cmd-end:722 |
| `YY` | 3039-3043 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `RR` | 3049-3053 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `WW` | 3059-3063 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `WWW` | 3069-3075 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:709, aa:deep-color-cmd:3394, aa:cmd-end:722 |
| `XU` | 3081-3155 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3161-3165 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `PP` | 3171-3175 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `HH` | 3181-3185 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:709, aa:color-cmd:2936, aa:cmd-end:722 |
| `HUI` | 3451-3456 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:709, aa:deep-color-cmd:3394, aa:cmd-end:722 |
| `ZHONG` | 3510-3514 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3459, aa:find-ref-by-top-bbox:1217, aa:bbox-center-x:1129, aa:normalize-visual-h:3653, aa:align-text-horizontal-by-bbox:1257 |
| `ZUO` | 3664-3668 | 5 | 将选中文字按视觉左侧统一对正（旋转文字按方向换算），并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3459, aa:find-ref-by-left-bbox:1177, aa:bbox-left-x:1135, aa:normalize-visual-h:3653, aa:align-text-horizontal-by-bbox:1257 |
| `AZUO` | 3674-3793 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:709, aa:cmd-end:722, aa:safe-get-bbox:1105, aa:bbox-left-x:1135, aa:safe-move-entity:1151 |
| `HP` | 3799-3936 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:709, aa:cmd-end:722, aa:safe-get-bbox:1105, aa:bbox-left-x:1135, aa:bbox-top-y:1143, aa:merge-sort:797, aa:bbox-right-x:1139, aa:safe-move-entity:1151 |
| `HP2` | 3942-4085 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:709, aa:cmd-end:722, aa:normalize-text-horizontal-align:3566, aa:safe-get-bbox:1105, aa:bbox-center-x:1129, aa:bbox-top-y:1143, aa:bbox-bottom-y:1147, aa:merge-sort:797, aa:safe-move-entity:1151 |
| `YOU` | 4088-4092 | 5 | 将选中文字按视觉右侧统一对正（旋转文字按方向换算），并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3459, aa:find-ref-by-right-bbox:1197, aa:bbox-right-x:1139, aa:normalize-visual-h:3653, aa:align-text-horizontal-by-bbox:1257 |
| `AYOU` | 4097-4216 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:709, aa:cmd-end:722, aa:safe-get-bbox:1105, aa:bbox-right-x:1139, aa:safe-move-entity:1151 |
| `SHANG` | 4219-4223 | 5 | 将选中文字按视觉上方统一对正（竖排文字定位点在顶端），并以最上方文字为基准上对齐。 | aa:align-text-cmd:3459, aa:find-ref-by-top-bbox:1217, aa:bbox-top-y:1143, aa:normalize-visual-v:3658, aa:align-text-vertical-by-bbox:1271 |
| `ASHANG` | 4229-4348 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:709, aa:cmd-end:722, aa:safe-get-bbox:1105, aa:bbox-top-y:1143, aa:safe-move-entity:1151 |
| `XIA` | 4351-4355 | 5 | 将选中文字按视觉下方统一对正（竖排文字定位点在底端），并以最下方文字为基准下对齐。 | aa:align-text-cmd:3459, aa:find-ref-by-bottom-bbox:1237, aa:bbox-bottom-y:1147, aa:normalize-visual-v:3658, aa:align-text-vertical-by-bbox:1271 |
| `AXIA` | 4360-4479 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:709, aa:cmd-end:722, aa:safe-get-bbox:1105, aa:bbox-bottom-y:1147, aa:safe-move-entity:1151 |
| `HE` | 4481-4574 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:709, aa:insert-sort:769, aa:cmd-end:722 |
| `QR` | 4609-4654 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:709, qr:last-height:4585, qr:height-str:4604, qr:save-height:4597, aa:cmd-end:722 |
| `QR2` | 4660-4690 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:709, qr:last-height:4585, qr:height-str:4604, qr:save-height:4597, aa:cmd-end:722 |
| `DEA` | 4696-4719 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `DEK` | 4726-4746 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `DEH` | 4789-4819 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:709, aa:has-chinese:4767, aa:ysdl-get-plain-text:1394, aa:layer-locked-p:4752, aa:cmd-end:722 |
| `DET` | 4849-4890 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:709, det:split-values:4829, aa:ysdl-get-raw-text:1309, aa:layer-locked-p:4752, aa:cmd-end:722 |
| `A2T` | 4929-4966 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:709, a2t:pick-string:4907, a2t:layer-locked-p:4902, a2t:text-dxf:4919, aa:cmd-end:722 |
| `WI` | 4972-5012 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `ATW` | 5019-5103 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:709, aa:safe-get-bbox:1105, aa:bbox-right-x:1139, aa:bbox-left-x:1135, aa:safe-move-entity:1151, aa:cmd-end:722 |
| `XB` | 5109-5162 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `YAN` | 5168-5284 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:769 |
| `LL` | 5295-5324 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5450, aa:undo-mark-off:748, aa:undo-mark-on:740 |
| `MM` | 5473-5505 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5450, aa:undo-mark-off:748, aa:undo-mark-on:740, aa:ortho-report:5439, aa:ortho-drag:5399 |
| `SS` | 5511-5543 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5450, aa:undo-mark-off:748, aa:undo-mark-on:740, aa:ortho-report:5439, aa:ortho-drag:5399 |
| `SW` | 5632-5687 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:709, aa:cmd-error:238, aa:ss-format-vec:5551, aa:ss-do-interactive-stretch:5597, aa:cmd-end:722 |
| `SYI` | 5797-5797 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5730 |
| `XYI` | 5798-5798 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5730 |
| `ZYI` | 5929-5929 | 1 | 预选对象中非水平对象向左移动 5X，水平直线向左拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:5841 |
| `YYI` | 5935-5935 | 1 | 预选对象中非水平对象向右移动 5X，水平直线向右拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:5841 |
| `SSS` | 6027-6098 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:5989, aa:sss-lowest-row-line:6015, aa:sss-find-pair:5962, aa:sss-horizontal-segments:5941, aa:cmd-begin:709, aa:cmd-end:722 |
| `SYAN` | 6141-6141 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6101 |
| `XYAN` | 6144-6144 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6101 |
| `SJ` | 6158-6184 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `XJ` | 6186-6212 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `SYJ` | 6255-6255 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6213 |
| `XYJ` | 6256-6256 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6213 |
| `GTX` | 6386-6566 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:748, aa:undo-mark-on:740, aa:gtx-select-prefix-text:6370, aa:ysdl-get-plain-text:1394, aa:try-get-bbox:1094, aa:merge-sort:797, aa:gtx-rows:6329, aa:gtx-key:6298, aa:gtx-find-last-char:6286, aa:gtx-natural-less:6306, aa:gtx-create-text-entity:6346 |
| `GTY` | 6809-6956 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6800, aa:gty-get-text-width:6637, aa:gty-separated-rows:6672, aa:gty-add-row:6706, aa:merge-sort:797, aa:gty-get-item-x:6605, aa:gty-order-rows:6756, aa:gty-column-widths:6768, aa:gty-row-tree:6718, aa:gty-build-sort-key:6613, aa:gty-tree-item:6729, aa:gty-copy-text:6780 …共 14 个 |
| `GTZ` | 6962-7119 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6637, aa:merge-sort:797, aa:gty-move-entity:6659 |
| `HWD` | 7146-7219 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:709, aa:safe-get-bbox:1105, aa:gty-get-text-width:6637, aa:merge-sort:797, aa:hwd-rows:7125, aa:hwd-make-text:7132, aa:cmd-end:722 |
| `BIAN` | 7275-7305 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:709, bian-draw-one:7247, aa:cmd-end:722 |
| `LAN` | 7345-7493 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:709, lan-vert-mode:7316, lan-get-option:7330, aa:cmd-end:722 |
| `XIN` | 7500-7590 | 91 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `XY` | 8746-8760 | 15 | 处理所选电缆线（水平线，或绿色竖直线），先运行 XIN 统计芯数，再运行 YUAN 提取原理号；水平线横向输出，竖直线在底端下方输出 270° 文字。 | aa:cmd-begin:709, xy:run-xin:7970, xy:run-yuan:8553, aa:cmd-end:722 |
| `XYG` | 9716-9716 | 1 | 一次框选，自动提取绿色水平/竖直电缆线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | xyg:run:9490 |
| `XYG2` | 9719-9719 | 1 | 与 XYG 相同的框选和汇总表，但原图不留痕：电缆后面不留芯数和原理号，异常电缆线也不改色、不延长。 | xyg:run:9490 |
| `SX0` | 9998-10037 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:709, aa:link-dwg-id:9746, aa:link-info:9734, aa:link-root-p:9742, aa:cmd-end:722 |
| `YSSX0` | 10044-10084 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:709, aa:link-dwg-id:9746, aa:link-info:9734, aa:link-root-p:9742, aa:cmd-end:722 |
| `SX` | 10109-10147 | 39 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:709, aa:link-dwg-id:9746, aa:link-info:9734, aa:link-root-p:9742, aa:link-export-roots:10091, aa:cmd-end:722 |
| `SXC` | 10167-10256 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:709, aa:rep-begin:20196, aa:link-dwg-id:9746, aa:link-info:9734, aa:rep-item:20207, aa:link-txt:10162, aa:link-root-p:9742, aa:link-root-ed:10487, aa:link-dwg-label:10154, aa:merge-sort:797, aa:rep-info:20213, aa:rep-counts:20262 …共 14 个 |
| `SXD` | 10438-10480 | 43 | 跳到原件：点选文字，缩放到它的原件；原件在其他图纸时按图名找到该图，打开或切换过去；只读。 | aa:link-pick-text:10422, aa:link-info:9734, aa:link-dwg-id:9746, aa:link-root-ed:10487, aa:link-write-jump:10308, aa:link-default-dir:9967, aa:link-locate-dwg:10413, aa:link-dwg-label:10154, aa:link-ask-folder:9982, aa:link-remember-dir:9977, aa:link-send-later:10338 |
| `SX1` | 10506-10574 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:709, aa:link-clock:10482, aa:link-dwg-id:9746, aa:link-info:9734, aa:link-root-p:9742, aa:link-root-ed:10487, aa:link-text-for:9764, aa:link-file-path:9796, aa:link-export:9835, aa:cmd-end:722 |
| `SX2` | 10582-10647 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:709, aa:link-dwg-id:9746, aa:link-info:9734, aa:link-ask-folder:9982, aa:link-collect-files:9901, aa:link-remember-dir:9977, aa:merge-sort:797, aa:link-file-time:9892, aa:link-read-file:9880, aa:link-uid<:9786, aa:link-count-conflicts:9929, aa:link-join:9917 …共 14 个 |
| `HBDL` | 10954-11059 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:709, aa:cmd-end:722, aa:ysdl-get-plain-text:1394, hb:cluster-rows:10724, hb:parse-row:10753, hb:apply-merge-in-place:10869 |
| `NU` | 11355-11406 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:11304, aa:num-int-target-p:11285 |
| `KAI` | 11597-11680 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:11536, aa:kai-process-text:11554 |
| `ZHENG` | 11751-11881 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:11689, aa:safe-get-bbox:1105, aa:zheng-align-text-to-rect-center:11738, aa:zheng-line-mid-x:11704, aa:zheng-add-texts-after-explode:11711, aa:zheng-align-text-center-x:11729 |
| `AAE` | 12298-12383 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:709, aae:split-lines:12252, aae:locate-dcl:12385, aae:resolve-val:12281, aa:cmd-end:722 |
| `HAO` | 12402-12406 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:709, fillframes-run:12106, aa:cmd-end:722 |
| `HAO2` | 12648-12805 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:709, blk-insertpt:11927, hao2:block-name:12419, hao2:sort-blocks:12433, zdml2:collect-all-texts:12481, hao2:format-num:12412, hao2:find-existing-text-fast:12615, tktj:current-space:17523, tktj:ensure-text-style:17533, aa:cmd-end:722 |
| `MING` | 12950-13114 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:709, ming:find-title-attrib:12814, blk-insertpt:11927, ming:get-block-height:12851, ming:get-text-info:12867, ming:cluster-and-sort:12899, aa:cmd-end:722 |
| `FIVE` | 13123-13164 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `JZ` | 13184-13326 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1105, aa:jz-line-center-y:13172, aa:bbox-center-x:1129, aa:bbox-top-y:1143, aa:bbox-bottom-y:1147, aa:safe-move-entity:1151 |
| `FKX` | 13496-13567 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:709, fdx:poly-rect:13356, fdx:add-rect:13570, fkx:choose-frame:13391, fdx:rect-from-points:13334, fkx:collect:13428, fkx:title-rect:13458, fkx:point-in-p:13382, fkx:filter:13485, aa:cmd-end:722 |
| `FDX` | 13750-13788 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:13646, aa:undo-mark-off:748, fdx:frames:13608, fdx:sort-frames:13627, fdx:show-frame:13639, aa:undo-mark-on:740, fdx:place:13674 |
| `DX` | 13999-14068 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:748, aa:zz-filter-text-ss:14288, aa:zz-harvest-lines:14406, aa:zz-build-spatial-index:14431, aa:zz-text-info:14497, aa:zz-group-by-rect:14548, aa:undo-mark-on:740, dx:apply-group:13910 |
| `DX2` | 14212-14271 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:709, aa:zz-filter-text-ss:14288, aa:zz-harvest-lines:14406, aa:zz-build-spatial-index:14431, aa:zz-text-info:14497, aa:zz-group-by-rect:14548, dx2:sort-groups:14109, dx2:export-group:14197, zi:to-clip:16336, aa:cmd-end:722 |
| `ZZ` | 14694-14696 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:14642 |
| `ZZ2` | 14817-14913 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:14804, aa:safe-get-bbox:1105, aa:zz2-frame:14784, aa:zz-build-spatial-index:14431, aa:zz-text-info:14497, aa:zz-group-by-rect:14548, aa:zz2-plan:14699, aa:zz2-plan-ok:14708, aa:cmd-begin:709, aa:zz2-map-edge:14739, aa:bbox-top-y:1143, aa:bbox-bottom-y:1147 …共 16 个 |
| `JACC` | 14916-14918 | 3 | ZZ 的同功能入口。 | aa:zz-run:14642 |
| `MJ` | 15061-15148 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:14921, aa:mj-collect-text-data:14940, aa:mj-horizontal-ys:14968, aa:mj-scale-line-x:15041, aa:mj-move-cached-texts:15051 |
| `FIVE2` | 15212-15319 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1094, aa:tbhb-segment:15324, aa:tbhb-merge-segments:15342, aa:hg5-rows:15154, aa:tbhb-border-p:15334, aa:hg5-side-p:15181, aa:hg5-text-y:15203, aa:cmd-begin:709, aa:hg5-point:15199, aa:hg5-y:15166, aa:cmd-end:722 |
| `HBBG` | 15519-15607 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:748, aa:tbhb-collect:15471, aa:tbhb-boxes:15363, aa:tbhb-groups:15436, aa:tbhb-group-problem:15411, aa:merge-sort:797, aa:tbhb-before-p:15383, aa:tbhb-item-inside-p:15395, aa:undo-mark-on:740, aa:tbhb-offset:15447, aa:tbhb-shift-point:15453, aa:tbhb-seen-line-p:15457 …共 14 个 |
| `HZBG` | 15675-15739 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1105, aa:hzbg-plan:15624, aa:cmd-begin:709, aa:hzbg-move:15654, aa:hzbg-line:15667, aa:cmd-end:722 |
| `ZDWI` | 16009-16126 | 118 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:15822, aa:zdwi-table-groups:15882, aa:zdwi-vertices:15945, aa:zdwi-unique:15928, aa:zdwi-add-span:15933, aa:merge-sort:797, aa:safe-get-bbox:1105, aa:zdwi-column:15958, aa:zdwi-set-nth:15967, aa:cmd-begin:709, aa:zdwi-map-entity:15984, aa:zz-move-text:14516 …共 14 个 |
| `FF` | 16251-16292 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:709, aa:ysdl-get-raw-text:1309, aa:str-replace-all:1286, aa:ff-text-data:16232, aa:cmd-end:722 |
| `DB` | 16295-16299 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:709, db:del:16162, aa:cmd-end:722 |
| `DF` | 16301-16305 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:709, db:del:16162, aa:cmd-end:722 |
| `AB` | 16307-16311 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:709, db:add:16195, aa:cmd-end:722 |
| `AF` | 16313-16317 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:709, db:add:16195, aa:cmd-end:722 |
| `QE` | 16385-16466 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:16354, qe:zhi-prefix:16375 |
| `CC` | 16469-16543 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:709, aa:cmd-error:238, qe:get-clip-text:16354, aa:cmd-end:722 |
| `QW` | 16612-16648 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:709, aa:ysdl-get-plain-text:1394, zi:pt:16331, qw:join:16547, zi:to-clip:16336, aa:cmd-end:722 |
| `QW2` | 16654-16715 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:709, aa:ysdl-get-plain-text:1394, zi:pt:16331, aa:merge-sort:797, zi:to-clip:16336, aa:cmd-end:722 |
| `QW3` | 16939-16977 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:709, aa:qw3-record:16912, aa:merge-sort:797, zi:to-clip:16336, aa:cmd-end:722 |
| `TJK` | 17066-17116 | 51 | 点选块，统计当前空间或框选范围内同名块（含动态块）的数量，选中它们并用红圈和序号标出；Q 清除标记。 | aa:cmd-begin:709, tjk:clear-marks:16982, aa:cmd-end:722, hao2:block-name:12419, tjk:select:17012, tjk:items:17024, tjk:ensure-layer:16992, tjk:draw:17041 |
| `DX1` | 17121-17191 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:709, zi:pt:16331, dx:color-kind:13815, aa:merge-sort:797, zi:to-clip:16336, aa:cmd-end:722 |
| `CE` | 17222-17252 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:709, ce-redraw:17206, aa:cmd-end:722 |
| `AW` | 17439-17481 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:17431, aw:process-one:17405 |
| `ZDML` | 17849-17927 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:709, tktj:safe-vla-object:17551, tktj:collect-one-block:17675, tktj:sort-by-page:17792, tktj:sort-by-position:17803, tktj:take:17747, tktj:draw-table:17764, tktj:drop:17756, aa:cmd-end:722 |
| `ZDML2` | 17991-18162 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:709, blk-insertpt:11927, hao2:block-name:12419, hao2:sort-blocks:12433, zdml2:collect-all-texts:12481, zdml2:build-spatial-index:12529, zdml2:extract-rect-text-fast:17933, zdml2:query-rect-index:12582, tktj:take:17747, tktj:draw-table:17764, tktj:drop:17756, aa:cmd-end:722 |
| `ZDMLDEBUG` | 18165-18199 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:709, tktj:get-attributes:17624, aa:cmd-end:722 |
| `DUMP` | 18203-18227 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `C1` | 18445-18447 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:18377 |
| `C2` | 18449-18451 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:18377 |
| `C3` | 18453-18455 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:18377 |
| `DE` | 18788-18788 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:18743 |
| `DE2` | 18789-18789 | 1 | 用最右侧括号内容替换括号前同样位数的数字（数字带相同尾缀时一并替换，A63(4)0I → A640I）。 | de:run:18743 |
| `GE` | 18876-18978 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:18800, ge:get-item:18814, ge:sort-items:18851, ge:make-line:18858 |
| `UT` | 19089-19201 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:748, ut:horizontal-line-p:19006, ut:get-bbox:19028, ut:line-y:19021, ut:sort-desc:19065, aa:undo-mark-on:740, aa:normalize-text-horizontal-align:3566, ut:bbox-bottom:19045, ut:bbox-left:19041, ut:move:19073 |
| `0` | 19212-19246 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `9` | 19295-19304 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:709, aa:rotate-90-run:19253, aa:cmd-end:722 |
| `99` | 19307-19316 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:709, aa:rotate-90-run:19253, aa:cmd-end:722 |
| `QZ` | 19323-19371 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 19399-19416 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:709, dl1:make-layer:19383, aa:cmd-end:722 |
| `REP` | 19440-19534 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:709, rep-trim:19430, aa:cmd-end:722 |
| `KMZ` | 19827-19829 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `KMY` | 19833-19835 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `LNZ` | 19839-19841 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `LNY` | 19845-19847 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `UPSZ` | 19851-19853 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `UPSY` | 19857-19859 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `BZ` | 19863-19865 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `BY` | 19869-19871 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `ZJ` | 19903-19905 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:19878 |
| `YJ` | 19909-19911 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:19878 |
| `YDZ` | 20113-20115 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:19919 |
| `YDY` | 20119-20121 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:19919 |
| `LBZ` | 20125-20127 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:19919 |
| `LBY` | 20131-20133 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:19919 |
| `485Z` | 20137-20139 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `485Y` | 20143-20145 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:19619 |
| `XX` | 20156-20184 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `JM` | 20563-20638 | 76 | 按绿色电缆线（水平或竖直）所连原理号，把 ZDDLH/ZDDLS 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:709, aa:rep-begin:20196, xyg:dedup-hlines:8988, xy:ss->list:7636, xy:filter-green-hlines:8720, xy:collect-vlines:7917, xy:build-vline-buckets:7845, xy:build-text-meta-list:8175, xy:collect-texts:7942, xy:hline-info-ed:7732, jm:find-spec-text:20525, aa:ysdl-get-plain-text:1394 …共 24 个 |
| `BH2` | 21648-21823 | 176 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:709, aa:rep-begin:20196, aa:link-clock:10482, bh:prepare:21042, bh:record-path:20754, bh:now:20758, bh:fold-joins:20994, bh:read-records:20785, bh:rec-key:20693, bh:kmap:20704, bh:nmap:20717, bh:split-map:21633 …共 34 个 |
| `BHG` | 21826-21941 | 116 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:709, aa:rep-begin:20196, aa:link-clock:10482, bh:prepare:21042, bh:record-path:20754, bh:now:20758, bh:fold-joins:20994, bh:read-records:20785, bh:rec-key:20693, bh:kmap:20704, bh:nmap:20717, bh:clean:20673 …共 26 个 |
| `BH1` | 22254-22465 | 212 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:709, bh:pick-start:22149, bh:ask-prefix:21122, bh:ask-start:21132, bh:record-path:20754, bh:fold-joins:20994, bh:read-records:20785, bh:rec-key:20693, bh:kmap:20704, bh:nmap:20717, bh:own-records:22106, bh:write-records:20805 …共 42 个 |
| `BH3` | 22544-22720 | 177 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:709, aa:rep-begin:20196, hddl:text:23140, hddl:point:23158, aa:merge-sort:797, hddl:sort-rows:23222, hddl:rows:23212, hddl:coord:23152, bh:record-path:20754, bh:now:20758, bh:fold-joins:20994, bh:read-records:20785 …共 32 个 |
| `ZDAO` | 22840-22844 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:709, dao:run:22778, aa:cmd-end:722 |
| `HDAO` | 22847-22851 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:709, dao:run:22778, aa:cmd-end:722 |
| `QH` | 22856-23007 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:797 |
| `BK` | 23037-23080 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:18737, de:get-text:18721, bk:extract-inner:23018, de:set-text:18730 |
| `HDDL` | 23368-23458 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:748, aa:undo-mark-on:740, hddl:ensure-layer:23089, hddl:clear-markers:23129, hddl:text:23140, hddl:point:23158, hddl:sort-rows:23222, hddl:rows:23212, hddl:group-rows:23227, hddl:mirror-p:23362, hddl:cell:23272, hddl:tail-count:23278 …共 20 个 |
| `CU` | 23532-23533 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:23464 |
| `CD` | 23536-23537 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:23464 |
| `CZ` | 23540-23541 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:23464 |
| `CY` | 23544-23545 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:23464 |
| `HS` | 23598-23770 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:709, aa:hs-filter-unlocked:23552, aa:cmd-end:722, aa:hs-get-ss-bbox:23572 |
| `ZS` | 23779-23951 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:709, aa:hs-filter-unlocked:23552, aa:cmd-end:722, aa:hs-get-ss-bbox:23572 |
| `SC3` | 23983-24050 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:709, aa:sc3-layer-locked-p:23957, aa:sc3-entity-bbox:23965, aa:cmd-end:722 |
| `Z0` | 24117-24160 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:709, aa:z0-layer-locked-p:24056, aa:z0-data-flat-p:24074, aa:z0-polyline-flat-p:24107, aa:z0-one:24087, aa:z0-polyline-verts:24099, aa:cmd-end:722 |
| `VPO1` | 24166-24171 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `VPO2` | 24174-24179 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:709, aa:cmd-end:722 |
| `TONG` | 24185-24269 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:709, aa:cmd-end:722, aa:merge-sort:797, aa:gtx-natural-less:6306 |
| `ZDDL2` | 24930-25021 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:709, aa:cmd-end:722, zddl:parse-strip:24461, zddl:parse-wiring-ss:24682, zddl:ensure-layer:24742, zddl:plan-cables:24819, zddl:lookup-terminal:24370, zddl:label-layout:24844, zddl:draw-one-cable:24851, zddl:format-cable-no:24809 |
| `ZDC` | 25023-25025 | 3 | ZDDLH 命令的简写别名。 | c:zddlh:27317 |
| `ZDDLD` | 26115-26143 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:709, zddl2:xdata-app:26098, aa:layer-locked-p:4752, zddl2:set-layer-lock:26101, aa:cmd-end:722 |
| `XZYL` | 27293-27299 | 7 | 修正原理号：先点原理号正确的电缆录入，再运行点对面一端的同一根电缆，替换不一致的原理号并补填未编号；合画图录入按 1#/2# 拆开；可先选电缆线再运行。 | aa:cmd-begin:709, zyl:work:27261, aa:cmd-end:722 |
| `BDL` | 27305-27311 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行；选水平原理号时按竖排端子排补画竖直电缆线。 | aa:cmd-begin:709, bdl:work:26739, aa:cmd-end:722 |
| `ZDDLH` | 27317-27324 | 8 | 两次选择文字并指定左下基点，生成横排端子排与水平绿色电缆线（原 ZDDL）。 | aa:cmd-begin:709, zddl2:work:26012, aa:cmd-end:722 |
| `ZDDLS` | 27330-27337 | 8 | 两次选择文字并指定左上基点，生成竖排端子排、水平引线与竖直绿色电缆线（向下箭头、文字 270°）。 | aa:cmd-begin:709, zddl2:work:26012, aa:cmd-end:722 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 316 | 238-335, 389-512, 709-821, 1072-1606, 2936-2997, 3191-3661 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 166 个 |
| `des:` | 5 | 544-572 | DES |
| `ystemp:` | 2 | 643-650 | YSTEMP |
| `ztf:` | 13 | 823-1055 | ZTF |
| `txt:` | 7 | 1861-2063 | T, T2 |
| `zhu:` | 5 | 2080-2121 | ZHU |
| `hwt:` | 14 | 2175-2388 | HWT |
| `txt2:` | 5 | 2449-2596 | T2 |
| `qr:` | 3 | 4585-4607 | QR, QR2 |
| `det:` | 1 | 4829-4847 | DET |
| `a2t:` | 3 | 4902-4927 | A2T |
| `(无前缀):` | 22 | 7221-7273, 7316-7343, 11903-12174, 17206-17219, 19430-19438 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 47 | 7623-8741 | BH1, BH2, BHG, JM, XY, XYG, XYG2, XZYL |
| `xyg:` | 26 | 8767-9713 | BH1, BH2, BHG, JM, XYG, XYG2 |
| `hb:` | 9 | 10655-10952 | HBDL |
| `aae:` | 4 | 12177-12296, 12385-12400 | AAE, HAO2, MING, ZDC, ZDDLH, ZDDLS, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 12412-12479, 12615-12646 | HAO2, TJK, ZDML2 |
| `zdml2:` | 4 | 12481-12612, 17933-17989 | HAO2, ZDML2 |
| `ming:` | 4 | 12814-12948 | MING |
| `fdx:` | 11 | 13334-13376, 13570-13748 | FDX, FKX |
| `fkx:` | 10 | 13382-13492 | FKX |
| `dx:` | 12 | 13791-13997 | DX, DX1, DX2, FDX, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `dx2:` | 12 | 14075-14210 | DX2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `db:` | 5 | 16142-16229 | AB, AF, DB, DF |
| `zi:` | 2 | 16331-16351 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 16354-16382 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 16547-16608 | QW |
| `tjk:` | 6 | 16982-17063 | TJK |
| `aw:` | 17 | 17267-17437 | AW, XZYL |
| `tktj:` | 24 | 17511-17846 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 18245-18443 | C1, C2, C3 |
| `de:` | 20 | 18476-18786 | BK, DE, DE2 |
| `ge:` | 6 | 18800-18874 | GE |
| `ut:` | 10 | 18985-19087 | UT |
| `dl1:` | 1 | 19383-19397 | DL1 |
| `jm:` | 20 | 20315-20560 | BH1, BH2, BH3, BHG, JM, XZYL |
| `bh:` | 101 | 20665-21645, 21946-22251, 22466-22541 | BDL, BH1, BH2, BH3, BHG, JM, XYG, XYG2, XZYL |
| `dao:` | 4 | 22730-22837 | HDAO, ZDAO |
| `bk:` | 1 | 23018-23035 | BK |
| `hddl:` | 29 | 23089-23366 | BH1, BH2, BH3, BHG, HDDL, XZYL |
| `cu:` | 1 | 23464-23529 | CD, CU, CY, CZ |
| `zddl:` | 27 | 24278-24928 | BDL, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `zddl2:` | 96 | 25033-26109 | BDL, ZDC, ZDDLD, ZDDLH, ZDDLS |
| `bdl:` | 34 | 26150-26899 | BDL, XZYL |
| `zyl:` | 31 | 26908-27287 | XZYL |
