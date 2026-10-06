# Section 9.1 Region Marker is ### 9.1 (3-hash), NOT ## 9.1

**Date:** 2026-05-31
**Linked to:** L2 ac-verification "AC Verification Drift Pattern"

---

### §9.1 Region Marker is `### 9.1` (3-hash subsection), NOT `## 9.1` — 2026-05-31
- **Context**: P4 verify-ac-commands.sh linter. Spec text said "extract the §9.1 region from `## 9.1` to the next `## `". Built the awk that way; the self-dogfood (AC4.6) on the archived vimax handoff returned 0 findings — missing the very `grep -ocE` AC15 bug it was designed to catch.
- **Discovery**: Real TAD handoffs mark §9.1 as `### 9.1 Spec Compliance Checklist` (THREE hashes — a subsection nested under `## 9. Acceptance Criteria`), and §9.1 ends at the next `### 9.2` (also 3-hash) or the next `## 10`. A `^## *9\.1` matcher finds NOTHING because the top-level §9 heading is `## 9. Acceptance Criteria`, with `9.1` only ever appearing at `### ` depth. The spec's `## 9.1` was an abbreviation, not the literal on-disk format. A linter/parser keyed to the wrong heading depth silently scans an empty region and reports clean — a false-negative that looks like success.
- **Action**: When extracting a numbered sub-section region (§N.M) from a TAD handoff, match `^#{2,} *N\.M([^0-9]|$)` (any heading depth ≥2) and terminate at the next `^#{2,} ` heading — do NOT hard-code `## N.M`. ALWAYS validate region-extraction by dogfooding on a real artifact known to contain the target pattern; "0 findings" on a fixture that should fire is the tell for a wrong-depth region matcher.
- **Grounded in**: .tad/hooks/lib/verify-ac-commands.sh:46-50, .tad/archive/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md:533 (`### 9.1`), COMPLETION-20260531-tad-lean-trustworthy-phase4.md AC4.6
