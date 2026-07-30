# Journal: lite-v11-quality-amendments (2026-07-30)

- L2.5 契约审查从 blake-lite spawn 前移到 alex-lite 设计阶段后，blake-lite L0.5 从 spawn-based 变为纯机械检查（grep/awk）。这个转变意味着 L0.5 不再需要独立上下文——它只验证段存在性和字段非空，不做语义判断。语义判断已在 alex-lite L2.5 完成。

- ND-2（首轮/最终 verdict 同行导致机械检查误停）是一个典型的"模板格式影响下游机械消费者"的问题：模板设计时必须考虑谁会用 grep/awk 消费它、用什么模式。解决方案（独立行 + 行首锚定 grep）比 sed/awk 解析 JSON 更健壮。
