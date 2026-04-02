# Web Frontend Skills Best Practices — Research Summary

**Sources**: 6 GitHub repositories + 1 cursor rules collection (2026-04-02 Blake research)
**Purpose**: Reference for web-frontend.yaml step design, analysis frameworks, and quality criteria

---

## Repositories Researched

| # | Repository | Stars/Scale | Key Strength |
|---|-----------|-------------|-------------|
| 1 | affaan-m/everything-claude-code (frontend-patterns) | Large collection | Most comprehensive React patterns — hooks, composition, performance, accessibility |
| 2 | anthropics/claude-code (frontend-design plugin) | Official | Design thinking process, bold aesthetic commitment, anti-generic patterns |
| 3 | wsimmonds/claude-nextjs-skills | PoC (32%→78% eval improvement) | 10 Next.js specific skills, App Router patterns, anti-patterns catalog |
| 4 | AlexPEClub/ai-coding-starter-kit | Production template | 6-agent workflow, feature specs, shadcn/ui + Supabase stack, quality gates |
| 5 | Koomook/claude-frontend-skills | npm package | 4-dimensional design: typography, color, motion, backgrounds |
| 6 | PatrickJS/awesome-cursorrules (Next.js + React + shadcn) | 10K+ stars | Coding conventions, RORO pattern, error handling, file naming |

---

## Capability 1: Project Scaffold

**Best Steps (from ai-coding-starter-kit + wsimmonds)**:
1. Choose framework based on requirements (Next.js App Router for most cases, Vite for SPA)
2. Scaffold with `npx create-next-app@latest --typescript --tailwind --eslint --app --src-dir`
3. Install component library: `npx shadcn@latest init` → select style, color, CSS variables
4. Add common components: `npx shadcn@latest add button card input form dialog`
5. Configure TypeScript strict mode: `"strict": true, "noUncheckedIndexedAccess": true`
6. Set up directory structure: `src/app/`, `src/components/ui/`, `src/hooks/`, `src/lib/`

**Best Quality Standards (from cursorrules + ai-coding-starter-kit)**:
- TypeScript strict mode enabled
- ESLint configured with no errors
- Project builds successfully (`npm run build`)
- Directory structure follows Next.js App Router conventions
- `src/components/ui/` contains shadcn components

**Anti-patterns**:
- ❌ Using Pages Router instead of App Router (wsimmonds: 10/50 eval failures from Pages Router patterns)
- ❌ Starting without TypeScript (cursorrules: "Use TypeScript for all code")
- ❌ No ESLint configuration (ai-coding-starter-kit: linting is mandatory)
- ❌ Flat file structure without src/ directory separation

---

## Capability 2: Component Development

**Best Steps (from everything-claude-code + cursorrules)**:
1. Define component interface with TypeScript (interfaces over types, avoid enums → use maps)
2. Use functional components with `function` keyword (not const arrow)
3. Implement composition pattern: props + children, compound components with Context
4. Add proper loading/error states (Suspense boundaries, error.tsx)
5. Ensure accessibility: keyboard navigation, ARIA attributes, focus management

**Best Analysis Framework (from everything-claude-code)**:
- Composition over inheritance (React functional components)
- Compound component pattern for shared state
- Render props for flexible presentation
- Custom hooks for reusable logic (useToggle, useDebounce, useQuery patterns)

**Best Quality Standards (from cursorrules)**:
- "Use function, not const, for components"
- "Prefer interfaces over types. Avoid enums, use maps."
- Structure: Exported component → subcomponents → helpers → static content → types
- Handle errors at function start, happy path last (guard clauses)
- Descriptive variable names with auxiliary verbs (isLoading, hasError)

**Anti-patterns (from wsimmonds + cursorrules)**:
- ❌ Using `useEffect` for data fetching (use Server Components instead)
- ❌ Excessive `'use client'` — minimize client components, favor RSC
- ❌ Class-based components or inheritance patterns
- ❌ Not wrapping client components in Suspense with fallback
- ❌ Serial awaits — parallelize async operations

---

## Capability 3: State Management

**Best Steps (from everything-claude-code + cursorrules)**:
1. Evaluate state scope: server state vs client state vs URL state
2. Server state → Server Components + React Query/SWR for client-side cache
3. Client global state → Zustand (lightweight) or Context + useReducer (built-in)
4. URL state → `useSearchParams` with Suspense boundary
5. Form state → react-hook-form + Zod validation

**Best Analysis Framework (from cursorrules)**:
- "Minimize 'use client', 'useEffect', and 'setState'. Favor RSC."
- "Rely on Next.js App Router for state changes"
- Use `useActionState` with react-hook-form for server actions
- Use next-safe-action with Zod input schemas

**Quality Standards**:
- Zero unnecessary re-renders (verified via React DevTools)
- State colocation: state lives closest to where it's used
- No prop drilling beyond 2 levels → use Context or Zustand
- All form validation uses Zod schemas

**Anti-patterns**:
- ❌ Global state for server-fetched data (use Server Components)
- ❌ Prop drilling through 3+ component levels
- ❌ Multiple competing state management libraries in one project
- ❌ Storing derived state (compute from source instead)

---

## Capability 4: API Integration

**Best Steps (from ai-coding-starter-kit + cursorrules)**:
1. Define API contract (OpenAPI spec if available)
2. Generate TypeScript types from spec: `npx openapi-typescript api.yaml -o types.ts`
3. Create API layer in `src/lib/api/` with typed fetch wrappers
4. Implement Server Actions with next-safe-action + Zod validation
5. Use React Query/SWR for client-side data fetching with cache
6. Handle errors as return values (ActionResponse pattern), not try/catch

**Best Analysis Framework (from cursorrules)**:
- Server Actions → `next-safe-action` with Zod input schema → ActionResponse
- Expected errors are return values, not exceptions
- Services directory code throws user-friendly errors
- Use `tanStackQuery` for data caching

**Quality Standards**:
- All API responses typed (no `any`)
- Error handling at every fetch point
- Loading states for all async operations
- Retry logic for transient failures

**Anti-patterns**:
- ❌ Using route handlers when Server Actions suffice (wsimmonds eval finding)
- ❌ Untyped API responses (`any` type)
- ❌ Missing error handling on fetch calls
- ❌ Client-side data fetching when Server Components can do it

---

## Capability 5: Styling

**Best Steps (from claude-frontend-skills + cursorrules + anthropics/claude-code)**:
1. Configure Tailwind with project tokens: `tailwind.config.ts` → custom colors, fonts, spacing
2. Define Design Tokens as CSS variables (`:root { --color-primary: ... }`)
3. Use mobile-first responsive design approach
4. Typography: distinctive font pairing (display + body), extreme weight contrast (200 vs 900)
5. Motion: orchestrated page-load sequences with staggered delays
6. Backgrounds: layer gradients, textures, atmospheric elements for depth

**Best Analysis Framework (from anthropics/claude-code frontend-design)**:
- 4-dimensional design: Typography, Color/Theme, Motion, Spatial Composition
- "Bold maximalism OR refined minimalism — intentionality matters, not intensity"
- "Dominant colors with sharp accents outperform evenly-distributed palettes"
- "One well-orchestrated page load beats scattered micro-interactions"

**Quality Standards (from claude-frontend-skills)**:
- No default system fonts as primary display fonts
- Responsive on mobile/tablet/desktop
- CSS variables for all design tokens
- Consistent spacing system (4px/8px base)

**Anti-patterns (from anthropics/claude-code + claude-frontend-skills)**:
- ❌ Inter/Roboto as display fonts (generic AI aesthetic)
- ❌ Purple gradients on white (clichéd AI color scheme)
- ❌ "Safe" font weights (400, 500, 600) — use extreme contrast
- ❌ Cookie-cutter layouts without context-specific character
- ❌ Flat white/gray backgrounds without atmosphere
- ❌ Converging on same aesthetic across projects (Space Grotesk trap)

---

## Capability 6: Build Optimization

**Best Steps (from cursorrules + wsimmonds)**:
1. Analyze current bundle: `npx vite-bundle-visualizer` or webpack-bundle-analyzer
2. Code splitting: dynamic imports with `next/dynamic` for non-critical components
3. Image optimization: WebP format, size data, lazy loading (Next.js Image component)
4. Prioritize Web Vitals: LCP, CLS, FID
5. Tree shaking: ensure proper ES module imports (named, not wildcard)
6. Cache optimization: leverage Next.js cache directives

**Best Quality Standards (from cursorrules)**:
- "Prioritize Web Vitals (LCP, CLS, FID)"
- "Optimize images: WebP format, size data, lazy loading"
- Dynamic loading for non-critical components
- No serial awaits in server components

**Anti-patterns**:
- ❌ Importing entire libraries when only a few functions needed
- ❌ Missing `loading.tsx` for route segments
- ❌ Not using Next.js Image component (raw `<img>` tags)
- ❌ Synchronous/serial data fetching when parallelizable

---

## Capability 7: Code Quality

**Best Steps (from ai-coding-starter-kit + cursorrules)**:
1. ESLint: configure with Next.js + TypeScript rules, `npx eslint .`
2. TypeScript: strict mode check `npx tsc --noEmit`
3. Prettier: consistent formatting `npx prettier --check .`
4. File naming: lowercase with dashes for directories (e.g., `components/auth-wizard`)
5. Favor named exports for components
6. Error boundaries: `error.tsx` and `global-error.tsx` per Next.js convention

**Best Analysis Framework (from cursorrules)**:
- RORO pattern: Receive an Object, Return an Object
- Guard clauses at function start, happy path last
- Favor iteration and modularization over duplication
- "Always read, never guess" — read files before modifying (ai-coding-starter-kit)

**Quality Standards**:
- `npx tsc --noEmit` → zero errors
- `npx eslint .` → zero errors
- `npx prettier --check .` → zero diff
- `npm run build` → success
- No `any` types in codebase

**Anti-patterns**:
- ❌ Using `any` type (use `unknown` + type guards)
- ❌ Ignoring ESLint warnings with `// eslint-disable`
- ❌ Inconsistent naming (mixing camelCase/kebab-case for files)
- ❌ Not using error boundaries for route segments

---

## Cross-Cutting Patterns

### From ai-coding-starter-kit: Development Workflow
```
1. /requirements → Feature spec with acceptance criteria
2. /architecture → Technical design (no code)
3. /frontend → UI implementation (sub-agent)
4. /backend → API implementation (sub-agent, parallel)
5. /qa → Testing against acceptance criteria
6. /deploy → Production deployment
```

### From wsimmonds: Next.js App Router Rules (10 skills, 78% eval pass rate)
1. Prefer Server Components over client
2. Prefer Server Actions over Route Handlers
3. Use Suspense boundaries for streaming
4. Use `next/link` over `<a>`, `next/image` over `<img>`
5. Implement metadata API for SEO
6. Avoid `useEffect` for data fetching
7. Parallelize async operations (no serial awaits)
8. Use proper error/loading boundary files
9. Leverage cache directives
10. Migrate from Pages Router patterns

### From cursorrules: Universal Code Standards
- TypeScript interfaces > types > enums (never)
- Function declarations > arrow functions (for components)
- Named exports > default exports
- Guard clauses > nested conditionals
- Descriptive names with auxiliaries (isLoading, hasError, canSubmit)
