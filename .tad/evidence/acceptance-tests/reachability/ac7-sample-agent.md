# AC7 Step 0 键双证明 —— fresh agent 真实作答（原始，未修改）

问题：「列出至少 4 类致命操作及其具体识别特征：给出每类的 YAML 标识符，外加每类至少 2 条怎么认出来的特征。」

基于 `.tad/config-cognitive.yaml` 的 `fatal_operations` 段（Pillar 3，`universal_preset` 定义 4 类致命操作，全部 `forced_review: true`）：

## 四类致命操作
1. `data_loss`（数据丢失，severity: critical）：操作含破坏性语句/命令 `DROP TABLE|DROP INDEX|DROP DATABASE`、`DELETE FROM ... WHERE 1`、`rm -rf`、批量 unlink、存储桶删除；覆盖 database/migrations/* 安全网路径；无备份的 truncation/overwrite 也算
2. `data_leak`（数据泄露，severity: critical）：涉及凭据/敏感信息（日志打印 process.env.(SECRET|KEY|TOKEN|PASSWORD)）；行为上是"放宽"类变更：移除鉴权/授权检查、数据可见性从 private 转 public
3. `financial_loss`（财务损失，severity: critical）：触碰 payment/*、billing/* 路径；支付逻辑、定价计算、订阅/计费流改动，或移除付费 API 的 rate limit
4. `service_crash`（服务崩溃，severity: high）：生产部署配置变更、数据库连接池变更；在核心路径移除错误处理、改动核心服务 timeout/retry 逻辑

通用判定：handoff_awareness 先比对 handoff 意图；risk_translation 命中后必须输出业务影响给真人审。

读取方式：12 个文件各一次 Read 无 offset，共 12 次；config-cognitive.yaml Read 返回 294 行（完整）；未用 Bash/Grep/Glob。
