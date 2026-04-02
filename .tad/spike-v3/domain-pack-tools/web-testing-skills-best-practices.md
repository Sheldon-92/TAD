# Web Testing Skills Best Practices — Research Summary

**Sources**: 5 GitHub repositories + testing blogs (2026-04-02 Blake research)
**Purpose**: Reference for web-testing.yaml step design, quality criteria, anti-patterns

---

## Repositories Researched

| # | Repository | Scale | Key Strength |
|---|-----------|-------|-------------|
| 1 | willcoliveira/qualiow-playwright-skills | CLI tool | Most structured — MUST/SHOULD/WON'T constitution, 7-category review checklist, network-first safeguards |
| 2 | LambdaTest/agent-skills (TestMu AI) | 46 skills, 15+ langs | Most comprehensive — 15 E2E + 15 unit + 5 mobile + 7 BDD skills, progressive disclosure architecture |
| 3 | rohitg00/awesome-claude-code-toolkit (qa-automation) | Single agent | Testing strategy — 70/20/10 pyramid, quality gates, feature-organized tests |
| 4 | TestDino Playwright Skill | 70+ guides, 5 packs | Best Playwright patterns — locator hierarchy, auth workflows, flaky test resolution |
| 5 | lackeyjb/playwright-skill | Model-invoked | Runtime automation — Claude writes and executes Playwright on-the-fly |

---

## Capability 1: E2E Testing (Playwright)

**Best Steps (from TestDino + qualiow)**:
1. Choose user flows to test (critical path: login → core action → verify → logout)
2. Set up Playwright project with proper config (browsers, retries, reporters)
3. Create Page Objects for each page (locators centralized, methods = user actions)
4. Write tests using semantic locators: getByRole > getByText > getByLabel > getByTestId > CSS
5. Add network safeguards: waitForResponse, toPass retry blocks, expect.poll for API
6. Run with HTML reporter and trace on first retry
7. Fix flaky tests before adding new ones

**Best Analysis Framework (from qualiow)**:
- 7-category review checklist: Assertions, Selectors, Timing, Isolation, POM usage, Readability, Reliability
- Root cause classification: app bug vs test bug vs environment
- MUST/SHOULD/WON'T rules for team agreements

**Best Quality Standards (from TestDino)**:
- "Without Skill: brittle CSS selectors. With Skill: getByRole() locators, proper wait strategies"
- All locators semantic-first (getByRole priority)
- Zero hardcoded timeouts (use web-first assertions)
- Session reuse for auth (no repeated login per test)
- Tests pass against real site, not just mock

**Anti-patterns (from qualiow + TestDino)**:
- ❌ Hardcoded timeouts instead of web-first assertions
- ❌ CSS selectors when getByRole/getByText available
- ❌ Repeated login flows (use session reuse/storageState)
- ❌ Tests passing in isolation but failing in suite (shared state)
- ❌ Assertions on implementation details (DOM structure) instead of behavior

---

## Capability 2: Unit Testing (Vitest)

**Best Steps (from LambdaTest + qa-automation)**:
1. Set up Vitest with coverage (vitest.config.ts + @vitest/coverage-v8)
2. Organize tests by feature (co-locate with source), not by type
3. Write tests for behavior, not implementation
4. Use proper mocking: vi.mock for modules, vi.fn for functions
5. Run with coverage report: `npx vitest run --coverage`

**Best Analysis Framework (from qa-automation)**:
- Test pyramid: 70% unit (fast) / 20% integration / 10% E2E
- Feature-organized: tests live alongside source code
- Shared test utilities: custom assertions, data builders, mock factories

**Quality Standards**:
- 80% minimum line coverage for critical modules
- Unit test suite runs in < 10 minutes
- Zero flaky tests in critical path
- Tests assert behavior, not implementation

**Anti-patterns**:
- ❌ Assertions on implementation details (expect(db.query).toHaveBeenCalled())
- ❌ Excessive snapshot testing (generates noise)
- ❌ Shared test data creating inter-test dependencies
- ❌ Testing private methods directly

---

## Capability 3: API Testing

**Best Steps (from qa-automation + LambdaTest)**:
1. Define API contract (OpenAPI spec)
2. Test each endpoint: happy path + error cases + edge cases
3. Validate response structure with Zod schemas
4. Check auth: valid token, expired token, no token, wrong role
5. Verify rate limiting behavior

**Quality Standards**:
- Every endpoint has happy path + at least 2 error cases
- Response schemas validated (not just status codes)
- Auth scenarios covered for all roles
- Contract tests detect breaking changes

---

## Capability 4: Performance Testing

**Best Steps (from qa-automation + BrowserStack)**:
1. Run Lighthouse on key pages (homepage, dashboard, critical flows)
2. Check Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1
3. Set performance budgets in CI
4. Profile slow pages with Chrome DevTools
5. unlighthouse for full-site scan

**Quality Standards**:
- LCP < 2.5s, FID < 100ms, CLS < 0.1 (Core Web Vitals)
- Performance score > 80 on Lighthouse
- E2E suite runs in < 30 minutes
- Performance regression caught in CI

---

## Capability 5: Accessibility Testing

**Best Steps (from TestDino + existing pa11y registry)**:
1. Run pa11y on every page: `npx pa11y url --reporter json`
2. Run axe-core for comprehensive checks
3. Manual keyboard navigation test (Tab, Enter, Escape, Arrow)
4. Screen reader check (VoiceOver on Mac)
5. Color contrast verification (4.5:1 ratio minimum)

**Quality Standards**:
- WCAG 2.1 AA compliance
- Zero critical accessibility violations
- All interactive elements keyboard accessible
- Color contrast ratio ≥ 4.5:1

---

## Capability 6: Pair Testing (4D Protocol) — TAD Unique

**No GitHub repos found for this capability** — this is TAD's proprietary methodology.

**Steps from TAD's own experience**:
1. **Discover**: AI navigates app with Playwright screenshots, identifies issues
2. **Discuss**: Human and AI discuss severity, root cause, priority
3. **Decide**: In-session decision (fix now / defer / won't fix), with full context
4. **Deliver**: Record decisions, generate fix handoffs or close

**Key insight**: "1M context window enables in-session decision making — no need to defer to a separate triage meeting"

**Quality Standards**:
- Each round produces decisions (not just bug list)
- Findings + decisions recorded per round
- Fix handoffs generated for "fix now" decisions
- Session context preserved across 10+ rounds

---

## Capability 7: Test Strategy (Document Type)

**Best Steps (from qa-automation + LambdaTest)**:
1. Identify what to test: critical user flows, high-risk areas, regression-prone code
2. Choose test pyramid distribution for THIS project (not generic 70/20/10)
3. Define quality gates: coverage thresholds, performance budgets, a11y requirements
4. Select tools per level: Playwright (E2E), Vitest (unit), pa11y (a11y), Lighthouse (perf)
5. Define CI integration: when to run what (pre-commit: lint+type, PR: unit+integration, merge: full E2E)

**Best Analysis Framework (from qa-automation)**:
- Test pyramid adapted to project type (data-heavy app → more integration, UI-heavy → more E2E)
- Risk-based testing: test critical paths first, edge cases second
- Flaky test policy: quarantine → fix → restore (never delete)

**Quality Standards**:
- Strategy document covers all 5 test levels
- Coverage targets defined per module (not global average)
- CI pipeline defined with run timing
- Flaky test policy documented

---

## Cross-Cutting Patterns

### Locator Priority (from TestDino — applicable to all UI testing)
1. getByRole — survives redesigns
2. getByText — readable, human-centric
3. getByLabel — form-specific
4. getByTestId — explicit, last resort before CSS
5. CSS — avoid (brittle)

### Test Data Strategy (from qualiow)
- Static data: for deterministic assertions
- Dynamic data (faker): for realistic scenarios
- API-seeded data: for complex state setup
- Always clean up after test

### Quality Gate Framework (from qa-automation)
- Build fails on test failure (zero tolerance)
- 80% coverage minimum for critical modules
- Unit suite < 10 min, E2E suite < 30 min
- Zero flaky tests in critical-path suite
