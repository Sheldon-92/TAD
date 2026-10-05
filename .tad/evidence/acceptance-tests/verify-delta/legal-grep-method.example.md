# LEGAL Method cell example (runnable grep command — can PASS)

`LEGAL_METHOD_CELL`

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|---------------------|-------------------|-----------------|
| 1 | Old prose checkbox gone from bug-path | post-impl-verifiable | `test "$(grep -cF -- 'some-retired-sentence' path/to/file.md)" -eq 0` | exit 0 | (post-impl) |

Why LEGAL: the Method cell is a pasteable shell command in backticks whose exit
code / output is observable. Gate 3 `step2_classify` marks it LEGAL, executes it,
and compares against Expected Evidence. Same shape works for the express
skip-e2e floor (a cheaper runnable check that remains when e2e is skipped).
