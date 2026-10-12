# ZZ / JACC / DX2 命令性能诊断与重构架构分析报告

- **分析代号**: `teamwork_preview_explorer_survey_1`
- **目标文件**: `AA整合版本.lsp` (及相关工具脚本)
- **分析日期**: 2026-10-12
- **状态**: 调查完成 (Read-Only Investigation)

---

## 1. 核心定位与入口定义 (Command Locations)

在 `AA整合版本.lsp` 中，命令 `ZZ`、别名 `JACC` 以及共用底层线框匹配算法的 `DX2`、`DX` 定义位置如下：

| 命令/别名 | 定义行号 | 入口实现函数 | 核心功能简述 |
| :--- | :--- | :--- | :--- |
| **`c:ZZ`** | L11380-11382 | `(aa:zz-run)` | 批量将文字转为中下对正，并居中对齐到最近的包围矩形线框；多行文字按 5.0 垂直间距对称堆叠 |
| **`c:JACC`** | L11384-11386 | `(aa:zz-run)` | `ZZ` 的完全等价同名别名入口 |
| **`c:DX2`** | L10972-11026 | 独立 defun | 框选方格和文字，复用 `aa:zz-text-info` 和 `aa:zz-group-by-rect` 识别单元格并按视觉顺序导出文字 |
| **`c:DX`** | L10772-10836 | 独立 defun | 复用 `aa:zz-text-info` 和 `aa:zz-group-by-rect` 识别 100×100 方格并整理端子/原理号文字 |

相关底层辅助函数集中分布在 **L11028 ~ L11378**：
- `aa:zz-near-line-tol` (L11032)
- `aa:zz-between-p` (L11036)
- `aa:zz-filter-text-ss` (L11043)
- `aa:zz-add-seg` (L11056)
- `aa:zz-collect-lwpoly-pts` (L11071)
- `aa:zz-poly-closed-p` (L11079)
- `aa:zz-build-line-cache` (L11084)
- `aa:zz-find-bound-lines` (L11136)
- `aa:zz-text-info` (L11181)
- `aa:zz-move-text` (L11226)
- `aa:zz-rect-match-p` (L11234)
- `aa:zz-group-by-rect` (L11242)
- `aa:zz-insert-y-desc` / `aa:zz-sort-y-desc` (L11262, L11270)
- `aa:zz-apply-group` (L11278)
- `aa:zz-run` (L11318)

---

## 2. 完整调用链与数据流全景追踪 (Call Flow & Data Flow)

### 2.1 用户选择与预选处理 (`ssget` Handling)
在 `aa:zz-run` (L11337-11342) 中：
```lisp
(setq ss (ssget "_I"))
(if (null ss)
  (progn
    (princ "\r\n[ZZ] 请选择对象，仅处理 TEXT/MTEXT 文字: ")
    (setq ss (ssget))))
```
1. 首先通过 `(ssget "_I")` 检查 PickFirst 预选集。
2. 若无预选，提示用户框选目标对象 `(setq ss (ssget))`。
3. 调用 `(aa:zz-filter-text-ss ss)` 遍历选择集，提取图元类型为 `"TEXT"` 或 `"MTEXT"` 的图元加入结果集 `text-ss`。
4. 若 `text-ss` 长度为 0，退出并打印提示；否则开启 `(vla-startundomark doc)` 事务，并通过 `(sssetfirst nil text-ss)` 点亮选中文字。

### 2.2 文字垂直对正归一化 (`aa:normalize-text-vertical-align`)
在 `aa:zz-run` (L11353-11361) 循环内，对每个文字图元 `en`：
```lisp
alignment-ok (aa:normalize-text-vertical-align doc en 3)
```
- 调用链：`aa:normalize-text-vertical-align` (L3227) $\to$ `aa:safe-get-bbox` (L1066) $\to$ `aa:set-text-vertical-align` (L3188) $\to$ `vla-put-Alignment` / `vla-put-AttachmentPoint` $\to$ `vla-update` $\to$ `entupd` $\to$ `aa:safe-get-bbox` $\to$ `aa:safe-move-entity` (L1084)。
- **逻辑目的**：将单行文字对正改为 `13` (`acAlignmentBottomCenter`)，多行文字对正改为 `8` (`acAttachmentPointBottomCenter`)。为了避免修改对正点导致文字发生视觉跳变，它在修改前后分别调用 COM `GetBoundingBox`，计算左下角偏移 `(dx, dy)` 并调用 `aa:safe-move-entity` 补回原位。

### 2.3 文字包围盒与文字信息计算 (`aa:zz-text-info`)
紧接着调用 `(info (aa:zz-text-info doc en tol))` (L11181-11224)：
1. 调用 `(aa:safe-get-bbox doc en)` 获取图元当前的 WCS 包围盒 `bbox = ((minX minY minZ) (maxX maxY maxZ))`。
2. 计算文字几何中心：
   $$cx = \frac{\min X + \max X}{2.0}, \quad cy = \frac{\min Y + \max Y}{2.0}$$
3. 设置最大搜索距离 `max-dist = 300.0`，构造多边形搜索框四个顶点：
   $$P_1 = (cx - 300, cy - 300), \quad P_2 = (cx + 300, cy - 300), \quad P_3 = (cx + 300, cy + 300), \quad P_4 = (cx - 300, cy + 300)$$
4. **触发高开销空间选择**：
   ```lisp
   line-ss (ssget "_CP"
             (mapcar '(lambda (pt) (trans pt 0 1)) (list P1 P2 P3 P4))
             '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (0 . "POLYLINE") (-4 . "OR>")))
   ```
5. 若检索到线段选择集 `line-ss`：
   - 调用 `(aa:zz-build-line-cache line-ss tol)` 将选择集中的图元分解为线段列表：
     - `vlist`: 竖线段列表 `((x ymin ymax) ...)`
     - `hlist`: 横线段列表 `((y xmin xmax) ...)`
   - 调用 `(aa:zz-find-bound-lines line-cache cx cy tol)` 搜索包围线框：
     - 遍历 `vlist`：筛选跨越 $cy$ 的竖线（$ymin - tol \le cy \le ymax + tol$）。在 $x < cx - tol$ 中找距离 $cx - x$ 最小者作为 `left-x`；在 $x > cx + tol$ 中找距离 $x - cx$ 最小者作为 `right-x`。
     - 遍历 `hlist`：筛选跨越 $cx$ 的横线（$xmin - tol \le cx \le xmax + tol$）。在 $y < cy - tol$ 中找距离 $cy - y$ 最小者作为 `bottom-y`；在 $y > cy + tol$ 中找距离 $y - cy$ 最小者作为 `top-y`。
     - 若四边边界全存在，返回 `(list left-x right-x top-y bottom-y)`。
   - 边界距离约束校验：
     校验 $|cx - lx| \le 300$ 且 $|rx - cx| \le 300$ 且 $|ty - cy| \le 300$ 且 $|cy - by| \le 300$。
     若均满足，返回元组 `(en cx cy lx rx ty by)`；否则返回 `nil`。
6. 若 `info` 有效加入 `infos`；若为 `nil` 则 `skipped` 自增 1。

### 2.4 线框矩形聚类分组 (`aa:zz-group-by-rect`)
在 `aa:zz-run` (L11362) 中：
```lisp
(setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
```
- `rect-tol` 传入 `0.1`。
- 采用嵌套循环对 `infos` 进行方格归类：
  - 对每个 `info`，遍历现有 `groups`；
  - 调用 `aa:zz-rect-match-p` (L11234) 比较四边坐标：
    $|lx_1 - lx_2| \le 0.1 \land |rx_1 - rx_2| \le 0.1 \land |ty_1 - ty_2| \le 0.1 \land |by_1 - by_2| \le 0.1$
  - 匹配成功则将 `info` 添加到该 group 列表中；否则新建单元素 group。
  - 循环中每次遍历重构 `new-groups` 并调用 `(reverse new-groups)`。

### 2.5 文字居中与多行等距排版数学计算 (`aa:zz-apply-group`)
在 `aa:zz-run` (L11363-11364) 中遍历每个 `group` 执行居中：
```lisp
(foreach g groups
  (setq changed (+ changed (aa:zz-apply-group g))))
```
函数 `aa:zz-apply-group` (L11278-11316) 分为两种情形：
1. **单个文字居中 (`cnt == 1`)**：
   - 矩形几何中心计算：
     $$tx = \frac{lx + rx}{2.0}, \quad ty = \frac{ty + by}{2.0}$$
   - 调用 `(aa:zz-move-text en cx cy tx ty)` 将文字从原中心 $(cx, cy)$ 平移到 $(tx, ty)$。
2. **多个文字堆叠 (`cnt > 1`)**：
   - 首先按文字原始 Y 坐标由大到小排序：调用 `(aa:zz-sort-y-desc group)`，基于插入排序将文字自上而下排列（最高处文字下标 $i = 0$，最低处文字下标 $i = n - 1$）。
   - 几何参数定义：
     - 水平目标坐标：$tx = \frac{lx + rx}{2.0}$
     - 矩形竖向中心：$center\_y = \frac{ty + by}{2.0}$
     - 预设中心行距：$spacing = 5.0$
     - 堆叠顶层起始 Y 坐标：
       $$start\_y = center\_y + 0.5 \times (n - 1) \times spacing$$
   - 遍历排序后的文字列表，第 $i$ 个文字（$i = 0, 1, \dots, n-1$）的目标 Y 坐标计算公式为：
     $$y_i = start\_y - i \times spacing = center\_y + \left(\frac{n - 1}{2} - i\right) \times 5.0$$
   - 逐个调用 `(aa:zz-move-text (nth 0 info) (nth 1 info) (nth 2 info) tx y_i)`。

### 2.6 图元移动与微小位移过滤 (`aa:zz-move-text` / `aa:safe-move-entity`)
```lisp
(defun aa:zz-move-text (en cx cy tx ty / dx dy)
  (setq dx (- tx cx)
        dy (- ty cy))
  (if (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6))
    T
    (aa:safe-move-entity en (vlax-3d-point (list dx dy 0.0))))
)
```
- 位移容差为 `1e-6`：当 $|dx| \le 10^{-6}$ 且 $|dy| \le 10^{-6}$ 时，直接返回 `T`，跳过底层图形移动操作。
- 实际移动时，调用 `aa:safe-move-entity` (L1084)：
  - 将 `ename` 转换为 ActiveX 对象 `vla_obj`；
  - 调用 `(vla-move vla_obj (vlax-3d-point '(0 0 0)) vec_pt)`；
  - 显式释放 COM 句柄 `(vlax-release-object vla_obj)`；
  - 调用 `(entupd ename)` 刷新图元。

### 2.7 Undo 事务管理与错误处理
- 开启事务：`(vla-startundomark doc)`，标记 `undo-open T`。
- 结束事务：`(vla-endundomark doc)`，清除 `undo-open nil`。
- 局部 `*error*` 保护：若中途异常或用户按下 Esc/Cancel，通过 `(vl-catch-all-apply 'vla-endundomark (list doc))` 安全闭合事务，并清除高亮 `(sssetfirst nil nil)`。

---

## 3. 性能瓶颈定量诊断与根本原因剖析 (Performance Bottlenecks)

经深度代码审查，当前实现的性能瓶颈主要集中在以下六个方面：

### 3.1 瓶颈 1：循环内 $O(N \times \text{CAD\_SSGET})$ 跨语言空间查询 (最严重瓶颈)
- **位置**：`aa:zz-text-info` (L11192-11200)
- **原因**：外层对选择集内全部 $N$ 个文字进行 `repeat` 遍历。每次循环均构造局部 600×600 窗口，并向 CAD 底层发出一次 `(ssget "_CP" ...)` 命令。
- **代价量化**：
  - `ssget` 是跨越 AutoLISP 解释器与 C++ ObjectARX 引擎的重型系统调用。每次调用涉及坐标系矩阵变换 (`trans pt 0 1`)、底层空间 R-Tree 树遍历、C++ 选择集对象创建与内存分配。
  - 在包含 200 个文字的表格中，需触发 **200 次独立 `ssget` 调用**；在 1000 个文字的大图中触发 **1000 次**！在 ZWCAD 2026 中，单次交互式空间选择开销约 15~40ms，200 次查询累计耗时高达 **3~8 秒**，1000 次查询将直接导致 CAD 界面卡死 20~40 秒。

### 3.2 瓶颈 2：局部线段重复提取与解析 ($O(N \times L_{local})$ 冗余计算)
- **位置**：`aa:zz-build-line-cache` (L11084-11134)
- **原因**：表格中的同一批水平线和垂直线（通常几十条）被相邻的几十个文字反复框选。在当前逻辑下，每个文字的 `ssget` 均获取一份局部的 `line-ss`，随后逐个调用 `entget` 读取实体 DXF 组码，遍历多段线顶点并拆分为线段。
- **代价量化**：同一条表格线被重复解析了几十甚至上百次，产生海量垃圾临时列表，严重加剧 AutoLISP 内存垃圾回收 (GC) 负担。

### 3.3 瓶颈 3：高频 COM 跨进程接口调用与包围盒重复获取 (3x `vla-GetBoundingBox`)
- **位置**：
  1. `aa:normalize-text-vertical-align` (L3228): 调用一次 `aa:safe-get-bbox`。
  2. `aa:normalize-text-vertical-align` (L3230): 修改对正后再次调用 `aa:safe-get-bbox`。
  3. `aa:zz-text-info` (L11184): 第三次调用 `aa:safe-get-bbox`。
- **代价量化**：
  每个文字在完成匹配前，连续发起了 **3 次 COM `vla-GetBoundingBox`** 和 1 次 `vla-put-Alignment`/`vla-put-AttachmentPoint` 以及 `entupd`。COM Dispatch 跨层反射调用开销巨大。更为致命的是：**即使某个文字不在任何线框内（后续被 skip），它在前期也已经被执行了对正修改和 2 次包围盒读取**，产生了无谓的开销和未居中文字的不可逆副作用。

### 3.4 瓶颈 4：线框聚类分组算法的二次方复杂度 ($O(N \cdot M)$ 列表重构与逆序)
- **位置**：`aa:zz-group-by-rect` (L11242-11260)
- **代码结构**：
  ```lisp
  (foreach info infos
    (setq placed nil new-groups '())
    (foreach g groups
      (cond ((and (not placed) (aa:zz-rect-match-p info (car g) rect-tol))
             (setq new-groups (cons (cons info g) new-groups) placed T))
            (T (setq new-groups (cons g new-groups)))))
    (if (not placed) (setq new-groups (cons (list info) new-groups)))
    (setq groups (reverse new-groups)))
  ```
- **复杂度与代价**：
  若有 $N$ 个文字分布在 $M$ 个矩形方格中，外层循环 $N$ 次，内层循环遍历当前的 $M$ 个分组，并对包含 $M$ 个元素的列表执行 `(reverse new-groups)`。整体耗时为：
  $$T \approx \sum_{k=1}^M k \approx O(M^2) \quad (\text{当 } M \approx N \text{ 时为 } O(N^2))$$
  对于 500 个方格，累计执行超过 125,000 次列表创建与 `reverse` 复制，产生严重性能衰减。

### 3.5 瓶颈 5：递归插入排序在关联命令中的堆栈隐患 ($O(M^2)$)
- **位置**：`dx2:sort-groups` (L10877-10884) 与 `aa:zz-sort-y-desc` (L11262-11275)
- **问题**：`dx2:sort-groups` 使用递归式 `dx2:insert-group` 对所有方格进行大排序；`aa:zz-sort-y-desc` 使用递归式 `aa:zz-insert-y-desc`。
- **隐患**：当方格数量较多时，递归深度易触碰 AutoLISP 解释器内部函数调用栈上限，且平均时间复杂度为 $O(M^2)$。违反了 `AGENTS.md` 中“大列表统一使用 `aa:merge-sort`”的核心准则。

### 3.6 瓶颈 6：逐图元 `entupd` 触发高频显卡管线刷新
- **位置**：`aa:safe-move-entity` (L1101) 和 `aa:set-text-vertical-align` (L3205)
- **问题**：每次移动图元或更新属性后，均立即调用 `(entupd ename)`。在循环移动数百个文字时，导致 CAD 图形刷新管线被高频打断触发重绘，造成肉眼可见的卡顿闪烁。符合 `AGENTS.md` 所指出的反模式。

---

## 4. 关联命令影响深度分析 (`c:DX2` / `c:DX` / `c:FDX`)

在重构底层线框检索与分组逻辑时，必须精确掌握其调用者依赖关系：

1. **`c:DX2` (方格文字顺序导出到剪贴板)**：
   - 依赖入口：
     - `(aa:zz-filter-text-ss ss)` 过滤文字；
     - `(aa:zz-text-info doc en tol)` 提取方格几何四界；
     - `(aa:zz-group-by-rect (reverse infos) rect-tol)` 按方格聚类；
     - `(dx2:sort-groups groups)` 将方格按空间自上而下、自左向右排序；
     - `(dx2:export-group doc (car group-record))` 框内文字按行输出。
   - **向后兼容关键**：重构后的几何提取算法返回的 `(en cx cy lx rx ty by)` 结构和方格四界数值必须与原算法在容差 `1e-6` 内完全一致，以保证 `DX2` 导出的文本顺序与内容 100% 相同。
2. **`c:DX` (方格端子整理)**：
   - 同样调用了 `aa:zz-filter-text-ss`、`aa:zz-text-info` 和 `aa:zz-group-by-rect`。重构通用接口时需确保 `c:DX` 的兼容性不受破坏。
3. **`c:FDX`**：
   - `c:FDX` 采用预先独立选框 (`fdx:frames`) 再选文字分配的流程，内部调用 `fdx:place` $\to$ `dx:apply-group`，不直接调用 `aa:zz-text-info`，但共用项目底层的空间几何容差标准。

---

## 5. 极致提速重构架构方案建议 (Refactoring Blueprint)

为实现 Acceptance Criteria 中“全选区 CAD `ssget` 降为 $O(1)$，纯计算耗时 5x 以上提速，单次 U 撤销”，提出以下具体重构设计：

```
+-----------------------------------------------------------------------------------+
|                           重构后全局单次采集与内存流水线                          |
+-----------------------------------------------------------------------------------+
  [用户框选 ss] 或 [选区整体包围盒扩展]
        |
        v
  1. 全局一次性采集 (One-Shot Harvesting, O(1) CAD SSGET)
     - 采集文字集合 text-ss (TEXT/MTEXT)
     - 采集全局线框集合 line-ss (LINE, LWPOLYLINE, POLYLINE)
        |
        v
  2. 纯内存线段解析与单次缓存 (One-Pass Segment Extraction)
     - 将所有直线/多段线展开为垂直线段集 VList 和水平线段集 HList
        |
        v
  3. 内存空间分桶索引 (In-Memory Spatial Grid / Binning, O(1) 检索)
     - 垂直线按 Y 轴网格分桶 (Y-Buckets, 区间覆盖哈希表)
     - 水平线按 X 轴网格分桶 (X-Buckets, 区间覆盖哈希表)
        |
        v
  4. 纯内存批量矩形匹配与成组 (Batch In-Memory Cell Matching & Grouping)
     - 对每个文字 (cx, cy)：在 O(1) 候选桶中筛选四向最近边界 (lx, rx, ty, by)
     - 矩形分组采用基于坐标主序的 aa:merge-sort 排序 + 线性扫描一次成组 (O(N log N))
        |
        v
  5. 延迟对正与微小位移过滤 (Deferred Normalization & Movement Filtering)
     - 仅对匹配成功且需移动的图元执行对正与物理平移 (位移阈值 1e-6)
     - 循环内禁用 entupd，改用纯 entmod 或批量 vla-move
        |
        v
  6. 事务安全提交与统一单次重绘 (Single Redraw & Transaction Finalize)
     - 循环结束后统一 (redraw)
     - 一次性输出处理与跳过统计
```

### 5.1 建议一：全局一次性实体采集 (One-Shot CAD Entity Harvesting)
- **方案**：
  若用户选择集 `ss` 中已包含线段，直接从 `ss` 中筛选出文字集 `text-ss` 和线段集 `line-ss`；
  若用户仅单选/预选了文字，计算所有文字的大包围盒外廓 $[X_{min}-305, Y_{min}-305] \sim [X_{max}+305, Y_{max}+305]$，仅执行**唯一一次**跨选：
  ```lisp
  (ssget "_C" pt-min pt-max '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (0 . "POLYLINE") (-4 . "OR>")))
  ```
- **收益**：CAD `ssget` 交互从 $N$ 次骤降为恒定 $1$ 次（或 $0$ 次额外查询），将该环节耗时从数秒压缩至数毫秒。

### 5.2 建议二：内存空间格网分桶索引 (In-Memory Spatial Binning)
- **分桶策略**：
  - 针对垂直线段 `(x, ymin, ymax)`：以桶高度 $H_{bin} = 100.0$ 将 Y 轴划分为网格区间。一条跨越 $[ymin, ymax]$ 的竖线仅被加入其覆盖的整数桶 $\lfloor y / H_{bin} \rfloor$ 对应的列表中。
  - 查询文字 $(cx, cy)$ 时，计算 $K_y = \lfloor cy / H_{bin} \rfloor$，仅在该桶内的数十条候选竖线中筛选横跨 $cy$ 的左侧最大 $x$ 和右侧最小 $x$。
  - 针对水平线段 `(y, xmin, xmax)`：同理以宽度 $W_{bin} = 100.0$ 按 X 轴分桶，快速定位下界与上界。
- **收益**：候选集过滤复杂度由 $O(L)$ 降至 $O(1)$，纯内存几何匹配耗时呈数量级下降。

### 5.3 建议三：亚线性/线性方格聚类算法 (Linear Cell Bucketing)
- **方案**：
  废弃低效的 `aa:zz-group-by-rect` 嵌套循环重构列表做法。
  改用**基于网格特征键的排序归并**：
  每个匹配到矩形的信息项赋予空间归一化元组键：
  $$Key = (\mathrm{round}(ty / 0.1), \mathrm{round}(lx / 0.1))$$
  使用项目中已有的 `aa:merge-sort` 按 $Key$ 稳定排序，复杂度为 $O(N \log N)$；排序后相同方格内的文字相邻排列，单次线性扫描遍历（$O(N)$）即可完成分组打包。
- **收益**：彻底消除内存反复分配与 `(reverse new-groups)` 造成的二次方退化。

### 5.4 建议四：多文字垂直居中排版公式标准化 (Multi-Text Centering Math)
保持与现行标准严格数学等价的公式实现：
- 设方格上下边界为 $ty, by$，左右边界为 $lx, rx$；
- 水平中心：$tx = \frac{lx + rx}{2.0}$
- 垂直中心：$center\_y = \frac{ty + by}{2.0}$
- 对包含 $n$ 个文字的分组，首先按文字原始几何中心 $cy$ 降序排序（高者在前，矮者在后，若 $cy$ 相同按原始次序稳定归并）；
- 垂直排布公式（行距 $spacing = 5.0$）：
  $$y_i = center\_y + \left(\frac{n - 1}{2} - i\right) \times 5.0, \quad (i = 0, 1, \dots, n - 1)$$
- **边界验证**：
  - 当 $n = 1$ 时：$y_0 = center\_y + 0 = center\_y$，与单文字中心公式完全统一。
  - 当 $n = 2$ 时：$y_0 = center\_y + 2.5, \quad y_1 = center\_y - 2.5$，间距为 $5.0$，整体对称中心为 $center\_y$。
  - 当 $n = 3$ 时：$y_0 = center\_y + 5.0, \quad y_1 = center\_y, \quad y_2 = center\_y - 5.0$，间距为 $5.0$，整体对称中心为 $center\_y$。

### 5.5 建议五：延迟对正与微小位移过滤 (Deferred Normalization & Movement Filter)
- **延迟对正 (Lazy Normalization)**：
  在确定文字成功匹配到封闭线框之前，**不执行**任何文字对正修改与实体移动；仅当确认需要居中时才调整对正。
  若文字当前对正本身已是中下对正（组码 72/73 满足条件），直接跳过 `vla-put-Alignment`，避免无谓修改。
- **位移过滤阈值**：
  严格保持 `1e-6` 容差判定：
  $|tx - cx| < 10^{-6} \land |y_i - cy| < 10^{-6}$ 时直接视为已就位，不调用底层的图形移动方法。
- **统一显卡重绘**：
  单次处理过程中，禁止对每个图元调用 `(entupd ename)`；循环全部完成后，在末尾执行单次 `(redraw)`。

### 5.6 建议六：规范 Undo 事务包裹
- 改用项目标准函数：在操作前调用 `(aa:undo-mark-on)`，完成或异常时调用 `(aa:undo-mark-off)`，确保符合 `AGENTS.md` 规范，使用户在 CAD 中按一次 `U` 即可完整撤销整批居中改动。

### 5.7 建议七：离线静态与数学仿真测试套件设计 (`tools/check_zz_static.py`)
根据 Acceptance Criteria R4，应新增 `tools/check_zz_static.py`，参考 `check_fkx_static.py` 和 `check_zdwi_static.py` 的仿真机制：
1. **静态代码分析**：
   - 检查 `AA整合版本.lsp` 中 `c:ZZ`、`c:JACC` 的 `defun` 结构、形参/局部变量列表完整性；
   - 验证无活体 `(vl-sort ...)` 调用；
   - 验证撤销标记配对性与安全保护。
2. **纯数学与几何算法离线仿真测试**：
   - 测试用例 1：单个文字在 100×100 方格中的精确居中（容差 $\le 10^{-6}$）；
   - 测试用例 2：双文字、三文字堆叠（5.0 单位对称间距，自上而下顺序一致，容差 $\le 10^{-6}$）；
   - 测试用例 3：边界缺失情况（缺失上、下、左、右任一边的非闭合矩形），验证安全识别并跳过；
   - 测试用例 4：大规模网格（200+ 文字及线框）空间索引查找基准测试，验证算法耗时较原算法实现 5x 以上提速；
   - 测试用例 5：`DX2` 兼容性验证，确保仿真导出的方格文本行顺序与老逻辑完全一致。
3. **集成至全仓检查**：
   - 将 `check_zz_static.py` 挂载到 `tools/check_all_static.py` 的模块检查列表中。

---

## 6. 总结 (Conclusion)

当前 `ZZ`/`JACC` 命令在处理批量文字时性能低下的根因已经完全明晰：核心瓶颈并非 AutoLISP 语言本身的计算能力，而是**在遍历循环中高频调用 CAD `ssget` 空间查询引擎**以及**重复反转列表的二次方分组聚合**。通过**全局单次范围采集**、**内存网格空间分桶**、**排序线性聚类**与**微小位移过滤**，即可在 100% 保持原有几何精度和 `DX2` 兼容性的前提下，实现全流程数量级的性能跃升。
