# CLAUDE.md Routing Label Conflicts

**Date:** 2026-05-05
**Linked to:** L2 shell-portability "Hook Shell Portability Rules"

---

### CLAUDE.md Routing Label Conflicts - 2026-05-05
- **Discovery**: When a CLAUDE.md routing table row uses keyword X AND an associated note uses X as label prefix, grep-c X returns 2 instead of 1. Fix: relabel notes to NOT share the routing keyword.
- **Action**: Use unique label prefixes for exclusion/annotation lines. Dry-run grep ACs on proposed text.
