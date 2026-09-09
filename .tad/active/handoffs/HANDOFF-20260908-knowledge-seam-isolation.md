---
task_id: TASK-20260908-KNOWLEDGE-SEAM-ISOLATION
task_type: feature
express: false
skip_knowledge_assessment: no
e2e_required: yes
research_required: no
status: READY_FOR_BLAKE
created: 2026-09-08
author: Alex (Solution Lead)
owner: Blake (Terminal 2)
---

# HANDOFF-20260908-knowledge-seam-isolation — Upstream Knowledge Seam & Downstream Isolation

**Task ID**: `TASK-20260908-KNOWLEDGE-SEAM-ISOLATION` | **Owner**: Blake (Terminal 2) | **Author**: Alex (Terminal 1)  
**Created**: 2026-09-08 | **Status**: `READY_FOR_BLAKE (Gate2-R4 dual PASS)` (Gate 2 R3 P0 cleared; Human Locks: ①A pure isolation + ②quarantine opt-in)  
**Target Version**: `v2.45.0` (or patch)  
**Design Reference**: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`  

---

## 1. Execution Mandate (PM / Human Authorization Scope)

- **Outcome**:
  1. Ban copying upstream `.tad/brain-index.md` to downstream repositories via `tad.sh` sync/install by updating `TOP_DENY` in `.tad/hooks/lib/derive-sync-set.sh` and `TAD_TOP_DENY` in `tad.sh`.
  2. Fix `set -euo pipefail` abortion defect across all 7 `grep` pipeline sites in `.tad/hooks/lib/brain-index-gen.sh`.
  3. Wire soft `brain-index` rebuild triggers into post-distillation (`distillation-loop-protocol.md` Step 6, `acceptance-protocol.md`) and maintenance routines (`tad doctor`, `tad-maintain`), strictly non-blocking and WARN-only.
  4. Enforce strict project knowledge isolation: new project installs receive only clean `README.md` (no framework incidents or patterns; `patterns/` and `incidents/` subdirectories initialized empty).
  5. Provide non-destructive quarantine utility (`.tad/hooks/lib/quarantine-framework-pk.sh`) with `tad.sh --quarantine-pk` CLI wiring, strictly opt-in, preserving `README.md` and locally modified files.
  6. Protect project-owned skills (`local/` and `ownership: project-owned` in all YAML serialization forms) from being overwritten by `tad.sh` across both `.claude/skills/` and `.agents/skills/`.
  7. Protect customized downstream `project-knowledge/README.md` during `tad.sh upgrade`/`migrate` (do not overwrite if exists).
- **Target Files**:
  - `.tad/hooks/lib/derive-sync-set.sh` (multiline `TOP_DENY` representation)
  - `tad.sh` (multiline `TAD_TOP_DENY`, set-membership consumer in `derive_framework_top_files`, CLI `--quarantine-pk` parser/help/dispatch, `copy_framework_files` project-skill protection, `install`/`upgrade`/`migrate` pk isolation and README preservation)
  - `.tad/hooks/lib/brain-index-gen.sh` (wrap all 7 pipefail sites with `{ grep ... || true; }` and fallback defaults, fix find grouping)
  - `.tad/hooks/lib/quarantine-framework-pk.sh` (new tool: portable sha256, strict pk-only scope, README exclusion, MANIFEST logging, idempotency)
  - `.tad/project-knowledge/README.md` (modernize distillation guide)
  - `.claude/skills/alex/references/distillation-loop-protocol.md` (scoped trigger in Step 6)
  - `.agents/skills/alex/references/distillation-loop-protocol.md` (dual platform mirror parity)
  - `.claude/skills/alex/references/acceptance-protocol.md` (Step 4f/Step 7 trigger)
  - `.agents/skills/alex/references/acceptance-protocol.md` (dual platform mirror parity)
  - `.claude/skills/tad-maintain/SKILL.md` (WARN-only freshness check in CHECK mode, auto-rebuild in SYNC mode)
  - `.agents/skills/tad-maintain/SKILL.md` (dual platform mirror parity)
- **Consequence**:
  - Downstream repositories no longer receive upstream TAD's internal `brain-index.md` or 26 framework incident/pattern files.
  - Existing polluted repos have an automated, safe, opt-in quarantine path to remove "fake richness".
  - Knowledge remains forged at distill, with soft evidence tracking.
- **Blast Radius**:
  - Framework distribution pipeline (`derive-sync-set.sh`, `tad.sh` top-file sync, `copy_framework_files`).
  - Installer/updater CLI (`tad.sh install/upgrade/migrate`, `tad.sh --quarantine-pk`).
  - Protocol references across dual platform trees (`.claude/` and `.agents/`).
- **Out of Scope (Explicit per Locked Decision ①)**:
  - No `framework-principles.md`; no provenance-tag machinery in v2.45.0 (pure isolation per locked Option A).
  - No auto-quarantine on `tad.sh update` (locked Option ②).
- **Forbidden**:
  - Making per-ticket journal capture a blocking Gate 3 or Gate 4 PASS requirement.
  - Making `brain-index.md` freshness a blocking Gate 3 or Gate 4 check.
  - Deleting user-modified files or sanctioned `README.md` in downstream `.tad/project-knowledge/`.
  - Re-opening locked decisions (must stay Option A + opt-in).
  - Calling external CLI without user confirmation or bypassing dual platform parity.

---

## 📚 Project Knowledge (Historical Lessons & Architectural Grounding)

The following project knowledge entries govern this task:
- **`principles.md:74`** (*Deny-List Beats Allow-List for Sync Sets; Version Grep Must Scope to git-ls-files; diff-r is the Universal Omission Catcher*):
  For any growing sync/distribution set: deny-list not allow-list; make the EXCLUSION assertion the load-bearing AC (`--dirs | grep -cxE '<deny>' == 0`).
- **`principles.md:94`** (*Deny-List Must Be Applied at EVERY Copy Granularity, and Verifiers Must Match Each Granularity*):
  Fixing the deny-list at one copy granularity (dirs) does not fix it at others (top-level files). Every copy loop must be derived by deny-list. A verifier is only as good as the granularity it inspects — top-file deny requires top-file verification.
- **`principles.md:110`** (*Knowledge Is Forged at Distill, Not Captured*):
  Capture is cheap, distillation is forge-work. Do NOT make per-ticket journal a Gate PASS requirement. Evidence paths must remain soft and advisory.
- **`patterns/shell-portability.md`** (*Hook Shell Portability Rules*):
  All shell scripts must be bash 3.2+ compatible (macOS/BSD safe). Use portable sha256 calculation (`sha256sum` or `shasum -a 256`). Always guard pipelines under `set -euo pipefail` using `{ grep ... 2>/dev/null || true; } | ...`.
- **`patterns/ac-verification.md`** (*AC Verification Drift Pattern & Behavioral Discrimination*):
  Alex and Blake must provide runnable verification commands and avoid vacuous assertions. Verifiers must inspect the exact granularity of the change.
- **`patterns/release-sync.md`** (*Dual-Platform Parity and Sync Safeguards*):
  Parity between `.claude/skills/` and `.agents/skills/` is mandatory. Ignore rules and skill protection must cover `local/` and all legal YAML quoting forms (`ownership: project-owned`, single-quoted, double-quoted).

---

## 2. Background & Problem Statement

Empirical audit across 5 repositories (`TAD`, `买卖`, `menu-tales`, `agent-workshop`, `grok-cloud`) revealed:
1. **Identical Brain-Index Header**: All 5 share an identical `brain-index.md` header `Generated: 2026-09-02 14:23` copied from upstream.
2. **"Fake Richness" in Project Knowledge**: In `买卖`, 26 of 41 project-knowledge files are byte-identical to TAD framework's internal incidents and patterns, wasting context and distorting project memory.
3. **The `tad.sh` Mechanism Leak**: While `project-knowledge/` was marked `ZERO_TOUCH`, `derive_framework_top_files()` in `tad.sh` only denied `sync-registry.yaml`. `.tad/brain-index.md` was treated as a regular syncable file and copied downstream.
4. **The `brain-index-gen.sh` Pipefail Defect**: `brain-index-gen.sh` crashes under `set -euo pipefail` when encountering older handoffs lacking `task_type:`. No protocol step actually refreshed the index post-distillation.

Detailed design: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`.

---

## 3. Implementation Tasks (For Blake)

### Task 1: Exclude `brain-index.md` from Top-Level Framework Sync
- **File**: `.tad/hooks/lib/derive-sync-set.sh`
  - Update `TOP_DENY` (line 77) to a multi-line newline-delimited string:
    ```bash
    TOP_DENY="sync-registry.yaml
    brain-index.md"
    ```
- **File**: `tad.sh`
  - Update `TAD_TOP_DENY` (line 566) to a multi-line newline-delimited string:
    ```bash
    TAD_TOP_DENY="sync-registry.yaml
    brain-index.md"
    ```
  - Update consumer in `derive_framework_top_files()` (lines 592–603):
    Update comment on line 592 ("the excluded files", not "the only excluded file").
    Replace scalar string equality `[ "$bn" = "$TAD_TOP_DENY" ]` with set-membership check:
    ```bash
    printf '%s\n' "$TAD_TOP_DENY" | grep -Fxq "$bn" && continue
    ```
- **Verification Assertions (Direct Behavioral Probe)**:
  - `derive_framework_top_files "$TAD_ROOT"` must NOT output `brain-index.md`.
  - `derive_framework_top_files "$TAD_ROOT"` must STILL NOT output `sync-registry.yaml` ("pin the siblings" rule).
  - `derive_framework_top_files "$TAD_ROOT"` MUST output `version.txt`.
  - `bash tad.sh --verify-denylist` must exit 0.

### Task 2: Robustify `brain-index-gen.sh` Pipefail Handling
- **File**: `.tad/hooks/lib/brain-index-gen.sh`
  - Wrap vulnerable `grep` / `grep -m1` invocations under `set -euo pipefail` across 7 handoff/doc grep sites + 1 find-precedence fix + 1 config grep site (re-pinned to live lines):
    1. Line 94: `summary=$({ grep -m1 '^## \|^### ' "$file" 2>/dev/null || true; } | sed 's/^#* //' | cut -c1-120 | escape_pipe)`
    2. Line 135: `task_type=$({ grep -m1 '^task_type:' "$file" 2>/dev/null || true; } | sed 's/task_type: *//' | tr -d '[:space:]')`; default: `task_type="${task_type:-unknown}"`
    3. Line 155: `summary=$({ grep -m1 '^[^#>|!-]' "$file" 2>/dev/null || true; } | head -1 | cut -c1-120 | escape_pipe)`
    4. Line 172: Fix operator precedence in find command:
       `find "$ARCHIVE_DIR" \( -name "HANDOFF-*.md" -o -name "handoff-*.md" \) 2>/dev/null | sort -r | head -50 | \`
    5. Line 174: `task_type=$({ grep -m1 '^task_type:' "$file" 2>/dev/null || true; } | sed 's/task_type: *//;s/ *#.*//' | tr -d '[:space:]')`; default: `task_type="${task_type:-unknown}"`
    6. Line 177: `summary=$({ grep -m1 '^# ' "$file" 2>/dev/null || true; } | sed 's/^# //' | cut -c1-120 | escape_pipe)`; default: `summary="${summary:-untitled}"`
    7. Line 212: `summary=$({ grep -m1 '^# \|^## ' "$file" 2>/dev/null || true; } | sed 's/^#* //' | cut -c1-120 | escape_pipe)`
    8. Line 228 (config grep site): `contains=$({ grep '^ *- ' "$file" 2>/dev/null || true; } | head -5 | tr '\n' ',' | sed 's/^ *- //g;s/,$//' | cut -c1-120 | escape_pipe)` (wrap config grep site for pipefail defense against empty lists)
    9. Line 251: `summary=$({ grep -m1 '^[^#>|!-]' "$file" 2>/dev/null || true; } | head -1 | cut -c1-80 | escape_pipe)`
  - Ensure script runs to completion across the entire archive, respecting the `head -50` cap on archived handoffs plus all active handoffs, producing non-empty entries (no fallback regressions).

### Task 3: Wire Soft Brain-Index Refresh Triggers
- **File**: `.claude/skills/alex/references/distillation-loop-protocol.md` and `.agents/skills/alex/references/distillation-loop-protocol.md`
  - In `## Step 6: Finalize` (before the next `## ` heading), add non-blocking execution:
    ```markdown
    bash .tad/hooks/lib/brain-index-gen.sh >/dev/null 2>&1 || true
    ```
- **File**: `.claude/skills/alex/references/acceptance-protocol.md` and `.agents/skills/alex/references/acceptance-protocol.md`
  - In Step 4f / Step 7, add soft rebuild execution when knowledge files are touched.
- **File**: `tad.sh` (`tad doctor` / `--doctor`), `.claude/skills/tad-maintain/SKILL.md`, and `.agents/skills/tad-maintain/SKILL.md`
  - Add status check: compare mtime of `.tad/brain-index.md` against the newest file in `.tad/project-knowledge/`.
  - In `CHECK` mode / `tad doctor`: print advisory warning if stale (`⚠️ brain-index.md is older than project-knowledge`), but exit 0 (WARN-only, never fail).
  - In `SYNC` mode: automatically run `bash .tad/hooks/lib/brain-index-gen.sh >/dev/null 2>&1 || true`.
  - Negative invariant: No Gate 3 or Gate 4 verification script shall block on `brain-index.md` freshness.

### Task 4: Shell/Install Clean Initialization, Skill Protection & CLI Wiring
- **File**: `tad.sh`
  - **CLI Parser & Dispatch (lines 320–375)**:
    - Add `--quarantine-pk` option to `while [ $# -gt 0 ]` parser loop:
      ```bash
      --quarantine-pk)
        shift
        exec bash .tad/hooks/lib/quarantine-framework-pk.sh "$@"
        ;;
      ```
    - Add `--quarantine-pk` entry to `show_help()`:
      `echo "  --quarantine-pk    quarantine legacy framework project-knowledge pollution (opt-in)"`
  - **Install Routine (lines 2660–2670)**:
    - Create directory structure under Option A:
      `mkdir -p .tad/project-knowledge/patterns .tad/project-knowledge/incidents`
    - Copy ONLY `README.md`:
      `cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true`
    - Do NOT copy upstream `principles.md`, `patterns/*.md`, or `incidents/**`.
  - **Upgrade / Migrate Routines (lines 2770, 2850)**:
    - Protect downstream-customized `README.md`:
      ```bash
      if [ ! -f .tad/project-knowledge/README.md ]; then
          cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true
      fi
      ```
  - **Skill Protection in `copy_framework_files()` (lines 1150–1180)**:
    - Skip `local/` directory: `[ "$skill_name" = "local" ] && continue`
    - Protect project-owned skills matching all legal YAML quoting forms (`ownership: project-owned`, single-quoted, double-quoted):
      ```bash
      if [ -f "$TARGET_SKILL_DIR/$skill_name/SKILL.md" ] && \
         grep -qE '^[[:space:]]*ownership:[[:space:]]*["'\'']?project-owned["'\'']?' "$TARGET_SKILL_DIR/$skill_name/SKILL.md"; then
          log_info "  → Preserving project-owned skill: $skill_name"
          continue
      fi
      ```
    - Ensure checks apply across both `.claude/skills/` and `.agents/skills/`.

### Task 5: Downstream Quarantine Tool
- **File**: `.tad/hooks/lib/quarantine-framework-pk.sh` (new tool)
  - Ensure executable permissions (`chmod +x`).
  - **Scope Limitation**: Must operate strictly within target repository's `.tad/project-knowledge/`.
  - **README Exclusion (P0-3)**: Must **NEVER** move or modify `.tad/project-knowledge/README.md`.
  - **Portable Hash Calculation (P1-4)**:
    ```bash
    hash_file() {
      if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
      else
        shasum -a 256 "$1" | awk '{print $1}'
      fi
    }
    ```
  - **Reference Manifest**: Inlined table of known upstream framework files (the 26 legacy files from 2026-05/06 incidents and framework patterns) with their canonical sha256 hashes.
  - **Action Matrix**:
    - For each file in target `.tad/project-knowledge/` (excluding `README.md`):
      - If `hash_file(file) == upstream_hash`:
        - Move file to `.tad/archive/quarantine-framework-pk-YYYYMMDD-HHMMSS/<relative_path>`.
        - Record in `.tad/archive/quarantine-framework-pk-YYYYMMDD-HHMMSS/MANIFEST.md`.
      - If `hash_file(file) != upstream_hash` (locally modified):
        - Retain in place, log warning: `User-modified knowledge preserved: <path>`.
  - **Manifest Schema**:
    `| Original File | Sha256 | Action | Reason | Timestamp |`
  - **Idempotency**: Running on a clean repository where 0 matching files are found prints `0 files quarantined`, creates NO empty quarantine archive directory, and exits 0.
  - **Post-Quarantine Rebuild**: Regenerate local `brain-index.md` via `bash .tad/hooks/lib/brain-index-gen.sh >/dev/null 2>&1 || true`.

### Task 6: Dual-Platform Skill Parity
- Keep all modified skill and reference files in `.claude/skills/` and `.agents/skills/` 100% byte-identical.
- Verify with `bash .tad/hooks/lib/release-verify.sh parity .`.

---

## 4. Acceptance Criteria (AC Checklist)

- [ ] **AC1**: `derive-sync-set.sh` and `tad.sh` both declare `brain-index.md` in `TOP_DENY` / `TAD_TOP_DENY`. Direct behavioral probe confirms: `derive_framework_top_files "$TAD_ROOT"` excludes `brain-index.md`, STILL excludes `sync-registry.yaml`, and includes `version.txt`. `bash tad.sh --verify-denylist` exits 0.
- [ ] **AC2**: Simulating `tad.sh install` into a clean temporary directory (`mktemp -d`) asserts: (a) `.tad/project-knowledge/patterns/` and `.tad/project-knowledge/incidents/` exist, (b) ONLY `README.md` is present at top of `project-knowledge/`, (c) 0 `*.md` files under `patterns/` or `incidents/`.
- [ ] **AC3**: `brain-index-gen.sh` runs to completion on the TAD repository without pipefail termination, processing the 50-most-recent archived handoffs cap plus all active handoffs. Every emitted row has non-empty `task_type` and `summary` (no regression to `(see file)` fallback).
- [ ] **AC4**: `quarantine-framework-pk.sh` executed via `tad.sh --quarantine-pk`:
  (a) Leaves `.tad/project-knowledge/README.md` byte-identical in place.
  (b) Moves identical framework files to `.tad/archive/quarantine-framework-pk-YYYYMMDD-HHMMSS/` with a complete `MANIFEST.md`.
  (c) Preserves locally modified files with a logged warning.
  (d) Re-running on clean repo exits 0 with `0 files quarantined` and creates no empty archive.
  (e) `tad.sh --help` outputs `--quarantine-pk` option.
- [ ] **AC5**: `copy_framework_files` in `tad.sh` preserves `.claude/skills/local/` and any skill declaring `ownership: project-owned` (in bare, single-quoted, or double-quoted YAML form) across both `.claude/skills/` and `.agents/skills/`.
- [ ] **AC6**: Distillation loop Step 6 runs `brain-index-gen.sh` softly without blocking Gate 4. Freshness checks in `tad doctor` and `tad-maintain` are WARN-only and exit 0.
- [ ] **AC7**: Platform parity: all modified files under `.claude/skills/` are byte-identical to their `.agents/skills/` counterparts (`release-verify.sh parity` exits 0).
- [ ] **AC8**: Negative Invariants:
  (a) `tad.sh update` execution path contains zero calls to `quarantine-framework-pk.sh` (absence proof).
  (b) No Gate 3 or Gate 4 verification check blocks on `brain-index.md` freshness.
  (c) Zero `framework-principles.md` or provenance tagging machinery installed under Option A.

---

## 5. Friction Preflight (§8.4)

| Prerequisite | Status | Resolution / Verification Path |
|---|---|---|
| Bash 3.2+ compatibility | READY | All shell additions strictly avoid bash 4+ features (no associative arrays, no `|&`). |
| Portable sha256 helper | READY | `hash_file()` dispatches to `sha256sum` or `shasum -a 256`. |
| Denylist parity verification | READY | Run `bash tad.sh --verify-denylist`. |
| Dual platform mirror parity | READY | Run `bash .tad/hooks/lib/release-verify.sh parity .`. |
| Quarantine fixture isolation | READY | Dry-run quarantine against synthetic temp directory fixture; never test destructively against live workspace. |

---

## 6. Decision Log (Human Locked 2026-09-08)

1. **`principles.md` / pk baseline**: **Option A — Complete isolation** (only `README.md` installed on fresh installs; empty `patterns/` and `incidents/` subdirectories). Methodology principles live in `CLAUDE.md`. Option B (shared framework principles) rejected.
2. **Quarantine invocation**: **opt-in only** — explicit `tad.sh --quarantine-pk`. **No auto quarantine** during `tad.sh update`.

*PM Note: Blake must implement Option A and opt-in quarantine only. Do not re-open these choices.*

---

## 7. Required Evidence Manifest (Phase 3 Anchor A-02)

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-20260908-knowledge-seam-isolation"
  evidence_files:
    - path: ".tad/evidence/reviews/gate3-evidence-knowledge-seam-isolation.md"
      description: "Blake Gate 3 comprehensive verification report covering §9.1 checklist verbatim"
      required_sections:
        - "Top-File Denylist Probe Output"
        - "Fresh Install Simulation Log"
        - "Brain Index Generation Full Output"
        - "Quarantine Fixture Test & Idempotency Run"
        - "Project Skill Protection Output"
        - "Dual Platform Parity Check"
    - path: ".tad/evidence/fixtures/quarantine-test-manifest.md"
      description: "Dry-run manifest captured during synthetic quarantine fixture run"
```

---

## 8. Sub-Agent & Testing Strategy

Blake should consider using:
- [x] **test-runner**: Execute AC1–AC8 verification commands in an isolated temp environment.
- [x] **spec-compliance-reviewer**: Execute §9.1 Spec Compliance Checklist row-by-row before calling Gate 3.
- [ ] **parallel-coordinator**: Not required (tasks are sequential shell and protocol edits).
- [ ] **code-reviewer**: Review `tad.sh` and `quarantine-framework-pk.sh` shell changes.

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1.1 | `derive-sync-set.sh` declares `brain-index.md` in `TOP_DENY` | post-impl-verifiable | `grep -F "brain-index.md" .tad/hooks/lib/derive-sync-set.sh` | Match found in `TOP_DENY` block | (post-impl); baseline: 0 hits (`grep -c` = 0) |
| AC1.2 | `tad.sh` declares `brain-index.md` in `TAD_TOP_DENY` | post-impl-verifiable | `grep -F "brain-index.md" tad.sh` | Match found in `TAD_TOP_DENY` block | (post-impl); baseline: 0 hits (`grep -c` = 0) |
| AC1.3 | `tad.sh` `derive_framework_top_files` uses set membership | post-impl-verifiable | `grep -E 'printf.*TAD_TOP_DENY.*grep.*Fxq' tad.sh` | Match found (set membership check) | (post-impl); baseline: scalar `[ "$bn" = "$TAD_TOP_DENY" ]` |
| AC1.4 | Behavioral top-file probe: `brain-index.md` and `sync-registry.yaml` excluded, `version.txt` included (main-free loader) | post-impl-verifiable | `TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; } && derive_framework_top_files . | grep -Fxq "version.txt"' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC` | Exit code 0 | (post-impl); baseline: fails-cleanly (leak detected, exit 1) |
| AC1.5 | `tad.sh --verify-denylist` passes | post-impl-verifiable | `bash tad.sh --verify-denylist` | Exit code 0, no drift detected | Exit code 0 ✅ (pre-existing directory parity) |
| AC2.1 | Clean install creates Option A structure (only README.md) | post-impl-verifiable | `TMPD=$(mktemp -d) && bash tad.sh --source . --platform both --yes "$TMPD" >/dev/null 2>&1 && test -f "$TMPD/.tad/project-knowledge/README.md" && test -d "$TMPD/.tad/project-knowledge/patterns" && test -d "$TMPD/.tad/project-knowledge/incidents" && test $(ls -1 "$TMPD/.tad/project-knowledge" | grep -vx 'README.md' | wc -l) -eq 2 && rm -rf "$TMPD"` | Exit code 0 (only README at pk root, subdirs empty) | (post-impl); baseline: subdirs not created |
| AC3.1 | `brain-index-gen.sh` runs to completion under `set -e` | post-impl-verifiable | `bash .tad/hooks/lib/brain-index-gen.sh` | Exit code 0, outputs line count, no pipefail crash | (post-impl); baseline: crashes after ~11 items |
| AC3.2 | Archived handoffs index processes up to 50 cap with complete fields | post-impl-verifiable | `[ $(grep -A 55 "## Archived Handoffs" .tad/brain-index.md | grep -c "HANDOFF-") -ge 50 ] && grep -A 55 "## Archived Handoffs" .tad/brain-index.md | grep "HANDOFF-" | { grep -qE '\|\s*\||\(see file\)' && exit 1 || true; }` | Exit code 0 (count ≥ 50, all rows contain non-empty task_type and summary) | (post-impl); baseline: count is 19 (< 50) |
| AC4.1 | `tad.sh --help` documents `--quarantine-pk` | post-impl-verifiable | `bash tad.sh --help | grep -F -- "--quarantine-pk"` | Match found with description | (post-impl); baseline: 0 hits |
| AC4.2 | `quarantine-framework-pk.sh` syntax and executable check | post-impl-verifiable | `test -x .tad/hooks/lib/quarantine-framework-pk.sh && bash -n .tad/hooks/lib/quarantine-framework-pk.sh` | Exit code 0 | (post-impl); file not yet created |
| AC4.3 | Quarantine preserves `README.md` and modified files in fixture | post-impl-verifiable | `TMPD=$(mktemp -d) && mkdir -p "$TMPD/.tad/project-knowledge" "$TMPD/.tad/archive" && echo "seed readme" > "$TMPD/.tad/project-knowledge/README.md" && echo "user file" > "$TMPD/.tad/project-knowledge/custom.md" && (cd "$TMPD" && bash "$OLDPWD/tad.sh" --quarantine-pk >/dev/null 2>&1) && test -f "$TMPD/.tad/project-knowledge/README.md" && test -f "$TMPD/.tad/project-knowledge/custom.md" && rm -rf "$TMPD"` | Exit code 0, README.md and custom.md remain intact | (post-impl; Blake runs fixture test) |
| AC4.4 | Quarantine idempotency on clean tree | post-impl-verifiable | `TMPD=$(mktemp -d) && mkdir -p "$TMPD/.tad/project-knowledge" && echo "seed" > "$TMPD/.tad/project-knowledge/README.md" && OUT=$(cd "$TMPD" && bash "$OLDPWD/tad.sh" --quarantine-pk 2>&1); echo "$OUT" | grep -F "0 files quarantined" && test ! -d "$TMPD/.tad/archive" && rm -rf "$TMPD"` | Exit code 0, "0 files quarantined" matched, 0 archives created | (post-impl) |
| AC5.1 | Project-owned skill preservation across YAML quoting variants | post-impl-verifiable | `TMPD=$(mktemp -d) && bash tad.sh --source . --platform both --yes "$TMPD" >/dev/null 2>&1 && mkdir -p "$TMPD/.claude/skills/local" "$TMPD/.claude/skills/c1" "$TMPD/.claude/skills/c2" "$TMPD/.claude/skills/c3" && printf -- "---\nownership: project-owned\n---\n" > "$TMPD/.claude/skills/c1/SKILL.md" && printf -- "---\nownership: 'project-owned'\n---\n" > "$TMPD/.claude/skills/c2/SKILL.md" && printf -- "---\nownership: \"project-owned\"\n---\n" > "$TMPD/.claude/skills/c3/SKILL.md" && echo "keep" > "$TMPD/.claude/skills/local/keep.txt" && bash tad.sh --source . --platform both --yes "$TMPD" >/dev/null 2>&1 && test -f "$TMPD/.claude/skills/c1/SKILL.md" && test -f "$TMPD/.claude/skills/c2/SKILL.md" && test -f "$TMPD/.claude/skills/c3/SKILL.md" && test -f "$TMPD/.claude/skills/local/keep.txt" && rm -rf "$TMPD"` | Exit code 0, project-owned (bare, single, double quoted) and local/ skills preserved across sync | (post-impl; Blake runs fixture test) |
| AC6.1 | Distillation Step 6 contains soft `brain-index-gen.sh` trigger | post-impl-verifiable | `awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' .claude/skills/alex/references/distillation-loop-protocol.md | grep -F "brain-index-gen.sh" && awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' .agents/skills/alex/references/distillation-loop-protocol.md | grep -F "brain-index-gen.sh"` | Match found in both trees with `>/dev/null 2>&1 \|\| true` | (post-impl); baseline: 0 hits in both trees |
| AC6.2 | Maintenance and doctor freshness check is WARN-only | post-impl-verifiable | `cp -p .tad/brain-index.md .tad/brain-index.md.bak && touch -t 202001010000 .tad/brain-index.md && { bash tad.sh --doctor 2>&1 | grep -F "brain-index.md is older"; } && bash tad.sh --doctor >/dev/null 2>&1; STAT=$?; mv -f .tad/brain-index.md.bak .tad/brain-index.md; test $STAT -eq 0` | Advisory warning printed, exit code 0 (live file backed up and restored) | (post-impl) |
| AC7.1 | Dual platform mirror parity across all modified skills | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh parity .` | Exit code 0 (100% byte identical) | Exit code 0 ✅ (pre-baseline parity intact) |
| AC8.1 | Negative assertion: `tad.sh update` never calls quarantine | pre-impl-verifiable | `sed -n '/"update")/,/;;/p' tad.sh | grep -F "quarantine-framework-pk"` | Empty output (exit code 1) | Empty output ✅ (2026-09-08 verified) |
| AC8.2 | Negative assertion: Gate 3/4 scripts do not block on freshness | pre-impl-verifiable | `grep -rn "brain-index" .tad/gates/ .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh 2>/dev/null \| grep -i "block"` | Empty output | Empty output ✅ (2026-09-08 verified) |
| AC8.3 | Negative assertion: zero `framework-principles.md` or provenance machinery | pre-impl-verifiable | `ls .tad/project-knowledge/framework-principles.md 2>&1` | No such file or directory | No such file or directory ✅ |

---

## 9.2 Expert Review Status & Audit Trail

### Audit Trail — Gate 2 P0 Closure

| Reviewer & Issue ID | Issue Description | Resolution in Handoff | Status |
|---------------------|-------------------|----------------------|--------|
| **Scope Reviewer P0-1** | AC1 verification is vacuous (verifier/granularity mismatch) | AC1 replaced with direct assertions: representation checks in both files + behavioral probe `derive_framework_top_files` checking exclusion of `brain-index.md`, retention of `version.txt`, and exclusion of sibling `sync-registry.yaml` (§3 Task 1, §4 AC1, §9.1 AC1.1–1.4). | **CLOSED** |
| **Scope Reviewer P0-2** / **Spec Reviewer P0-2** | `TAD_TOP_DENY` single-string equality breaks silently on 2-value edit | Mandated multiline string in `tad.sh` and `derive-sync-set.sh`; updated consumer to set-membership `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn" && continue`; updated comment at `tad.sh:592`; complement assertions added (§3 Task 1, §9.1 AC1.3). | **CLOSED** |
| **Scope Reviewer P0-3** / **Spec Reviewer P0-3** | Quarantine script unconditionally clobbers sanctioned `README.md` seed | Task 5 and AC4 explicitly prohibit moving or modifying `.tad/project-knowledge/README.md`; quarantine is strictly scoped to `project-knowledge/`; AC4.3 asserts `README.md` remains intact byte-identical (§3 Task 5, §4 AC4, §9.1 AC4.3). | **CLOSED** |
| **Spec Reviewer P0-1** | Missing `## 9.1 Spec Compliance Checklist` (Gate 3 Hard Block) | Created comprehensive 6-column `## 9.1 Spec Compliance Checklist` table covering AC1–AC8 with literal bash commands, expected evidence, and step1d dry-run baseline verification (§9.1). | **CLOSED** |
| **Spec Reviewer P0-4** | Quarantine tool lacks `tad.sh --quarantine-pk` CLI wiring | Updated Task 4 & Task 5 to include CLI option parsing in `tad.sh`, `--help` text documentation, and dispatcher invocation; added AC4(e) and §9.1 AC4.1 (§3 Task 4/5, §4 AC4, §9.1 AC4.1). | **CLOSED** |
| **Spec Reviewer P0-5** | Missing Required Evidence Manifest (A-02 contract violation) | Added YAML block `## 7. Required Evidence Manifest` declaring `gate3-evidence-knowledge-seam-isolation.md` and fixture outputs (§7). | **CLOSED** |

### Audit Trail — Critical P1 Incorporation

| Reviewer & Issue ID | Issue Description | Resolution in Handoff | Status |
|---------------------|-------------------|----------------------|--------|
| **Scope/Spec P1-1** | Target Files / blast radius omits dual-tree mirrors and carriers | Fully enumerated 11 files in §1 Target Files (including `.agents/skills/` mirrors, `tad.sh` CLI parser, `tad-maintain`). | **INCORPORATED** |
| **Scope/Spec P1-2** | Incomplete catalog of `brain-index-gen.sh` pipefail sites | Enumerated all 7 pipefail sites with line numbers; specified `{ grep ... || true; }` pattern and fallback defaults; fixed `find` operator grouping (§3 Task 2). | **INCORPORATED** |
| **Scope P1-2 / AC2** | AC2 non-discriminative at baseline | AC2 / §9.1 AC2.1 specifies isolated `mktemp -d` simulation asserting subdirectories exist, ONLY `README.md` at top level, and zero `*.md` in subdirs. | **INCORPORATED** |
| **Scope P1-3 / AC3** | Clarify `head -50` cap on archived handoffs | Specified that generator respects the `head -50` cap + active handoffs, verifying non-empty fields without pipefail exit (§3 Task 2, §4 AC3, §9.1 AC3.2). | **INCORPORATED** |
| **Scope/Spec P1-4** | Portable hash calculation & quarantine manifest schema | Mandated portable `hash_file()` helper; specified timestamp format `quarantine-framework-pk-YYYYMMDD-HHMMSS/`; defined `MANIFEST.md` schema table (§3 Task 5). | **INCORPORATED** |
| **Scope/Spec P1-5** | Project-owned skill regex supporting all YAML quoting variants | Mandated regex `^[[:space:]]*ownership:[[:space:]]*["'']?project-owned["'']?`; covers `.claude/skills/` and `.agents/skills/`; excludes `local/` (§3 Task 4, §9.1 AC5.1). | **INCORPORATED** |
| **Scope P1-6** | Provenance tagging out of scope | Added explicit `Out of Scope` clause in §1 confirming no `framework-principles.md` or provenance machinery in v2.45.0 under Option A (§1). | **INCORPORATED** |
| **Scope/Spec P1-7** | Missing negative ACs for locks and WARN-only freshness | Added AC8 and §9.1 AC8.1–8.3: update never calls quarantine, Gate 3/4 never blocks on freshness, freshness in doctor/maintain is WARN-only. | **INCORPORATED** |
| **Scope P1-8** | Section-scoped anchors for protocol triggers | Scoped Step 6 trigger specifically between `## Step 6: Finalize` and next `## ` heading, mirrored in both `.claude/` and `.agents/` trees (§3 Task 3, §9.1 AC6.1). | **INCORPORATED** |
| **Spec P1-8** | Missing Project Knowledge & Historical Lessons | Added `## 📚 Project Knowledge` section citing `principles.md:74`, `94`, `110`, `patterns/shell-portability.md`, `ac-verification.md`, and `release-sync.md`. | **INCORPORATED** |
| **Scope P2-2 / Spec P1-6** | Upgrade/migrate overwrite of customized `README.md` | Added check in `upgrade`/`migrate` to preserve existing downstream `README.md` if already present (§3 Task 4). | **INCORPORATED** |

### Audit Trail — Gate 2 Round 2 Scope Review Findings (Resolution for Round 3)

| Reviewer & Issue ID | Issue Description | Resolution in Handoff | Status |
|---------------------|-------------------|----------------------|--------|
| **Scope R2 NEW-P0-1** | AC6.1 awk range `/## Step 6: Finalize/,/## [A-Z0-9]/` end pattern matches start line, collapsing range to 1 line | Replaced with stateful pattern `awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' <file> \| grep -F "brain-index-gen.sh"`, mirrored across both `.claude/` and `.agents/` protocol trees (§9.1 AC6.1). | **CLOSED** |
| **Scope R2 P1-1** | AC3.2 `\|` in BRE regex matches every line; missing assertion for non-empty fields | Fixed count pattern to `grep -c "HANDOFF-"` and added content assertion asserting absence of empty cells `\|\s*\|` or `(see file)` fallback (§9.1 AC3.2). | **CLOSED** |
| **Scope R2 P1-2** | AC4.3 and AC6.2 methods are prose instead of literal executable commands | Replaced prose with runnable bash commands executing in isolated temp directories / touch-stale fixtures (§9.1 AC4.3, AC4.4, AC5.1, AC6.2). | **CLOSED** |
| **Scope R2 P1-3** | Task 2 line numbers drifted from live file; L228 disposition unspecified | Re-pinned live line numbers (L94, L135, L155, L172, L174, L177, L212, L251) and explicitly wrapped L228 config grep site for pipefail defense (§3 Task 2). | **CLOSED** |
| **Scope R2 P2-1** | Task 2 self-contradiction ("7 sites" vs 8 bullets) | Reworded to "7 handoff/doc grep sites + 1 find-precedence fix + 1 config grep site" (§3 Task 2). | **CLOSED** |

### Audit Trail — Gate 2 Round 3 Findings (Resolution for Round 4)

| Reviewer & Issue ID | Issue Description | Resolution in Handoff | Status |
|---------------------|-------------------|----------------------|--------|
| **Scope R3-NEW-P0-1** | AC1.4 `source tad.sh` runs bare `main` and exits 0 before reaching probe | Replaced with main-free loader `TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" ...' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC`. Live-tested mechanism: fails-cleanly (exit 1) at baseline when `brain-index.md` leaks, passes post-impl (§9.1 AC1.4). | **CLOSED** |
| **Scope R3 P1-1** | AC5.1 fixture only installed bare YAML form, leaving quoting variants uncovered | Extended fixture in AC5.1 to create `c1` (bare), `c2` (single-quoted `'project-owned'`), and `c3` (double-quoted `"project-owned"`), asserting all three plus `local/` survive sync (§9.1 AC5.1). | **CLOSED** |
| **Scope R3 P2-1** | AC2.1 uses unanchored `grep -v 'README.md'` | Anchored to exact match `grep -vx 'README.md'` (§9.1 AC2.1). | **CLOSED** |
| **Scope R3 P2-2** | AC6.2 `touch` mutates live `.tad/brain-index.md` and relies on regen | Wrapped probe with `cp -p .tad/brain-index.md .tad/brain-index.md.bak` and restoration `mv -f .tad/brain-index.md.bak .tad/brain-index.md` (§9.1 AC6.2). | **CLOSED** |

---

## 10. Sub-Agent Usage Record (Blake完成后填写)

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|---|---|---|---|---|
| spec-compliance-reviewer | ✅ | Gate 3 pre-check (Group 0) | 19/19 PASS, P0:0 P1:0 P2:1 | .tad/evidence/reviews/2026-09-09-gate3-layer2-spec-compliance-knowledge-seam.md |
| code-reviewer | ✅ | Shell diff review (Group 1) | PASS, P0:0 P1:0 P2:5 (3 applied, 2 deferred) | .tad/evidence/reviews/2026-09-09-gate3-layer2-code-review-knowledge-seam.md |
| test-runner | ✅ | AC re-execution in /tmp fixtures (Group 2) | 19/19 PASS | .tad/evidence/reviews/2026-09-09-gate3-layer2-test-runner-knowledge-seam.md |

---

**Handoff Created By**: Alex (Agent A - Solution Lead)  
**Date**: 2026-09-08  
**Status**: `READY_FOR_BLAKE (Gate2-R4 dual PASS)`
