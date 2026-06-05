---
name: web-frontend
description: Web frontend engineering judgment for React — component architecture, state management, design token consumption, styling, performance, accessibility, testing, and visual-code bridge. Loads DESIGN.md when present and turns design artifacts into production-grade code.
keywords: ["React", "frontend", "component", "CSS", "TypeScript", "前端", "组件", "状态管理", "performance", "accessibility", "WCAG", "visual edit", "browser edit", "UI polish", "visual bridge"]
type: reference-based
---

# Web Frontend Capability Pack

**CONSUMES**: Design artifacts (DESIGN.md + tokens from web-ui-design) + optional existing React codebase
**PRODUCES**: Production-grade React code + component library + performance audit results

> This pack CONSUMES design artifacts. It does NOT create them.
> Use the web-ui-design pack to produce DESIGN.md, tokens, and palettes.
> Use this pack to turn those artifacts into production-grade React code.

React-first. Vue/Svelte equivalents noted in [brackets] where applicable.

---

## Step 0: DESIGN.md Detection (always run first)

Before routing, check if the project has a DESIGN.md file:

```
Locations to check (in order):
  1. ./DESIGN.md
  2. ./design/DESIGN.md
  3. ./.design/DESIGN.md
```

**If DESIGN.md found**, extract structured values:

(a) **CSS custom properties** — scan for `--color-*`, `--spacing-*`, `--font-*`, `--radius-*` declarations. Use these as constraints for all color, spacing, and typography decisions.

(b) **W3C DTCG token JSON** — if DESIGN.md references a `tokens.json` path (e.g., `tokens/tokens.json`), read that file and extract token values by category (`color`, `spacing`, `typography`, `borderRadius`).

(c) **Tailwind config values** — if DESIGN.md references a `tailwind.config.ts/js` path, read the `theme.extend` section and use those values as design constraints.

If DESIGN.md contains only prose without structured tokens: proceed without design constraints. The pack works standalone.

**If DESIGN.md not found**: proceed without design constraints. The pack works standalone.

---

## Step 1: Context Detection → Load Reference

Read the user's request and route to the correct reference file:

| User says… | Load reference |
|-----------|---------------|
| "component / split / compose / refactor UI / RSC / server component / boundary" | [`references/component-architecture.md`](references/component-architecture.md) |
| "state / fetch / cache / store / zustand / jotai / query / react context / context api" | [`references/state-management.md`](references/state-management.md) |
| "token / design system / DESIGN.md / brand / DTCG / style dictionary" | [`references/design-tokens.md`](references/design-tokens.md) |
| "style / css / tailwind / theme / dark mode / module / scss" | [`references/styling.md`](references/styling.md) |
| "slow / performance / bundle / lighthouse / CWV / vitals / LCP / INP" | [`references/performance.md`](references/performance.md) |
| "accessible / a11y / screen reader / aria / wcag / axe / keyboard" | [`references/accessibility.md`](references/accessibility.md) |
| "test / coverage / storybook / playwright / vitest / testing library" | [`references/testing.md`](references/testing.md) |
| "visual edit / browser edit / fix this element / UI polish / visual bridge / 看到的 / 这个元素 / 改这里" | [`references/visual-code-bridge.md`](references/visual-code-bridge.md) |
| "new project / scaffold / setup / conventions" | Load [`CONVENTIONS.md`](CONVENTIONS.md) + all references |
| "review / audit / quality check / checklist" | Load [`checklists/frontend-quality.md`](checklists/frontend-quality.md) |

**Disambiguation**: if multiple references match, load the FIRST matching row AND announce the other matches:
> "I've loaded [reference A] for your question. This also touches [reference B] — should I load that too?"

If the user confirms, load the second reference. Do NOT preemptively load all matches — load on confirmation only.

---

## Step 2: Apply Judgment Rules

Read the loaded reference and apply the judgment rules to the user's specific situation. Rules have explicit thresholds — apply them literally, not as "guidelines."

Anti-skip table: these steps are NEVER optional even for small tasks:

| Skippable? | Check |
|-----------|-------|
| ❌ Never | DESIGN.md detection (Step 0) |
| ❌ Never | Rule thresholds — if a rule says "≥50 components" the threshold applies |
| ❌ Never | Source references — rules are grounded in real specifications |
| ⚠️ Judgment | Loading multiple references — only if user's task genuinely spans dimensions |

---

## Step 3: Validate with Scripts (when applicable)

For performance checks:
```bash
bash scripts/lighthouse-check.sh http://localhost:3000
```

For accessibility scans:
```bash
bash scripts/a11y-scan.sh http://localhost:3000
```

For bundle size checks:
```bash
bash scripts/bundle-check.sh
```

Scripts require the app to be running. They do NOT start a server.

---

## Pack Design

**Interface contract with web-ui-design pack:**

| web-ui-design produces | web-frontend consumes |
|----------------------|----------------------|
| DESIGN.md | Step 0: Parse and extract tokens |
| tokens.json (DTCG) | design-tokens.md: Transform via Style Dictionary |
| Color palette | styling.md: Apply as CSS custom properties |
| Spacing scale | component-architecture.md: Layout constraints |
| Typography | CONVENTIONS.md: Font loading strategy |

**This pack NEVER touches**: color selection, typography pairing, wireframe layout, brand identity decisions.

**web-ui-design pack NEVER touches**: component code, state management, build configuration, test strategy.
