# Completion Report: Publish Migration Gate (Phase 5/6)

**Task ID**: TASK-20260610-002
**Epic**: EPIC-20260609-upgrade-lifecycle-system.md (Phase 5/6)
**Completed**: 2026-06-10
**Handoff**: HANDOFF-20260610-publish-gate-phase5.md

---

## Deliverables

### Phase 1: migration-draft.sh + Historical Manifests

1. **`.tad/hooks/lib/migration-draft.sh`** — Created. Draft manifest generator from git tag diffs.
   - Argument parsing (from_tag, to_tag, --output-dir)
   - Tag existence validation (exit 2 on missing tag)
   - ZERO_TOUCH filtering via derive-sync-set.sh --zero-touch
   - git diff classification (D→delete, R→rename, A→track)
   - Secondary rename detection (basename matching between D and A entries)
   - Schema-v1 YAML template emission with quoted versions
   - Refuse-to-overwrite existing manifests (exit 2)
   - Summary output with "DRAFT — review manually" reminder

2. **11 new historical manifests** + 1 existing = 12 total in `.tad/migrations/`:
   - 2.19.0-to-2.19.1.yaml through 2.24.1-to-2.25.0.yaml: empty-section manifests (zero D/R entries in framework-scoped non-ZERO_TOUCH paths)
   - 2.25.0-to-2.26.0.yaml: 14 delete entries (codex files + codex-parity-check.sh)
   - 2.26.0-to-2.27.0.yaml: existing (3 blake reference files)

### Phase 2: release-verify.sh migration mode + Fixtures

3. **`release-verify.sh migration` case arm** — Added.
   - Previous tag detection via `git describe --tags --abbrev=0 HEAD^`
   - Version normalization to 3-segment semver
   - Framework-scoped git diff (`.tad/`, `.claude/`, `.codex/`, `.agents/`, root files)
   - ZERO_TOUCH path filtering (reused pattern from version mode)
   - Manifest cross-reference via `grep -F` (smoke alarm approach)
   - Secondary rename detection (basename match D→A, prefer false-positive)
   - Exit codes: 0=pass, 1=drift, 2=usage
   - CONTRACT header updated with migration mode documentation

4. **3 migration gate fixtures** added to run-fixtures.sh:
   - MG1: unmanifested-delete-detected (exit 1 without manifest, exit 0 after adding)
   - MG2: zero-touch-excluded (delete inside active/ does NOT trigger finding)
   - MG3: rename-detected (git mv without manifest → exit 1)

### Phase 3: publish-protocol.md update

5. **step3d** inserted between step3c and step4 in publish-protocol.md.
   - Calls `release-verify.sh migration "$PWD"`
   - Exit code handling mirrors step3c pattern (exit 2 = HARD BLOCK, exit 1 + TAD_RELEASE_GATE=warn = advisory)
   - GATE label: `GATE: release-verify migration exit=<n>`

---

## Acceptance Criteria Evidence

| AC | Criterion | Result | Evidence |
|----|-----------|--------|----------|
| AC1 | migration-draft.sh syntax | PASS | `bash -n` exit 0 |
| AC2 | release-verify.sh syntax | PASS | `bash -n` exit 0 |
| AC3 | 12 manifest files | PASS | `ls .tad/migrations/*.yaml | wc -l` = 12 |
| AC4 | Chain completeness v2.19.0→v2.27.0 | PASS | 12 pairs, 0 missing |
| AC5 | Scoped to git diff (not raw FS walk) | PASS | `grep -c 'git.*diff.*name-status'` >= 1 |
| AC6 | Fixture: unmanifested-delete detected | PASS | MG1 PASS in harness |
| AC7 | ZERO_TOUCH paths excluded | PASS | MG2 PASS + `grep -cE 'ZERO_TOUCH\|ZT_'` = 33 |
| AC8 | Exit codes 0/1/2 | PASS | Code review + fixture verification |
| AC9 | publish-protocol step3d | PASS | `grep -c 'step3d'` >= 1 |
| AC10 | TAD_RELEASE_GATE in publish-protocol | PASS | 5 references (step3c existing + step3d new) |
| AC11 | Refuse-to-overwrite | PASS | `migration-draft.sh v2.26.0 v2.27.0` → exit 2, "already exists" |
| AC12 | Rename detection (false-positive bias) | PASS | POSSIBLE RENAME code path + MG3 fixture |
| AC13 | 2 manifests spot-checked | PASS | v2.25.0→v2.26.0 (14 D, all match raw diff) + v2.22.0→v2.22.1 (0 D after ZT filter, 2 raw D in active/ confirmed filtered) |
| AC14 | All existing fixtures pass | PASS | 22/22 ALL FIXTURES PASS |
| AC15 | No grep -P | PASS | Only in comments ("no grep -P"), zero code usage |
| AC16 | Change scope | PASS | Only Phase 5 files modified/created |

---

## Spot-Check Evidence (AC13)

### Manifest 1: v2.25.0→v2.26.0

Raw `git diff --name-status -M v2.25.0..v2.26.0` D entries (14):
```
D  .tad/codex/codex-alex-skill.md
D  .tad/codex/codex-blake-skill.md
D  .tad/codex/codex-tad-alex.sh
D  .tad/codex/codex-tad-blake.sh
D  .tad/codex/expert-review-sequential.md
D  .tad/codex/manual-gates.md
D  .tad/codex/regen-codex-editions.sh
D  .tad/codex/schemas/design.json
D  .tad/codex/schemas/judge.json
D  .tad/codex/schemas/merged.json
D  .tad/codex/sequential-review.md
D  .tad/codex/socratic-fallback.md
D  .tad/codex/tournament-codex.sh
D  .tad/hooks/lib/codex-parity-check.sh
```
Generated manifest: 14 delete entries, all paths match. CORRECT.

### Manifest 2: v2.22.0→v2.22.1

Raw `git diff --name-status -M v2.22.0..v2.22.1` D entries (2):
```
D  .tad/active/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase1.md
D  .tad/active/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
```
Both inside `.tad/active/` (ZERO_TOUCH). Generated manifest: empty sections. CORRECT.

---

## Files Changed

### Created
- `.tad/hooks/lib/migration-draft.sh`
- `.tad/migrations/2.19.0-to-2.19.1.yaml`
- `.tad/migrations/2.19.1-to-2.20.0.yaml`
- `.tad/migrations/2.20.0-to-2.21.0.yaml`
- `.tad/migrations/2.21.0-to-2.22.0.yaml`
- `.tad/migrations/2.22.0-to-2.22.1.yaml`
- `.tad/migrations/2.22.1-to-2.23.0.yaml`
- `.tad/migrations/2.23.0-to-2.23.1.yaml`
- `.tad/migrations/2.23.1-to-2.24.0.yaml`
- `.tad/migrations/2.24.0-to-2.24.1.yaml`
- `.tad/migrations/2.24.1-to-2.25.0.yaml`
- `.tad/migrations/2.25.0-to-2.26.0.yaml`

### Modified
- `.tad/hooks/lib/release-verify.sh` — added migration case arm + CONTRACT header
- `.tad/tests/migration-fixtures/run-fixtures.sh` — added MG1/MG2/MG3 fixtures
- `.claude/skills/alex/references/publish-protocol.md` — added step3d

---

## Sub-Agent Usage

| Sub-Agent | Used | When | Output Summary | Evidence |
|-----------|------|------|----------------|----------|
| parallel-coordinator | No | — | — | — |
| bug-hunter | No | — | — | — |
| test-runner | No | — | — | — |
