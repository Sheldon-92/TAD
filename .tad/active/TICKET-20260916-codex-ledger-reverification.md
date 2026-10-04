# TICKET-20260916-codex-ledger-reverification

- **Task ID**: `TASK-20260916-CODEX-LEDGER-REVERIFY`
- **Owner**: Blake (Execution Master)
- **Created**: 2026-09-16 (Gate 3 rework R3, out-of-band from `TASK-20260915-CLAUDE-REMOVAL`)
- **Status**: `OPEN` — queued in `NEXT.md` 优先队列
- **Source**: Gate 3 adjudication `.tad/evidence/reviews/2026-09-15-gate3-adjudication-claude-removal.md` §2 (R3) + §4 (C-4, duplicate-of-R3,同一张单)
- **Waiver**: `.tad/evidence/reviews/2026-09-16-gate3-rework-r3-waiver.md` (Gate 4 签字前置)

## Scope（只做真实重验，不碰移除批）

对 `.tad/runtime-compat/codex.md` 12 条（至少 6 个 BLOCK 高波动条目，
`last_verified: 2026-08-03` / `next_review: 2026-09-02` 已过期）做**真实**
re-verification：live `codex-cli` 实测 + 官方文档核对（含 `context_compaction` /
`trace_evidence_capture` 两个 `verified_partial` 项，需可信鉴权的 Codex 会话实测），
随后刷新日期，恢复 `runtime-freshness-verify.sh` `exit 0`。

## Boundaries

- 本单动作**不得**进入 v3.0.0 移除批次（不进本批 commit、不进本批 AC 证据）；
  与本批的 `codex.md` J7 单行 source-of-truth 措辞改动区分开。
- **禁止空 bump 日期**（无实测仅改日期）；waiver 单批次有效。
- R3/C-4 同一事实只开这一张单，不重复开单。

## Done criteria

- 6 BLOCK 清零（真实重验后刷新），`runtime-freshness-verify.sh` 对当日日期 `exit 0`；
- Gate 4 验收该单时 waiver 自动失效（AC21 回归 PASS）。
