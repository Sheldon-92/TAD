# REQ · TASK-20261006-SELF-REVIEW-R3-C12

task_id: TASK-20261006-SELF-REVIEW-R3-C12
parent_ticket: TICKET-20261006-self-review-r3
task_type: blake-impl-redispatch
role_path: Blake 实施（C-12 台账补建；R3 组 3）
redispatch_of: lost tip 4ad330e1 (object missing; GM plan B 2026-10-06)
gate2: PASS

## Why / 为什么

C-12 曾在坏 tip `4ad330e1` 上提交，但 commit object 与新 blob 未进 box/Mac/origin；工作树仍停在 Gate2 PASS 父尖 `26637423`。须从该父尖**重做** C-12，不得依赖找回 MuseVM 对象。

本刀只关 R3 组 3（C-12）。组 1（状态面冲突断言）与组 2（借 4 实验）仍属父票范围，**本 REQ 不交付**，另开或随后同批续派。

## Source / 出处

1. 父票 `.tad/active/TICKET-20261006-self-review-r3.md` §范围-3 C-12 台账补建（人令「采纳了就改吧」2026-10-06）。
2. 设计正本 `.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md` ＋ 增补 `.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3-SUPPLEMENT-1.md`。
3. Gate 2 合并 PASS：`.tad/evidence/pm/2026-10-06-r3-gate2-merged-ruling.md`（SUPPLEMENT-1 核销后转 PASS）。
4. 补充件判断：`.tad/evidence/pm/2026-10-06-supplement2-judgment.md` ＋ `…-supplement3-judgment-addendum.md`（C-12 默认「建」）。
5. **PM定**：本刀为 GM 拍板 Plan B 后的 C-12 **重派**；时区本机 `-0400`；禁 force 远端；坏 tip 只考古不阻塞。

## Acceptance / 验收

1. `.tad/runtime-compat/opencode.md` 与 `.tad/runtime-compat/cursor.md` 已建，字段同构现行 `codex.md`；首填含 P3 落地件版本＋2026-10-06 活体 PASS 指针。
2. 两份台账纳入 freshness 校验面（缺文件/坏行 fail-closed）；复跑有终值。
3. 触发条件落字：hooks 投影件变更当轮必复核该两台账。
4. `AGENTS.md` Known Gaps：Deferred 行去掉 C-12，改为具名 C-12 条目；**C-5/C-11 维持原 deferred 写法不动**。
5. 提交用本机时区 `-0400`；可 `git cat-file -t HEAD`；不依赖已丢弃的 `4ad330e1`。
6. COMPLETION 回填 runner 汇总退出码一行（Gate2 fit F-3）。

## Non-goals / 不做什么

- 不实施 R3 组 1 / 组 2。
- 不升版、不打 tag、不开 GitHub Release。
- 不改 C-5/C-11 正文；不顺手改 publish-protocol 人工回读终态以外的面。
- 不 force push；不从 MuseVM 考古对象当正式 tip。
- 不派 Cursor 作 Blake；Codex 冻至 2026-10-10 前不派 Codex。
