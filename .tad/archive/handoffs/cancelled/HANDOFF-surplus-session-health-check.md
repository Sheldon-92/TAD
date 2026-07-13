---
cancel_reason: obsolete
cancel_rationale: "Synthesized to burn expiring surplus quota; never executed (spend-limit casualty); surplus premise gone with new billing cycle"
id: HANDOFF-surplus-session-health-check
task_type: code
epic: EPHEMERAL-surplus-session-health-check
phase: 1/1
created: 2026-07-06
author: surplus-execute (HUMAN-AUTHORIZED 2026-07-05/06 relaunch)
status: ready
scope_estimate: 1 new file (~150-250 lines bash), 0 files modified
risk: low (read-only diagnostic; mutates nothing)
---

# Handoff: session-health.sh — Framework Component Integrity Check

## 1. Requirement

Build `.tad/hooks/lib/session-health.sh`, a **read-only** diagnostic script that verifies core
TAD framework components are correctly wired. Outputs an annotated report; exit 0 when all
checks pass, exit 1 with per-check FAIL annotations when any check fails.

Origin: IDEA-20260403. Value: fast drift diagnosis after every sync/release, replacing manual
inspection across many files.

## 2. Checks (all four REQUIRED)

1. **SKILL.md presence on both platforms**
   - For each pack dir in `.claude/skills/*/` (excluding `_archived`), assert `SKILL.md` exists.
   - Assert the same skill set exists in `.agents/skills/*/` (parity: same dir names, each with
     SKILL.md). Report any one-sided or SKILL.md-missing entries by name.
2. **Hook wiring in settings.json**
   - Parse `.claude/settings.json` with `jq`. For every hook entry of `"type": "command"`,
     extract the script path (strip args/env prefixes) and assert the file exists on disk.
   - Assert the `hooks` object is non-empty and contains `SessionStart`.
3. **Version consistency**
   - Assert `.tad/version.txt` content == `TARGET_VERSION="X.Y.Z"` value in `tad.sh` (line ~22;
     match ONLY the literal assignment `TARGET_VERSION="..."`, not the `$v` reassignment).
4. **Pack registry coherence**
   - Registry file: `.tad/capability-packs/pack-registry.yaml`.
   - Compare the set of pack names declared in the registry against installed pack dirs in
     `.claude/skills/` (exclude `_archived` and non-pack skills not listed in the registry —
     direction that matters: every REGISTRY entry must have an installed dir with SKILL.md;
     also report installed capability-pack dirs absent from the registry as WARN, not FAIL).

## 3. Implementation Steps

1. Read `.tad/capability-packs/pack-registry.yaml` first to learn its actual schema (name key,
   status field); derive the pack-name extraction accordingly — do NOT guess the YAML shape.
2. Write `.tad/hooks/lib/session-health.sh`:
   - `#!/usr/bin/env bash`, `set -uo pipefail` (NOT `set -e` — checks must continue after a
     failure to produce the full annotated report; accumulate `FAILS` counter).
   - macOS/BSD-portable (no GNU-only flags; use `jq` for JSON, plain grep/sed/awk for YAML).
   - Resolve repo root from the script's own location (`cd "$(dirname "$0")/../../.."`) so it
     works from any cwd.
   - Output format: one line per check `[PASS]`/`[FAIL]`/`[WARN]` + detail lines for each
     offending item; final summary line `session-health: N checks, M failed`.
   - Exit 0 iff zero FAIL (WARN does not fail the run).
3. `chmod +x` the script.
4. Run it against the live repo (expected: all PASS at current HEAD) and capture output.
5. Negative test: verify FAIL paths fire without mutating the repo — run each doctored input
   through an env override or a temp-dir copy (e.g. `TAD_ROOT` override pointing at a scratch
   clone with version.txt edited), NEVER by editing tracked files in place.

## 4. Acceptance Criteria

- **AC1 (happy path)**: `bash .tad/hooks/lib/session-health.sh` on the current repo exits 0 and
  prints 4 `[PASS]` check lines plus a summary line.
- **AC2 (version drift detection)**: with a scratch copy where `version.txt` says `9.9.9`, the
  script exits non-zero and the report contains a `[FAIL]` line naming both values
  (`version.txt=9.9.9` vs `tad.sh TARGET_VERSION=2.33.0`-style annotation).
- **AC3 (hook wiring detection)**: with a scratch copy whose settings.json references a
  nonexistent hook script path, the script exits non-zero and the `[FAIL]` line names the
  missing path.
- **AC4 (skill parity detection)**: with a scratch copy where one pack dir's SKILL.md is removed
  (or one platform's dir deleted), the script exits non-zero and names the offending pack.
- **AC5 (read-only guarantee)**: after AC1 run on the live repo, `git status --porcelain` output
  is unchanged relative to before the run (script mutates nothing tracked; no temp files left
  in repo).

## 5. Constraints

- forbidden: modifying tad.sh, settings.json, pack-registry.yaml, or any skill files.
- forbidden: network calls; `set -e` (breaks report accumulation); GNU-only utils.
- Script must degrade gracefully if `jq` is missing: emit `[FAIL] jq not found` rather than
  crashing mid-report.
