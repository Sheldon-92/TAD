# License Verification Evidence — Phase 4

**AC**: AC-G5 (BA-P0-3 license verification)
**Date**: 2026-04-25
**Verifier**: Blake (Terminal 2)

Phase 4 lifts content verbatim from two external open-source projects:
1. Anthropic skills/frontend-design (Anti-AI-Slop philosophy → P4.11.2)
2. Google Labs design.md (DESIGN.md spec format → P4.11.1)

Both repos must be Apache 2.0 (or compatible) for verbatim attribution to be legal.

---

## 1. anthropics/skills repo

**Repo URL**: https://github.com/anthropics/skills
**LICENSE file path**: https://github.com/anthropics/skills/blob/main/LICENSE
**License**: Apache License 2.0
**Verified by Alex**: 2026-04-25 via WebFetch of the repo README + LICENSE
**Source content lifted into Phase 4**:
- `https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md`
- Used in: `.tad/domains/web-ui-design.yaml` `visual_design.quality_criteria` (P4.11.2 — 2 positive criteria) + `visual_design.anti_patterns` (P4.11.2 — 6 anti-patterns)
- Attribution: inline YAML comments
  - `# Source: Anthropic skills/frontend-design/SKILL.md (Apache 2.0, retrieved 2026-04-25).`
  - `# P4.11.2 (2026-04-25): Anti-AI-Slop anti-patterns.`
  - `# Source: Anthropic skills/frontend-design/SKILL.md, Apache 2.0, retrieved 2026-04-25.`

**Commit SHA at retrieval time**: not pinned to a specific SHA in this evidence file (Alex retrieved via WebFetch which returned the live `main` branch state on 2026-04-25). For audit-grade traceability, future Phase 4 follow-up could clone the repo locally and pin the exact SHA. Acceptable as-is for the verbatim quote because Apache 2.0 attribution requirement is satisfied by the `Source: ...` comment.

**License compliance**: ✅ PASS
- Apache 2.0 permits redistribution + modification with attribution
- Verbatim lift with `Source:` comment satisfies the attribution requirement
- No NOTICE file exists in the source skill, so no additional NOTICE preservation needed
- Modifications (translation to Chinese for `Bold aesthetic direction committed`, etc.) are permitted under Apache 2.0 §4 (modifications)

---

## 2. google-labs-code/design.md repo

**Repo URL**: https://github.com/google-labs-code/design.md
**LICENSE file path**: https://github.com/google-labs-code/design.md/blob/main/LICENSE
**License**: Apache License 2.0
**Verified by Alex**: 2026-04-25 (per handoff §3 P4.11.1 references block, `license_verified: "Apache 2.0"`)
**Source content lifted into Phase 4**:
- DESIGN.md spec format (8 canonical sections, frontmatter token tree, quality_criteria reflecting spec rules)
- Used in: `.tad/domains/web-ui-design.yaml` new `design_system_documentation` capability (P4.11.1 — full capability ~80 lines)

**Spec version**:
- `version_pinned: "alpha as of 2026-04-21"` (per handoff §3 P4.11.1.references)
- `retrieved_by_alex: "2026-04-25"`
- Spec source: https://github.com/google-labs-code/design.md/blob/main/docs/spec.md

**Commit SHA at retrieval time**: not separately pinned in this evidence — same Apache 2.0 attribution rationale as #1 above. The spec version is alpha and explicitly flagged in the references block as expected to change; future readers can use the `retrieved_by_alex` date + the spec URL to reconstruct the state Phase 4 was based on.

**License compliance**: ✅ PASS
- Apache 2.0 permits use of the spec format for downstream tooling
- Pack capability documents Google Labs as the spec source via:
  - `.tad/domains/web-ui-design.yaml` references block
  - `description: "Google Labs DESIGN.md spec (Apache 2.0)"`
- The `name` field requirement, 8 canonical sections, token reference syntax, etc. are spec conventions — using them does not require a separate license grant

---

## Summary

| Repo | License | Verbatim Lift Allowed | Evidence Path |
|------|---------|-----------------------|---------------|
| anthropics/skills | Apache 2.0 | ✅ Yes (with attribution) | `web-ui-design.yaml` inline comments |
| google-labs-code/design.md | Apache 2.0 | ✅ Yes (with attribution) | `web-ui-design.yaml` references block |

**Verdict**: ✅ AC-G5 PASS — both source repos verified Apache 2.0; verbatim attribution requirements met via inline YAML comments + references block.

**Audit trail**:
- Alex 2026-04-25 WebFetch → handoff §3 references block carries `license_verified: "Apache 2.0"`
- Blake 2026-04-25 cross-checked the live LICENSE files via the repo URLs above
- Both repos remain Apache 2.0 as of this evidence file timestamp
