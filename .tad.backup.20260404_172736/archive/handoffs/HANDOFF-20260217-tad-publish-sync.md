# Handoff: TAD Publish & Sync Commands

**From:** Alex | **To:** Blake | **Date:** 2026-02-17
**Type:** Standard TAD
**Priority:** P1

## Executive Summary

Add two new Alex commands (`*publish` and `*sync`) plus supporting data files to systematize TAD's GitHub release and cross-project synchronization workflows. Currently both processes rely on human memory, causing missed steps (e.g., tad.sh version number was forgotten during the v2.3.0 release). These commands provide structured checklists with guided execution.

## Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Command ownership | Alex / Blake / Standalone | Alex sub-commands | Publish and sync are project management operations, Alex's domain |
| 2 | Project registration | Auto-scan / Manual / Hybrid | Manual only | Simpler, safer, no risk of syncing wrong projects |
| 3 | GitHub release scope | Check only / Check+push / Check+push+tag | Check + push + tag | Human confirms before each destructive action |
| 4 | Deprecation mechanism | Deprecation list / Diff-based | Deprecation list per version | Explicit, no risk of accidentally deleting project-specific files |
| 5 | CLAUDE.md merge strategy | Always overwrite / Always merge / Auto-detect | Auto-detect via `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker | HTML comment won't conflict with standard markdown; first occurrence splits TAD vs project content |

## Task Breakdown

### Task 1: Create `sync-registry.yaml`
**File:** `.tad/sync-registry.yaml` (NEW)

```yaml
# TAD Sync Registry — Manual project registration
# Managed by Alex *sync command

registry_version: 1
tad_source: "."  # This repo is the TAD source

projects: []
  # Example entry:
  # - path: "/Users/sheldonzhao/01-on progress programs/menu-snap"
  #   name: "menu-snap"
  #   claude_md_strategy: "overwrite"  # overwrite | merge
  #   last_synced_version: "2.3.0"
  #   last_synced_date: "2026-02-17"
  #   notes: ""
```

Strategy detection rule for `claude_md_strategy`:
- On first registration, read the project's CLAUDE.md
- If it contains the HTML comment marker `<!-- TAD:PROJECT-CONTENT-BELOW -->` → `merge`
- Otherwise → `overwrite`
- User can override manually

**Separator convention**: Use `<!-- TAD:PROJECT-CONTENT-BELOW -->` (HTML comment, will not conflict with standard markdown `---` horizontal rules). During merge, everything ABOVE the first occurrence of this marker is replaced with TAD source CLAUDE.md; everything FROM the marker onward is preserved.

### Task 2: Create `deprecation.yaml`
**File:** `.tad/deprecation.yaml` (NEW)

```yaml
# TAD Deprecation Registry — Files removed per version
# Used by *sync to clean up target projects

deprecations:
  "2.3.0":
    description: "Multi-platform cleanup — remove Codex/Gemini full runtime"
    files:
      - AGENTS.md
      - GEMINI.md
      - .codex/
      - .gemini/
      - .tad/templates/AGENTS.md.template
      - .tad/templates/GEMINI.md.template
    date: "2026-02-17"
```

Each version entry lists files/directories to delete. `*sync` processes deprecations for all versions between the target project's `last_synced_version` and the current TAD version.

### Task 3: Add `*publish` protocol to `tad-alex.md`
**File:** `.claude/commands/tad-alex.md` (MODIFY)

Add to `commands:` section:
```yaml
  # Framework management commands
  publish: GitHub publish workflow — version check, changelog, push, tag
  sync: Sync TAD to registered projects — framework files, cleanup, verify
  sync-add: Register a new project for TAD sync
  sync-list: List registered projects and sync status
```

Add protocol block `publish_protocol`:

```yaml
publish_protocol:
  description: "GitHub publish workflow with version consistency checks"
  trigger: "User types *publish"

  execution:
    step1:
      name: "Version Consistency Check"
      action: |
        Read and compare version strings from these files:
        1. .tad/version.txt (uses MAJOR.MINOR format, e.g., "2.3")
        2. .tad/config.yaml → version field (uses MAJOR.MINOR.PATCH, e.g., "2.3.0")
        3. tad.sh → TARGET_VERSION (uses MAJOR.MINOR format, e.g., "2.3")
        4. INSTALLATION_GUIDE.md → version references
        5. .claude/commands/tad-help.md → version references

        Consistency rule: extract MAJOR.MINOR from all sources; they must match.
        (config.yaml's ".0" patch suffix is expected and not a mismatch)

        Display comparison table:
        | File | Format | Version Found | MAJOR.MINOR | Status |
        |------|--------|--------------|-------------|--------|
        | version.txt | M.m | 2.3 | 2.3 | ✅ |
        | config.yaml | M.m.p | 2.3.0 | 2.3 | ✅ |
        | tad.sh | M.m | 2.3 | 2.3 | ✅ |
        | ... | ... | ... | ... | ... |

        If ANY MAJOR.MINOR mismatch → list them and ask user to fix before continuing.
        Alex does NOT fix version numbers directly (Alex doesn't code).

    step2:
      name: "CHANGELOG Check"
      action: |
        Read CHANGELOG.md.
        Check if there's an entry for the current version.
        If missing → warn: "CHANGELOG.md has no entry for v{version}. Add one before publishing."
        If exists → show the entry summary.

    step3:
      name: "Git Status Check"
      action: |
        Display git status summary:
        - Uncommitted changes?
        - Unpushed commits?
        - Current branch?
        If uncommitted changes → warn and ask user to commit first.

    step4:
      name: "Confirm & Execute"
      action: |
        Use AskUserQuestion:
        "Pre-publish checks complete. Ready to publish?"
        Options:
        - "Push + Tag" → execute git push && git tag v{version} && git push --tags
        - "Push only" → git push (no tag)
        - "Abort" → cancel

        EXCEPTION TO "ALEX DOESN'T CODE":
        Git push/tag are one-way publish operations with no design ambiguity.
        Human confirms before each command via AskUserQuestion.
        This exception does NOT extend to: code changes, build scripts,
        configuration file edits, or any implementation work.

    step5:
      name: "Post-Publish"
      action: |
        After successful push:
        1. Display confirmation with commit hash and tag
        2. Suggest: "Run *sync to update registered projects"
        Return to standby.
```

### Task 4: Add `*sync` protocol to `tad-alex.md`
**File:** `.claude/commands/tad-alex.md` (MODIFY)

Add protocol block `sync_protocol`:

```yaml
sync_protocol:
  description: "Sync TAD framework files to registered projects"
  trigger: "User types *sync"

  execution:
    step1:
      name: "Load Registry"
      action: |
        Check if .tad/sync-registry.yaml exists.
        If missing → "Registry not found. Use *sync-add to register a project first." → standby.
        Read .tad/sync-registry.yaml.
        If projects list is empty → "No projects registered. Use *sync-add to register one." → standby.
        Display project table:
        | # | Project | Last Synced | Current | Status |
        |---|---------|------------|---------|--------|
        | 1 | menu-snap | v2.3.0 | v2.3.0 | ✅ Up to date |
        | 2 | my-openclaw-agents | v2.2.1 | v2.3.0 | ⚠️ Needs sync |

    step2:
      name: "Select Scope"
      action: |
        Use AskUserQuestion:
        "Which projects to sync?"
        Options:
        - "All outdated projects" → sync all where last_synced < current
        - "Select specific" → show numbered list, user picks
        - "Cancel" → standby

    step3:
      name: "Execute Sync (per project)"
      action: |
        For each selected project, execute in order:

        0. PATH VALIDATION:
           - Check target path exists
           - Check .tad/ directory exists at target
           - If validation fails → mark as SKIPPED, log error, continue to next project

        a. CLAUDE.md — based on claude_md_strategy:
           - "overwrite": copy TAD source CLAUDE.md directly
           - "merge":
             1. Read target CLAUDE.md
             2. Find first occurrence of `<!-- TAD:PROJECT-CONTENT-BELOW -->`
             3. If marker found: replace everything ABOVE the marker with TAD source CLAUDE.md content, preserve marker + everything below
             4. If marker NOT found: WARN user "Merge marker not found in {project}. Overwrite or skip?"
                → AskUserQuestion: "Overwrite" / "Skip this project"
           - After merge: backup original to CLAUDE.md.bak before writing

        b. Framework files — copy from TAD source (mirror tad.sh copy_framework_files):
           Top-level .tad/ config & metadata:
           - .tad/*.yaml, .tad/*.md, .tad/*.txt (all top-level files)
           Framework subdirectories (full recursive copy):
           - .tad/agents/
           - .tad/data/
           - .tad/gates/
           - .tad/guides/
           - .tad/ralph-config/
           - .tad/references/
           - .tad/schemas/
           - .tad/skills/
           - .tad/sub-agents/
           - .tad/tasks/
           - .tad/templates/
           - .tad/workflows/
           .claude/ framework files:
           - .claude/commands/*.md
           - .claude/settings.json
           - .claude/skills/code-review/* (recursive)
           - .claude/skills/doc-organization.md
           Root-level files:
           - tad.sh
           - docs/MULTI-PLATFORM.md
           - README.md, INSTALLATION_GUIDE.md

        c. Deprecation cleanup:
           Read .tad/deprecation.yaml (if missing → skip silently, no deprecations to apply).
           Version comparison rules (semver):
           - Compare major.minor.patch numerically (2.10.0 > 2.3.0)
           - Apply deprecations where: last_synced_version < deprecation_version <= current_version
           - If deprecation.yaml has no entries for the version range → skip silently
           - Ignore entries for versions > current_version (future deprecations)
           For each matching deprecation: delete listed files/directories, log each deletion.

        d. Verification:
           - Check version.txt in target matches current TAD version
           - Check CLAUDE.md exists and is readable
           - If merge: verify project-specific content still present (check marker exists)

        e. Update registry:
           - Set last_synced_version and last_synced_date

        PRESERVE (never touch):
        - .tad/project-knowledge/
        - .tad/active/ (handoffs, epics, ideas)
        - .tad/archive/
        - .tad/evidence/
        - .tad/pair-testing/
        - .tad/decisions/
        - PROJECT_CONTEXT.md, NEXT.md, CHANGELOG.md (project-level)

    step4:
      name: "Summary"
      action: |
        Display sync summary:
        | Project | Version | Files Updated | Files Deleted | Status |
        |---------|---------|--------------|---------------|--------|
        | menu-snap | → 2.3.0 | 45 | 0 | ✅ |
        | my-openclaw-agents | → 2.3.0 | 45 | 6 | ✅ |

        Return to standby.
```

### Task 5: Add `*sync-add` and `*sync-list` protocols
**File:** `.claude/commands/tad-alex.md` (MODIFY)

```yaml
sync_add_protocol:
  description: "Register a new project for TAD sync"
  trigger: "User types *sync-add"

  execution:
    step1:
      name: "Get Project Path"
      action: |
        Ask user for the project's absolute path.
        Validate:
        - Path exists
        - .tad/ directory exists (has TAD installed)
        - .tad/version.txt exists (can read current version)
        If validation fails → error with specific message.

    step2:
      name: "Detect CLAUDE.md Strategy"
      action: |
        Read the project's CLAUDE.md.
        If it contains `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker:
          → Pre-select "merge"
          → Show: "Detected project-specific content in CLAUDE.md (N lines after marker)"
        Else:
          → Pre-select "overwrite"
        Use AskUserQuestion to confirm strategy.
        If user selects "merge" but marker doesn't exist yet:
          → Inform: "You'll need to add `<!-- TAD:PROJECT-CONTENT-BELOW -->` to the project's CLAUDE.md before the project-specific section."

    step3:
      name: "Register"
      action: |
        Add entry to .tad/sync-registry.yaml with:
        - path, name (derived from directory name), claude_md_strategy
        - last_synced_version: read from target's .tad/version.txt
        - last_synced_date: today
        Confirm: "Project {name} registered for TAD sync."

sync_list_protocol:
  description: "List registered projects and their sync status"
  trigger: "User types *sync-list"
  execution:
    step1:
      name: "Display"
      action: |
        Read .tad/sync-registry.yaml.
        Display table with: name, path, strategy, last synced version, current TAD version, status.
        Return to standby.
```

### Task 6: Update `commands` section, `on_start`, Quick Reference
**File:** `.claude/commands/tad-alex.md` (MODIFY)

**Commands section** — add under new heading:
```yaml
  # Framework management commands
  publish: GitHub publish workflow — version check, changelog, push, tag
  sync: Sync TAD to registered projects — framework files, cleanup, verify
  sync-add: Register a new project for TAD sync
  sync-list: List registered projects and sync status
```

**on_start greeting** — add line:
```
  - *publish — Push TAD updates to GitHub (version check + push + tag)
  - *sync — Sync TAD to your other projects
```

**Quick Reference Key Commands** — add:
```
- `*publish` - GitHub publish (version consistency check → push → tag)
- `*sync` - Sync TAD framework to registered projects
- `*sync-add` - Register a new project for sync
- `*sync-list` - List registered sync projects
```

**standby.enters_standby** — add:
```
- "After *publish step5 completes → Enter standby"
- "After *sync step4 completes → Enter standby"
- "After *sync-add step3 completes → Enter standby"
- "After *sync-list step1 completes → Enter standby"
```

### Task 7: Update `config.yaml`
**File:** `.tad/config.yaml` (MODIFY)

Add to `version_history`:
```yaml
  - version: "2.4.0"
    date: "2026-02-17"
    changes: "Added *publish and *sync commands for GitHub release and cross-project sync"
```

Update `version` to `2.4.0`.

### Task 8: Update `CLAUDE.md` routing table
**File:** `CLAUDE.md` (MODIFY)

In Section 2 "TAD Framework 使用场景", add row to the table:
```
| `/alex` + `*publish` | TAD 升级后推送 GitHub（版本检查 + push + tag）|
| `/alex` + `*sync` | 同步 TAD 框架到已注册的活跃项目 |
```

### Task 9: Update `tad-help.md`
**File:** `.claude/commands/tad-help.md` (MODIFY)

Add to Available Commands section:
```
- `*publish` - GitHub publish workflow (Alex command)
- `*sync` - Sync TAD to registered projects (Alex command)
- `*sync-add` - Register project for sync
- `*sync-list` - List sync-registered projects
```

### Task 10: Update version files
**Files:** `.tad/version.txt`, `.tad/config.yaml`, `tad.sh`, `INSTALLATION_GUIDE.md`, `tad-help.md`

Bump version: 2.3 → 2.4 (new feature = minor bump).

Version format conventions (existing, do not change):
- `.tad/version.txt`: short format "2.4" (currently "2.3")
- `.tad/config.yaml`: full semver "2.4.0" (currently "2.3.0")
- `tad.sh` TARGET_VERSION: short format "2.4" (currently "2.3")
- `INSTALLATION_GUIDE.md` and `tad-help.md`: match surrounding context (typically "v2.4" or "2.4")

The `*publish` version check (Task 3 step1) must account for these format differences when comparing. version.txt and tad.sh use MAJOR.MINOR; config.yaml uses MAJOR.MINOR.PATCH. They are consistent if the MAJOR.MINOR parts match.

### Task 11: Update `PROJECT_CONTEXT.md` and `NEXT.md`
**Files:** `PROJECT_CONTEXT.md`, `NEXT.md` (MODIFY)

PROJECT_CONTEXT:
- Version: 2.4.0
- Active Work: *publish + *sync commands
- Recent Decisions: add entry

NEXT.md:
- Add to In Progress

### Task 12: Seed the registry with 3 current projects
**File:** `.tad/sync-registry.yaml` (MODIFY)

After creating the file, pre-populate with the 3 projects we just synced:
```yaml
projects:
  - path: "/Users/sheldonzhao/01-on progress programs/menu-snap"
    name: "menu-snap"
    claude_md_strategy: "overwrite"
    last_synced_version: "2.3.0"
    last_synced_date: "2026-02-17"
  - path: "/Users/sheldonzhao/01-on progress programs/my-openclaw-agents"
    name: "my-openclaw-agents"
    claude_md_strategy: "merge"
    last_synced_version: "2.3.0"
    last_synced_date: "2026-02-17"
  - path: "/Users/sheldonzhao/01-on progress programs/O1 for builder"
    name: "O1 for builder"
    claude_md_strategy: "overwrite"
    last_synced_version: "2.3.0"
    last_synced_date: "2026-02-17"
```

### Task 13: Seed deprecation.yaml with v2.3.0 entry
Already shown in Task 2 — the v2.3.0 Codex/Gemini cleanup files.

## Acceptance Criteria

- [ ] AC1: `*publish` runs version consistency check across 5+ files and reports mismatches
- [ ] AC2: `*publish` checks CHANGELOG.md for current version entry
- [ ] AC3: `*publish` executes git push + tag after human confirmation
- [ ] AC4: `*sync` reads sync-registry.yaml and shows project status table
- [ ] AC5: `*sync` correctly handles "overwrite" CLAUDE.md strategy (full replacement)
- [ ] AC6: `*sync` correctly handles "merge" CLAUDE.md strategy (preserve content after `---\n---`)
- [ ] AC7: `*sync` applies deprecation.yaml deletions for version gaps
- [ ] AC8: `*sync` NEVER touches project-knowledge, active, archive, evidence, pair-testing, PROJECT_CONTEXT.md, NEXT.md
- [ ] AC9: `*sync-add` validates target path has .tad/ and auto-detects CLAUDE.md strategy
- [ ] AC10: `*sync-list` displays all registered projects with sync status
- [ ] AC11: sync-registry.yaml pre-populated with 3 current projects
- [ ] AC12: deprecation.yaml seeded with v2.3.0 Codex/Gemini cleanup entry
- [ ] AC13: Version bumped to 2.4.0 across all files (version.txt, config.yaml, tad.sh, docs)
- [ ] AC14: CLAUDE.md routing table updated with *publish and *sync
- [ ] AC15: tad-help.md documents new commands
- [ ] AC16: Alex on_start greeting includes *publish and *sync
- [ ] AC17: standby enters_standby list updated for all 4 new commands
- [ ] AC18: `grep -E "codex|gemini|AGENTS.md|GEMINI.md" .tad/deprecation.yaml` returns expected entries
- [ ] AC19: `*sync` gracefully handles missing sync-registry.yaml (prompts to use *sync-add)
- [ ] AC20: `*sync` gracefully handles missing deprecation.yaml (skips deprecation step)
- [ ] AC21: `*sync` warns when merge strategy selected but marker not found in target CLAUDE.md
- [ ] AC22: `*publish` version check correctly handles mixed formats (MAJOR.MINOR vs MAJOR.MINOR.PATCH)

## Files to Modify/Create

| # | File | Action |
|---|------|--------|
| 1 | `.tad/sync-registry.yaml` | CREATE |
| 2 | `.tad/deprecation.yaml` | CREATE |
| 3 | `.claude/commands/tad-alex.md` | MODIFY (add 4 commands + 4 protocols + on_start + Quick Ref + standby) |
| 4 | `.tad/config.yaml` | MODIFY (version bump + history) |
| 5 | `CLAUDE.md` | MODIFY (routing table) |
| 6 | `.claude/commands/tad-help.md` | MODIFY (add commands) |
| 7 | `.tad/version.txt` | MODIFY (2.3.0 → 2.4.0) |
| 8 | `tad.sh` | MODIFY (TARGET_VERSION 2.3 → 2.4) |
| 9 | `INSTALLATION_GUIDE.md` | MODIFY (version refs) |
| 10 | `PROJECT_CONTEXT.md` | MODIFY (version + active work) |
| 11 | `NEXT.md` | MODIFY (add task) |

## Testing Checklist

- [ ] Read tad-alex.md after changes — verify no syntax errors in YAML blocks
- [ ] Verify sync-registry.yaml is valid YAML
- [ ] Verify deprecation.yaml is valid YAML
- [ ] Verify version consistency across all 5 version-bearing files
- [ ] Verify CLAUDE.md routing table has new entries
- [ ] Verify on_start greeting mentions new commands
- [ ] Verify Quick Reference lists new commands
- [ ] Verify standby enters_standby includes 4 new entries

## Blake Instructions

- Task 3 (tad-alex.md) is the largest task — add protocols near the end of the file, before the `# Forbidden actions` section
- CLAUDE.md merge uses `<!-- TAD:PROJECT-CONTENT-BELOW -->` HTML comment marker (NOT `---` markdown HR). Find first occurrence, replace everything above with TAD source, preserve marker + below. Create CLAUDE.md.bak backup before writing.
- The `*publish` step4 is an **exception** to "Alex doesn't code" — explicitly documented in the protocol
- Pre-populate both data files (Tasks 12-13) as part of implementation, not as a separate step
- Framework file list in *sync step3b must match tad.sh `copy_framework_files()` — 12 subdirectories under .tad/ plus .claude/ files and root-level files
- Version format: version.txt uses "2.4" (MAJOR.MINOR), config.yaml uses "2.4.0" (full semver). The *publish version check compares MAJOR.MINOR across all sources.
- All file read operations must handle "file not found" gracefully — see AC19-AC22
- For my-openclaw-agents: add `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker to its CLAUDE.md (replacing the current implicit separator) as part of seeding the registry (Task 12)

## Expert Review Status

| Expert | Status | Key Findings |
|--------|--------|-------------|
| code-reviewer | ✅ CONDITIONAL PASS → P0 Fixed | P0: separator fragile (→ HTML comment), missing file checks (→ added guards), version format (→ clarified), deprecation logic undefined (→ added semver rules). P1: Alex git exception documented. |
| backend-architect | ✅ CONDITIONAL PASS → P0 Fixed | P0: merge pattern edge cases (→ HTML marker + backup + warning), no rollback (→ CLAUDE.md.bak), version comparison (→ semver rules). P1: file list incomplete (→ matched tad.sh), add enabled flag (deferred to P2). |

### P0 Issues Resolved
1. **Separator**: `---\n---` → `<!-- TAD:PROJECT-CONTENT-BELOW -->` (HTML comment, no markdown conflict)
2. **File existence checks**: Added guards for missing sync-registry.yaml, deprecation.yaml, target path
3. **Version format**: Clarified version.txt uses "2.4" (MAJOR.MINOR), config.yaml uses "2.4.0"; publish compares MAJOR.MINOR
4. **Deprecation semver**: Added explicit rules (last_synced < deprecation_version <= current, numeric comparison)
5. **File list**: Expanded from 3 .tad/ dirs to 12 dirs (matching tad.sh copy_framework_files)
6. **Merge safety**: Added CLAUDE.md.bak backup, warning when marker missing

### P1 Items Deferred to Implementation
- Add dry-run mode for *sync (Blake can add if straightforward)
- Deprecation YAML retention policy (not needed yet with 1 entry)
- `enabled` flag in registry (can add later if needed)

### Expert Review Complete — Ready for Gate 2
