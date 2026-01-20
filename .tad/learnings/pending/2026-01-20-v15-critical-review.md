# TAD v1.5 Critical Review - Pending Validation

**Date**: 2026-01-20
**Reviewer**: Claude (at user's request)
**Purpose**: Record critical opinions on v1.5 improvements for future validation
**Validation Timeline**: 2-4 weeks of usage, then review

---

## Summary

User implemented extensive TAD improvements in menu-snap project. These improvements were adopted into TAD v1.5. This document records concerns that should be validated after real-world usage.

---

## Concerns to Validate

### 1. Gate 3/4 Mandatory Subagent Calls

**Current Implementation**:
- Gate 3 requires: test-runner subagent
- Gate 4 requires: security-auditor, performance-optimizer, code-reviewer (+ ux-expert if UI)

**Concern**:
- Each Gate 4 execution requires 3-4 subagent calls
- Significant token consumption and time cost
- May be skipped in practice due to overhead

**Validation Criteria**:
- [ ] Track how often Gate 4 is fully executed vs skipped
- [ ] Measure time/token cost per Gate 4 execution
- [ ] Assess quality of generated evidence files

**Prediction**: Gate 4 will be frequently skipped or simplified in practice.

---

### 2. Skills Reading Rule Before Subagent Calls

**Current Implementation**:
- Must read corresponding Skill file before calling any subagent

**Concern**:
- Claude Code subagents have built-in personas and tools
- Skill files in `.claude/skills/` are separate knowledge bases
- Forcing read before call creates confusion and extra steps

**Validation Criteria**:
- [ ] Track if LLM actually reads Skill files before subagent calls
- [ ] Assess if Skill content conflicts with subagent behavior
- [ ] Measure if this improves or hinders subagent effectiveness

**Prediction**: This rule will cause confusion and be inconsistently applied.

---

### 3. Evidence File Storage System

**Current Implementation**:
- All subagent outputs saved to `.tad/evidence/reviews/`
- Gate checks file existence before passing
- 12+ template types defined

**Concern**:
- File system will grow rapidly (4-6 files per task)
- Template maintenance burden
- Blocking on file existence may cause frustration

**Validation Criteria**:
- [ ] Count evidence files after 10 tasks
- [ ] Assess quality/usefulness of stored evidence
- [ ] Track how often missing evidence blocks Gates

**Prediction**: Evidence directory will become cluttered; most files never re-read.

---

### 4. Mandatory Knowledge Capture at Every Gate

**Current Implementation**:
- Gate 3/4 post-pass actions include "evaluate if worth recording"
- Write to `.tad/project-knowledge/{category}.md`

**Concern**:
- "Every Gate" evaluation may lead to low-quality "checkbox" entries
- Overlap with `.tad/learnings/` system
- Stale knowledge accumulation over time

**Validation Criteria**:
- [ ] Review knowledge entries after 10 tasks - how many are useful?
- [ ] Track if knowledge is ever re-read/referenced
- [ ] Compare quality of forced vs voluntary entries

**Prediction**: Many entries will be low-value; voluntary capture would be higher quality.

---

### 5. *accept Command Complexity

**Current Implementation**:
- Archive handoff + completion report
- Update PROJECT_CONTEXT.md
- Update NEXT.md
- Multiple subagent calls for verification

**Concern**:
- Too many steps for small tasks
- No "light mode" for minor implementations
- May discourage proper closure

**Validation Criteria**:
- [ ] Track *accept completion rate
- [ ] Measure time to complete *accept
- [ ] Assess if users skip to avoid overhead

**Prediction**: Users will often skip *accept or do it incompletely.

---

## Recommended Future Actions

If validation confirms these concerns:

1. **Gate 4 Subagents**: Change to conditional triggers (only call security-auditor if auth/data involved)

2. **Skills Rule**: Remove mandatory reading; keep Skills as reference knowledge only

3. **Evidence Storage**: Change to "recommended but not blocking"; archive older files automatically

4. **Knowledge Capture**: Change to "notable discoveries only" rather than every Gate

5. **Accept Command**: Add `*accept --light` option for minor tasks

---

## Validation Schedule

- **Week 2**: Quick check on Gate compliance rates
- **Week 4**: Full review of all concerns above
- **Week 8**: Decision on v1.6 simplifications

---

## Notes

This is not a criticism of the improvements - they reflect careful engineering thinking. The question is whether the overhead is proportionate to the value in practice. Real-world usage will provide the answer.

User explicitly chose to "try it first, validate later" - this is a reasonable empirical approach.
