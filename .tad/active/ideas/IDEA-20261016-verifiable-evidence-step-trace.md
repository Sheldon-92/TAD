---
title: 可复核的证据与步履层 — 让 TAD 的「干对了」能重跑、能查痕
date: 2026-10-16
status: landed
scope: medium
---

## Summary & Problem

TAD 的质量靠证据说话，但证据面有两个现行短板：

1. **验收证据常是叙事，不可重跑。** COMPLETION 与 verdict 里大量结论是文字自述，Gate 3/4 想核只能靠评审临场重跑命令、翻文件补——每次验收都在重复发明核查方法，且自报数字与盘面不符的事故出过不止一次（长文件截断自报、状态注记冒充事实）。
2. **步履靠自觉，无痕可查。** 规程步骤是否真按原件走、跳了哪一步、为什么跳，目前没有留痕形态；「凭记忆走流程」的静默漂移要到出事才暴露。步骤卡点检查器只能查产物在不在盘，查不了步履本身。

本 idea 借 pstack（Lauren Tan 的技能包，技术研究席 2026-10-16 精读评估）的证据与步履层做法，给 TAD 补一层「可复核性」基础设施。只借这一层，不动 Alex/Blake/Cora 的角色分离宪法。

## Proposed Solution — 四个组件

### 1. 项目 verify 技能＋feature map（证据可重跑）

项目仓可建 `.agents/skills/verify/`：Launch／Doctor／Drive／Evidence／Cleanup 五节＋按功能拆的 feature map。Gate 3/4 的证据要求增这一类**可选形态**：COMPLETION 引用 verify 的真实驱动证据（动作＋结果状态＋副作用回读），而不只是叙事。

关键性质（pstack 原做法的精华）：verify 技能生成后，**必须自己端到端跑通一遍才算交付**——验人的工具先过自己的验收；另有维护环，技能随项目演进更新。

### 2. 引用纪律（引判据必须真读过）

verdict 与 COMPLETION 只能引用**本链真读过的原件**，引用带节号。与 Knowledge Usage 转写互补：KU 记「读了什么」，此条管「引了什么」——引的东西必须在读单里。堵凭印象引判据（引错节、拿旧口径冒充现行）这一类真实出过的错。

### 3. Pilot 先行成硬步（批量开工先证伪一遍配方）

多单元 Phase 的规程增 pilot 步：先用 1 个单元证伪任务书模板＋验收配方＋单元粒度，拿证据修约后再 fan-out。数据线与本体 Epic 一直有这个实践，但停留在习惯、没进判据——本组件把它写成硬步。

### 4. 步骤逐字入清单＋skip 留理由（步履留痕）

规程步的执行清单采 pstack 的 playbook 纪律：步骤**逐字复制**进清单（不许凭记忆转述），跳步必须留一行 `skip: <理由>`。与步骤卡点检查器分工：卡点查产物在盘，此法查步履痕迹——跳步从隐形变成可审计。

## Open Questions（落地方式待议，本 idea 不预设）

- 组件 1 与既有资产的分工：`.tad/templates/acceptance-verification-guide.md`、capability-packs 已有近似面，verify 技能是替代、收编还是并行？feature map 粒度到哪一级算够、到哪一级算过细？
- 组件 3 的触发面：何为「多单元 Phase」（单元数？同构性？）要写成可判的口径；pilot 由该 Phase 既有 Gate 结构判还是另设出口，证伪结论落哪？
- 组件 2/4 的落点形态：进 canonical 判据、进模板、还是进检查器脚本——三者的执法强度不同，须逐组件选。
- 四个组件是一批落还是分批：它们同属一层但彼此独立，分批落各自的验证法怎么定。

## Status & Provenance

- 来源：技术研究席 pstack 借鉴提案乙部（`research_notes/lauren-tan-grok-bot-20261016/pstack-proposals.md`），TAD PM 2026-10-16 判断四件全采纳（判断正本 `.tad/evidence/pm/2026-10-16-pstack-proposals-judgment.md`），登记为自查批 R4 具名输入。
- 同批不借（在案）：pstack 的单路由器形态（与角色分离冲突）、Always-pause 人闸清单（粗于 TAD 现行人闸）。
- 下一步：与用户议定落地方式后，并入 R4 设计步或另立 Epic，本文件随讨论更新。

## 落地回写（2026-10-27，EPIC-20261027-r4-batch Phase 4）

- 组件 1（项目 verify 技能＋feature map）：分工与粒度判据见设计 P4-6（`.tad/evidence/yolo/r4-batch/phase1-design.md` §4），落点 `.tad/templates/acceptance-verification-guide.md` §10。
- 组件 2（引用纪律）：落点形态见设计 P4-2，落点 `.tad/templates/review-contract.md` §4（引用纪律款）与 §5（run 镜头引用抽查义务）＋`.tad/templates/completion-report.md` Evidence 节引用纪律镜像句与文末 Citation findings 节。
- 组件 3（Pilot 先行成硬步）：触发面与判方见设计 P4-7，落点 `.tad/gates/gate-canonical-checklist.md` Gate 2「Pilot declared」行＋`.tad/templates/handoff-a-to-b.md` §1 pilot 行＋`.agents/skills/alex/references/handoff-creation-protocol.md` step1 pilot 段。
- 组件 4（步骤逐字入清单＋skip 留理由）：落点形态见设计 P4-3，落点 `.tad/templates/completion-report.md` 步骤执行记录桩＋`.agents/skills/alex/references/handoff-creation-protocol.md` step1 逐字抄录句。
- 同批甲 1（空否决）：设计 P4-4，落点 `.tad/templates/review-contract.md` §2 裸否决 remark 段＋`.agents/skills/cora/references/conductor-protocol.md` step_Y4 item 5.0 与 step_Y6 item 4.0 两处 Route 段路由消费句。
- 同批甲 3（换人续跑 brief）：设计 P4-5，落点 `.tad/templates/resume-brief.md`（本 phase 新建）＋`.agents/skills/blake/SKILL.md` recovery 配置块后指针句。
- 同批甲 4（Claims vs Records）：设计 P4-1，落点 `.tad/templates/completion-report.md` Evidence 节内 Claims vs Records 子节。
