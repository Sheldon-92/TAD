# UX Research Review Format

> Extracted from ux-research skill - use this for UX research planning and reporting

## Quick Checklist

```
1. [ ] Research goal clear; method matches (qualitative/quantitative)
2. [ ] Sample and bias control; informed consent
3. [ ] Templated materials: interview guide/survey/task script
4. [ ] Recording and synthesis: transcripts/usability issue list
5. [ ] Deliverables: research plan/interview notes/insights report
```

## Red Flags

- Method doesn't match research goal
- Sample bias (e.g., only power users)
- No task script for usability testing
- Only anecdotal evidence
- Leading questions in interviews
- Conclusions not supported by data

## Output Format

### Research Plan

| Field | Content |
|-------|---------|
| Research Goal | [one sentence] |
| Research Questions | [list] |
| Method | Interview / Usability Test / Survey / A-B Test |
| Participants | [count] [criteria] |
| Timeline | [dates] |

### Interview Question Quality

| Question | Type | Issue |
|----------|------|-------|
| [question] | Open/Closed/Leading | Good / Needs revision |

Good questions:
- Open-ended
- Neutral, non-leading
- Focus on specific behaviors
- One question at a time

### Usability Test Summary

| Task | Success Rate | Avg Time | Common Issues |
|------|--------------|----------|---------------|
| [task 1] | X/Y (Z%) | Xs | [issues] |
| [task 2] | X/Y (Z%) | Xs | [issues] |

### Nielsen Heuristics Evaluation

| # | Heuristic | Status | Issues Found |
|---|-----------|--------|--------------|
| 1 | Visibility of system status | Pass/Fail | [issues] |
| 2 | Match between system and real world | Pass/Fail | [issues] |
| 3 | User control and freedom | Pass/Fail | [issues] |
| 4 | Consistency and standards | Pass/Fail | [issues] |
| 5 | Error prevention | Pass/Fail | [issues] |
| 6 | Recognition rather than recall | Pass/Fail | [issues] |
| 7 | Flexibility and efficiency | Pass/Fail | [issues] |
| 8 | Aesthetic and minimalist design | Pass/Fail | [issues] |
| 9 | Help users recognize/recover from errors | Pass/Fail | [issues] |
| 10 | Help and documentation | Pass/Fail | [issues] |

### Severity Rating

| Level | Description |
|-------|-------------|
| 0 | Not a usability problem |
| 1 | Cosmetic - low priority |
| 2 | Minor - should fix |
| 3 | Major - must fix |
| 4 | Catastrophic - fix immediately |

### Research Findings Summary

| Finding | Evidence | Impact | Affected Users |
|---------|----------|--------|----------------|
| [finding 1] | [quotes/data] | High/Med/Low | X% |
| [finding 2] | [quotes/data] | High/Med/Low | X% |

### User Persona Template

```markdown
## Persona: [Name]

**Demographics**: [age, occupation, location]
**Goals**: [primary and secondary goals]
**Pain Points**: [frustrations]
**Behaviors**: [usage patterns]
**Quote**: "[representative quote from research]"
```

### A/B Test Results

| Metric | Control (A) | Variant (B) | Change | Significant? |
|--------|-------------|-------------|--------|--------------|
| [primary metric] | X.X% | X.X% | +X.X% | p < 0.05 ✓ |
| [secondary metric] | X.X% | X.X% | +X.X% | p > 0.05 ✗ |

**Recommendation**: Ship / Hold / Iterate

### Actionable Recommendations

| Priority | Recommendation | Based On | Expected Impact |
|----------|----------------|----------|-----------------|
| P0 | [recommendation] | Finding 1 | [impact] |
| P1 | [recommendation] | Finding 2 | [impact] |
| P2 | [recommendation] | Finding 3 | [impact] |
