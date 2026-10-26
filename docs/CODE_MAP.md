# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，24569 行，1033 个函数，其中 170 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 329-378 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:701, aa:ys-line:252, aa:ys-ring:321, aa:ys-rim:310, aa:ys-snowflake:278, aa:ys-detail:303, aa:cmd-end:714 |
| `YS1` | 507-533 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:701, aa:ys-line:252, aa:ys1-t:407, aa:ys1-g:424, aa:ys1-o:444, aa:ys1-d:481, aa:cmd-end:714 |
| `DES` | 567-632 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:701, des:key-less-p:536, aa:merge-sort:789, des:record-less-p:541, des:x-less-p:545, des:overlap-p:551, aa:cmd-end:714 |
| `YSTEMP` | 645-699 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:701, aa:merge-sort:789, ystemp:y-less-p:635, ystemp:pair-p:639, aa:cmd-end:714 |
| `ZTF` | 1049-1062 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:701, ztf:collect-font-records:919, ztf:run-dialog:1019, aa:cmd-end:714 |
| `YSDL` | 1605-1806 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:740, aa:undo-mark-on:732, aa:ysdl-get-plain-text:1386, aa:ysdl-get-lwpoly-rect:1440, aa:ysdl-sort-boxes:1507, aa:ysdl-desktop-dir:1583, aa:merge-sort:789, aa:ysdl-parse-rows-from-text-data:1535, aa:ysdl-clean-text:1410, aa:ysdl-format-categorized-row:1575, aa:ysdl-build-csv-field:1401, aa:ysdl-reorder-row:1418 …共 13 个 |
| `Q` | 1818-1844 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `T` | 2018-2022 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:701, txt:run:2003, aa:cmd-end:714 |
| `ZHU` | 2074-2118 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:701, aa:ysdl-get-plain-text:1386, zhu:classify:2043, zhu:trim:2031, zhu:pick-name:2062, zhu:build-note:2053, aa:cmd-end:714 |
| `HWT` | 2341-2392 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:701, aa:ysdl-get-plain-text:1386, aa:merge-sort:789, hwt:counts-text:2264, hwt:row-counts:2126, hwt:draw:2289, hwt:layout:2170, hwt:cable-no:2136, hwt:draw-list:2318, hwt:cable-rows:2251, aa:cmd-end:714 |
| `T2` | 2886-2905 | 20 | 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。 | aa:cmd-begin:701, txt2:process-selection:2812, aa:cmd-end:714 |
| `ABCN` | 2921-2972 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:701, aa:safe-get-bbox:1097, aa:safe-move-entity:1143, aa:cmd-end:714 |
| `H` | 2974-3101 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:701, aa:normalize-text-horizontal-align:3869, aa:merge-sort:789, aa:cmd-end:714 |
| `H2` | 3108-3232 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:701, aa:normalize-text-horizontal-align:3869, aa:merge-sort:789, aa:cmd-end:714 |
| `Y` | 3258-3262 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `DZ` | 3302-3336 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:701, aa:ysdl-get-plain-text:1386, aa:dz-number-p:3268, aa:dz-color-text:3284, aa:cmd-end:714 |
| `YY` | 3342-3346 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `RR` | 3352-3356 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `WW` | 3362-3366 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `WWW` | 3372-3378 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:701, aa:deep-color-cmd:3697, aa:cmd-end:714 |
| `XU` | 3384-3458 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3464-3468 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `PP` | 3474-3478 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `HH` | 3484-3488 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:701, aa:color-cmd:3239, aa:cmd-end:714 |
| `HUI` | 3754-3759 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:701, aa:deep-color-cmd:3697, aa:cmd-end:714 |
| `ZHONG` | 3813-3817 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3762, aa:find-ref-by-top-bbox:1209, aa:bbox-center-x:1121, aa:normalize-text-horizontal-align:3869, aa:align-text-horizontal-by-bbox:1249 |
| `ZUO` | 3898-3902 | 5 | 将选中文字统一为左中对正，并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3762, aa:find-ref-by-left-bbox:1169, aa:bbox-left-x:1127, aa:normalize-text-horizontal-align:3869, aa:align-text-horizontal-by-bbox:1249 |
| `AZUO` | 3908-4027 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:701, aa:cmd-end:714, aa:safe-get-bbox:1097, aa:bbox-left-x:1127, aa:safe-move-entity:1143 |
| `HP` | 4033-4170 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:701, aa:cmd-end:714, aa:safe-get-bbox:1097, aa:bbox-left-x:1127, aa:bbox-top-y:1135, aa:merge-sort:789, aa:bbox-right-x:1131, aa:safe-move-entity:1143 |
| `HP2` | 4176-4319 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:701, aa:cmd-end:714, aa:normalize-text-horizontal-align:3869, aa:safe-get-bbox:1097, aa:bbox-center-x:1121, aa:bbox-top-y:1135, aa:bbox-bottom-y:1139, aa:merge-sort:789, aa:safe-move-entity:1143 |
| `YOU` | 4322-4326 | 5 | 将选中文字统一为右中对正，并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3762, aa:find-ref-by-right-bbox:1189, aa:bbox-right-x:1131, aa:normalize-text-horizontal-align:3869, aa:align-text-horizontal-by-bbox:1249 |
| `AYOU` | 4331-4450 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:701, aa:cmd-end:714, aa:safe-get-bbox:1097, aa:bbox-right-x:1131, aa:safe-move-entity:1143 |
| `SHANG` | 4453-4457 | 5 | 将选中文字统一为中上对正，并以最上方文字为基准上对齐。 | aa:align-text-cmd:3762, aa:find-ref-by-top-bbox:1209, aa:bbox-top-y:1135, aa:normalize-text-vertical-align:3883, aa:align-text-vertical-by-bbox:1263 |
| `ASHANG` | 4463-4582 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:701, aa:cmd-end:714, aa:safe-get-bbox:1097, aa:bbox-top-y:1135, aa:safe-move-entity:1143 |
| `XIA` | 4585-4589 | 5 | 将选中文字统一为中下对正，并以最下方文字为基准下对齐。 | aa:align-text-cmd:3762, aa:find-ref-by-bottom-bbox:1229, aa:bbox-bottom-y:1139, aa:normalize-text-vertical-align:3883, aa:align-text-vertical-by-bbox:1263 |
| `AXIA` | 4594-4713 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:701, aa:cmd-end:714, aa:safe-get-bbox:1097, aa:bbox-bottom-y:1139, aa:safe-move-entity:1143 |
| `HE` | 4715-4808 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:701, aa:insert-sort:761, aa:cmd-end:714 |
| `QR` | 4843-4888 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:701, qr:last-height:4819, qr:height-str:4838, qr:save-height:4831, aa:cmd-end:714 |
| `QR2` | 4894-4924 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:701, qr:last-height:4819, qr:height-str:4838, qr:save-height:4831, aa:cmd-end:714 |
| `DEA` | 4930-4953 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `DEK` | 4960-4980 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `DEH` | 5023-5053 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:701, aa:has-chinese:5001, aa:ysdl-get-plain-text:1386, aa:layer-locked-p:4986, aa:cmd-end:714 |
| `DET` | 5083-5124 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:701, det:split-values:5063, aa:ysdl-get-raw-text:1301, aa:layer-locked-p:4986, aa:cmd-end:714 |
| `A2T` | 5163-5200 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:701, a2t:pick-string:5141, a2t:layer-locked-p:5136, a2t:text-dxf:5153, aa:cmd-end:714 |
| `WI` | 5206-5246 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `ATW` | 5253-5337 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:701, aa:safe-get-bbox:1097, aa:bbox-right-x:1131, aa:bbox-left-x:1127, aa:safe-move-entity:1143, aa:cmd-end:714 |
| `XB` | 5343-5396 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `YAN` | 5402-5518 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:761 |
| `LL` | 5529-5558 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5684, aa:undo-mark-off:740, aa:undo-mark-on:732 |
| `MM` | 5707-5739 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5684, aa:undo-mark-off:740, aa:undo-mark-on:732, aa:ortho-report:5673, aa:ortho-drag:5633 |
| `SS` | 5745-5777 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5684, aa:undo-mark-off:740, aa:undo-mark-on:732, aa:ortho-report:5673, aa:ortho-drag:5633 |
| `SW` | 5866-5921 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:701, aa:cmd-error:230, aa:ss-format-vec:5785, aa:ss-do-interactive-stretch:5831, aa:cmd-end:714 |
| `SYI` | 6031-6031 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5964 |
| `XYI` | 6032-6032 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5964 |
| `SSS` | 6124-6195 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:6086, aa:sss-lowest-row-line:6112, aa:sss-find-pair:6059, aa:sss-horizontal-segments:6038, aa:cmd-begin:701, aa:cmd-end:714 |
| `SYAN` | 6238-6238 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6198 |
| `XYAN` | 6241-6241 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6198 |
| `SJ` | 6255-6281 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `XJ` | 6283-6309 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `SYJ` | 6352-6352 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6310 |
| `XYJ` | 6353-6353 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6310 |
| `GTX` | 6483-6663 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:740, aa:undo-mark-on:732, aa:gtx-select-prefix-text:6467, aa:ysdl-get-plain-text:1386, aa:try-get-bbox:1086, aa:merge-sort:789, aa:gtx-rows:6426, aa:gtx-key:6395, aa:gtx-find-last-char:6383, aa:gtx-natural-less:6403, aa:gtx-create-text-entity:6443 |
| `GTY` | 6906-7053 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6897, aa:gty-get-text-width:6734, aa:gty-separated-rows:6769, aa:gty-add-row:6803, aa:merge-sort:789, aa:gty-get-item-x:6702, aa:gty-order-rows:6853, aa:gty-column-widths:6865, aa:gty-row-tree:6815, aa:gty-build-sort-key:6710, aa:gty-tree-item:6826, aa:gty-copy-text:6877 …共 14 个 |
| `GTZ` | 7059-7216 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6734, aa:merge-sort:789, aa:gty-move-entity:6756 |
| `HWD` | 7243-7316 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:701, aa:safe-get-bbox:1097, aa:gty-get-text-width:6734, aa:merge-sort:789, aa:hwd-rows:7222, aa:hwd-make-text:7229, aa:cmd-end:714 |
| `BIAN` | 7372-7402 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:701, bian-draw-one:7344, aa:cmd-end:714 |
| `LAN` | 7442-7590 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:701, lan-vert-mode:7413, lan-get-option:7427, aa:cmd-end:714 |
| `XIN` | 7597-7671 | 75 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `XY` | 8543-8557 | 15 | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | aa:cmd-begin:701, xy:run-xin:7966, xy:run-yuan:8361, aa:cmd-end:714 |
| `XYG` | 8957-9152 | 196 | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:701, aa:cmd-end:714, xy:filter-green-hlines:8523, xyg:dedup-hlines:8738, xy:ss->list:7716, xyg:find-prefix-text:8564, aa:ysdl-get-plain-text:1386, aa:gtx-select-prefix-text:6467, aa:link-xdata:9162, xy:run-xin:7966, xy:run-yuan:8361, xyg:sort-lines-desc:8779 …共 22 个 |
| `SX0` | 9418-9457 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:701, aa:link-dwg-id:9179, aa:link-info:9167, aa:link-root-p:9175, aa:cmd-end:714 |
| `YSSX0` | 9464-9504 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:701, aa:link-dwg-id:9179, aa:link-info:9167, aa:link-root-p:9175, aa:cmd-end:714 |
| `SX` | 9511-9544 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:701, aa:link-dwg-id:9179, aa:link-info:9167, aa:link-root-p:9175, aa:cmd-end:714 |
| `SX1` | 9570-9638 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:701, aa:link-clock:9546, aa:link-dwg-id:9179, aa:link-info:9167, aa:link-root-p:9175, aa:link-root-ed:9551, aa:link-text-for:9197, aa:link-file-path:9229, aa:link-export:9268, aa:cmd-end:714 |
| `SX2` | 9646-9711 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:701, aa:link-dwg-id:9179, aa:link-info:9167, aa:link-ask-folder:9400, aa:link-collect-files:9334, aa:merge-sort:789, aa:link-file-time:9325, aa:link-read-file:9313, aa:link-uid<:9219, aa:link-count-conflicts:9362, aa:link-join:9350, aa:link-text-from-rec:9209 …共 13 个 |
| `HBDL` | 10018-10123 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:701, aa:cmd-end:714, aa:ysdl-get-plain-text:1386, hb:cluster-rows:9788, hb:parse-row:9817, hb:apply-merge-in-place:9933 |
| `NU` | 10419-10470 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:10368, aa:num-int-target-p:10349 |
| `KAI` | 10661-10744 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:10600, aa:kai-process-text:10618 |
| `ZHENG` | 10815-10945 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:10753, aa:safe-get-bbox:1097, aa:zheng-align-text-to-rect-center:10802, aa:zheng-line-mid-x:10768, aa:zheng-add-texts-after-explode:10775, aa:zheng-align-text-center-x:10793 |
| `AAE` | 11362-11447 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:701, aae:split-lines:11316, aae:locate-dcl:11449, aae:resolve-val:11345, aa:cmd-end:714 |
| `HAO` | 11466-11470 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:701, fillframes-run:11170, aa:cmd-end:714 |
| `HAO2` | 11712-11869 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:701, blk-insertpt:10991, hao2:block-name:11483, hao2:sort-blocks:11497, zdml2:collect-all-texts:11545, hao2:format-num:11476, hao2:find-existing-text-fast:11679, tktj:current-space:16354, tktj:ensure-text-style:16364, aa:cmd-end:714 |
| `MING` | 12014-12178 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:701, ming:find-title-attrib:11878, blk-insertpt:10991, ming:get-block-height:11915, ming:get-text-info:11931, ming:cluster-and-sort:11963, aa:cmd-end:714 |
| `FIVE` | 12187-12228 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `JZ` | 12248-12390 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1097, aa:jz-line-center-y:12236, aa:bbox-center-x:1121, aa:bbox-top-y:1135, aa:bbox-bottom-y:1139, aa:safe-move-entity:1143 |
| `FKX` | 12560-12631 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:701, fdx:poly-rect:12420, fdx:add-rect:12634, fkx:choose-frame:12455, fdx:rect-from-points:12398, fkx:collect:12492, fkx:title-rect:12522, fkx:point-in-p:12446, fkx:filter:12549, aa:cmd-end:714 |
| `FDX` | 12814-12852 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:12710, aa:undo-mark-off:740, fdx:frames:12672, fdx:sort-frames:12691, fdx:show-frame:12703, aa:undo-mark-on:732, fdx:place:12738 |
| `DX` | 13063-13132 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:740, aa:zz-filter-text-ss:13352, aa:zz-harvest-lines:13470, aa:zz-build-spatial-index:13495, aa:zz-text-info:13561, aa:zz-group-by-rect:13612, aa:undo-mark-on:732, dx:apply-group:12974 |
| `DX2` | 13276-13335 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:701, aa:zz-filter-text-ss:13352, aa:zz-harvest-lines:13470, aa:zz-build-spatial-index:13495, aa:zz-text-info:13561, aa:zz-group-by-rect:13612, dx2:sort-groups:13173, dx2:export-group:13261, zi:to-clip:15307, aa:cmd-end:714 |
| `ZZ` | 13758-13760 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:13706 |
| `ZZ2` | 13881-13977 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:13868, aa:safe-get-bbox:1097, aa:zz2-frame:13848, aa:zz-build-spatial-index:13495, aa:zz-text-info:13561, aa:zz-group-by-rect:13612, aa:zz2-plan:13763, aa:zz2-plan-ok:13772, aa:cmd-begin:701, aa:zz2-map-edge:13803, aa:bbox-top-y:1135, aa:bbox-bottom-y:1139 …共 16 个 |
| `JACC` | 13980-13982 | 3 | ZZ 的同功能入口。 | aa:zz-run:13706 |
| `MJ` | 14125-14212 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:13985, aa:mj-collect-text-data:14004, aa:mj-horizontal-ys:14032, aa:mj-scale-line-x:14105, aa:mj-move-cached-texts:14115 |
| `FIVE2` | 14276-14383 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1086, aa:tbhb-segment:14388, aa:tbhb-merge-segments:14406, aa:hg5-rows:14218, aa:tbhb-border-p:14398, aa:hg5-side-p:14245, aa:hg5-text-y:14267, aa:cmd-begin:701, aa:hg5-point:14263, aa:hg5-y:14230, aa:cmd-end:714 |
| `HBBG` | 14583-14671 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:740, aa:tbhb-collect:14535, aa:tbhb-boxes:14427, aa:tbhb-groups:14500, aa:tbhb-group-problem:14475, aa:merge-sort:789, aa:tbhb-before-p:14447, aa:tbhb-item-inside-p:14459, aa:undo-mark-on:732, aa:tbhb-offset:14511, aa:tbhb-shift-point:14517, aa:tbhb-seen-line-p:14521 …共 14 个 |
| `HZBG` | 14739-14803 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1097, aa:hzbg-plan:14688, aa:cmd-begin:701, aa:hzbg-move:14718, aa:hzbg-line:14731, aa:cmd-end:714 |
| `ZDWI` | 14993-15097 | 105 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:14854, aa:zdwi-vertices:14929, aa:zdwi-unique:14912, aa:zdwi-add-span:14917, aa:merge-sort:789, aa:safe-get-bbox:1097, aa:zdwi-column:14942, aa:zdwi-set-nth:14951, aa:cmd-begin:701, aa:zdwi-map-entity:14968, aa:zz-move-text:13580, aa:zz-center-texts:13687 …共 13 个 |
| `FF` | 15222-15263 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:701, aa:ysdl-get-raw-text:1301, aa:str-replace-all:1278, aa:ff-text-data:15203, aa:cmd-end:714 |
| `DB` | 15266-15270 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:701, db:del:15133, aa:cmd-end:714 |
| `DF` | 15272-15276 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:701, db:del:15133, aa:cmd-end:714 |
| `AB` | 15278-15282 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:701, db:add:15166, aa:cmd-end:714 |
| `AF` | 15284-15288 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:701, db:add:15166, aa:cmd-end:714 |
| `QE` | 15356-15437 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:15325, qe:zhi-prefix:15346 |
| `CC` | 15440-15514 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:701, aa:cmd-error:230, qe:get-clip-text:15325, aa:cmd-end:714 |
| `QW` | 15583-15619 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:701, aa:ysdl-get-plain-text:1386, zi:pt:15302, qw:join:15518, zi:to-clip:15307, aa:cmd-end:714 |
| `QW2` | 15625-15686 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:701, aa:ysdl-get-plain-text:1386, zi:pt:15302, aa:merge-sort:789, zi:to-clip:15307, aa:cmd-end:714 |
| `QW3` | 15910-15948 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:701, aa:qw3-record:15883, aa:merge-sort:789, zi:to-clip:15307, aa:cmd-end:714 |
| `DX1` | 15952-16022 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:701, zi:pt:15302, dx:color-kind:12879, aa:merge-sort:789, zi:to-clip:15307, aa:cmd-end:714 |
| `CE` | 16053-16083 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:701, ce-redraw:16037, aa:cmd-end:714 |
| `AW` | 16270-16312 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:16262, aw:process-one:16236 |
| `ZDML` | 16680-16758 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:701, tktj:safe-vla-object:16382, tktj:collect-one-block:16506, tktj:sort-by-page:16623, tktj:sort-by-position:16634, tktj:take:16578, tktj:draw-table:16595, tktj:drop:16587, aa:cmd-end:714 |
| `ZDML2` | 16822-16993 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:701, blk-insertpt:10991, hao2:block-name:11483, hao2:sort-blocks:11497, zdml2:collect-all-texts:11545, zdml2:build-spatial-index:11593, zdml2:extract-rect-text-fast:16764, zdml2:query-rect-index:11646, tktj:take:16578, tktj:draw-table:16595, tktj:drop:16587, aa:cmd-end:714 |
| `ZDMLDEBUG` | 16996-17030 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:701, tktj:get-attributes:16455, aa:cmd-end:714 |
| `DUMP` | 17034-17058 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `C1` | 17276-17278 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17208 |
| `C2` | 17280-17282 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17208 |
| `C3` | 17284-17286 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:17208 |
| `DE` | 17471-17471 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:17426 |
| `DE2` | 17472-17472 | 1 | 用最右侧括号内容替换括号前连续数字（数字带相同尾缀时一并替换）。 | de:run:17426 |
| `GE` | 17559-17661 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:17483, ge:get-item:17497, ge:sort-items:17534, ge:make-line:17541 |
| `UT` | 17772-17884 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:740, ut:horizontal-line-p:17689, ut:get-bbox:17711, ut:line-y:17704, ut:sort-desc:17748, aa:undo-mark-on:732, aa:normalize-text-horizontal-align:3869, ut:bbox-bottom:17728, ut:bbox-left:17724, ut:move:17756 |
| `0` | 17895-17929 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `9` | 17978-17987 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:701, aa:rotate-90-run:17936, aa:cmd-end:714 |
| `99` | 17990-17999 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:701, aa:rotate-90-run:17936, aa:cmd-end:714 |
| `QZ` | 18006-18054 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 18082-18099 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:701, dl1:make-layer:18066, aa:cmd-end:714 |
| `REP` | 18123-18217 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:701, rep-trim:18113, aa:cmd-end:714 |
| `KMZ` | 18510-18512 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `KMY` | 18516-18518 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `LNZ` | 18522-18524 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `LNY` | 18528-18530 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `UPSZ` | 18534-18536 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `UPSY` | 18540-18542 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `BZ` | 18546-18548 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `BY` | 18552-18554 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `ZJ` | 18586-18588 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18561 |
| `YJ` | 18592-18594 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18561 |
| `YDZ` | 18796-18798 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18602 |
| `YDY` | 18802-18804 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18602 |
| `LBZ` | 18808-18810 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18602 |
| `LBY` | 18814-18816 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18602 |
| `485Z` | 18820-18822 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `485Y` | 18826-18828 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:18302 |
| `XX` | 18839-18867 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `JM` | 19210-19285 | 76 | 按绿色电缆线所连原理号，把 ZDDL 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:701, aa:rep-begin:18879, xyg:dedup-hlines:8738, xy:ss->list:7716, xy:filter-green-hlines:8523, xy:collect-vlines:7931, xy:build-vline-buckets:7860, xy:build-text-meta-list:8149, xy:collect-texts:7947, xy:hline-info-ed:7784, jm:find-spec-text:19184, aa:ysdl-get-plain-text:1386 …共 24 个 |
| `BH2` | 20033-20191 | 159 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:701, aa:rep-begin:18879, aa:link-clock:9546, bh:prepare:19560, bh:record-path:19399, bh:now:19403, bh:read-records:19430, bh:rec-key:19338, bh:kmap:19349, bh:nmap:19362, bh:split-map:20018, bh:resolve-neighbors:19748 …共 31 个 |
| `BHG` | 20194-20294 | 101 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:701, aa:rep-begin:18879, aa:link-clock:9546, bh:prepare:19560, bh:record-path:19399, bh:now:19403, bh:read-records:19430, bh:rec-key:19338, bh:kmap:19349, bh:nmap:19362, bh:clean:19318, hddl:color:21357 …共 24 个 |
| `BH1` | 20574-20779 | 206 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:701, bh:pick-start:20476, bh:ask-prefix:19634, bh:ask-start:19644, bh:record-path:19399, bh:read-records:19430, bh:rec-key:19338, bh:kmap:19349, bh:nmap:19362, bh:own-records:20433, bh:write-records:19450, bh:clean:19318 …共 39 个 |
| `BH3` | 20809-20934 | 126 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:701, aa:rep-begin:18879, hddl:text:21354, hddl:point:21372, aa:merge-sort:789, hddl:sort-rows:21436, hddl:rows:21426, hddl:coord:21366, bh:record-path:19399, bh:now:19403, bh:read-records:19430, bh:rec-key:19338 …共 29 个 |
| `ZDAO` | 21054-21058 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:701, dao:run:20992, aa:cmd-end:714 |
| `HDAO` | 21061-21065 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:701, dao:run:20992, aa:cmd-end:714 |
| `QH` | 21070-21221 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:789 |
| `BK` | 21251-21294 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:17420, de:get-text:17404, bk:extract-inner:21232, de:set-text:17413 |
| `HDDL` | 21582-21672 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:740, aa:undo-mark-on:732, hddl:ensure-layer:21303, hddl:clear-markers:21343, hddl:text:21354, hddl:point:21372, hddl:sort-rows:21436, hddl:rows:21426, hddl:group-rows:21441, hddl:mirror-p:21576, hddl:cell:21486, hddl:tail-count:21492 …共 20 个 |
| `CU` | 21746-21747 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:21678 |
| `CD` | 21750-21751 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:21678 |
| `CZ` | 21754-21755 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:21678 |
| `CY` | 21758-21759 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:21678 |
| `HS` | 21812-21984 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:701, aa:hs-filter-unlocked:21766, aa:cmd-end:714, aa:hs-get-ss-bbox:21786 |
| `ZS` | 21993-22165 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:701, aa:hs-filter-unlocked:21766, aa:cmd-end:714, aa:hs-get-ss-bbox:21786 |
| `SC3` | 22197-22264 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:701, aa:sc3-layer-locked-p:22171, aa:sc3-entity-bbox:22179, aa:cmd-end:714 |
| `Z0` | 22331-22374 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:701, aa:z0-layer-locked-p:22270, aa:z0-data-flat-p:22288, aa:z0-polyline-flat-p:22321, aa:z0-one:22301, aa:z0-polyline-verts:22313, aa:cmd-end:714 |
| `VPO1` | 22380-22385 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `VPO2` | 22388-22393 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:701, aa:cmd-end:714 |
| `TONG` | 22399-22483 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:701, aa:cmd-end:714, aa:merge-sort:789, aa:gtx-natural-less:6403 |
| `ZDDL2` | 23103-23194 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:701, aa:cmd-end:714, zddl:parse-strip:22652, zddl:parse-wiring-ss:22855, zddl:ensure-layer:22915, zddl:plan-cables:22992, zddl:lookup-terminal:22584, zddl:label-layout:23017, zddl:draw-one-cable:23024, zddl:format-cable-no:22982 |
| `ZDC` | 23196-23198 | 3 | ZDDL 命令的简写别名。 | c:zddl:24561 |
| `ZDDLD` | 24252-24280 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:701, zddl2:xdata-app:24235, aa:layer-locked-p:4986, zddl2:set-layer-lock:24238, aa:cmd-end:714 |
| `BDL` | 24549-24555 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行。 | aa:cmd-begin:701, bdl:work:24418, aa:cmd-end:714 |
| `ZDDL` | 24561-24568 | 8 | 两次选择文字并指定插入点，按网页规则生成端子排与电缆。 | aa:cmd-begin:701, zddl2:work:24160, aa:cmd-end:714 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 290 | 230-327, 381-504, 701-813, 1064-1598, 3239-3300, 3494-3895 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 158 个 |
| `des:` | 5 | 536-564 | DES |
| `ystemp:` | 2 | 635-642 | YSTEMP |
| `ztf:` | 13 | 815-1047 | ZTF |
| `txt:` | 6 | 1853-2016 | T, T2 |
| `zhu:` | 5 | 2031-2072 | ZHU |
| `hwt:` | 14 | 2126-2339 | HWT |
| `txt2:` | 14 | 2399-2884 | T2 |
| `qr:` | 3 | 4819-4841 | QR, QR2 |
| `det:` | 1 | 5063-5081 | DET |
| `a2t:` | 3 | 5136-5161 | A2T |
| `(无前缀):` | 22 | 7318-7370, 7413-7440, 10967-11238, 16037-16050, 18113-18121 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 39 | 7703-8538 | BH1, BH2, BHG, JM, XY, XYG |
| `xyg:` | 15 | 8564-8955 | BH1, BH2, BHG, JM, XYG |
| `hb:` | 9 | 9719-10016 | HBDL |
| `aae:` | 4 | 11241-11360, 11449-11464 | AAE, HAO2, MING, ZDC, ZDDL, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 11476-11543, 11679-11710 | HAO2, ZDML2 |
| `zdml2:` | 4 | 11545-11676, 16764-16820 | HAO2, ZDML2 |
| `ming:` | 4 | 11878-12012 | MING |
| `fdx:` | 11 | 12398-12440, 12634-12812 | FDX, FKX |
| `fkx:` | 10 | 12446-12556 | FKX |
| `dx:` | 12 | 12855-13061 | DX, DX1, DX2, FDX, ZDC, ZDDL, ZDDL2 |
| `dx2:` | 12 | 13139-13274 | DX2, ZDC, ZDDL, ZDDL2 |
| `db:` | 5 | 15113-15200 | AB, AF, DB, DF |
| `zi:` | 2 | 15302-15322 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 15325-15353 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 15518-15579 | QW |
| `aw:` | 17 | 16098-16268 | AW |
| `tktj:` | 24 | 16342-16677 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 17076-17274 | C1, C2, C3 |
| `de:` | 11 | 17303-17469 | BK, DE, DE2 |
| `ge:` | 6 | 17483-17557 | GE |
| `ut:` | 10 | 17668-17770 | UT |
| `dl1:` | 1 | 18066-18080 | DL1 |
| `jm:` | 18 | 18998-19207 | BH1, BH2, BH3, BHG, JM |
| `bh:` | 85 | 19310-20030, 20299-20571, 20780-20806 | BH1, BH2, BH3, BHG |
| `dao:` | 4 | 20944-21051 | HDAO, ZDAO |
| `bk:` | 1 | 21232-21249 | BK |
| `hddl:` | 29 | 21303-21580 | BH1, BH2, BH3, BHG, HDDL |
| `cu:` | 1 | 21678-21743 | CD, CU, CY, CZ |
| `zddl:` | 25 | 22492-23101 | BDL, ZDC, ZDDL, ZDDL2 |
| `zddl2:` | 93 | 23206-24246 | BDL, ZDC, ZDDL, ZDDLD |
| `bdl:` | 13 | 24286-24543 | BDL |
