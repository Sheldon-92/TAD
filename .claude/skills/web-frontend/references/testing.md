# Testing Strategy Judgment Rules

> React-first. [Vue] and [Svelte] equivalents noted in brackets.

---

## Rule 1: Testing Pyramid Ratios for Frontend

**When**: Deciding how many tests to write at each layer (unit / integration / E2E).

**Decision**: Follow the frontend-specific testing pyramid. Most tests at the unit layer. E2E tests are expensive — write them for happy paths only.

| Layer | Ratio | Tools | What to test |
|-------|-------|-------|-------------|
| **Unit** (most) | ~60% | Vitest + jest-axe + Testing Library | Component behavior, focus APIs, ARIA states, utility functions |
| **Integration** (medium) | ~30% | React Testing Library + Storybook | Real user interactions, component composition, form workflows |
| **E2E** (fewest) | ~10% | Playwright | Complete multi-page happy paths only |

**Threshold**: If E2E tests make up >20% of the test suite — cut. E2E tests that duplicate unit and integration tests have negative value (they're slower, flakier, and give no additional signal).

**Anti-pattern**:
```
// ❌ Test pyramid inverted — E2E for everything
tests/
  e2e/
    login.spec.ts           ← should be unit/integration
    product-card.spec.ts    ← should be unit
    add-to-cart.spec.ts     ← OK for E2E
    checkout.spec.ts        ← OK for E2E
    search.spec.ts          ← should be integration

// ✅ Pyramid shape
tests/
  unit/                     ← most tests here
    button.test.tsx
    useCart.test.ts
    formatPrice.test.ts
  integration/              ← medium coverage
    CartPage.test.tsx
    CheckoutForm.test.tsx
  e2e/                      ← fewest, happy paths only
    checkout-flow.spec.ts
    login-flow.spec.ts
```

**Source**: [Testing Library — Guiding Principles](https://testing-library.com/docs/guiding-principles); [Google Testing Blog — Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html); [Playwright — Best Practices](https://playwright.dev/docs/best-practices)

[Vue: Vue Testing Library + Vitest for unit/integration; Playwright for E2E — same ratios]
[Svelte: Svelte Testing Library + Vitest; Playwright — same ratios]

---

## Rule 2: Behavioral Testing (Not Implementation Testing)

**When**: Writing unit or integration tests for React components.

**Decision**: Test what the component DOES from a user's perspective, not how it's implemented internally. Query by role, label, or visible text — never by class names, component names, or internal state.

**Threshold**: If a test needs to access internal state (`component.state.isOpen`), call private methods, or query by CSS class (`container.querySelector('.modal')`) — rewrite to test behavior instead.

**Anti-pattern**:
```typescript
// ❌ Tests internal implementation — breaks on refactor
it('should set isOpen to true when button is clicked', () => {
  const wrapper = mount(<Dropdown />)
  wrapper.find('Button').simulate('click')
  expect(wrapper.state('isOpen')).toBe(true)      // Internal state
  expect(wrapper.find('.dropdown-menu').exists())  // CSS class
})

// ✅ Tests user behavior — survives refactor
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

it('shows options when trigger is clicked', async () => {
  const user = userEvent.setup()
  render(<Dropdown label="Sort by" options={['Price', 'Rating']} />)
  
  await user.click(screen.getByRole('button', { name: 'Sort by' }))
  
  expect(screen.getByRole('option', { name: 'Price' })).toBeVisible()
  expect(screen.getByRole('option', { name: 'Rating' })).toBeVisible()
})
```

**Source**: [Testing Library — Guiding Principles](https://testing-library.com/docs/guiding-principles); [Kent C. Dodds — Testing Implementation Details](https://kentcdodds.com/blog/testing-implementation-details)

[Vue: Vue Testing Library has identical API — same behavioral testing approach]
[Svelte: Svelte Testing Library — identical approach]

---

## Rule 3: Stable Test Locators

**When**: Writing any test that selects elements from the rendered DOM.

**Decision**: Use this priority order for locators. Never use CSS selectors or snapshot tests as the primary assertion mechanism.

Priority order (highest to lowest confidence):
1. `getByRole` — queries by ARIA role + accessible name (best signal: matches screen reader experience)
2. `getByLabelText` — form elements by label
3. `getByPlaceholderText` — inputs by placeholder (less stable than label)
4. `getByText` — visible text (stable if content doesn't change frequently)
5. `getByTestId` with `data-testid` attribute — escape hatch when above options don't work

**Threshold**: `getByTestId` usage >20% of all queries → consider if semantic HTML can be improved to allow `getByRole`.

**Anti-pattern**:
```typescript
// ❌ CSS selector — breaks on class rename/refactor
container.querySelector('.btn-primary')
document.querySelector('[data-qa="submit"]')

// ❌ Index-based (brittle — breaks when list order changes)
screen.getAllByRole('button')[2]

// ✅ Role + name (semantic and stable)
screen.getByRole('button', { name: /submit order/i })
screen.getByRole('textbox', { name: /email address/i })
screen.getByRole('checkbox', { name: /i agree to terms/i })

// ✅ data-testid as escape hatch for non-standard elements
// In component:
<canvas data-testid="product-preview-canvas" />
// In test:
screen.getByTestId('product-preview-canvas')
```

**Source**: [Testing Library — Queries — getByRole](https://testing-library.com/docs/queries/byrole); [Testing Library — Which query should I use?](https://testing-library.com/docs/guide-which-query)

[Vue: Vue Testing Library — identical query priority]
[Svelte: Svelte Testing Library — identical query priority]

---

## Rule 4: Accessibility Unit Tests

**When**: Writing tests for any interactive component — buttons, forms, dialogs, navigation menus.

**Decision**: Include accessibility assertions in unit tests alongside behavior assertions. Use `jest-axe` for automated ARIA checks and explicit keyboard interaction tests.

**Threshold**: Every custom interactive component MUST have:
- `toHaveNoViolations()` assertion (jest-axe)
- Keyboard navigation test (Tab, Escape, Enter at minimum)
- Focus state test (focus is visible, focus moves correctly)

**Anti-pattern**:
```typescript
// ❌ No accessibility assertions — a11y bugs invisible until user reports
it('renders dropdown', () => {
  render(<Dropdown options={['A', 'B']} />)
  expect(screen.getByRole('button')).toBeInTheDocument()
  // No keyboard test, no axe check, no focus test
})

// ✅ With accessibility assertions
import { axe } from 'jest-axe'
import userEvent from '@testing-library/user-event'

it('is accessible', async () => {
  const { container } = render(<Dropdown label="Filter" options={['A', 'B']} />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})

it('is keyboard navigable', async () => {
  const user = userEvent.setup()
  render(<Dropdown label="Filter" options={['A', 'B']} />)
  
  // Tab to focus the trigger
  await user.tab()
  expect(screen.getByRole('button', { name: 'Filter' })).toHaveFocus()
  
  // Enter to open
  await user.keyboard('{Enter}')
  expect(screen.getByRole('listbox')).toBeVisible()
  
  // Escape to close
  await user.keyboard('{Escape}')
  expect(screen.queryByRole('listbox')).not.toBeInTheDocument()
})
```

**Source**: [jest-axe — GitHub](https://github.com/nickcolley/jest-axe); [Testing Library — User Interactions with userEvent](https://testing-library.com/docs/user-event/intro); [WCAG 2.2 — Success Criteria 2.1.1 Keyboard](https://www.w3.org/TR/WCAG22/#keyboard)

[Vue: @vue/test-utils + jest-axe — same patterns]
[Svelte: @testing-library/svelte + jest-axe — same patterns]

---

## Rule 5: Storybook as Living Documentation and Integration Test Environment

**When**: Building a component library or design system where components must be tested in isolation with real browser rendering.

**Decision**: Write Storybook stories for every shared UI component. Stories ARE integration tests — they verify the component renders correctly in isolation without a full application context.

**Threshold**: 
- Every component in `components/ui/` → requires a Story
- Story file co-located with component: `Button.stories.tsx` next to `Button.tsx`
- Use `@storybook/addon-a11y` — catches accessibility violations in the visual browser environment (catches issues that jest-axe misses in JSDOM)
- Storybook Interaction Tests for complex interaction flows (type, click sequence, hover states)

**Anti-pattern**:
```typescript
// ❌ Story with no variants — doesn't document the component's range
export default { title: 'UI/Button', component: Button }
export const Default = {}

// ✅ Stories document all meaningful states
import type { Meta, StoryObj } from '@storybook/react'

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: { layout: 'centered' },
  argTypes: { variant: { control: 'select', options: ['primary', 'secondary', 'ghost'] } },
}
export default meta

type Story = StoryObj<typeof Button>

export const Primary: Story = { args: { children: 'Submit', variant: 'primary' } }
export const Loading: Story = { args: { children: 'Saving...', loading: true } }
export const Disabled: Story = { args: { children: 'Unavailable', disabled: true } }
export const IconLeft: Story = { args: { children: 'Add to cart', iconLeft: <CartIcon /> } }
```

**Source**: [Storybook — Writing Stories](https://storybook.js.org/docs/writing-stories); [Storybook — Accessibility Addon](https://storybook.js.org/docs/writing-tests/accessibility-testing); [Storybook — Interaction Tests](https://storybook.js.org/docs/writing-tests/interaction-testing)

[Vue: `@storybook/vue3` — same Story format with `<template>` syntax in args]
[Svelte: `@storybook/svelte` — same Story format]
