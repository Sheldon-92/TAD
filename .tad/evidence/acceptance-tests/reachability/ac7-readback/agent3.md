# AC7 回读 Agent 3/3（原始作答）
题：列出至少 4 类致命操作及其具体识别特征（YAML 标识符 + 每类 ≥2 条特征）

data_loss（critical, forced_review: true）：DROP TABLE|DROP INDEX|DROP DATABASE；rm -rf、unlink batch、删桶；无备份 truncate/overwrite、DELETE FROM ... WHERE 1 / 无 WHERE
data_leak（critical, forced_review: true）：无鉴权暴露、process.env.(SECRET|KEY|TOKEN|PASSWORD) 打印/记录、移除鉴权、private→public；auth/*、middleware/auth*、api/admin/*
financial_loss（critical, forced_review: true）：支付/计费逻辑、定价修改、订阅/账单流、移除付费 rate limit；payment/*、billing/*
service_crash（high, forced_review: true）：生产部署配置、连接池参数、移除核心路径错误处理、timeout/retry；sudo|--force|--no-verify、chmod 777|666
通用：handoff_awareness（EXPECTED 不阻断）；risk_translation（business impact/可逆性/建议）

读取方式：12 文件各 1 次 Read 无 offset 并行；仅 Read；config-quality.yaml 返回 875 行（完整）。
六键判定：data_leak✓ financial_loss✓ service_crash✓ forced_review✓ DROP TABLE✓ DELETE FROM✓ → 全中
