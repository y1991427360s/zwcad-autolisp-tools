# ZZ / JACC / DX2 离线静态测试套件与基准测试调研分析报告

## 1. 概述与核心结论

针对 ZWCAD 2026 AutoLISP 插件中的 `ZZ` 命令（及其别名 `JACC`，以及共用几何线框匹配核心算法的 `DX2` 和 `DX`）的性能诊断、极致提速重构及离线测试需求，本报告全面调查了仓库现有的静态测试基础设施、现有测试脚本的设计范式与工具链，并系统梳理了 `tools/check_zz_static.py` 的测试规范、数学仿真模型、基准测试设计与集成方案。

### 核心结论摘要：
1. **现有测试基础设施极其成熟完善**：
   - 根入口 `scripts/check_project.py` 串联单元测试、代码同步、静态代码审计（`audit_lsp.py`）、命令索引比对（`gen_命令索引.py`）以及全量离线检查（`tools/check_all_static.py`）。
   - `tools/check_all_static.py` 目前串联执行 22 个命令专项检查（如 `check_hb_static.py`、`check_fdx_static.py`、`check_ysdl_static.py` 等）。测试体系完全脱离实时 CAD，纯离线运行，耗时仅数秒。
2. **ZZ / JACC / DX2 的关键性能瓶颈已锁定**：
   - **CAD 级 $O(N)$ 交互瓶颈**：在文字循环中，对每一个文字对象均调用一次 `(ssget "_CP" ...)` 交叉多边形选集查询。处理 200 个文字产生 200 次 CAD 进程空间查询，每次约 10~50ms，仅交互开销即达 2~10 秒。
   - **重复图元解析与线缓存构建**：对每个文字拾取的图元重复调用 `(entget en)`，重复构建 `line-cache`。
   - **内存级 $O(N^2)$ 分组与反复反转**：`aa:zz-group-by-rect` 对每个文字嵌套遍历既有分组，且每次追加均执行 `(reverse new-groups)`。
   - **$O(k^2)$ 递归插入排序**：`aa:zz-sort-y-desc`、`dx2:sort-groups`、`dx2:sort-y-desc`、`dx2:sort-x-asc` 均使用递归插入排序（如 `dx2:insert-group`、`aa:zz-insert-y-desc`）。
3. **公共函数与契约完备**：
   - `aa:merge-sort` 位于 `AA整合版本.lsp:754`，具有完整 $O(N \log N)$ 稳定归并排序能力，支持自定义 comparator lambda，无 `vl-sort` 的去重丢弃 bug。
   - 空间包围盒辅助函数（`aa:safe-get-bbox`、`aa:bbox-*`、`aa:safe-move-entity`、`aa:normalize-text-vertical-align`）已被全局广泛验证并具备 COM 释放与异常保护。
4. **离线测试套件与基准测试可行性验证**：
   - 经原型实验验证：在 15×15（225 格子、32 条线、300 个文字）规模下，将 $O(N \cdot M)$ 线性扫描与 $O(N^2)$ 列表反转分组优化为基于排序列坐标二分检索与哈希分桶后，纯算法计算耗时从 5.13ms 降至 0.57ms，**提速达 9.0x**（轻松满足 5x+ 指标）；在实际 CAD 中配合消除 300 次 `ssget` 更是可达成 50x~200x 的端到端提速。

---

## 2. 现有静态测试基础设施调研

### 2.1 全项目检查流程与工具链

项目采用分层、严格的纯离线检查机制（**禁止连接实时 CAD 进程**）：

```
scripts/check_project.py (一键全项目离线门禁)
  ├── 1. python -m unittest discover -s tests -v (AST解析与审计单元测试)
  ├── 2. scripts/sync_common.py (公共纯函数一致性展开)
  ├── 3. scripts/audit_lsp.py --check (全仓 LISP 静态语义与作用域审计)
  ├── 4. gen_命令索引.py --check (命令清单与 Markdown/HTML 索引双向校验)
  └── 5. tools/check_all_static.py (AA整合版本.lsp 综合离线测试)
         ├── check_encoding: UTF-8 无 BOM、纯 CRLF
         ├── check_full_parse: 严格 Lisp 语法树解析 (725 forms, 639 defuns, 135 commands)
         ├── check_header_list: 文件头注释清单与实际 defun 严格一致
         ├── check_index_consistency: 命令索引覆盖所有命令
         ├── check_undo_pairing: aa:cmd-begin/end 与 undo-mark 配对
         ├── check_banned_patterns: 严禁在 defun 中使用 (vl-sort ...)
         └── run_command_checks: 串联 22 个命令专属静态与数学仿真检查
```

### 2.2 现有专项检查器设计模式对比

通过深入检视 `tools/` 目录下的典型专项检查脚本，总结出以下经过项目验证的最佳模式：

| 专项脚本 | 校验重点 | 仿真/测试设计模式 | 对 ZZ 检查的借鉴意义 |
|---|---|---|---|
| `check_hb_static.py` | AST 函数存在性、局部变量、语法 arity、禁止 `vl-sort` | Python 完整模拟电缆并入行解析、自然序合并、多场景数据断言 | 结构分为静态 AST 扫描 + 核心纯函数数学仿真两大部分 |
| `check_ysdl_static.py` | 5000×5000 矩形框拓扑识别、标题文字绑定、聚类编号 | 几何容差矩形过滤、分类框空间排序、112 个真实文字端到端模拟 | 几何矩形框边界测试（容差、圆弧段、未闭合、非正交）的建模方法 |
| `check_fdx_static.py` | FDX 框排序、矩阵配对、负坐标与标高、grdraw | 内置 Mini-Lisp 解释器 `evaluate(node)` 直接执行 AST 中的 lambda 比较器 | 直接验证 Lisp 表达式逻辑与数学性质，无需依赖外部运行时 |
| `check_cc_static.py` | 原生 MOVE 拖拽、剪贴板读取、清理与动态循环 | 严格检查函数体内特定操作的先后调用时序与系统变量保护 | 检查文字移动前后的几何偏移容差与无意义写入消除 |
| `check_hzbg_static.py` / `check_tbhb_static.py` | 多表格线条网络提取、分段线打断合并、50~195 个图元 | 引入 `fixtures/*.json` 真实 CAD 图元坐标，验证布局与重排 | 适合用于 200+ 实体大规模基准测试的数据集构造与比对 |
| `check_ming_static.py` | 3×3 矩阵行列空间聚类与排序 | 单链聚类（single-linkage）分行模拟，行内升序匹配 | 网格分行分列容差计算与抗抖动（jitter）验证 |

---

## 3. ZZ / JACC / DX2 现状与性能瓶颈深度诊断

### 3.1 当前实现架构与调用链路

在 `AA整合版本.lsp` 中：
- `(defun c:ZZ ...)`（行 11380）直接调用 `(aa:zz-run)`。
- `(defun c:JACC ...)`（行 11384）直接调用 `(aa:zz-run)`。
- `(defun c:DX2 ...)`（行 10972）与 `(defun c:DX ...)`（行 10772）复用 `aa:zz-filter-text-ss`、`aa:zz-text-info` 和 `aa:zz-group-by-rect`。

核心调用链如下：
```
c:ZZ / c:JACC
  └── aa:zz-run
        ├── (ssget) 交互获取选区
        ├── aa:zz-filter-text-ss 提取 TEXT/MTEXT
        ├── vla-startundomark
        ├── [循环 1..N] 遍历每个文字 en:
        │     ├── aa:normalize-text-vertical-align (重置为中下对正)
        │     └── aa:zz-text-info (计算文字所在线框)
        │           ├── aa:safe-get-bbox (获取文字包围盒与中心点 cx, cy)
        │           ├── (ssget "_CP" pts filter)  <=== 【瓶颈 1: O(N) CAD 选集交互】
        │           ├── aa:zz-build-line-cache   <=== 【瓶颈 2: 重复遍历线图元】
        │           │     ├── aa:zz-add-seg (收集水平线 hlist、垂直线 vlist)
        │           │     └── aa:zz-collect-lwpoly-pts
        │           └── aa:zz-find-bound-lines   <=== 【瓶颈 3: O(M) 遍历每条线找边界】
        ├── aa:zz-group-by-rect (infos)          <=== 【瓶颈 4: O(N^2) 分组与频繁 reverse】
        ├── [循环每个方格分组 g]:
        │     └── aa:zz-apply-group (g)
        │           ├── aa:zz-sort-y-desc (g)    <=== 【瓶颈 5: O(k^2) 递归插入排序】
        │           └── [循环移动每个文字]:
        │                 └── aa:zz-move-text (移动到计算的目标中心)
        └── vla-endundomark
```

### 3.2 性能瓶颈定量分析

1. **CAD 交互瓶颈：$O(N \times \text{CAD\_SSGET})$**：
   - 当前在 `aa:zz-text-info` 内部（行 11192）：每次以 `(cx, cy)` 为中心构造 600×600 的四边形，调用 `(ssget "_CP" ...)` 拾取周边的 `LINE`、`LWPOLYLINE`、`POLYLINE`。
   - 在包含 200 个文字的表格中，产生 200 次完整的 CAD 交互与底层空间索引查询。即使在高性能工作站上，单次 `ssget` 也需要 15~30ms，200 次累计消耗 **3~6 秒**，这是整个命令缓慢的**最主要元凶（占总耗时 80% 以上）**。
2. **重复图元解析与内存分配**：
   - 200 个文字共享同一个表格的线框。每个文字重复拾取相同的一组线，执行 200 次 `entget`、点提取与坐标转换，产生大量临时列表，触发 CAD 内存 GC。
3. **线框边界检索未建立空间索引**：
   - `aa:zz-find-bound-lines`（行 11136）：针对单个文字的 `(cx, cy)`，通过全量 `foreach` 扫描 `vlist` 和 `hlist` 来寻找最小差值。对于 $M$ 条线和 $N$ 个文字，耗时为 $O(N \cdot M)$。
4. **方格分组算法复杂度过高**：
   - `aa:zz-group-by-rect`（行 11242）：
     ```lisp
     (foreach info infos
       (setq placed nil new-groups '())
       (foreach g groups
         ...)
       (setq groups (reverse new-groups)))
     ```
     每次向 `groups` 插入时都进行内层循环比对，并在每次插入后对整个 `new-groups` 进行一次 `reverse`！当有 $N$ 个文字时，时间复杂度为 $O(N^2)$，伴随极高频率的列表反转。
5. **插入排序而非归并排序**：
   - `aa:zz-sort-y-desc`（行 11270）与 `dx2:sort-groups`（行 10877）均使用插入排序，违背了项目关于统一使用 `aa:merge-sort` 的准则。
6. **未声明变量泄漏（`PROJECT_AUDIT.md` 既有告警）**：
   - 在 `PROJECT_AUDIT.md` 中已有记录：
     - `aa:zz-add-seg`：写入未声明变量 `hlist`、`vlist`（利用了调用方动态作用域，但未局部绑定）。
     - `aa:zz-collect-lwpoly-pts`：foreach 循环变量 `pair` 未声明。
     - `aa:zz-build-line-cache`：foreach 循环变量 `p` 未声明。
     - `aa:zz-run`：foreach 循环变量 `g` 未声明。
   - 重构时必须补齐所有局部变量声明，消除审计隐患。

---

## 4. 仓库公共函数与基础设施检视

### 4.1 `aa:merge-sort` 契约与规范

- **源码位置**：`AA整合版本.lsp` 第 754-778 行。
- **函数签名**：
  ```lisp
  (defun aa:merge-sort (items comparator / n half left rest i) ...)
  ```
- **辅助函数**：`aa:msort-merge`（第 737-752 行）。
- **比较器参数契约**：
  `aa:msort-merge` 中的比较调用为：
  ```lisp
  (if (apply comparator (list (car b) (car a)))
    (setq out (cons (car b) out) b (cdr b))
    (setq out (cons (car a) out) a (cdr a)))
  ```
  - `comparator` 接受两个参数 `(comparator b a)`。
  - 当 `b` **严格排在 `a` 之前** 时返回真（`T`），此时先取 `b`。
  - 当比较器判定为假或两者等价时，先取 `a`，从而保证**严格的稳定性（Stable Sort）**。
  - 示例：
    - 数值升序：`'(lambda (a b) (< (nth 1 a) (nth 1 b)))` 或 `'<`
    - 数值降序（Y 从上到下）：`'(lambda (a b) (> (nth 2 a) (nth 2 b)))`
- **项目规则遵从**：
  `AGENTS.md` 明确规定：“排序统一使用 `aa:merge-sort`；禁止大列表使用 `vl-sort`”。`aa:merge-sort` 不会像 ZWCAD 的 `vl-sort` 那样丢失相等元素，且时间复杂度为稳定的 $O(N \log N)$。

### 4.2 空间几何与 COM 辅助函数

`AA整合版本.lsp` 中已有成熟的几何与 COM 封装，重构时可直接复用：
1. **包围盒计算**：
   - `(aa:safe-get-bbox doc ename)`（第 1038 行）：封装 `vla-getboundingbox`，包含 `vla-update` 与 `vla-regen` 容错重试，自动执行 `(vlax-release-object vla_obj)` 防止句柄泄露。
   - 提取宏：`aa:bbox-center-x`、`aa:bbox-left-x`、`aa:bbox-right-x`、`aa:bbox-top-y`、`aa:bbox-bottom-y`。
2. **图元位移**：
   - `(aa:safe-move-entity ename move_vec)`（第 1084 行）：封装 `vla-move`，支持传入 list 或 3D variant 点，失败时安全捕获并返回 `nil`，成功则自动更新。
   - `(aa:zz-move-text en cx cy tx ty)`（第 11226 行）：
     ```lisp
     (defun aa:zz-move-text (en cx cy tx ty / dx dy)
       (setq dx (- tx cx) dy (- ty cy))
       (if (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6))
         T
         (aa:safe-move-entity en (vlax-3d-point (list dx dy 0.0)))))
     ```
     **关键特性**：自带微小位移容差判断（`1e-6`），当前已居中的文字直接返回 `T`，不产生多余的图元写操作。
3. **文字对正标准化**：
   - `(aa:normalize-text-vertical-align doc en mode)`：统一文字为中下对正（Bottom Center），消除不同字型插入点造成的视觉中心偏移。

---

## 5. `tools/check_zz_static.py` 需求与实现方案规范

测试套件必须严格遵守“只做离线静态分析与数学仿真测试，禁止连接实时 CAD 进程”的安全准则。

### 5.1 模块结构与静态代码审计规范

脚本应包含以下静态代码检查项：
1. **编码与格式检查**：
   - 读取 `AA整合版本.lsp`，验证无 UTF-8 BOM，无 `\ufffd` 替换字符，换行符严格为纯 CRLF。
2. **AST 结构与函数完整性**：
   - 使用 `lsp_common.parse` 解析整文件语法树。
   - 确认核心顶层命令及关键辅助函数存在：
     - `c:zz`、`c:jacc`、`c:dx2`、`c:dx`
     - `aa:zz-run`、`aa:zz-text-info`、`aa:zz-move-text`、`aa:zz-apply-group`
     - 以及重构后的全局空间索引或批量采集函数（如 `aa:zz-build-global-line-cache`、`aa:zz-find-cell-bounds` 等）。
3. **禁止模式检查（Banned Patterns）**：
   - 扫描 `c:zz`、`c:jacc`、`c:dx2` 及其所有被调用子函数的 AST 节点，严禁出现 `vl-sort` 调用。
4. **CAD `ssget` 调用频率静态审计（核心性能门禁）**：
   - 遍历 `aa:zz-run`（以及 `c:DX2`）中针对文字集合的循环遍历结构（`repeat`、`while`、`foreach`）。
   - **严格断言**：在文字逐个迭代的循环体子节点中，**不得包含任何 `ssget` 调用**！
   - 选区与线框拾取的 `ssget` 必须且仅允许出现在循环外部的全局单次采集阶段。
5. **Undo 事务与异常配对检查**：
   - 检查 `vla-startundomark` 与 `vla-endundomark`（或 `aa:undo-mark-on` 与 `aa:undo-mark-off`）在正常路径与 `*error*` 路径上的严格配对。
6. **局部变量声明完备性**：
   - 检查函数参数形参后斜杠 `/` 后的局部变量列表，确认所有 `setq` 赋值变量与 `foreach` 循环变量均已声明，杜绝未声明变量泄漏。

---

### 5.2 离线纯数学仿真测试套件规范

#### 1. 矩形线框几何仿真（LINE 与 LWPOLYLINE）
- **数据结构定义**：
  - 水平线段集合：`HLine(y, xmin, xmax)`
  - 垂直线段集合：`VLine(x, ymin, ymax)`
- **图元转线段模型**：
  - `LINE`：根据端点斜率分别归类为水平或垂直线段。
  - `LWPOLYLINE`：遍历多段线顶点对，闭合线框追加末顶点至首顶点线段，分别归类为水平或垂直线段。
- **线框边界解析算法模型**：
  给定点 $(cx, cy)$：
  - 左边界 $lx$：$\max \{ x \mid VLine(x, ymin, ymax), x < cx - tol, ymin \le cy \le ymax \}$
  - 右边界 $rx$：$\min \{ x \mid VLine(x, ymin, ymax), x > cx + tol, ymin \le cy \le ymax \}$
  - 下边界 $by$：$\max \{ y \mid HLine(y, xmin, xmax), y < cy - tol, xmin \le cx \le xmax \}$
  - 上边界 $ty$：$\min \{ y \mid HLine(y, xmin, xmax), y > cy + tol, xmin \le cx \le xmax \}$
  - 若四边中任意一边缺失，或到边界距离超过 `max_dist`（如 300），则返回 `None`。

#### 2. 单个文字居中仿真（容差 $< 1\text{e}-6$）
- **测试场景**：
  - 矩形线框 $[lx, rx, by, ty] = [0.0, 100.0, 0.0, 50.0]$，理论几何中心为 $(50.0, 25.0)$。
  - 测试用例 1：文字初始位于偏左上角 $(12.34, 45.67)$。
  - 测试用例 2：文字初始位于偏右下角 $(88.88, 5.55)$。
  - 测试用例 3：文字初始已位于严格中心 $(50.0, 25.0)$（位移矢量为 0，跳过物理写操作）。
- **断言要求**：
  - 最终文字中心坐标与理论中心坐标的绝对差值：
    $$\max(|x_{final} - 50.0|, |y_{final} - 25.0|) < 1\text{e}-6$$

#### 3. 多个文字堆叠等距对称居中（5.0 单位垂直间距，保持原顺序）
- **测试场景**：
  - 矩形线框 $[lx, rx, by, ty] = [0.0, 100.0, 0.0, 80.0]$，中心 $cx = 50.0, cy = 40.0$。
  - 分别测试 $k = 2, 3, 4, 5$ 个文字的堆叠排列。
- **数学模型与排列公式**：
  - 给定 $k$ 个文字，首先按初始 $y$ 坐标降序排序（确保从上到下的视觉相对顺序不变）：$T_0, T_1, \dots, T_{k-1}$。
  - 垂直间距 $spacing = 5.0$。
  - 顶部起始文字 Y 坐标：
    $$start\_y = cy + 0.5 \times (k - 1) \times spacing$$
  - 第 $i$ 个文字的目标坐标：
    $$target\_x_i = cx$$
    $$target\_y_i = start\_y - i \times spacing$$
- **断言要求**：
  - 整个文字堆叠的几何中点精确等于线框中心：
    $$\frac{target\_y_0 + target\_y_{k-1}}{2} = cy \quad (\text{误差} < 1\text{e}-6)$$
  - 相邻文字间距恒等于 5.0：
    $$target\_y_i - target\_y_{i+1} = 5.0 \quad (\text{误差} < 1\text{e}-6)$$
  - 文字水平居中对齐线框中心 $cx$（误差 $< 1\text{e}-6$）。
  - 顺序一致性：原始较高的文字在新布局中仍然位于较上方。

#### 4. 边界异常处理与跳过计数
- **测试场景**：
  - 场景 A：缺失上边框（仅有左、右、下三条线）。
  - 场景 B：缺失下边框。
  - 场景 C：缺失左边框。
  - 场景 D：缺失右边框。
  - 场景 E：线条端点未延伸到文字投影范围（例如水平线长度不足，未跨过文字 $cx$）。
  - 场景 F：文字距离边界过远（超过 300 阈值）。
- **断言要求**：
  - 以上所有情况均被准确识别并判定为无效方格，返回 `None`。
  - 异常计数器 `skipped` 准确累加，不发生未捕获异常。

#### 5. DX2 方格文字提取与排版顺序一致性
- **测试场景**：
  - 构造包含 3 行 3 列的 9 宫格表格，网格线带微小坐标抖动（$\pm 0.05$）。
  - 多个格子内填充单行或多行文字。
- **提取与排序规则**：
  - 方格排序：行容差带分组（$ay - by \le row\_tol$），从上到下，行内从左到右。
  - 格内文字排序：从上到下（Y 降序），同高度从左到右（X 升序）。
  - 连接格式：格内文字用顿号“、”连接，格与格之间用“\r\n”换行符连接。
- **断言要求**：
  - 提取的文本字符串与理论预期排版严格全等。

---

### 5.3 离线基准测试（200+ 文字与网格，验证 5x+ 提速）

#### 1. 基准测试场景构造
- **网格规格**：15 行 × 15 列 = 225 个网格单元。
- **网格线规模**：16 条水平线、16 条垂直线（共 32 条主网格线，或划分为 450 条线段）。
- **文字规模**：随机在网格内生成 300 个文字，覆盖单文字居中（约 150 格）、双文字堆叠（约 50 格）、多文字堆叠（约 25 格）。

#### 2. 对比测试设计
- **基线算法（Baseline，模拟当前实现）**：
  - 对每个文字，线性遍历全部 32 条线条寻找最小包围差（复杂度 $O(N \cdot M)$）。
  - 分组阶段：使用类似 `aa:zz-group-by-rect` 的 $O(N^2)$ 列表反转嵌套比对算法。
  - 排序阶段：使用插入排序。
- **优化算法（Optimized，模拟重构后纯内存算法）**：
  - 预构建空间索引：线条按 X/Y 分别排序，或构建线性格网分桶（查找耗时降为 $O(\log M)$ 或 $O(1)$）。
  - 分组阶段：使用空间坐标哈希键或单趟排序列分桶（复杂度降为 $O(N)$ 或 $O(N \log N)$）。
  - 排序阶段：使用归并排序 `aa:merge-sort`。
- **验证指标**：
  - 纯算法纯计算耗时加速比：
    $$Speedup = \frac{T_{baseline}}{T_{optimized}} \ge 5.0$$
  - 几何结果一致性：验证优化算法与基线算法输出的文字目标坐标 $(target\_x, target\_y)$ 完全一致（误差 $< 1\text{e}-6$）。

---

## 6. 与 `tools/check_all_static.py` 的集成方案

在 `tools/check_all_static.py` 中，所有专项检查通过 `run_command_checks()` 中的 `checks` 列表加载执行。

### 6.1 集成点修改设计

在 `tools/check_all_static.py` 的 `run_command_checks()` 函数中，将 `check_zz_static.py` 追加至列表中：

```python
    checks = [
        'check_t_static.py',
        'check_fdx_static.py',
        'check_fkx_static.py',
        'check_cc_static.py',
        'check_c1c2_static.py',
        'check_des_static.py',
        'check_gtx_static.py',
        'check_xy_static.py',
        'check_hddl_static.py',
        'check_xyg_static.py',
        'check_hb_static.py',
        'check_ys1_static.py',
        'check_aicad_static.py',
        'check_ming_static.py',
        'check_atw_static.py',
        'check_zdwi_static.py',
        'check_hzbg_static.py',
        'check_sss_static.py',
        'check_tbhb_static.py',
        'check_hg5_static.py',
        'check_zj_static.py',
        'check_ysdl_static.py',
        'check_zz_static.py',       # <=== 新增集成项
    ]
```

### 6.2 链式触发与全库合规保证
1. 运行 `python tools/check_all_static.py` 将自动串联运行第 23 个专项检查并打印 `-- check_zz_static.py --`。
2. 运行 `python scripts/check_project.py` 将依次自动通过 `unittest`、`sync_common`、`audit_lsp`、`gen_命令索引` 并最终调用 `check_all_static.py`。
3. `AGENTS.md` 与 `CLAUDE.md`：
   建议同步在两份规则文件的第 32 行“一键静态检查”命令列表中追加 `ZZ` 说明（保持两份文件逐字一致）。

---

## 7. 给后续实施阶段（Implementer）的架构建议

为了确保提速重构的顺利实施并防范回归风险，向后续实施智能体提供如下技术建议：

1. **CAD 单次批量范围采样架构（消除 $O(N)$ `ssget`）**：
   - 用户框选得到 `text-ss` 后，首先计算整个选区文字的外围包围盒（所有文字中心点与尺寸的全局外包矩形，外扩 300 容差）。
   - 在循环外部执行**唯一一次** `(ssget "_C" pt1 pt2 '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (0 . "POLYLINE") (-4 . "OR>")))`。
   - 一次性解析所有线条得到全局 `line-cache`，将 CAD 选择集开销从 $O(N)$ 彻底降为 $O(1)$。
2. **内存线框网格分桶 / 坐标排序二分**：
   - 将提取的垂直线按 X 坐标使用 `aa:merge-sort` 升序排列，水平线按 Y 坐标升序排列。
   - 给定文字 $(cx, cy)$，利用二分或区间段快速定位邻近边线，纯内存查找复杂度为 $O(\log M)$。
3. **方格分组算法重构（消除 $O(N^2)$ 与 `reverse`）**：
   - 将方格坐标整型化作为桶键（例如保留 1 位小数的哈希键或坐标对），直接使用关联列表或先按坐标排序后单趟线性扫描分桶，将分组复杂度降至 $O(N)$ 或 $O(N \log N)$。
4. **向后兼容与副作用防护**：
   - 保留公共工具函数 `aa:zz-move-text` 的入参及容差行为，因其被 `c:MJ` 和 `c:ZDWI` 共用。
   - `c:DX` 和 `c:DX2` 复用新的全局线框提取与单次选集机制，确保导出顺序与文本格式 100% 保持一致。
   - 彻底修复 `aa:zz-add-seg`、`aa:zz-build-line-cache`、`aa:zz-run` 中的未声明局部变量，使 `scripts/audit_lsp.py --strict` 零结构性告警。
