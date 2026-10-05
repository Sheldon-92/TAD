# Blake Code Review — Capability Builder Phase 1 Create

**Reviewer:** code-reviewer (independent subagent, muse-spark)
**Date:** 2026-08-31
**Scope:** `.claude/skills/capability-builder/`, `.agents/skills/capability-builder/`, `.claude/skills/capability-upgrade/`, `.agents/skills/capability-upgrade/`, `.tad/scripts/capability-skill.sh`, `.tad/scripts/pack-eval-runner.sh`, `CLAUDE.md`, `.tad/evidence/acceptance-tests/capability-builder-create/`
**Verdict:** PASS (no P0, all P1 resolved)

## Findings

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | P1 | Helper initially used absolute path in hash_tree, causing manifest vs recompute divergence (relative vs absolute). | Fixed to content-only hash (cut filename, sort hashes). Verified manifest and recompute now reconcile. |
| 2 | P1 | Runner dual-field detection used fallback-resolved pack, misclassifying skill-only as dual. | Added parse_pack_raw for frontmatter-only detection; skill-only now correctly valid, dual SKIP only when both fields present. |
| 3 | P1 | Run-acceptance used unicode variable names (invalid bash identifiers) causing behavior mode to fail under set -u. | Renamed to ASCII (control_state/with_state). |
| 4 | P2 | Builder router must have non-circular create trigger; verify it lives in body not reference. | Confirmed `capability-builder create` and `references/create-protocol.md` mandatory load both in body. |
| 5 | P2 | Helper `--help` exit codes must be stable and documented. | Verified help prints 0/1/2/3/4 and structural tests assert each class. |
| 6 | P1 (Gate4-1) | Divergent branch removed pre-existing .tmp.* | Removed find+rm of pre-existing tmp; divergent now only returns 3 with no mutation, no cleanup of untracked temps. |
| 7 | P1 (Gate4-2) | Final verify failure left projection published | Added `_published_by_this_invocation` + `device:inode` ownership check; rollback only if lock+inode owned, else 4 with diagnostic; centralized `cleanup_project_resources` now also removes owned empty parents; test via `diff` PATH wrapper (no production hook). |
| 8 | P1 (Gate4-3) | Frontmatter accepted block scalars `>`/`\|` | Added rejection of `description: >/\|` and `name: >/\|`, plus `grep -qE '^[>|]'` on values; negative fixtures for both. |
| 9 | P1 (Gate4-4) | Publication not protected against race | Added per-skill `mkdir .lock` + recheck before/after lock, fail-closed 3, `get_inode` ownership; tests via `cp`/`diff` PATH wrappers (no production hook). |
| 10 | P1 (Gate4-5) | hash_tree and parent inventory not binding | `hash_tree` now binds relative path + node type (f/d/l); parent inventory equality required for all failing cases including pre-existing; `inventory_parent` covers pre-existing. |
| 11 | P1 (Gate4-6) | eval grep without --, invalid regex not SKIP | Changed to `grep -oE --`, added `is_invalid_regex` → `SKIP (bad fixture: invalid pattern)`, handles leading-dash. |
| 12 | P1 (Gate4-7) | CLAUDE.md check used implicit HEAD | Pinned to `scope/implementation-commit.txt` (`2d7e359b` 2-file remediation; marker is post-commit working-tree evidence, `git cat-file -e` passes, not inside commit). |
| 13 | P1 (Gate4 new) | Late copy/temp-diff left empty `.claude` parents | Centralized `cleanup_owned_parents` after temp/lock, invoked on every post-parent-creation failure; added `cp`/`diff` wrapper cases from absent `.claude` asserting parent inventory == pre-call (absent). |

## Shell Safety

- No `grep -P`, no `set -e` in runner, BSD-safe `grep -oE | sort -u | wc -l`, `LC_ALL=C` on sort/comm, quoted path expansions.
- Helper uses `set -uo pipefail`, `mktemp -d` for temp sibling, `cp -R` + `diff -rq` verify + `mv` atomic, cleanup of empty parents only.
- All scripts pass `bash -n`.

## AC Coverage

- Validated AC1–AC12 commands literally: projection, structural (54 cases incl. block scalar >/| (2), foreign temp, copy/diff wrapper parent-cleanup (2), diff wrapper rollback, cp wrapper concurrency), eval-compat (7/7 incl. invalid regex, leading-dash), behavior (hash_tree binds path+type), routing (baseline SHA 69026199), claude-routing (pinned to `2d7e359b` via `scope/implementation-commit.txt`), scope (remediation 2 files `2d7e359b`, honest marker), parity (byte-identical). No `eval`/`CAPABILITY_SKILL_TEST_` in production helper.

No P0 remaining. Gate 3 rerun PASS — ready for Alex independent Gate4.
