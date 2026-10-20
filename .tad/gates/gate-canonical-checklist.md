# Gate Canonical Checklist (SSOT)
> THE authoritative definition of Gate 1-4 checklist items.
> All other files MUST reference this file, not duplicate items.
> Edit here FIRST, then propagate to gate/SKILL.md inline copy and other references.
> Last reconciled: 2026-06-23 (MECE pass)
> **装载纪律：放进文件的东西必须有装载点位。** 每条规程、模板与文件必须能指名它在哪个既有装载面、何时被读到或触发；指不出装载点位的条文等于没写。

## Gate 1: Requirements Clarity
**Owner:** the human (content: per-block playback) + Alex (content: "can design from it") + gate1-format-check.sh (format) | **When:** after the per-block playback is confirmed, before design (Cora: before the intake dispatch)

Checklist items:
- [ ] What the human gets / Not wanted — the Result contract lines `What the human gets:` and `Not wanted:`. Why ME: 只检查"给什么、不要什么"
- [ ] Done check per deliverable — a `Done check` block in `## Requirement` (handoff: §1.5) that can judge done / not done. Why ME: 只检查"怎么判完成"
- [ ] Decisions for the human listed; Premise and size (blast radius) stated. Why ME: 只检查"要他拍板的事、前提和规模"
- [ ] Estimate stated — **Budget**. Why ME: 只检查"估算"

Checked by: format -> `bash .tad/hooks/lib/gate1-format-check.sh <Epic | handoff | journal>` (advisory, exit 1 = something missing); content -> his confirmed playback and Alex's line "can design from it" (or the block it cannot). No self-score.

Why CE: 结果 / 完成判据 / 决策与规模 / 估算 — 四个独立条件。

## Gate 2: Design Completeness
**Owner:** Alex | **When:** Before handoff to Blake

Checklist items:
- [ ] Gate 2 review complete — two reviewers with different lenses (consistency + risk or fit; .tad/templates/review-contract.md). Why ME: 流程检查（审查是否发生）
- [ ] All P0 resolved. Why ME: 质量检查（问题是否修复）
- [ ] §9.1 Methods legal — command | path-check | fixture | rubric-spawn | light-tier N/A; prose-only illegal (Gate 3 row FAIL), empty §9.1 still BLOCKS (consistency lens baseline run). Why ME: 只检查"验证方法合法"
- [ ] Architecture complete. Why ME: 高层设计存在性
- [ ] Components specified. Why ME: 组件级规格存在性
- [ ] Functions verified. Why ME: 代码级引用正确性（grep 可验证）
- [ ] Data flow mapped. Why ME: 数据流图存在性
- [ ] Risk card for high-risk handoffs — 高风险 handoff（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者）附风险卡（模板 `.tad/templates/dispatch-risk-card.md`，落盘 `.tad/evidence/risk-cards/risk-<task_id>.md`），证伪式假设表逐条成立（假设句＋证伪信号＋动作三列齐）；非高风险须在 Gate 2 节写明触发项核对结论. Why ME: 只检查"高风险派发的关键假设是否写明且可证伪"
- [ ] Load points declared — 本次新增/修改的每条规程、模板、文件逐项写明装载点位（装载面＋触发时点）；无装载点位的项判设计未完成. Why ME: 只检查"写下的东西读不读得到"

Why CE: 流程 + 质量 + 4 层设计检查。已 MECE ✅。

## Gate 3: Implementation Quality
**Owner:** the Gate 3 run reviewer — not the builder (Blake prepares: completion report, journal, commit) | **When:** After implementation (Layer 1 and commit)
# MECE: verified 2026-10-19 — 9 items check 9 distinct artifacts

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
- [ ] ACs re-run by the run reviewer in one throwaway project copy — its verdict file's `## AC runs` table has every §9.1 AC row (or a not-run reason); every row compared with Expected Evidence. Why ME: 重算是否真跑
- [ ] Real paths covered — every real_path has a run row or "not-run: <reason>" (gate3-check.sh exit 0). Why ME: 真实路径覆盖

Why CE: 产出 + 规格 + 证据 + 可重放 + 版本 + 知识 + 追溯 + 脚本重跑 + 真实路径 — 九个独立 artifact。

## Gate 4: Acceptance by Real Use
**Owner:** an Alex acceptor that took no part — dispatched by Cora in her runs, by the designing Alex at *accept in direct mode; never Blake, never the designer | **When:** After Gate 3 passes

Checklist items:
- [ ] Acceptance by real use — what the human will do, done once for real or in a browser; evidence under the gate4 dir; judged against ## Requirement + Result contract. Why ME: 只检查"从人的一侧真跑过"
  Fail-close: cannot Gate 4 PASS if the Gate 3 run file's `## AC runs` table is missing or a row is neither run nor recorded not-run; Blake summary is not Gate 4 evidence; a self-report that disagrees with the run reviewer's AC runs -> that item FAIL and gate4_delta.
- [ ] Gate 3 evidence complete — every contract §8 lens file, gate3-check.sh exit 0 on the run file (FAIL enumerates missing). Why ME: 只检查 Gate 3 证据存在性
- [ ] Issues — every P0 resolved; open P1, Assumptions, not-run items and human-only items (real device, payment, own account login, with reason) listed for the human. Why ME: 只检查问题修复状态
- [ ] Knowledge Assessment complete — distillation loop 或 "no new discovery". Why ME: 只检查知识记录

Why CE: 真跑 + 证据 + 修复 + 知识 — 四个独立维度。无遗漏。
