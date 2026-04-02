# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-31
**Project:** TAD Framework
**Task ID:** TASK-20260331-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260331-tad-v3-hook-native-rebuild.md (Phase 5/5 — FINAL)
**Linear:** N/A

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Final phase: version bump to v2.7, update all version references, update CHANGELOG, verify no broken references across the codebase. This is a release-prep phase, not a feature phase.

### 1.2 Why
Phases 0-4 delivered:
- Hook infrastructure (settings.json native, 3 hooks)
- Skill reduction (Alex 2528→570, Blake 1052→283)
- CLAUDE.md simplification (155→69)
- PreToolUse intelligent gating
- 76% context footprint reduction

All of this needs to be tagged as v2.7 with proper changelog and version references.

### 1.3 Intent

**不是要做的**:
- ❌ Not adding new features
- ❌ Not modifying hooks or skills (those are done)
- ❌ Not syncing to downstream projects (user will run *sync manually later)

---

## 2. Deliverables

### 2.1 Version Bump

Update version from 2.6.0 → 2.7.0 in:

| File | Field | Current | Target |
|------|-------|---------|--------|
| `.tad/config.yaml` | `version:` | 2.6.0 | 2.7.0 |
| `.tad/config.yaml` | `description:` | Update to mention Hook-Native Architecture |
| `.tad/version.txt` | Full content | 2.6 | 2.7 |
| `tad.sh` | `TARGET_VERSION` | 2.6 | 2.7 |
| CLAUDE.md | Any version refs | Check and update |
| Alex SKILL.md | `<!-- TAD v2.6.0 -->` comment | Update to v2.7.0 |
| Blake SKILL.md | Any version refs | Check and update |

**Verification**: `grep -r "2\.6" .tad/ CLAUDE.md .claude/skills/alex/ .claude/skills/blake/ tad.sh --include="*.md" --include="*.yaml" --include="*.txt" --include="*.sh" | grep -v archive | grep -v backup | grep -v spike`

### 2.2 CHANGELOG Entry

Add v2.7.0 entry to CHANGELOG.md:

```markdown
## v2.7.0 — Hook-Native Architecture Rebuild (2026-03-31)

### Breaking Changes
- `settings.json` rewritten to Claude Code native format (hooks + permissions)
- Alex SKILL.md reduced from 2528 to 570 lines (78% reduction)
- Blake SKILL.md reduced from 1052 to 283 lines (73% reduction)
- CLAUDE.md reduced from 155 to 69 lines (56% reduction)

### New Features
- **Hook Infrastructure**: SessionStart health check, PostToolUse workflow reminders
- **PreToolUse Prompt Hook**: Haiku-based intelligent gating for Write/Edit operations
- **Native Claude Code Integration**: settings.json uses Claude Code's hook system directly

### Architecture Changes
- 5-layer architecture: CLAUDE.md router → settings.json hooks → .tad/hooks/ scripts → Skills (judgment-only) → Config YAML
- Hook event keys confirmed PascalCase (PostToolUse, PreToolUse, SessionStart)
- additionalContext injects as `<system-reminder>` (system-level authority)
- Enforcement priority: permissions.deny > hooks > allow > user prompt

### Context Optimization
- Total context footprint reduced ~76% (59K → 14K tokens)
- Hook scripts execute externally (zero context cost)
- Skills contain only judgment logic (Socratic inquiry, intent routing, design decisions)

### Known Limitations
- `allowed-tools` frontmatter not enforced in Claude Code v2.1.88
- Per-skill hooks in frontmatter not implemented
- PreToolUse prompt hook adds ~2-5s latency per Write/Edit (Haiku round trip)
- `permissions.deny` only works at tool-name level (no path patterns)

### Migration Notes
- Old settings.json backed up as `.claude/settings.json.v2-backup`
- Hooks require `jq` installed (with grep fallback)
- TAD v2.7 should NOT use `bypassPermissions` mode (deny rules don't work in bypass)
```

### 2.3 config.yaml version_history

Add v2.7.0 entry to the `version_history:` section in `.tad/config.yaml`.

### 2.4 Reference Integrity Check

Run comprehensive grep to find any dangling references:
```bash
# Check for old version references
grep -rn "v2\.6\|2\.6\.0" . --include="*.md" --include="*.yaml" --include="*.sh" --include="*.txt" | grep -v archive | grep -v backup | grep -v spike | grep -v node_modules | grep -v .git

# Check for references to removed sections
grep -rn "tad-alex\.md\|tad-blake\.md" CLAUDE.md .claude/skills/

# Check for broken @import paths
grep "^@" CLAUDE.md
```

---

## 3. Implementation Steps

### Phase 1: Version Bump
1. Update all version references per table in 2.1
2. Run verification grep — fix any remaining v2.6 references

### Phase 2: CHANGELOG
1. Add v2.7.0 entry per template in 2.2
2. Add version_history entry to config.yaml

### Phase 3: Reference Integrity
1. Run all greps from 2.4
2. Fix any dangling references
3. Verify @imports resolve

### Phase 4: Final Verification
1. `wc -l` on all key files — confirm line counts match Phase 3/4 deliverables
2. `jq .` on settings.json — valid JSON
3. `bash -n .tad/hooks/*.sh` — syntax check all hook scripts
4. Read CLAUDE.md end-to-end — coherent?

---

## 4. Acceptance Criteria

- [ ] AC1: `.tad/config.yaml` version = 2.7.0
- [ ] AC2: `.tad/version.txt` = 2.7
- [ ] AC3: `tad.sh` TARGET_VERSION = 2.7
- [ ] AC4: No v2.6 references in active files (grep clean)
- [ ] AC5: CHANGELOG.md has v2.7.0 entry with all sections
- [ ] AC6: config.yaml version_history has v2.7.0 entry
- [ ] AC7: All @imports in CLAUDE.md resolve (no broken paths)
- [ ] AC8: settings.json validates with jq
- [ ] AC9: All hook scripts pass bash -n syntax check
- [ ] AC10: Alex SKILL.md still 570 lines, Blake still 283 lines (no unintended changes)

---

## 5. Important Notes

- ⚠️ **Do NOT run *sync or *publish** — user will do this manually after verifying in a fresh session
- ⚠️ **Do NOT modify hook scripts or skill files** — only version references and changelog
- ⚠️ **Check archive/ and spike/ dirs with grep but do NOT update them** — they're historical records

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-31
**Version**: 3.1.0
