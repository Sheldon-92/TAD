# AC7 回读 Agent 2/3（原始作答）
题：列出至少 4 类致命操作及其具体识别特征（YAML 标识符 + 每类 ≥2 条特征）

data_loss（critical, forced_review: true）：schema DROP/破坏性迁移、rm -rf/unlink batch、无备份 truncate/overwrite、删桶；DROP TABLE|DROP INDEX|DROP DATABASE、DELETE FROM .* WHERE 1 / WITHOUT WHERE；database/migrations/*
data_leak（critical, forced_review: true）：无 auth 暴露、日志打印 passwords/tokens/PII、移除鉴权、private→public；process.env.(SECRET|KEY|TOKEN|PASSWORD)；auth/*、api/admin/*
financial_loss（critical, forced_review: true）：支付逻辑、定价计算、订阅/计费流、移除付费 rate limit；payment/*、billing/*
service_crash（high, forced_review: true）：生产部署配置、连接池变更、移除错误处理、timeout/retry；唯一 severity high 但仍 forced_review
通用：handoff_awareness（EXPECTED 不拦）；risk_translation（Business Impact 卡片）；project_custom 扩展点

读取方式：12 文件各 1 次 Read 无 offset 并行；仅 Read；config-quality.yaml 返回 875 行。
六键判定：data_leak✓ financial_loss✓ service_crash✓ forced_review✓ DROP TABLE✓ DELETE FROM✓ → 全中
