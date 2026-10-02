# 公共函数库

运行时仍只加载整合文件与 V6 loader。主整合文件保持自包含；`common/` 是开发源目录，不加入 APPLOAD，不作为第三个启动入口。

## 已实施：构建时展开

`aicad_pure.lsp` 统一维护两个 V6 模块原本完全相同的三个函数。`scripts/sync_common.py --write` 将模板展开为原来的 `aicad:` / `aicadloader:` 名称，保留函数所在位置和调用接口。每处展开有 Generated 注释；默认运行脚本只检查同步状态。

| 模板函数 | 参数 | 返回 / 契约 | 外部依赖 |
| --- | --- | --- | --- |
| common:normalize-path | path：字符串或 nil | 斜杠转换为反斜杠；nil 返回空串 | vl-string-translate |
| common:not-empty-p | value：字符串或 nil | 非 nil 且不等于空串；纯空白仍有效 | AutoLISP 布尔运算 |
| common:error-message | err：捕获错误对象、字符串或其他值 | 错误消息、原字符串或空串 | Visual LISP；两个目标文件已有 vl-load-com |

展开器写入前保存字节级备份到忽略的 `backups/common-*/`；检查器对展开结果做整文件解析。回归测试验证两种命名空间的 AST 等价及重复运行不产生改动。模板不引入额外运行时 COM 初始化或加载路径。

## 后续建议

| 候选模块 | 现有实现 | 处理建议 |
| --- | --- | --- |
| command-context | aa:cmd-begin/end/error、aa:undo-mark-on/off | 已经复用；保留整合文件内的位置和动态作用域绑定。先设计异常路径测试再迁移。 |
| geometry | aa:safe-get-bbox、各模块 bbox / UCS 辅助函数 | 不直接合并：返回结构、坐标系、失败策略和 COM 释放责任不同。先定义契约。 |
| text | plain-text、DXF 文本读写、属性处理 | 区分 TEXT/MTEXT/ATTRIB、格式码保留与丢弃策略，再建立兼容层。 |
| sorting | aa:merge-sort、aa:insert-sort、命令专属比较器 | 统一接口已存在；不合并不同容差与稳定性规则，ZTF 小列表继续插入排序。 |
| selection | 预选、过滤、单对象拾取 | 空选、取消、锁层、混合类型分别定义结果；不更改已有交互习惯。 |
| environment | aicad / aicadloader 的系统变量快照与堆栈 | 两套堆栈有不同生命周期，不能按外观相似合并；全局错误处理覆盖问题需单独设计。 |

只对接口和异常语义都相同的函数做抽象。将源码搬出整合文件时，优先沿用构建时展开；不要引入运行时 `load common/...` 依赖。
