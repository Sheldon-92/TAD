# Test-Runner Review — AI Agent Architecture Capability Pack
Date: 2026-05-07
Reviewer: test-runner subagent
Scope: install.sh bash script + exit-code contracts (documentation pack, no application tests)

## Verdict: PASS

All 7 exit-code contracts satisfied. Function ordering correct. Bash syntax clean.

## Structural Checks

| Check | Status |
|-------|--------|
| `install_claude_code()` defined before case statement (line 41 vs line 99) | PASS |
| CAPABILITY.md frontmatter validation present and fires correctly | PASS |
| `bash -n` syntax check | PASS |

## Exit Code Verification

| Invocation | Expected | Actual | Status |
|---|---|---|---|
| `--agent=claude-code --dry-run` | 0 | 0 | PASS |
| `--agent=codex` | 2 | 2 | PASS |
| `--agent=cursor` | 2 | 2 | PASS |
| `--agent=gemini` | 2 | 2 | PASS |
| `--agent=unknown` | 1 | 1 | PASS |
| `--help` | 0 | 0 | PASS |
| unknown flag | 1 | 1 | PASS |

## Findings

**P1 — Empty glob on line 82 fails mid-install (latent)**
- `cp "$PACK_DIR"/references/*.md "$TARGET_DIR/references/"` — if references/ empty, bash expands to literal string, cp fails at line 82, partial install state
- Not triggered by current pack (11 .md files in references/)
- Fix: add `compgen -G` guard before line 82
- Deferred: P1 advisory for v1.1 — does not affect current pack

**P2 — Gemini stub missing "Expected install" description (cosmetic, matches codex/cursor format)**
**P2 — Dry-run for-loop silently iterates over non-matching glob (cosmetic)**

## P0 Issues: None
