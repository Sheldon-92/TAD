# React Project Conventions

React-first naming, directory structure, and code patterns for production applications. Next.js App Router conventions unless noted.

[If Vue: use `<component>.vue` single-file components; PascalCase for component names; `composables/` for shared logic]
[If Svelte: `.svelte` files; PascalCase components; `lib/` for shared utilities]

---

## Directory Structure

### Next.js App Router (recommended default)

```
src/
├── app/                    # Next.js App Router pages and layouts
│   ├── layout.tsx          # Root layout (fonts, providers, metadata)
│   ├── page.tsx            # Root page
│   ├── (auth)/             # Route group — no URL segment
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   └── dashboard/
│       ├── layout.tsx      # Nested layout
│       └── page.tsx
│
├── components/             # Shared UI components
│   ├── ui/                 # Primitive components (Button, Input, Card)
│   │   ├── Button.tsx
│   │   ├── Button.module.css   # Co-located styles (CSS Modules pattern)
│   │   └── Button.test.tsx     # Co-located tests
│   └── features/           # Feature-specific composite components
│       └── UserProfile/
│           ├── index.tsx
│           └── UserProfile.test.tsx
│
├── lib/                    # Shared utilities, constants, helpers
│   ├── api/                # API client functions
│   ├── hooks/              # Custom hooks (use* naming)
│   └── utils/              # Pure utility functions
│
├── store/                  # Global state (Zustand stores)
│   └── useAppStore.ts
│
├── types/                  # Shared TypeScript types
│   └── index.ts
│
└── styles/                 # Global styles
    ├── globals.css         # CSS reset + custom properties
    └── tokens.css          # Design tokens from DESIGN.md pipeline
```

### Feature-Sliced Design (for apps >50 components)

```
src/
├── app/            # App-level initialization, providers, router
├── pages/          # Page-level components (Next.js: app/ directory)
├── widgets/        # Self-contained UI blocks (Header, Sidebar, Feed)
├── features/       # User scenarios (auth, checkout, search)
├── entities/       # Business objects (user, product, order)
└── shared/         # Reusable primitives (ui/, lib/, api/)
```

Rule: layers can only import from layers BELOW them. `features` can import `entities` and `shared`. `entities` cannot import `features`.

---

## Naming Conventions

### Components

```typescript
// ✅ PascalCase — components are nouns
Button.tsx
UserProfileCard.tsx
NavigationMenu.tsx

// ✅ Default export for single component per file
export default function Button({ children, onClick, variant = 'primary' }: ButtonProps) {
  return <button className={styles[variant]} onClick={onClick}>{children}</button>
}

// ✅ Named exports for component + types in same file
export interface ButtonProps {
  children: React.ReactNode
  onClick?: () => void
  variant?: 'primary' | 'secondary' | 'ghost'
}
export default function Button(props: ButtonProps) { ... }
```

### Hooks

```typescript
// ✅ use* prefix — always returns something
useAuth.ts        // returns { user, login, logout }
useCartItems.ts   // returns { items, addItem, removeItem, total }

// ✅ Custom hooks encapsulate logic, not just state
function useCartItems() {
  const items = useStore(state => state.cartItems)  // Zustand selector
  const addItem = useStore(state => state.addItem)
  const total = useMemo(() => items.reduce((sum, item) => sum + item.price, 0), [items])
  return { items, addItem, total }
}
```

### Files and Folders

```
// ✅ PascalCase for components
Button.tsx
UserProfile.tsx

// ✅ camelCase for utilities, hooks, stores
formatDate.ts
useScrollPosition.ts
useProductStore.ts

// ✅ kebab-case for Next.js App Router segments (URL-safe)
app/user-profile/page.tsx    → /user-profile
app/product-catalog/page.tsx → /product-catalog

// ✅ Co-locate tests and styles with components
Button.tsx
Button.test.tsx
Button.module.css
```

---

## TypeScript Patterns

### Component Props

```typescript
// ✅ Inline interface, exported when consumed by other files
interface CardProps {
  title: string
  description?: string            // Optional: use ?
  children: React.ReactNode       // Use React.ReactNode for JSX children
  className?: string              // Allow className extension
  onClick?: (event: React.MouseEvent<HTMLDivElement>) => void
}

// ✅ Spread native HTML props for primitive wrapper components
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary'
  loading?: boolean
}
```

### Server vs Client Components (Next.js App Router)

```typescript
// ✅ Default: Server Component (no 'use client' directive)
// Can use: async/await, database, fs, server-only packages
// Cannot use: useState, useEffect, event handlers, browser APIs
async function ProductPage({ params }: { params: { id: string } }) {
  const product = await db.product.findUnique({ where: { id: params.id } })
  return <ProductDetail product={product} />
}

// ✅ 'use client' only on interactive leaf components
'use client'
import { useState } from 'react'

function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  // ...
}
```

### Async Data Fetching (TanStack Query)

```typescript
// ✅ useSuspenseQuery for React 19+ (or useQuery for compatibility)
import { useQuery } from '@tanstack/react-query'

function useProduct(id: string) {
  return useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
    staleTime: 5 * 60 * 1000,  // 5 minutes — products change infrequently
  })
}
```

---

## Font Loading (Next.js)

```typescript
// ✅ Always use next/font — eliminates layout shift (CLS), self-hosted, no third-party requests
import { Inter, Roboto_Mono } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',    // CSS custom property for token pipeline
  display: 'swap',             // Fallback font while loading
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

```css
/* globals.css — use the variable from DESIGN.md token pipeline */
body {
  font-family: var(--font-inter), var(--font-fallback, system-ui);
}
```

---

## Import Order

```typescript
// 1. React and framework imports
import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'

// 2. Third-party libraries
import { useQuery } from '@tanstack/react-query'
import { clsx } from 'clsx'

// 3. Internal absolute imports (configured in tsconfig)
import { Button } from '@/components/ui'
import { useAuth } from '@/lib/hooks'

// 4. Relative imports
import { ProductCard } from './ProductCard'
import styles from './ProductList.module.css'

// 5. Types (at the end, or inline where used)
import type { Product } from '@/types'
```

---

## Code Quality

- **No `any` type** — use `unknown` and narrow, or create a proper type
- **No `// @ts-ignore`** — fix the underlying type issue
- **No inline styles** except for dynamic values from JS (e.g., `style={{ width: progress + '%' }}`)
- **No magic strings** — extract to named constants
- **Explicit return types** on exported functions
- **`data-testid` attributes** on interactive elements for stable test locators

[If Vue: use `defineProps` with TypeScript generics; avoid Options API for new code; use `<script setup>` syntax]
[If Svelte: use TypeScript in `<script lang="ts">`; stores via `writable`/`derived` from `svelte/store`]
