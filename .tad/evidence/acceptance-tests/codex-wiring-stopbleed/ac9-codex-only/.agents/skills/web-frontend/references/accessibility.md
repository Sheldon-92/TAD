# Accessibility Judgment Rules

> React-first. These rules apply across all frameworks.
> ⚠️ Automation catches only 20-40% of accessibility bugs. The remaining 60-80% requires manual screen-reader testing and testing with disabled users.

---

## Rule 1: Semantic HTML First, ARIA Last

**When**: Building any interactive component — buttons, links, forms, navigation, dialogs.

**Decision**: Use the native HTML element that matches the semantic role before adding ARIA. Native elements have built-in keyboard support, screen reader announcement, and focus management. ARIA only adds semantics — it does NOT add behavior.

**Threshold**: Before using `role="button"` on a `<div>`, check if `<button>` is usable. Before `role="link"` on a `<span>`, check if `<a href>` works. The only acceptable reason to use ARIA roles is when native elements are structurally impossible (custom interactive widgets like date pickers, comboboxes, tree views).

**Anti-pattern**:
```typescript
// ❌ div with click handler — no keyboard access, no screen reader role
<div onClick={handleClick} style={{ cursor: 'pointer' }}>Add to cart</div>

// ❌ ARIA button on span — works for screen readers but still needs tabIndex + key handler
<span role="button" onClick={handleClick}>Add to cart</span>

// ✅ Native button — keyboard, focus, ARIA role all built in
<button onClick={handleClick}>Add to cart</button>
// Or with loading state (React 19+):
<button onClick={handleClick} aria-busy={isLoading} disabled={isLoading}>
  {isLoading ? 'Adding...' : 'Add to cart'}
</button>
```

**Source**: [W3C WAI — First Rule of ARIA Use](https://www.w3.org/TR/using-aria/#rule1); [Adobe React Aria — Why React Aria](https://react-spectrum.adobe.com/react-aria/why.html); [WebAIM — Semantic Structure](https://webaim.org/techniques/semanticstructure/)

---

## Rule 2: Top 7 axe-core Failures — Fix Patterns

**When**: Running an automated accessibility scan on any page.

**Decision**: Fix these 7 violations in priority order. They represent >80% of all automated a11y failures (based on WebAIM Million 2024 report).

| # | Violation | Fix |
|---|-----------|-----|
| 1 | Missing/empty `alt` on images | `<img alt="Descriptive text" />` or `alt=""` for decorative |
| 2 | Insufficient color contrast | Minimum 4.5:1 (normal text), 3:1 (large text/UI). Use [contrast checker](https://webaim.org/resources/contrastchecker/) |
| 3 | Missing form labels | `<label htmlFor="email">Email</label><input id="email" />` or `aria-label` |
| 4 | Improper heading structure | One `<h1>`, logical `h2→h3→h4` hierarchy, no skipped levels |
| 5 | Missing document language | `<html lang="en">` in root layout |
| 6 | ARIA misuse | Check ARIA against allowed roles/states per spec; remove redundant `role="button"` on `<button>` |
| 7 | Keyboard focus issues | Test Tab/Shift+Tab navigation; every interactive element must be reachable and have visible focus ring |

**Threshold**: `bash scripts/a11y-scan.sh http://localhost:3000` must report 0 critical and 0 serious violations before release. Run in CI on every PR.

**Source**: [WebAIM Million 2024 — Annual Accessibility Analysis](https://webaim.org/projects/million/); [axe-core rule documentation](https://dequeuniversity.com/rules/axe/4.10/); [WCAG 2.2 — Success Criteria 1.4.3 Contrast](https://www.w3.org/TR/WCAG22/#contrast-minimum)

[Vue: identical fixes — accessibility is HTML-level, not framework-level]
[Svelte: identical fixes]

---

## Rule 3: Interactive Component Accessibility Pattern (Headless UI)

**When**: Building a custom interactive component that has no native HTML equivalent — date pickers, comboboxes, tree views, tabs, accordions.

**Decision**: Use a headless accessibility library (React Aria, Radix UI) instead of building ARIA patterns from scratch. These libraries implement the WAI-ARIA Authoring Practices 1.1 patterns, which require correct keyboard navigation (arrow keys, Home/End, Escape), focus management, and announcements.

**Threshold**: If building a custom component that requires >2 ARIA attributes, use React Aria or Radix UI primitives. The time to implement correct keyboard + screen reader behavior from scratch is 3-5× longer than using a headless library.

**Anti-pattern**:
```typescript
// ❌ Custom dropdown with incomplete keyboard support
function Dropdown({ options, value, onChange }) {
  const [open, setOpen] = useState(false)
  return (
    <div>
      <button onClick={() => setOpen(!open)} aria-expanded={open}>
        {value}
      </button>
      {open && options.map(opt => (
        <div key={opt.id} onClick={() => onChange(opt)}>
          {opt.label}
        </div>
        // Missing: Arrow key navigation, escape to close, focus management,
        // aria-haspopup, aria-controls, role="listbox", role="option"
      ))}
    </div>
  )
}

// ✅ React Aria — all keyboard/ARIA patterns implemented
import { Select, Button, SelectValue, Popover, ListBox, ListBoxItem } from 'react-aria-components'

function ProductSelect({ products, selected, onChange }) {
  return (
    <Select selectedKey={selected} onSelectionChange={onChange}>
      <Button><SelectValue /></Button>
      <Popover>
        <ListBox>
          {products.map(p => <ListBoxItem key={p.id}>{p.name}</ListBoxItem>)}
        </ListBox>
      </Popover>
    </Select>
  )
  // Arrow keys, Escape, type-ahead, screen reader announcements: all built in
}
```

**Source**: [Adobe React Aria — Getting Started](https://react-spectrum.adobe.com/react-aria/getting-started.html); [Radix UI — Accessibility](https://www.radix-ui.com/primitives); [WAI-ARIA Authoring Practices 1.2](https://www.w3.org/WAI/ARIA/apg/)

[Vue: use Headless UI (Tailwind Labs) or Radix Vue for equivalent patterns]
[Svelte: use Bits UI or Melt UI for accessible headless components]

---

## Rule 4: Image Alt Text Rules

**When**: Adding any `<img>` element to a component.

**Decision**: Every image needs one of two alt text treatments. There is no third option.

| Image type | Alt text rule |
|-----------|--------------|
| **Informative** (product photos, diagrams, screenshots, icons with meaning) | Descriptive text: `alt="Blue Nike Air Max sneaker, size chart view"` |
| **Decorative** (background textures, dividers, illustrations that repeat nearby text) | Empty string: `alt=""` (NOT omitting `alt` — omitting is a WCAG failure) |

**Threshold**: 
- Never use the filename as alt text: `alt="IMG_2042.jpg"` → FAIL
- Never use "image of" or "picture of" — screen readers already say "image": `alt="image of shoe"` → FAIL
- Alt text >200 characters → consider moving the description to visible text or `aria-describedby`

**Anti-pattern**:
```typescript
// ❌ Missing alt — screen reader announces the src URL
<img src="/product/shoe.jpg" />

// ❌ Filename as alt text
<img src="/hero-banner.jpg" alt="hero-banner.jpg" />

// ❌ "Image of" prefix
<img src="/sneaker.jpg" alt="Image of blue Nike sneaker" />

// ✅ Informative image
<img src="/sneaker.jpg" alt="Blue Nike Air Max 90, right side view" />

// ✅ Decorative divider
<img src="/divider.svg" alt="" role="presentation" />
```

**Source**: [WebAIM — Alternative Text](https://webaim.org/techniques/alttext/); [WCAG 2.2 — Success Criteria 1.1.1 Non-text Content](https://www.w3.org/TR/WCAG22/#non-text-content); [axe-core — image-alt rule](https://dequeuniversity.com/rules/axe/4.10/image-alt)

---

## Rule 5: Focus Management for Dynamic Content

**When**: Content appears or changes dynamically — modals opening, route navigation, form submission errors, inline edit panels.

**Decision**: Manage focus explicitly when dynamic content appears. Don't leave focus on the trigger element when the target content is somewhere else.

**Threshold**:
- Modal/dialog opens → focus moves to first interactive element inside (or dialog heading)
- Modal closes → focus returns to trigger button
- Route navigation (SPA) → focus moves to `<h1>` or page skip link
- Form error appears → focus moves to the first error message or summary

**Anti-pattern**:
```typescript
// ❌ Modal opens, focus stays on the "Open modal" button
// User pressing Tab goes to elements behind the modal overlay

// ✅ Focus management with React Aria Dialog
import { Dialog, Modal, ModalOverlay, Heading } from 'react-aria-components'

function ConfirmModal({ onClose }) {
  return (
    <ModalOverlay>
      <Modal>
        <Dialog>
          {({ close }) => (
            <>
              <Heading slot="title">Confirm action</Heading>
              <p>Are you sure you want to delete this item?</p>
              <button autoFocus onClick={close}>Cancel</button>  {/* autoFocus → first element */}
              <button onClick={() => { deleteItem(); close(); }}>Delete</button>
            </>
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  )
  // React Aria handles: focus trap, Escape to close, focus return to trigger
}
```

**Source**: [WCAG 2.2 — Success Criteria 2.4.3 Focus Order](https://www.w3.org/TR/WCAG22/#focus-order); [W3C APG — Modal Dialog Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/); [Adobe React Aria — Modal](https://react-spectrum.adobe.com/react-aria/Modal.html)

[Vue: @headlessui/vue handles focus management in Dialog, Listbox, etc.]
[Svelte: Svelte headless libraries like Melt UI or bits-ui handle focus management]

---

## Rule 6: Automation Coverage Boundary

**When**: Deciding how to test accessibility — automated tools vs manual testing.

**Decision**: Automated tools (axe-core, Lighthouse, jest-axe) catch ~20-40% of WCAG failures. The remaining 60-80% requires manual screen-reader testing (VoiceOver on macOS/iOS, NVDA on Windows, TalkBack on Android) and testing with actual users who have disabilities.

**Threshold**: 
- 0 automated violations is a NECESSARY but NOT SUFFICIENT condition for "accessible"
- Critical flows (checkout, authentication, core navigation) require manual screen-reader testing before each major release
- Color contrast automated checks only catch solid colors — gradients, images, and overlays require manual inspection

**Testing matrix**:
| Automated | What it catches |
|-----------|-----------------|
| axe-core / Lighthouse | Missing labels, contrast failures (solid colors only), ARIA misuse, structural issues |
| jest-axe in unit tests | Component-level ARIA issues in isolation |
| **Manual (required)** | Screen reader announcements, interaction flow, cognitive load, context switching, custom widget usability |

**Source**: [WebAIM — Accessibility Testing Approaches](https://webaim.org/articles/evaluationoverview/); [Deque — How Much of WCAG Can Be Automated](https://www.deque.com/blog/how-much-of-wcag-can-be-automated/); Research finding: "automation catches 20-40% of a11y bugs"

[Vue: identical testing split — framework doesn't change what automation can/can't catch]
[Svelte: identical testing split]
