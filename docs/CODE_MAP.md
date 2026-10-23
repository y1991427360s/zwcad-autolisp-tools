# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，21794 行，879 个函数，其中 162 个 `c:` 命令。

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
| `SYI` | 5613-5613 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5546 |
| `XYI` | 5614-5614 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5546 |
| `SSS` | 5706-5777 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:5668, aa:sss-lowest-row-line:5694, aa:sss-find-pair:5641, aa:sss-horizontal-segments:5620, aa:cmd-begin:693, aa:cmd-end:706 |
| `SYAN` | 5820-5820 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:5780 |
| `XYAN` | 5823-5823 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:5780 |
| `SJ` | 5837-5863 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `XJ` | 5865-5891 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `SYJ` | 5934-5934 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:5892 |
| `XYJ` | 5935-5935 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:5892 |
| `GTX` | 6065-6245 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:732, aa:undo-mark-on:724, aa:gtx-select-prefix-text:6049, aa:ysdl-get-plain-text:1338, aa:try-get-bbox:1078, aa:merge-sort:781, aa:gtx-rows:6008, aa:gtx-key:5977, aa:gtx-find-last-char:5965, aa:gtx-natural-less:5985, aa:gtx-create-text-entity:6025 |
| `GTY` | 6488-6635 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6479, aa:gty-get-text-width:6316, aa:gty-separated-rows:6351, aa:gty-add-row:6385, aa:merge-sort:781, aa:gty-get-item-x:6284, aa:gty-order-rows:6435, aa:gty-column-widths:6447, aa:gty-row-tree:6397, aa:gty-build-sort-key:6292, aa:gty-tree-item:6408, aa:gty-copy-text:6459 …共 14 个 |
| `GTZ` | 6641-6798 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6316, aa:merge-sort:781, aa:gty-move-entity:6338 |
| `HWD` | 6825-6898 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:693, aa:safe-get-bbox:1089, aa:gty-get-text-width:6316, aa:merge-sort:781, aa:hwd-rows:6804, aa:hwd-make-text:6811, aa:cmd-end:706 |
| `BIAN` | 6954-6984 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:693, bian-draw-one:6926, aa:cmd-end:706 |
| `LAN` | 7024-7172 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:693, lan-vert-mode:6995, lan-get-option:7009, aa:cmd-end:706 |
| `XIN` | 7179-7253 | 75 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `XY` | 8125-8139 | 15 | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | aa:cmd-begin:693, xy:run-xin:7548, xy:run-yuan:7943, aa:cmd-end:706 |
| `XYG` | 8539-8734 | 196 | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:693, aa:cmd-end:706, xy:filter-green-hlines:8105, xyg:dedup-hlines:8320, xy:ss->list:7298, xyg:find-prefix-text:8146, aa:ysdl-get-plain-text:1338, aa:gtx-select-prefix-text:6049, aa:link-xdata:8744, xy:run-xin:7548, xy:run-yuan:7943, xyg:sort-lines-desc:8361 …共 22 个 |
| `SX0` | 9000-9039 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:693, aa:link-dwg-id:8761, aa:link-info:8749, aa:link-root-p:8757, aa:cmd-end:706 |
| `YSSX0` | 9046-9086 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:693, aa:link-dwg-id:8761, aa:link-info:8749, aa:link-root-p:8757, aa:cmd-end:706 |
| `SX` | 9093-9126 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:693, aa:link-dwg-id:8761, aa:link-info:8749, aa:link-root-p:8757, aa:cmd-end:706 |
| `SX1` | 9152-9220 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:693, aa:link-clock:9128, aa:link-dwg-id:8761, aa:link-info:8749, aa:link-root-p:8757, aa:link-root-ed:9133, aa:link-text-for:8779, aa:link-file-path:8811, aa:link-export:8850, aa:cmd-end:706 |
| `SX2` | 9228-9293 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:693, aa:link-dwg-id:8761, aa:link-info:8749, aa:link-ask-folder:8982, aa:link-collect-files:8916, aa:merge-sort:781, aa:link-file-time:8907, aa:link-read-file:8895, aa:link-uid<:8801, aa:link-count-conflicts:8944, aa:link-join:8932, aa:link-text-from-rec:8791 …共 13 个 |
| `HBDL` | 9600-9705 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:693, aa:cmd-end:706, aa:ysdl-get-plain-text:1338, hb:cluster-rows:9370, hb:parse-row:9399, hb:apply-merge-in-place:9515 |
| `NU` | 10001-10052 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:9950, aa:num-int-target-p:9931 |
| `KAI` | 10243-10326 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:10182, aa:kai-process-text:10200 |
| `ZHENG` | 10397-10527 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:10335, aa:safe-get-bbox:1089, aa:zheng-align-text-to-rect-center:10384, aa:zheng-line-mid-x:10350, aa:zheng-add-texts-after-explode:10357, aa:zheng-align-text-center-x:10375 |
| `AAE` | 10944-11029 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:693, aae:split-lines:10898, aae:locate-dcl:11031, aae:resolve-val:10927, aa:cmd-end:706 |
| `HAO` | 11048-11052 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:693, fillframes-run:10752, aa:cmd-end:706 |
| `HAO2` | 11294-11451 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:693, blk-insertpt:10573, hao2:block-name:11065, hao2:sort-blocks:11079, zdml2:collect-all-texts:11127, hao2:format-num:11058, hao2:find-existing-text-fast:11261, tktj:current-space:15923, tktj:ensure-text-style:15933, aa:cmd-end:706 |
| `MING` | 11596-11760 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:693, ming:find-title-attrib:11460, blk-insertpt:10573, ming:get-block-height:11497, ming:get-text-info:11513, ming:cluster-and-sort:11545, aa:cmd-end:706 |
| `FIVE` | 11769-11810 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `JZ` | 11830-11972 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1089, aa:jz-line-center-y:11818, aa:bbox-center-x:1113, aa:bbox-top-y:1127, aa:bbox-bottom-y:1131, aa:safe-move-entity:1135 |
| `FKX` | 12142-12213 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:693, fdx:poly-rect:12002, fdx:add-rect:12216, fkx:choose-frame:12037, fdx:rect-from-points:11980, fkx:collect:12074, fkx:title-rect:12104, fkx:point-in-p:12028, fkx:filter:12131, aa:cmd-end:706 |
| `FDX` | 12396-12434 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:12292, aa:undo-mark-off:732, fdx:frames:12254, fdx:sort-frames:12273, fdx:show-frame:12285, aa:undo-mark-on:724, fdx:place:12320 |
| `DX` | 12645-12714 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:732, aa:zz-filter-text-ss:12934, aa:zz-harvest-lines:13052, aa:zz-build-spatial-index:13077, aa:zz-text-info:13143, aa:zz-group-by-rect:13194, aa:undo-mark-on:724, dx:apply-group:12556 |
| `DX2` | 12858-12917 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:693, aa:zz-filter-text-ss:12934, aa:zz-harvest-lines:13052, aa:zz-build-spatial-index:13077, aa:zz-text-info:13143, aa:zz-group-by-rect:13194, dx2:sort-groups:12755, dx2:export-group:12843, zi:to-clip:14889, aa:cmd-end:706 |
| `ZZ` | 13340-13342 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:13288 |
| `ZZ2` | 13463-13559 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:13450, aa:safe-get-bbox:1089, aa:zz2-frame:13430, aa:zz-build-spatial-index:13077, aa:zz-text-info:13143, aa:zz-group-by-rect:13194, aa:zz2-plan:13345, aa:zz2-plan-ok:13354, aa:cmd-begin:693, aa:zz2-map-edge:13385, aa:bbox-top-y:1127, aa:bbox-bottom-y:1131 …共 16 个 |
| `JACC` | 13562-13564 | 3 | ZZ 的同功能入口。 | aa:zz-run:13288 |
| `MJ` | 13707-13794 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:13567, aa:mj-collect-text-data:13586, aa:mj-horizontal-ys:13614, aa:mj-scale-line-x:13687, aa:mj-move-cached-texts:13697 |
| `FIVE2` | 13858-13965 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1078, aa:tbhb-segment:13970, aa:tbhb-merge-segments:13988, aa:hg5-rows:13800, aa:tbhb-border-p:13980, aa:hg5-side-p:13827, aa:hg5-text-y:13849, aa:cmd-begin:693, aa:hg5-point:13845, aa:hg5-y:13812, aa:cmd-end:706 |
| `HBBG` | 14165-14253 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:732, aa:tbhb-collect:14117, aa:tbhb-boxes:14009, aa:tbhb-groups:14082, aa:tbhb-group-problem:14057, aa:merge-sort:781, aa:tbhb-before-p:14029, aa:tbhb-item-inside-p:14041, aa:undo-mark-on:724, aa:tbhb-offset:14093, aa:tbhb-shift-point:14099, aa:tbhb-seen-line-p:14103 …共 14 个 |
| `HZBG` | 14321-14385 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1089, aa:hzbg-plan:14270, aa:cmd-begin:693, aa:hzbg-move:14300, aa:hzbg-line:14313, aa:cmd-end:706 |
| `ZDWI` | 14575-14679 | 105 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:14436, aa:zdwi-vertices:14511, aa:zdwi-unique:14494, aa:zdwi-add-span:14499, aa:merge-sort:781, aa:safe-get-bbox:1089, aa:zdwi-column:14524, aa:zdwi-set-nth:14533, aa:cmd-begin:693, aa:zdwi-map-entity:14550, aa:zz-move-text:13162, aa:zz-center-texts:13269 …共 13 个 |
| `FF` | 14804-14845 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:693, aa:ysdl-get-raw-text:1253, aa:str-replace-all:1230, aa:ff-text-data:14785, aa:cmd-end:706 |
| `DB` | 14848-14852 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:693, db:del:14715, aa:cmd-end:706 |
| `DF` | 14854-14858 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:693, db:del:14715, aa:cmd-end:706 |
| `AB` | 14860-14864 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:693, db:add:14748, aa:cmd-end:706 |
| `AF` | 14866-14870 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:693, db:add:14748, aa:cmd-end:706 |
| `QE` | 14938-15019 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:14907, qe:zhi-prefix:14928 |
| `CC` | 15022-15096 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:693, aa:cmd-error:222, qe:get-clip-text:14907, aa:cmd-end:706 |
| `QW` | 15165-15201 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:693, aa:ysdl-get-plain-text:1338, zi:pt:14884, qw:join:15100, zi:to-clip:14889, aa:cmd-end:706 |
| `QW2` | 15207-15268 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:693, aa:ysdl-get-plain-text:1338, zi:pt:14884, aa:merge-sort:781, zi:to-clip:14889, aa:cmd-end:706 |
| `QW3` | 15480-15517 | 38 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:693, aa:qw3-record:15460, aa:merge-sort:781, zi:to-clip:14889, aa:cmd-end:706 |
| `DX1` | 15521-15591 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:693, zi:pt:14884, dx:color-kind:12461, aa:merge-sort:781, zi:to-clip:14889, aa:cmd-end:706 |
| `CE` | 15622-15652 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:693, ce-redraw:15606, aa:cmd-end:706 |
| `AW` | 15839-15881 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:15831, aw:process-one:15805 |
| `ZDML` | 16249-16327 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:693, tktj:safe-vla-object:15951, tktj:collect-one-block:16075, tktj:sort-by-page:16192, tktj:sort-by-position:16203, tktj:take:16147, tktj:draw-table:16164, tktj:drop:16156, aa:cmd-end:706 |
| `ZDML2` | 16391-16562 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:693, blk-insertpt:10573, hao2:block-name:11065, hao2:sort-blocks:11079, zdml2:collect-all-texts:11127, zdml2:build-spatial-index:11175, zdml2:extract-rect-text-fast:16333, zdml2:query-rect-index:11228, tktj:take:16147, tktj:draw-table:16164, tktj:drop:16156, aa:cmd-end:706 |
| `ZDMLDEBUG` | 16565-16599 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:693, tktj:get-attributes:16024, aa:cmd-end:706 |
| `DUMP` | 16603-16627 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `C1` | 16845-16847 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16777 |
| `C2` | 16849-16851 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16777 |
| `C3` | 16853-16855 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16777 |
| `DE` | 17040-17040 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:16995 |
| `DE2` | 17041-17041 | 1 | 用最右侧括号内容替换括号前连续数字（数字带相同尾缀时一并替换）。 | de:run:16995 |
| `GE` | 17128-17230 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:17052, ge:get-item:17066, ge:sort-items:17103, ge:make-line:17110 |
| `UT` | 17341-17453 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:732, ut:horizontal-line-p:17258, ut:get-bbox:17280, ut:line-y:17273, ut:sort-desc:17317, aa:undo-mark-on:724, aa:normalize-text-horizontal-align:3451, ut:bbox-bottom:17297, ut:bbox-left:17293, ut:move:17325 |
| `0` | 17464-17498 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `9` | 17547-17556 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:693, aa:rotate-90-run:17505, aa:cmd-end:706 |
| `99` | 17559-17568 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:693, aa:rotate-90-run:17505, aa:cmd-end:706 |
| `QZ` | 17575-17623 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 17651-17668 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:693, dl1:make-layer:17635, aa:cmd-end:706 |
| `REP` | 17692-17786 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:693, rep-trim:17682, aa:cmd-end:706 |
| `KMZ` | 18079-18081 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `KMY` | 18085-18087 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `LNZ` | 18091-18093 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `LNY` | 18097-18099 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `UPSZ` | 18103-18105 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `UPSY` | 18109-18111 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `BZ` | 18115-18117 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `BY` | 18121-18123 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `ZJ` | 18155-18157 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18130 |
| `YJ` | 18161-18163 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18130 |
| `YDZ` | 18365-18367 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18171 |
| `YDY` | 18371-18373 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18171 |
| `LBZ` | 18377-18379 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18171 |
| `LBY` | 18383-18385 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18171 |
| `485Z` | 18389-18391 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `485Y` | 18395-18397 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17871 |
| `XX` | 18408-18436 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `ZDAO` | 18555-18559 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:693, dao:run:18493, aa:cmd-end:706 |
| `HDAO` | 18562-18566 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:693, dao:run:18493, aa:cmd-end:706 |
| `QH` | 18571-18722 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:781 |
| `BK` | 18752-18795 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:16989, de:get-text:16973, bk:extract-inner:18733, de:set-text:16982 |
| `HDDL` | 19083-19173 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:732, aa:undo-mark-on:724, hddl:ensure-layer:18804, hddl:clear-markers:18844, hddl:text:18855, hddl:point:18873, hddl:sort-rows:18937, hddl:rows:18927, hddl:group-rows:18942, hddl:mirror-p:19077, hddl:cell:18987, hddl:tail-count:18993 …共 20 个 |
| `CU` | 19247-19248 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:19179 |
| `CD` | 19251-19252 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:19179 |
| `CZ` | 19255-19256 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:19179 |
| `CY` | 19259-19260 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:19179 |
| `HS` | 19313-19485 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:693, aa:hs-filter-unlocked:19267, aa:cmd-end:706, aa:hs-get-ss-bbox:19287 |
| `ZS` | 19494-19666 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:693, aa:hs-filter-unlocked:19267, aa:cmd-end:706, aa:hs-get-ss-bbox:19287 |
| `SC3` | 19698-19765 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:693, aa:sc3-layer-locked-p:19672, aa:sc3-entity-bbox:19680, aa:cmd-end:706 |
| `Z0` | 19832-19875 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:693, aa:z0-layer-locked-p:19771, aa:z0-data-flat-p:19789, aa:z0-polyline-flat-p:19822, aa:z0-one:19802, aa:z0-polyline-verts:19814, aa:cmd-end:706 |
| `VPO1` | 19881-19886 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `VPO2` | 19889-19894 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:693, aa:cmd-end:706 |
| `TONG` | 19900-19984 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:693, aa:cmd-end:706, aa:merge-sort:781, aa:gtx-natural-less:5985 |
| `ZDDL2` | 20604-20695 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:693, aa:cmd-end:706, zddl:parse-strip:20153, zddl:parse-wiring-ss:20356, zddl:ensure-layer:20416, zddl:plan-cables:20493, zddl:lookup-terminal:20085, zddl:label-layout:20518, zddl:draw-one-cable:20525, zddl:format-cable-no:20483 |
| `ZDC` | 20697-20699 | 3 | ZDDL 命令的简写别名。 | c:zddl:21786 |
| `ZDDLD` | 21752-21780 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:693, zddl2:xdata-app:21735, aa:layer-locked-p:4568, zddl2:set-layer-lock:21738, aa:cmd-end:706 |
| `ZDDL` | 21786-21793 | 8 | 两次选择文字并指定插入点，按网页规则生成端子排与电缆。 | aa:cmd-begin:693, zddl2:work:21660, aa:cmd-end:706 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 279 | 222-319, 373-496, 693-805, 1056-1550, 2821-2882, 3076-3477 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 150 个 |
| `des:` | 5 | 528-556 | DES |
| `ystemp:` | 2 | 627-634 | YSTEMP |
| `ztf:` | 13 | 807-1039 | ZTF |
| `txt:` | 6 | 1805-1968 | T, T2 |
| `txt2:` | 14 | 1981-2466 | T2 |
| `qr:` | 3 | 4401-4423 | QR, QR2 |
| `det:` | 1 | 4645-4663 | DET |
| `a2t:` | 3 | 4718-4743 | A2T |
| `(无前缀):` | 22 | 6900-6952, 6995-7022, 10549-10820, 15606-15619, 17682-17690 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 39 | 7285-8120 | XY, XYG |
| `xyg:` | 15 | 8146-8537 | XYG |
| `hb:` | 9 | 9301-9598 | HBDL |
| `aae:` | 4 | 10823-10942, 11031-11046 | AAE, HAO2, MING, ZDC, ZDDL, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 11058-11125, 11261-11292 | HAO2, ZDML2 |
| `zdml2:` | 4 | 11127-11258, 16333-16389 | HAO2, ZDML2 |
| `ming:` | 4 | 11460-11594 | MING |
| `fdx:` | 11 | 11980-12022, 12216-12394 | FDX, FKX |
| `fkx:` | 10 | 12028-12138 | FKX |
| `dx:` | 12 | 12437-12643 | DX, DX1, DX2, FDX, ZDC, ZDDL, ZDDL2 |
| `dx2:` | 12 | 12721-12856 | DX2, ZDC, ZDDL, ZDDL2 |
| `db:` | 5 | 14695-14782 | AB, AF, DB, DF |
| `zi:` | 2 | 14884-14904 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 14907-14935 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 15100-15161 | QW |
| `aw:` | 17 | 15667-15837 | AW |
| `tktj:` | 24 | 15911-16246 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 16645-16843 | C1, C2, C3 |
| `de:` | 11 | 16872-17038 | BK, DE, DE2 |
| `ge:` | 6 | 17052-17126 | GE |
| `ut:` | 10 | 17237-17339 | UT |
| `dl1:` | 1 | 17635-17649 | DL1 |
| `dao:` | 4 | 18445-18552 | HDAO, ZDAO |
| `bk:` | 1 | 18733-18750 | BK |
| `hddl:` | 29 | 18804-19081 | HDDL |
| `cu:` | 1 | 19179-19244 | CD, CU, CY, CZ |
| `zddl:` | 25 | 19993-20602 | ZDC, ZDDL, ZDDL2 |
| `zddl2:` | 93 | 20707-21746 | ZDC, ZDDL, ZDDLD |
