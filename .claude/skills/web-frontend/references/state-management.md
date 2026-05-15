# State Management Judgment Rules

> React-first. [Vue] and [Svelte] equivalents noted in brackets.

---

## Rule 1: Server State vs Client State — Never Mix

**When**: Deciding where to store data that comes from an API or database (user profile, product list, order history).

**Decision**: Server state (remote data) goes in TanStack Query. Client state (UI flags, theme, navigation state) goes in Zustand or Jotai. Never put API responses in a global Redux/Zustand store alongside UI flags.

**Threshold**: If a Zustand store contains both API response data AND UI state (modal open, selected tab), separate them immediately into TanStack Query (for API data) + Zustand (for UI-only state).

**Anti-pattern**:
```typescript
// ❌ Mixed store — API data and UI flags together
const useStore = create((set) => ({
  products: [],          // Server state — belongs in TanStack Query
  isLoading: false,      // Managed by TanStack Query
  cartOpen: false,       // Client state — OK here
  fetchProducts: async () => { /* manual fetch + set */ },  // Duplicate of Query logic
}))

// ✅ Separated
// Server state — TanStack Query manages loading, caching, revalidation
const { data: products, isLoading } = useQuery({
  queryKey: ['products'],
  queryFn: fetchProducts,
})

// Client state — Zustand for pure UI
const useUIStore = create((set) => ({
  cartOpen: false,
  openCart: () => set({ cartOpen: true }),
  closeCart: () => set({ cartOpen: false }),
}))
```

**Source**: [TanStack Query — Does TanStack Query replace Redux?](https://tanstack.com/query/latest/docs/framework/react/guides/does-this-replace-client-state); [Zustand documentation — Comparison](https://docs.pmnd.rs/zustand/getting-started/comparison)

[Vue: Pinia for client state + VueQuery / @tanstack/vue-query for server state. Same separation rule.]
[Svelte: Svelte stores for client state + @tanstack/svelte-query for server state.]

---

## Rule 2: State Selection Matrix (2026 Stack)

**When**: Starting a new React project or adding state management to an existing one.

**Decision**: Use this matrix to select the right tool:

| Need | Tool | Reason |
|------|------|--------|
| Remote data (API, DB) | **TanStack Query** | Caching, deduplication, background refetch, loading/error states automatic |
| Simple UI state (theme, modal, navigation) | **Zustand** | Zero boilerplate, no providers, tiny bundle (~1KB) |
| Complex interdependent state (form with derived values, spreadsheets) | **Jotai** | Atomic model — each atom is independent; derived atoms computed automatically |
| Large team with time-travel debugging needs | **Redux Toolkit** | DevTools, predictability, but 10× boilerplate vs Zustand |
| Pass 1-2 values to avoid prop drilling (theme, locale) | **React Context** | Acceptable only for low-frequency updates — re-renders all consumers |
| High-frequency updates (cursor position, live collaboration) | **Signals** (Preact/Angular/SolidJS) | Granular DOM updates without component re-renders |

**Threshold**: Default 2026 stack for new projects: **TanStack Query + Zustand**. Add Jotai only when complex derived state appears. Add Redux Toolkit only when team size >10 and explicit time-travel debugging is required.

**Anti-pattern**:
```typescript
// ❌ React Context for frequently-updating state — re-renders entire tree
const CartContext = createContext(null)
export function CartProvider({ children }) {
  const [items, setItems] = useState([])
  // Every item add/remove re-renders ALL context consumers
  return <CartContext.Provider value={{ items, setItems }}>{children}</CartContext.Provider>
}

// ✅ Zustand — components subscribe to only the slice they need
const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
}))
// Components subscribe to exactly what they use:
const items = useCartStore((state) => state.items)  // Re-renders only on items change
```

**Source**: [Zustand vs Context comparison](https://docs.pmnd.rs/zustand/getting-started/comparison); [Jotai motivation](https://jotai.org/docs/introduction); [TanStack Query motivation](https://tanstack.com/query/latest/docs/framework/react/overview)

[Vue: Pinia replaces both Zustand and Redux Toolkit in the Vue ecosystem. VueQuery for server state.]
[Svelte: Built-in stores (`writable`, `derived`) handle Jotai use cases. @tanstack/svelte-query for server state.]

---

## Rule 3: Local State First Rule

**When**: Adding state to any component in any application.

**Decision**: Start with `useState` in the component that needs it. Lift to parent only when siblings need it. Lift to global store only when distant components need it. Do NOT add to global store by default.

**Threshold**: 
- 1 component needs the state → `useState` (local)
- 2-3 sibling components need the state → lift to shared parent
- Components more than 3 levels apart need the state → global store (Zustand/Jotai)

**Anti-pattern**:
```typescript
// ❌ Everything in global store — form state, hover state, scroll position
const useGlobalStore = create(() => ({
  isMenuHovered: false,      // Should be local useState
  formFirstName: '',         // Should be local useState
  formLastName: '',          // Should be local useState
  scrollPosition: 0,         // Should be useRef or local useState
}))

// ✅ Local state for local concerns
function ContactForm() {
  const [firstName, setFirstName] = useState('')  // Local — only this form uses it
  const [lastName, setLastName] = useState('')
  // ...
}
```

**Source**: [React documentation — Sharing State Between Components](https://react.dev/learn/sharing-state-between-components); [Dan Abramov — You Might Not Need Redux](https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367)

[Vue: same principle; local `ref`/`reactive` before Pinia]
[Svelte: local reactive `let` declarations before writable stores]

---

## Rule 4: TanStack Query Configuration Defaults

**When**: Setting up TanStack Query in a production application.

**Decision**: Configure `QueryClient` with explicit `staleTime` per query type. Never use the default `staleTime: 0` (causes re-fetch on every tab focus for all queries).

**Threshold**:
- Static reference data (product categories, config): `staleTime: Infinity`
- Slowly-changing data (product listings, user profile): `staleTime: 5 * 60 * 1000` (5 min)
- Real-time data (notifications, chat): `staleTime: 0` + WebSocket invalidation
- Default for unknown data: `staleTime: 60 * 1000` (1 min)

**Anti-pattern**:
```typescript
// ❌ Default staleTime: 0 — re-fetches user profile on every window focus
const queryClient = new QueryClient()

// ✅ Explicit defaults + per-query override
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,   // 1 minute default
      retry: 1,               // 1 retry on failure (not 3)
      refetchOnWindowFocus: true,
    },
  },
})

// Per-query override for static data
useQuery({
  queryKey: ['product-categories'],
  queryFn: fetchCategories,
  staleTime: Infinity,   // Categories don't change — never re-fetch
})
```

**Source**: [TanStack Query — Default Query Function Options](https://tanstack.com/query/latest/docs/framework/react/guides/important-defaults); [TanStack Query — staleTime vs cacheTime](https://tanstack.com/query/latest/docs/framework/react/guides/caching)

[Vue: Same configuration via `VueQueryPlugin` `queryClientConfig` option.]
[Svelte: Same via `@tanstack/svelte-query` QueryClient setup.]

---

## Rule 5: Zustand Selector Pattern (Prevent Over-Rendering)

**When**: A component subscribes to a Zustand store using `useStore()` without a selector.

**Decision**: Always pass a selector function to `useStore`. Subscribing to the entire store causes the component to re-render on ANY state change, even changes to unrelated slices.

**Threshold**: If a component subscribes to the full store (`useStore()` with no argument or `useStore((state) => state)`) AND the store has >3 fields — refactor to use targeted selectors.

**Anti-pattern**:
```typescript
// ❌ Subscribes to entire store — re-renders on ANY change (cart, theme, navigation, etc.)
const store = useCartStore()
const items = store.items

// ✅ Selector — re-renders ONLY when items array changes
const items = useCartStore((state) => state.items)
const itemCount = useCartStore((state) => state.items.length)  // Even more targeted
```

**Source**: [Zustand documentation — Selecting Multiple State Slices](https://docs.pmnd.rs/zustand/guides/auto-generating-selectors); [Zustand documentation — Preventing Unnecessary Rerenders with useShallow](https://docs.pmnd.rs/zustand/guides/prevent-rerenders-with-use-shallow)

[Vue: Pinia `storeToRefs` destructures reactive refs without losing reactivity. `store.items` (reactive) vs raw destructuring (loses reactivity).]
[Svelte: `$store.items` subscription — Svelte handles granularity at the store level; use `derived` stores for computed subsets.]

---

## Rule 6: AI-Amplified State Inconsistency Rule

**When**: Working in a codebase where AI code generation (Copilot, Cursor, Claude Code) is used regularly.

**Decision**: Explicitly define and document state conventions in CONVENTIONS.md before AI generates any stateful components. Without explicit conventions, AI will mix local state, global store, server state, and URL state in inconsistent ways across components.

**Threshold**: Any project with >2 developers using AI code generation tools MUST have a written state management convention document. Check: can any new developer (or AI agent) answer these questions without reading existing code?
- Where does remote data live? (TanStack Query)
- Where does UI state live? (Zustand)
- When is React Context acceptable? (locale, theme only)
- When is `useState` preferred? (local-only state)

**Anti-pattern**:
```
// ❌ Inconsistent conventions across AI-generated components (real pattern)
// Component A: stores user in Zustand
// Component B: fetches user in useEffect + useState
// Component C: uses React Context for user
// Component D: passes user as props 6 levels deep
```

**Source**: [Jotai — Why Jotai over Context](https://jotai.org/docs/basics/comparison); Research finding: "AI-amplified inconsistency — if state conventions aren't explicitly defined, AI agents dangerously mix local/global/server caches"

[Vue: same principle; document Pinia vs Composition API reactivity conventions explicitly]
[Svelte: document writable stores vs reactive $: declarations vs Svelte stores]
