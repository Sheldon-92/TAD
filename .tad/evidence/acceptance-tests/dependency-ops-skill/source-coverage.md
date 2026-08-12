# dependency-ops skill 源覆盖映射

基准：LITE-20260811-2254-dependency-ops-skill.md 附录 A（源协议逐条抄录，经独立 reviewer 核验）。
执行者未打开源文件 `.claude/skills/alex/references/deps-protocol.md`（blake-lite Forbidden 排除）。

## 表 A：编号 Step（19 条）

| # | 编号 | 内容摘要 | SKILL.md 承载位置 | 状态 |
|---|---|---|---|---|
| 1 | S1 | 读 REGISTRY.yaml；不存在则建议 init | deps show 第 1 步 | MAPPED |
| 2 | S2 | 表格化 Name/Type/Version/Safety/Last Checked/Limitations | deps show 第 2 步 | MAPPED |
| 3 | S3 | 逾期告警 overdue by N days | deps show 第 3 步 + 定位与口径（公式） | MAPPED |
| 4 | A1 | 检查 registry 存在 | deps add 第 1 步 | MAPPED |
| 5 | A2 | 询问依赖名 | deps add 第 2 步 | MAPPED |
| 6 | A3 | 自动探测/手工询问 | deps add 第 3 步 | MAPPED |
| 7 | A4 | 富化流程（type/safety_tier 默认值） | deps add 第 4 步 | MAPPED |
| 8 | A5 | 追加 + 更新 last_updated + 校验 YAML | deps add 第 5 步 | MAPPED |
| 9 | K1 | 跑 deps-scan.sh 查上游 | deps check 第 1 步（含绝对 root + NO_AUTO_UPDATE） | MAPPED |
| 10 | K2 | 读 scan-results.yaml | deps check 第 2 步（yq -r 读法） | MAPPED |
| 11 | K3 | 汇总表 Dependency/Current/Latest/... | deps check 第 3 步 | MAPPED |
| 12 | K4 | 高亮安全公告/版本变更/错误跳过 | deps check 第 4 步 | MAPPED |
| 13 | K5 | 追问 changelog | deps check 第 5 步 | MAPPED |
| 14 | U1 | 解析目标名 | deps update 第 1 步 | MAPPED |
| 15 | U2 | 校验存在；不存在提示 | deps update 第 2 步 | MAPPED |
| 16 | U3 | 询问新版本 | deps update 第 3 步 | MAPPED |
| 17 | U4 | Edit 更新三字段 | deps update 第 4 步 | MAPPED |
| 18 | U5 | limitation 判定用当次 changelog | deps update 第 5 步 | MAPPED |
| 19 | U6 | 输出确认 | deps update 第 6 步 | MAPPED |

断言：19/19 MAPPED，无 UNMAPPED。

## 表 B：Constraints / Notes（9 条）

| # | 编号 | 内容摘要 | 承载位置 | 状态 |
|---|---|---|---|---|
| 1 | C-A1 | 不得覆盖同名已有条目 | deps add 约束行 | MAPPED |
| 2 | C-A2 | 已存在 → 询问改为更新 | deps add 约束行 | MAPPED |
| 3 | N-K1 | 扫描 15–30 秒 | deps check 边界 | MAPPED |
| 4 | N-K2 | registry: null 被跳过（点名 3 个） | deps check 边界（正文可执行措辞） | MAPPED（承重） |
| 5 | N-K3 | 安全公告 best-effort | deps check 边界 | MAPPED |
| 6 | N-K4 | 定时扫描 cron prompt | deps check 边界 | MAPPED |
| 7 | C-U1 | Edit 工具，yq 原地写规范化全文 | deps update 第 4 步 + 头部（正文可执行措辞） | MAPPED（承重） |
| 8 | C-U2 | 只更新目标条目，其余逐字节不变 | deps update 第 4 步（含 diff 验证手段）（正文可执行措辞） | MAPPED（承重） |
| 9 | C-U3 | 不确定 → 保持 false | deps update 第 5 步（正文可执行措辞） | MAPPED（承重） |

断言：9/9 MAPPED，无 UNMAPPED；承重 4 条（N-K2/C-U1/C-U2/C-U3）全部落进正文可执行措辞。

## 表 C：deps_init（NOT-MIGRATED: Phase 5）

5 条 Step + 3 条 Constraints 全部标 NOT-MIGRATED: Phase 5（口径与附录 A.5/A.6 一致）。
SKILL.md 边界节已声明 init 未迁移及其理由。

## 对账

- 表 A 基准 19 条 ✅（S1-S3 3 + A1-A5 5 + K1-K5 5 + U1-U6 6）
- 表 B 基准 9 条 ✅（C-A1/C-A2 2 + N-K1..N-K4 4 + C-U1/C-U2/C-U3 3）
- 承重 4 条全部落正文 ✅
- deps_init 5+3 全部 NOT-MIGRATED ✅
- 无 UNMAPPED ✅
