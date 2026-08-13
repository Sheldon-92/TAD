# Component Library Selection Matrix

Use this matrix to choose the right component library for your project.
**Universal options first** (no framework required); framework-specific as branches.

---

## Selection Guide

**Start with these questions:**
1. Does your project have a framework requirement? → If no, use Universal options
2. Do you need copy-paste control of component code? → shadcn/ui
3. Do you need zero JS overhead? → DaisyUI or Pico.css
4. Do you need AAA accessibility + multi-framework? → Ark UI
5. Are you already on MUI / Chakra? → Migrate to headless when capacity allows

---

## Comparison Matrix

| Library | Type | A11y | Bundle | Framework | Best For |
|---------|------|------|--------|-----------|---------|
| Ark UI | Headless | AAA | ~3KB/component | React, Vue, Solid, Svelte | Multi-framework, full control |
| DaisyUI | CSS Plugin | Good | ~20KB | Framework-agnostic + Tailwind | Rapid prototyping, CSS-only |
| Radix UI | Headless | AAA | 3–5KB/component | React only | React projects, WAI-ARIA |
| Headless UI | Headless | AAA | ~4KB/component | React, Vue + Tailwind | Tailwind projects |
| shadcn/ui | Copy-paste | AAA | 10–20KB | React/Next.js + Tailwind | Full control, customizable |
| MUI | Styled | AA | 100–200KB | React only | Enterprise CRUD apps |
| Chakra UI | Styled | AA+ | ~40KB | React only | Rapid dev with theming |
| Mantine | Styled | AA | ~60KB | React only | Feature-rich apps |

---

## Universal Libraries (No Framework Required)

### Ark UI
**Type**: Headless components
**A11y**: AAA — full WAI-ARIA compliance
**Bundle**: ~3KB per component
**Framework support**: React, Vue, Solid, Svelte

Choose when:
- Your stack is not React-only
- You need full styling control
- Accessibility is non-negotiable

```bash
# React
npm install @ark-ui/react

# Vue
npm install @ark-ui/vue

# Solid
npm install @ark-ui/solid

# Svelte
npm install @ark-ui/svelte
```

Components: Accordion, Checkbox, Combobox, Dialog, Menu, Select, Slider, Switch, Tabs, Tooltip, and 30+ more.

---

### DaisyUI
**Type**: Tailwind CSS plugin — no JavaScript
**A11y**: Good (relies on semantic HTML)
**Bundle**: ~20KB base
**Framework support**: Any (or none)

Choose when:
- Speed of prototyping matters
- No JS framework in use
- Semantic HTML is the base

```bash
npm install daisyui
# Add to tailwind.config.js:
# plugins: [require("daisyui")]
```

Usage (no framework needed):
```html
<button class="btn btn-primary">Click me</button>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body"><h2 class="card-title">Title</h2></div>
</div>
```

---

### Pico.css
**Type**: Class-less CSS framework
**A11y**: AA (semantic HTML auto-styled)
**Bundle**: ~10KB
**Framework support**: Any

Choose when:
- AI generates semantic HTML and you want instant styling
- No classes = minimal LLM token cost
- Prototyping without design decisions

```bash
npm install @picocss/pico
```

Usage (zero classes needed):
```html
<nav><ul><li><a href="/">Home</a></li></ul></nav>
<main><article><h1>Title</h1><p>Content</p></article></main>
```

---

## React Libraries

### Radix UI Primitives
**Type**: Headless, unstyled
**A11y**: AAA — built to WAI-ARIA spec
**Bundle**: 3–5KB per component
**Framework**: React only

Choose when:
- React project requiring maximum accessibility
- Building a custom design system on top

```bash
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-select
```

---

### shadcn/ui
**Type**: Copy-paste — you own the code
**A11y**: AAA (uses Radix UI primitives)
**Bundle**: 10–20KB (only what you add)
**Framework**: React/Next.js + Tailwind CSS

Choose when:
- React + Tailwind project
- You want to own and customize component code
- You need a quick but high-quality starting point

```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add button dialog dropdown-menu input card badge
```

Distinctive feature: components are copied into `src/components/ui/` — you edit them directly.

---

### Headless UI
**Type**: Headless, Tailwind-native
**A11y**: AAA
**Bundle**: ~4KB per component
**Framework**: React, Vue + Tailwind CSS

Choose when:
- Already using Tailwind CSS
- Need React or Vue (not multi-framework)

```bash
# React
npm install @headlessui/react

# Vue
npm install @headlessui/vue
```

---

## Styled Libraries (Opinionated)

Use these when speed of development outweighs design system flexibility.
**Warning**: migrating away from styled libraries is costly. Prefer headless for new projects.

### MUI (Material UI)
**A11y**: AA
**Bundle**: 100–200KB (large)
**Framework**: React only

Best for: Enterprise dashboards, Google Material compliance requirements.

```bash
npm install @mui/material @emotion/react @emotion/styled
```

---

### Chakra UI
**A11y**: AA+
**Bundle**: ~40KB
**Framework**: React only

Best for: Rapid development where design polish is secondary.

```bash
npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion
```

---

### Mantine
**A11y**: AA
**Bundle**: ~60KB
**Framework**: React only

Best for: Feature-rich apps needing many pre-built components.

```bash
npm install @mantine/core @mantine/hooks
```

---

## Decision Flowchart

```
Need components?
│
├── Have a framework?
│   ├── React only?
│   │   ├── Need copy-paste control? → shadcn/ui
│   │   ├── Need AAA + headless?    → Radix UI
│   │   ├── Need styled/fast?       → Chakra UI or Mantine
│   │   └── Enterprise/Material?    → MUI
│   │
│   ├── Multi-framework (React + Vue + Solid)?
│   │   └── → Ark UI
│   │
│   └── Framework-agnostic / React + Vue?
│       └── With Tailwind? → Headless UI / DaisyUI
│
└── No framework?
    ├── Need interactions? → DaisyUI (CSS) or Ark UI
    └── Semantic HTML only? → Pico.css (class-less)
```

---

## Accessibility Ratings Explained

| Rating | Meaning |
|--------|---------|
| AAA | Full WAI-ARIA spec compliance, keyboard navigation, screen reader tested |
| AA+ | Exceeds WCAG AA; minor WAI-ARIA gaps |
| AA | Meets WCAG AA; basic keyboard navigation |
| Good | Accessible with semantic HTML; limited ARIA |
