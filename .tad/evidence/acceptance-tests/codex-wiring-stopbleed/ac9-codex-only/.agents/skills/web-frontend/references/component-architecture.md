# Component Architecture Judgment Rules

> React-first. [Vue] and [Svelte] equivalents noted in brackets.

---

## Rule 1: Server Component by Default (RSC Decision Rule)

**When**: You are building a component in Next.js App Router and deciding whether to add `'use client'`.

**Decision**: Default to Server Component (no directive). Only add `'use client'` when the component requires browser APIs, event handlers, `useState`, or `useEffect`. Push `'use client'` as far down the component tree as possible — preferably to leaf components only.

**Threshold**: If a component tree has `'use client'` at a level that makes >20% of its children server-side incompatible, restructure: extract the interactive part as a named client component and keep the wrapper as Server Component.

**Anti-pattern**:
```typescript
// ❌ 'use client' at layout level — forces entire subtree to run on client
'use client'
export default function ProductLayout({ children }) { ... }

// ✅ 'use client' only on the interactive leaf
export default function ProductLayout({ children }) {
  // Server Component — can fetch, can access DB
  return <div>{children}<AddToCartButton /></div>
}

// In AddToCartButton.tsx:
'use client'
export function AddToCartButton() {
  const [loading, setLoading] = useState(false)
  ...
}
```

**Source**: [React Server Components RFC](https://github.com/reactjs/rfcs/blob/main/text/0188-server-components.md) — Thin Client Rule; [Next.js App Router docs — When to use Server vs Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components#when-to-use-client-components)

[Vue: equivalent pattern is Islands Architecture with Nuxt 3 server components. Default to static rendering; add `client:*` directives only to interactive islands.]
[Svelte: SvelteKit +page.server.ts for data loading stays server-side; `$app/browser` usage triggers client-only rendering.]

---

## Rule 2: Component Splitting Threshold

**When**: A component file exceeds 150 lines, or a single component handles multiple responsibilities (fetching + displaying + user interaction).

**Decision**: Split. Each component should do one thing. The split signals:
- **Data component** (fetches/transforms) — no JSX beyond passing props
- **Display component** (pure JSX, props in, UI out) — no fetching, no side effects
- **Container component** (composes display + data) — minimal own logic

**Threshold**: 
- Single component file >150 lines → split
- Component with >3 `useState` hooks → likely needs decomposition
- Component with >5 props → consider if it's doing too much

**Anti-pattern**:
```typescript
// ❌ God component: fetches, transforms, renders, handles interactions, manages form state
function ProductPage() {
  const [product, setProduct] = useState(null)
  const [loading, setLoading] = useState(false)
  const [cartOpen, setCartOpen] = useState(false)
  const [quantity, setQuantity] = useState(1)
  useEffect(() => { fetch('/api/product').then(r => r.json()).then(setProduct) }, [])
  // 200 more lines...
}

// ✅ Composed: each piece is testable, replaceable
async function ProductPage({ params }) {
  const product = await getProduct(params.id)  // Server Component fetch
  return <ProductDetail product={product} />    // Display component
}
```

**Source**: [Feature-Sliced Design — Component Guidelines](https://feature-sliced.design/docs/guides/issues/decompose); [React documentation — Thinking in React](https://react.dev/learn/thinking-in-react)

[Vue: same split applies; Composition API `composables/` take the data-logic role]
[Svelte: split into `+page.ts` (data) + `+page.svelte` (display)]

---

## Rule 3: Composition over Configuration (Headless Pattern)

**When**: Building a reusable component that needs to work across multiple design contexts (different brands, themes, or teams).

**Decision**: Use composition (children + compound components) over configuration props. Build a "headless" component that provides accessibility and behavior; let the caller own the styles.

**Threshold**: If a component accepts >3 visual configuration props (`size`, `variant`, `color`, `rounded`, `bordered`…) — convert to compound pattern or headless + slot system.

**Anti-pattern**:
```typescript
// ❌ Configuration explosion — every visual variation needs a new prop
<Button size="lg" variant="primary" rounded="full" iconLeft="cart" loading={true} />

// ✅ Compound component — caller controls structure
<Button loading={loading}>
  <CartIcon aria-hidden />
  Add to cart
</Button>
```

**Source**: [Radix UI Primitives — Design Principles](https://www.radix-ui.com/primitives); [Adobe React Aria — Anatomy of a Component](https://react-spectrum.adobe.com/react-aria/getting-started.html)

[Vue: use slots and scoped slots for the same pattern; headless libraries: Headless UI, Radix Vue]
[Svelte: use `<slot>` and named slots; consider Bits UI (Svelte headless)]

---

## Rule 4: Feature-Sliced Design at Scale Threshold

**When**: An application grows past 50 components and developers start having difficulty finding where to put new code.

**Decision**: Adopt Feature-Sliced Design (FSD) layering. FSD defines strict vertical slices (features) and horizontal layers (app → pages → widgets → features → entities → shared). Import direction: top layers import from bottom layers only.

**Threshold**: Apply FSD when:
- >50 components in the project, OR
- >3 developers working on different features simultaneously, OR
- Feature merges regularly cause conflicts in shared directories

Avoid FSD for <10 developers or simple CRUD apps — overhead exceeds benefit.

**Anti-pattern**:
```
// ❌ Flat components/ with no ownership — any component can import any other
components/
  UserCard.tsx        → imports CartSummary (cross-feature dependency)
  CartSummary.tsx     → imports UserPreferences (another cross-feature dep)

// ✅ FSD — dependency direction enforced by layer
features/
  cart/               → can import entities/user, shared/ui
  user-profile/       → can import entities/user, shared/ui
  // cart CANNOT import user-profile (same layer = forbidden)
```

**Source**: [Feature-Sliced Design documentation](https://feature-sliced.design/); [Shopify Polaris — Component Architecture](https://polaris.shopify.com/patterns/app-extensions/overview)

[Vue: FSD is framework-agnostic — same directory structure, same import rules]
[Svelte: applies identically to SvelteKit projects]

---

## Rule 5: Micro-Frontend Threshold

**When**: Leadership or architects propose splitting a frontend into independently-deployed micro-frontends.

**Decision**: Defer micro-frontends unless the team has ≥10 developers with genuinely distinct business domains (separate deployment cycles, separate tech stacks, separate ownership). Below that threshold, the overhead (Module Federation complexity, shared dependency conflicts, inter-app communication) outweighs benefits.

**Threshold**: 
- <10 developers → monorepo with FSD, not micro-frontends
- ≥10 developers with distinct domains → evaluate Module Federation (Webpack 5) or single-spa
- Different tech stacks (React + Vue + Angular in same org) → micro-frontends are justified

**Anti-pattern**:
```
// ❌ Micro-frontend for 5-developer team — overkill
host-app/            → shell
header-mfe/          → tiny header (3 files)
sidebar-mfe/         → tiny sidebar (5 files)
content-mfe/         → main content

// ✅ Monorepo with clear ownership
apps/web/            → single deployable
packages/ui/         → shared component library (publishable)
packages/features/   → feature modules
```

**Source**: [Luca Mezzalira — Building Micro-Frontends (O'Reilly)](https://www.oreilly.com/library/view/building-micro-frontends/9781492082996/); [Martin Fowler — Micro Frontends](https://martinfowler.com/articles/micro-frontends.html)

[Vue: same threshold; Nuxt Layers is a lighter alternative for monorepo setups]
[Svelte: Vite workspace sharing covers most monorepo needs without micro-frontend overhead]

---

## Rule 6: Primitive Props Rule (Performance)

**When**: Writing a component that receives an object as a prop and the object contains more fields than the component actually uses.

**Decision**: Destructure and pass only the primitive values the component needs. This prevents child re-renders when unrelated fields in the parent object change.

**Threshold**: If a child component only uses 1-2 fields from a parent object with ≥5 fields, pass only those fields. Use `React.memo` if profiling shows this component renders >2× per second.

**Anti-pattern**:
```typescript
// ❌ Entire user object passed — any user field change re-renders Avatar
function Avatar({ user }: { user: User }) {
  return <img src={user.avatarUrl} alt={user.name} />
}
// Called as: <Avatar user={currentUser} />

// ✅ Primitive props — only re-renders when these two strings actually change
function Avatar({ src, alt }: { src: string; alt: string }) {
  return <img src={src} alt={alt} />
}
// Called as: <Avatar src={currentUser.avatarUrl} alt={currentUser.name} />
```

**Source**: [React documentation — Passing Props to a Component](https://react.dev/learn/passing-props-to-a-component); [React Performance documentation — Rendering behavior](https://react.dev/reference/react/memo)

[Vue: same principle; use computed properties to extract primitives before passing as props]
[Svelte: same principle; reactive declarations (`$:`) extract primitives]

---

## Rule 7: Conditional Rendering — Guard Clauses Over Nesting

**When**: A component has multiple conditional render states (loading, error, empty, data-present).

**Decision**: Use guard clauses (early returns) rather than nested ternaries. Each state is a separate, clearly-readable branch.

**Threshold**: >2 conditional states in one component → use guard clauses. >1 level of nested ternaries → refactor immediately.

**Anti-pattern**:
```typescript
// ❌ Nested ternaries — unreadable, untestable states
return loading ? <Spinner /> : error ? <ErrorMessage error={error} /> : data.length === 0 ? <EmptyState /> : <DataList data={data} />

// ✅ Guard clauses — each state is explicit and testable
if (loading) return <Spinner />
if (error) return <ErrorMessage error={error} />
if (data.length === 0) return <EmptyState />
return <DataList data={data} />
```

**Source**: [React documentation — Conditional Rendering](https://react.dev/learn/conditional-rendering); [Clean Code — Guard Clauses (Robert Martin)]

[Vue: same pattern; use `v-if` with early return from setup function logic]
[Svelte: use `{#if}` blocks with early bail-out in `<script>` where possible]
