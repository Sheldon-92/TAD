# AC grep-count for reference-based pack files

**Date:** 2026-05-27
**Linked to:** L2 ac-verification "Alex Handoff AC Design Rules"

---

### AC grep-count for reference-based pack files - 2026-05-27
- **Context**: Upgrading video-creation pack with vimax-patterns.md. Alex wrote AC8/AC13 as `grep -c 'vimax-patterns.md' SKILL.md` expecting `= 1`.
- **Discovery**: Reference filenames in reference-based capability packs naturally appear in 2 locations: (1) Context Detection table row, (2) Quick Rule Index section heading. All existing references follow this pattern (storytelling.md, audio-design.md, etc.). ACs using `grep -c 'filename'` should expect `= 2`, not `= 1`.
- **Action**: When writing ACs for pack reference additions, use `grep -c 'filename' SKILL.md` with expected `= 2` (or `≥ 1` if only checking existence). Dry-run the grep against an existing reference filename to confirm the expected count before shipping handoff.
