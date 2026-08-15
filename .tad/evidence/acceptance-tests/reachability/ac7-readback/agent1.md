# AC7 回读 Agent 1/3（原始作答）
题：列出至少 4 类致命操作及其具体识别特征（YAML 标识符 + 每类 ≥2 条特征）

data_loss（critical, forced_review: true）：DROP TABLE|DROP INDEX|DROP DATABASE；DELETE FROM .* WHERE 1 / WITHOUT WHERE；rm -rf、批量 unlink、存储桶删除、无备份 truncate/overwrite
data_leak（critical）：API 无鉴权暴露、private→public、移除鉴权；process.env.(SECRET|KEY|TOKEN|PASSWORD)；auth/*、middleware/auth*、api/admin/*
financial_loss（critical）：支付/定价/订阅计费变更、移除付费 rate limit；payment/*、billing/*
service_crash（high）：生产部署配置、连接池变更、移除核心路径错误处理、timeout/retry 改动
通用：handoff_awareness（EXPECTED 不阻塞）；safety_net 兜底 chmod 777|chmod 666、sudo|--force|--no-verify

读取方式：12 文件各 1 次 Read 无 offset；仅 Read；config-quality.yaml 返回 875 行（fatal_operations L779-875 完整）。
六键判定：data_leak✓ financial_loss✓ service_crash✓ forced_review✓ DROP TABLE✓ DELETE FROM✓ → 全中
