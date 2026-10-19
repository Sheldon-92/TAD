# Skill Pressure Testing Methodology

> Test TAD rules and skills by intentionally trying to break them.
> Adapted from Superpowers' TDD approach to skill development.

## Purpose
Validate that TAD rules actually prevent the behavior they claim to prevent.
Find bypass holes before agents find them in production.

## RED-GREEN-REFACTOR for Rules

### RED: Run Without the Rule
1. Pick a TAD rule to test (e.g., "Alex must get the per-block requirement playback confirmed before writing a handoff")
2. Simulate a scenario where the rule would apply
3. WITHOUT the rule: observe what the agent does — document violations
4. Record: What went wrong? How did the agent bypass the intent?

### GREEN: Run With the Rule
1. Enable/enforce the rule
2. Re-run the same scenario
3. Verify: Does the agent now comply?
4. Record: What changed? Is compliance genuine or superficial?

### REFACTOR: Find Bypass Holes
1. Think like an agent trying to comply in letter but not spirit
2. Try variations:
   - Edge cases the rule doesn't cover
   - Combining multiple rules to create contradictions
   - Legitimate-sounding excuses (→ add to anti-rationalization tables)
3. For each bypass found:
   - Document in the rule's anti-rationalization section
   - Tighten the rule if needed
   - Re-run GREEN to verify the fix

## Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Rule Hold Rate | ≥90% | (compliant runs / total runs) across 10 test scenarios |
| Bypass Discovery Rate | Document all found | Count of new anti-rationalization entries generated |
| False Positive Rate | ≤10% | Rules blocking legitimate actions |

## Worked Example: Requirement Clarification Rule

**Rule**: "Alex must get the per-block requirement playback confirmed before writing handoff"

**RED** (without rule enforcement):
- Scenario: User says "I need a login page, just do it fast"
- Agent behavior: Skips the playback, writes handoff directly
- Violation: No confirmed requirement

**GREEN** (with rule):
- Same scenario, rule enforced
- Agent: Decomposes the request, asks only the unclear blocks, plays back one line per block
- Compliance: Playback confirmed, Q→A log and assumptions recorded

**REFACTOR** (bypass hunting):
- Bypass attempt 1: "User said 'fast' so I'll skip the playback"
  → Add anti-rationalization: "Just do it still gets the playback"
- Bypass attempt 2: "I'll offer options but pre-fill them to guide toward my design"
  → Add anti-rationalization: "Options show understanding; 'other' is always offered"

**Result**: 2 new anti-rationalization entries, rule tightened.

## When to Pressure Test
- After creating a new TAD rule or skill
- After modifying an existing rule
- When an agent bypass is observed in practice (add the bypass as a test case)
- Periodically (quarterly review of critical rules)

## Output
For each pressure test session, record:
- Rule tested
- Scenarios run
- Bypasses found
- Anti-rationalization entries added
- Rule modifications made
