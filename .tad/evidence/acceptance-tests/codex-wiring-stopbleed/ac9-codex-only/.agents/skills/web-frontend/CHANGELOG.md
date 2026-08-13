# Changelog

All notable changes to this capability pack will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] — 2026-05-08

### Added
- Initial release: 41 judgment rules across 7 dimensions
- `references/component-architecture.md` — 7 rules (RSC, composition, headless, FSD, micro-frontends)
- `references/state-management.md` — 6 rules (selection matrix, local/global/server separation, Zustand selectors)
- `references/design-tokens.md` — 6 rules (DTCG pipeline, Style Dictionary, DESIGN.md consumption)
- `references/styling.md` — 5 rules (Tailwind vs CSS Modules, responsive, container queries, dark mode)
- `references/performance.md` — 6 rules (CWV thresholds, images, code splitting, memoization, virtualisation)
- `references/accessibility.md` — 6 rules (semantic HTML, top axe failures, headless UI, alt text, focus management)
- `references/testing.md` — 5 rules (pyramid, behavioral testing, stable locators, a11y tests, Storybook)
- `checklists/frontend-quality.md` — 3-tier quality checklist (Tier 1: automatable, Tier 2: attestation, Tier 3: infra)
- `scripts/lighthouse-check.sh` — Core Web Vitals measurement via Lighthouse CLI
- `scripts/a11y-scan.sh` — Accessibility scan via axe-core CLI
- `scripts/bundle-check.sh` — Bundle size budget check
- `CAPABILITY.md` — Context-sensitive router with DESIGN.md consumption (Step 0)
- `CONVENTIONS.md` — React naming conventions, Next.js App Router directory structure
- `install.sh` — Installer with `--agent` flag and Phase 3 stubs (codex/cursor/gemini → exit 2)

### Research Foundation
- NotebookLM notebook `430044a7-d808-4a70-9969-24e00c92da8d` — 299 sources
- Key sources: Shopify Polaris, Adobe React Aria, Radix UI, TanStack Query/Virtual, Amazon Style Dictionary, axe-core, Google web-vitals, React Testing Library
