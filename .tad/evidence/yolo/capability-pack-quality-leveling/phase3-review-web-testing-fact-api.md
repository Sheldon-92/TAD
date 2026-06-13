# Phase 3 Review — web-testing — Lens: fact-api

**Lens**: fact-api (factual / API / version correctness; replaces cross-model review)
**Reviewer**: Blake subagent (Opus 4.8 1M)
**Date**: 2026-06-13
**meets_bar**: true

---

## Verdict

`meets_bar = true`. The pack is unusually disciplined about version-sensitive claims — nearly
every numeric/version assertion already carries a source URL + retrieval date, and the
authors pre-empted common drift (e.g. an explicit "reject LCP=2.0s" anti-pattern). I
WebSearched every version-sensitive claim against current primary docs. One genuine factual
error found (Stryker `break:50` mislabeled as a "documented default") — it is a framing/attribution
error, not a behavioral one (the recommended value is sound), so it does not sink the pack below
the bar. Everything else verified correct against current primary documentation.

---

## Findings

### F1 [P1 — factual error] Stryker `break: 50` is NOT a documented default
- **Where**: SKILL.md L129 ("thresholds break 50 / low 60 / high 80"); `unit-testing-rules.md` U5 L107
  ("**Stryker's `thresholds` config has three knobs**: `break: 50` ... These are the *documented*
  defaults — they are not arbitrary."); `test-strategy-rules.md` S6 L159.
- **Error**: Stryker.JS default thresholds are `{ high: 80, low: 60, break: null }`. `break: null`
  means the build NEVER fails by default. `break: 50` appears only as an *example* in Stryker docs,
  not as a default. The U5 sentence explicitly asserts all three (incl. `break: 50`) "are the
  documented defaults" — that is false. `high: 80` and `low: 60` ARE the real documented defaults.
- **Fix**: Reword to "`high: 80` / `low: 60` are Stryker's documented defaults; `break` defaults to
  `null` (build never fails) — set `break: 50` to make CI fail below 50%." Keep the recommendation,
  drop the false "documented default" attribution on `break`.
- **Severity rationale**: P1 not P0 — the *recommended* config (`break:50`) is reasonable and the
  gate script behavior is unaffected; only the provenance claim is wrong. But it is stated as fact
  in three places and a reader could cite it as a Stryker default.

### F2 [P2 — advisory] Vitest "4.1 current" / k6 "1.3.0 current" version pins will drift
- **Where**: SKILL.md L122/L124, `unit-testing-rules.md` L27/L31, `performance-testing-rules.md` L73.
- **Note**: As of 2026-06, axe-core is already at 4.12.1 (pack says "4.12.x" — still accurate),
  k6 has a v1.4.0 release issue open and Wikipedia lists 1.3.0 as stable (pack's "current 1.3.0" is
  defensible but aging), Vitest 4.1 is real and current. These are not errors today, but the
  `^4.1`/`1.3.0`/"current" framing is the kind of time-sensitive pin the Layer-A soft-constraint
  warns against. The caret ranges (`@^4.1`, `@^1.60`) are the right mitigation; the prose "current"
  labels are the drift risk. Advisory only — all values are correct as of the retrieval date.

---

## Fact-Checks (every version-sensitive claim, verified against primary docs)

1. **Vitest 4.0 → Browser Mode STABLE + native `toMatchScreenshot()` + Playwright Trace** —
   ✅ CORRECT. Confirmed by vitest.dev/blog/vitest-4 ("Browser Mode graduates to stable",
   `toMatchScreenshot`, Playwright Traces). (retrieved 2026-06-13)
2. **`@vitest/browser-playwright` is the v4 provider package name** — ✅ CORRECT. Vitest 4 split
   providers into `@vitest/browser-playwright` / `-webdriverio` / `-preview`. (vitest.dev v4 docs)
3. **Vitest 4.1 restored `/* v8 ignore */` + istanbul coverage ignore comments** — ✅ CORRECT.
   vitest.dev/blog/vitest-4-1 confirms ignore start/stop hints restored for v8 AND istanbul (broken
   in 4.0 due to dependency changes). (retrieved 2026-06-13)
4. **`page.elementLocator()` bridges Vitest Browser Mode to Testing Library** — ✅ CORRECT. Confirmed
   by vitest.dev/guide/browser/component-testing — `page.elementLocator(baseElement)` is the exact
   bridge API.
5. **Playwright Test Agents (Planner/Generator/Healer) shipped in v1.56** — ✅ CORRECT. Playwright
   v1.56 (Oct 2025) introduced the three Test Agent definitions; setup via `npx playwright init-agents`.
   (playwright.dev release notes + multiple corroborating sources)
6. **`browser.bind()` added in Playwright 1.59 (exposes browser to playwright-cli/MCP)** — ✅ CORRECT.
   github.com/microsoft/playwright releases/v1.59.0 — `browser.bind()` registers a launched browser
   for CLI/`@playwright/mcp` clients to share. (retrieved 2026-06-13)
7. **`npx playwright test --debug=cli` added in 1.59 for agent-driven repair** — ✅ CORRECT. v1.59
   release: `--debug=cli` pauses a test, prints a session id for an agent to attach. (Playwright 1.59 notes)
8. **k6 reached v1.0 on 2025-05-07 at GrafanaCON; current stable 1.3.0** — ✅ CORRECT (date + GrafanaCON).
   "current 1.3.0" is accurate-but-aging (a v1.4.0 release issue is open as of 2026); not an error today.
9. **k6 exits non-zero (exit code 99) on threshold breach** — ✅ CORRECT. Confirmed: exit code 99 =
   one or more thresholds failed (k6 errext/exitcodes). (retrieved 2026-06-13)
10. **k6 `abortOnFail: true` long-format object threshold syntax** — ✅ CORRECT. grafana k6 thresholds
    docs: long format is an array of objects `{ threshold, abortOnFail, delayAbortEval }`. The pack's
    `[{ threshold: 'p(95)<500', abortOnFail: true }]` is valid v1.x syntax.
11. **"Grafana Cloud thresholds evaluate every 60s"** — ✅ CORRECT. grafana k6 docs confirm cloud
    thresholds are evaluated every 60 seconds (vs local immediate). (retrieved 2026-06-13)
12. **k6 `delayAbortEval` exists** — ✅ CORRECT (not cited in pack but consistent with what is).
13. **Core Web Vitals: LCP≤2.5s / INP≤200ms / CLS≤0.1 at 75th percentile, unchanged 2026** —
    ✅ CORRECT. web.dev defining-core-web-vitals-thresholds; "poor" bands (LCP>4.0s, INP>500ms,
    CLS>0.25) also correct. (retrieved 2026-06-13)
14. **INP replaced FID in March 2024** — ✅ CORRECT. INP became a Core Web Vital and replaced FID on
    2024-03-12 (web.dev/blog/inp-cwv-march-12). Pack says "March 2024" — accurate.
15. **axe-core current 4.12.x; `target-size` rule landed in the 4.x line** — ✅ CORRECT. npm axe-core
    latest is 4.12.1. The `target-size` rule (WCAG 2.2 SC 2.5.8) was first added in **axe-core 4.5**
    (Deque blog "axe-core 4.5: First WCAG 2.2 Support") — the pack's source citation (S: "axe-core 4.5")
    is exactly right, and the body's looser "added in the 4.x line, current 4.12.x" is also correct.
16. **WCAG 2.2 added 9 new SC; SC 4.1.1 Parsing REMOVED; target-size 24×24 CSS px (SC 2.5.8 AA)** —
    ✅ CORRECT. W3C "What's New in WCAG 2.2" confirms 9 new criteria, 4.1.1 removed, 24px target size.
17. **Focus Appearance SC 2.4.13 is Level AAA, ≥2px perimeter, ≥3:1 contrast, manual-only** —
    ✅ CORRECT per W3C WCAG 2.2.
18. **WCAG contrast: 4.5:1 normal / 3:1 large / 3:1 UI components / 7:1 AAA** — ✅ CORRECT (WCAG 2.x).
19. **Stryker `mutationScore = detected/(detected+undetected)*100`, detected=killed+timeout,
    undetected=survived+noCoverage** — ✅ CORRECT. stryker-mutator.io mutant-states-and-metrics.
20. **Stryker covered-code score = detected/(detected+survived)*100 (excludes NoCoverage)** —
    ✅ CORRECT per same Stryker metrics doc.
21. **Stryker `high:80` / `low:60` documented defaults** — ✅ CORRECT. → BUT `break:50` is NOT a
    default (`break` default = `null` in Stryker.JS). See F1.
22. **Lighthouse mobile is the default preset (4× CPU throttle, slow 4G); `--preset=desktop` opt-in** —
    ✅ CORRECT (Lighthouse CLI behavior).
23. **Schemathesis (property-based from OpenAPI) / Dredd (spec compliance) / Pact (CDC)** —
    ✅ CORRECT tool descriptions; `@pact-foundation/pact` is the correct npm package.
24. **HTTP error-code semantics 400/401/403/404/429/500** — ✅ CORRECT (standard).
25. **`--chrome-flags="--headless=new"` Lighthouse flag** — ✅ valid Chrome new-headless flag; correct.

---

## Layer interaction note
No fabricated class names, no deprecated/renamed APIs presented as current, no wrong metric types,
no wrong exit codes (exit 99 verified, mutation-score formula verified). The single substantive
factual defect (F1) is an attribution error on one default value, not a behavioral/API error.
Pack clears the fact-api bar.
