# Accessibility Testing Rules
<!-- capability: accessibility_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| X1 | Top 5 WCAG failures: alt text, contrast, form labels, links, ARIA | Prioritizing a11y fixes |
| X2 | axe-core + Playwright integration pattern | Setting up automated a11y testing |
| X3 | Automated catches 30-50% of WCAG issues | Setting expectations for automation |
| X4 | Pa11y CLI for standalone scanning | Running quick a11y audits |
| X5 | Contrast ratio >= 4.5:1 for normal text | Checking color accessibility |
| X6 | Keyboard navigation: Tab, Enter, Escape | Testing interactive elements |
| X7 | Focus management for modals and dialogs | Testing dynamic UI |
| X8 | ARIA: wrong ARIA is worse than no ARIA | Using ARIA attributes |

---

## Rules

### X1: Top 5 WCAG Failures

When prioritizing accessibility fixes, start with the five most common failures (source: WebAIM Million, Deque audits n=550):

1. **Missing alt text on images** -- screen readers announce "image" with no context
2. **Insufficient color contrast** -- text unreadable for low-vision users (ratio < 4.5:1)
3. **Unlabelled form inputs** -- screen readers can't tell users what to type
4. **Empty links/buttons** -- clickable elements with no accessible name
5. **Broken ARIA attributes** -- invalid roles, missing required properties, conflicting states

These five account for the majority of automated a11y failures. Fix them first.

### X2: axe-core + Playwright Integration

When setting up automated accessibility testing in E2E suites:

```bash
npm i -D @axe-core/playwright
```

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage has no a11y violations', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa'])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

- **`withTags(['wcag2a', 'wcag2aa'])`**: Tests against WCAG 2.1 Level A and AA criteria
- **Run after page is fully loaded**: Dynamic content must be rendered before scanning
- **Test key states**: Empty state, loaded state, error state, modal open state

**Anti-pattern**: Running axe-core only on the homepage. Every page with unique UI elements needs its own scan.

### X3: Automated Catch Rate -- 30-50%

When relying on automated accessibility tools:

- Automated tools (axe-core, Pa11y, Lighthouse a11y) catch **30-50% of WCAG issues** (57% by volume per Deque, across n=550 audits)
- **What automation catches**: Missing alt text, contrast ratios, missing labels, invalid ARIA, heading hierarchy, duplicate IDs
- **What automation misses**: Keyboard navigation flow quality, screen reader announcement coherence, cognitive load, meaningful alt text content, focus order logic, touch target adequacy

**Consequence**: A zero-violation axe-core report does NOT mean the site is accessible. It means half the work is done. Manual testing (keyboard navigation, screen reader walkthrough) covers the other half.

### X4: Pa11y CLI for Quick Scanning

When running a quick accessibility audit without a test suite:

```bash
# Single page
npx pa11y https://example.com

# With specific standard
npx pa11y --standard WCAG2AA https://example.com

# JSON output for CI
npx pa11y --reporter json https://example.com

# Multiple pages
npx pa11y-ci --config .pa11yci.json
```

Pa11y uses HTML_CodeSniffer by default and can switch to axe-core as its test runner. Use Pa11y for quick scans, axe-core + Playwright for E2E integration.

### X5: Color Contrast Requirements

When checking color accessibility:

- **Normal text (< 18px / < 14px bold)**: Contrast ratio >= 4.5:1 (WCAG AA)
- **Large text (>= 18px / >= 14px bold)**: Contrast ratio >= 3:1 (WCAG AA)
- **UI components and graphical objects**: Contrast ratio >= 3:1 against adjacent colors
- **Enhanced (WCAG AAA)**: 7:1 for normal text, 4.5:1 for large text

```bash
# Lighthouse contrast audit
npx lighthouse https://example.com --only-audits=color-contrast --output=json
```

**Anti-pattern**: Using brand colors that fail contrast. The fix is adjusting shade/tint, not removing the brand color entirely. Tools like https://webaim.org/resources/contrastchecker/ show the nearest passing shade.

### X6: Keyboard Navigation Testing

When testing keyboard accessibility:

- **Tab**: Moves focus to next interactive element in logical order
- **Shift+Tab**: Moves focus backward
- **Enter/Space**: Activates focused element (buttons, links, checkboxes)
- **Escape**: Closes modals, dropdowns, tooltips
- **Arrow keys**: Navigate within components (tabs, menus, radio groups)

**Checklist**:
- [ ] Every interactive element is reachable via Tab
- [ ] Focus order matches visual order (left-to-right, top-to-bottom)
- [ ] Focus is visible (outline or highlight) on every focused element
- [ ] No keyboard traps (except intentional modal traps)
- [ ] Skip-to-content link available for navigation-heavy pages

### X7: Focus Management for Dynamic UI

When building or testing modals, dialogs, and dynamic content:

- **Modal opens**: Focus moves to the first focusable element inside the modal
- **Modal closes**: Focus returns to the element that opened it
- **Focus trap**: Tab cycles within the modal (does not escape to background content)
- **Dynamic content**: When new content appears (toast, alert), use `aria-live` regions

```typescript
// Playwright focus test
test('modal traps focus', async ({ page }) => {
  await page.click('[data-testid="open-modal"]');
  const modal = page.locator('[role="dialog"]');
  await expect(modal).toBeFocused(); // or first child

  // Tab should cycle within modal
  await page.keyboard.press('Tab');
  const focused = await page.evaluate(() => document.activeElement?.closest('[role="dialog"]'));
  expect(focused).not.toBeNull();

  // Escape closes and returns focus
  await page.keyboard.press('Escape');
  await expect(page.locator('[data-testid="open-modal"]')).toBeFocused();
});
```

### X8: ARIA -- Wrong ARIA Is Worse Than No ARIA

When using ARIA attributes:

- **First rule of ARIA**: Don't use ARIA if a native HTML element works. `<button>` > `<div role="button">`
- **Second rule**: Don't change native semantics. `<h2 role="tab">` confuses screen readers.
- **Required properties**: If you use a role, include all required ARIA properties (e.g., `role="slider"` requires `aria-valuenow`, `aria-valuemin`, `aria-valuemax`)
- **Invalid ARIA is worse than missing ARIA**: A wrong `aria-label` actively misleads users

**Common mistakes**:
- `aria-label="click here"` -- redundant with visible text, may conflict
- `role="button"` without keyboard handler -- looks like a button but doesn't work like one
- `aria-hidden="true"` on visible interactive elements -- hides them from screen readers while they're still visible and clickable

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Automated-only testing | Catches 30-50% at best | Add keyboard nav + screen reader testing |
| `display:none` to hide violations | Hides content from everyone | Fix the actual violation |
| `<div onClick>` instead of `<button>` | No keyboard access, no role | Use semantic HTML elements |
| ARIA on everything | Over-ARIA confuses screen readers | Native HTML first, ARIA only when needed |
| Homepage-only a11y test | Unique pages have unique violations | Test every page template |
| Ignoring mobile a11y | Touch targets, zoom, reflow differ | Test at 320px width, 200% zoom |
