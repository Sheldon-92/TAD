# AC7 Step 0 键双证明 —— fresh agent 真实作答（第二轮，原始，未修改）

问题：「列出至少 4 类致命操作及其具体识别特征：给出每类的 YAML 标识符，外加每类至少 2 条怎么认出来的特征。」

1. data_loss（数据丢失）— severity: critical, forced_review: true：破坏性操作清单（rm -rf, unlink in batch, truncation without backup, storage bucket deletion）；safety_net.always_review_patterns 正则 DROP TABLE|DROP INDEX|DROP DATABASE、DELETE FROM .* WHERE 1|DELETE FROM .* WITHOUT WHERE；always_review_paths 的 database/migrations/*
2. data_leak（数据泄露）— severity: critical, forced_review: true：敏感数据无 auth 暴露、日志打印 passwords/tokens/PII、移除鉴权检查、private→public；process.env.(SECRET|KEY|TOKEN|PASSWORD) 模式；auth/*、middleware/auth*、api/admin/* 路径
3. financial_loss（财务损失）— severity: critical, forced_review: true：支付逻辑/定价/订阅计费流改动、移除付费 API rate limit；payment/*、billing/* 路径
4. service_crash（服务崩溃）— severity: high, forced_review: true：生产部署配置变更、连接池变更、核心路径移除错误处理、timeout/retry 改动

另：handoff_awareness 核对 handoff 意图（EXPECTED 不阻塞）；risk_translation 输出业务影响卡片。

读取方式：12 文件各一次 Read 无 offset 并行；只用 Read；config-cognitive.yaml 返回 294 行（完整，fatal_operations L180-275 全读）。
