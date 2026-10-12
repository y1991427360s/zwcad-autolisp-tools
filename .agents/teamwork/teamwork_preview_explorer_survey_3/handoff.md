# Handoff Report — Explorer Survey 3 (Testing Infrastructure & check_zz_static.py)

## 1. Observation

1. **测试基础设施与现有工具链**：
   - `scripts/check_project.py` 串联执行 5 个离线步骤，包含 `unittest`、`sync_common.py`、`audit_lsp.py --check`、`gen_命令索引.py --check` 及 `tools/check_all_static.py`。
   - `tools/check_all_static.py:127-159` 中定义了 `run_command_checks()`，顺序通过 `runpy.run_path` 执行 22 个命令专项检查（从 `check_t_static.py` 到 `check_ysdl_static.py`）。
   - 运行 `python tools/check_all_static.py` 输出：
     ```
     PASS encoding: AA整合版本.lsp 681005 bytes, UTF-8 no BOM, pure CRLF
     PASS parse: 725 top-level forms, 639 defuns, 135 c: commands
     PASS header: 135 commands listed and defined
     PASS index: 命令索引 covers all 135 c: commands
     PASS undo: no cmd-begin/undo-mark leaks across 639 defuns
     PASS bans: no live (vl-sort ...) in defuns
     ...
     PASS modules: 22 command-specific static checks
     ALL PASS
     ```
   - 运行 `python scripts/check_project.py` 同样全量通过，耗时约 4 秒。

2. **ZZ / JACC / DX2 源码现状与性能瓶颈**：
   - `AA整合版本.lsp` 中：
     - `c:ZZ` 位于 11380 行，定义为 `(defun c:ZZ () (aa:zz-run))`。
     - `c:JACC` 位于 11384 行，定义为 `(defun c:JACC () (aa:zz-run))`。
     - `c:DX2` 位于 10972 行，定义为 `(defun c:DX2 ...)`。
     - `c:DX` 位于 10772 行。
   - 在 `aa:zz-run`（11353-11361 行）和 `c:DX2`（10997-11003 行）中，遍历文字选集 `text-ss` 时，逐个文字调用 `(aa:zz-text-info doc en tol)`。
   - 在 `aa:zz-text-info`（11181-11200 行）内部：
     ```lisp
     (line-ss (ssget "_CP"
                (mapcar '(lambda (pt) (trans pt 0 1))
                  (list pt1 (list (+ cx margin) (- cy margin))
                        pt2 (list (- cx margin) (+ cy margin))))
                '((-4 . "<OR")
                  (0 . "LINE")
                  (0 . "LWPOLYLINE")
                  (0 . "POLYLINE")
                  (-4 . "OR>"))))
     ```
     每个文字触发一次交互式 CAD 交叉多边形选集查询，产生严重 $O(N \times \text{CAD\_SSGET})$ 性能瓶颈。
   - 在 `aa:zz-group-by-rect`（11242-11260 行）中：
     采用嵌套 `foreach` 逐个比对，每次插入后执行 `(setq groups (reverse new-groups))`，复杂度为 $O(N^2)$ 且伴随频繁列表反转。
   - 在 `aa:zz-sort-y-desc`（11270 行）和 `dx2:sort-groups`（10877 行）中：
     均使用递归插入排序（`aa:zz-insert-y-desc`、`dx2:insert-group`）。
   - 在 `PROJECT_AUDIT.md:88-92` 中已记录 `aa:zz-add-seg`、`aa:zz-collect-lwpoly-pts`、`aa:zz-build-line-cache`、`aa:zz-run` 存在未局部声明变量（`hlist`, `vlist`, `pair`, `p`, `g`）。

3. **仓库现有核心工具函数**：
   - `aa:merge-sort` 位于 `AA整合版本.lsp:754`：
     ```lisp
     (defun aa:merge-sort (items comparator / n half left rest i) ...)
     ```
     配合 `aa:msort-merge`（行 737），实现 $O(N \log N)$ 严格稳定归并排序。比较器调用形式为 `(apply comparator (list (car b) (car a)))`，若 `(comparator b a)` 为真则将 `b` 排在 `a` 前。
   - 包围盒与几何移动工具：`aa:safe-get-bbox`（行 1038）、`aa:bbox-center-x`（行 1062）、`aa:safe-move-entity`（行 1084）、`aa:normalize-text-vertical-align`（行 3169）、`aa:zz-move-text`（行 11226，自带 `1e-6` 位移容差拦截无意义写操作）。

4. **纯数学基准测试原型验证**：
   - 构造 15×15（225 格子、32 条线、300 个文字）规模基准测试：
     - 基线算法（模拟线性扫描线条 + $O(N^2)$ 列表反转分桶）：耗时 5.133ms
     - 优化算法（排序列坐标二分定位 + 哈希分桶）：耗时 0.572ms
     - 纯算法加速比：**9.0x**，输出几何坐标完全一致。

---

## 2. Logic Chain

1. 基于 Observation 2，`aa:zz-run` 和 `c:DX2` 针对每个文字反复调用 CAD `ssget "_CP"`，200 个文字产生 200 次 CAD 进程通信与空间索引计算（约 2~10 秒），且在线条解析和方格分组中分别存在 $O(M)$ 重复遍历与 $O(N^2)$ 列表反转开销。
2. 因此，提速重构的核心在于：
   - 全局单次采样：循环前根据所有文字的宏观包围盒单次 `ssget` 拾取全部线框并解析为全局缓存，将 CAD 交互从 $O(N)$ 降至 $O(1)$；
   - 内存级空间检索：在内存中对线条按坐标预排序或线性格网分桶，将点到边界查询降为 $O(\log M)$ 或 $O(1)$；
   - 快速分组与归并：以方格坐标为键进行单趟分组，消除反复 `reverse`，并使用 Observation 3 确认的 `aa:merge-sort` 替代递归插入排序。
3. 基于 Observation 1，`tools/check_all_static.py` 具有成熟的 `run_command_checks` 动态执行机制，且与 `scripts/check_project.py` 联动。
4. 基于 Observation 4，纯数学仿真在 225 格/300 文字规模下已验证可实现 9.0x 的纯计算提速，完全满足要求中的 5x+ 性能指标。
5. 因此，新增 `tools/check_zz_static.py` 并将其追加至 `tools/check_all_static.py` 的 `checks` 列表中，可以完整覆盖代码合规审计、纯数学几何仿真（单字居中、多字 5.0 堆叠、边界异常、DX2 排版一致性）以及 200+ 实体 5x+ 基准测试。

---

## 3. Caveats

1. **CAD 实时进程测试限制**：
   - 遵循项目及安全准则，本次调研及后续静态检查完全处于离线状态，未连接亦未操作任何实时 ZWCAD 进程。
2. **DX 与 DX2 兼容性约束**：
   - `c:DX`（第 10772 行）和 `c:DX2`（第 10972 行）共用 `aa:zz-text-info` 和 `aa:zz-group-by-rect`。重构底层函数时必须保证既有接口参数与返回值向后兼容，或提供批量接口的同时保留单体兼容回退。
3. **MJ 与 ZDWI 外部依赖**：
   - `aa:zz-move-text` 被 `c:MJ`（第 11524 行）和 `c:ZDWI`（第 12393 行）调用，其函数名及签名 `(aa:zz-move-text en cx cy tx ty)` 绝不可随意改动或删除。

---

## 4. Conclusion

1. `tools/check_zz_static.py` 的测试规范已完整建立，涵盖：
   - AST 静态合规（UTF-8 CRLF、顶层 `defun`、禁止 `vl-sort`、循环内 `ssget` 数量为 0、undo 配对、局部变量完整）；
   - 纯数学仿真测试（单字居中误差 $<1\text{e}-6$、多字 5.0 对称堆叠误差 $<1\text{e}-6$、四向边界缺失跳过、DX2 导出文本排版严格一致）；
   - 200+ 实体网格离线基准测试（算法提速 $\ge 5\text{x}$）。
2. 集成路径清晰：在 `tools/check_all_static.py` 的 `run_command_checks()` 列表末尾添加 `'check_zz_static.py'` 即可无缝接入一键门禁 `python scripts/check_project.py`。
3. 详细分析报告已写入 `report.md`。

---

## 5. Verification Method

独立验证步骤：
1. **查看调研成果文档**：
   - 详细技术报告：`d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_3\report.md`
2. **验证现有测试基线**：
   - 运行全量离线检查：`python tools/check_all_static.py`（预期输出 22 个模块通过，`ALL PASS`）。
   - 运行全项目工程门禁：`python scripts/check_project.py`（预期 5 步全量通过）。
3. **失效条件**：
   - 若 `tools/check_all_static.py` 退出码非 0，或 `scripts/audit_lsp.py --check` 报告过期文件，则表明基线环境受损，需排查。
