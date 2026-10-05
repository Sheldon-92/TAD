# Gate 2 Code/Product Quality Review — Round 1

Model: Claude Code 2.1.239 | harness: Claude-oriented review subagent | route: host/unknown

**Verdict:** FAIL

## P0

1. Arbitrary evidence files could self-certify verified progress, bypassing Conductor/Gate authority.
2. A fabricated `recovery-scores.json` with self-reported booleans could pass the dogfood ACs without fresh-context recovery.

## P1

- Machine-check exact a/b/c treatments, control/base/worktree parity and raw evidence.
- Define a real local action boundary for outcome reconciliation.

## P2

- Replace `git diff --stat` scope checking with an exact path allowlist.

