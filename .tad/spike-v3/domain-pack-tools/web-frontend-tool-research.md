# Web Frontend Tool Research — Test Results

**Date**: 2026-04-02
**Environment**: macOS, Node v24.7.0, npm 11.5.1

---

## Tools Tested

| # | Tool | Install | Verify | Test Result | Status |
|---|------|---------|--------|-------------|--------|
| 1 | create-next-app | `npx create-next-app@latest` | N/A (scaffolds project) | Full project with src/, App Router, TS, Tailwind, ESLint in ~20s | PASS |
| 2 | shadcn CLI | `npx shadcn@latest init -d` | N/A (adds components) | Init created button.tsx + utils.ts; `add card input` created 2 components | PASS |
| 3 | ESLint | Included with create-next-app | `npx eslint --version` → 10.1.0 | `npx eslint . --max-warnings 0` → zero errors on fresh scaffold | PASS |
| 4 | TypeScript (tsc) | Included with create-next-app | `npx tsc --version` | `npx tsc --noEmit` → zero errors on fresh scaffold | PASS |
| 5 | Prettier | `npx prettier` | `npx prettier --version` → 3.8.1 | `npx prettier --check "src/**"` correctly detects formatting issues | PASS |
| 6 | openapi-typescript | `npx openapi-typescript` | auto-downloads 7.13.0 | Generates typed interfaces from OpenAPI YAML in 21ms | PASS |
| 7 | npm run build | Included with Next.js | N/A | Build succeeds, outputs static pages | PASS |

## Tools Not Tested (already in registry)

- typst, d2, matplotlib — already tested in product-definition research
- pa11y, style-dictionary, svgo, playwright-screenshot — already tested in web-ui-design research

## Tools Deferred

- `create-vite` — alternative scaffold, same mechanism as create-next-app, lower priority
- `vite-bundle-visualizer` — requires a vite project with actual code to analyze

## Key Findings

1. **create-next-app** is the most complete scaffold: TS + Tailwind + ESLint + App Router in one command
2. **shadcn CLI** integrates seamlessly after scaffold, `-d` flag auto-detects config
3. **ESLint + tsc** come free with create-next-app, no extra install needed
4. **openapi-typescript** auto-downloads via npx, no global install required
5. **Prettier** detects shadcn-generated code style differences (expected, can `--write` to fix)

## Registry Entries to Add

8 new entries for tools-registry.yaml:
1. `project_scaffold` → create-next-app (recommended) + create-vite (alternative)
2. `component_library` → shadcn CLI
3. `api_type_generation` → openapi-typescript
4. `code_linting` → ESLint
5. `type_checking` → TypeScript (tsc)
6. `code_formatting` → Prettier
7. `bundle_analysis` → vite-bundle-visualizer
8. `build_verification` → npm run build (built-in)
