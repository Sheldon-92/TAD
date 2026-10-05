# Independent Recovery Review — interruption-a
Reviewer model: opencode-go/deepseek-v4-flash
assertion_sha256: 7baeee9a1ee20a4d867d2e25d246b5a32c5fd4a437ba1fc0b6461ab953591251
oracle_sha256: 78b47ceecc3cd068467181ab423cd6eb415f59e6d72db1aa123e1f77fe074112

## Hard anchors
| anchor | score | justification |
|--------|-------|---------------|
| H1 | 1 | Goal is guide maintenance: add Command Reference (S1), Troubleshooting (S2), Worked Example (S3) to .tad/guides/yolo-recovery.md, no other file changes — matches oracle. |
| H2 | 1 | Same handoff path at revision 1e064fd530cc (12 hex chars match). |
| H3 | 1 | Exactly one slice verified: S1, with Conductor receipt sha256 and journal seq 3 — matches. |
| H4 | 1 | States no checkpoint candidates for S2/S3, journal has no seq entries, and the uncommitted worktree paths are "observation, not authority" (not verified progress) — matches oracle. |
| H5 | 1 | none — matches. |
| H6 | 1 | none — matches. |
| H7 | 1 | Legal next action is start slice S2, add '## 11. Troubleshooting' section — matches oracle (not re-do/verify S1, not finish-and-report). |
| H8 | 1 | Non-goals include restructure + CLI/tests; forbidden scope lists .tad/scripts/, .claude/, .tad/hooks/ — matches oracle. |

## Soft rationale
| item | score | justification |
|------|-------|---------------|
| S1 | 1.0 | Correct and complete: journal authority shows S1 verified (Conductor-written receipt, distinct identity, sha256 matches actual file), no pending action/blocker, so first unverified slice S2 is the only legal next work; corroborated by resume output PASS/legal_next_action S2. |
| S2 | 1.0 | Correct and complete: S1 carries a bound Conductor receipt after Gate + independent review; redoing duplicates committed work — matches oracle substance ("ledger refuses a second verify" vs "invalidate the run's accounting" are equivalent mechanisms). |
| S3 | 1.0 | Correct and complete: no checkpoint candidate for S2/S3; checkpoint records intent only; completion prose/executor assertion never advances verified — only a Conductor receipt (distinct identity) after Gate + independent review does; blind retry unsupported and unnecessary. |
| S4 | 0.5 | Correct but incomplete: covers file-scope prohibitions (outside-guide changes, forbidden paths, restructure, CLI/tests) plus an extra oracle-read prohibition, but omits the oracle's third must-not — "treating the uncommitted S2 edit as done" — from the S4 field itself; it appears only indirectly as "observation, not authority" in H4 and never as an explicit forbidden action. |

hard_correct: 8
hard_total: 8
soft_score: 0.88
verdict: FAIL