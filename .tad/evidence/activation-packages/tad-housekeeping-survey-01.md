# 激活包 — B 批次自家欠账只读普查

- step_id：`tad-housekeeping-survey-01`
- 事项：TAD 本体自维护 B 批次（普查存疑处置的前置事实普查）
- 范围声明：**全程只读**。你只产一份普查报告，不改任何文件、不移任何文件、不回写任何状态。处置由 PM 看了你的报告再定。
- pm_seat: 📐 TAD

## ① 角色身份

你是 PM 的普查执行者：把四件事的盘面事实逐件查清、列全，每条事实附盘上路径与原文摘录（状态行逐字引）。不许推断补空——盘上查不到的就写「查无」，并写明查过哪些位置。

## ② 背景原件（先读，作对照基线）

1. `.tad/evidence/phase3-census.md` 中 D36 条与普查存疑相关行（归档结构口径）。
2. `.tad/evidence/phase3-inflight-chains.md`（10 条在飞链清单，含 claude-removal 与 hillclimb 两链的当时记录）。

## ③ 普查四项（逐项查，报告逐项成节）

1. **已收口链未迁 archive**：枚举 `.tad/active/handoffs/` 全部 HANDOFF 与 `.tad/archive/` 现有结构；逐条链判定其收口证据是否齐（COMPLETION 或等价收口件在盘），列出「已收口但 HANDOFF 仍在 active」的全名单，并注明 archive 侧的预期落点形态（对照 archive 里已有链的放法）。
2. **claude-removal 链**：该链全部盘上件清单（票、HANDOFF、评审、裁定、COMPLETION 有无逐项列）；HANDOFF 的 status 原文逐字引；最新一份评审/裁定件的路径与结论原文摘录；明确回答：它缺哪一件、状态停在哪一步。
3. **三条已收口链 HANDOFF status 未回写**：在第 1 项名单中，逐条引 HANDOFF 的 status 原文与收口证据路径，标出哪三条（或实际条数）属于「事已收口、status 还停在未收口表述」。
4. **hillclimb 链查盘一致性**：枚举该链盘上件，与 `.tad/evidence/phase3-inflight-chains.md` 中该链记录逐项对照，列出不一致处（当时记录有而盘上无、盘上有而记录无、状态表述不符），以盘面为准给出该链当前真实件清单。

## ④ 产物与判据

- 产物：`.tad/evidence/pm/2026-10-04-housekeeping-survey.md`，四节对应四项，每项末尾给「建议处置」一行（只建议，不执行）：可选处置词——回写 status／迁 archive／补件（注明补什么）／如实标注缺件／无须动。
- 判据：四项全查、全名单无遗漏（active HANDOFF 总数与逐条判定数对得上）；每条事实有路径；status 类事实逐字引原文。

## ⑤ 纪律件

- 只许写普查报告一处；仓内其他文件只读；仓外禁写；gm 仓只读。
- git 只读（log/status）。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 报告必含：字节数、active HANDOFF 总数、四项各自的结论行。回 PM 的简短结论里给出：四项各一句话＋建议处置条数。
