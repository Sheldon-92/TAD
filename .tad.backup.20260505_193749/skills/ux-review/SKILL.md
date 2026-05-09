---
name: "UX Review"
id: "ux-review"
version: "1.0"
claude_subagent: "ux-expert-reviewer"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# UX Review Skill

## Purpose
Review user interface implementations for usability, accessibility, visual consistency, and user experience best practices.

## When to Use
- After implementing UI components
- During Gate 2 (design review)
- During Gate 4 (acceptance verification)
- For user-facing feature changes
- When accessibility is important

## Checklist

### Critical (P0) - Must Pass
- [ ] Core user flow is functional and intuitive
- [ ] No broken interactive elements
- [ ] Critical actions are clearly visible
- [ ] Error states provide clear feedback
- [ ] No accessibility blockers (keyboard navigation works)

### Important (P1) - Should Pass
- [ ] Consistent visual design (colors, spacing, typography)
- [ ] Loading states provide feedback
- [ ] Form validation is clear and helpful
- [ ] Responsive design works on target devices
- [ ] ARIA labels on interactive elements

### Nice-to-have (P2) - Informational
- [ ] Animations enhance (don't distract from) UX
- [ ] Empty states are well-designed
- [ ] Micro-interactions provide delight
- [ ] Performance feels snappy
- [ ] Dark mode/theme support consistent

### Suggestions (P3) - Optional
- [ ] A/B testing considerations
- [ ] Analytics instrumentation
- [ ] User research opportunities
- [ ] Future enhancement ideas

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 2 failures |
| P2 | Informational |
| P3 | Optional |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-ux-review-{task}.md`

## Execution Contract
- **Input**: file_paths[], screenshots[], context{}
- **Output**: {passed: bool, findings: [{severity, category, component, description, recommendation}], evidence_path: string}
- **Timeout**: 180s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `ux-expert-reviewer` for deeper analysis.
Reference: `.tad/templates/output-formats/ui-review-format.md`

## UX Review Categories

### Usability
- User flow clarity
- Task completion ease
- Error prevention
- Learnability
- Efficiency

### Visual Design
- Color consistency
- Typography hierarchy
- Spacing and alignment
- Visual feedback
- Brand consistency

### Accessibility (WCAG 2.1)
- Keyboard navigation
- Screen reader compatibility
- Color contrast
- Focus indicators
- Alt text for images

### Interaction Design
- Feedback on actions
- Loading indicators
- Transition smoothness
- Gesture support (mobile)
- Undo/redo support

### Responsive Design
- Mobile breakpoints
- Touch targets (48px min)
- Orientation handling
- Content reflow
- Image optimization
