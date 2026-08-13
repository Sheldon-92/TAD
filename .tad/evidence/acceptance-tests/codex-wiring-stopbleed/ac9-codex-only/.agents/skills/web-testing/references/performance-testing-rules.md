# Performance Testing Rules
<!-- capability: performance_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| P1 | Core Web Vitals thresholds: LCP <= 2.5s, INP <= 200ms, CLS <= 0.1 | Setting performance targets |
| P2 | Lighthouse CLI for page-level auditing | Running performance audits |
| P3 | k6 threshold syntax with non-zero exit | Setting CI performance gates |
| P4 | Tiered VU budgets per environment | Configuring load test levels |
| P5 | Measure before optimizing -- always baseline first | Starting performance work |
| P6 | Test production builds, not dev mode | Running performance tests |
| P7 | Test both mobile and desktop presets | Configuring Lighthouse |
| P8 | Sitespeed.io for continuous monitoring | Setting up performance dashboards |

---

## Rules

### P1: Core Web Vitals Thresholds

When setting performance targets for web pages:

- **LCP (Largest Contentful Paint) <= 2.5s** -- time until the largest visible element renders. Above 4.0s is "poor".
- **INP (Interaction to Next Paint) <= 200ms** -- replaced FID in March 2024. Measures responsiveness to ALL user interactions, not just first input. Above 500ms is "poor".
- **CLS (Cumulative Layout Shift) <= 0.1** -- measures visual stability. Above 0.25 is "poor".

These are Google's "good" thresholds, evaluated at the **75th percentile of CrUX field data** — a page passes a metric only when **>=75% of page views** hit "good". They directly affect search ranking.

> **These numbers are UNCHANGED in 2026** (web.dev "Defining the Core Web Vitals metrics thresholds"). Reject any claim that LCP tightened to 2.0s — that surfaces from a single low-authority SEO blog and contradicts the official thresholds. The authoritative numbers remain LCP 2.5s / INP 200ms / CLS 0.1.

**Field-data prioritization signal (2026 CrUX)**: only **~55.9% of origins pass all three** CWV, and **~43% fail INP** — making **INP the most-failed Core Web Vital**. When you have to pick one to fix first, fix interaction latency (INP), not LCP. The deterministic budget check is `scripts/cwv-budget-check.sh report.json`.

```bash
# Quick audit
npx lighthouse https://example.com --output=json --output-path=report.json \
  --chrome-flags="--headless=new"

# Extract CWV from JSON
cat report.json | jq '.audits["largest-contentful-paint"].numericValue'
```

### P2: Lighthouse CLI for Page Audits

When auditing page performance:

- Run Lighthouse CLI in headless mode for CI integration
- Extract four scores: Performance, Accessibility, Best Practices, SEO
- **Performance score >= 80** as CI gate (blocks deploy if below)
- For full-site scanning: `npx unlighthouse --site URL`

```bash
# Single page audit
npx lighthouse https://example.com \
  --output=json,html \
  --chrome-flags="--headless=new" \
  --preset=desktop

# Mobile (default, no preset flag needed)
npx lighthouse https://example.com --output=json

# Full site
npx unlighthouse --site https://example.com
```

**Key**: Lighthouse mobile preset throttles CPU 4x and network to slow 4G. Desktop scores are always higher. Test both.

### P3: k6 Threshold Syntax

When setting API performance gates in CI:

> **Version**: k6 reached **v1.0 on 2025-05-07** (GrafanaCON); current stable is **1.3.0**. Use the v1.x CLI — pre-1.0 syntax/options differ. Verify with `k6 version` (>= 1.0.0).

```javascript
export const options = {
  thresholds: {
    // abortOnFail stops the run the instant a threshold is crossed (don't burn 10min once doomed)
    http_req_duration: [{ threshold: 'p(95)<500', abortOnFail: true }], // P95 < 500ms
    http_req_failed:   ['rate<0.01'],   // Error rate < 1%
    http_reqs:         ['rate>100'],    // Throughput > 100 req/s
  },
};
```

- k6 exits **non-zero (exit code 99)** when thresholds are breached -- use this to fail CI
- **`abortOnFail: true`** aborts the test the moment a threshold is crossed. ⚠️ In **Grafana Cloud, thresholds evaluate every 60s**, so an abort there can lag up to 60s; locally it aborts as soon as the metric is computed.
- **P95, not average**: averages hide tail latency. A P95 of 500ms means 95% of requests complete in under 500ms.
- Adjust thresholds per endpoint: auth endpoints may need tighter limits than report generation.

```bash
k6 run --out json=results.json performance.js   # k6 1.x CLI
# Exit code 99 = threshold breach
```

### P4: Tiered VU Budgets

When configuring load tests across environments:

| Tier | VU Count | Duration | CI Trigger | Purpose |
|------|----------|----------|------------|---------|
| Smoke | 5-10 | 30s | Every PR | Catch regressions early |
| Load | 100-500 | 5min | Merge to main | Validate normal capacity |
| Stress | 1000+ | 10min | Nightly | Find breaking points |
| Soak | 50-100 | 1-4 hours | Pre-release | Detect memory leaks, pool exhaustion |

**Anti-pattern**: Running stress tests on every PR. Wastes CI time and produces flaky results. Smoke per PR, stress nightly.

### P5: Measure Before Optimizing

When starting performance work:

1. **Baseline first**: Run Lighthouse + k6 on the current state. Record numbers.
2. **Identify bottleneck**: Lighthouse audit details show the specific blocking resources.
3. **Fix one thing**: Change one variable (image optimization, code splitting, etc.).
4. **Re-measure**: Compare before/after. If no improvement, revert.

**Anti-pattern**: "Let's optimize images and add lazy loading and switch to a CDN and enable compression" all at once. You won't know which change helped.

### P6: Test Production Builds

When running performance tests:

- **Always test production builds** (`npm run build && npm run preview`), not dev mode
- Dev mode includes HMR, source maps, unminified code -- 2-10x slower than production
- Lighthouse scores from dev mode are meaningless
- Exception: k6 API tests can run against dev server if the API layer is identical

### P7: Test Mobile and Desktop

When configuring Lighthouse runs:

- **Mobile is the default** Lighthouse preset (4x CPU throttle, slow 4G network)
- Desktop requires explicit `--preset=desktop`
- Mobile scores are typically 20-40 points lower than desktop
- If you only test one, test mobile -- it's the harder target

```bash
# Mobile (default)
npx lighthouse https://example.com --output=json

# Desktop (explicit)
npx lighthouse https://example.com --preset=desktop --output=json
```

### P8: Sitespeed.io for Continuous Monitoring

When setting up ongoing performance tracking:

- Sitespeed.io runs via Docker, produces dashboards over time
- Better for trend analysis than one-shot Lighthouse runs
- Integrates with Grafana for visualization

```bash
docker run --rm -v "$(pwd)/sitespeed-result:/sitespeed.io" \
  sitespeedio/sitespeed.io:latest \
  https://example.com -n 5
```

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Testing in dev mode | Scores 20-40 points lower, misleading | Always `npm run build` first |
| Desktop-only testing | Misses mobile bottlenecks (most users) | Test both presets, prioritize mobile |
| Average latency | Hides P99 spikes | Use P95/P99 percentiles |
| Optimizing without baseline | Can't prove improvement | Lighthouse + k6 baseline first |
| Stress test on every PR | Wastes CI, flaky results | Smoke per PR, stress nightly |
| FID instead of INP | FID deprecated March 2024 | Use INP <= 200ms |
| "LCP is now 2.0s" | Single low-authority source, contradicts web.dev | Keep LCP <= 2.5s (P1) |
| Letting a doomed load test run full duration | Wastes CI minutes | `abortOnFail: true` on the threshold (P3) |

---

## Sources

- web.dev — Defining the Core Web Vitals thresholds (LCP 2.5s / INP 200ms / CLS 0.1, 75th pct, unchanged 2026) — https://web.dev/articles/defining-core-web-vitals-thresholds (retrieved 2026-06-13)
- web.dev — Interaction to Next Paint (INP) — https://web.dev/articles/inp (retrieved 2026-06-13)
- k6 releases (v1.0 2025-05-07, current 1.3.0) — https://github.com/grafana/k6/releases (retrieved 2026-06-13)
- k6 thresholds & abortOnFail semantics — https://grafana.com/docs/k6/latest/using-k6/thresholds/ (retrieved 2026-06-13)
