# Fixture: Override marker MALFORMED — 4 negative cases (P3.3 AC-P3.3-h)
# Purpose: Demonstrate variations that Alex grep MUST NOT match.
# Each case shows a real failure mode and why it fails the strict format.

# ═══════════════════════════════════════════════════════
# CASE 1: marker NOT in "## Knowledge Assessment" section
# ═══════════════════════════════════════════════════════

# COMPLETION-20260424-bad-1.md

## Some Other Section

**knowledge_assessment_override: unskip — reason: misplaced marker**

## Knowledge Assessment

(empty — no marker here)

# Failure reason:
#   Even though grep `^\*\*knowledge_assessment_override:\s*unskip` MATCHES the line literally,
#   Alex acceptance_protocol.step7.pre_check.action step 2 says:
#     "Locate '## Knowledge Assessment' section header. Grep for override marker on the
#      FIRST non-blank line under that header"
#   The marker outside that section is IGNORED by Alex's locating logic.

# ═══════════════════════════════════════════════════════
# CASE 2: missing bold markdown (no `**`)
# ═══════════════════════════════════════════════════════

# COMPLETION-20260424-bad-2.md

## Knowledge Assessment

knowledge_assessment_override: unskip — reason: missing bold markers

# Failure reason:
#   Pattern `^\*\*knowledge_assessment_override` requires literal `**` at line start.
#   Plain text without `**` does NOT match. Format spec says "must be exactly: bold markdown".

# ═══════════════════════════════════════════════════════
# CASE 3: leading whitespace before `**`
# ═══════════════════════════════════════════════════════

# COMPLETION-20260424-bad-3.md

## Knowledge Assessment

   **knowledge_assessment_override: unskip — reason: leading spaces**

# Failure reason:
#   Pattern is line-anchored (`^\*\*`). Spaces before `**` make this NOT a line-start match.
#   Format spec says "no leading whitespace permitted".

# ═══════════════════════════════════════════════════════
# CASE 4: missing reason text (no "— reason:" suffix)
# ═══════════════════════════════════════════════════════

# COMPLETION-20260424-bad-4.md

## Knowledge Assessment

**knowledge_assessment_override: unskip**

# Failure reason:
#   The pattern as currently written `^\*\*knowledge_assessment_override:\s*unskip`
#   technically matches this prefix. However, the FORMAT SPEC mandates "One-sentence
#   reason after `— reason:`". An override without reason is a format violation that
#   step7's reason extraction handles by:
#     - extracting "(reason missing)" placeholder
#     - emitting WARN in acceptance_report: "Override marker found but reason missing —
#       Blake should re-add reason; treating as override anyway for safety net behavior"
#   Behavior: counts as override (safety net trumps format pedantry) but generates warning.
#   This is a MILD failure — still triggers branch_2 routing, but log shows the issue.

# ═══════════════════════════════════════════════════════
# Summary table
# ═══════════════════════════════════════════════════════
# | Case | grep matches? | Alex routing                           | Verdict     |
# |------|---------------|----------------------------------------|-------------|
# | 1    | yes (literal) | branch_1 (locator says no marker here) | ignored     |
# | 2    | NO            | branch_1                               | ignored     |
# | 3    | NO            | branch_1                               | ignored     |
# | 4    | yes           | branch_2 with WARN                     | accepted+warn |
