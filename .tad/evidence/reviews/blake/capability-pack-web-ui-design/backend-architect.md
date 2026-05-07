# Backend/Architecture Review
**Task**: HANDOFF-20260507-capability-pack-web-ui-design
**Reviewer**: backend-architect (sub-agent)
**Date**: 2026-05-07

## Initial Findings (Pre-Fix)

- P0-1: CAPABILITY.md missing YAML frontmatter — Claude Code skill loader requires `name` + `description` fields; pack would silently fail to register despite "Installation complete" message
- P1-1: install.sh doesn't copy LICENSE or LICENSE-ATTRIBUTION.md — Apache 2.0 attribution requirements for Anthropic frontend-design SKILL content not met post-install
- P1-2: Phase 3 interfaces (Codex/Cursor/Gemini) "reserved" in §11 Decision #6 but install.sh has zero abstraction — Phase 3 would require full install.sh restructure not "adding cases"
- P1-3: Unbound SKILL_DIR when .claude/ missing + DRY_RUN=true → misleading `/skills/web-ui-design/` paths
- P1-4: starter-tokens.json primitive layer is flat bag mixing color/font/spacing/radius — contradicts claim of 3-level architecture; not compatible with Style Dictionary sub-grouping convention
- P2-1 through P2-5: Advisory items (anti-slop rule contradiction, CSS output order, awk edge case for last capability, unverified GitHub URLs)

## Resolutions Applied

| Finding | Resolution | Status |
|---------|-----------|--------|
| P0-1 | Added YAML frontmatter with `name: web-ui-design` + description to CAPABILITY.md | ✅ Fixed |
| P1-1 | Added LICENSE + LICENSE-ATTRIBUTION.md to install.sh COPY_PAIRS | ✅ Fixed |
| P1-2 | Added `--agent=claude|codex|cursor|gemini` flag with Phase 3 stubs (exit 2 with informative message) | ✅ Fixed |
| P1-3 | Combined fix with CR-P1-1: exit unconditional when no .claude/ found | ✅ Fixed |
| P1-4 | Added inline documentation note in CAPABILITY.md C3 Step 1 explaining flat primitive design choice + Style Dictionary compatibility guidance | ✅ Fixed (documented) |

## Post-Fix Verdict: PASS (P0=0)
