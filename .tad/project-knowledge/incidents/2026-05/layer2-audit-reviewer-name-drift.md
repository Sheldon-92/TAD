# Layer 2 Audit Canonical Reviewer Name Drift

**Date:** 2026-05-27
**Linked to:** L2 gate-design "Gate 4 Verification Integrity"

---

### Layer 2 Audit Canonical Reviewer Name Drift - 2026-05-27
- **Context**: Gate 4 ran `layer2-audit.sh vimax-pattern-upgrade-video-creation`. Audit script returned exit 0 (PASS) with `DISTINCT_COUNT=0` and WARN: "unknown reviewer name(s) — add to KNOWN_REVIEWERS in layer2-audit.sh if legitimate: spec-compliance-review code-review architecture-review".
- **Discovery**: Blake's Layer 2 review files use suffix `-review.md` (spec-compliance-review.md, code-review.md, architecture-review.md). The audit script's KNOWN_REVIEWERS list expects canonical names like `code-reviewer.md` / `backend-architect.md` / `security-auditor.md` (matching Claude Code sub-agent type names). When pack upgrade handoffs use the "domain-task-review" naming convention, the audit's distinct-count gate (Tier 1 requires ≥2 distinct reviewers) computes 0 and would WARN but for the file-count fallback.
- **Action**: Two options: (a) standardize Blake review file names to canonical sub-agent type names (code-reviewer.md, backend-architect.md, security-auditor.md, etc.) so audit script recognizes them; (b) extend KNOWN_REVIEWERS list in layer2-audit.sh to include "-review" suffix patterns for pack upgrade work. Prefer (a) — keeps audit script generic; Blake should match review filename to sub-agent type, not to handoff theme.
- **Grounded in**: .tad/hooks/lib/layer2-audit.sh, .tad/evidence/reviews/blake/vimax-pattern-upgrade-video-creation/
