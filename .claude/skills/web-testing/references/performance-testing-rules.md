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

These are Google's "good" thresholds at the 75th percentile of page loads. They directly affect search ranking.

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

```javascript
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],   // P95 response time < 500ms
    http_req_failed: ['rate<0.01'],      // Error rate < 1%
    http_reqs: ['rate>100'],             // Throughput > 100 req/s
  },
};
```

- k6 exits non-zero when thresholds are breached -- use this to fail CI
- **P95, not average**: averages hide tail latency. A P95 of 500ms means 95% of requests complete in under 500ms.
- Adjust thresholds per endpoint: auth endpoints may need tighter limits than report generation.

```bash
k6 run --out json=results.json performance.js
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
