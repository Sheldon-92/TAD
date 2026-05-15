# Pair Testing Rules (4D Protocol)
<!-- capability: pair_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| T1 | 3-5 critical user flows only (5-15 tests per app) | Selecting E2E scope |
| T2 | Human validates UX/cognitive; agent validates structure/regression | Dividing testing roles |
| T3 | Round-by-round 4D Protocol: Discover-Discuss-Decide-Deliver | Running pair test sessions |
| T4 | Decisions in-session, not deferred | Handling findings |
| T5 | Screenshot evidence for every finding | Documenting issues |
| T6 | Severity rated by human, not AI alone | Classifying bugs |
| T7 | Fix-now decisions generate immediate handoffs | Acting on findings |
| T8 | Session report with per-round detail | Closing pair test sessions |

---

## Rules

### T1: E2E Scope -- 3-5 Critical Flows

When selecting what to cover in pair testing or E2E automation:

- **3-5 critical user flows per application** -- not every possible path
- These are flows where failure means revenue loss, user churn, or data corruption
- Typical critical flows: signup/login, core action (create/purchase/submit), payment, data export
- **5-15 E2E tests per app** is the target count for the thin top of the testing pyramid

**Anti-pattern**: 50+ E2E tests covering edge cases. Those belong in unit/integration tests. E2E tests the happy path of critical flows.

### T2: Human vs Agent Testing Roles

When dividing work in pair testing:

| Role | Human | Agent |
|------|-------|-------|
| **UX judgment** | "This flow feels confusing" | Cannot assess cognitive load |
| **Visual aesthetics** | "This spacing looks wrong" | Can screenshot + measure but not judge beauty |
| **Business context** | "Users won't understand this label" | No domain expertise |
| **Structural checks** | Slower, error-prone | Systematic: DOM structure, missing elements |
| **Regression detection** | Misses subtle changes | Screenshot comparison, automated assertions |
| **Edge cases** | Knows which matter | Can generate many, doesn't know which matter |
| **Accessibility** | Keyboard + screen reader feel | axe-core automated scanning |

**Rule**: Human guides WHAT to test and judges severity. Agent executes systematically and provides evidence.

### T3: 4D Protocol Execution

When running a pair testing session, follow the 4D Protocol:

**Round structure** (repeat 3-10 rounds per session):

1. **Discover**: Agent navigates to the target page/state. Takes screenshots. Reports observations: layout issues, missing elements, broken interactions, edge cases.
   ```bash
   # Agent takes full-page screenshot
   npx playwright screenshot https://app.example.com/dashboard --full-page
   ```

2. **Discuss**: Human and agent discuss each finding. Human provides context ("that's intentional" or "that's a bug"). Agent provides technical analysis ("the z-index causes overlap").

3. **Decide**: For each finding, decide NOW:
   - **Fix now** -- create immediate task/handoff
   - **Fix later** -- add to backlog with priority (P0/P1/P2)
   - **Won't fix** -- document reasoning ("intentional design", "low impact")
   
4. **Deliver**: Record the round's findings, decisions, and evidence in the session log.

**Key advantage**: 1M context window means Round 10 still has Round 1's full details. No information loss across rounds.

### T4: In-Session Decisions

When handling findings during pair testing:

- **Decide during the session**, not after in a separate triage meeting
- Context richness at discovery time is highest -- the screenshot, the state, the reproduction steps are all live
- Deferring decisions means losing context and re-investigating later
- "We'll triage later" is the pair testing equivalent of "we'll add tests later"

**Exception**: Findings that require stakeholder input beyond the human tester's authority. Document the decision as "needs-stakeholder" with a clear question.

### T5: Screenshot Evidence

When documenting findings:

- Every finding MUST have a screenshot showing the issue
- Full-page screenshots for layout issues; element screenshots for specific bugs
- Before/after screenshots for regression findings
- Screenshots are stored in the session directory, referenced from the report

```bash
# Full page
npx playwright screenshot URL --full-page -o finding-001.png

# Specific viewport
npx playwright screenshot URL --viewport-size=375,812 -o finding-001-mobile.png
```

**Anti-pattern**: "The button is misaligned" without a screenshot. No evidence = no finding.

### T6: Human Severity Rating

When classifying bug severity:

- **Human rates severity**, not the agent alone
- Agent can suggest based on technical impact, but human judges user impact
- "This feels wrong" from the human is valid input -- it often catches issues automation misses

| Severity | Criteria | Response |
|----------|----------|----------|
| Critical | Blocks core flow, data loss risk | Fix immediately |
| Major | Significant UX degradation, wrong behavior | Fix before release |
| Minor | Cosmetic, non-blocking, edge case | Fix in next sprint |
| Cosmetic | Visual polish, nice-to-have | Backlog |

### T7: Fix-Now Handoffs

When a finding is decided as "fix now":

- Generate an immediate handoff or task with:
  - Screenshot evidence
  - Reproduction steps
  - Expected vs actual behavior
  - Suggested fix (if agent can identify the code)
- Do NOT batch fix-now items for "later" -- the whole point is immediate action with full context

### T8: Session Report

When closing a pair testing session:

```markdown
## Pair Testing Session Report

**Date**: YYYY-MM-DD
**Application**: [name + URL]
**Rounds completed**: N
**Findings**: X total (Y critical, Z major)

### Round 1: [focus area]
- **Finding**: [description]
- **Evidence**: [screenshot path]
- **Severity**: [human-rated]
- **Decision**: [fix now / fix later / won't fix]

### Round 2: [focus area]
...

### Summary
- Fix now: N items (handoffs generated)
- Fix later: N items (backlog)
- Won't fix: N items (documented)
- Discovery rate: X findings/round
```

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| AI decides severity | Missing user context, over/under-rates | Human rates, agent suggests |
| Defer all decisions | Loses context, doubles work | Decide in-session (4D Protocol) |
| No screenshots | No evidence, no reproduction | Screenshot every finding |
| Test without focus areas | Aimless exploration, low coverage | Human picks 3-5 focus areas upfront |
| 50+ E2E tests | Ice cream cone, slow, brittle | 3-5 critical flows, 5-15 tests |
| Ignoring "this feels wrong" | Human intuition catches real bugs | Treat human intuition as valid signal |
