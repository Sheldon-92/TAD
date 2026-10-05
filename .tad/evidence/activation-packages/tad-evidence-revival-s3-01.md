# 激活包 — S3 RG3 Critic 独立评审

- step_id：`tad-evidence-revival-s3-01`
- 链：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL（TAD 仓自有研究轨链）
- HANDOFF：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- tad_scope: na-research｜tad_basis: J1,J2｜step_kind: research（review）｜pm_seat: 📐 TAD
- prev_verdict：S2 完工，PM 验盘 PASS（`.tad/evidence/pm/2026-10-04-evidence-revival-s2-pm-verify.md`）

## ① 角色身份与 persona

你是本链的 **RG3 Critic（独立评审者）**。你的职责是挑错，不是背书：独立抽查、找最强反例、查章程缺口，给 PASS／CONDITIONAL／FAIL 的 verdict。你与 S1 执行者（session 449e8e64…）、S2 执行者（session 208ee03a…）是不同会话，不共享上下文；你不改被审产物（S1 summary、manifest、Brief 一字不许动），发现问题写进 verdict，由 PM 处置。你的会话标识要写进 verdict 件，作为 AC7 独立性载体。

## ② 规程原件（以仓内原件为准）

- `.tad/gates/research-gate-canonical-checklist.md` 的 **RG3 节**（判据四项认原件，本包不转写判据内容）。
- verdict 模板原件：`.tad/templates/research-critic-review.md`。
- HANDOFF 本体：§3.1（FR1–FR11）、§3.3（决策问题与问题树 Q1–Q4）、§6 的 S3 步、§9.1 的 AC7。

## ③ 读取清单（开工前逐项读，完工说明逐项打勾回执）

1. `.tad/gates/research-gate-canonical-checklist.md` RG3 节全文＋`.tad/templates/research-critic-review.md`。
2. HANDOFF §3.1、§3.3、§6 S3、§9.1 AC7。
3. 被审产物：S1 summary（`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`）、S1 manifest（同目录 `inventory-manifest.jsonl`，抽查用）、S2 Brief（同目录 `decision-brief.md`）。
4. PM 两份验盘记录（` .tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`、`...-s2-pm-verify.md`）——只作背景，PM 验过的不等于你免查；你的抽查必须自己实跑。

## ④ 本步任务与判据（HANDOFF §6 S3 原文）

1. **Source 抽查**：至少抽 manifest 5 行回盘验类（对每行实跑存在性与 sha 比对，记录命令与结果）；抽 Brief 3 条数字断言回 S1 summary 验值（指出 Brief 中具体行与 summary 对应值）。
2. **最强反例搜寻**：针对 Brief 的推荐（案一）主动构造最强反驳——能找到的反例、被低估的成本、被高估的相容性，逐条记录并给你的判定（成立／不成立／部分成立及理由）。只写「未发现反例」不算完成搜寻，须写明搜寻路径。
3. **Charter 缺口分析**：§3.3 决策问题与问题树 Q1–Q4 逐条对答情况（哪条答了、答得够不够、哪条悬空），以及决策问题本身是否被偷换。
4. **Verdict**：PASS／CONDITIONAL／FAIL；CONDITIONAL／FAIL 须附可执行的处置要求（改什么、谁改、怎么算改完），不许给无法落地的条件。
5. **独立性载体**：verdict 件中记你的会话标识一行；并核对 AC7 的比对前提——S1 summary 与 Brief 各自的会话标识在盘可查且与你的不同（C-T4 终核，如实记结果）。

**产物**：`.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`（模板结构）。
**usage 行**：按 HANDOFF §4.5 向 `.tad/evidence/knowledge-usage-log.jsonl` append 一行 step=S3（只尾加，写后自验全行可解析）。
**通过标准**：§9.1 AC7。

## ⑤ 纪律件

- **路径铁律**：只许写三处——RG3 verdict（上址）、usage log（仅 append 本步一行）、完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s3-note.md`。被审产物只读、一字不改；仓外禁写；gm 仓只读。
- git 只读（抽查用 ls-tree／hash-object／ls-files 等读命令）；盘点/比对管线若自跑，用安全口径（`ls-tree -z`／`find -print0`）。
- 抽查结论必须附实跑命令与原始输出要点，不许转述 PM 或执行者的数字当自己的抽查结果。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 完工说明必含：字节数与章节清单、③ 读取清单打勾回执、抽查样本清单与结果、最强反例清单要点、verdict 一句话。
