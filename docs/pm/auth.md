# TAD · 授权档位（准入三件套）

> 引用 SSOT：`云同步/grok-cloud/docs/pm-charter.md` §4 与「文档线 L2」。本文件只写本项目落地注意。

## L1
只读、巡检、整理指针、更新台账/状态叙述（不改产品意图）。

## L2
- 站立目标内派 Alex/Blake（已授权模型，grokbox OpenCode）
- 可逆文档/证据落盘；节点验收；Routine Gate 4 由 Alex 收口（不问人「要不要验收」）
- **文档线**：本项目 docs 线 Gate 4 PASS 后 → 终稿改名 + commit + push（做完报）

## L3（先问）
- 删/重建/重启、共享配置、大额花费、密钥
- 非文档线 commit/push；未过 Gate 4 的提交
- **release / tag / publish / 官方 install 与升级路径**（含对外发版、改安装脚本默认行为）
- 扩大框架范围、新合作条款、默许业务仓私改上游当正式补丁
- 新开其它项目经理；同步冲突挑边

## 硬禁区
凭证不进仓库；不替 Blake 改实现；不默修红灯；不从业务仓私下 patch 上游顶掉正式流程。

## 派活前载体（共享规则）

- 规则 SSOT：`/home/box/云同步/grok-cloud/docs/pm/human-operating.md` §§3.7b、3.7d、3.10。共享薄模板：`/home/box/云同步/grok-cloud/docs/pm/templates/open-run-card.md` 与 `/home/box/云同步/grok-cloud/docs/pm/templates/restate.md`。
- **开跑卡双写与顺序**：卡片先落盘，并将同一正文完整发到 PM↔人 1:1；然后记录匹配本步的 stamp；最后才启动包装。盘上有卡或 stamp 不能单独证明 1:1 已发送。
- **复述门**：复述文件须已存在、非空，并留下人确认“理解对了”的迹；没有复述路径不得开跑。
- **Blake 依据边界**：`*discuss` / `*research` 等旁路产物、复述卡或开跑卡都不能充当 Blake 的 `handoff_path`；正式派 Blake 时，该字段只能指向 `HANDOFF-*.md`（见共享 HO §3.7d）。
