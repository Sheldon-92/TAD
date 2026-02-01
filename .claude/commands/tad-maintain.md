# TAD Maintain Command

When this command is used, perform document health check and synchronization.

## Mode

- Default (no argument or `full`): FULL mode - comprehensive check + sync
- When called with `check` context from agent activation: CHECK mode - read-only
- When called with `sync` context from *accept: SYNC mode - scoped write operations

**CHECK mode**: MUST NOT modify any files. Read-only scan and report only.
**SYNC mode**: Scoped to the specific handoff being accepted + NEXT.md cleanup.
**FULL mode**: CHECK + broad SYNC across all documents.

## Step 1: Gather Current State

Read these to establish baseline:
1. `.tad/version.txt` → current version string
2. `.tad/config.yaml` (first 10 lines) → config version
3. `ls .tad/active/handoffs/` → list active handoff files
4. `ls .tad/archive/handoffs/` → list archived files
5. `ls .tad/active/epics/` → list active epic files
6. `ls .tad/archive/epics/` → list archived epic files
7. `NEXT.md` → count lines, read content
8. `PROJECT_CONTEXT.md` → check if exists

## Step 2: Handoff Lifecycle Audit

For each file in `.tad/active/handoffs/`:

### Step 2a: Extract Canonical Slug

Different naming formats exist. Extract a slug for matching:

| Format | Example | Extracted Slug |
|--------|---------|----------------|
| `HANDOFF-{date}-{slug}.md` | `HANDOFF-20260126-multi-platform-init.md` | `multi-platform-init` |
| `{date}_{time}_{version}_{taskid}_{slug}_{type}.md` | `20260126_0043_v1.0_TASK-20260126-001_blake-ralph-fusion_design.md` | `blake-ralph-fusion` |
| `COMPLETION-{date}-{slug}.md` | `COMPLETION-20260126-blake-ralph-fusion.md` | `blake-ralph-fusion` |

**Extraction rules:**
1. Strip file extension `.md`
2. If starts with `HANDOFF-` or `COMPLETION-`: remove prefix and date, remaining = slug
3. If long format: extract the segment between task-id and type (e.g., between `TASK-YYYYMMDD-NNN_` and `_design`)
4. Normalize: lowercase, keep hyphens

### Step 2b: Match Against Archive

For each active handoff's slug, search `.tad/archive/handoffs/` for:

**Criterion A (COMPLETED)**: A file matching `COMPLETION-*{slug}*` exists in archive.
→ Action: Mark as COMPLETED.

**Criterion B (SUPERSEDED)**: A file with the same slug but higher version number exists in archive.
→ Action: Mark as STALE.

**Criterion C (AGE_STALE)**: Handoff has been active longer than `handoff_lifecycle.stale_age_days` (default 7).
→ Calculate age: extract date from filename (YYYYMMDD), compare with today.
→ If age > threshold AND Criterion A/B did not match: Mark as POTENTIALLY_STALE.

**Criterion D (TOPIC_SUPERSEDED)**: An archived handoff's topic overlaps with this active handoff.
→ For each active handoff not matched by A/B/C:
  1. Read the active handoff's first 15 lines to extract title and Executive Summary keywords.
  2. Scan archived handoffs (created within `handoff_lifecycle.cross_reference_window_days`, default 30 days).
  3. Read each archive candidate's first 15 lines, compare title/summary keywords.
  4. If significant keyword overlap found (≥2 shared topic words excluding common words like "TAD", "implementation", "design"):
     Mark as POTENTIALLY_SUPERSEDED and record the matching archive file.

**No match found by any criterion**: Keep as ACTIVE (in progress).

### Step 2c: Actions (SYNC/FULL mode only)

**Write safety - two-phase approach:**
1. First: Verify destination in `.tad/archive/handoffs/` does not already have a file with the same name
2. If name conflict: append `-dup-{timestamp}` suffix to avoid overwrite
3. Move file: copy to archive first, then delete from active
4. If copy fails: abort, report error, do NOT delete source

Actions by status:
- COMPLETED → move to `.tad/archive/handoffs/`
- STALE → verify archive has newer version (re-read archive directory to confirm), then delete from active. If verification fails, keep in active and report error.
- POTENTIALLY_STALE or POTENTIALLY_SUPERSEDED (FULL mode only) → **interactive confirmation required**:
  1. Use `AskUserQuestion` to present findings to the user:
     - Show handoff filename, age in days, and slug
     - For POTENTIALLY_SUPERSEDED: show the matching archived handoff filename
     - Options: "Archive" (move to archive), "Keep" (leave as active), "Delete" (remove, work was absorbed elsewhere)
  2. If user says Archive → move to `.tad/archive/handoffs/` (two-phase safety)
  3. If user says Keep → leave in place, no action
  4. If user says Delete → delete from active (no archive copy needed)
  5. In CHECK/SYNC mode: only report as finding, do NOT prompt or take action
- ACTIVE → no action (leave in place)

### Step 2d: Idempotency Check

Before any move/delete, verify the source file still exists in `active/`. If already moved (e.g., by a concurrent run), skip silently.

## Step 2e: Epic Lifecycle Audit

For each file in `.tad/active/epics/`:

### Step 2e-i: Parse Epic

1. Read the Epic file
2. Extract Phase Map table
3. For each phase, determine status (⬚ Planned / 🔄 Active / ✅ Done)
4. Check if phase has a linked handoff filename

### Step 2e-ii: Run 6 Check Types

**Check 1 - STALE**: All phases are ✅ Done but Epic is still in `active/epics/`.
→ Detection: Parse Phase Map, count statuses. If all ✅ → STALE.
→ Action (SYNC/FULL): Move to `.tad/archive/epics/` (two-phase safety).

**Check 2 - ORPHAN**: No linked handoffs AND Epic age > `stale_age_days`.
→ Detection: Phase Map has no handoff filenames filled in, AND file date > threshold.
→ Action (FULL only): AskUserQuestion - "Epic {name} has no linked handoffs and is {N} days old. Archive, keep, or delete?"

**Check 3 - DANGLING_REF**: Phase Map references a handoff file that doesn't exist.
→ Detection: For each handoff filename in Phase Map, check if file exists in `active/handoffs/` or `archive/handoffs/`.
→ Action (all modes): Report WARNING. Do not auto-fix.

**Check 4 - BACK_REF_MISMATCH**: A handoff has an `**Epic**` field referencing this Epic, but the Epic's Phase Map doesn't list that handoff.
→ Detection: Scan active handoffs AND recently archived handoffs (within `cross_reference_window_days`) for Epic field, cross-reference with Phase Map.
→ Action (all modes): Report WARNING. Do not auto-fix.

**Check 5 - STUCK**: A phase is 🔄 Active but its linked handoff was created > `stale_age_days` ago, OR an Active phase has no linked handoff at all.
→ Detection: Find Active phases, check handoff creation date from filename. If Active phase has no linked handoff (dash or empty), treat as STUCK immediately (an Active phase without a handoff is abnormal).
→ Action (all modes): Report WARNING. Remind user to check progress.

**Check 6 - OVER_ACTIVE**: More than 1 phase in the same Epic is 🔄 Active.
→ Detection: Count Active phases per Epic. If > 1 → violation.
→ Action (all modes): Report ERROR. This violates concurrent control rules.

**Check 7 - OVER_LIMIT**: More than `max_active_epics` (default 3) Epics in `active/epics/`.
→ Detection: Count Epic files in `.tad/active/epics/` (excluding `.gitkeep`). If > 3 → warning.
→ Action (all modes): Report WARNING. Suggest completing existing Epics before creating new ones.

### Step 2e-iii: Actions (SYNC/FULL mode only)

- STALE → move to `.tad/archive/epics/` (two-phase safety: copy first, verify, then delete source)
- ORPHAN → FULL mode only, interactive confirmation via AskUserQuestion
- All others → report only, do not auto-fix

## Step 3: NEXT.md Maintenance

### Step 3a: Read Thresholds from Config

Read `.tad/config.yaml` section `next_md_maintenance.size_limits`:
- `warning_threshold` (default 400)
- `max_lines` (default 500)

### Step 3b: Check

1. Count total lines in NEXT.md
2. Parse sections by `## ` headers
3. Classify each section:

| Section Pattern | Classification | Archive? |
|-----------------|---------------|----------|
| `## 已完成 (DATE)` or `## Completed (DATE)` | Completed | Yes, if DATE > 7 days ago |
| `## 今天` or `## Today` | Active | Never |
| `## 本周` or `## This Week` | Active | Never |
| `## In Progress` | Active | Never |
| `## 待定` or `## Pending` | Active | Never |
| `## 阻塞` or `## Blocked` | Active | Never |
| `## vX.X 变更摘要` | Reference | Archive with its parent completed section |
| Any other `## ` section | Unknown | Flag in report, don't auto-archive |

4. Check if total lines > `warning_threshold`

### Step 3c: Actions (SYNC/FULL mode only)

Only if total lines > `max_lines` (from config):
1. Identify archivable sections (completed > 7 days + their reference tables)
2. Read `.tad/templates/history-md-template.md` for archive format
3. Create or append to `docs/HISTORY.md`:
   - If `docs/HISTORY.md` doesn't exist, create it with template header
   - Append archived sections under `## Week of {date}` heading
4. **Write HISTORY.md first, verify write succeeded**
5. Only then: remove archived sections from NEXT.md
6. Update any stale version references in NEXT.md

If between `warning_threshold` and `max_lines`: report WARNING but do not auto-archive.

## Step 4: PROJECT_CONTEXT.md Sync

### Check:
- File exists?
- If exists: version matches `.tad/version.txt`?

### Actions (SYNC/FULL mode only):

If missing, create with this template (use actual project values):

```markdown
# Project Context - {project_name}

## Current State
- **Version**: {from .tad/version.txt}
- **Last Updated**: {today}
- **Framework**: TAD v{version}

## Active Work
{list each file in .tad/active/handoffs/ with status}

## Recent Decisions
{from last 3 archived handoffs - 1 line summary each}

## Known Issues
{any flagged items from health check}

## Next Direction
{from NEXT.md active sections - top 3 items}
```

If exists but outdated: update version and Active Work section only.
Keep under 150 lines.

## Step 5: Document Consistency Check

### Checks (all modes):
1. `.tad/version.txt` value == `config.yaml` `version:` field
2. No orphaned design files in `.tad/active/designs/` (designs whose slug has no matching active handoff)
3. Evidence check (FULL mode only): `.tad/evidence/reviews/` files reference existing archived gates

### Actions (FULL mode only):
- Report all inconsistencies
- Auto-fix: if version.txt and config.yaml disagree, report which is newer (by file modification date) and suggest fix, but do NOT auto-fix version mismatches

## Step 6: Health Report Output (Terminal)

**CHECK mode output:**

```
=== TAD Health Check | {date} ===

HANDOFFS
  [icon] {N} active | {N} completed (not archived) | {N} stale | {N} potentially stale (age>{threshold}d) | {N} potentially superseded

EPICS
  [icon] {N} active | {N} stale | {N} orphan | {N} stuck | {N} over-active | {N} dangling refs

DOCUMENTS
  [icon] NEXT.md: {lines} lines {status}
  [icon] PROJECT_CONTEXT.md: {exists/missing}
  [icon] Version: {version.txt} / config: {config version}

PAIR TESTING
  [icon] TEST_BRIEF.md: {exists/none}
  [icon] PAIR_TEST_REPORT.md: {exists (unprocessed!)/none}
  [icon] e2e-screenshots/: {exists ({N} files)/none}

{if issues found:}
RECOMMENDED ACTIONS
  1. Run `/tad-maintain` to sync documents
  2. {specific recommendations}
  {if PAIR_TEST_REPORT.md exists:}
  N. Run *test-review in Alex to process pair test report

HEALTH: {OK/WARNING/CRITICAL}
===
```

**SYNC/FULL mode output:**

```
=== TAD Maintain Report | {date} | MODE: {sync/full} ===

HANDOFFS
  [icon] {N} properly archived
  [icon] {N} completed -> archived (this run)
  [icon] {N} stale -> cleaned (this run)
  [icon] {N} user-confirmed -> archived/deleted (this run)
  [icon] {N} active (in progress)

EPICS
  [icon] {N} properly archived
  [icon] {N} stale -> archived (this run)
  [icon] {N} orphan -> user-confirmed (this run)
  [icon] {N} active (in progress)
  [icon] {N} warnings (dangling refs, stuck, back-ref mismatch)

DOCUMENTS
  [icon] config.yaml: v{version}
  [icon] version.txt: v{version}
  [icon] NEXT.md: {lines} lines ({action taken or status})
  [icon] PROJECT_CONTEXT.md: {created/updated/ok}

PAIR TESTING
  [icon] TEST_BRIEF.md: {exists/none}
  [icon] PAIR_TEST_REPORT.md: {exists (unprocessed!)/none}
  [icon] e2e-screenshots/: {exists ({N} files)/none}

CONSISTENCY
  [icon] Version alignment: {pass/fail}
  [icon] Active directory: {clean/N orphans}

ACTIONS TAKEN
  1. {description}
  2. {description}
  ...

{if any errors:}
ERRORS
  1. {what failed and why}

HEALTH: {OK/WARNING/CRITICAL} - {summary}
===
```

Icons: use text markers `[OK]` `[WARN]` `[ERR]` `[INFO]` for terminal compatibility.
