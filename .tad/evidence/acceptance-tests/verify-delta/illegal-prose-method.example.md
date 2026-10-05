# ILLEGAL Method cell example (prose-only — Gate 3 row FAIL)

`ILLEGAL_METHOD_CELL`

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|---------------------|-------------------|-----------------|
| 1 | Bug fixed | post-impl-verifiable | Bug no longer reproduces under reported conditions | looks OK | (post-impl) |

Why ILLEGAL: the Method cell is prose with no runnable command — no backticked
command, no path-check, no fixture runner, no rubric-spawn, no light-tier N/A.
Gate 3 `step2_classify` marks this row FAIL (`prose-only Verification Method = FAIL`)
→ cannot Gate 3 PASS. Gate 4 cannot PASS if this row is missing or unrun.
