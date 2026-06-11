# Gate 4 Independent AC Re-Verification — codex-parity-step3b

**Date**: 2026-06-10 | **Verifier**: independent general-purpose sub-agent (Alex Gate 4)
**Target**: commits 16983f6 + ebe92cf on main

## AC re-run results (independent, not trusted from Blake's report)

| AC | Expected | Actual | Verdict |
|----|----------|--------|---------|
| AC2 clean | exit 0 | 0 byte-identical | PASS |
| AC3 agents content drift | 1 + named + agents-newer; --fix REFUSED, unchanged | as expected | PASS |
| AC4 orphan | 1 + "Only in" + agents-newer; --fix REFUSED, orphan survives | as expected | PASS |
| AC5 claude drift | 1 + claude-newer; --fix 0, propagated; re-verify 0 | as expected | PASS |
| AC6a mktemp -d | 2 | 2 | PASS |
| AC6b no-arg | 2 + usage lists parity [--fix] | as expected | PASS |
| AC11 final clean tree | porcelain empty + parity 0 | as expected | PASS |

Tree restored clean after every mutation; final state verified clean.

## Adversarial probe (source analysis, parity case ~L513-604)

DIRECTION defaults to claude-newer and only flips to STOP on positive evidence.
Paths reaching rsync WITHOUT genuine claude-newer proof:
1. Non-git repo_root: all git probes || true → heuristic blind → always claude-newer.
2. Mixed commit (touches .agents AND .claude): agents-only test fails → claude-newer.
3. Filename with space: sed [^ ]* truncation → path skipped → claude-newer.
4. Agents-side deletion ("Only in $CLAUDE_SKILLS") matches no branch → claude-newer (benign outcome).
No exit-code fail-open found; || true guards degrade the heuristic, never convert FAIL to 0.
