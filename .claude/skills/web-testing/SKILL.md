---
name: web-testing
description: Web testing capability pack. Gives AI agents the judgment rules for unit testing (Vitest Browser Mode), API contract testing (Pact/OpenAPI), performance auditing (Core Web Vitals/k6), accessibility compliance (axe-core/Pa11y), human-AI pair testing (4D Protocol), and test strategy design (pyramid/CI/CD pipeline). Research-grounded rules from Playwright, Vitest, k6, axe-core, MSW, and Pact documentation. Use for any web application testing, test infrastructure setup, or quality assurance task.
keywords: ["测试", "testing", "test", "单元测试", "unit test", "E2E", "端到端", "API 测试", "api test", "性能测试", "performance", "可访问性", "accessibility", "a11y", "WCAG", "pair testing", "配对测试", "Playwright", "Vitest", "k6", "axe-core", "测试策略", "test strategy", "coverage", "覆盖率"]
type: reference-based
---

**CONSUMES**: User testing task + project tech stack + optional existing test configs
**PRODUCES**: Applied testing judgment rules + test configs + CI/CD pipeline configs + accessibility audit results + performance budgets + pair testing session reports

# Web Testing Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents write tests by copying tutorial examples. They reach for E2E tests first because they look impressive, building an inverted pyramid that takes 30 minutes to run and breaks on every CSS rename. They skip contract testing, so API changes break consumers silently. They mock everything, so tests pass while the real system fails. They declare "80% coverage" without per-module targets, hiding untested business logic behind tested getters.

This pack embeds the judgment rules that test engineers apply automatically -- rules from real testing frameworks, performance measurement tools, accessibility audit standards, and CI/CD pipeline design.

**Pack = testing judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Fastest-Fail-First Pipeline Ordering

> **When ordering test stages in a CI/CD pipeline, run cheaper/faster tests first: lint/typecheck (<10s) -> unit (<30s) -> integration (2-10min) -> E2E (10-30min) -> performance/a11y (nightly).** Each stage gates the next -- a unit test failure at 15 seconds saves 25 minutes of E2E time. Sharding (`npx playwright test --shard=1/4`) compresses E2E from 20min to 5min.

This rule applies to: CI/CD pipeline design, PR gates, merge checks, and nightly runs. It is surfaced here because agents default to running everything in parallel without gating, wasting CI minutes on doomed builds.

---

## Step 0: Context Detection

When the user mentions testing work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "unit test", "component test", "Vitest", "coverage", "snapshot", "MSW", "mock", "单元测试" | `references/unit-testing-rules.md` |
| "API test", "contract test", "Pact", "OpenAPI", "schema validation", "k6", "load test", "API 测试" | `references/api-testing-rules.md` |
| "performance", "Lighthouse", "Core Web Vitals", "LCP", "CLS", "INP", "k6 threshold", "性能测试" | `references/performance-testing-rules.md` |
| "accessibility", "a11y", "WCAG", "axe-core", "Pa11y", "contrast", "screen reader", "可访问性" | `references/accessibility-testing-rules.md` |
| "pair test", "4D Protocol", "exploratory", "session", "human+AI", "配对测试" | `references/pair-testing-rules.md` |
| "test strategy", "testing pyramid", "CI/CD pipeline", "sharding", "flaky", "AI code testing", "测试策略" | `references/test-strategy-rules.md` |
| "full testing", "complete test setup", "test everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** -- do not skim
2. **Apply each rule as a judgment check** against the user's test setup, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce the Fastest-Fail-First cross-cutting rule** on every CI/CD pipeline configuration
5. **Check test level appropriateness** -- are tests at the right pyramid level?
   - Business logic in E2E instead of unit = wrong level
   - API schema checks in unit instead of contract = wrong level
   - Visual regression in unit instead of E2E = wrong level

Output format per finding:
```
[P0] Rule U3 (unit-testing): Snapshot test is 47 lines -- inline snapshots must be 3-7 lines max.
-> Replace with toMatchScreenshot for visual regression or extract assertion on specific fields.

[P1] Rule S2 (test-strategy): All modules have same 80% coverage target -- business logic needs 90%, UI can be 60%.
-> Set per-module targets: auth 90%, utils 80%, components 60%.
```

---

## Step 2: Output

Produce a structured testing review:

```
## Testing Review: [area reviewed]

### P0 -- Blocking (must fix before merging)
- [finding + specific fix]

### P1 -- Required (fix before trusting results)
- [finding + specific fix]

### P2 -- Advisory (improves test quality)
- [finding + specific fix]

### Test Level Audit
[table of test areas with their current vs recommended pyramid level]

### Tool Recommendation
[Vitest / Playwright / k6 / axe-core based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We only need E2E tests" | E2E-only is the ice cream cone anti-pattern. A 30-test E2E suite takes 20+ minutes and breaks on CSS changes. Unit tests catch logic bugs in <30 seconds. |
| "We'll add tests later" | Code without tests accumulates debt at compound interest. Retrofit testing costs 3-5x more than test-first. Start with 3-5 critical flow E2E tests + unit tests on business logic. |
| "80% coverage is enough" | Global 80% hides untested auth at 40% behind tested getters at 100%. Set per-module targets: auth 90%, business logic 80%, UI components 60%. |
| "Mocking everything is fine" | Over-mocking tests your mocks, not your code. Mock boundaries (network via MSW, modules via vi.mock), not implementations. If you mock the database AND the API AND the auth, what are you actually testing? |
| "Accessibility testing is optional" | Automated a11y catches 30-50% of WCAG issues (57% by volume per Deque, n=550 audits). The top 5 failures (alt text, contrast, form labels, links, ARIA) are all automatable. Zero effort for half the bugs. |
| "Our tests pass so quality is fine" | Passing tests prove nothing about coverage gaps. Mutation testing (Stryker) verifies that tests actually catch bugs. AI-generated code can fool line coverage metrics while hiding logic errors. |

---

## Tool Quick Reference

| Tool | Install | Primary Use |
|------|---------|-------------|
| Playwright | `npm i -D @playwright/test && npx playwright install` | E2E testing, screenshots, tracing |
| Vitest | `npm i -D vitest @vitest/coverage-v8` | Unit + component testing |
| Vitest Browser Mode | `npm i -D @vitest/browser-playwright` | Real-browser component tests |
| MSW | `npm i -D msw` | Network mocking at service worker level |
| k6 | `brew install k6` | Load/performance testing (JS scripts) |
| axe-core + Playwright | `npm i -D @axe-core/playwright` | Automated accessibility auditing |
| Pa11y | `npx pa11y URL` | CLI accessibility scanning |
| Lighthouse | `npx lighthouse URL --output=json` | Performance + a11y + SEO auditing |
| Pact | `npm i -D @pact-foundation/pact` | Consumer-driven contract testing |
| Stryker | `npx stryker init` | Mutation testing |
