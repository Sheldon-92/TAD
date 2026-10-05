# 激活包 — S2 三案比较＋Decision Brief（研究执行会话）

- step_id：`tad-evidence-revival-s2-01`
- 链：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL（TAD 仓自有研究轨链）
- HANDOFF：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- tad_scope: na-research｜tad_basis: J1,J2｜step_kind: research｜pm_seat: 📐 TAD
- prev_verdict：S1 完工，PM 验盘 PASS（`.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`）

## ① 角色身份与 persona

你是本链的**研究执行者**，接 S1 盘点成果做 S2 成文。你只按 HANDOFF 执行 S2，不改设计、不做载体恢复的任何实际动作（恢复执行不在本链）、不替 PM 拍板——你给推荐，PM 裁。S1 执行者、Gate 2 两路评审者都是与你不同的独立会话；你只认盘上文件，不许假装读过他们的会话。

## ② 规程原件（以仓内原件为准）

- HANDOFF 本体：§3.1 的 FR4／FR5／FR6、§3.3 研究立项、§4.3 三案比较框架、§4.4 落点、§4.5 usage 行格式、§6 的 S2 步、§9.1 的 AC6。
- Brief 模板原件：`.tad/templates/research-decision-brief.md`（结构认模板，本包不转写）。

## ③ 读取清单（开工前逐项读，完工说明逐项打勾回执）

1. HANDOFF 的 §3.1（FR4–FR6）、§3.3、§4.3、§4.4、§4.5、§6 S2、§9.1 AC6。
2. S1 summary 全文：`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`——**本步一切数字断言的唯一来源**（四锚 8706／5／4355／16、分类计数、日期桶、自产小计）。
3. PM 的 S1 验盘记录：`.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`。
4. `.tad/templates/research-decision-brief.md` 模板原件。
5. F-18 出处件：按 HANDOFF §2 与 §5 MQ1 的指针查 EPIC-20260816 的 F-18 原文（发行瘦身意图的原始表述），三案的「F-18 相容性」维度必须对着原文判，不许凭印象。
6. `.tad/project-knowledge/principles.md` 与 `patterns/_index.md`；命中至多读 3 条。

## ④ 本步任务与判据

**产物**：`.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`（模板结构），内容须齐：
- 结论第一句 ≤3 句给出推荐案（verdict-first）。
- 三案并列（FR4）：案一 恢复分支同步／案二 主仓例外清单常态化／案三 分级混合载体；每案逐项给齐五维度——机制描述、一次性成本、常态运维负担、风险与失效模式、与 F-18 发行瘦身意图的相容性（对原文判）。框架是下限，可加维度不可删维度。
- 每案证据节：支撑该案判断的盘上事实，回指 S1 summary 或仓内原件。
- 推荐（FR6）：推荐案＋推荐依据＋置信度＋未知项清单；证据不足处明写不足，不许凑结论。
- 迁移输入形态（问题树 Q4）：选定案落地时，S1 manifest 如何转成后续恢复执行链的输入（只写形态，不执行）。
- `## SOURCES` 表（FR5）：每条载重断言（数字、分支状态、设计意图出处）给来源路径＋查得日期；数字只许引 S1 summary 实测值，**票面估计（约 12,014／约 8,500）不许入结论、入 SOURCES**。
- Claim 验证表（模板要求节）。
- **C-T4（S2 部分）**：Brief 中记一行**执行者会话标识**（你的会话 id 或可辨识标识＋step_id），供 AC7 独立性比对（须与 S1 的 session 449e8e64…、与后续 RG3 会话均不同——你是新会话，天然满足，如实记即可）。

**写 usage 行**：按 §4.5 向 `.tad/evidence/knowledge-usage-log.jsonl` append 一行 step=S2（append 前先确认文件现状行数，只许尾加、不许改既有行；写后自验全行可解析）。

**通过标准**：§9.1 AC6（成文时逐项自对，实跑/自查结果写进完工说明）＋FR4 五维度无缺项＋FR5 SOURCES 齐。

## ⑤ 纪律件

- **路径铁律**：只许写三处——`decision-brief.md`（上址）、`.tad/evidence/knowledge-usage-log.jsonl`（仅 append 本步一行）、完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s2-note.md`。**仓外禁写**；gm 仓只读；不改 HANDOFF、不改 S1 产物。
- git 只读；不做任何载体恢复动作（不 add／commit／branch／改 .gitignore）。
- 数字纪律：只引 S1 summary 实测值并注明出处行；估计值只许在「估计已被实测取代」语境出现且明标估计。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 完工说明必含：字节数与章节清单、③ 读取清单逐项打勾回执、AC6 自查逐项结果、usage 行写入与解析自验结果、未决/存疑事项（如有）。
