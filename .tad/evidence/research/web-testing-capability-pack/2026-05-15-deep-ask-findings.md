# web-testing Capability Pack — Deep Ask Research Findings

> Notebook: Web Testing — E2E, Unit, API, Performance, Accessibility Testing 2025-2026
> Notebook ID: c3288195-a879-4f3f-aeeb-dd73e22b2477
> Sources: ~15 GitHub + deep research
> Date: 2026-05-15
> Rounds: 3

---

## Round 1: E2E, Unit, API Testing Patterns

### E2E (Playwright)
- CLI: `npx playwright test`, `npx playwright show-trace`, `npx playwright codegen`, `npx playwright install --with-deps`
- Page Object Model: centralize selectors, expose intent-level methods (login/addToCart)
- Stateful fixtures: login once → save storageState → reuse across tests
- User-visible selectors: getByRole/getByLabel over CSS/XPath

### Unit (Vitest)
- Vitest 4.0 Browser Mode: `@vitest/browser-playwright` for real browser rendering
- Testing Library bridge: `page.elementLocator()` for React components
- MSW for network mocking (intercepts at boundary), vi.mock() for module mocking
- Snapshots: 3-7 line inline only; `toMatchScreenshot` for visual regression

### API Testing
- CLI tools: Newman (Postman headless), k6 (JS perf), Artillery (YAML/serverless), Bruno (offline-first), REST Assured (Java)
- Contract testing: Consumer-Driven Contracts (Pact) — consumer spec → provider verification
- Schema validation: OpenAPI as source of truth, Schemathesis/Dredd for property-based tests
- Load testing tiers: smoke (5-10 VU/PR), load (100-500 VU/merge), stress (1000+ VU/nightly), soak (hours)

---

## Round 2: Performance, Accessibility, Test Strategy

### Core Web Vitals
- LCP ≤ 2.5s, INP ≤ 200ms (replaced FID), CLS ≤ 0.1
- CLI: Lighthouse CLI, Sitespeed.io (Docker)
- k6 thresholds: P95 < 500ms + error rate < 1% → non-zero exit on fail

### Accessibility
- Top 5 WCAG failures: missing alt text, insufficient contrast, unlabelled forms, empty links, broken ARIA
- Playwright + axe-core: `@axe-core/playwright` → `new AxeBuilder({page}).withTags(['wcag2a','wcag2aa']).analyze()`
- Automated catch rate: 30-50% of WCAG issues (57% by volume per Deque)
- Pa11y for CLI-native a11y scanning

### Test Strategy
- Testing pyramid: wide unit base → integration middle → thin E2E top
- 80% coverage target on business logic/hooks/utilities (unit+integration)
- E2E: 3-5 critical user flows only (5-15 tests per app)
- Over-relying on E2E = "ice cream cone" anti-pattern

---

## Round 3: Anti-Patterns, CI/CD, AI Testing

### Anti-Patterns
- Flaky tests: use auto-waiting not sleep(); isolated browser contexts; retry only on failure with trace
- Test coupling: no shared global state; avoid "mystery guest" pattern (external data files)
- Ice cream cone: invert pyramid by relying on E2E = slow, brittle pipelines
- Over-mocking: mock boundaries not implementations; MSW for network, vi.mock for modules
- Implementation vs behavior: assert user-visible behavior, use role-based locators

### CI/CD Pipeline
- Fastest-fail-first: unit (<30s, pre-commit) → integration (2-10min, PR) → E2E (10-30min, nightly)
- Playwright sharding: `npx playwright test --shard=1/4` → 20min→5min
- GitHub Actions: matrix strategy for shards, `needs: test-fast` dependency
- Reports: JUnit/JSON, `--merge-reports` for sharded runs, screenshots only-on-failure

### AI-Generated Code Testing
- Closed-loop validator: AI generates → test → classify failures → feed back to AI
- Human-authored business logic tests ON TOP of AI-generated edge case tests
- Mutation testing (Stryker) over line coverage — AI can fool traditional coverage metrics

---

## Key Judgment Rules Extracted

### unit_testing
1. Vitest Browser Mode > jsdom for component tests (real CSS/API rendering)
2. MSW for network boundaries, vi.mock() for module deps only
3. Inline snapshots 3-7 lines max; toMatchScreenshot for visual regression
4. 80% coverage on business logic; mutation testing for AI-generated code

### api_testing
1. OpenAPI spec as single source of truth; Schemathesis/Dredd for property-based
2. Consumer-Driven Contracts (Pact) for microservice isolation
3. k6 thresholds: P95 < 500ms, error < 1%; non-zero exit blocks CI
4. Tiered: smoke (5-10 VU) / load (100-500) / stress (1000+) / soak (hours)

### performance_testing
1. CWV thresholds: LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1
2. Lighthouse CLI + Sitespeed.io for measurement
3. k6 threshold syntax: `thresholds: { http_req_duration: ['p(95)<500'] }`
4. Budget per tier with explicit VU counts

### accessibility_testing
1. Top 5 failures: alt text, contrast, form labels, links, ARIA
2. axe-core + Playwright: `@axe-core/playwright` AxeBuilder pattern
3. Automated catches 30-50%; manual needed for keyboard/screen reader/cognitive
4. Pa11y CLI for standalone scanning

### pair_testing (4D Protocol)
1. E2E: 3-5 critical flows only (5-15 tests per app)
2. Human validates UX/cognitive; agent validates structure/regression
3. Round-by-round collaboration per 4D Protocol

### test_strategy
1. Pyramid: unit (fast, many) → integration (medium) → E2E (slow, few)
2. Fastest-fail-first pipeline: lint/unit → integration → E2E
3. Sharding for parallelization: `--shard=N/M`
4. AI code: mutation testing > line coverage
