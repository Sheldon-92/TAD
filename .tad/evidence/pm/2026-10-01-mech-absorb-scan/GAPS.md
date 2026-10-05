# GAPS — TASK-20261001-mech-absorb-scan

Verdict: CONDITIONAL
continue: no

检查对象是当前 TAD 工作树（包含已存在的未提交 PM 文档），不是已发布版本。yes 表示盘上有直接载体；不代表外部聊天、私有脑或包装实际执行已独立验证。候选任务统一为 `TASK-20261001-TAD-PM-MECH-DOCS-ABSORB`，只点名，不派活。

| hole | TAD path checked | absorbed? | gap / next-knife candidate name if no或partial |
| --- | --- | --- | --- |
| 开跑双写：盘卡 + 1:1 可见 + stamp | `docs/pm/open-cards/open-20261001-mech-absorb-scan-alex.md`; `docs/pm/chat-card-stamps/stamp-20261001-mech-absorb-scan-alex.md`; `docs/pm/segment-status/seg-20261001-mech-absorb-scan.md` | partial | 本刀六字段、复述、stamp、段状态齐；stamp 自述 chat_sent=yes、消息 t144s1118。无本仓通用 open-run 模板或可发现的本地硬规则承载“先发全文→stamp→包装、只落盘不得开跑”。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| 复述 hard gate | `docs/pm/restates/restate-20261001-mech-absorb-scan.md`; 同刀 open-card | partial | 本刀有理解正确迹和无路径禁止派活，未发现本仓通用 restate/open-run 模板要求非空文件、确认迹及包装变量对齐。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| Gate4 盘⇄私有脑双写 | `docs/pm/ops-knowledge.md` §盘⇄私有脑; `docs/pm/evidence/dual-write-once-20260921.md`; `docs/pm/acceptance.md` | partial | 9/21 约定及一次两勾已有；无本仓 PM closeout 模板承载每刀盘/脑指针或“本刀无项目记忆”显式分支。9/21 自述不能证明本刀脑写完成。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| KA 必须显式完成 | `.tad/config-quality.yaml` Gate3/Gate4; `.tad/templates/completion-report.md` §Knowledge Assessment; `.tad/templates/deliverable-completion.md`; `.agents/skills/alex/references/acceptance-protocol.md` | yes | TAD 原生 KA 已有 required/blocking 与无发现理由；保留其既有分支。PM 正式交付卡的 KA/无新发现字段尚缺，与上一行共同落在 PM 文档候选范围；本 discuss 不冒充 Gate3/4。 |
| 禁裸 WAIT：Phase/Epic/门4/完事停工须候选或 HOLD 原因+解锁人 | `docs/pm/acceptance.md`; `docs/pm/segment-status/seg-20261001-mech-absorb-scan.md`; `.tad/templates/epic-template.md` §Context for Next Phase; `.tad/templates/session-state-template.md` §Next Action; `.tad/templates/next-md-template.md`; `.tad/templates/completion-report.md` PM-Next | partial | 有下一步/phase 结构，但未发现 next_knife_candidate 或禁裸 WAIT 的明确义务；模板自由文本不能等同候选名硬要求。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| 相关：完事/要拍只走 PM↔人 1:1，禁“群里只发要拍” | `docs/pm/acceptance.md`; `docs/pm/auth.md`; `docs/pm/status.md`; 本刀 stamp | partial | stamp 有 1:1 本刀记录；通用 PM exit 卡/群要拍硬禁未落本仓。未找到本仓实际“群里只发要拍”违规文案，缺规则不等于已发生违规。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| charter / intent / model-routing 指针，消除过期默认表 | `docs/pm/intent.md` §老板拍过的先例; `docs/pm/{acceptance,auth,status}.md`; `docs/model-routing.md`（不存在）; `docs/pm-charter.md`（不存在） | no | charter 外仓 SSOT 引用已有，但 intent 把 9/13 旧默认写成当前默认：Codex gpt-5.6-sol/luna、Cursor composer-2.5，与 10/1 锁冲突；其本仓 docs/model-routing.md 指针悬空。应只承载可解析路由/临时锁指针，不复制新硬编码表。候选：TASK-20261001-TAD-PM-MECH-DOCS-ABSORB。 |
| 当前刀模型记录 | `docs/pm/now.md`; 本刀 open-card | yes | 已记录 Alex Codex gpt-6.1-sol；只能证明本刀选型记录，不能抵消 intent 陈旧默认。 |

## 来源定位与边界

- `gm/.tad/evidence/pm/2026-10-01-mech-hole-patch/{STATUS,LAND,ACCEPTANCE}.md`：声称已在 grok-cloud 落 HO §3.8b/3.9、charter、exit/gate4 模板和 intent；不是 TAD 吸收证明。
- `grok-cloud/docs/pm/human-operating.md` §3.7b/3.7d/3.10：开跑卡全文 1:1、stamp、复述确认与包装顺序；§3.8b：候选或 HOLD 原因+谁解锁；§3.9：禁群要拍；§3.12：PM 门4、双写和 KA。
- `grok-cloud/docs/pm/templates/{open-run-card,exit-human-card,gate4-pm-closeout}.md`：直接对照载体。gate4 模板仍允许候选占位 `none`，后续不得照抄成允许裸空候选；以 HO §3.8b 的候选/HOLD 语义为准。
- `grok-cloud/docs/model-routing.md` 与 `gm/ops/codex-prefer-temp-2026-10-01.md`：新派 Alex/discuss/research gpt-6.1-sol；Blake/Review gpt-6-luna + CODEX_EFFORT=max；临时锁到期须再检，进行中不切模。
- HO §3.12 明写本轮只补 PM 操作层，不改 TAD 上游 SKILL/模板所有权。缺 PM 本地载体不构成批准 seat-persona、hooks、包装脚本或 Gate 所有权修改。
