# Dispatch Assignment

## 2026-10-12T02:03:57Z

You are the Project Orchestrator for the following mission:
对 ZWCAD 2026 AutoLISP 插件中的 ZZ 命令（及其别名 JACC、共用线框匹配算法的 DX2）进行全方位的性能诊断与极致提速重构，彻底解决大批量文字在复杂表格/线框中批量居中对齐时运行缓慢的问题。

Your dedicated working directory is:
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\orchestrator_1

Authoritative user request file:
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp\.agents\teamwork\ORIGINAL_REQUEST.md (inspect the latest timestamp section 2026-10-12T02:02:32Z).

Project Root:
d:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp

Requirements Summary:
1. R1: 消除高频交互式 CAD 空间选择瓶颈。消除在循环中对每个文字逐次调用 ssget 空间查询的 O(N * CAD_SSGET) 瓶颈，采用一次性范围采集结合内存空间索引/分类缓存，将 CAD 选择集交互开销降至全局单次完成。
2. R2: 纯内存几何计算与高效分组算法。重构文字与包围线框的匹配检索，查找复杂度降至内存级亚线性或线性时间。优化多行文字等距对称居中排列及方格去重算法，消除低效的重复遍历与多次列表反转。大列表严禁使用 vl-sort，统一使用 aa:merge-sort 或纯线性格网分桶。
3. R3: 图元几何更新效率与向后兼容保障。仅对目标坐标与当前坐标偏移大于几何容差的文字执行物理移动，避免无意义的图元写操作。保持 DX2（方格文字顺序导出）的底层线框几何提取完全兼容且同步提速，输出文本格式与排版顺序保持 100% 一致。严格遵循 AGENTS.md（UTF-8 无 BOM、CRLF 换行、完整 undo 事务包裹、ActiveX 资源释放保护）。
4. R4: 离线自动化测试套件与安全约束。新增独立的离线静态与数学仿真测试套件 tools/check_zz_static.py，并集成至全项目静态检查 tools/check_all_static.py。默认仅做离线静态分析与数学仿真测试，未获用户明确要求禁止主动连接或操作外部实时 CAD 进程。

Acceptance Criteria:
- 单个文字中心准确对齐矩形线框几何中心，容差在 1e-6 以内。
- 多个文字保持原从上到下的顺序，以 5.0 单位垂直间距对称分布在矩形中心，容差在 1e-6 以内。
- 边界异常处理：对缺失上/下/左/右任意边界的非闭合情况，能正确识别并安全跳过，跳过计数准确。
- DX2 兼容性：DX2 提取方格文字的行为与导出的文本内容在几何顺序上完全一致。
- 针对 200+ 文字及线框网格的离线基准测试中，重构后线框查找与匹配的算法运算复杂度实现数量级降低（算法纯计算耗时 5x 以上提速）。
- CAD 执行路径中，全选区下的 CAD ssget 交互调用次数从 O(N) 降为 O(1)。
- AA整合版本.lsp 保持 UTF-8 无 BOM 且 CRLF 换行，命令清单与顶层 defun 数量一致。
- 运行 python tools/check_zz_static.py 离线测试全部通过（PASS）。
- 运行 python tools/check_all_static.py 全部检查通过（ALL PASS）。
- 运行 python gen_命令索引.py 成功生成并同步命令索引文档。
