# R3 Reland Closeout Note — 现行线补落记录（2026-10-08）

执行：Blake（原生派发，任务书 dispatch-2026-10-08-r3-reland）。本件记 R3 批在
2026-10-06 同步对象丢失事故后的补落经过与复验终值；不改判任何既有评审结论。

## 1. 事故与补落经过

- 原实施线：组 3 入提交 `4ad330e1`、组 1（check8）入提交 `0099fbc0`，原线走完
  Gate 3 双审与 Gate 4 PASS（评审件与验收件均在证据分支在册）。
- 2026-10-06 同步事故：关键提交对象在本机→grokbox 同步中丢失（坏 tip），原线
  提交未进现行 main 谱系。现行 main 经 Plan B 重建：组 3（C-12）由 `5b6617ad`
  重做落地并已推送；组 1 代码只剩工作区未提交修改；票文件收口注记、HANDOFF
  归档删除、13 张开跑/完事卡均只在工作区层面存在、未入现行线 git 记录。
- 本步补落（2026-10-08，用户令「所有都补完」后 PM 派发）：身份复核通过后，
  以两笔提交把组 1 实现与链务记录正式落入现行 main（见 §4），并对全套判据
  复验（见 §3）。未改实现一字、未动 Plan B 组 3 成果、未重跑组 2 实验、未 push
  （PM 统一推）。

## 2. 身份复核（Step 0 闸）

- `git show 0099fbc0:.tad/hooks/lib/state-surface-check.sh` 与工作区同路径文件
  `diff` 输出为空；sha256 双侧同为
  `d1ac0d7cadefe6c6b0f349974553772f5094f99742578ab800a443a5a111a676`。
- 对 HEAD 的 diff 为 +95/−0（`git diff --numstat` = `95 0`），与 `0099fbc0`
  自身写集（单文件 +95）一致。复核通过，未触发停步。

## 3. 复验终值（四项，2026-10-08 实跑）

1. 组 1 fixture：`g1-fixture-runner.sh` 退出码 0，五树全 ASSERT-OK
   （pos／neg／exempt／outside／undecidable）；锚缺失树（undecidable）退出码 1、
   FAIL check8 指名 `fact-source anchor missing`。日志：`reland-g1-fixture-run.log`
   ＋ runner 再生 `g1-fixture-summary.log` 与五树分日志。
2. 活仓 state-surface：退出码 0，含 `PASS check8: PAIR-1 governed block carries
   no stale pattern contradicting the fact source`；总结行 `state-surface: PASS
   (repo: ., version 3.2.0)`。日志：`reland-live-state-surface.log`。
3. freshness 复跑（`.tad/hooks/lib/runtime-freshness-verify.sh`）：钉死日期
   2026-10-06 与活日期 2026-10-08 两跑终值相同——**Total 31｜PASS 29｜WARN 1｜
   BLOCK 1**；残差恒为 codex 两条 C 类（context_compaction BLOCK、
   trace_evidence_capture WARN），台账日期未动。校验器退出码 1 为 BLOCK 在册时
   的设计值。日志：`reland-freshness-pinned-20261006.log`、
   `reland-freshness-live-20261008.log`。
4. 组 2 证据点名（只点名、未重跑）：`g2-borrow4-trial/` 共 33 件，实验报告
   `experiment-report.md`（6,174 B）在册，另 build-record、run-trace、同题子集
   题面/期望、试验前后权威面 manifest、trial-index（routing＋25 drawers）齐。
   清单：`reland-g2-rollcall.log`。

## 4. 补落提交（两笔）

- (a) 实现笔 `2d0929f2` — `[R3-G1] state-surface check8: keyword-conflict
  assertion (re-land)`：写集恰 1 件 `.tad/hooks/lib/state-surface-check.sh`
  （+95/−0），提交信息含 re-land 归因与身份哈希。
- (b) 链务笔 `124b5533` — `r3: chain closeout records on current main lineage
  (re-land)`：写集 16 件 = 票文件修改 1＋HANDOFF 与 SUPPLEMENT-1 自 active
  删除 2＋open-cards 13（done 7／open 6）。
- 提交后 `git status --porcelain` 仅剩两件，均非本步写集：
  `docs/pm/status.md` 修改（见 §5）、本步开跑卡
  `docs/pm/open-cards/open-20261008-r3-reland-blake.md` 未跟踪（属本步派发卡，
  归 PM 随完事卡一并落账）。

## 5. status.md 定性

`git diff docs/pm/status.md` 仅一处：项目经理 agent 身份行由旧 agent
（id `6cea3eb5-…`）改为 `TAD PM`（id `JQACSLdzARJFMmJoaNFWeD`，创建于
2026-10-07）。此为 PM 席位身份记录更新，与 R3 三组范围及收口链务无关——
判**非 R3 链内记录**，本步不提交，留 PM 另行处置。

## 6. 结论

组 1 已评审实现以逐字节同一形态入现行 main（`2d0929f2`），链务记录补齐
（`124b5533`），四项复验终值与原线 Gate 4 验收值逐项相等。票面 CLOSED
注记自此在现行线 git 记录与工作区双面成立；余下动作（推送＋证据分支同步）
归 PM。
