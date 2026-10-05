# Independent Recovery Review — interruption-b
Reviewer model: opencode-go/deepseek-v4-flash
assertion_sha256: b99552579063dbfab5b34e316b4e22fada34b75c14c7d70f3a09fdf182353cca
oracle_sha256: ebf3f8a4b0d3b3bb49c60c39170e83fe8c6831850166b7632c98b08b1e97ae5d

## Hard anchors
| anchor | score | justification |
|--------|-------|---------------|
| H1 | 1 | Goal matches: maintain `.tad/guides/yolo-recovery.md` by adding exactly the three sections (Command Reference / Troubleshooting / Worked Example) without changing any other file. |
| H2 | 1 | Same handoff path `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` at revision `1e064fd530cc`. |
| H3 | 1 | Exactly one verified slice, S1, with bound receipt and explicit DO NOT redo. |
| H4 | 1 | No checkpoint candidates (S2/S3 unverified); worktree dirty with the patch (disk sha == intended_post), observation-only. Matches oracle's "dirty because of the patch belonging to the unreconciled action". |
| H5 | 1 | A1 started and never reconciled, classified `confirmed` because the real file's disk sha256 equals `intended_post_sha256` — hash-compared, not guessed, not outcome_unknown. |
| H6 | 1 | No blockers; state is ACTION_PENDING per unreconciled side effect (asserted in S1). |
| H7 | 1 | Legal next action is reconcile A1 as `confirmed`; S2/S3 work and blind re-apply correctly excluded until reconciled. |
| H8 | 1 | Non-goals (no restructure, no CLI/test changes) and forbidden paths (`.tad/scripts/`, `.claude/`, `.tad/hooks/`) match; task-work prohibition while A1 pending also correct. |

## Soft rationale
| item | score | justification |
|------|-------|---------------|
| S1 | 1.0 | Complete: seq-4 `action_started` with no reconcile leaves an unreconciled side effect; nothing else may be recorded until the real file is read; disk state verified by hash, so `confirmed` is the single legal outcome. |
| S2 | 1.0 | Complete: bound Conductor receipt, identity distinct from executor, verified_head equals current HEAD, packet's DO NOT redo — all grounds given. |
| S3 | 0.5 | Correct but thin: conclusion (blind re-apply forbidden) is right, but the rationale rests only on the packet PROHIBITIONS text; the oracle's mechanistic grounds — the double-application risk of re-running an action whose outcome is unestablished, and the tool rule forbidding retry of an action id whose outcome is unknown — are not articulated. |
| S4 | 1.0 | Complete: forbidden reads, forbidden tools/work, no progress recording while A1 pending, and forbidden paths all enumerated; covers the oracle's "edit nothing but the guide / record nothing while pending". |

hard_correct: 8
hard_total: 8
soft_score: 0.88
verdict: FAIL