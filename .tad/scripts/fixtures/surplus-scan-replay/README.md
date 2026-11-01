# surplus-scan-replay 语料（Phase 4 扫描面回放集）

回放脚本 `.tad/scripts/surplus-scan-replay.mjs` 以「逐字抽取＋哈希对账」消费
`.tad/workflows/claude/surplus-scan.workflow.js` 内的 classify-block：块文本的
sha256 必须与 `corpus.json` 的 `classify_block_sha256` 一致，否则
`REPLAY-RESULT: EXTRACT-FAIL`、exit 2（fail-closed）。永不维护平行副本。

**改 classify-block 的义务**：任何对 classify-block 的编辑，落定前必须重跑
本回放至 12/12 PASS（`REPLAY-RESULT: PASS rows=12`）；块哈希变化时同步更新
`corpus.json` 的锚（锚的是实施后的实际块）。

## 运行

```
node .tad/scripts/surplus-scan-replay.mjs [--workflow <path>]
```

逐行输出 `ROW <id> expected=<d> got=<d> OK|MISMATCH …`，末行
`REPLAY-RESULT: PASS rows=12`（exit 0）或 `FAIL … mismatches=<k>`（exit 1）。

## 语料 12 行来源（逐行）

| # | id | 来源 |
|---|----|------|
| 1 | replay-prereq-lock | AC8 七行集第 1 行：`.tad/evidence/surplus-execute-fix-20261031/fixture-sidecar-replay.json` 同 id 行逐字映射为 reader-output 形态；预期处置见 `run-record-replay.md` L37（处置表）——needs_you / human-prerequisite-lock |
| 2 | replay-human-acceptance | 七行集第 2 行（fixture 同 id；run-record L38）——人域验收（human_prereq）＋input brief 件缺位（cited_missing 取 fixture 行的 target 件 `scand-input-absent.md`，该路径在 gate4-fixture 目录中实缺位）＋状态未发（三重命中，只判 disposition 与 auto=false；run-record 观察行同记 status-missing） |
| 3 | replay-already-landed | 七行集第 3 行（run-record L39）——landed 凭据（deliverable＋completion 在盘）→ 字段层 dropped-stale（执行侧形态为 skipped / already-landed） |
| 4 | replay-approval-reversed | 七行集第 4 行（run-record L40）——批准面矛盾：source_status='unknown'、evidence 点名批准面；守 D3 边界：human_prereq 恒 false（expected 以 reasons_not_contains 钉死） |
| 5 | replay-status-missing | 七行集第 5 行（run-record L41）——reader 未发 source_status 字段 → status_unknown 派生门 |
| 6 | replay-stale-narrative-52 | 七行集第 6 行（run-record L42）——叙述称 52 条 parked，活状态件（replay-live-queue-state.md）计数为挂起 0 → source_status='superseded'、dropped-stale |
| 7 | replay-regression-missing-status | 七行集第 7 行（run-record L43）——同第 5 行的缺失形态（回归行，2026-10-31 AC8 漏检形态） |
| 8 | jev-production-trial | 技术研究席 proposal §1 三例之一（tech-radar `consult/tad-process-suggestions-2026-10-31/proposal.md` §1）：曾标 auto-eligible、卡 L3 账号＋PM 1:1 人供前置 → needs-human |
| 9 | gap-queue-52-disposition | proposal §1 三例之二：据 EPIC §13 叙述立论，活状态件实况 52 条已出队、挂起 0 → dropped-stale。与第 6 行是有意配对的两层形态（扫描侧事件原型 vs 执行侧回放行，HANDOFF §4.4 D7），各计一行 |
| 10 | epic-20260927-citation | proposal §1 三例之三：基线引用的 EPIC-20260927 件缺位 → cited_missing 非空、needs-human。本行以合成缺位形态构造：真文件已于 2026-10-31 恢复（现位于 tech-radar 仓），语料只验分类行为、不依赖盘面缺席 |
| 11 | control-live-auto | 构造正控（显名）：全字段健康、value=4 → ranked 且 auto_eligible=true（守「门不误杀」） |
| 12 | control-live-lowvalue | 构造正控（显名）：同 11 惟 value=2 → ranked 且 auto_eligible=false（价值地板，不许被门误判 needs-human） |

`expected.json` 的对账口径：disposition 全等；`auto_eligible` 逐行对账；
`status_unknown` 在点名行（4/5/7）对账；`reasons_contains` /
`reasons_not_contains` 在点名行对账（第 4 行的 reasons 构成——不含
human-prereq——在此钉死，供 Gate 3 spec 面核）。
