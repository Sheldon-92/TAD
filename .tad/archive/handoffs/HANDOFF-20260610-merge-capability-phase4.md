---
task_type: code
e2e_required: yes
research_required: no
git_tracked_dirs: [".tad/hooks/lib", ".tad/tests/migration-fixtures"]
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
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 4/6)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex)

**Execution Time**: 2026-06-10 14:30

### Gate 2 Check Results

| Check Item | Status | Notes |
|-----------|--------|-------|
| Architecture Complete | ✅ | Merge execution fits into existing execute_manifest flow at L808-812 |
| Components Specified | ✅ | Single function (execute_merge) + fixture + marker documentation |
| Functions Verified | ✅ | report_line, do_backup, check_containment all exist (MQ2 below) |
| Data Flow Mapped | ✅ | Source file -> split at marker -> replace head -> write target |

**Gate 2 Result**: ✅ PASS

**Alex Confirmation**: I have verified all design elements. Blake can independently complete the implementation based on this document.

---

## Handoff Checklist (Blake)

Blake, before beginning implementation please confirm:
- [ ] Read all sections
- [ ] **Read the "Project Knowledge" section and historical lessons**
- [ ] All Mandatory Questions (MQ) have evidence
- [ ] Understood the true intent (not just surface requirements)
- [ ] Each Phase's deliverables and evidence requirements are clear
- [ ] Confirmed ability to independently complete using this document

---

## 1. Task Overview

### 1.1 What We're Building
Replace the `manual-required` placeholder in migration-engine.sh's merge execution with actual `tad-head-marker` strategy execution. The merge reads the target file, finds the marker, replaces everything above the marker with source content (up to but not including the marker), preserves the marker and everything below, and writes back. If no marker is found, it skips the file and reports (never overwrites user content).

### 1.2 Why We're Building It
**Business Value**: Completes the migration engine's merge capability so that CLAUDE.md files (which contain both TAD framework content and user project content) can be automatically upgraded without losing user content.
**User Benefit**: Users no longer see "manual-required" in migration reports for CLAUDE.md; the upgrade Just Works.
**Success Looks Like**: Running a migration with a merge entry on a file with the marker updates the TAD header seamlessly while the user's project-specific content below the marker remains byte-identical.

### 1.3 Intent Statement

**The real problem**: The migration engine currently cannot execute merge operations. It reports them as "manual-required" and relies on the user or *sync's separate logic to handle them. This means the engine is incomplete for automated end-to-end upgrades.

**NOT what we're doing**:
- We are NOT implementing any merge strategy other than `tad-head-marker`
- We are NOT changing the manifest schema or parser (already working)
- We are NOT directly modifying the 3 legacy projects' files from this repo (we document how to fix them)
- We are NOT handling non-CLAUDE.md merge targets (other files with different merge needs remain manual-required via unknown strategy fallback)

**Blake Confirmation**:
```
Before beginning implementation, answer in your own words:
1. What problem does this solve?
2. How will the merge algorithm work step-by-step?
3. What happens when the marker is missing?

Only proceed after Human confirms your understanding.
```

---

## Project Knowledge (Blake MANDATORY READ)

**MANDATORY READ - Blake must execute the following Read operations before starting:**
1. Read ALL `.tad/project-knowledge/*.md` files listed below
2. Read the "Blake Must Note Historical Lessons" entries carefully
3. This is NOT optional

### Step 1: Relevant Categories

- [x] code-quality - Shell patterns
- [x] testing - Fixture design
- [x] architecture - Engine integration

### Step 2: Historical Experience Extracts

**Read project-knowledge files**:

| File | Relevant Records | Key Reminders |
|------|-----------------|---------------|
| patterns/shell-portability.md | 3 | BSD awk, bash 3.2 arrays, APFS case |
| patterns/ac-verification.md | 1 | Dry-run discipline |
| principles.md | 2 | "Never Hand-Write What Tool Does" + YOLO audit |

**Blake Must Note Historical Lessons**:

1. **ERR safety: use `||` pattern, not `set +e`** (from shell-portability.md)
   - Problem: `set +e` then `set -e` in bash 3.2 can leave errexit disabled if an error occurs between
   - Solution: Use `cmd || rc=$?` pattern to capture failures without disabling errexit

2. **APFS case preservation** (from shell-portability.md)
   - Problem: `pwd -P` on macOS APFS preserves input case even on case-insensitive filesystem
   - Solution: Case-normalize comparisons where needed (already handled in check_zero_touch)

3. **Fixture discrimination** (from ac-verification.md)
   - Problem: Fixtures that always pass regardless of implementation correctness
   - Solution: Each fixture must fail if the implementation is broken (test the negative case too)

### Blake Confirmation

- [ ] I have read the above historical experience
- [ ] I understand the problems to avoid
- [ ] If encountering similar situations, I will reference the above solutions

---

## 2. Background Context

### 2.1 Previous Work
- **Phase 2** (commit fe11b95 + 7e2a945): Built the migration engine with full delete/rename/verify execution. Merge entries are parsed into `MERGE_PATHS[]`, `MERGE_STRATEGIES[]`, `MERGE_MARKERS[]`, `MERGE_MISSING[]` arrays but execution only outputs `manual-required`.
- **Phase 3** (commit pending): Dual-caller integration (tad.sh + *sync both call the engine).
- **sync-protocol.md L86-88**: Already defines the exact same marker merge algorithm for *sync's CLAUDE.md handling. This phase brings the engine to parity.

### 2.2 Current State
- `migration-engine.sh` L808-812: Merge section in `execute_manifest()` currently iterates `MERGE_PATHS` and unconditionally reports `manual-required`.
- The parser (L391-396) already correctly populates all 4 merge arrays from manifest YAML.
- Existing fixture F8 tests that merge entries produce `manual-required` + file untouched. This fixture's assertion will need updating.

### 2.3 Dependencies
- Phase 3 must be complete (engine is callable from both paths)
- `do_backup()` function exists at L641-662 (will reuse for merge backup)
- `report_line()` function exists at L249-255 (will reuse for status output)
- `$SOURCE` variable holds the TAD source directory (contains the new version of files)

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: For `strategy="tad-head-marker"`, execute the merge: read target, find marker, replace above-marker content with source content (up to but not including marker), preserve marker + below, write back.
- **FR2**: If marker NOT found in target file: do NOT write anything, report `skipped-no-marker`. (SAFETY: never overwrite user content)
- **FR3**: Backup target file before any write (same pattern as delete: `$TARGET/.tad-backup/{from}-to-{to}/{path}`)
- **FR4**: Idempotent: if content above marker in target already matches source content above marker, report `already-current` and do NOT write.
- **FR5**: Dry-run mode: output `would-merge` status, do NOT write any file.
- **FR6**: Unknown strategy value: keep outputting `manual-required` (forward compatibility for future strategies).
- **FR7**: Source content comes from `$SOURCE/{path}` — read the source file, extract everything UP TO (not including) the marker line, that becomes the new head.
- **FR8**: If source file does not exist at `$SOURCE/{path}`, report error and return failure.
- **FR9**: If target file does not exist at `$TARGET/{path}`, report `skipped-no-marker` (missing file = no marker, same treatment).
- **FR10**: TSV report statuses for merge: `done` / `skipped-no-marker` / `already-current` / `would-merge` / `manual-required`
- **FR11**: Update the summary line counter: change `manual` counter logic (currently all merge = manual; now only unknown-strategy = manual; successful merge = use a new `merged` counter).

### 3.2 Non-Functional Requirements

- **NFR1**: bash 3.2 compatible (macOS default). No associative arrays, no `readarray`, no `${var,,}`.
- **NFR2**: No `set +e` — use `|| rc=$?` pattern for error capture.
- **NFR3**: Marker comparison must be EXACT string match (no regex, no trimming whitespace, no partial match).
- **NFR4**: User content below marker must be byte-identical after merge (no trailing newline addition/removal).

### 3.3 Marker Convention (for documentation)

The standard marker is:
```
<!-- TAD:PROJECT-CONTENT-BELOW -->
```

Semantics:
- Everything ABOVE this line = TAD framework content (managed by TAD, updated on upgrade)
- The marker line itself = boundary (preserved as-is)
- Everything BELOW this line = user/project content (NEVER touched by TAD)

---

## 4. Technical Design

### 4.1 Architecture Overview

The merge execution slots into the existing `execute_manifest()` function at L808-812, replacing the 3-line `manual-required` loop with a call to a new `execute_merge_entry()` function.

```
execute_manifest()
  ...existing rename/delete execution...
  # MERGE
  for each merge entry:
    if strategy != "tad-head-marker":
      report manual-required (forward compat)
      continue
    execute_merge_entry $path $marker
  ...existing verify execution...
```

### 4.2 Function: execute_merge_entry

```bash
execute_merge_entry() {
    local m_path="$1" m_marker="$2" target_base="$3" source_base="$4" dry_run="$5"
    # Returns: 0=done (content changed), 1=fatal error, 2=skipped or already-current
    local target_file="$TARGET/$m_path"
    local source_file="$SOURCE/$m_path"
    local backup_base="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"

    # 1. Source must exist
    if [ ! -f "$source_file" ]; then
        report_line "merge" "error" "$m_path" "source file not found: $source_file"
        return 1
    fi

    # 2. Target must exist (no target = no marker = skip)
    if [ ! -f "$target_file" ]; then
        report_line "merge" "skipped-no-marker" "$m_path" "target file not found"
        return 0  # not a failure, just skip
    fi

    # 3. Find marker in target
    local marker_line_num=""
    marker_line_num="$(grep -nF "$m_marker" "$target_file" | head -1 | cut -d: -f1)" || true
    if [ -z "$marker_line_num" ]; then
        # on_missing_marker is always skip_and_report (schema v1)
        report_line "merge" "skipped-no-marker" "$m_path" "marker not found in target"
        return 0
    fi

    # 4. Extract source head (everything above marker in source)
    local source_marker_line=""
    source_marker_line="$(grep -nF "$m_marker" "$source_file" | head -1 | cut -d: -f1)" || true
    if [ -z "$source_marker_line" ]; then
        report_line "merge" "error" "$m_path" "marker not found in source file"
        return 1
    fi
    # Source head = lines 1 to (source_marker_line - 1)
    local source_head=""
    if [ "$source_marker_line" -gt 1 ]; then
        source_head="$(head -n $((source_marker_line - 1)) "$source_file")"
    fi

    # 5. Extract target tail (marker line + everything below)
    local target_tail=""
    target_tail="$(tail -n +${marker_line_num} "$target_file")"

    # 6. Idempotency check: compare current head with source head
    local current_head=""
    if [ "$marker_line_num" -gt 1 ]; then
        current_head="$(head -n $((marker_line_num - 1)) "$target_file")"
    fi
    if [ "$current_head" = "$source_head" ]; then
        report_line "merge" "already-current" "$m_path" "head content matches source"
        return 0
    fi

    # 7. Dry-run: report but don't write
    if [ "$DRY_RUN" -eq 1 ]; then
        report_line "merge" "would-merge" "$m_path" "would replace head (${source_marker_line} lines from source)"
        return 0
    fi

    # 8. Backup before write
    do_backup "$m_path" "$backup_base" || return 1

    # 9. Assemble and write
    {
        if [ -n "$source_head" ]; then
            printf '%s\n' "$source_head"
        fi
        printf '%s\n' "$target_tail"
    } > "$target_file"

    report_line "merge" "done" "$m_path" "head replaced from source"
    return 0
}
```

### 4.3 Integration Point (L808-812 replacement)

Replace:
```bash
    # MERGE (not executed, only reported)
    for ((i=0; i<${#MERGE_PATHS[@]}; i++)); do
        report_line "merge" "manual-required" "${MERGE_PATHS[$i]}" "strategy=${MERGE_STRATEGIES[$i]}"
        manual=$((manual + 1))
    done
```

With:
```bash
    # MERGE
    local merged=0
    for ((i=0; i<${#MERGE_PATHS[@]}; i++)); do
        local m_path="${MERGE_PATHS[$i]}" m_strategy="${MERGE_STRATEGIES[$i]}"
        local m_marker="${MERGE_MARKERS[$i]}" m_missing="${MERGE_MISSING[$i]}"

        if [ "$m_strategy" != "tad-head-marker" ]; then
            report_line "merge" "manual-required" "$m_path" "unknown strategy=$m_strategy"
            manual=$((manual + 1))
            continue
        fi

        # Return convention: 0=done, 2=skipped/already-current, 1=fatal
        local merge_rc=0
        execute_merge_entry "$m_path" "$m_marker" "$TARGET" "$SOURCE" "$DRY_RUN" || merge_rc=$?
        if [ "$merge_rc" -eq 1 ]; then return 1; fi  # fatal → fail-fast
        if [ "$merge_rc" -eq 0 ]; then merged=$((merged + 1)); fi
        # merge_rc=2 → skipped/already-current, don't count as merged
    done
```

### 4.4 Summary Line Update

Current (L841):
```bash
report_line "summary" "ok" "-" "deleted=$deleted skipped=$skipped manual=$manual"
```

Updated:
```bash
report_line "summary" "ok" "-" "deleted=$deleted skipped=$skipped merged=$merged manual=$manual"
```

### 4.5 Edge Case: Trailing Newline Preservation

The `printf '%s\n'` pattern adds a trailing newline. For byte-identity of user content, the write logic must handle the case where the original file has no trailing newline. Use this pattern:

```bash
    # Write: source_head + newline + target_tail (which starts with marker)
    # target_tail already includes the marker line
    {
        if [ -n "$source_head" ]; then
            printf '%s\n' "$source_head"
        fi
        # Use cat-style copy for target_tail to preserve exact bytes
        printf '%s' "$target_tail"
    } > "$target_file"
    # If original had trailing newline, target_tail captured it; if not, we preserve that too
```

**IMPORTANT**: The `tail -n +N` command preserves the exact bytes including any trailing newline (or lack thereof) from the original file. However, storing in a variable via `$(...)` strips trailing newlines. To preserve byte-identity:

**Revised approach**: Use `sed` or temp-file assembly to avoid variable-stripping:
```bash
    # 9. Assemble via temp file to preserve exact bytes
    local tmp_file="${target_file}.merge-tmp"
    {
        if [ "$source_marker_line" -gt 1 ]; then
            head -n $((source_marker_line - 1)) "$source_file"
        fi
        tail -n +"${marker_line_num}" "$target_file"
    } > "$tmp_file"
    mv -- "$tmp_file" "$target_file"
```

This avoids command-substitution newline stripping entirely by piping directly to file. **Use this approach** (direct pipe, no variable capture for content that goes to disk).

### 4.6 Fixture: F8 Update + New Fixtures

**F8 (existing)**: Currently asserts merge entry -> `manual-required` + file untouched. This needs updating since `tad-head-marker` is now executed. Change F8 to test unknown strategy -> `manual-required`.

**F16: Merge with marker present** (new):
- Source CLAUDE.md has marker at line 5
- Target CLAUDE.md has marker at line 3, with user content below
- After merge: lines 1-4 from source + marker + user content from target
- Assert: user content below marker is byte-identical to original

**F17: Merge with marker absent** (new):
- Target CLAUDE.md has NO marker
- After merge: file is untouched
- Assert: `skipped-no-marker` in TSV, file content unchanged

**F18: Merge idempotent** (new):
- Run merge once (succeeds)
- Run merge again
- Assert: second run reports `already-current`, file unchanged

**F19: Merge dry-run** (new):
- Run with `--dry-run`
- Assert: `would-merge` in output, target file unmodified

---

## 5. Mandatory Questions (Evidence Required)

### MQ1: Historical Code Search

**Question**: Did the user mention "previous" or "existing" solutions?

**Answer**:
- [x] Yes

**Evidence**:
- sync-protocol.md L86-88 already implements the exact merge algorithm for *sync
- migration-engine.sh L808-812 is the current placeholder

**Decision**:
- **Found**: sync-protocol.md merge logic (L82-90)
- **Location**: `.claude/skills/alex/references/sync-protocol.md:86`
- **Decision**: ✅ Replicate the same algorithm inside the engine
- **Reason**: Semantic parity with *sync ensures consistent behavior

### MQ2: Function Existence Verification

| Function | File | Line | Snippet | Verified |
|----------|------|------|---------|----------|
| report_line | migration-engine.sh | 249 | `report_line() { local action="$1"...` | ✅ |
| do_backup | migration-engine.sh | 641 | `do_backup() { local path="$1" backup_base="$2"` | ✅ |
| check_containment | migration-engine.sh | 85 | `check_containment() { local base="$1" p="$2"` | ✅ |
| validate_full | migration-engine.sh | 205 | `validate_full() { local base="$1" p="$2"` | ✅ |
| head (BSD) | /usr/bin/head | system | `head -n N` | ✅ |
| tail (BSD) | /usr/bin/tail | system | `tail -n +N` | ✅ |
| grep -nF | /usr/bin/grep | system | fixed-string match with line numbers | ✅ |

### MQ3: Data Flow

| Data | Source | Transform | Destination | Used |
|------|--------|-----------|-------------|------|
| Source head content | `$SOURCE/{path}` lines 1..marker-1 | direct copy | Target file top | ✅ |
| Target tail content | `$TARGET/{path}` lines marker..EOF | preserved as-is | Target file bottom | ✅ |
| Marker line | Both files | exact string match | Boundary (kept in tail) | ✅ |
| Backup | `$TARGET/{path}` original | cp -a | `.tad-backup/{from}-to-{to}/{path}` | ✅ |

```
Source file ($SOURCE/CLAUDE.md)     Target file ($TARGET/CLAUDE.md)
+---------------------------+       +---------------------------+
| TAD head (new version)    |       | TAD head (old version)    |  <- REPLACED
| ...                       |       | ...                       |
+---------------------------+       +---------------------------+
| <!-- TAD:PROJECT-...  --> |       | <!-- TAD:PROJECT-...  --> |  <- PRESERVED
| (source tail - ignored)   |       | User project content      |  <- PRESERVED
+---------------------------+       +---------------------------+
```

After merge:
```
Target file ($TARGET/CLAUDE.md)
+---------------------------+
| TAD head (new version)    |  <- FROM SOURCE (lines 1 to marker-1)
| ...                       |
+---------------------------+
| <!-- TAD:PROJECT-...  --> |  <- PRESERVED from target
| User project content      |  <- PRESERVED from target (byte-identical)
+---------------------------+
```

### MQ4: Visual/State Types

- [x] N/A - no UI, no visual states

### MQ5: State Synchronization

| Data | Storage 1 | Storage 2 | Sync Trigger | Direction |
|------|-----------|-----------|--------------|-----------|
| Merge result | TSV report | stdout | report_line() | simultaneous |
| Backup | original file | .tad-backup/ | do_backup() | one-time copy |

```
[engine execution] → target file (sole source of truth)
                   → .tad-backup/ (one-time safety copy before write)
                   → TSV report (append-only log)
✅ Single write target, no sync needed
```

---

## 6. Implementation Steps

### Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | .tad/hooks/lib/migration-engine.sh | Add `execute_merge_entry()` function before `execute_manifest()` | `grep -c 'execute_merge_entry' .tad/hooks/lib/migration-engine.sh` returns 2+ | 5 min |
| 2 | .tad/hooks/lib/migration-engine.sh | Replace L808-812 merge loop with strategy dispatch + execute_merge_entry call | `grep 'manual-required' .tad/hooks/lib/migration-engine.sh` only matches unknown-strategy branch | 3 min |
| 3 | .tad/hooks/lib/migration-engine.sh | Update summary line to include `merged=` counter | `grep 'merged=' .tad/hooks/lib/migration-engine.sh` | 2 min |
| 4 | .tad/tests/migration-fixtures/run-fixtures.sh | Update F8 to test unknown strategy (not tad-head-marker) | `bash run-fixtures.sh` F8 passes | 5 min |
| 5 | .tad/tests/migration-fixtures/run-fixtures.sh | Add F16: merge with marker present | `bash run-fixtures.sh` F16 passes | 10 min |
| 6 | .tad/tests/migration-fixtures/run-fixtures.sh | Add F17: merge with marker absent -> skip | `bash run-fixtures.sh` F17 passes | 5 min |
| 7 | .tad/tests/migration-fixtures/run-fixtures.sh | Add F18: merge idempotent | `bash run-fixtures.sh` F18 passes | 5 min |
| 8 | .tad/tests/migration-fixtures/run-fixtures.sh | Add F19: merge dry-run | `bash run-fixtures.sh` F19 passes | 5 min |
| 9 | .tad/evidence/designs/migration-manifest-schema-v1.md | Add Marker Convention section (after L193) | `grep 'Marker Convention' .tad/evidence/designs/migration-manifest-schema-v1.md` | 3 min |

---

### Phase 1: Engine Merge Execution (est. 30 min)

#### Deliverables
- [ ] `execute_merge_entry()` function added to migration-engine.sh
- [ ] L808-812 merge loop replaced with strategy dispatch
- [ ] Summary line includes `merged=` counter
- [ ] `bash -n migration-engine.sh` passes (syntax check)

#### Implementation Steps

1. Add `execute_merge_entry()` function BEFORE the `execute_manifest()` function (around L713). Use the design from Section 4.2/4.5 — direct pipe approach (no variable capture for file content).

2. Replace the merge loop in `execute_manifest()` (L808-812) with:
   - Strategy check: only `tad-head-marker` is executed; anything else -> `manual-required`
   - Call `execute_merge_entry` for tad-head-marker
   - Track `merged` counter

3. Update summary report_line to include `merged=$merged`.

4. Increment `ENGINE_VERSION` to `"2.29.0"` (merge capability addition).

#### Implementation Hints

- **grep -nF**: The `-F` flag does fixed-string match (no regex interpretation of the marker's `<!--` or `-->`). The `-n` gives line numbers.
- **head -n $((N-1))**: Gets lines 1 through N-1 (everything before the marker)
- **tail -n +N**: Gets lines N through EOF (marker + everything below)
- **Direct pipe to file**: Avoids bash `$(...)` newline stripping. This is the CRITICAL byte-identity guarantee.
- **Error handling**: Use `|| return 1` on do_backup. If backup fails, abort merge (same as delete pattern).
- **mv temp to target**: Use `mv --` to handle filenames starting with dash (defense in depth, even though paths are validated).
- **$merged counter**: Only increment for `done` status (not `already-current` or `skipped-no-marker`). But include all three in the loop iteration. Actually, increment for `done` only to parallel `deleted` counter semantics. `skipped-no-marker` and `already-current` are informational.

#### Verification

```bash
bash -n .tad/hooks/lib/migration-engine.sh  # syntax OK
grep -c 'execute_merge_entry' .tad/hooks/lib/migration-engine.sh  # >= 2 (def + call)
grep 'merged=' .tad/hooks/lib/migration-engine.sh  # present in summary
```

#### Phase 1 Completion Evidence (Blake must provide)
- [ ] `bash -n` output (exit 0)
- [ ] grep showing execute_merge_entry definition and call site
- [ ] The complete execute_merge_entry function as implemented

**Human Decision**: ✅ Continue Phase 2 / Adjust

---

### Phase 2: Fixtures (est. 30 min)

#### Deliverables
- [ ] F8 updated to test unknown strategy -> manual-required
- [ ] F16: merge with marker present -> head replaced, user content preserved
- [ ] F17: merge with marker absent -> skipped-no-marker, file untouched
- [ ] F18: merge idempotent -> second run reports already-current
- [ ] F19: merge dry-run -> would-merge, no write
- [ ] All fixtures pass: `bash run-fixtures.sh` reports 18/18 (or appropriate total)

#### Implementation Steps

1. **Update F8**: Change the manifest entry to use `strategy: "unknown-future-strategy"` instead of `"tad-head-marker"`. Assertion stays the same: `manual-required` in output + file untouched.

2. **F16 - Merge with marker present**:
   ```
   Source CLAUDE.md:
     "# TAD Framework v2.28\n\nNew content here.\n\n<!-- TAD:PROJECT-CONTENT-BELOW -->\n\nSource user area (ignored)\n"
   
   Target CLAUDE.md (v2.27):
     "# TAD Framework v2.27\n\nOld content.\n\n<!-- TAD:PROJECT-CONTENT-BELOW -->\n\n## My Project\n\nUser notes here.\n"
   
   Manifest:
     merge:
       - path: "CLAUDE.md"
         strategy: "tad-head-marker"
         marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"
         on_missing_marker: "skip_and_report"
   
   Assertions:
     - Exit 0
     - TSV contains: merge done CLAUDE.md
     - Target CLAUDE.md line 1 = "# TAD Framework v2.28" (new head)
     - Target CLAUDE.md contains "## My Project" (user content preserved)
     - Target CLAUDE.md contains "User notes here." (user content preserved)
     - grep -c "Old content" target/CLAUDE.md = 0 (old head gone)
   ```

3. **F17 - Merge with marker absent**:
   ```
   Target CLAUDE.md (no marker):
     "# My Project\n\nAll user content, no marker.\n"
   
   Source CLAUDE.md (has marker):
     "# TAD v2.28\n\n<!-- TAD:PROJECT-CONTENT-BELOW -->\n"
   
   Assertions:
     - Exit 0 (skip is not a failure)
     - TSV contains: merge skipped-no-marker CLAUDE.md
     - Target CLAUDE.md unchanged (cmp -s before/after)
   ```

4. **F18 - Merge idempotent**:
   ```
   Run engine once -> merge done
   Run engine again (same source, same target) -> merge already-current
   Assert:
     - Second run output contains "already-current"
     - Target file unchanged between runs (cmp -s)
   ```

5. **F19 - Merge dry-run**:
   ```
   Run engine with --dry-run
   Assert:
     - Output contains "would-merge"
     - Target file unchanged (cmp -s with pre-run copy)
   ```

#### Implementation Hints for Fixtures

- Use `add_version` to create source versions with CLAUDE.md content containing the marker
- The source git repo needs the CLAUDE.md at the target version (for `git show v${from}` detection if needed, though merge doesn't use modification detection)
- For byte-identity assertion: `cmp -s` is the right tool (not diff, which ignores trailing newline)
- Update TOTAL count in run-fixtures.sh header (currently `TOTAL=14`, will become `TOTAL=18` or as needed)
- Each fixture needs both the SOURCE and TARGET to have the file; source has the NEW version

#### Verification

```bash
bash .tad/tests/migration-fixtures/run-fixtures.sh
# Expected: all pass (18/18 or similar)
```

#### Phase 2 Completion Evidence (Blake must provide)
- [ ] Full fixture run output showing all PASS
- [ ] F16 output showing merge done + user content preserved
- [ ] F17 output showing skipped-no-marker

**Human Decision**: ✅ Continue Phase 3 / Adjust

---

### Phase 3: Marker Documentation + Legacy Project Guidance (est. 15 min)

#### Deliverables
- [ ] Marker convention section added to migration-manifest-schema-v1.md
- [ ] 3 legacy projects documented: what marker to add and where

#### Implementation Steps

1. **Add to schema doc** (after L193 in migration-manifest-schema-v1.md):

```markdown
### Marker Convention

The standard TAD content boundary marker is:

```
<!-- TAD:PROJECT-CONTENT-BELOW -->
```

**Semantics**:
- Everything ABOVE the marker = TAD framework-managed content. Updated automatically during upgrades.
- The marker line = immutable boundary. Never modified by any operation.
- Everything BELOW the marker = user/project content. Never touched by TAD (byte-identity guarantee).

**Requirements for CLAUDE.md files using merge strategy**:
- The marker MUST appear exactly once in the file
- The marker MUST be on its own line (no leading/trailing content on same line)
- The marker MUST appear in both the source template AND the target file for merge to execute

**Adding the marker to existing projects**:
If a project's CLAUDE.md was created before the marker convention, add the marker between
the TAD-managed header and the project-specific content:
1. Identify where TAD framework content ends and project content begins
2. Insert `<!-- TAD:PROJECT-CONTENT-BELOW -->` on its own line at that boundary
3. Run *sync to verify merge works (will report `done` instead of skip)
```

2. **Legacy project fix documentation** (add below the convention section):

```markdown
### Legacy Projects Requiring Marker Addition

The following 3 registered projects have CLAUDE.md files without the marker.
*sync currently skips them with a warning. After adding the marker, *sync's
merge (and the migration engine) will work correctly.

| Project | Action Required |
|---------|----------------|
| my-openclaw-agents | Add `<!-- TAD:PROJECT-CONTENT-BELOW -->` between TAD header and project content |
| toy | Add `<!-- TAD:PROJECT-CONTENT-BELOW -->` between TAD header and project content |
| 内存管理 | Add `<!-- TAD:PROJECT-CONTENT-BELOW -->` between TAD header and project content |

**Fix procedure** (run via *sync or manual edit):
1. Open the project's CLAUDE.md
2. Find the end of the TAD framework section (typically after `@.tad/project-knowledge/...` imports)
3. Insert a blank line + the marker + a blank line
4. Run *sync against the project to verify: should report `merge done` (not `skipped`)

**NOTE**: This is a *sync operation performed on each target project, NOT an engine operation.
The engine processes manifests; adding markers is project setup.
```

#### Verification

```bash
grep -c 'Marker Convention' .tad/evidence/designs/migration-manifest-schema-v1.md  # = 1
grep -c 'my-openclaw-agents' .tad/evidence/designs/migration-manifest-schema-v1.md  # = 1
```

#### Phase 3 Completion Evidence (Blake must provide)
- [ ] Marker Convention section content
- [ ] Legacy project table

**Human Decision**: ✅ Complete / Adjust

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/hooks/lib/migration-engine.sh          # Add execute_merge_entry(), replace merge loop, update summary
.tad/tests/migration-fixtures/run-fixtures.sh  # Update F8, add F16-F19, update TOTAL
.tad/evidence/designs/migration-manifest-schema-v1.md  # Add Marker Convention + legacy project docs
```

### 7.2 Files to Create
```
(none — all changes are modifications to existing files)
```

### 7.3 Grounded Against (Alex step1c)

- `.tad/hooks/lib/migration-engine.sh` (head 50+, read at 2026-06-10 14:30, L1-80, L200-260, L380-445, L641-662, L716-898)
- `.tad/tests/migration-fixtures/run-fixtures.sh` (head 60, read at 2026-06-10 14:30)
- `.tad/evidence/designs/migration-manifest-schema-v1.md` (L159-193, read at 2026-06-10 14:30)

---

## 8. Testing Requirements

### 8.1 Unit-Level (Fixture Tests)

| Fixture | Tests | Expected |
|---------|-------|----------|
| F8 (updated) | Unknown strategy -> manual-required | TSV shows `manual-required`, file untouched |
| F16 | Marker present -> merge executes | Head replaced, user content byte-identical |
| F17 | Marker absent -> skip | TSV shows `skipped-no-marker`, file unchanged |
| F18 | Idempotent rerun | Second run: `already-current`, no file change |
| F19 | Dry-run | `would-merge` in output, file unchanged |

### 8.2 Integration Tests

- Full chain test: manifest with delete + rename + merge + verify entries all execute in order (rename -> delete -> merge -> verify per FR6)
- If existing fixtures already cover chain behavior, ensure a merge entry doesn't break them

### 8.3 Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Source file missing | `return 1` (error) — engine fails, not silent |
| Target file missing | `skipped-no-marker` (no file = no marker) |
| Marker at line 1 of target | Empty head = source head replaces nothing above; works correctly |
| Marker at last line of target | No user content below; still works (tail captures just the marker) |
| Source marker at line 1 | Empty source head -> target head becomes empty (only marker + user content remain) |
| Multiple markers in file | First occurrence wins (grep head -1 pattern) |
| File with no trailing newline | Direct pipe preserves exact bytes (no variable capture) |
| Backup dir already has file | do_backup refuses (existing behavior, `ABORT: backup already exists`) |

### 8.4 Test Evidence Required
- [ ] All fixture run output (all pass)
- [ ] `bash -n` syntax check passes
- [ ] A manual test showing byte-identity: `cmp -s` before-user-content vs after-user-content

---

## 9. Acceptance Criteria

Blake's implementation is considered complete when:
- [ ] Engine executes `tad-head-marker` merge strategy (replaces manual-required)
- [ ] Marker absent -> skip and report (never overwrite)
- [ ] Backup before write (reuses do_backup)
- [ ] Idempotent: already-matching -> no-op
- [ ] Dry-run: reports would-merge, no write
- [ ] Unknown strategy -> manual-required (forward compat)
- [ ] All existing fixtures still pass (no regression)
- [ ] 4+ new merge fixtures pass
- [ ] Marker convention documented in schema doc
- [ ] 3 legacy projects fix procedure documented

---

## 9.1 Spec Compliance Checklist (PRIMARY VERIFICATION SOURCE)

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | Engine syntax valid | post-impl-verifiable | `bash -n .tad/hooks/lib/migration-engine.sh` | exit 0 | (post-impl) |
| AC2 | execute_merge_entry function exists | post-impl-verifiable | `grep -c 'execute_merge_entry()' .tad/hooks/lib/migration-engine.sh` | >= 1 | (post-impl) |
| AC3 | tad-head-marker strategy dispatch | post-impl-verifiable | `grep -A2 'tad-head-marker' .tad/hooks/lib/migration-engine.sh \| grep execute_merge_entry` | matches | (post-impl) |
| AC4 | Unknown strategy -> manual-required | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| grep 'F8.*PASS\|F8.*FAIL'` | F8 PASS | (post-impl) |
| AC5 | Merge with marker present | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| grep 'F16.*PASS\|F16.*FAIL'` | F16 PASS | (post-impl) |
| AC6 | Merge with marker absent -> skip | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| grep 'F17.*PASS\|F17.*FAIL'` | F17 PASS | (post-impl) |
| AC7 | Merge idempotent | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| grep 'F18.*PASS\|F18.*FAIL'` | F18 PASS | (post-impl) |
| AC8 | Merge dry-run | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| grep 'F19.*PASS\|F19.*FAIL'` | F19 PASS | (post-impl) |
| AC9 | All fixtures pass (no regression) | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh 2>&1 \| tail -1` | "X/X passed" with 0 fail | (post-impl) |
| AC10 | Summary line includes merged counter | post-impl-verifiable | `grep 'merged=' .tad/hooks/lib/migration-engine.sh` | >= 1 match | (post-impl) |
| AC11 | Marker convention documented | post-impl-verifiable | `grep -c 'Marker Convention' .tad/evidence/designs/migration-manifest-schema-v1.md` | 1 | (post-impl) |
| AC12 | Legacy projects documented | post-impl-verifiable | `grep -c 'my-openclaw-agents' .tad/evidence/designs/migration-manifest-schema-v1.md` | >= 1 | (post-impl) |
| AC13 | No set +e usage in new code | post-impl-verifiable | `grep -n 'set +e' .tad/hooks/lib/migration-engine.sh` | no output | (post-impl) |
| AC14 | Source file missing -> error | post-impl-verifiable | `grep 'source file not found' .tad/hooks/lib/migration-engine.sh` | >= 1 match | (post-impl) |
| AC15 | ENGINE_VERSION bumped | post-impl-verifiable | `grep 'ENGINE_VERSION=' .tad/hooks/lib/migration-engine.sh \| grep -v '2.28'` | shows 2.29.0 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| shell-portability-reviewer | P1: Variable capture strips trailing newlines — byte-identity risk | Section 4.5 revised approach (direct pipe, no variable capture for disk content) | Resolved |
| shell-portability-reviewer | P1: `mv --` may not be supported on all BSD mv | Section 4.5: use `mv -- "$tmp_file" "$target_file"` — BSD mv supports `--` | Resolved |
| safety-reviewer | P0: If source has no marker, merge would write empty head or fail silently | Section 4.2 step 4: explicit check, return 1 with error report if source has no marker | Resolved |
| safety-reviewer | P1: Idempotency check via variable comparison still strips trailing newline | Section 4.5: For idempotency check ONLY (not write), variable comparison is acceptable because both sides are extracted the same way — stripping is symmetric | Resolved |

### Experts Selected

1. **shell-portability-reviewer** — Critical for bash 3.2 + BSD tool compatibility (Phase 2 had APFS pwd -P bug; this phase adds file I/O)
2. **safety-reviewer** — Merge touches user content; any byte-identity violation is P0

### Overall Assessment (post-integration)

- shell-portability-reviewer: CONDITIONAL PASS (1 P1 resolved: direct pipe approach)
- safety-reviewer: CONDITIONAL PASS (1 P0 resolved: source-marker-missing check, 1 P1 resolved: symmetric comparison)

---

## 10. Important Notes

### 10.1 Critical Warnings

- **NEVER overwrite user content**: If anything goes wrong (marker not found, source missing, write error), the target file must remain untouched. The `do_backup` + temp-file-mv pattern ensures atomicity: if mv fails, original is still intact.
- **bash 3.2**: No `readarray`, no `${var,,}`, no associative arrays. Use `head`/`tail`/`grep -nF` which are POSIX.
- **Direct pipe for byte-identity**: Do NOT store file content in bash variables when writing to disk. Use `head`/`tail` piped directly to the temp file.

### 10.2 Known Constraints

- Only `tad-head-marker` strategy is implemented. Any other strategy value -> `manual-required`.
- The marker must be an EXACT match (grep -F). No regex, no partial match.
- First occurrence of marker wins (if multiple exist in file).
- The 3 legacy project fixes are NOT automated by this phase. They require running *sync after manually adding the marker. This is documented, not executed.

### 10.3 Sub-Agent Usage Suggestions

- [ ] **test-runner** - After each phase to verify fixture suite
- [ ] **bug-hunter** - If byte-identity assertion fails in fixtures

---

## 11. Learning Content

### 11.1 Decision Rationale: Direct Pipe vs Variable Capture

**Chosen Approach**: Direct pipe (head/tail piped to temp file, then mv to target)

| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| Direct pipe (chosen) | Byte-identity guaranteed, no newline stripping | Needs temp file + mv | ✅ Selected |
| Variable capture + printf | Simpler code | `$(...)` strips trailing newlines, breaks byte-identity | NFR4 violation |
| sed in-place | No temp file | Complex quoting for marker string with HTML comments | Fragile |
| awk | Powerful | awk dialect differences BSD vs GNU | Portability risk |

**Tradeoff**: Simplicity vs correctness. Byte-identity is a SAFETY boundary (Epic AC says "byte-identical"), so correctness wins over code simplicity.

---

## 12. Sub-Agent Usage Record

Blake fills after completion:

| Sub-Agent | Called | When | Output Summary | Evidence Link |
|-----------|--------|------|----------------|---------------|
| test-runner | | | | |
| bug-hunter | | | | |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
