# Code Review — Phase 1 State Consistency

Reviewer: code-reviewer
Date: 2026-04-24
Pass criteria: P0=0, P1=0, P2≤10

## Summary
- P0: 0
- P1: 0
- P2: 4
- Verdict: **PASS**

## Scope verified
Read all 4 shell files (drift-check.sh 393L, gate3-git-tracked-check.sh 163L, layer2-audit.sh 135L, userprompt-domain-router.sh 262L), all 5 AC test scripts, `.claude/settings.json`, plus runtime smoke tests (injection, multi-line, deep slug, edge-case `---` in strings).

## Findings

### P0 (blocking) — none

Epic-1 compliance verified end-to-end:
- `.claude/settings.json` `permissions.deny` is `[]` — no additions.
- `drift-check.sh`, `gate3-git-tracked-check.sh`, `layer2-audit.sh` are **NOT** registered under `PreToolUse` / `PostToolUse` / `UserPromptSubmit` — confirmed via `jq` over settings. Only the existing domain-router (modified, not new) sits on UserPromptSubmit as `type: command`, advisory-only, always `exit 0`.
- `exit 2` occurrences are all **POSIX usage-error** semantics (bad args, unreadable handoff, invalid slug, wrong YAML type) — never fleet-blocker. `exit 1` on `gate3-git-tracked` and `layer2-audit` is the smoke-alarm FAIL code consumed by the caller (Alex/Blake), not by Claude Code as a hook gate.
- No `set -e` + trap-reliance conflict: router uses `set -uo pipefail` + `trap 'exit 0' ERR` (documented). Other scripts use `set -uo pipefail` (drift-check, gate3) or `set -euo pipefail` (layer2-audit, short script, no ERR trap dependencies).

### P1 (blocking) — none

Spot-verified hazards one by one:

1. **Awk frontmatter extraction on `---` inside strings** (gate3-git-tracked-check.sh L50-55, drift-check.sh L322-327): the pattern `^---[[:space:]]*$` with `^` and `$` anchors correctly rejects any `---` appearing inside a YAML string value (which is never the sole content of its line). Empirically verified: handoff with `description: "separator --- inside string"` parsed correctly, `git_tracked_dirs` extracted.
2. **layer2-audit truncation infinite-loop defense** (L60-79): CR-P1-3 guard in place — `slug_try1="${slug%-*}"`; if `slug_try1 == slug` (no dash found, `%-*` returns original) OR `-z slug_try1`, skip recursion. `slug_try2` similarly guarded. Bounded to 2 attempts. Verified: `layer2-audit.sh foo` (single-segment) exits 1 with FAIL message, no hang.
3. **gate3 git check-ignore branching** (L128): `git check-ignore -q -- "$dir"` returns 0 when ignored, 1 when not ignored. Logic `if git check-ignore -q; then WARN` is correct. AC-P1.1-g test covers this with a real `.gitignore` fixture.
4. **Router multi-line prompt filter** (L75): `printf '%s' "$USER_MSG" | grep -qE ...` uses `-q` (quiet) which returns 0 as soon as ANY line matches. Embedded `<system-reminder>` on an internal line is correctly detected and skipped. Verified runtime.
5. **Shell injection defense** (layer2-audit.sh L39): strict whitelist regex `^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$` rejects leading/trailing dashes (argv-flag injection) and any shell metachar. Tested `'; rm -rf /tmp/evil'` → rejected with exit 2. Empty and single-`-` also rejected.
6. **jq safety**: all jq invocations use `--arg` binding for user-derived data (drift-check `_emit`, router `additionalContext`). No string interpolation.
7. **BSD portability grep across all 4 files**: clean. No `grep -P`, no `grep -oP`, no `gdate`, no `EPOCHREALTIME`, no `awk gensub()`. Identifier-boundary regex `(^|[^A-Za-z0-9_-])slug([^A-Za-z0-9_-]|\$)` empirically matches `feat(zombie-fix):` on BSD grep. `wc -c < file` used for size (router L248); `stat -c%s` appears in layer2-audit L22 but **correctly guarded** by `stat --version` runtime detection with BSD fallback `stat -f%z`.
8. **ShellCheck clean**: 2 SC2034 warnings only (`had_small` in layer2-audit — actually read indirectly via branch logic; `BEST_RATIO_NUM` in router — dead var). Informational, not P1.

### P2 (advisory)

1. **layer2-audit.sh L103 `had_small=1` is technically unused** after the refactor — SC2034 warning. The subsequent `had_symlink_small=1` inside the same branch carries the real signal; `had_small` setting is redundant since `qualified==0` already implies "all found were small". Consider removing the assignment on L103.
2. **userprompt-domain-router.sh L128 `BEST_RATIO_NUM=0` is dead** — never read, awk computes `best_ratio` internally. Remove the bash-side var.
3. **drift-check.sh `_load_config` swallows `yq` errors silently** (L60, L67) — `2>/dev/null || echo 60`. If `yq` prints errors for a malformed `drift_check:` block, the user will never know the YAML is broken; just silently sees defaults. Consider `||: ; stderr-to-log` pattern so config typos surface during tad-maintain CHECK.
4. **AC-P1.4-g latency test forks hook via `open(my $fh, "|-")`** (line 120) — this works but `close $fh` will return nonzero exit from the hook and `die "fork failed"` comment is misleading (hook exit propagates as pipe close status). Minor test-code clarity; not a correctness issue. Consider adding `close $fh or warn "...";` so test failures in the hook surface in the TSV.

## Strengths

- **Failure isolation architecture** in drift-check (L358-366): each subcheck guarded by `|| _emit ... error ""` so git absence doesn't kill slug/ghost checks. Verified with AC-P1.2-k.
- **Observability contract**: every subcheck emits JSONL on stdout + human status on stderr (`[drift-check] <subcheck> <handoff> <status>`). Grep-friendly, tooling-friendly.
- **Snapshot-based execution** (drift-check L353): one `find` snapshot passed to all 4 subchecks → deterministic ordering, no TOCTOU across subchecks.
- **Advisory-only contract rigorously enforced**: supersedes action is text (`"archive X (human review)"`), AC-P1.2-e explicitly tests that the supersedee file is **not** auto-moved.
- **Epic-1 post-mortem lessons are baked in**: every new script has a header comment referencing "smoke alarm", "advisory only", "not a PreToolUse hook", and the 2026-04-15 cancellation context is respected at every layer.
- **AC coverage is strong**: 8 cases in AC-P1.1 (tracked/untracked/absent/non-git/empty/missing/ignored/wrong-type + bonus aggregate), 12 cases in AC-P1.2 (4 subchecks × clean/fixture/false-positive/isolation/observability/portability), 5 cases in AC-P1.3 (strict/truncated/missing/single-segment/2-level), 7 cases in AC-P1.4 (match/skip variants + dogfood + literal-tag edge + p95 latency).
- **BSD/GNU `stat` detection** (layer2-audit L21-25) is the cleanest pattern I've seen for cross-platform size — runtime probe via `stat --version`, not guesswork.

## Bottom line

This is solid smoke-alarm infrastructure. The Epic-1 cancellation boundaries are respected without fanfare — no PreToolUse registration, no permissions.deny, no `exit 2` fleet-blocking, failure paths are advisory text consumed by Alex/Blake judgment, not enforced by the harness. Shell quality is production-grade: strict whitelists, jq `--arg` binding, BSD-portable grep/sed/awk, runtime stat-flavor detection, failure-isolated subchecks. AC test coverage is thorough including the specific regressions that motivated each script (toy 2026-04-22 untracked-38-files, toy 2026-04-23 slug truncation loop, 2026-04-24 domain-router false positives). 4 P2 advisories are cosmetic cleanups. Ship it.

## Files reviewed (absolute paths)

- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/drift-check.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/gate3-git-tracked-check.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/layer2-audit.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/userprompt-domain-router.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/settings.json`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.1-gate3-git-tracked.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.2-drift-check.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.2-g-backward-compat.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.3-layer2-audit-slug-fallback.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh`
