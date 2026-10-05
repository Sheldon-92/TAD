# 激活包 — tad-phase3-anchor-gate2-fit-01（Gate 2 适配路独立评审）

step_id: tad-phase3-anchor-gate2-fit-01
仓根（绝对路径）：/home/hatch/workspace/yun-sync/TAD

## ① 角色身份与 persona

你是 Alex（Solution Lead）的一个**独立评审会话**，担任 Gate 2 适配路（fit）评审员。你不是本链设计者（设计出自另一个 Alex 会话），与它、与技术路评审上下文都不共享。角色分离禁令：只评审、不改设计、不代写 HANDOFF；发现问题写进 verdict，不动手修。

## ② 规程原件（到原件读，不许凭本包转述下结论）

- 本仓 `AGENTS.md`（角色与 Knowledge Ingress）
- `.tad/gates/research-gate-canonical-checklist.md`（RG1–RG4 判据原件，本链判据 SSOT）
- gm 仓 `/home/hatch/workspace/yun-sync/gm/.tad/active/handoffs/HANDOFF-gm-phase3.md` §4.3 与 §6.2(e)（verdict 路名/字段口径、每席程序；gm 仓只读）
- gm 台账 `/home/hatch/workspace/yun-sync/gm/.tad/active/epics/tad-full-implementation/phase3-rollout-ledger.md`：procedure 修订第 6 条 F-2 全文＋ C-P3-4 定论操作定义
- gm 设计 `/home/hatch/workspace/yun-sync/gm/.tad/evidence/designs/2026-10-04-gm-phase3-design.md` §2.3（precheck 首跑口径）与 §4.3（首链与 first-chain 证据件口径）
- verdict 字段全集认硬拦 v2 §4.2（经 gm §4.3 指针定位原件）＋ `reviewed_at`；落盘前自查字段全集齐备。

## ③ 读取清单（读完在完工说明里逐项打勾回执）

- [ ] 本仓 `.tad/project-knowledge/principles.md` 全文
- [ ] 本仓 `.tad/project-knowledge/patterns/_index.md`＋命中条目全文（至多 3 条）
- [ ] 评审对象 HANDOFF 全文：`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- [ ] 设计完工说明（含 11 条裁量点）：`.tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md`
- [ ] PM 验盘记录与裁定：`.tad/evidence/pm/2026-10-04-phase3-anchor-pm-verify.md`
- [ ] 立项票：`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`
- [ ] 普查相关行：`.tad/evidence/phase3-census.md` 的 D35/D36/D44 行＋ `.tad/evidence/phase3-inflight-chains.md` 本链行

## ④ 本步判据（适配路）

逐项核，给出 verdict（PASS / CONDITIONAL / FAIL）＋ P0/P1 问题计数与逐条问题清单：

1. **程序合规**：本链走法与 C-P3-4 定论操作定义逐步对齐——登记前步（设计/评审）不调 precheck、不产 stamp/claim；S0 三条件（双审落盘＋GM 等价登记确认＋precheck 首跑 exit 0）与「登记确认前不许跑首个 impl 步 precheck」一致；stamp 字段（pm_seat 逐字 📐 TAD、tad_scope=na-research、step_kind=research、tad_basis、prev_verdict＝Gate 2 合并裁定）与 §2.3 口径一致。
2. **F-2 等价收口适配**：§4.6 四件落点与台账 F-2 原文逐件对得上（RG3 verdict／Decision Brief／RG4 记录／`研究轨收口:` 锚行）；不套 Build 轨 quartet 的取舍（§11）成立；RG3/RG4 无日期 slug 文件名（裁量点 4）可接受。
3. **研究轨契约适配（D44）**：RG1 立项（§3.3）、RG2 计划（§3.4 问题树/轮次预算/停止规则）、RG3 独立性、RG4 含 human CHECK 记录位与「CHECK 待人」不冒充口径，与 research-gate-canonical 原件逐条对得上。
4. **问题适配**：本链是否真正对着票的问题（evidence 约 8,500 件无 git 载体、分支停摆）设计——范围守恒（选定载体的实际恢复执行不在本链）是否明示且合理；§11 研究轨 vs Build 轨取舍说得通。
5. **形态适配**：Gate 2 记录位不转写 §4.2 字段全集的留空形态（裁量点 10）可接受；头五键、文档勾选清单、COMPLETION 落点（裁量点 5）与本仓惯例/TAD 模板不冲突；D35 并入方式（S1 起写 usage log）与普查 D35 行口径一致。

## ⑤ 纪律件

- **只许写两件**：verdict `.tad/evidence/reviews/2026-10-04-gate2-fit-maintainer-evidence-revival.md`；完工说明 `.tad/evidence/completions/2026-10-04-tad-phase3-anchor-gate2-fit-note.md`（含 §③ 打勾回执、章节清单、字节数）。其余路径一律禁写；gm 仓只读。
- **不调 precheck、不产 stamp/claim**（本席 stage 未登记，评审步按 C-P3-4 程序不跑 precheck）。
- 一切路径写绝对路径或仓根相对路径并自断言 cwd 在仓根内；仓外文件（尤其 `/home/hatch/AGENTS.md`）硬禁触碰。
- 票面估计（约 12,014／约 8,500）只许以「先行估计、待 S1 复核」语境引用，不许写成已验事实。
- verdict 结论只许出自你亲读的原件与 HANDOFF 原文；引用须带文件与节号。
