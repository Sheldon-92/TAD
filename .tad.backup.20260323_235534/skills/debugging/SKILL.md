---
name: "Debugging"
id: "debugging"
version: "1.0"
claude_subagent: "debugging-assistant"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# Debugging Skill

## Purpose
Systematically diagnose and fix bugs, errors, and unexpected behavior in code through structured analysis.

## When to Use
- During Gate 3 (implementation quality)
- When encountering runtime errors
- When tests fail unexpectedly
- For logic error investigation
- For performance issue root cause analysis

## Checklist

### Critical (P0) - Must Pass
- [ ] Root cause identified (not just symptoms)
- [ ] Fix addresses root cause
- [ ] No regression introduced
- [ ] Error no longer reproducible
- [ ] Related code paths checked

### Important (P1) - Should Pass
- [ ] Test added to prevent regression
- [ ] Error handling improved
- [ ] Logging added for future debugging
- [ ] Documentation updated if behavior changed
- [ ] Similar patterns checked elsewhere

### Nice-to-have (P2) - Informational
- [ ] Debug notes documented
- [ ] Monitoring/alerts added
- [ ] Performance impact assessed
- [ ] Related improvements identified
- [ ] Knowledge shared with team

### Suggestions (P3) - Optional
- [ ] Automated prevention possible
- [ ] Tool/process improvement ideas
- [ ] Training opportunity identified
- [ ] Architecture improvement suggested

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 1 failure |
| P2 | Informational |
| P3 | Optional |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-debugging-{task}.md`

## Execution Contract
- **Input**: error_description, stack_trace, file_paths[], context{}
- **Output**: {passed: bool, root_cause: string, fix_applied: bool, evidence_path: string}
- **Timeout**: 300s
- **Parallelizable**: false

## Claude Enhancement
When running on Claude Code, call subagent `debugging-assistant` for deeper analysis.
Reference: `.tad/templates/output-formats/debugging-format.md`

## Debugging Process

### 1. Reproduce
- [ ] Error consistently reproducible
- [ ] Minimal reproduction case identified
- [ ] Environment factors documented
- [ ] Trigger conditions understood

### 2. Isolate
- [ ] Scope narrowed to specific module
- [ ] Related components ruled out
- [ ] Data dependencies identified
- [ ] Timing/order dependencies checked

### 3. Analyze
- [ ] Stack trace examined
- [ ] Logs reviewed
- [ ] State inspection performed
- [ ] Hypothesis formed

### 4. Fix
- [ ] Root cause addressed
- [ ] Minimal change principle followed
- [ ] Side effects considered
- [ ] Rollback plan available

### 5. Verify
- [ ] Original error resolved
- [ ] No new errors introduced
- [ ] Edge cases tested
- [ ] Performance acceptable

### 6. Document
- [ ] Fix documented
- [ ] Lessons learned captured
- [ ] Prevention measures identified
- [ ] Knowledge shared
