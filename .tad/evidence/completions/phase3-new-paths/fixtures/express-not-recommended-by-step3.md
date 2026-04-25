# Fixture: Step3 must NEVER pre-select *express as Recommended (P3.1 AC-P3.1-j, BA-P1-2)
# Purpose: Letter-not-spirit defense against AR-001 — Alex auto-downgrading scope to express.

# Scenario:
#   User input (ambiguous text, NOT explicit *express command):
#     "fix small thing in the navbar"
#
#   Signal-word detection of "fix" + "small" + "thing" leans toward *express
#   (small + fix-like vocabulary).

# Expected Alex behavior:
#   step3 must NOT show *express as Option 1 (Recommended).
#   Even though signal score for express is highest, step3 7-mode display strategy
#   classifies as analyze with note:
#     "looks small — start *analyze; user can downgrade by typing *express"

# Expected step3 AskUserQuestion options (4-option layout):
#   Option 1: analyze (Recommended)  ← NOT express
#     "Standard TAD with Socratic — small scope can be confirmed in step1; if truly trivial, you can type *express to downgrade"
#   Option 2: bug
#     "If this is a defect rather than a tweak"
#   Option 3: discuss
#     "If you want to think before deciding scope"
#   Option 4: analyze (always 4th when not Recommended)
#     [if Recommended is analyze, Options 2-4 are alt modes]

# Negative case (failure mode):
#   If Alex shows Option 1 = "express (Recommended)" → AC-P3.1-j FAIL
#   If Alex shows Option 1 = anything BUT express → AC-P3.1-j PASS

# Verification:
#   Read .claude/skills/alex/SKILL.md → intent_router_protocol step3
#   Confirm "*express MUST NOT appear as Option 1" rule is present in the EXCEPTION block.

# Reference: express_path_protocol.trigger.NOT_via_alex_suggestion (rule b)
