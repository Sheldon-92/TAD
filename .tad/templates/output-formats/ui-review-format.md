# UI Review Output Format

> Extracted from ui-design skill - use this for UI/UX design reviews

## Quick Checklist

```
1. [ ] Visual hierarchy clear (size, color, spacing guide attention)
2. [ ] Contrast ratio ≥ 4.5:1 for text (WCAG AA)
3. [ ] Touch targets ≥ 44px (mobile)
4. [ ] Design tokens used (colors, spacing, typography from system)
5. [ ] All states covered (empty, loading, error, success, partial)
6. [ ] Responsive breakpoints tested (mobile, tablet, desktop)
```

## Red Flags

- Hardcoded colors/sizes instead of design tokens
- Missing loading states (users think app is frozen)
- No error states (silent failures)
- Text over images without overlay (readability)
- Inconsistent spacing/alignment
- No focus indicators (keyboard accessibility)
- Z-index wars (999, 9999, 99999)

## Output Format

### Accessibility Audit

| Element | Check | Status | Finding |
|---------|-------|--------|---------|
| Color Contrast | ≥ 4.5:1 | Pass/Fail | [ratio found] |
| Touch Targets | ≥ 44px | Pass/Fail | [size found] |
| Focus Indicators | Visible | Pass/Fail | [details] |
| Alt Text | Present | Pass/Fail | [missing items] |
| Keyboard Nav | Works | Pass/Fail | [issues] |

### State Completeness

| Component | Empty | Loading | Error | Success | Partial |
|-----------|-------|---------|-------|---------|---------|
| [component] | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |

### Responsive Check

| Breakpoint | Width | Layout | Issues |
|------------|-------|--------|--------|
| Mobile | 375px | [status] | [findings] |
| Tablet | 768px | [status] | [findings] |
| Desktop | 1200px | [status] | [findings] |

### Design Token Usage

| Category | Using Tokens | Hardcoded Values | Fix Needed |
|----------|--------------|------------------|------------|
| Colors | [count] | [count] | Yes/No |
| Spacing | [count] | [count] | Yes/No |
| Typography | [count] | [count] | Yes/No |

### Recommendations

1. **Critical (A11y)**: [accessibility issues]
2. **Important (UX)**: [user experience issues]
3. **Polish**: [visual refinements]
