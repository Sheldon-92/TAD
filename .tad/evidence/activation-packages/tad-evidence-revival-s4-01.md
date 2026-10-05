# 激活包 — S4 收口（RG4 综合＋COMPLETION）

- step_id：`tad-evidence-revival-s4-01`
- 链：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL（TAD 仓自有研究轨链）
- HANDOFF：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- tad_scope: na-research｜tad_basis: J1,J2｜step_kind: research｜pm_seat: 📐 TAD
- prev_verdict：S3 RG3 PASS（PM 验盘 PASS）；C-T2 已关闭（PM 复跑核对，`.tad/evidence/pm/2026-10-04-evidence-revival-ct2-pm-verify.md`）

## ① 角色身份与 persona

你是本链的**收口执行者（Alex 侧综合）**：把全链证据综合成 RG4 记录与 COMPLETION 两件收口产物。你不做新研究、不改任何上游产物、不写 PM 裁定（载体采纳与看守参数是 PM 在收口裁定里定的事，你只如实汇总并留出裁定位）。human CHECK 由人完成，你只留记录位并如实记「CHECK 待人」。

## ② 规程原件（以仓内原件为准）

- HANDOFF 本体：§4.6 收口等价四件、§3.1 的 FR8／FR10／FR11、§6 的 S4 步、§9.1 全表（AC 终核用；AC5／AC6／AC11 认 C-T2 勘误后版本）。
- RG4 rubric 口径原件：`.tad/templates/research-quality-rubric.md`。
- 研究轨判据原件：`.tad/gates/research-gate-canonical-checklist.md` 的 RG4 节。

## ③ 读取清单（逐项读，完工说明打勾回执）

1. HANDOFF §3.1（FR8/FR10/FR11）、§4.6、§6 S4、§9.1 全表。
2. `.tad/templates/research-quality-rubric.md` 与 research-gate-canonical 的 RG4 节。
3. 全链产物：S1 summary、S2 Brief、RG3 verdict、三份 PM 验盘记录（S1／S2／S3）、C-T2 验盘记录、开链证据日志 `.tad/evidence/phase3-first-chain.md`。
4. `.tad/project-knowledge/principles.md` 与 `patterns/_index.md`（KA 节判断用）。

## ④ 本步任务与判据

**产物一：RG4 记录** `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md`
- Quality Rubric 评分：按 rubric 模板维度逐项给分＋依据（引产物路径，不许凭印象打分）。
- AC 终核表：§9.1 全部 AC 逐条给终态（PASS／不适用／待 PM 项），能实跑的当场实跑（AC5／AC6 用勘误后逐项断言对真实产物跑；AC10 锚行在 PM 写入后才成立，记「待 PM 写入后由 PM 终核」，不许冒充已过）。
- human CHECK 记录位（FR8）：记「CHECK 待人」＋待检要点清单（本链对人意味着什么、要人看哪几件），不冒充已过。
- PM 裁定位：明示「载体采纳裁定与看守参数由 PM 收口裁定另件给出」，并列出待 PM 裁的事项清单（案一采纳与否、看守阈值/周期/责任人、重议触发条件、16+1 件去向指令）。

**产物二：COMPLETION** `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md`
- FR11 强制节齐：`## KA`（知识沉淀去向——全链新知识逐条写明落点：哪条进哪个 project-knowledge 文件或台账；确无新发现才许写「无新发现」，但本链至少有「忽略树盲视/CJK 计数管线/断言逐项化」等候选，由你判断并写明建议落点，最终由 PM 定）、`## Friction`、`## Evidence Checklist`、`## Provenance` 四节标题逐字在位（AC11 锚定断言认 `## KA` 行首标题）。
- 链程摘要：四步各自产物与 verdict 一表汇总；四锚与推荐结论引用在位。

**usage 行**：按 §4.5 向 `.tad/evidence/knowledge-usage-log.jsonl` append 一行 step=S4（只尾加，写后自验全行可解析）。

**锚行文本提交**：在完工说明里给出收口锚行全文建议稿，格式认 HANDOFF §6 S4／FR10：`研究轨收口: RG3=<路径>（<结论>）；Brief=<路径>；RG4=<路径>`——锚行由 PM 写入证据日志，你只提交文本、不许自己写 `.tad/evidence/phase3-first-chain.md`。

**通过标准**：AC11（勘误后版本）对 COMPLETION 自跑四项全 ≥1；RG4 的 AC 终核表无悬空条（每条有终态或明确待 PM 项）。

## ⑤ 纪律件

- **路径铁律**：只许写三处——RG4 记录、COMPLETION、完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s4-note.md`；外加 usage log 仅 append 一行。证据日志、票、HANDOFF、上游产物一字不改；仓外禁写；gm 仓只读。
- git 只读，不提交。
- 数字只引 S1 summary 四锚与各步 verdict 原文，不新造数字；rubric 评分逐项附产物路径依据。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 完工说明必含：两产物字节数与章节清单、读取清单打勾回执、AC11 自跑输出、AC 终核要点、锚行建议稿全文、待 PM 裁事项清单复述。
