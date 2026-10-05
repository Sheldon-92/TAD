# Gate 3 返工 R3 登记 — AC21 `runtime-freshness` Gate 4 书面 waiver（本批）

- **Role**: Blake (Execution Master) — 只登记不改日期；未 bump 任何 ledger 日期；未 commit
- **Date**: 2026-09-16 | **Handoff**: `TASK-20260915-CLAUDE-REMOVAL`
- **Adjudication**: `.tad/evidence/reviews/2026-09-15-gate3-adjudication-claude-removal.md` §2 (R3) + §4 (C-4 duplicate-of-R3)
- **Handoff 落字**: `HANDOFF-2026-09-15-claude-removal-plan.md` AC21 行（WAIVED + 另单）

## 事实基线（复核，未改动）

- `bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-09-16` → `Total: 12 entries | PASS: 0 | WARN: 6 | BLOCK: 6`，`exit=1`。
- 6 BLOCK 全部是 codex ledger 高波动条目日期陈旧（`last_verified: 2026-08-03`，44 天 > 30；`next_review: 2026-09-02` 已过期）。
- claude ledger 已 `RETIRED` 头 + `INFO … skipping`（I18 接线正确）；缺 ledger/RETIRED 不再 `exit 2`，无永久 wiring-BLOCK。
- 本批对 `codex.md` 的改动仅 J7 单行 source-of-truth 措辞（`git diff HEAD` 可验）；日期零改动。**HEAD 同样 BLOCK**——pre-existing，与移除无关。

## Waiver（Gate 4 落字，缺一不可）

1. AC21 记为 **WAIVED（不是 PASS）**，豁免范围精确限定为"codex ledger 高波动条目的日期陈旧（`last_verified 2026-08-03` / `next_review 2026-09-02`）"，pre-existing、HEAD 复现、与移除无关。
2. AC21 意图子句独立判 PASS：移除未破坏 freshness 门——claude ledger retire-skip 生效、缺 ledger/RETIRED 不再 `exit 2`、无永久 wiring-BLOCK（I18 目标达成）。即**接线 PASS + 日期陈旧 WAIVED**。
3. 发布物料**不得**声称 AC21 全绿；release note 如实标注该项 waiver。
4. 强制另单：`TASK-20260916-CODEX-LEDGER-REVERIFY`（owner Blake，`NEXT.md` 优先队列，路径 `.tad/active/TICKET-20260916-codex-ledger-reverification.md`）——范围 = codex ledger 12 条（至少 6 BLOCK）真实 re-verification（live codex-cli + 官方文档）后刷新日期，恢复 `exit 0`。C-4 即此单（duplicate-of-R3），不另开。
5. waiver **单批次有效**；不授权任何后续"无实测仅 bump 日期"。

## 禁止

空 bump 日期；把"另单重验"塞进本移除批（不进本批 commit、不进本批 AC 证据）。
