# Handoff: Multi-Platform Runtime Cleanup

**From:** Alex | **To:** Blake | **Date:** 2026-02-17
**Priority:** P1
**Process Depth:** Full TAD
**Version Bump:** v2.2.1 → v2.3.0 (architectural simplification — multi-platform runtime removal)

## Executive Summary

Remove the "full TAD runtime" model for Codex/Gemini. These platforms failed in real-world testing — gate mechanisms weren't understood, tad-init overwrote user's CLAUDE.md, and the overall experience was negative. The new model: Codex/Gemini receive Handoffs as "temporary Blake" for specialized tasks (code review, frontend design), with Alex (Claude) doing acceptance. No new framework needed — existing Handoff mechanism is sufficient.

## Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Codex/Gemini role | Full TAD runtime / Specialized tools / Remove entirely | Specialized tools via existing Handoff | Real-world testing showed full runtime fails; Handoff model already mature |
| 2 | tad.sh cleanup | Remove completely / Keep detection / Mark deprecated | Remove Codex/Gemini code completely | tad.sh only needs to serve Claude Code |
| 3 | config-platform.yaml | Split file / In-place cleanup / Keep as-is | In-place cleanup (remove multi_platform, keep MCP) | Minimizes reference chain changes |
| 4 | Skills files | Delete / Keep | Keep | Used by Claude Code Gates + future Codex/Gemini task reference |
| 5 | MULTI-PLATFORM.md | Delete / Archive / Rewrite | Rewrite as "Specialized Tools" guide | User wants a guide for giving Handoffs to Codex/Gemini |

## Task Breakdown

### Task 1: Delete Outdated Platform Files (Root Level)

**Delete these files completely:**

| File | Lines | Reason |
|------|-------|--------|
| `AGENTS.md` | 176 | Outdated Codex project instructions (v2.0 level) |
| `GEMINI.md` | 201 | Outdated Gemini project instructions |
| `.codex/README.md` | 26 | Codex quick start guide |
| `.gemini/README.md` | ~31 | Gemini quick start guide |
| `.gemini/commands/tad-alex.toml` | ~40 | Gemini Alex command |
| `.gemini/commands/tad-blake.toml` | ~40 | Gemini Blake command |
| `.gemini/commands/tad-gate.toml` | ~40 | Gemini Gate command |
| `.gemini/commands/tad-init.toml` | ~40 | Gemini Init command |
| `.gemini/commands/tad-status.toml` | ~40 | Gemini Status command |
| `.gemini/commands/tad-help.toml` | ~40 | Gemini Help command |
| `.tad/templates/AGENTS.md.template` | ~? | Template for generating AGENTS.md |
| `.tad/templates/GEMINI.md.template` | ~? | Template for generating GEMINI.md |

**After deleting files, remove empty directories:**
- `.codex/` (entire directory)
- `.gemini/` (entire directory, including `.gemini/commands/`)

### Task 2: Clean config-platform.yaml (In-Place)

**File:** `.tad/config-platform.yaml` (288 lines)

**Action:** Remove lines 1-55 (the entire `multi_platform` section), keep lines 57-288 (MCP tools section).

**Update file header comment:**
```yaml
# TAD Config Module: MCP Tools Integration
# Part of TAD config.yaml modular split (v2.2)
# Contains: mcp_tools
# Consumers: tad-alex.md (MCP), tad-blake.md (MCP)
```

**Before (lines 1-5):**
```yaml
# TAD Config Module: Platform & MCP Tools
# Part of TAD config.yaml modular split (v2.2)
# Contains: multi_platform, mcp_tools
# Consumers: tad-init.md, tad-alex.md (MCP), tad-blake.md (MCP)
```

**After:**
```yaml
# TAD Config Module: MCP Tools Integration
# Part of TAD config.yaml modular split (v2.2)
# Contains: mcp_tools
# Consumers: tad-alex.md (MCP), tad-blake.md (MCP)
```

Remove: entire `multi_platform:` block (lines 6-55)
Keep: everything from line 57 (`# ==================== MCP 工具集成 ...`) onward, unchanged.

### Task 3: Update config.yaml Module Reference

**File:** `.tad/config.yaml`

**Change 1 — Module description (line 77):**
```yaml
# Before:
    description: "Multi-platform support, MCP tools integration"
# After:
    description: "MCP tools integration"
```

**Change 2 — Contains list (lines 78-80):**
```yaml
# Before:
    contains:
      - multi_platform (claude, codex, gemini, skills)
      - mcp_tools (agent_a_tools, agent_b_tools, enforcement, security)
# After:
    contains:
      - mcp_tools (agent_a_tools, agent_b_tools, enforcement, security)
```

**Change 3 — loaded_by list (lines 81-84):**
```yaml
# Before:
    loaded_by:
      - tad-init.md
      - tad-alex.md  # MCP tools
      - tad-blake.md  # MCP tools
# After:
    loaded_by:
      - tad-alex.md  # MCP tools
      - tad-blake.md  # MCP tools
```

**Change 4 — tad-init module binding (lines 114-116):**
```yaml
# Before:
  tad-init:
    modules: [config-platform]
    note: "Init only needs platform configuration"
# After:
  tad-init:
    modules: []
    note: "Init creates project structure, no config modules needed"
```

### Task 4: Clean tad.sh Install Script

**File:** `tad.sh` (977 lines)

⚠️ **IMPORTANT: Use FUNCTION NAMES to locate code, not line numbers. Line numbers are approximate references only.**

**Removals (preserve line continuity, don't leave gaps):**

1. **Header comment:** Change `# Multi-Platform Support: Claude Code, Codex CLI, Gemini CLI` → `# Claude Code Support`

2. **Function `backup_existing()`:** Remove the two for-loops that backup `.codex`, `.gemini`, `AGENTS.md`, `GEMINI.md`:
   ```bash
   # Remove these blocks inside backup_existing():
   for dir in .codex .gemini; do ...
   for file in AGENTS.md GEMINI.md; do ...
   ```

3. **Function `detect_installed_tools()`:** Simplify to only detect Claude Code. Remove the Codex CLI and Gemini CLI detection blocks (the `if command -v codex` and `if command -v gemini` blocks).

4. **Delete these 3 functions entirely:** `generate_codex_config()`, `generate_agents_md()`, `convert_commands_to_codex()`

5. **Delete these 3 functions entirely:** `generate_gemini_config()`, `generate_gemini_md()`, `convert_commands_to_gemini()`

6. **Function `rollback_on_failure()`:** Remove cleanup of `AGENTS.md`, `GEMINI.md`, `.codex`, `.gemini`:
   ```bash
   # Remove these blocks inside rollback_on_failure():
   for file in AGENTS.md GEMINI.md; do ...
   for dir in .codex .gemini; do ...
   ```

7. **Function `main()` — "what will happen" display sections:** Remove all `codex)` and `gemini)` case blocks inside the install/upgrade/migrate display `case $ACTION` blocks.

8. **Function `main()` — platform config generation loop:** Remove the `for tool in $DETECTED_PLATFORMS` loop that calls `generate_codex_config` and `generate_gemini_config`. (The loop body only has codex and gemini cases, so the entire loop can be removed.)

9. **Function `main()` — final output:** Remove the `for tool in $DETECTED_PLATFORMS` loop that displays Codex/Gemini quick start lines. Keep only the Claude line.

10. **Function `main()` — header banner:** Change `Multi-Platform Support` to `Claude Code Integration`.

11. **Function `main()` — Platforms display:** Remove `echo -e "   Platforms: ${CYAN}$DETECTED_PLATFORMS${NC}"` and the `DETECTED_PLATFORMS` variable usage throughout, since it's now always just "claude".

12. **`$DETECTED_PLATFORMS` variable:** Can be simplified or removed entirely — the script now only supports Claude Code.

### Task 5: Clean tad-init.md Command

**File:** `.claude/commands/tad-init.md`

**Remove:** Section 7 "Multi-Platform Support" entirely (lines 113-207+). This includes:
- 7a. Codex CLI Support (AGENTS.md generation, .codex/README.md, command conversion)
- 7b. Gemini CLI Support (GEMINI.md generation, .gemini/commands/, command conversion)

### Task 6: Clean tad-status.md Command

**File:** `.claude/commands/tad-status.md`

**Change 1 (line 25):** Remove `[✅/❌] Multi-Platform adapters (.tad/adapters/)`

**Change 2 (line 90):** Change `v2.2.1 features available (Ralph Loop, Skills, Multi-Platform, Pair Testing)` → `v2.2.1 features available (Ralph Loop, Skills, Pair Testing)`

### Task 7: Clean tad.md Main Entry

**File:** `.claude/commands/tad.md`

**Change 1 (line 9):** Remove "Multi-Platform" from welcome line.

**Change 2 (line 64):** Remove `- **Multi-Platform**: Claude Code, Codex CLI, Gemini CLI support`

**Change 3 (line 146):** Remove `- 🤝 **Multi-Platform**: Claude Code, Codex CLI, Gemini CLI`

**Change 4 (line 149):** Remove "Multi-Platform" from LLM instruction.

### Task 7b: Clean tad-help.md (P0 FIX — missed in original draft)

**File:** `.claude/commands/tad-help.md`

**Change (line 215):** Remove `- **Multi-Platform**: Claude Code, Codex CLI, Gemini CLI support`

### Task 7c: Clean README.md (P0 FIX — missed in original draft)

**File:** `README.md`

**Changes:**
- Line 5: Update docs portal link — remove "Multi-Platform Guide" link or change to "Specialized Tools Guide"
- Lines 74-76: Remove or rewrite "Multi-Platform Support (v2.1.0)" section. Replace with a brief note: "Codex CLI and Gemini CLI can serve as specialized execution tools via the Handoff mechanism. See [Specialized Tools Guide](docs/MULTI-PLATFORM.md)."
- Line 90: Remove "Detects platforms: Claude Code, Codex CLI, Gemini CLI"
- Lines 120-126: Remove `.codex/`, `.gemini/`, `AGENTS.md`, `GEMINI.md` from directory structure display
- Line 333: Keep historical version table entry (v2.1.0 is history) but mark if needed
- Line 402: Update link text from "Multi-Platform Guide" to "Specialized Tools Guide"

### Task 7d: Clean INSTALLATION_GUIDE.md (P0 FIX — missed in original draft)

**File:** `INSTALLATION_GUIDE.md`

**Changes:**
- Line 12: Change "检测平台：自动检测 Claude Code、Codex CLI、Gemini CLI" → "检测平台：Claude Code"
- Lines 232+: Remove comments about detecting Codex/Gemini
- Lines 250-254: Remove Codex CLI section
- Lines 268-269: Remove Codex/Gemini rows from platform table
- Lines 273: Change "Codex/Gemini: 读取 .tad/skills/..." → remove or simplify
- Lines 282-284: Remove multi-platform mention

### Task 7e: Clean docs/README.md (P0 FIX — missed in original draft)

**File:** `docs/README.md`

**Changes:**
- Line 3: Remove "Multi-Platform" from header links, or update to "Specialized Tools"
- Line 11: Change "Claude/Codex/Gemini support (v2.1)" → "Specialized Tools Guide"
- Lines 42-43: Remove Codex/Gemini rows from platform table
- Line 45: Update "Multi-Platform Guide" reference to "Specialized Tools Guide"

### Task 8: Rewrite docs/MULTI-PLATFORM.md

**File:** `docs/MULTI-PLATFORM.md` (288 lines → ~60 lines)

**Replace entire content with a "Specialized Tools Guide":**

```markdown
# TAD Specialized Tools Guide

**Version 2.9.0**

> TAD runs on Claude Code as its primary runtime. Codex CLI and Gemini CLI can serve as
> specialized execution tools for specific tasks via the Handoff mechanism.

---

## Architecture

| Platform | Role | How It Works |
|----------|------|--------------|
| **Claude Code** | Full TAD Runtime | Alex (design) + Blake (implement) + Gates |
| **Codex CLI** | Specialized Executor | Receives Handoff → executes task → human returns result to Alex |
| **Gemini CLI** | Specialized Executor | Receives Handoff → executes task → human returns result to Alex |

## When to Use Codex/Gemini

| Tool | Best For | Workflow |
|------|----------|---------|
| **Codex CLI** | Code review, security audit | Alex creates Handoff → human gives to Codex → Codex reviews → human brings findings back |
| **Gemini CLI** | Frontend design, UI prototyping | Alex creates Handoff or /playground output → human gives to Gemini → Gemini designs → human brings result back |

## Workflow

1. **Alex (Claude)** designs task and creates Handoff as usual
2. **Human** decides which tool to use for execution (Claude Blake / Codex / Gemini)
3. **Human** copies Handoff content to the chosen tool
4. **Tool** executes the task
5. **Human** brings results back to Alex for acceptance (Gate 4)

## Tips

- Give Codex/Gemini the full Handoff content — it contains all context needed
- Reference `.tad/skills/{skill}/SKILL.md` for quality checklists they can follow
- Evidence files should still go to `.tad/evidence/reviews/` for Gate verification
- Alex does NOT need to know which tool executed — acceptance is based on results

## Skills Reference

The `.tad/skills/` directory contains platform-agnostic quality checklists:

| Skill | Use Case |
|-------|----------|
| code-review | Code quality, type safety, structure |
| security-audit | Security vulnerabilities, data protection |
| testing | Test coverage, test quality |
| performance | Performance bottlenecks, optimization |
| ux-review | UI/UX quality, accessibility |
| architecture | System design, data flow |
| api-design | API contracts, RESTful patterns |
| debugging | Bug diagnosis, root cause analysis |

---

*TAD v2.3.0 — Claude Code primary, Codex/Gemini as specialized tools.*
```

### Task 9: Update PROJECT_CONTEXT.md

**File:** `PROJECT_CONTEXT.md`

- Update version description to reflect v2.3.0 changes
- Update framework description: Remove "Multi-Platform" from the list
- Add to Recent Decisions: "Multi-Platform Cleanup: Removed full TAD runtime for Codex/Gemini, simplified to specialized tool model via existing Handoff mechanism (2026-02-17)"
- Add to Active Work if currently empty

### Task 10: Update ROADMAP.md

**File:** `ROADMAP.md`

- Under "Developer Experience" theme, add a row:
  `| Multi-Platform Cleanup (Codex/Gemini → specialized tools) | Direction | Complete | [Handoff](link) |`
- OR create a new completed item under appropriate theme

### Task 11: Update NEXT.md

- Add to "In Progress" or "Recently Completed" (depending on timing):
  `- [ ] Multi-Platform Cleanup: Remove full TAD runtime for Codex/Gemini, simplify to specialized tool model`

### Task 12: Version Bump

- `.tad/version.txt`: Update from `2.2.1` to `2.3`
- `config.yaml` line 3: Update `version: 2.2.1` → `version: 2.3.0`
- `config.yaml` `version_history` section: Add new entry:
  ```yaml
  v2.3.0:
    date: "2026-02-17"
    changes:
      - "Multi-Platform Runtime Cleanup: Removed full TAD runtime for Codex/Gemini"
      - "Codex/Gemini repositioned as specialized tools via existing Handoff mechanism"
      - "Removed ~1000 lines of outdated multi-platform configuration"
      - "docs/MULTI-PLATFORM.md rewritten as Specialized Tools Guide"
  ```

## Files to Modify (Complete List)

| # | File | Action | Lines Changed (est.) |
|---|------|--------|---------------------|
| 1 | `AGENTS.md` | DELETE | -176 |
| 2 | `GEMINI.md` | DELETE | -201 |
| 3 | `.codex/` (directory) | DELETE | - |
| 4 | `.gemini/` (directory) | DELETE | -~280 |
| 5 | `.tad/templates/AGENTS.md.template` | DELETE | - |
| 6 | `.tad/templates/GEMINI.md.template` | DELETE | - |
| 7 | `.tad/config-platform.yaml` | EDIT | -55 lines (remove multi_platform section) |
| 8 | `.tad/config.yaml` | EDIT | ~12 lines changed (module ref + version) |
| 9 | `tad.sh` | EDIT | -~350 lines (remove Codex/Gemini generation) |
| 10 | `.claude/commands/tad-init.md` | EDIT | -~100 lines (remove Section 7) |
| 11 | `.claude/commands/tad-status.md` | EDIT | 2 lines changed |
| 12 | `.claude/commands/tad.md` | EDIT | 4 lines changed |
| 13 | `.claude/commands/tad-help.md` | EDIT | 1 line removed |
| 14 | `README.md` | EDIT | ~15 lines changed |
| 15 | `INSTALLATION_GUIDE.md` | EDIT | ~20 lines changed |
| 16 | `docs/README.md` | EDIT | ~6 lines changed |
| 17 | `docs/MULTI-PLATFORM.md` | REWRITE | 288 → ~70 lines |
| 18 | `PROJECT_CONTEXT.md` | EDIT | ~5 lines changed |
| 19 | `ROADMAP.md` | EDIT | ~2 lines added |
| 20 | `NEXT.md` | EDIT | ~2 lines added |

**Estimated net change:** ~-1100 lines removed, ~70 lines added
**Total files affected:** 20

## Acceptance Criteria

- [ ] AC1: All outdated files deleted (AGENTS.md, GEMINI.md, .codex/, .gemini/, templates)
- [ ] AC2: tad.sh syntax check passes: `bash -n tad.sh`
- [ ] AC3: tad.sh contains no references to codex/gemini functions
- [ ] AC4: config.yaml → config-platform.yaml reference chain intact (MCP tools still loadable)
- [ ] AC5: config-platform.yaml is valid YAML after edit
- [ ] AC6: .tad/skills/ preserved and intact (8 skills discoverable)
- [ ] AC7: docs/MULTI-PLATFORM.md rewritten as Specialized Tools Guide
- [ ] AC8: No broken references — `grep -ri "AGENTS\.md\|GEMINI\.md\|\.codex\|\.gemini" .claude/commands/ .tad/config*.yaml CLAUDE.md README.md INSTALLATION_GUIDE.md` returns 0 results
- [ ] AC9: Acceptable exceptions only: research.md "Gemini Deep Research", CHANGELOG.md historical entries, version_history
- [ ] AC10: README.md, INSTALLATION_GUIDE.md, docs/README.md cleaned of Codex/Gemini runtime references
- [ ] AC11: PROJECT_CONTEXT.md, ROADMAP.md, NEXT.md updated
- [ ] AC12: Version bumped: version.txt=2.3, config.yaml version=2.3.0, version_history entry added

## Testing Checklist

- [ ] `bash -n tad.sh` — syntax check passes
- [ ] `grep -ri "AGENTS\.md\|GEMINI\.md\|\.codex\|\.gemini" .claude/commands/ .tad/config*.yaml CLAUDE.md README.md INSTALLATION_GUIDE.md` — 0 results
- [ ] `grep -ri "codex cli\|gemini cli" .claude/commands/ README.md INSTALLATION_GUIDE.md` — 0 results (except docs/ and CHANGELOG)
- [ ] `grep -r "multi_platform" .tad/config*.yaml` — 0 results
- [ ] config-platform.yaml starts with MCP section (no multi_platform block)
- [ ] config.yaml tad-init modules = `[]`
- [ ] `.tad/skills/` contains 8 skill directories
- [ ] Directories `.codex/` and `.gemini/` do not exist
- [ ] Files `AGENTS.md` and `GEMINI.md` do not exist at project root

## Blake Instructions

- Execute tasks 1-12 in order, then 7b-7e (P0 fix additions)
- Task 4 (tad.sh) is the most complex — use FUNCTION NAMES to locate code, not line numbers
- Task 8 (MULTI-PLATFORM.md rewrite) — use the provided content as-is
- Tasks 7b-7e are P0 fixes from expert review — clean all Codex/Gemini references from docs
- Run Ralph Loop Layer 1 (self-check) after all edits
- Run ALL Testing Checklist items
- For Gate 3: verify all 12 Acceptance Criteria
- If any reference chain breaks, fix immediately before proceeding

## Expert Review Status

| Expert | Focus | Status | Result |
|--------|-------|--------|--------|
| code-reviewer | Config consistency, reference chains, script integrity | ✅ Done | CONDITIONAL PASS → P0s fixed |
| backend-architect | Architecture simplification, dependency analysis | ✅ Done | CONDITIONAL PASS → P0s fixed |

### P0 Issues Found and Fixed

| # | Source | Issue | Fix |
|---|--------|-------|-----|
| P0-1 | code-reviewer | Missing files: tad-help.md, README.md, INSTALLATION_GUIDE.md, docs/README.md | Added Tasks 7b-7e |
| P0-2 | code-reviewer | tad.sh instructions used line numbers (risky) | Changed Task 4 to use function names |
| P0-3 | code-reviewer + architect | Version inconsistency (2.8.0 vs 2.2.1) | Fixed: v2.2.1 → v2.3.0 (framework version) |

### P1 Recommendations Integrated

| # | Source | Recommendation | Action |
|---|--------|----------------|--------|
| P1-1 | code-reviewer | Add grep verification to AC | Added to AC8, Testing Checklist |
| P1-3 | code-reviewer | tad-status.md adapters line | Confirmed .tad/adapters/ doesn't exist — line removal is correct |
| P1-4 | code-reviewer | skills-config.yaml check | Verified — no codex/gemini refs, no action needed |
| P1-3 | architect | Version strategy clarification | Resolved: v2.3.0 (MINOR bump, SemVer correct for feature removal) |
| P1-4 | architect | Consider renaming config-platform.yaml → config-mcp.yaml | Deferred to future cleanup (note in NEXT.md) |

---

*Generated by Alex (Solution Lead) — TAD Full Workflow*
*Expert Review: 2 reviewers (code-reviewer + backend-architect), 3 P0 all fixed*
