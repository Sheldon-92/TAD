# Gate Canonical Checklist (SSOT)
> THE authoritative definition of Gate 1-4 checklist items.
> All other files MUST reference this file, not duplicate items.
> Edit here FIRST, then propagate to gate/SKILL.md inline copy and other references.
> Last reconciled: 2026-06-23 (MECE pass)
> **装载纪律：放进文件的东西必须有装载点位。** 每条规程、模板与文件必须能指名它在哪个既有装载面、何时被读到或触发；指不出装载点位的条文等于没写。

## Gate 1: Requirements Clarity
**Owner:** Alex | **When:** After Socratic Inquiry, before *design

Checklist items:
- [ ] Problem defined — 问题定义清晰（Socratic Q2）. Why ME: 只检查"问题是什么"
- [ ] User identified — ICP 或目标用户已定义（Socratic Q1）. Why ME: 只检查"给谁用"
- [ ] Scope bounded (including edge cases) — 范围、排除项、边界条件明确（Socratic Q3a/Q3b）. Why ME: 只检查"做什么/不做什么/边界在哪"
- [ ] Acceptance criteria verifiable — 每个 AC 有可运行的验证方法. Why ME: 只检查"怎么验收"
  Method grammar (2026-09-10 verify-delta): a legal Verification Method is exactly one of
  command | path-check | fixture | rubric-spawn | light-tier N/A — prose-only cells are
  illegal (Gate 3 row FAIL), empty §9.1 still BLOCKS.

Why CE: What / Who / Boundary / How-to-verify — 四个独立需求维度。

## Gate 2: Design Completeness
**Owner:** Alex | **When:** Before handoff to Blake

Checklist items:
- [ ] Expert review complete (min 2). Why ME: 流程检查（审查是否发生）
- [ ] All P0 resolved. Why ME: 质量检查（问题是否修复）
- [ ] Architecture complete. Why ME: 高层设计存在性
- [ ] Components specified. Why ME: 组件级规格存在性
- [ ] Functions verified. Why ME: 代码级引用正确性（grep 可验证）
- [ ] Data flow mapped. Why ME: 数据流图存在性
- [ ] Risk card for high-risk handoffs — 高风险 handoff（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者）附风险卡（模板 `.tad/templates/dispatch-risk-card.md`，落盘 `.tad/evidence/risk-cards/risk-<task_id>.md`），证伪式假设表逐条成立（假设句＋证伪信号＋动作三列齐）；非高风险须在 Gate 2 节写明触发项核对结论. Why ME: 只检查"高风险派发的关键假设是否写明且可证伪"
- [ ] Load points declared — 本次新增/修改的每条规程、模板、文件逐项写明装载点位（装载面＋触发时点）；无装载点位的项判设计未完成. Why ME: 只检查"写下的东西读不读得到"

Why CE: 流程 + 质量 + 4 层设计检查。已 MECE ✅。

## Gate 3: Implementation Quality
**Owner:** Blake | **When:** After implementation (Ralph Loop complete)
# MECE: verified 2026-08-04 — 7 items check 7 distinct artifacts

Checklist items:
- [ ] Code/deliverable complete — all handoff tasks done. Why ME: 产出物完整性
- [ ] §9.1 Spec Compliance — every row verified. Why ME: AC 逐条验证
  Present-but-prose ≠ empty: any landing row whose Verification Method is prose-only FAILs
  that row → cannot Gate 3 PASS. Empty §9.1 still BLOCKS (separate guard).
  Evidence discipline (E维): 每行判定必须附证据指针（落盘路径＋行号/章节，或命令输出
  的落盘路径）；无指针的 PASS 不成立。被审方自报（Verified Output、完工说明中的
  数字与计数）与评审重算不符的行 → 该行 FAIL，且 Gate 3 整体不得 PASS（证据否决），
  不得以其他行结果抵消；不符属口径未注明者，须先注明口径再重算，仍不符按上行处理。
  Load-point claims: 声称某文件/条文构成装载或约束的 AC 行，Verification Method
  必须含位置断言（目标内容行号 ≤ 该载体单次可达范围）；只有 grep 在场不算装载成立。
- [ ] Evidence files exist — per handoff manifest. Why ME: 证据存在性
- [ ] Evidence replayable (advisory) — 证据采集命令重跑两次应 0 diff。若每次重跑都产生
      全量改动（随机 ID / 时间戳 / commit SHA 入了证据体），则任何一处改动都触发全量重采，
      reviewer 无法 diff 只能重读全文 → 先修证据管道再谈验收。Why ME: 证据管道确定性
- [ ] Git commit done — hash recorded (or NONE for doc-only). Why ME: 版本控制
- [ ] Knowledge Assessment complete — journal or "no discovery". Why ME: 知识捕获
- [ ] Provenance non-empty (advisory) — ≥1 row per CREATE file. Why ME: 生成可追溯性

Why CE: 产出 + 规格 + 证据 + 可重放 + 版本 + 知识 + 追溯 — 七个独立 artifact。

## Gate 4: Business Acceptance
**Owner:** Alex | **When:** After Gate 3 passes

Checklist items:
- [ ] Functional acceptance — §9 AC met AND no open post-implementation blockers (list any). Why ME: 只检查"功能达标+可交付"
  Fail-close (2026-09-10 verify-delta): cannot Gate 4 PASS if landing Verification Method missing or unrun.
  Gate 4 must recompute landing Verification Methods from disk; Blake summary is not Gate 4 evidence.
  Gate 4 复算发现自报与盘上不符的条目 → 该条目判 FAIL 并记入 gate4_delta，
  不得以被审方总结覆盖重算结果。
- [ ] Quality evidence complete (BLOCKING per Structural_Subagent_Conditionality) — 以下 evidence 逐项确认; FAIL must enumerate which are missing:
  - [ ] Code review evidence exists
  - [ ] Security review evidence exists (code/mixed only)
  - [ ] Performance review evidence exists (code/mixed only)
  - [ ] UX review evidence exists (if UI involved)
  Why ME: 只检查 evidence 存在性
- [ ] Subagent issues resolved — 所有 subagent 反馈中的 P0/P1 已处理. Why ME: 只检查问题修复状态
- [ ] Knowledge Assessment complete — distillation loop 或 "no new discovery". Why ME: 只检查知识记录

Why CE: 功能 + 证据 + 修复 + 知识 — 四个独立维度。无遗漏。
