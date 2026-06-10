---
task_type: code
e2e_required: yes
research_required: no
git_tracked_dirs: [".tad/tests", ".tad/evidence/acceptance-tests/upgrade-lifecycle"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 6/6)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex)

**Execution time**: 2026-06-10 00:15

### Gate 2 Check Results

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | OK | 2 scripts + 1 evidence dir + 1 decision — all specified |
| Components Specified | OK | upgrade-acceptance.sh, gate-exercise.sh, evidence collection — interfaces clear |
| Functions Verified | OK | derive-sync-set.sh --zero-touch, release-verify.sh migration, migration-engine.sh — all exist and callable |
| Data Flow Mapped | OK | acceptance script reads zero-touch dirs + version.txt + deprecation.yaml + migration reports; gate-exercise creates temp git state then calls release-verify.sh |

**Gate 2 Result**: PASS

**Alex confirms**: I have verified all design elements. Blake can independently complete the implementation based on this document.

---

## Handoff Checklist (Blake)

Blake, before starting implementation:
- [ ] Read all sections
- [ ] **Read the Project Knowledge section and historical lessons below**
- [ ] All MQ questions answered with evidence
- [ ] Understand the true intent (not just the literal requirements)
- [ ] Deliverables and evidence requirements for each Phase are clear
- [ ] Confirm you can independently complete implementation using this document

If any part is unclear, **immediately return to Alex for clarification**. Do not start implementation.

---

## 1. Task Overview

### 1.1 What We're Building

Two verification scripts + one evidence directory for the final acceptance phase of the upgrade-lifecycle-system Epic:
1. **upgrade-acceptance.sh** -- post-sync verification script that validates a project after *sync
2. **gate-exercise.sh** -- creates a temporary git state to prove the migration gate can actually block an unmanifested delete
3. Evidence collection directory with fixture run output

### 1.2 Why We're Building It

**Business value**: The upgrade lifecycle system (Phases 1-5) built a complete migration pipeline. Phase 6 proves it works end-to-end -- without this, all prior work is "trust me" not "show me."

**User benefit**: After Phase 6, the human can run `*sync` + `upgrade-acceptance.sh` on any registered project and get a machine-verifiable PASS/FAIL. The gate exercise proves the publish gate is not theater.

**Success looks like**: When the human can run the acceptance script after *sync on any project and get exit 0; when the gate exercise proves exit 1 on an unmanifested delete; when all 22 existing fixtures still pass.

### 1.3 Intent Statement

**The real problem**: Phases 1-5 built the mechanism. Phase 6 builds the VERIFICATION that the mechanism works. This is the "show me" evidence, not "trust me" claims.

**This is NOT**:
- NOT running *sync on 14 projects (that is human-triggered, this phase provides the SCRIPT)
- NOT modifying the engine or gate logic (Phase 2-5 scope)
- NOT generating new manifests
- NOT a new feature -- purely verification scripts and evidence

**Blake, confirm understanding**:
```
Before starting, answer in your own words:
1. What problem does this solve?
2. How will the user use these scripts?
3. What are the success criteria?

Only start after Human confirms your understanding is correct.
```

---

## Project Knowledge (Blake)

**Blake MANDATORY READ before implementation:**
1. Read ALL listed project-knowledge files
2. Read the historical lessons below
3. This is NOT optional

### Step 1: Relevant Categories

This task involves:
- [x] testing - Test patterns/edge cases
- [x] code-quality - Shell script patterns
- [x] architecture - Script integration with existing tools

### Step 2: Historical Experience

**Read project-knowledge files**:

| File | Relevant Records | Key Reminder |
|------|-----------------|--------------|
| patterns/shell-portability.md | 4 entries | No grep -P on macOS; LC_ALL=C on sort/comm; validate CLI args |
| patterns/ac-verification.md | 3 entries | Dry-run all verification commands; AC self-leak prevention |
| patterns/gate-design.md | 2 entries | Gate must be able to FAIL to prove it is not theater; decouple detect from heal |

**Blake historical lessons**:

1. **Shell Portability** (from patterns/shell-portability.md)
   - Problem: Scripts using grep -P, locale-dependent sort, or unvalidated args fail on macOS
   - Solution: Use grep -E not -P; LC_ALL=C on all sort/comm; validate numeric args with `[[ =~ ^[0-9]+$ ]]`

2. **Gate Must FAIL to Prove Non-Theater** (from patterns/gate-design.md)
   - Problem: A gate that only ever passes is unproven
   - Solution: gate-exercise.sh must demonstrate a real exit 1, with the blocking output captured as evidence

3. **diff -rq Is the Universal Omission Catcher** (from principles.md)
   - Problem: Presence-only checks miss partial copies
   - Solution: Use `diff -rq` for content-completeness verification of ZERO_TOUCH dirs

### Blake Confirmation

- [ ] I have read the historical lessons
- [ ] I understand the problems to avoid
- [ ] I will reference the solutions above if encountering similar situations

---

## 2. Background Context

### 2.1 Previous Work

Phases 1-5 of the upgrade-lifecycle-system Epic built:
- **Phase 1**: Migration manifest schema v1 (4 sections: delete/rename/merge/verify)
- **Phase 2**: migration-engine.sh (~500 lines) + 14 E2E fixtures (now 22 total with Phase 4-5 additions)
- **Phase 3**: tad.sh + *sync integration with call_migration_engine()
- **Phase 4**: Merge capability (tad-head-marker strategy) + 4 merge fixtures (F16-F19)
- **Phase 5**: release-verify.sh migration mode + 12 historical manifests + 3 gate fixtures (MG1-MG3)

### 2.2 Current State

- 22 fixtures exist: 18 engine + 1 AC17 + 3 migration gate -- ALL PASS (verified 2026-06-10)
- 12 historical manifests in `.tad/migrations/` (v2.19.0-to-v2.19.1 through v2.26.0-to-v2.27.0)
- migration-engine.sh ENGINE_VERSION="2.29.0"
- release-verify.sh: structural + freshness + migration modes all operational
- 14 registered projects in sync-registry.yaml, all at v2.27.0
- 9 ZERO_TOUCH dirs: active, archive, decisions, evidence, github-registry, pair-testing, project-knowledge, research-notebooks, skillify-candidates
- deprecation.yaml: 6 version entries with deprecated file lists

### 2.3 Dependencies

- `.tad/hooks/lib/derive-sync-set.sh` (--zero-touch flag) -- exists, verified
- `.tad/hooks/lib/release-verify.sh` (migration mode) -- exists, verified
- `.tad/hooks/lib/migration-engine.sh` -- exists, verified
- `.tad/tests/migration-fixtures/run-fixtures.sh` -- exists, 22/22 pass
- `.tad/deprecation.yaml` -- exists, 6 version entries
- `.tad/sync-registry.yaml` -- exists, 14 projects registered

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: `upgrade-acceptance.sh` accepts `--target <dir>` and `--expected-version <ver>` arguments. Runs 4 verification checks:
  - FR1.1: ZERO_TOUCH directories `diff -rq` -- each ZERO_TOUCH dir in target must be byte-identical to pre-sync snapshot (script takes `--snapshot <dir>` for comparison)
  - FR1.2: `version.txt` matches `--expected-version`
  - FR1.3: No stale deprecated files remain (reads deprecation.yaml, checks each file against target)
  - FR1.4: Migration report exists in `.tad-backup/` if migration was expected (checked via `--expect-migration-from <ver>` flag; optional)
- **FR2**: `gate-exercise.sh` creates a temporary git repo state, deletes a tracked framework file without adding it to a manifest, runs `release-verify.sh migration`, verifies exit 1, then cleans up. All in a temp dir (no mutation of the real repo).
- **FR3**: Run existing 22 fixtures via `run-fixtures.sh` and capture output to evidence directory.
- **FR4**: Evidence directory `.tad/evidence/acceptance-tests/upgrade-lifecycle/` with:
  - `fixture-run-output.txt` -- captured from FR3
  - `gate-exercise-output.txt` -- captured from FR2
  - `README.md` -- describes what each evidence file contains
- **FR5**: Decision recommendation on warn-to-hard-block flip for the migration gate in release-verify.sh. Written as a structured recommendation in the evidence README (not a DR -- the human decides).

### 3.2 Non-Functional Requirements

- **NFR1**: Both scripts must be BSD/macOS compatible (no grep -P, LC_ALL=C where needed)
- **NFR2**: Both scripts must be idempotent (re-running produces same result)
- **NFR3**: Scripts must have clear exit codes: 0=pass, 1=verification failure, 2=usage error
- **NFR4**: Scripts must produce human-readable output with PASS/FAIL per check
- **NFR5**: gate-exercise.sh must clean up its temp dir on exit (trap cleanup)

---

## 4. Technical Design

### 4.1 Architecture Overview

```
.tad/tests/upgrade-acceptance.sh     -- post-sync per-project verification
.tad/tests/gate-exercise.sh          -- gate interception exercise (temp dir)
.tad/evidence/acceptance-tests/
  upgrade-lifecycle/
    fixture-run-output.txt           -- 22-fixture harness output
    gate-exercise-output.txt         -- gate exercise proof
    README.md                        -- evidence index + warn->block recommendation
```

### 4.2 upgrade-acceptance.sh Design

```
Usage: bash upgrade-acceptance.sh --target <dir> --expected-version <ver> \
         [--snapshot <pre-sync-snapshot-dir>] \
         [--expect-migration-from <old-ver>]

Checks (in order):
1. version.txt match
   - Read $target/.tad/version.txt, compare to --expected-version
   - PASS if match, FAIL with actual vs expected

2. ZERO_TOUCH diff (only when --snapshot provided)
   - Read ZERO_TOUCH dirs from derive-sync-set.sh --zero-touch
   - For each dir: diff -rq $snapshot/.tad/$dir $target/.tad/$dir
   - PASS if all identical, FAIL listing each differing file
   - NOTE: when --snapshot not provided, report SKIP (can't verify without baseline)

3. No stale deprecated files
   - Parse deprecation.yaml (lightweight: grep paths, not full YAML parse)
   - For each deprecated file path: check if exists in $target
   - PASS if none exist, FAIL listing each stale file found
   - Use grep to extract file paths from deprecation.yaml under each version's files: section

4. Migration report (only when --expect-migration-from provided)
   - Check for .tad-backup/{from}-to-{expected}/MIGRATION-REPORT.tsv
   - PASS if exists, FAIL if missing (migration should have created it)

Output: per-check PASS/FAIL, then summary verdict line.
Exit: 0 if all checks pass (including skipped), 1 if any fail, 2 if usage error.
```

### 4.3 gate-exercise.sh Design

```
Usage: bash gate-exercise.sh [--source <tad-repo-root>]
  Default --source: auto-detect from script location (../../..)

Steps:
1. Create temp dir (mktemp -d)
2. Set trap for cleanup on EXIT
3. Initialize a git repo in temp dir
4. Create a v0.1.0 tag with a framework file (.claude/skills/test-file.md)
5. Remove the file, bump to v0.2.0, commit and tag -- NO manifest
6. Copy derive-sync-set.sh and release-verify.sh into the temp repo
7. Run: bash release-verify.sh migration <temp-repo> 0.2.0
8. Capture output + exit code
9. Assert exit code == 1 (FAIL = gate caught the unmanifested delete)
10. Assert output contains "UNMANIFESTED DELETE"
11. Print PASS/FAIL with captured output

Exit: 0 if gate correctly blocked, 1 if gate failed to catch
```

### 4.4 deprecation.yaml Parsing (for upgrade-acceptance.sh Check 3)

The deprecation.yaml format is:
```yaml
deprecations:
  "2.3.0":
    files:
      - AGENTS.md
      - .codex/
```

Parsing approach (no jq/yq dependency -- pure grep/sed/awk):
- Extract all lines matching `^      - ` (6-space indent under `files:`) as file paths
- Strip the `      - ` prefix and quotes
- Check each path in target directory
- For directory entries (ending with `/`): check with `-d`
- For file entries: check with `-f`

### 4.5 Evidence README Content

The README.md in the evidence directory will contain:
1. Date of evidence collection
2. TAD version tested
3. Index of evidence files with descriptions
4. Fixture results summary (22/22)
5. Gate exercise result summary (PASS/FAIL)
6. **Warn-to-hard-block recommendation** with rationale:
   - Current state: TAD_RELEASE_GATE=warn downgrades migration drift to advisory
   - Recommendation: flip to hard-block AFTER the 14-project real sync confirms zero false positives
   - Rationale: The gate has been exercised (gate-exercise.sh exit 1 proof) + 22 fixtures pass + 3 migration gate fixtures (MG1-MG3) prove detection. The remaining risk is false positives on real projects -- once the 14-project sync confirms zero FP, the gate should hard-block.

---

## 5. Mandatory Questions (Evidence Required)

### MQ1: Historical Code Search

**Question**: Did the user mention "previous", "original", or "our approach"?

**Answer**:
- [x] No -- skip

### MQ2: Function Existence Verification

**Question**: Which functions does the design call? Do they all exist?

**Answer**:

| Function/Script | File Location | Line | Snippet | Verified |
|-----------------|--------------|------|---------|----------|
| derive-sync-set.sh --zero-touch | .tad/hooks/lib/derive-sync-set.sh | L16-17 | `--zero-touch the 9 category-A...` | OK |
| release-verify.sh migration | .tad/hooks/lib/release-verify.sh | L311 | `migration)` case arm | OK |
| migration-engine.sh | .tad/hooks/lib/migration-engine.sh | L1-8 | `#!/usr/bin/env bash` header | OK |
| run-fixtures.sh | .tad/tests/migration-fixtures/run-fixtures.sh | L1-7 | harness header | OK |

### MQ3: Data Flow Completeness

**Question**: What fields does the backend compute/return? Does the frontend display them?

**Answer**: Not applicable -- these are CLI scripts, not client-server.

**Data flow**:
```
upgrade-acceptance.sh
  reads: --zero-touch (derive-sync-set.sh) → ZERO_TOUCH dir list
  reads: deprecation.yaml → deprecated file paths
  reads: version.txt → current version string
  reads: .tad-backup/*/MIGRATION-REPORT.tsv → migration evidence
  outputs: per-check PASS/FAIL → stdout

gate-exercise.sh
  creates: temp git repo with unmanifested delete
  calls: release-verify.sh migration → exit code + output
  outputs: PASS/FAIL with captured gate output → stdout
```

### MQ4: Visual Hierarchy

- [x] No different states -- skip (CLI scripts)

### MQ5: State Synchronization

**Answer**: Single state -- scripts are stateless read-only verifiers. No synchronization needed.

```
[script invocation] → read target dir + reference data → output verdict
No persistent state. No synchronization.
```

---

## 6. Implementation Steps

### Phase 1: upgrade-acceptance.sh (estimated 1 hour)

#### Deliverables
- [ ] `.tad/tests/upgrade-acceptance.sh` -- complete post-sync verification script
- [ ] Script passes `bash -n` syntax check

#### Implementation Steps

1. Create `.tad/tests/upgrade-acceptance.sh` with:
   - Argument parsing: `--target`, `--expected-version`, `--snapshot` (optional), `--expect-migration-from` (optional)
   - Usage/help output on bad args (exit 2)
   - Check 1: version.txt match
   - Check 2: ZERO_TOUCH diff -rq (skip if --snapshot not provided)
   - Check 3: deprecated file absence (parse deprecation.yaml)
   - Check 4: migration report existence (skip if --expect-migration-from not provided)
   - Summary verdict with per-check PASS/FAIL/SKIP
   - Exit code: 0 all pass, 1 any fail, 2 usage

2. Implementation hints:
   - Locate derive-sync-set.sh relative to script: `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"` then `DERIVE="$SCRIPT_DIR/../hooks/lib/derive-sync-set.sh"`
   - For deprecation.yaml parsing: use awk to extract file paths (state machine: track when inside a `files:` block, capture `- path` lines)
   - For ZERO_TOUCH diff: iterate `--zero-touch` output, for each dir check if both `$snapshot/.tad/$dir` and `$target/.tad/$dir` exist, then `diff -rq`
   - trap cleanup not needed (read-only script)
   - Colors: same pattern as run-fixtures.sh (RED/GREEN/RESET if terminal)

3. Deprecation.yaml parsing detail (awk approach):
   ```bash
   # Extract all deprecated file paths from deprecation.yaml
   awk '
     /^  "[0-9]/ { in_version=1; next }
     /^    files:/ { in_files=1; next }
     in_files && /^      - / {
       sub(/^      - /, "")
       gsub(/"/, "")
       gsub(/'\''/, "")
       print
       next
     }
     in_files && !/^      / { in_files=0 }
   ' "$deprecation_yaml"
   ```

#### Verification
- `bash -n .tad/tests/upgrade-acceptance.sh` exits 0
- `bash .tad/tests/upgrade-acceptance.sh` (no args) exits 2 with usage
- `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0` exits 0 (version matches, deprecated files already cleaned)

#### Phase 1 Evidence (Blake must provide)
- [ ] `bash -n` output (exit 0)
- [ ] Usage output on bad args (exit 2)
- [ ] Run against TAD repo itself with `--expected-version 2.27.0`: version check PASS

**Human decision**: Continue to Phase 2 / Adjust

---

### Phase 2: gate-exercise.sh (estimated 45 minutes)

#### Deliverables
- [ ] `.tad/tests/gate-exercise.sh` -- gate interception exercise script
- [ ] Script passes `bash -n` syntax check

#### Implementation Steps

1. Create `.tad/tests/gate-exercise.sh` with:
   - Auto-detect source root from script location (or accept `--source` arg)
   - Create temp dir with trap cleanup on EXIT
   - Initialize git repo in temp dir
   - Create v0.1.0 tag with `.claude/skills/test-file.md`
   - Remove the file, commit as v0.2.0 with tag -- NO manifest
   - Copy `derive-sync-set.sh` and `release-verify.sh` into temp repo's `.tad/hooks/lib/`
   - Run `bash release-verify.sh migration <temp> 0.2.0` capturing output + exit code
   - Assert exit == 1
   - Assert output contains "UNMANIFESTED DELETE"
   - Print captured output + PASS/FAIL verdict
   - Cleanup happens via trap

2. Implementation hints:
   - Use the same `create_source` / `add_version` pattern from run-fixtures.sh
   - The temp repo needs `.tad/hooks/lib/derive-sync-set.sh` for the migration gate to work (it calls --zero-touch)
   - git config user.email/name needed for commits in temp dir
   - Capture both stdout and stderr from release-verify.sh: `out="$(bash release-verify.sh migration "$tmp" "0.2.0" 2>&1)"`
   - Print the raw gate output as proof (this becomes the evidence artifact)

#### Verification
- `bash -n .tad/tests/gate-exercise.sh` exits 0
- `bash .tad/tests/gate-exercise.sh` exits 0 and output contains "UNMANIFESTED DELETE" + "PASS"

#### Phase 2 Evidence (Blake must provide)
- [ ] `bash -n` output (exit 0)
- [ ] Full script output showing gate interception + PASS verdict

**Human decision**: Continue to Phase 3 / Adjust

---

### Phase 3: Evidence Collection + Run All (estimated 30 minutes)

#### Deliverables
- [ ] `.tad/evidence/acceptance-tests/upgrade-lifecycle/fixture-run-output.txt`
- [ ] `.tad/evidence/acceptance-tests/upgrade-lifecycle/gate-exercise-output.txt`
- [ ] `.tad/evidence/acceptance-tests/upgrade-lifecycle/README.md`

#### Implementation Steps

1. Create evidence directory: `mkdir -p .tad/evidence/acceptance-tests/upgrade-lifecycle/`
2. Run fixture harness and capture: `bash .tad/tests/migration-fixtures/run-fixtures.sh > fixture-run-output.txt 2>&1`
3. Run gate exercise and capture: `bash .tad/tests/gate-exercise.sh > gate-exercise-output.txt 2>&1`
4. Write README.md with:
   - Date: 2026-06-10
   - TAD version: 2.27.0
   - Evidence file index
   - Fixture results summary line
   - Gate exercise result summary line
   - Warn-to-hard-block recommendation (see 4.5 above)

5. README.md warn-to-hard-block recommendation content:
   ```
   ## Gate Warn-to-Hard-Block Recommendation

   **Current state**: TAD_RELEASE_GATE=warn downgrades migration gate (release-verify.sh
   migration mode exit 1) to advisory warning during *publish.

   **Recommendation**: Flip to hard-block.

   **Evidence supporting the flip**:
   1. Gate exercise proves real interception (exit 1 on unmanifested delete)
   2. 22/22 engine fixtures pass (including 3 migration gate fixtures MG1-MG3)
   3. 12 historical manifests cover v2.19.0 through v2.27.0 with no gaps
   4. MG2 proves ZERO_TOUCH exclusion works (no false positives on user dirs)

   **Remaining risk**: False positives on real *publish with non-framework file
   changes. Mitigation: the gate scopes to framework paths only (.tad/, .claude/,
   .codex/, .agents/, root files) and excludes ZERO_TOUCH dirs.

   **Recommended trigger**: After the 14-project real *sync confirms the acceptance
   script passes on all projects, flip TAD_RELEASE_GATE from warn to hard-block
   (or remove the warn override entirely, since hard-block is the default for
   non-patch releases per the gate rule contract in release-verify.sh header).
   ```

#### Verification
- `ls .tad/evidence/acceptance-tests/upgrade-lifecycle/` shows 3 files
- `grep "ALL FIXTURES PASS" .tad/evidence/acceptance-tests/upgrade-lifecycle/fixture-run-output.txt` exits 0
- `grep -q "PASS" .tad/evidence/acceptance-tests/upgrade-lifecycle/gate-exercise-output.txt` exits 0

#### Phase 3 Evidence (Blake must provide)
- [ ] Directory listing of evidence dir
- [ ] Head of each evidence file
- [ ] README.md content

**Human decision**: Accept / Adjust

---

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | .tad/tests/upgrade-acceptance.sh | Create: arg parsing + usage | `bash -n .tad/tests/upgrade-acceptance.sh && bash .tad/tests/upgrade-acceptance.sh 2>&1; echo $?` should show usage + exit 2 | 5 min |
| 2 | .tad/tests/upgrade-acceptance.sh | Add: version.txt check | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -i version` shows PASS | 5 min |
| 3 | .tad/tests/upgrade-acceptance.sh | Add: ZERO_TOUCH diff check | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -i zero` shows SKIP (no --snapshot) | 5 min |
| 4 | .tad/tests/upgrade-acceptance.sh | Add: deprecation.yaml check | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -i deprecated` shows PASS | 10 min |
| 5 | .tad/tests/upgrade-acceptance.sh | Add: migration report check + summary | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0; echo $?` exits 0 | 5 min |
| 6 | .tad/tests/gate-exercise.sh | Create: full gate exercise script | `bash -n .tad/tests/gate-exercise.sh && bash .tad/tests/gate-exercise.sh 2>&1 \| grep PASS` | 15 min |
| 7 | .tad/evidence/acceptance-tests/upgrade-lifecycle/ | Create: evidence dir + capture outputs + README | `ls .tad/evidence/acceptance-tests/upgrade-lifecycle/ \| wc -l` >= 3 | 10 min |
| 8 | Chain dry-run (P0-1 fix) | Run: `bash .tad/hooks/lib/migration-engine.sh --from 2.19.0 --to 2.27.0 --target /tmp/tad-chain-test --source . --dry-run` and capture output to evidence | exit 0 + resolves 12 manifests | 5 min |
| 9 | README merge-strategy documentation (P0-2 fix) | Add to README.md: document that 3 projects (my-openclaw-agents/toy/内存管理) need marker `<!-- TAD:PROJECT-CONTENT-BELOW -->` added to their CLAUDE.md, then re-run *sync for merge to work. This is a human step post-Epic. | grep -c merge-strategy README.md >= 1 | 3 min |

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/tests/upgrade-acceptance.sh                              # Post-sync per-project verification
.tad/tests/gate-exercise.sh                                   # Gate interception exercise
.tad/evidence/acceptance-tests/upgrade-lifecycle/README.md     # Evidence index + recommendation
.tad/evidence/acceptance-tests/upgrade-lifecycle/fixture-run-output.txt    # Captured fixture output
.tad/evidence/acceptance-tests/upgrade-lifecycle/gate-exercise-output.txt  # Captured gate exercise output
```

### 7.2 Files to Modify
```
(none)
```

### 7.3 Grounded Against (Alex step1c)

- `.tad/hooks/lib/derive-sync-set.sh` (head 50 lines, read at 2026-06-10 00:10) -- --zero-touch flag contract, DENY_LIST structure
- `.tad/hooks/lib/release-verify.sh` (full file, read at 2026-06-10 00:10) -- migration mode case arm (L311-477), exit code contract (header)
- `.tad/hooks/lib/migration-engine.sh` (head 50 lines, read at 2026-06-10 00:12) -- ENGINE_VERSION="2.29.0", arg parsing, exit codes
- `.tad/tests/migration-fixtures/run-fixtures.sh` (full file, read at 2026-06-10 00:10) -- 22 fixtures, helper patterns (create_source, add_version, write_manifest, create_target)
- `.tad/deprecation.yaml` (head 30 lines, read at 2026-06-10 00:14) -- YAML structure for parsing
- `.tad/evidence/acceptance-tests/upgrade-lifecycle/README.md` (new -- will be created)
- `.tad/tests/upgrade-acceptance.sh` (new -- will be created)
- `.tad/tests/gate-exercise.sh` (new -- will be created)

---

## 8. Testing Requirements

### 8.1 Unit Tests

Not applicable -- these are self-contained verification scripts. Testing IS the deliverable.

### 8.2 Integration Tests

- Test upgrade-acceptance.sh against the TAD repo itself: `--target . --expected-version 2.27.0` should PASS (version matches, deprecated files cleaned)
- Test gate-exercise.sh standalone: should create temp git state, catch unmanifested delete, exit 0
- Run existing 22 fixtures: all must still pass (regression check)

### 8.3 Edge Cases

- upgrade-acceptance.sh with wrong version: `--expected-version 9.9.9` should FAIL the version check
- upgrade-acceptance.sh without --snapshot: ZERO_TOUCH check should SKIP, not FAIL
- upgrade-acceptance.sh without --expect-migration-from: migration report check should SKIP
- gate-exercise.sh cleanup: even if assertions fail, temp dir must be cleaned up (trap)
- deprecation.yaml entries with directory paths (ending in `/`): check with `-d`, not `-f`

### 8.4 Test Evidence Required

Blake must provide:
- [ ] upgrade-acceptance.sh `bash -n` passes
- [ ] upgrade-acceptance.sh run against TAD repo with correct version: PASS
- [ ] upgrade-acceptance.sh run against TAD repo with wrong version: FAIL
- [ ] gate-exercise.sh `bash -n` passes
- [ ] gate-exercise.sh run: gate interception PASS
- [ ] run-fixtures.sh: 22/22 PASS (regression)
- [ ] Evidence directory contains all 3 files

---

## 9. Acceptance Criteria

Blake's implementation is complete when and only when:
- [ ] All FRs implemented and verified
- [ ] All Phases completed with evidence
- [ ] All tests pass (with evidence)
- [ ] Human verifies "this is what I expected"

---

## 9.1 Spec Compliance Checklist -- PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | upgrade-acceptance.sh syntax valid | post-impl-verifiable | `bash -n .tad/tests/upgrade-acceptance.sh; echo $?` | exit 0 | (post-impl) |
| AC2 | upgrade-acceptance.sh usage on bad args | post-impl-verifiable | `bash .tad/tests/upgrade-acceptance.sh 2>&1; echo "EXIT:$?"` | Contains "Usage" and EXIT:2 | (post-impl) |
| AC3 | upgrade-acceptance.sh version check PASS | post-impl-verifiable | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -i 'version.*PASS'` | 1 match | (post-impl) |
| AC4 | upgrade-acceptance.sh version check FAIL | post-impl-verifiable | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 9.9.9 2>&1 \| grep -i 'version.*FAIL'` | 1 match | (post-impl) |
| AC5 | upgrade-acceptance.sh ZERO_TOUCH skips without --snapshot | post-impl-verifiable | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -i 'zero.*SKIP'` | 1 match | (post-impl) |
| AC6 | upgrade-acceptance.sh deprecated files check runs | post-impl-verifiable | `bash .tad/tests/upgrade-acceptance.sh --target . --expected-version 2.27.0 2>&1 \| grep -iE 'deprecat.*(PASS\|FAIL)'` | 1 match | (post-impl) |
| AC7 | upgrade-acceptance.sh reads derive-sync-set.sh --zero-touch | post-impl-verifiable | `grep -c 'derive-sync-set.sh.*--zero-touch' .tad/tests/upgrade-acceptance.sh` | >= 1 | (post-impl) |
| AC8 | upgrade-acceptance.sh reads deprecation.yaml | post-impl-verifiable | `grep -c 'deprecation.yaml' .tad/tests/upgrade-acceptance.sh` | >= 1 | (post-impl) |
| AC9 | upgrade-acceptance.sh exit codes: 0/1/2 | post-impl-verifiable | `grep -cE 'exit [012]' .tad/tests/upgrade-acceptance.sh` | >= 3 | (post-impl) |
| AC10 | gate-exercise.sh syntax valid | post-impl-verifiable | `bash -n .tad/tests/gate-exercise.sh; echo $?` | exit 0 | (post-impl) |
| AC11 | gate-exercise.sh runs and catches unmanifested delete | post-impl-verifiable | `bash .tad/tests/gate-exercise.sh 2>&1 \| grep -i 'PASS'` | 1 match | (post-impl) |
| AC12 | gate-exercise.sh output contains raw gate output | post-impl-verifiable | `bash .tad/tests/gate-exercise.sh 2>&1 \| grep -i 'UNMANIFESTED DELETE'` | 1 match | (post-impl) |
| AC13 | gate-exercise.sh uses trap for cleanup | post-impl-verifiable | `grep -c 'trap.*EXIT' .tad/tests/gate-exercise.sh` | >= 1 | (post-impl) |
| AC14 | Existing 22 fixtures still pass | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| tail -1` | "ALL FIXTURES PASS (22/22)" | (post-impl) |
| AC15 | Evidence dir exists with 3 files | post-impl-verifiable | `ls .tad/evidence/acceptance-tests/upgrade-lifecycle/ \| wc -l \| tr -d ' '` | 3 | (post-impl) |
| AC16 | Evidence fixture output contains ALL PASS | post-impl-verifiable | `grep -c 'ALL FIXTURES PASS' .tad/evidence/acceptance-tests/upgrade-lifecycle/fixture-run-output.txt` | 1 | (post-impl) |
| AC17 | Evidence gate exercise contains PASS | post-impl-verifiable | `grep -c 'PASS' .tad/evidence/acceptance-tests/upgrade-lifecycle/gate-exercise-output.txt` | >= 1 | (post-impl) |
| AC18 | README contains warn-to-hard-block recommendation | post-impl-verifiable | `grep -c 'hard-block' .tad/evidence/acceptance-tests/upgrade-lifecycle/README.md` | >= 1 | (post-impl) |
| AC19 | Scripts use set -euo pipefail | post-impl-verifiable | `grep -c 'set -euo pipefail' .tad/tests/upgrade-acceptance.sh .tad/tests/gate-exercise.sh` | 2 | (post-impl) |
| AC20 | No grep -P in any new script | pre-impl-verifiable | `grep -c 'grep -P' .tad/tests/upgrade-acceptance.sh .tad/tests/gate-exercise.sh 2>/dev/null \|\| echo 0` | 0 | Verified: files do not yet exist, will be created without grep -P (shell-portability rule) |
| AC21 | Change scope limited to new files | post-impl-verifiable | `git diff --stat HEAD` | Only .tad/tests/upgrade-acceptance.sh, .tad/tests/gate-exercise.sh, .tad/evidence/acceptance-tests/upgrade-lifecycle/* | (post-impl) |
| AC22 | Chain upgrade dry-run (v2.19.0→v2.27.0) PASS | post-impl-verifiable | `bash .tad/hooks/lib/migration-engine.sh --from 2.19.0 --to 2.27.0 --target /tmp/tad-chain-test --source . --dry-run 2>&1; echo "exit=$?"` | exit=0 + output contains chain resolving 12 manifests | (post-impl) |
| AC23 | 3 merge-strategy projects documented | post-impl-verifiable | `grep -c 'merge-strategy\|marker.*project\|openclaw\|toy\|内存' .tad/evidence/acceptance-tests/upgrade-lifecycle/README.md` | >= 1 (human step documented) | (post-impl) |

---

## 9.2 Expert Review Status (Alex)

### Experts Selected

1. **shell-security-reviewer** -- These scripts create temp git repos and parse YAML; need to verify no injection vectors or cleanup failures
2. **test-architect** -- Acceptance test design review to ensure the scripts actually verify what they claim

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| shell-security-reviewer | P1: deprecation.yaml awk parsing could break on quoted paths with spaces | S4.4 parsing hint now uses gsub to strip quotes | Resolved |
| shell-security-reviewer | P1: gate-exercise.sh must not leave temp dirs on failure | S4.3 design specifies trap on EXIT | Resolved |
| test-architect | P1: upgrade-acceptance.sh should distinguish SKIP from PASS in exit code | S4.2 clarifies SKIP counts as PASS for exit code (exit 0) -- a skipped check is not a failure | Resolved |
| test-architect | P2: Consider adding --source arg to upgrade-acceptance.sh for derive-sync-set.sh location | Deferred: script locates it relative to SCRIPT_DIR, sufficient for TAD repo structure | Deferred |

### Overall Assessment (post-integration)

- shell-security-reviewer: PASS (0 P0, 2 P1 resolved)
- test-architect: PASS (0 P0, 1 P1 resolved, 1 P2 deferred)

---

## 10. Important Notes

### 10.1 Critical Warnings

- **The 14-project *sync is NOT part of this handoff.** Blake implements the verification SCRIPT. The human triggers *sync separately. Document this clearly in the evidence README.
- **upgrade-acceptance.sh requires --snapshot for ZERO_TOUCH verification.** Without it, the ZERO_TOUCH check SKIPs (the human must take a snapshot BEFORE running *sync: `cp -a project/.tad/project-knowledge project-snapshot/`).
- **gate-exercise.sh operates ONLY in a temp dir.** It must never modify the real TAD repo.

### 10.2 Known Constraints

- deprecation.yaml parsing is lightweight (awk/grep, not a full YAML parser) -- this is intentional to avoid jq/yq dependencies
- The acceptance script cannot verify ZERO_TOUCH byte-identity without a pre-sync snapshot -- this is by design (the snapshot is the human's responsibility)
- gate-exercise.sh needs git to create tags -- this is available in all TAD environments

### 10.3 Sub-Agent Usage Suggestions

Blake should consider:
- [ ] **test-runner** -- After completing each Phase, verify scripts work
- [ ] **bug-hunter** -- If deprecation.yaml parsing produces unexpected results

---

## 11. Learning Content

### 11.1 Decision Rationale: Script vs Fixture Approach

**Chosen approach**: Standalone scripts (upgrade-acceptance.sh + gate-exercise.sh) that produce evidence files

**Alternatives considered**:

| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| Standalone scripts (chosen) | Reusable by human after *sync; clear evidence trail; simple to maintain | Two new files | Selected |
| Add to run-fixtures.sh | Single test entry point | Mixes unit-level fixtures with acceptance-level verification; can't run upgrade-acceptance per-project | Different granularity |
| Inline in *sync protocol | Automatic verification | Couples verification to execution; can't re-run independently | Violates "decouple detect from heal" |

**Core tradeoff**: Reusability vs integration. Standalone scripts win because the human needs to run them per-project after *sync, which is a different invocation pattern from the fixture harness.

---

## 12. Sub-Agent Usage Record

Blake fills this in after completion:

| Sub-Agent | Called | When | Output Summary | Evidence Link |
|-----------|-------|------|----------------|---------------|
| test-runner | | | | |
| bug-hunter | | | | |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
