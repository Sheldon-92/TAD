# Blake Security Auditor — Capability Builder Phase 1 Create

**Reviewer:** security-auditor (independent subagent)
**Date:** 2026-08-31
**Scope:** `.tad/scripts/capability-skill.sh`, `.tad/scripts/pack-eval-runner.sh`, `.tad/evidence/acceptance-tests/capability-builder-create/`
**Verdict:** PASS

## Threat Analysis

| Area | Check | Result |
|---|---|---|
| Path traversal | skill-name normalized `^[a-z0-9]+(-[a-z0-9]+)*$` rejects `/`, `..`, absolute, slash; derived paths checked for prefix escape | PASS |
| Symlink write | Path chain checked for symlinks in `.agents`, `.agents/skills`, `.claude`, `.claude/skills` before any write; canonical tree scanned for interior symlinks | PASS |
| Symlink race | Temp sibling created via `mktemp -d` inside parent, verified before rename; no symlink traversal via `cp -R` (target checked) | PASS |
| Overwrite / drift | Divergent target exits 3 without merge/overwrite/delete; neither tree mutated; parent inventory checked | PASS |
| I/O failure | Temp sibling cleanup on copy/verify failure; empty parent directories removed only if created by this invocation; no leftover `.tmp.*` | PASS |
| Injection | No `eval` of user input; skill-name validated before use; no heredoc injection; `grep -E` patterns from fixture are trusted (developer-authored) and not user-supplied at runtime | PASS |
| Shell portability | No `grep -P`, `LC_ALL=C` on sort, `shasum` fallback to `sha256sum`, `set -uo pipefail` without `set -e` in runner | PASS |
| Evidence integrity | CONTROL/WITH use same prompt hash, skill tree hash, fixture hash, output hashes, harness/model provenance; manifest recomputed; verdicts recomputed via runner, SKIP rejected | PASS |

## Negative Tests

- `../escape`, `/absolute`, `bad/name`, `Bad_Name` all return exit 2 (invalid).
- Symlink in canonical tree and in `.agents/skills` path chain both refuse with exit 2.
- Divergent projection returns exit 3, no mutation, no temp.
- Copy failure (parent is file) returns exit 4, no temp.
- Dual `skill:` + `pack:` returns `SKIP (bad fixture: conflicting subject fields)` and cannot satisfy AC5.

No security P0/P1. Fix is narrow and does not expand blast radius to arbitrary sync.

## Scope

Reviewed helper bounded writer and parser change only. No new network, config, or marketplace writes. Protected surfaces untouched per manifest diff.
