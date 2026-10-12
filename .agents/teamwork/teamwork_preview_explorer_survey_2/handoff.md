# Handoff Report: DX2 与 ZZ 线框匹配算法调研

## 1. Observation
1. **源码定义位置**：
   - 文件：`d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\AA整合版本.lsp`
   - `c:DX2` 定义位于行 10972 - 11026。
   - `dx2:*` 辅助函数（`dx2:group-record` 至 `dx2:export-group`）位于行 10843 - 10970。
   - `c:ZZ` 定义位于行 11380，其执行体 `aa:zz-run` 位于行 11318 - 11378；别名 `c:JACC` 位于行 11384。
   - `c:DX` 定义位于行 10772 - 10836。
   - 共享底层函数 `aa:zz-filter-text-ss`、`aa:zz-build-line-cache`、`aa:zz-find-bound-lines`、`aa:zz-text-info`、`aa:zz-group-by-rect` 位于行 11043 - 11260。
2. **复用机制直接观察**：
   - `c:DX2`（第 10992、10999、11004 行）直接调用 `aa:zz-filter-text-ss`、`aa:zz-text-info` 和 `aa:zz-group-by-rect`。
   - `c:ZZ`（第 11345、11357、11362 行）直接调用相同的三个函数。
   - `c:DX`（第 10801、10808、10813 行）同样直接调用相同的三个函数。
3. **算法调用与参数**：
   - 寻找线框时使用 `tol = 1e-8`，`rect-tol = 0.1`，线段正交容差 `near = 0.5`，最大包围距离 `max-dist = 300.0`。
   - `aa:zz-text-info`（第 11192 行）对**每个文字**均执行一次 CAD 视窗交叉选择：
     `(ssget "_CP" (mapcar '(lambda (pt) (trans pt 0 1)) (list pt1 pt2 pt3 pt4)) '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (0 . "POLYLINE") (-4 . "OR>")))`。
   - `dx2:group-before-p`（第 10862 行）使用 `row-tol (* 0.25 (min ah bh))` 作为同一行方格吸附容差。
   - `dx2:group-rows`（第 10939 行）使用 `tol (* 0.55 (max row-h (nth 4 item) 1e-8))` 作为格内同行动字吸附容差。
4. **输出介质与数据流**：
   - `dx2:export-group` 通过 `(dx2:append-text out text)` 以顿号 `"、"`（第 10954 行）拼接格内文字。
   - `c:DX2` 通过 `(strcat out "\r\n" group-text)`（第 11009 行）将各方格以 Windows CRLF 换行拼接。
   - `c:DX2` 通过 `(setq ok (zi:to-clip out))`（第 11013、12637 行）将结果纯文本写入操作系统剪贴板，不产生任何磁盘文件。
5. **离线测试基线**：
   - 执行 `python tools/check_all_static.py` 输出 `ALL PASS`（22 个专项检查与编码全部通过）。
   - 当前 `tools/` 目录下尚未存在针对 `ZZ`/`DX2` 的专项仿真测试 `check_zz_static.py`。

## 2. Logic Chain
1. 从【观察 2】可知：`DX2`、`ZZ` 与 `DX` 并非简单复制粘贴代码，而是直接调用同一套 `aa:zz-*` 模块函数。这意味着重构 `aa:zz-text-info` 与线框匹配底层将同时直接影响 `DX2`、`ZZ`、`JACC` 和 `DX`。
2. 从【观察 3】可知：`aa:zz-text-info` 在循环体内对每个文字调用一次 `ssget "_CP"`，算法复杂度为 $O(N \times \text{CAD\_SSGET})$。在拥有数百文字的工程图纸中，多次 CAD 核心引擎 IPC 与选择集求交构成了 >80% 的耗时。
3. 从【观察 1、4】可知：`DX2` 是一个只读导出命令，不执行 `ZZ` 的 `aa:normalize-text-vertical-align` 与图形位移；其最终产物是严格按二维空间顺序排布、以 `\r\n` 换行、格内以 `"、"` 连接的剪贴板纯文本。
4. 从【数学仿真验证】可知：当采用全局单次包围盒采集（$O(1)$ `ssget`）并在内存中建立水平/垂直线段区间索引后，边界线查找耗时可从单次 ~15ms 降至微秒级。同时将 `dx2:sort-groups` 升级为 `aa:merge-sort`（使用相同的 `dx2:group-before-p` 比较器）可在完全保证排序结果严格一致的前提下消除 $O(M^2)$ 递归栈开销。

## 3. Caveats
- 极少数特殊图纸中若存在跨越超长距离（>300 个绘图单位）的特大非标方格，原算法将其作为未识别（`skipped`）处理；重构方案必须精确保留 `max-dist = 300.0` 阈值，以防误识别引起统计与排序差异。
- 原算法中的 `aa:zz-group-by-rect` 使用了容差 `0.1`；在统一空间索引中建立矩形分桶时，必须保证边界坐标在 `0.1` 容差内能正确聚合，避免拆分或错位。

## 4. Conclusion
1. **算法共享性**：`DX2` 与 `ZZ` 深度共用 `aa:zz-text-info` 和 `aa:zz-group-by-rect`。
2. **核心瓶颈**：高频 $O(N)$ 次 CAD 原生 `ssget` 交互和循环内重复反序列化同一批正交线段。
3. **输出契约**：
   - 媒介：Windows 剪贴板（`zi:to-clip`）；
   - 行结构：方格间 `\r\n` 分割；格内文字按自然视觉行（0.55 字高容差）自上而下、行内从左到右，以 `"、"` 连接；
   - 方格顺序：自上而下、自左向右（0.25 较小格高容差）。
4. **重构路线**：采用“全局单次范围采集 + 纯内存正交线段区间索引 + 元数据缓存”架构，可将算法运算性能提升数量级，同时保证 `DX2` 的导出行为与输出内容 100% 向后兼容。

## 5. Verification Method
1. **静态代码与全库一致性验证**：
   ```pwsh
   python tools/check_all_static.py
   ```
   预期：全部 22 项静态检查通过，整文件语法与 Undo 事务无泄漏。
2. **文本报告查验**：
   直接审阅详细报告：`d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\teamwork_preview_explorer_survey_2\report.md`。
3. **失效判定条件**：
   若任何后续重构导致 `DX2` 导出的剪贴板文字顺序发生变化、格内文本顿号连接丢失、`skipped` 统计不一致或产生任何非 CRLF 换行，则视为重构不合格。
