# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，21675 行，875 个函数，其中 162 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 321-370 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:693, aa:ys-line:244, aa:ys-ring:313, aa:ys-rim:302, aa:ys-snowflake:270, aa:ys-detail:295, aa:cmd-end:706 |
| `YS1` | 499-525 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:693, aa:ys-line:244, aa:ys1-t:399, aa:ys1-g:416, aa:ys1-o:436, aa:ys1-d:473, aa:cmd-end:706 |
| `DES` | 559-624 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:693, des:key-less-p:528, aa:merge-sort:781, des:record-less-p:533, des:x-less-p:537, des:overlap-p:543, aa:cmd-end:706 |
| `YSTEMP` | 637-691 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:693, aa:merge-sort:781, ystemp:y-less-p:627, ystemp:pair-p:631, aa:cmd-end:706 |
| `ZTF` | 1041-1054 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:693, ztf:collect-font-records:911, ztf:run-dialog:1011, aa:cmd-end:706 |
| `YSDL` | 1557-1758 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:732, aa:undo-mark-on:724, aa:ysdl-get-plain-text:1338, aa:ysdl-get-lwpoly-rect:1392, aa:ysdl-sort-boxes:1459, aa:ysdl-desktop-dir:1535, aa:merge-sort:781, aa:ysdl-parse-rows-from-text-data:1487, aa:ysdl-clean-text:1362, aa:ysdl-format-categorized-row:1527, aa:ysdl-build-csv-field:1353, aa:ysdl-reorder-row:1370 …共 13 个 |
| `Q` | 1770-1796 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `T` | 1970-1974 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:693, txt:run:1955, aa:cmd-end:706 |
| `T2` | 2468-2487 | 20 | 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。 | aa:cmd-begin:693, txt2:process-selection:2394, aa:cmd-end:706 |
| `ABCN` | 2503-2554 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:693, aa:safe-get-bbox:1089, aa:safe-move-entity:1135, aa:cmd-end:706 |
| `H` | 2556-2683 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:693, aa:normalize-text-horizontal-align:3451, aa:merge-sort:781, aa:cmd-end:706 |
| `H2` | 2690-2814 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:693, aa:normalize-text-horizontal-align:3451, aa:merge-sort:781, aa:cmd-end:706 |
| `Y` | 2840-2844 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `DZ` | 2884-2918 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:693, aa:ysdl-get-plain-text:1338, aa:dz-number-p:2850, aa:dz-color-text:2866, aa:cmd-end:706 |
| `YY` | 2924-2928 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `RR` | 2934-2938 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `WW` | 2944-2948 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `WWW` | 2954-2960 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:693, aa:deep-color-cmd:3279, aa:cmd-end:706 |
| `XU` | 2966-3040 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3046-3050 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `PP` | 3056-3060 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `HH` | 3066-3070 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:693, aa:color-cmd:2821, aa:cmd-end:706 |
| `HUI` | 3336-3341 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:693, aa:deep-color-cmd:3279, aa:cmd-end:706 |
| `ZHONG` | 3395-3399 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3344, aa:find-ref-by-top-bbox:1181, aa:bbox-center-x:1113, aa:normalize-text-horizontal-align:3451, aa:align-text-horizontal-by-bbox:1201 |
| `ZUO` | 3480-3484 | 5 | 将选中文字统一为左中对正，并以最上方文字为基准左对齐。 | aa:align-text-cmd:3344, aa:find-ref-by-top-bbox:1181, aa:bbox-left-x:1119, aa:normalize-text-horizontal-align:3451, aa:align-text-horizontal-by-bbox:1201 |
| `AZUO` | 3490-3609 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:693, aa:cmd-end:706, aa:safe-get-bbox:1089, aa:bbox-left-x:1119, aa:safe-move-entity:1135 |
| `HP` | 3615-3752 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:693, aa:cmd-end:706, aa:safe-get-bbox:1089, aa:bbox-left-x:1119, aa:bbox-top-y:1127, aa:merge-sort:781, aa:bbox-right-x:1123, aa:safe-move-entity:1135 |
| `HP2` | 3758-3901 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:693, aa:cmd-end:706, aa:normalize-text-horizontal-align:3451, aa:safe-get-bbox:1089, aa:bbox-center-x:1113, aa:bbox-top-y:1127, aa:bbox-bottom-y:1131, aa:merge-sort:781, aa:safe-move-entity:1135 |
| `YOU` | 3904-3908 | 5 | 将选中文字统一为右中对正，并以最上方文字为基准右对齐。 | aa:align-text-cmd:3344, aa:find-ref-by-top-bbox:1181, aa:bbox-right-x:1123, aa:normalize-text-horizontal-align:3451, aa:align-text-horizontal-by-bbox:1201 |
| `AYOU` | 3913-4032 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:693, aa:cmd-end:706, aa:safe-get-bbox:1089, aa:bbox-right-x:1123, aa:safe-move-entity:1135 |
| `SHANG` | 4035-4039 | 5 | 将选中文字统一为中上对正，并以最上方文字为基准上对齐。 | aa:align-text-cmd:3344, aa:find-ref-by-top-bbox:1181, aa:bbox-top-y:1127, aa:normalize-text-vertical-align:3465, aa:align-text-vertical-by-bbox:1215 |
| `ASHANG` | 4045-4164 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:693, aa:cmd-end:706, aa:safe-get-bbox:1089, aa:bbox-top-y:1127, aa:safe-move-entity:1135 |
| `XIA` | 4167-4171 | 5 | 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。 | aa:align-text-cmd:3344, aa:find-ref-by-left-bbox:1161, aa:bbox-bottom-y:1131, aa:normalize-text-vertical-align:3465, aa:align-text-vertical-by-bbox:1215 |
| `AXIA` | 4176-4295 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:693, aa:cmd-end:706, aa:safe-get-bbox:1089, aa:bbox-bottom-y:1131, aa:safe-move-entity:1135 |
| `HE` | 4297-4390 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:693, aa:insert-sort:753, aa:cmd-end:706 |
| `QR` | 4425-4470 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:693, qr:last-height:4401, qr:height-str:4420, qr:save-height:4413, aa:cmd-end:706 |
| `QR2` | 4476-4506 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:693, qr:last-height:4401, qr:height-str:4420, qr:save-height:4413, aa:cmd-end:706 |
| `DEA` | 4512-4535 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `DEK` | 4542-4562 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `DEH` | 4605-4635 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:693, aa:has-chinese:4583, aa:ysdl-get-plain-text:1338, aa:layer-locked-p:4568, aa:cmd-end:706 |
| `DET` | 4665-4706 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:693, det:split-values:4645, aa:ysdl-get-raw-text:1253, aa:layer-locked-p:4568, aa:cmd-end:706 |
| `A2T` | 4745-4782 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:693, a2t:pick-string:4723, a2t:layer-locked-p:4718, a2t:text-dxf:4735, aa:cmd-end:706 |
| `WI` | 4788-4828 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `ATW` | 4835-4919 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:693, aa:safe-get-bbox:1089, aa:bbox-right-x:1123, aa:bbox-left-x:1119, aa:safe-move-entity:1135, aa:cmd-end:706 |
| `XB` | 4925-4978 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `YAN` | 4984-5100 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:753 |
| `LL` | 5111-5140 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5266, aa:undo-mark-off:732, aa:undo-mark-on:724 |
| `MM` | 5289-5321 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5266, aa:undo-mark-off:732, aa:undo-mark-on:724, aa:ortho-report:5255, aa:ortho-drag:5215 |
| `SS` | 5327-5359 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5266, aa:undo-mark-off:732, aa:undo-mark-on:724, aa:ortho-report:5255, aa:ortho-drag:5215 |
| `SW` | 5448-5503 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:693, aa:cmd-error:222, aa:ss-format-vec:5367, aa:ss-do-interactive-stretch:5413, aa:cmd-end:706 |
| `SYI` | 5552-5552 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X。 | aa:move-stretch-vertical-cmd:5506 |
| `XYI` | 5553-5553 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X。 | aa:move-stretch-vertical-cmd:5506 |
| `SSS` | 5645-5716 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:5607, aa:sss-lowest-row-line:5633, aa:sss-find-pair:5580, aa:sss-horizontal-segments:5559, aa:cmd-begin:693, aa:cmd-end:706 |
| `SYAN` | 5759-5759 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:5719 |
| `XYAN` | 5762-5762 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:5719 |
| `SJ` | 5776-5802 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `XJ` | 5804-5830 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `SYJ` | 5873-5873 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:5831 |
| `XYJ` | 5874-5874 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:5831 |
| `GTX` | 6004-6184 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:732, aa:undo-mark-on:724, aa:gtx-select-prefix-text:5988, aa:ysdl-get-plain-text:1338, aa:try-get-bbox:1078, aa:merge-sort:781, aa:gtx-rows:5947, aa:gtx-key:5916, aa:gtx-find-last-char:5904, aa:gtx-natural-less:5924, aa:gtx-create-text-entity:5964 |
| `GTY` | 6427-6574 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6418, aa:gty-get-text-width:6255, aa:gty-separated-rows:6290, aa:gty-add-row:6324, aa:merge-sort:781, aa:gty-get-item-x:6223, aa:gty-order-rows:6374, aa:gty-column-widths:6386, aa:gty-row-tree:6336, aa:gty-build-sort-key:6231, aa:gty-tree-item:6347, aa:gty-copy-text:6398 …共 14 个 |
| `GTZ` | 6580-6737 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6255, aa:merge-sort:781, aa:gty-move-entity:6277 |
| `HWD` | 6764-6837 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:693, aa:safe-get-bbox:1089, aa:gty-get-text-width:6255, aa:merge-sort:781, aa:hwd-rows:6743, aa:hwd-make-text:6750, aa:cmd-end:706 |
| `BIAN` | 6893-6923 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:693, bian-draw-one:6865, aa:cmd-end:706 |
| `LAN` | 6946-7082 | 137 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:693, lan-get-option:6932, aa:cmd-end:706 |
| `XIN` | 7089-7163 | 75 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `XY` | 8035-8049 | 15 | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | aa:cmd-begin:693, xy:run-xin:7458, xy:run-yuan:7853, aa:cmd-end:706 |
| `XYG` | 8449-8644 | 196 | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:693, aa:cmd-end:706, xy:filter-green-hlines:8015, xyg:dedup-hlines:8230, xy:ss->list:7208, xyg:find-prefix-text:8056, aa:ysdl-get-plain-text:1338, aa:gtx-select-prefix-text:5988, aa:link-xdata:8654, xy:run-xin:7458, xy:run-yuan:7853, xyg:sort-lines-desc:8271 …共 22 个 |
| `SX0` | 8910-8949 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:693, aa:link-dwg-id:8671, aa:link-info:8659, aa:link-root-p:8667, aa:cmd-end:706 |
| `YSSX0` | 8956-8996 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:693, aa:link-dwg-id:8671, aa:link-info:8659, aa:link-root-p:8667, aa:cmd-end:706 |
| `SX` | 9003-9036 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:693, aa:link-dwg-id:8671, aa:link-info:8659, aa:link-root-p:8667, aa:cmd-end:706 |
| `SX1` | 9062-9130 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:693, aa:link-clock:9038, aa:link-dwg-id:8671, aa:link-info:8659, aa:link-root-p:8667, aa:link-root-ed:9043, aa:link-text-for:8689, aa:link-file-path:8721, aa:link-export:8760, aa:cmd-end:706 |
| `SX2` | 9138-9203 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:693, aa:link-dwg-id:8671, aa:link-info:8659, aa:link-ask-folder:8892, aa:link-collect-files:8826, aa:merge-sort:781, aa:link-file-time:8817, aa:link-read-file:8805, aa:link-uid<:8711, aa:link-count-conflicts:8854, aa:link-join:8842, aa:link-text-from-rec:8701 …共 13 个 |
| `HBDL` | 9510-9615 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:693, aa:cmd-end:706, aa:ysdl-get-plain-text:1338, hb:cluster-rows:9280, hb:parse-row:9309, hb:apply-merge-in-place:9425 |
| `NU` | 9911-9962 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:9860, aa:num-int-target-p:9841 |
| `KAI` | 10153-10236 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:10092, aa:kai-process-text:10110 |
| `ZHENG` | 10307-10437 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:10245, aa:safe-get-bbox:1089, aa:zheng-align-text-to-rect-center:10294, aa:zheng-line-mid-x:10260, aa:zheng-add-texts-after-explode:10267, aa:zheng-align-text-center-x:10285 |
| `AAE` | 10854-10939 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:693, aae:split-lines:10808, aae:locate-dcl:10941, aae:resolve-val:10837, aa:cmd-end:706 |
| `HAO` | 10958-10962 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:693, fillframes-run:10662, aa:cmd-end:706 |
| `HAO2` | 11204-11361 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:693, blk-insertpt:10483, hao2:block-name:10975, hao2:sort-blocks:10989, zdml2:collect-all-texts:11037, hao2:format-num:10968, hao2:find-existing-text-fast:11171, tktj:current-space:15833, tktj:ensure-text-style:15843, aa:cmd-end:706 |
| `MING` | 11506-11670 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:693, ming:find-title-attrib:11370, blk-insertpt:10483, ming:get-block-height:11407, ming:get-text-info:11423, ming:cluster-and-sort:11455, aa:cmd-end:706 |
| `FIVE` | 11679-11720 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `JZ` | 11740-11882 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1089, aa:jz-line-center-y:11728, aa:bbox-center-x:1113, aa:bbox-top-y:1127, aa:bbox-bottom-y:1131, aa:safe-move-entity:1135 |
| `FKX` | 12052-12123 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:693, fdx:poly-rect:11912, fdx:add-rect:12126, fkx:choose-frame:11947, fdx:rect-from-points:11890, fkx:collect:11984, fkx:title-rect:12014, fkx:point-in-p:11938, fkx:filter:12041, aa:cmd-end:706 |
| `FDX` | 12306-12344 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:12202, aa:undo-mark-off:732, fdx:frames:12164, fdx:sort-frames:12183, fdx:show-frame:12195, aa:undo-mark-on:724, fdx:place:12230 |
| `DX` | 12555-12624 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:732, aa:zz-filter-text-ss:12844, aa:zz-harvest-lines:12962, aa:zz-build-spatial-index:12987, aa:zz-text-info:13053, aa:zz-group-by-rect:13104, aa:undo-mark-on:724, dx:apply-group:12466 |
| `DX2` | 12768-12827 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:693, aa:zz-filter-text-ss:12844, aa:zz-harvest-lines:12962, aa:zz-build-spatial-index:12987, aa:zz-text-info:13053, aa:zz-group-by-rect:13104, dx2:sort-groups:12665, dx2:export-group:12753, zi:to-clip:14799, aa:cmd-end:706 |
| `ZZ` | 13250-13252 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:13198 |
| `ZZ2` | 13373-13469 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:13360, aa:safe-get-bbox:1089, aa:zz2-frame:13340, aa:zz-build-spatial-index:12987, aa:zz-text-info:13053, aa:zz-group-by-rect:13104, aa:zz2-plan:13255, aa:zz2-plan-ok:13264, aa:cmd-begin:693, aa:zz2-map-edge:13295, aa:bbox-top-y:1127, aa:bbox-bottom-y:1131 …共 16 个 |
| `JACC` | 13472-13474 | 3 | ZZ 的同功能入口。 | aa:zz-run:13198 |
| `MJ` | 13617-13704 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:13477, aa:mj-collect-text-data:13496, aa:mj-horizontal-ys:13524, aa:mj-scale-line-x:13597, aa:mj-move-cached-texts:13607 |
| `FIVE2` | 13768-13875 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1078, aa:tbhb-segment:13880, aa:tbhb-merge-segments:13898, aa:hg5-rows:13710, aa:tbhb-border-p:13890, aa:hg5-side-p:13737, aa:hg5-text-y:13759, aa:cmd-begin:693, aa:hg5-point:13755, aa:hg5-y:13722, aa:cmd-end:706 |
| `HBBG` | 14075-14163 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:732, aa:tbhb-collect:14027, aa:tbhb-boxes:13919, aa:tbhb-groups:13992, aa:tbhb-group-problem:13967, aa:merge-sort:781, aa:tbhb-before-p:13939, aa:tbhb-item-inside-p:13951, aa:undo-mark-on:724, aa:tbhb-offset:14003, aa:tbhb-shift-point:14009, aa:tbhb-seen-line-p:14013 …共 14 个 |
| `HZBG` | 14231-14295 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1089, aa:hzbg-plan:14180, aa:cmd-begin:693, aa:hzbg-move:14210, aa:hzbg-line:14223, aa:cmd-end:706 |
| `ZDWI` | 14485-14589 | 105 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:14346, aa:zdwi-vertices:14421, aa:zdwi-unique:14404, aa:zdwi-add-span:14409, aa:merge-sort:781, aa:safe-get-bbox:1089, aa:zdwi-column:14434, aa:zdwi-set-nth:14443, aa:cmd-begin:693, aa:zdwi-map-entity:14460, aa:zz-move-text:13072, aa:zz-center-texts:13179 …共 13 个 |
| `FF` | 14714-14755 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:693, aa:ysdl-get-raw-text:1253, aa:str-replace-all:1230, aa:ff-text-data:14695, aa:cmd-end:706 |
| `DB` | 14758-14762 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:693, db:del:14625, aa:cmd-end:706 |
| `DF` | 14764-14768 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:693, db:del:14625, aa:cmd-end:706 |
| `AB` | 14770-14774 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:693, db:add:14658, aa:cmd-end:706 |
| `AF` | 14776-14780 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:693, db:add:14658, aa:cmd-end:706 |
| `QE` | 14848-14929 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:14817, qe:zhi-prefix:14838 |
| `CC` | 14932-15006 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:693, aa:cmd-error:222, qe:get-clip-text:14817, aa:cmd-end:706 |
| `QW` | 15075-15111 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:693, aa:ysdl-get-plain-text:1338, zi:pt:14794, qw:join:15010, zi:to-clip:14799, aa:cmd-end:706 |
| `QW2` | 15117-15178 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:693, aa:ysdl-get-plain-text:1338, zi:pt:14794, aa:merge-sort:781, zi:to-clip:14799, aa:cmd-end:706 |
| `QW3` | 15390-15427 | 38 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:693, aa:qw3-record:15370, aa:merge-sort:781, zi:to-clip:14799, aa:cmd-end:706 |
| `DX1` | 15431-15501 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:693, zi:pt:14794, dx:color-kind:12371, aa:merge-sort:781, zi:to-clip:14799, aa:cmd-end:706 |
| `CE` | 15532-15562 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:693, ce-redraw:15516, aa:cmd-end:706 |
| `AW` | 15749-15791 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:15741, aw:process-one:15715 |
| `ZDML` | 16159-16237 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:693, tktj:safe-vla-object:15861, tktj:collect-one-block:15985, tktj:sort-by-page:16102, tktj:sort-by-position:16113, tktj:take:16057, tktj:draw-table:16074, tktj:drop:16066, aa:cmd-end:706 |
| `ZDML2` | 16301-16472 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:693, blk-insertpt:10483, hao2:block-name:10975, hao2:sort-blocks:10989, zdml2:collect-all-texts:11037, zdml2:build-spatial-index:11085, zdml2:extract-rect-text-fast:16243, zdml2:query-rect-index:11138, tktj:take:16057, tktj:draw-table:16074, tktj:drop:16066, aa:cmd-end:706 |
| `ZDMLDEBUG` | 16475-16509 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:693, tktj:get-attributes:15934, aa:cmd-end:706 |
| `DUMP` | 16513-16537 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `C1` | 16755-16757 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16687 |
| `C2` | 16759-16761 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16687 |
| `C3` | 16763-16765 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16687 |
| `DE` | 16921-16921 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:16876 |
| `DE2` | 16922-16922 | 1 | 用最右侧括号内容替换括号前连续数字。 | de:run:16876 |
| `GE` | 17009-17111 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:16933, ge:get-item:16947, ge:sort-items:16984, ge:make-line:16991 |
| `UT` | 17222-17334 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:732, ut:horizontal-line-p:17139, ut:get-bbox:17161, ut:line-y:17154, ut:sort-desc:17198, aa:undo-mark-on:724, aa:normalize-text-horizontal-align:3451, ut:bbox-bottom:17178, ut:bbox-left:17174, ut:move:17206 |
| `0` | 17345-17379 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `9` | 17428-17437 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:693, aa:rotate-90-run:17386, aa:cmd-end:706 |
| `99` | 17440-17449 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:693, aa:rotate-90-run:17386, aa:cmd-end:706 |
| `QZ` | 17456-17504 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 17532-17549 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:693, dl1:make-layer:17516, aa:cmd-end:706 |
| `REP` | 17573-17667 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:693, rep-trim:17563, aa:cmd-end:706 |
| `KMZ` | 17960-17962 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `KMY` | 17966-17968 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `LNZ` | 17972-17974 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `LNY` | 17978-17980 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `UPSZ` | 17984-17986 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `UPSY` | 17990-17992 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `BZ` | 17996-17998 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `BY` | 18002-18004 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `ZJ` | 18036-18038 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18011 |
| `YJ` | 18042-18044 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18011 |
| `YDZ` | 18246-18248 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18052 |
| `YDY` | 18252-18254 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18052 |
| `LBZ` | 18258-18260 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18052 |
| `LBY` | 18264-18266 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18052 |
| `485Z` | 18270-18272 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `485Y` | 18276-18278 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17752 |
| `XX` | 18289-18317 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `ZDAO` | 18436-18440 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:693, dao:run:18374, aa:cmd-end:706 |
| `HDAO` | 18443-18447 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:693, dao:run:18374, aa:cmd-end:706 |
| `QH` | 18452-18603 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:781 |
| `BK` | 18633-18676 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:16870, de:get-text:16854, bk:extract-inner:18614, de:set-text:16863 |
| `HDDL` | 18964-19054 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:732, aa:undo-mark-on:724, hddl:ensure-layer:18685, hddl:clear-markers:18725, hddl:text:18736, hddl:point:18754, hddl:sort-rows:18818, hddl:rows:18808, hddl:group-rows:18823, hddl:mirror-p:18958, hddl:cell:18868, hddl:tail-count:18874 …共 20 个 |
| `CU` | 19128-19129 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:19060 |
| `CD` | 19132-19133 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:19060 |
| `CZ` | 19136-19137 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:19060 |
| `CY` | 19140-19141 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:19060 |
| `HS` | 19194-19366 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:693, aa:hs-filter-unlocked:19148, aa:cmd-end:706, aa:hs-get-ss-bbox:19168 |
| `ZS` | 19375-19547 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:693, aa:hs-filter-unlocked:19148, aa:cmd-end:706, aa:hs-get-ss-bbox:19168 |
| `SC3` | 19579-19646 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:693, aa:sc3-layer-locked-p:19553, aa:sc3-entity-bbox:19561, aa:cmd-end:706 |
| `Z0` | 19713-19756 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:693, aa:z0-layer-locked-p:19652, aa:z0-data-flat-p:19670, aa:z0-polyline-flat-p:19703, aa:z0-one:19683, aa:z0-polyline-verts:19695, aa:cmd-end:706 |
| `VPO1` | 19762-19767 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `VPO2` | 19770-19775 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `TONG` | 19781-19865 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:693, aa:cmd-end:706, aa:merge-sort:781, aa:gtx-natural-less:5924 |
| `ZDDL2` | 20485-20576 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:693, aa:cmd-end:706, zddl:parse-strip:20034, zddl:parse-wiring-ss:20237, zddl:ensure-layer:20297, zddl:plan-cables:20374, zddl:lookup-terminal:19966, zddl:label-layout:20399, zddl:draw-one-cable:20406, zddl:format-cable-no:20364 |
| `ZDC` | 20578-20580 | 3 | ZDDL 命令的简写别名。 | c:zddl:21667 |
| `ZDDLD` | 21633-21661 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:693, zddl2:xdata-app:21616, aa:layer-locked-p:4568, zddl2:set-layer-lock:21619, aa:cmd-end:706 |
| `ZDDL` | 21667-21674 | 8 | 两次选择文字并指定插入点，按网页规则生成端子排与电缆。 | aa:cmd-begin:693, zddl2:work:21541, aa:cmd-end:706 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 278 | 222-319, 373-496, 693-805, 1056-1550, 2821-2882, 3076-3477 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 150 个 |
| `des:` | 5 | 528-556 | DES |
| `ystemp:` | 2 | 627-634 | YSTEMP |
| `ztf:` | 13 | 807-1039 | ZTF |
| `txt:` | 6 | 1805-1968 | T, T2 |
| `txt2:` | 14 | 1981-2466 | T2 |
| `qr:` | 3 | 4401-4423 | QR, QR2 |
| `det:` | 1 | 4645-4663 | DET |
| `a2t:` | 3 | 4718-4743 | A2T |
| `(无前缀):` | 21 | 6839-6891, 6932-6944, 10459-10730, 15516-15529, 17563-17571 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 39 | 7195-8030 | XY, XYG |
| `xyg:` | 15 | 8056-8447 | XYG |
| `hb:` | 9 | 9211-9508 | HBDL |
| `aae:` | 4 | 10733-10852, 10941-10956 | AAE, HAO2, MING, ZDC, ZDDL, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 10968-11035, 11171-11202 | HAO2, ZDML2 |
| `zdml2:` | 4 | 11037-11168, 16243-16299 | HAO2, ZDML2 |
| `ming:` | 4 | 11370-11504 | MING |
| `fdx:` | 11 | 11890-11932, 12126-12304 | FDX, FKX |
| `fkx:` | 10 | 11938-12048 | FKX |
| `dx:` | 12 | 12347-12553 | DX, DX1, DX2, FDX, ZDC, ZDDL, ZDDL2 |
| `dx2:` | 12 | 12631-12766 | DX2, ZDC, ZDDL, ZDDL2 |
| `db:` | 5 | 14605-14692 | AB, AF, DB, DF |
| `zi:` | 2 | 14794-14814 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 14817-14845 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 15010-15071 | QW |
| `aw:` | 17 | 15577-15747 | AW |
| `tktj:` | 24 | 15821-16156 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 16555-16753 | C1, C2, C3 |
| `de:` | 9 | 16781-16919 | BK, DE, DE2 |
| `ge:` | 6 | 16933-17007 | GE |
| `ut:` | 10 | 17118-17220 | UT |
| `dl1:` | 1 | 17516-17530 | DL1 |
| `dao:` | 4 | 18326-18433 | HDAO, ZDAO |
| `bk:` | 1 | 18614-18631 | BK |
| `hddl:` | 29 | 18685-18962 | HDDL |
| `cu:` | 1 | 19060-19125 | CD, CU, CY, CZ |
| `zddl:` | 25 | 19874-20483 | ZDC, ZDDL, ZDDL2 |
| `zddl2:` | 93 | 20588-21627 | ZDC, ZDDL, ZDDLD |
