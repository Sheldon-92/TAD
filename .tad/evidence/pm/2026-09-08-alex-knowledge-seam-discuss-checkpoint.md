# Alex Discuss Checkpoint — TAD Upstream Knowledge Seam & Isolation

**Date**: 2026-09-08  
**Agent**: Alex (Solution Lead, Terminal 1)  
**Mode**: `*discuss` / light research  
**Topic**: TAD Upstream Knowledge Seam & Downstream Isolation  
**Related Documents**:
- Design Note: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`
- Draft Handoff: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md`

---

## 1. Summary of Findings & Verified Facts

1. **Stale Brain-Index Across 5 Repos**:
   - Cause: `derive_framework_top_files()` in `tad.sh` and `derive-sync-set.sh` excluded only `sync-registry.yaml` via `TOP_DENY`.
   - Consequence: `.tad/brain-index.md` was copied verbatim to downstream projects with timestamp `2026-09-02 14:23`.
   - Flaw: `brain-index-gen.sh` terminates prematurely under `set -eo pipefail` when encountering older handoffs without `task_type:`.

2. **Project Knowledge "Fake Richness" in Business Repos**:
   - Cause: Downstream business projects (such as `买卖`) inherited 26/41 project knowledge files byte-identical to TAD framework internals (2026-05/06 incidents, 160KB `ac-verification.md` pattern).
   - Consequence: Downstream LLM context was flooded with irrelevant framework debugging logs, while actual business domain memory remained empty.

3. **Skill Demarcation**:
   - Framework skills in `.claude/skills/` and `.agents/skills/` are distributed by `tad.sh`.
   - Project-owned skills (`local/` and `ownership: project-owned`) must be strictly protected from `tad.sh` overwrite.

---

## 2. Recommended Action Paths

- **Path A (Core Isolation)**:
  - Add `brain-index.md` to `TOP_DENY` in `derive-sync-set.sh` and `tad.sh`.
  - Fix `brain-index-gen.sh` grep pipefail handling.
  - Wire non-blocking index refresh into post-distillation and maintenance checks.
- **Path B (Downstream Cleanliness)**:
  - Provide `quarantine-framework-pk.sh` to move identical upstream framework files into `.tad/archive/quarantine-framework-pk-<date>/`.
  - Update `tad.sh install` to only initialize `.tad/project-knowledge/README.md` (clean slate).
- **Path C (Soft Distillation Evidence)**:
  - Strictly maintain the principle "Knowledge is forged at distill, not captured".
  - Log distillation outcomes as advisory evidence blocks; never fail Gate 3 or Gate 4 if zero entries were distilled.

---

## 3. Status

- **Design Status**: Complete (`.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`).
- **Handoff Status**: Drafted (`status: NEEDS_HUMAN`) awaiting human confirmation before scheduling Blake implementation.
- **Implementation Status**: Zero implementation changes made in this session (per mandate).
