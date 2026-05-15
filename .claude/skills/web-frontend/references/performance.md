# Performance Judgment Rules

> React-first. [Vue] and [Svelte] equivalents noted in brackets.

---

## Rule 1: Core Web Vitals Thresholds (2026)

**When**: Evaluating whether a frontend application meets performance requirements for production.

**Decision**: Measure against these Google CWV thresholds. All three must be in the "Good" range for the P75 (75th percentile) of page loads.

| Metric | Good | Needs Improvement | Poor | What it measures |
|--------|------|-------------------|------|-----------------|
| **LCP** (Largest Contentful Paint) | <2.5s | 2.5s–4.0s | >4.0s | Hero element load time |
| **INP** (Interaction to Next Paint) | <200ms | 200ms–500ms | >500ms | Responsiveness to interactions |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1–0.25 | >0.25 | Visual stability (no layout jumps) |

INP replaced FID (First Input Delay) in March 2024. Do NOT optimize for FID.

**Threshold**: Run `bash scripts/lighthouse-check.sh http://localhost:3000` as a CI check. LCP>2.5s or INP>200ms is a release blocker. Note: Lighthouse measures TBT (Total Blocking Time) as a lab-mode proxy for INP — for true INP, use Real User Monitoring (Vercel Analytics, Datadog RUM, or web-vitals library in production).

**Source**: [web.dev — Core Web Vitals](https://web.dev/articles/vitals); [Google Search Console — Core Web Vitals report](https://support.google.com/webmasters/answer/9205520)

[Vue: same CWV thresholds — Nuxt has built-in performance tooling]
[Svelte: same thresholds — SvelteKit generates lean HTML, typically better baseline LCP]

---

## Rule 2: Image Optimization (LCP Impact)

**When**: Adding any image to a React/Next.js application — especially hero images, product photos, or above-the-fold content.

**Decision**: Use `next/image` for all images in Next.js. For non-Next.js: use `<img loading="lazy" decoding="async">` for below-fold; use `fetchpriority="high"` for the LCP image. Always provide explicit `width` and `height` to prevent CLS.

**Threshold**:
- LCP image (largest above-fold image): `priority` prop in `next/image` (or `fetchpriority="high"` in plain HTML)
- All other images: lazy load (default in `next/image`)
- Hero images >200KB uncompressed → convert to WebP or AVIF (typically 30-50% size reduction)
- Images without explicit dimensions → CLS violation

**Anti-pattern**:
```typescript
// ❌ Plain img tag — no optimization, causes CLS
<img src="/hero.jpg" className="hero" />

// ✅ next/image — auto WebP, lazy loading, prevents CLS
import Image from 'next/image'

// For LCP (hero) image:
<Image
  src="/hero.jpg"
  alt="Product hero"
  width={1200}
  height={600}
  priority          // Preloads for LCP — use on above-fold images only
  quality={85}
/>

// For below-fold images:
<Image
  src="/product.jpg"
  alt="Product thumbnail"
  width={400}
  height={300}
  // No priority — lazy loads by default
/>
```

**Source**: [Next.js — Image Component](https://nextjs.org/docs/app/api-reference/components/image); [web.dev — Optimize LCP](https://web.dev/articles/optimize-lcp); [web.dev — CLS](https://web.dev/articles/cls)

[Vue: use `@nuxt/image` for same optimizations in Nuxt; plain Vue apps use explicit width/height + loading="lazy"]
[Svelte: use `@sveltejs/enhanced-img` or explicit width/height attributes]

---

## Rule 3: Code Splitting and Bundle Optimization

**When**: An application's JavaScript bundle exceeds performance thresholds or a route takes >3s to become interactive.

**Decision**: Implement route-based code splitting via dynamic imports. Never load the entire application bundle for a single page.

**Threshold**:
- Initial JS bundle >200KB (gzipped) → aggressive code splitting needed
- Any dynamic import chunk >100KB (gzipped) → split further or evaluate necessity
- Run `bash scripts/bundle-check.sh` — any chunk over threshold is a blocking issue

```typescript
// ✅ Route-based lazy loading (React.lazy + Suspense)
import { lazy, Suspense } from 'react'

const ProductCatalog = lazy(() => import('./pages/ProductCatalog'))
const CheckoutFlow = lazy(() => import('./pages/CheckoutFlow'))

// Usage — Suspense required for lazy components
<Suspense fallback={<PageSkeleton />}>
  <Routes>
    <Route path="/products" element={<ProductCatalog />} />
    <Route path="/checkout" element={<CheckoutFlow />} />
  </Routes>
</Suspense>
```

```typescript
// ✅ Lazy load heavy libraries (date pickers, charts, rich text editors)
const RichTextEditor = lazy(() => import('./components/RichTextEditor'))
// Only loads when rendered — not in initial bundle
```

**Source**: [React documentation — Code-Splitting with lazy and Suspense](https://react.dev/reference/react/lazy); [Next.js — Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading); [web.dev — Reduce JavaScript payloads](https://web.dev/articles/apply-instant-loading-with-prpl)

[Vue: `defineAsyncComponent` for the same pattern; Nuxt handles route-splitting automatically]
[Svelte: SvelteKit handles route-splitting automatically; `import()` for component-level lazy loading]

---

## Rule 4: React Performance — When to Use Memoization

**When**: Encountering performance issues in React — unnecessary re-renders, slow list rendering, expensive calculations on every render.

**Decision**: Use `useMemo` for expensive calculations (>1ms execution time) that depend on specific inputs. Use `useCallback` only when passing callbacks to memoized children. Use `React.memo` only after profiling confirms the component re-renders unnecessarily. Do NOT add memoization preemptively — it adds complexity with no benefit for fast operations.

**Threshold**:
- `useMemo`: calculation takes >1ms AND renders >1× per second → apply
- `React.memo`: component renders unnecessarily (profiler confirms) AND re-render costs >1ms → apply
- `useCallback`: only when the callback is a prop to a `React.memo`-wrapped child — otherwise overhead > benefit

**Anti-pattern**:
```typescript
// ❌ Premature memoization — useMemo on trivial operations
const doubled = useMemo(() => value * 2, [value])  // 0.001ms — useMemo overhead > benefit
const label = useMemo(() => `Hello ${name}`, [name])  // String concat doesn't need memo

// ✅ useMemo for genuinely expensive operations
const sortedAndFiltered = useMemo(
  () => products
    .filter(p => p.category === selectedCategory)
    .sort((a, b) => b.rating - a.rating),  // O(n log n) on large list — worth memoizing
  [products, selectedCategory]
)
```

**Source**: [React documentation — useMemo](https://react.dev/reference/react/useMemo); [React documentation — When to apply useMemo](https://react.dev/reference/react/useMemo#should-you-add-usememo-everywhere); [React DevTools Profiler](https://react.dev/learn/react-developer-tools)

[Vue: `computed` properties are automatically cached — no equivalent anti-pattern]
[Svelte: reactive declarations (`$:`) are automatically lazy — same auto-caching benefit]

---

## Rule 5: Virtualization for Long Lists

**When**: Rendering a list with >100 items in the DOM simultaneously.

**Decision**: Use virtual scrolling (TanStack Virtual or react-window). Rendering 1000 DOM nodes causes layout thrashing and slows interaction response (INP impact).

**Threshold**:
- >100 items rendered simultaneously → implement virtual scrolling
- INP >200ms on a page with a long list → virtual scrolling is likely the fix
- Use `@tanstack/react-virtual` (2026 recommended) — actively maintained, React 19 compatible

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function ProductList({ products }) {
  const parentRef = useRef(null)
  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 120,  // estimated row height
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize(), position: 'relative' }}>
        {virtualizer.getVirtualItems().map(item => (
          <div key={item.key} style={{ position: 'absolute', top: item.start }}>
            <ProductCard product={products[item.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

**Source**: [TanStack Virtual — Getting Started](https://tanstack.com/virtual/latest/docs/framework/react/examples/fixed); [web.dev — Rendering performance](https://web.dev/articles/rendering-performance)

[Vue: vue-virtual-scroller or @tanstack/vue-virtual]
[Svelte: svelte-virtual-list or @tanstack/svelte-virtual]

---

## Rule 6: Font Loading Strategy (CLS Prevention)

**When**: Loading web fonts in any React application.

**Decision**: Always use `font-display: swap` with a defined fallback font stack. Never let a page shift layout when fonts load. Define font metric overrides to reduce layout shift from font substitution.

**Threshold**:
- CLS >0.1 on pages with web fonts → check font loading strategy
- Fonts loaded from external CDN (Google Fonts embed) → switch to self-hosted or `next/font`

**Anti-pattern**:
```html
<!-- ❌ Google Fonts @import in CSS — render-blocking, no size-adjust -->
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter');
</style>

<!-- ✅ next/font — self-hosted, font-display swap, automatic size-adjust for CLS=0 -->
```

```typescript
// ✅ next/font (React 19+ / Next.js 13+)
import { Inter } from 'next/font/google'
const inter = Inter({
  subsets: ['latin'],
  display: 'swap',    // Fallback while loading
  variable: '--font-inter',
})
```

**Source**: [web.dev — Optimize CLS — Font loading](https://web.dev/articles/optimize-cls#fonts); [Next.js — Font Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/fonts); [Google Fonts — font-display](https://developer.chrome.com/docs/lighthouse/performance/font-display)

[Vue: use `@nuxtjs/google-fonts` with `display: 'swap'`; or add `font-display: swap` to CSS @font-face]
[Svelte: SvelteKit — configure in `app.html` with `<link rel="preload">` + CSS `font-display: swap`]
