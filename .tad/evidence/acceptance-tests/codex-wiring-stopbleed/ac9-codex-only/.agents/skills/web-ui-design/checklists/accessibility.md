# Accessibility Checklist

WCAG 2.1 AA compliance checks — each item is a runnable command or binary yes/no.
Automated tools cover 25–40% of issues; the remaining items require human review.

## Automated Checks (Run These First)

### axe-core
- [ ] Run: `axe http://localhost:3000 --tags wcag2a,wcag2aa --exit` returns exit 0
- [ ] Run: `axe http://localhost:3000 --reporter json > axe-report.json` — zero `critical` violations
- [ ] Run: `axe http://localhost:3000 --reporter json > axe-report.json` — zero `serious` violations

### Lighthouse CI
- [ ] Run: `lhci autorun` — accessibility score ≥ 90
- [ ] Run: `lhci autorun` — no blocking accessibility failures

### Pa11y
- [ ] Run: `pa11y http://localhost:3000 --standard WCAG2AA` — zero failures
- [ ] Run: `pa11y http://localhost:3000/[other-pages] --standard WCAG2AA` — zero failures

### Contrast (APCA)
- [ ] Run: `pa11y http://localhost:3000 --standard WCAG2AA` — zero color contrast failures
- [ ] Body text: APCA LC ≥ 60 (replaces WCAG 4.5:1 for body)
- [ ] Large text (≥24px): APCA LC ≥ 45
- [ ] UI components (buttons, inputs): APCA LC ≥ 45

---

## Structure Checks

### Semantic HTML
- [ ] Page has exactly one `<main>` landmark
- [ ] Page has `<header>` and `<footer>` landmarks
- [ ] Navigation uses `<nav>` element (not `<div role="navigation">`)
- [ ] No `<div>` or `<span>` used where a semantic element exists
- [ ] Run: `grep -r "div.*role\|span.*role" src/ --include="*.html" --include="*.tsx"` — minimal results

### Heading Hierarchy
- [ ] Page has exactly one `<h1>`
- [ ] Heading levels are sequential (no jumping from h1 to h3)
- [ ] Run: `grep -r "<h[1-6]" src/ | sort` — verify hierarchy is sequential

### Images
- [ ] All `<img>` elements have `alt` attribute (empty string OK for decorative)
- [ ] Decorative images have `alt=""` and `aria-hidden="true"`
- [ ] Run: `grep -r "<img" src/ | grep -v "alt=" | wc -l` — should return 0

### Links and Buttons
- [ ] All `<a>` elements have descriptive text (not "click here" or "read more")
- [ ] Buttons have accessible names (via text content, `aria-label`, or `aria-labelledby`)
- [ ] Run: `axe http://localhost:3000 --tags wcag2a --exit` catches link-name violations

---

## Keyboard Navigation

- [ ] All interactive elements reachable by Tab key
- [ ] Focus order matches visual reading order
- [ ] Custom components (modals, dropdowns) trap focus when open
- [ ] Escape key closes modals and dropdowns
- [ ] Skip-to-content link visible on focus (`:focus-visible`)
- [ ] Run: `grep -r "outline: none\|outline:0" src/ --include="*.css"` — returns 0 results (or all have `:focus-visible` replacement)

### Focus Styles
- [ ] All focusable elements show visible focus indicator
- [ ] Focus ring has ≥2px outline
- [ ] Focus ring has sufficient contrast against background
- [ ] Check: `:focus-visible` styles exist for every interactive element type

---

## Touch Accessibility

- [ ] All interactive elements ≥ 44×44px on touch devices
- [ ] Run: `grep -r "height: [1-3][0-9]px" src/ --include="*.css"` — review results
- [ ] Spacing between touch targets ≥ 8px

---

## Form Accessibility

- [ ] Every `<input>` has a `<label>` (not just placeholder)
- [ ] Error messages are associated with their input (`aria-describedby`)
- [ ] Required fields have `required` attribute AND visible indicator
- [ ] Form validation errors announced to screen readers

---

## ARIA Usage

- [ ] ARIA roles used only when no semantic HTML alternative exists
- [ ] Interactive ARIA widgets have correct keyboard interaction (roving tabindex for lists, etc.)
- [ ] `aria-live` regions used for dynamic content updates
- [ ] No duplicate IDs in the document

---

## Manual Review (Cannot Be Automated)

These require human judgment:

- [ ] Screen reader test with VoiceOver (macOS/iOS) — test core flows
- [ ] Screen reader test with NVDA or JAWS (Windows) — for Windows users
- [ ] Cognitive load check — can a new user understand page purpose in ≤5 seconds?
- [ ] Error recovery check — are error messages helpful (not just "invalid input")?
- [ ] Motion sensitivity check — does `prefers-reduced-motion` suppress animations?

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Quick Run: Full Automated Suite

```bash
# Run all automated checks at once
echo "--- axe-core ---" && axe http://localhost:3000 --tags wcag2aa --exit
echo "--- Lighthouse ---" && lhci autorun
echo "--- Pa11y ---" && pa11y http://localhost:3000 --standard WCAG2AA
echo "--- Focus styles ---" && \
  grep -r "outline: none\|outline:0" src/ --include="*.css" | grep -v "focus-visible" | wc -l
echo "--- Images without alt ---" && \
  grep -r "<img" src/ | grep -v "alt=" | wc -l
```
