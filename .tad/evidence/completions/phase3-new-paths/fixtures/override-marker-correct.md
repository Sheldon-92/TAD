# Fixture: Override marker CORRECT format (P3.3 AC-P3.3-h positive case)
# Purpose: Demonstrate the exact override marker format that Alex grep MUST match.

# This is a sample Blake completion report with skip_KA=yes handoff but
# implementation surfaced reusable knowledge — Blake overrides unskip.

---

# COMPLETION-20260424-toast-typo-fix

(Blake's normal completion report content here…)

## ✅ Implementation Complete

(report sections…)

## Knowledge Assessment

**knowledge_assessment_override: unskip — reason: bug fix surfaced reusable React Toast SDK type-cast pattern reproducible across 3 projects**

### React Toast SDK shape cast - 2026-04-24
- **Context**: Trivial typo fix in WelcomeBanner.tsx
- **Discovery**: While editing the file, noticed Toast<T> generic API has a hidden
  type-cast quirk where T must extend Record<string, unknown> not just `object`
- **Action**: Codify in TypeScript best-practices doc

# Verification:
#   Alex grep pattern: ^\*\*knowledge_assessment_override:\s*unskip
#   Should match the bold line under "## Knowledge Assessment" exactly.
#
#   $ grep -E '^\*\*knowledge_assessment_override:\s*unskip' override-marker-correct.md
#   **knowledge_assessment_override: unskip — reason: bug fix surfaced reusable React Toast SDK type-cast pattern reproducible across 3 projects**
#   ↑ exit 0, marker matched

# Expected Alex step7 routing:
#   skip_KA=yes from frontmatter (assumed)
#   AND override marker matched
#   → branch_2_skip_with_override
#   → A_verify_blake_claims=REQUIRED, B_raw_tsv=REQUIRED, C_alex_own=REQUIRED
#   → acceptance_report: "⚠️ Knowledge Assessment EXECUTED despite skip flag — Blake override..."
