# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，24177 行，1011 个函数，其中 168 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 327-376 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:699, aa:ys-line:250, aa:ys-ring:319, aa:ys-rim:308, aa:ys-snowflake:276, aa:ys-detail:301, aa:cmd-end:712 |
| `YS1` | 505-531 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:699, aa:ys-line:250, aa:ys1-t:405, aa:ys1-g:422, aa:ys1-o:442, aa:ys1-d:479, aa:cmd-end:712 |
| `DES` | 565-630 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:699, des:key-less-p:534, aa:merge-sort:787, des:record-less-p:539, des:x-less-p:543, des:overlap-p:549, aa:cmd-end:712 |
| `YSTEMP` | 643-697 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:699, aa:merge-sort:787, ystemp:y-less-p:633, ystemp:pair-p:637, aa:cmd-end:712 |
| `ZTF` | 1047-1060 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:699, ztf:collect-font-records:917, ztf:run-dialog:1017, aa:cmd-end:712 |
| `YSDL` | 1583-1784 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:738, aa:undo-mark-on:730, aa:ysdl-get-plain-text:1364, aa:ysdl-get-lwpoly-rect:1418, aa:ysdl-sort-boxes:1485, aa:ysdl-desktop-dir:1561, aa:merge-sort:787, aa:ysdl-parse-rows-from-text-data:1513, aa:ysdl-clean-text:1388, aa:ysdl-format-categorized-row:1553, aa:ysdl-build-csv-field:1379, aa:ysdl-reorder-row:1396 …共 13 个 |
| `Q` | 1796-1822 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `T` | 1996-2000 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:699, txt:run:1981, aa:cmd-end:712 |
| `T2` | 2494-2513 | 20 | 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。 | aa:cmd-begin:699, txt2:process-selection:2420, aa:cmd-end:712 |
| `ABCN` | 2529-2580 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:699, aa:safe-get-bbox:1095, aa:safe-move-entity:1141, aa:cmd-end:712 |
| `H` | 2582-2709 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:699, aa:normalize-text-horizontal-align:3477, aa:merge-sort:787, aa:cmd-end:712 |
| `H2` | 2716-2840 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:699, aa:normalize-text-horizontal-align:3477, aa:merge-sort:787, aa:cmd-end:712 |
| `Y` | 2866-2870 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `DZ` | 2910-2944 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:699, aa:ysdl-get-plain-text:1364, aa:dz-number-p:2876, aa:dz-color-text:2892, aa:cmd-end:712 |
| `YY` | 2950-2954 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `RR` | 2960-2964 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `WW` | 2970-2974 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `WWW` | 2980-2986 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:699, aa:deep-color-cmd:3305, aa:cmd-end:712 |
| `XU` | 2992-3066 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3072-3076 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `PP` | 3082-3086 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `HH` | 3092-3096 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:699, aa:color-cmd:2847, aa:cmd-end:712 |
| `HUI` | 3362-3367 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:699, aa:deep-color-cmd:3305, aa:cmd-end:712 |
| `ZHONG` | 3421-3425 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3370, aa:find-ref-by-top-bbox:1187, aa:bbox-center-x:1119, aa:normalize-text-horizontal-align:3477, aa:align-text-horizontal-by-bbox:1227 |
| `ZUO` | 3506-3510 | 5 | 将选中文字统一为左中对正，并以最上方文字为基准左对齐。 | aa:align-text-cmd:3370, aa:find-ref-by-top-bbox:1187, aa:bbox-left-x:1125, aa:normalize-text-horizontal-align:3477, aa:align-text-horizontal-by-bbox:1227 |
| `AZUO` | 3516-3635 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:699, aa:cmd-end:712, aa:safe-get-bbox:1095, aa:bbox-left-x:1125, aa:safe-move-entity:1141 |
| `HP` | 3641-3778 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:699, aa:cmd-end:712, aa:safe-get-bbox:1095, aa:bbox-left-x:1125, aa:bbox-top-y:1133, aa:merge-sort:787, aa:bbox-right-x:1129, aa:safe-move-entity:1141 |
| `HP2` | 3784-3927 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:699, aa:cmd-end:712, aa:normalize-text-horizontal-align:3477, aa:safe-get-bbox:1095, aa:bbox-center-x:1119, aa:bbox-top-y:1133, aa:bbox-bottom-y:1137, aa:merge-sort:787, aa:safe-move-entity:1141 |
| `YOU` | 3930-3934 | 5 | 将选中文字统一为右中对正，并以最上方文字为基准右对齐。 | aa:align-text-cmd:3370, aa:find-ref-by-top-bbox:1187, aa:bbox-right-x:1129, aa:normalize-text-horizontal-align:3477, aa:align-text-horizontal-by-bbox:1227 |
| `AYOU` | 3939-4058 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:699, aa:cmd-end:712, aa:safe-get-bbox:1095, aa:bbox-right-x:1129, aa:safe-move-entity:1141 |
| `SHANG` | 4061-4065 | 5 | 将选中文字统一为中上对正，并以最上方文字为基准上对齐。 | aa:align-text-cmd:3370, aa:find-ref-by-top-bbox:1187, aa:bbox-top-y:1133, aa:normalize-text-vertical-align:3491, aa:align-text-vertical-by-bbox:1241 |
| `ASHANG` | 4071-4190 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:699, aa:cmd-end:712, aa:safe-get-bbox:1095, aa:bbox-top-y:1133, aa:safe-move-entity:1141 |
| `XIA` | 4193-4197 | 5 | 将选中文字统一为中下对正，并以最下方文字为基准下对齐。 | aa:align-text-cmd:3370, aa:find-ref-by-bottom-bbox:1207, aa:bbox-bottom-y:1137, aa:normalize-text-vertical-align:3491, aa:align-text-vertical-by-bbox:1241 |
| `AXIA` | 4202-4321 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:699, aa:cmd-end:712, aa:safe-get-bbox:1095, aa:bbox-bottom-y:1137, aa:safe-move-entity:1141 |
| `HE` | 4323-4416 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:699, aa:insert-sort:759, aa:cmd-end:712 |
| `QR` | 4451-4496 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:699, qr:last-height:4427, qr:height-str:4446, qr:save-height:4439, aa:cmd-end:712 |
| `QR2` | 4502-4532 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:699, qr:last-height:4427, qr:height-str:4446, qr:save-height:4439, aa:cmd-end:712 |
| `DEA` | 4538-4561 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `DEK` | 4568-4588 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `DEH` | 4631-4661 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:699, aa:has-chinese:4609, aa:ysdl-get-plain-text:1364, aa:layer-locked-p:4594, aa:cmd-end:712 |
| `DET` | 4691-4732 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:699, det:split-values:4671, aa:ysdl-get-raw-text:1279, aa:layer-locked-p:4594, aa:cmd-end:712 |
| `A2T` | 4771-4808 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:699, a2t:pick-string:4749, a2t:layer-locked-p:4744, a2t:text-dxf:4761, aa:cmd-end:712 |
| `WI` | 4814-4854 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `ATW` | 4861-4945 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:699, aa:safe-get-bbox:1095, aa:bbox-right-x:1129, aa:bbox-left-x:1125, aa:safe-move-entity:1141, aa:cmd-end:712 |
| `XB` | 4951-5004 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `YAN` | 5010-5126 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:759 |
| `LL` | 5137-5166 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5292, aa:undo-mark-off:738, aa:undo-mark-on:730 |
| `MM` | 5315-5347 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5292, aa:undo-mark-off:738, aa:undo-mark-on:730, aa:ortho-report:5281, aa:ortho-drag:5241 |
| `SS` | 5353-5385 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5292, aa:undo-mark-off:738, aa:undo-mark-on:730, aa:ortho-report:5281, aa:ortho-drag:5241 |
| `SW` | 5474-5529 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:699, aa:cmd-error:228, aa:ss-format-vec:5393, aa:ss-do-interactive-stretch:5439, aa:cmd-end:712 |
| `SYI` | 5639-5639 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5572 |
| `XYI` | 5640-5640 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5572 |
| `SSS` | 5732-5803 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:5694, aa:sss-lowest-row-line:5720, aa:sss-find-pair:5667, aa:sss-horizontal-segments:5646, aa:cmd-begin:699, aa:cmd-end:712 |
| `SYAN` | 5846-5846 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:5806 |
| `XYAN` | 5849-5849 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:5806 |
| `SJ` | 5863-5889 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `XJ` | 5891-5917 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `SYJ` | 5960-5960 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:5918 |
| `XYJ` | 5961-5961 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:5918 |
| `GTX` | 6091-6271 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:738, aa:undo-mark-on:730, aa:gtx-select-prefix-text:6075, aa:ysdl-get-plain-text:1364, aa:try-get-bbox:1084, aa:merge-sort:787, aa:gtx-rows:6034, aa:gtx-key:6003, aa:gtx-find-last-char:5991, aa:gtx-natural-less:6011, aa:gtx-create-text-entity:6051 |
| `GTY` | 6514-6661 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:6505, aa:gty-get-text-width:6342, aa:gty-separated-rows:6377, aa:gty-add-row:6411, aa:merge-sort:787, aa:gty-get-item-x:6310, aa:gty-order-rows:6461, aa:gty-column-widths:6473, aa:gty-row-tree:6423, aa:gty-build-sort-key:6318, aa:gty-tree-item:6434, aa:gty-copy-text:6485 …共 14 个 |
| `GTZ` | 6667-6824 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6342, aa:merge-sort:787, aa:gty-move-entity:6364 |
| `HWD` | 6851-6924 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:699, aa:safe-get-bbox:1095, aa:gty-get-text-width:6342, aa:merge-sort:787, aa:hwd-rows:6830, aa:hwd-make-text:6837, aa:cmd-end:712 |
| `BIAN` | 6980-7010 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:699, bian-draw-one:6952, aa:cmd-end:712 |
| `LAN` | 7050-7198 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:699, lan-vert-mode:7021, lan-get-option:7035, aa:cmd-end:712 |
| `XIN` | 7205-7279 | 75 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `XY` | 8151-8165 | 15 | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | aa:cmd-begin:699, xy:run-xin:7574, xy:run-yuan:7969, aa:cmd-end:712 |
| `XYG` | 8565-8760 | 196 | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | aa:cmd-begin:699, aa:cmd-end:712, xy:filter-green-hlines:8131, xyg:dedup-hlines:8346, xy:ss->list:7324, xyg:find-prefix-text:8172, aa:ysdl-get-plain-text:1364, aa:gtx-select-prefix-text:6075, aa:link-xdata:8770, xy:run-xin:7574, xy:run-yuan:7969, xyg:sort-lines-desc:8387 …共 22 个 |
| `SX0` | 9026-9065 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:699, aa:link-dwg-id:8787, aa:link-info:8775, aa:link-root-p:8783, aa:cmd-end:712 |
| `YSSX0` | 9072-9112 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:699, aa:link-dwg-id:8787, aa:link-info:8775, aa:link-root-p:8783, aa:cmd-end:712 |
| `SX` | 9119-9152 | 34 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:699, aa:link-dwg-id:8787, aa:link-info:8775, aa:link-root-p:8783, aa:cmd-end:712 |
| `SX1` | 9178-9246 | 69 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:699, aa:link-clock:9154, aa:link-dwg-id:8787, aa:link-info:8775, aa:link-root-p:8783, aa:link-root-ed:9159, aa:link-text-for:8805, aa:link-file-path:8837, aa:link-export:8876, aa:cmd-end:712 |
| `SX2` | 9254-9319 | 66 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:699, aa:link-dwg-id:8787, aa:link-info:8775, aa:link-ask-folder:9008, aa:link-collect-files:8942, aa:merge-sort:787, aa:link-file-time:8933, aa:link-read-file:8921, aa:link-uid<:8827, aa:link-count-conflicts:8970, aa:link-join:8958, aa:link-text-from-rec:8817 …共 13 个 |
| `HBDL` | 9626-9731 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:699, aa:cmd-end:712, aa:ysdl-get-plain-text:1364, hb:cluster-rows:9396, hb:parse-row:9425, hb:apply-merge-in-place:9541 |
| `NU` | 10027-10078 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:9976, aa:num-int-target-p:9957 |
| `KAI` | 10269-10352 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:10208, aa:kai-process-text:10226 |
| `ZHENG` | 10423-10553 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:10361, aa:safe-get-bbox:1095, aa:zheng-align-text-to-rect-center:10410, aa:zheng-line-mid-x:10376, aa:zheng-add-texts-after-explode:10383, aa:zheng-align-text-center-x:10401 |
| `AAE` | 10970-11055 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:699, aae:split-lines:10924, aae:locate-dcl:11057, aae:resolve-val:10953, aa:cmd-end:712 |
| `HAO` | 11074-11078 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:699, fillframes-run:10778, aa:cmd-end:712 |
| `HAO2` | 11320-11477 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:699, blk-insertpt:10599, hao2:block-name:11091, hao2:sort-blocks:11105, zdml2:collect-all-texts:11153, hao2:format-num:11084, hao2:find-existing-text-fast:11287, tktj:current-space:15962, tktj:ensure-text-style:15972, aa:cmd-end:712 |
| `MING` | 11622-11786 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:699, ming:find-title-attrib:11486, blk-insertpt:10599, ming:get-block-height:11523, ming:get-text-info:11539, ming:cluster-and-sort:11571, aa:cmd-end:712 |
| `FIVE` | 11795-11836 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `JZ` | 11856-11998 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1095, aa:jz-line-center-y:11844, aa:bbox-center-x:1119, aa:bbox-top-y:1133, aa:bbox-bottom-y:1137, aa:safe-move-entity:1141 |
| `FKX` | 12168-12239 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:699, fdx:poly-rect:12028, fdx:add-rect:12242, fkx:choose-frame:12063, fdx:rect-from-points:12006, fkx:collect:12100, fkx:title-rect:12130, fkx:point-in-p:12054, fkx:filter:12157, aa:cmd-end:712 |
| `FDX` | 12422-12460 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:12318, aa:undo-mark-off:738, fdx:frames:12280, fdx:sort-frames:12299, fdx:show-frame:12311, aa:undo-mark-on:730, fdx:place:12346 |
| `DX` | 12671-12740 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:738, aa:zz-filter-text-ss:12960, aa:zz-harvest-lines:13078, aa:zz-build-spatial-index:13103, aa:zz-text-info:13169, aa:zz-group-by-rect:13220, aa:undo-mark-on:730, dx:apply-group:12582 |
| `DX2` | 12884-12943 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:699, aa:zz-filter-text-ss:12960, aa:zz-harvest-lines:13078, aa:zz-build-spatial-index:13103, aa:zz-text-info:13169, aa:zz-group-by-rect:13220, dx2:sort-groups:12781, dx2:export-group:12869, zi:to-clip:14915, aa:cmd-end:712 |
| `ZZ` | 13366-13368 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:13314 |
| `ZZ2` | 13489-13585 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:13476, aa:safe-get-bbox:1095, aa:zz2-frame:13456, aa:zz-build-spatial-index:13103, aa:zz-text-info:13169, aa:zz-group-by-rect:13220, aa:zz2-plan:13371, aa:zz2-plan-ok:13380, aa:cmd-begin:699, aa:zz2-map-edge:13411, aa:bbox-top-y:1133, aa:bbox-bottom-y:1137 …共 16 个 |
| `JACC` | 13588-13590 | 3 | ZZ 的同功能入口。 | aa:zz-run:13314 |
| `MJ` | 13733-13820 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:13593, aa:mj-collect-text-data:13612, aa:mj-horizontal-ys:13640, aa:mj-scale-line-x:13713, aa:mj-move-cached-texts:13723 |
| `FIVE2` | 13884-13991 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1084, aa:tbhb-segment:13996, aa:tbhb-merge-segments:14014, aa:hg5-rows:13826, aa:tbhb-border-p:14006, aa:hg5-side-p:13853, aa:hg5-text-y:13875, aa:cmd-begin:699, aa:hg5-point:13871, aa:hg5-y:13838, aa:cmd-end:712 |
| `HBBG` | 14191-14279 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:738, aa:tbhb-collect:14143, aa:tbhb-boxes:14035, aa:tbhb-groups:14108, aa:tbhb-group-problem:14083, aa:merge-sort:787, aa:tbhb-before-p:14055, aa:tbhb-item-inside-p:14067, aa:undo-mark-on:730, aa:tbhb-offset:14119, aa:tbhb-shift-point:14125, aa:tbhb-seen-line-p:14129 …共 14 个 |
| `HZBG` | 14347-14411 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1095, aa:hzbg-plan:14296, aa:cmd-begin:699, aa:hzbg-move:14326, aa:hzbg-line:14339, aa:cmd-end:712 |
| `ZDWI` | 14601-14705 | 105 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:14462, aa:zdwi-vertices:14537, aa:zdwi-unique:14520, aa:zdwi-add-span:14525, aa:merge-sort:787, aa:safe-get-bbox:1095, aa:zdwi-column:14550, aa:zdwi-set-nth:14559, aa:cmd-begin:699, aa:zdwi-map-entity:14576, aa:zz-move-text:13188, aa:zz-center-texts:13295 …共 13 个 |
| `FF` | 14830-14871 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:699, aa:ysdl-get-raw-text:1279, aa:str-replace-all:1256, aa:ff-text-data:14811, aa:cmd-end:712 |
| `DB` | 14874-14878 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:699, db:del:14741, aa:cmd-end:712 |
| `DF` | 14880-14884 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:699, db:del:14741, aa:cmd-end:712 |
| `AB` | 14886-14890 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:699, db:add:14774, aa:cmd-end:712 |
| `AF` | 14892-14896 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:699, db:add:14774, aa:cmd-end:712 |
| `QE` | 14964-15045 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:14933, qe:zhi-prefix:14954 |
| `CC` | 15048-15122 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:699, aa:cmd-error:228, qe:get-clip-text:14933, aa:cmd-end:712 |
| `QW` | 15191-15227 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:699, aa:ysdl-get-plain-text:1364, zi:pt:14910, qw:join:15126, zi:to-clip:14915, aa:cmd-end:712 |
| `QW2` | 15233-15294 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:699, aa:ysdl-get-plain-text:1364, zi:pt:14910, aa:merge-sort:787, zi:to-clip:14915, aa:cmd-end:712 |
| `QW3` | 15518-15556 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:699, aa:qw3-record:15491, aa:merge-sort:787, zi:to-clip:14915, aa:cmd-end:712 |
| `DX1` | 15560-15630 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:699, zi:pt:14910, dx:color-kind:12487, aa:merge-sort:787, zi:to-clip:14915, aa:cmd-end:712 |
| `CE` | 15661-15691 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:699, ce-redraw:15645, aa:cmd-end:712 |
| `AW` | 15878-15920 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:15870, aw:process-one:15844 |
| `ZDML` | 16288-16366 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:699, tktj:safe-vla-object:15990, tktj:collect-one-block:16114, tktj:sort-by-page:16231, tktj:sort-by-position:16242, tktj:take:16186, tktj:draw-table:16203, tktj:drop:16195, aa:cmd-end:712 |
| `ZDML2` | 16430-16601 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:699, blk-insertpt:10599, hao2:block-name:11091, hao2:sort-blocks:11105, zdml2:collect-all-texts:11153, zdml2:build-spatial-index:11201, zdml2:extract-rect-text-fast:16372, zdml2:query-rect-index:11254, tktj:take:16186, tktj:draw-table:16203, tktj:drop:16195, aa:cmd-end:712 |
| `ZDMLDEBUG` | 16604-16638 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:699, tktj:get-attributes:16063, aa:cmd-end:712 |
| `DUMP` | 16642-16666 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `C1` | 16884-16886 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16816 |
| `C2` | 16888-16890 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16816 |
| `C3` | 16892-16894 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:16816 |
| `DE` | 17079-17079 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:17034 |
| `DE2` | 17080-17080 | 1 | 用最右侧括号内容替换括号前连续数字（数字带相同尾缀时一并替换）。 | de:run:17034 |
| `GE` | 17167-17269 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:17091, ge:get-item:17105, ge:sort-items:17142, ge:make-line:17149 |
| `UT` | 17380-17492 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:738, ut:horizontal-line-p:17297, ut:get-bbox:17319, ut:line-y:17312, ut:sort-desc:17356, aa:undo-mark-on:730, aa:normalize-text-horizontal-align:3477, ut:bbox-bottom:17336, ut:bbox-left:17332, ut:move:17364 |
| `0` | 17503-17537 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `9` | 17586-17595 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:699, aa:rotate-90-run:17544, aa:cmd-end:712 |
| `99` | 17598-17607 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:699, aa:rotate-90-run:17544, aa:cmd-end:712 |
| `QZ` | 17614-17662 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 17690-17707 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:699, dl1:make-layer:17674, aa:cmd-end:712 |
| `REP` | 17731-17825 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:699, rep-trim:17721, aa:cmd-end:712 |
| `KMZ` | 18118-18120 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `KMY` | 18124-18126 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `LNZ` | 18130-18132 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `LNY` | 18136-18138 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `UPSZ` | 18142-18144 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `UPSY` | 18148-18150 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `BZ` | 18154-18156 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `BY` | 18160-18162 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `ZJ` | 18194-18196 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18169 |
| `YJ` | 18200-18202 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:18169 |
| `YDZ` | 18404-18406 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18210 |
| `YDY` | 18410-18412 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:18210 |
| `LBZ` | 18416-18418 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18210 |
| `LBY` | 18422-18424 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:18210 |
| `485Z` | 18428-18430 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `485Y` | 18434-18436 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:17910 |
| `XX` | 18447-18475 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `JM` | 18818-18893 | 76 | 按绿色电缆线所连原理号，把 ZDDL 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:699, aa:rep-begin:18487, xyg:dedup-hlines:8346, xy:ss->list:7324, xy:filter-green-hlines:8131, xy:collect-vlines:7539, xy:build-vline-buckets:7468, xy:build-text-meta-list:7757, xy:collect-texts:7555, xy:hline-info-ed:7392, jm:find-spec-text:18792, aa:ysdl-get-plain-text:1364 …共 24 个 |
| `BH2` | 19641-19799 | 159 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:699, aa:rep-begin:18487, aa:link-clock:9154, bh:prepare:19168, bh:record-path:19007, bh:now:19011, bh:read-records:19038, bh:rec-key:18946, bh:kmap:18957, bh:nmap:18970, bh:split-map:19626, bh:resolve-neighbors:19356 …共 31 个 |
| `BHG` | 19802-19902 | 101 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:699, aa:rep-begin:18487, aa:link-clock:9154, bh:prepare:19168, bh:record-path:19007, bh:now:19011, bh:read-records:19038, bh:rec-key:18946, bh:kmap:18957, bh:nmap:18970, bh:clean:18926, hddl:color:20965 …共 24 个 |
| `BH1` | 20182-20387 | 206 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:699, bh:pick-start:20084, bh:ask-prefix:19242, bh:ask-start:19252, bh:record-path:19007, bh:read-records:19038, bh:rec-key:18946, bh:kmap:18957, bh:nmap:18970, bh:own-records:20041, bh:write-records:19058, bh:clean:18926 …共 39 个 |
| `BH3` | 20417-20542 | 126 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:699, aa:rep-begin:18487, hddl:text:20962, hddl:point:20980, aa:merge-sort:787, hddl:sort-rows:21044, hddl:rows:21034, hddl:coord:20974, bh:record-path:19007, bh:now:19011, bh:read-records:19038, bh:rec-key:18946 …共 29 个 |
| `ZDAO` | 20662-20666 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:699, dao:run:20600, aa:cmd-end:712 |
| `HDAO` | 20669-20673 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:699, dao:run:20600, aa:cmd-end:712 |
| `QH` | 20678-20829 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:787 |
| `BK` | 20859-20902 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:17028, de:get-text:17012, bk:extract-inner:20840, de:set-text:17021 |
| `HDDL` | 21190-21280 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:738, aa:undo-mark-on:730, hddl:ensure-layer:20911, hddl:clear-markers:20951, hddl:text:20962, hddl:point:20980, hddl:sort-rows:21044, hddl:rows:21034, hddl:group-rows:21049, hddl:mirror-p:21184, hddl:cell:21094, hddl:tail-count:21100 …共 20 个 |
| `CU` | 21354-21355 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:21286 |
| `CD` | 21358-21359 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:21286 |
| `CZ` | 21362-21363 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:21286 |
| `CY` | 21366-21367 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:21286 |
| `HS` | 21420-21592 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:699, aa:hs-filter-unlocked:21374, aa:cmd-end:712, aa:hs-get-ss-bbox:21394 |
| `ZS` | 21601-21773 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:699, aa:hs-filter-unlocked:21374, aa:cmd-end:712, aa:hs-get-ss-bbox:21394 |
| `SC3` | 21805-21872 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:699, aa:sc3-layer-locked-p:21779, aa:sc3-entity-bbox:21787, aa:cmd-end:712 |
| `Z0` | 21939-21982 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:699, aa:z0-layer-locked-p:21878, aa:z0-data-flat-p:21896, aa:z0-polyline-flat-p:21929, aa:z0-one:21909, aa:z0-polyline-verts:21921, aa:cmd-end:712 |
| `VPO1` | 21988-21993 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `VPO2` | 21996-22001 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:699, aa:cmd-end:712 |
| `TONG` | 22007-22091 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:699, aa:cmd-end:712, aa:merge-sort:787, aa:gtx-natural-less:6011 |
| `ZDDL2` | 22711-22802 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:699, aa:cmd-end:712, zddl:parse-strip:22260, zddl:parse-wiring-ss:22463, zddl:ensure-layer:22523, zddl:plan-cables:22600, zddl:lookup-terminal:22192, zddl:label-layout:22625, zddl:draw-one-cable:22632, zddl:format-cable-no:22590 |
| `ZDC` | 22804-22806 | 3 | ZDDL 命令的简写别名。 | c:zddl:24169 |
| `ZDDLD` | 23860-23888 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:699, zddl2:xdata-app:23843, aa:layer-locked-p:4594, zddl2:set-layer-lock:23846, aa:cmd-end:712 |
| `BDL` | 24157-24163 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行。 | aa:cmd-begin:699, bdl:work:24026, aa:cmd-end:712 |
| `ZDDL` | 24169-24176 | 8 | 两次选择文字并指定插入点，按网页规则生成端子排与电缆。 | aa:cmd-begin:699, zddl2:work:23768, aa:cmd-end:712 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 289 | 228-325, 379-502, 699-811, 1062-1576, 2847-2908, 3102-3503 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 156 个 |
| `des:` | 5 | 534-562 | DES |
| `ystemp:` | 2 | 633-640 | YSTEMP |
| `ztf:` | 13 | 813-1045 | ZTF |
| `txt:` | 6 | 1831-1994 | T, T2 |
| `txt2:` | 14 | 2007-2492 | T2 |
| `qr:` | 3 | 4427-4449 | QR, QR2 |
| `det:` | 1 | 4671-4689 | DET |
| `a2t:` | 3 | 4744-4769 | A2T |
| `(无前缀):` | 22 | 6926-6978, 7021-7048, 10575-10846, 15645-15658, 17721-17729 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 39 | 7311-8146 | BH1, BH2, BHG, JM, XY, XYG |
| `xyg:` | 15 | 8172-8563 | BH1, BH2, BHG, JM, XYG |
| `hb:` | 9 | 9327-9624 | HBDL |
| `aae:` | 4 | 10849-10968, 11057-11072 | AAE, HAO2, MING, ZDC, ZDDL, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 11084-11151, 11287-11318 | HAO2, ZDML2 |
| `zdml2:` | 4 | 11153-11284, 16372-16428 | HAO2, ZDML2 |
| `ming:` | 4 | 11486-11620 | MING |
| `fdx:` | 11 | 12006-12048, 12242-12420 | FDX, FKX |
| `fkx:` | 10 | 12054-12164 | FKX |
| `dx:` | 12 | 12463-12669 | DX, DX1, DX2, FDX, ZDC, ZDDL, ZDDL2 |
| `dx2:` | 12 | 12747-12882 | DX2, ZDC, ZDDL, ZDDL2 |
| `db:` | 5 | 14721-14808 | AB, AF, DB, DF |
| `zi:` | 2 | 14910-14930 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 14933-14961 | AB, AF, CC, QE, YJ, ZJ |
| `qw:` | 1 | 15126-15187 | QW |
| `aw:` | 17 | 15706-15876 | AW |
| `tktj:` | 24 | 15950-16285 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 16684-16882 | C1, C2, C3 |
| `de:` | 11 | 16911-17077 | BK, DE, DE2 |
| `ge:` | 6 | 17091-17165 | GE |
| `ut:` | 10 | 17276-17378 | UT |
| `dl1:` | 1 | 17674-17688 | DL1 |
| `jm:` | 18 | 18606-18815 | BH1, BH2, BH3, BHG, JM |
| `bh:` | 85 | 18918-19638, 19907-20179, 20388-20414 | BH1, BH2, BH3, BHG |
| `dao:` | 4 | 20552-20659 | HDAO, ZDAO |
| `bk:` | 1 | 20840-20857 | BK |
| `hddl:` | 29 | 20911-21188 | BH1, BH2, BH3, BHG, HDDL |
| `cu:` | 1 | 21286-21351 | CD, CU, CY, CZ |
| `zddl:` | 25 | 22100-22709 | BDL, ZDC, ZDDL, ZDDL2 |
| `zddl2:` | 93 | 22814-23854 | BDL, ZDC, ZDDL, ZDDLD |
| `bdl:` | 13 | 23894-24151 | BDL |
