# Gate 4 验收 — R3 现行线补落（re-land）整票终判

- 验收人：Alex（Solution Lead 激活壳，Gate 4 验收会话；未参与补落实施与本轮双审）
- 日期：2026-10-08
- 被验对象：票 `/home/hatch/workspace/yun-sync/TAD/.tad/active/TICKET-20261006-self-review-r3.md` 全批（三组）在现行 main 上的终态
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 4 节＋票 Done 标准；方法＝从盘重算（Canonical verify-delta：被验方自述不作证据）
- 现行线谱系（盘面实测）：`fec93f33 → 2d0929f2 → 124b5533 → 834ff199`（HEAD）

## Verdict：PASS（无条件）

整票 Done 逐项在现行线盘面成立（见下逐项复算）；链完整、无未关闭条件；票可由 PM 正式 CLOSED（结论见 §4）。

## 激活自报

- 激活壳：`~/workspace/skills/tad-alex/SKILL.md` 全文，按其激活协议在目标仓 `/home/hatch/workspace/yun-sync/TAD` 执行。Step 0 断言：票绝对路径实存（4,471 B）。
- 实读原件（逐件路径）：
  - `/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（全文，含 Runtime status 与 C-12 Known Gaps 条目）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/principles.md`（全文）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/_index.md`（全文）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/gate-design.md`（Gate 4 Verification Integrity 等相关段）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/ac-verification.md`（相关段）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/brain-index.md`（路由段：Principles／Patterns／Project Knowledge 表）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/tasks/gate-execution.md`（Gate 4 节）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/gates/gate-canonical-checklist.md`（Gate 4 节，判据 SSOT）
  - 票本体、`.tad/evidence/pm/2026-10-06-r3-gate4-final-ruling.md`（借 4 终裁件）
- patterns 选中 2 条（≤3 上限）：Gate Design（Gate 4 须从一手证据重算、查 git status）、AC Verification（复算命令须对真实工件实跑）。
- brain-index 路由命中：Principles 表 Four-Gate／Measure Before Optimizing 行；Patterns 表 Gate Design／AC Verification 行。本步为仓内验收，无跨库检索需求。
- 与任务书冲突：无。

## 1. 整票 Done 逐项终判（现行线口径，全部亲跑复算）

### 组 1 — 状态面关键词冲突断言（check8）：成立

- 谱系：`git merge-base --is-ancestor 2d0929f2 HEAD` ＝在线；提交题名 `[R3-G1] state-surface check8: keyword-conflict assertion (re-land)`。
- 身份桥接：补落 Gate 3 CODE 评审已以 sha256 比对原线 `0099fbc0` 版脚本与现行 HEAD 版（其项 1 身份 PASS），本验收采信该独立复算并自验活仓终态如下。
- 活仓终态亲跑：`bash .tad/hooks/lib/state-surface-check.sh --repo .` → **exit 0**；输出含 `PASS check8: PAIR-1 governed block carries no stale pattern contradicting the fact source` 与 INFO check8 登记卫生行；check1–6 全 PASS、check7 INFO。check8 实现在 `.tad/hooks/lib/state-surface-check.sh` 在册（grep 命中）。

### 组 2 — 借 4 解冻评估实验：成立

- 实验件在盘：`.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/` 含 experiment-report.md、build-record.md、run-trace.md、questions/expected-subset-13、authority-manifest before/after、trial-index。
- 判读复算（报告原文）：incidents Recall@3 ＝ **8/8**（基线 4/8）、Recall@1 ＝ 8/8（基线 2/8）、无答案误报 ＝ **0**；冻结判据线（Recall@3 ≥ 6/8 且误报 ≤ 3）两条同时成立 → 判读「建议立项」与判据机械套用一致。
- 终裁件在盘：`.tad/evidence/pm/2026-10-06-r3-gate4-final-ruling.md`——终裁「立项、限定范围」四条边界（首批只覆盖 incidents 面；只立文本路由、向量后端与 ChromaDB 许可继续挂账；后续实验预登记恰返 3 候选并注明本轮证据按 @1 强度计权；构造纪律冻结），与实验判读（建议立项）方向一致，限定属 PM Gate 4 终裁权内，与票面「借 4 正式立项与实现不在本批范围」不冲突。

### 组 3 — C-12 台账补建（Plan B）：成立

- 谱系：`5b6617ad`（Plan B C-12）`merge-base --is-ancestor` ＝在线。
- freshness 终值亲跑：`bash .tad/hooks/lib/release-verify.sh freshness .` → **Total: 31 entries | PASS: 29 | WARN: 1 | BLOCK: 1**，与登记终值逐字相同。WARN/BLOCK 恰为预登记残差 codex 两条（context_compaction BLOCK、trace_evidence_capture WARN，日期未动），归 10-10 补测小单／TASK-20260916，非本票缺陷。
- AGENTS.md Known Gaps 的 C-12 条目已具名在册（激活时实读确认）；C-5/C-11 维持 deferred 原写法（同段实读确认）。
- 批内未升版：`.tad/version.txt` ＝ **3.2.0**（亲读）；state-surface check1–3 亦以 3.2.0 全 PASS 为旁证。

## 2. 链完整性

- 原线评审件在盘齐全：gate2-fit.md（13,429 B）／gate2-tech.md（13,795 B）／gate3-code.md（17,714 B）／gate3-safety.md（11,840 B）／gate4-alex.md（14,557 B，Verdict PASS）。
- 补落双审件在盘：gate3-reland-code.md（**8,153 B**，Verdict PASS、四项重算逐项全等、无条件项）／gate3-reland-safety.md（**6,412 B**，Verdict PASS、无条件项）——字节数与任务书 prev_verdict 记值逐字相同。
- 未关闭条件：无。原线 Gate 3 CODE 唯一条件 F-1 已在原线 Gate 4 定点核销；补落双审均无条件 PASS。
- 谱系桥接：补落记录 `.tad/evidence/self-review-r3-20261006/reland-closeout-note.md`（4,488 B）在盘；`124b5533`「chain closeout records on current main lineage (re-land)」把票收口节（+8 行）与链务件带入现行线，叙述（丢失线 → Plan B 组 3 先行 → 组 1 同哈希重落 → 现行线收口）与盘面谱系、评审件被审对象清单一致。
- COMPLETION 两件在盘：全批件 14,357 B（含 Knowledge Assessment 节，grep 命中 6 处）＋ C-12 Plan B 件 7,308 B。
- git status 观察（非本票阻塞，记 PM 收口处理）：工作区有 `docs/pm/status.md` 未提交修改与补落 Gate 3 四张卡未跟踪——均属 PM 链务落账面；其中 status.md 席位身份行按任务书口径留 PM 另行处置、不属本票。

## 3. Canonical Gate 4 四项对照

- Functional acceptance：Done 逐项成立（§1），无 open post-implementation blocker（属本票者）。
- Quality evidence complete：CODE 评审件（原线＋补落）✓；SAFETY 评审件（原线＋补落）✓；performance/UX 不适用（本批无性能/UI 面，原链同口径）。
- Subagent issues resolved：无 open P0/P1；F-S2 两处属前存残面、已登记 R4（见 §4），非本票引入。
- Knowledge Assessment：COMPLETION 含该节 ✓（另 usage-log 转写已在原线 Gate 4 收口记账）。

## 4. 可关票结论与残项去向

**结论：票可由 PM 正式 CLOSED。** 票内「收口」节已随 `124b5533` 入现行线（CLOSED 字面、借 4 终裁、连带登记俱在）；本验收确认其内容与现行线盘面终态一致，关票与归档的机械动作留 PM 执行。

残项去向逐项确认有着落：
- R4 输入面（终裁件 §二登记）：借 4 立项实施（具名首项）、F-S2 freshness 两处非 fail-closed 残面、AC 字面 dry-run 常设化议题、candidate 冻结目录去向呈报、R3 救援备份另立票。
- 10-10 补测小单：Codex 真机基线补跑＋台账 C 类 2 条补测（freshness 残差即其对象），now.md 挂账在册（「Codex 基线 2026-10-10」）。
- status.md 席位身份行：不属本票，留 PM 另行处置。

观察一项（不阻塞关票）：`docs/pm/now.md` 进度块仍记旧尖 `c3573326` 且挂账含「R3 组1/组2」——补落已在其后发生，建议 PM 关票时同步回写 now.md。
