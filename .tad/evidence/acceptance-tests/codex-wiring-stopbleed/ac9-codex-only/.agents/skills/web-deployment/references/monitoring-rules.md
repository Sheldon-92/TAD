# Monitoring Rules
<!-- capability: monitoring -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| MO1 | Uptime Kuma for self-hosted uptime monitoring — 1 Docker command | Any web project |
| MO2 | Prometheus + Grafana for metrics and dashboards | Self-hosted / K8s stacks |
| MO3 | Multi-window multi-burn-rate alerting (14.4x/6x/1x) — not a flat threshold | Alert configuration |
| MO4 | SLA targets: 99.95% (standard) to 99.99% (enterprise) | SLO/SLI definition |
| MO5 | Alert severity tiers: P0 immediate / P1 1-hour / P2 next business day | Alert routing |
| MO6 | Four core dashboard metrics: error rate, p95 latency, uptime, deploy frequency | Dashboard design |
| MO7 | Sentry DSN from env var, sampling rate 0.1 in production | Error monitoring setup |
| MO8 | DORA deploy-health targets: top-tier CFR ≤5%, MTTR <1h (DORA 2025 retired the 4-tier model for 7 archetypes) | Deploy quality SLOs |

---

## Rules

### MO1: Uptime Kuma — Self-Hosted Uptime Monitoring

When you need uptime monitoring without SaaS costs:

```bash
# One command to start
docker run -d -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1

# Access at http://localhost:3001
# Add monitors: HTTP(s), TCP, Ping, DNS, Docker container
# Notification channels: Slack, Discord, Telegram, PagerDuty, email
```

**Configuration**:
- Check interval: 60s for standard, 30s for critical endpoints
- Retry count: 3 (avoid alerting on single-request failures)
- Accepted status codes: 200-299
- Monitor both the application URL AND the health check endpoint (`/api/health`)

**When to use alternatives**:
- BetterUptime/UptimeRobot: SaaS, free tier (50 monitors), no Docker needed
- Managed platforms (Vercel/Netlify): Built-in analytics, no separate monitoring needed for basic uptime

### MO2: Prometheus + Grafana Stack

When running self-hosted or Kubernetes workloads:

**Prometheus** (metrics collection):
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'webapp'
    static_configs:
      - targets: ['webapp:3000']
    metrics_path: '/metrics'
```

**Key PromQL queries**:
```promql
# Request rate (requests/second)
rate(http_requests_total[5m])

# Error rate (percentage of 5xx responses)
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# p95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Memory usage percentage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

**Grafana** (dashboards):
```bash
docker run -d -p 3000:3000 --name grafana grafana/grafana-oss:latest
# Add Prometheus as data source: http://prometheus:9090
```

### MO3: Multi-Window Multi-Burn-Rate Alerting (MANDATORY)

When configuring SLO alerts, do NOT alert on a flat instantaneous threshold like ">5% errors for 2 minutes". A flat threshold both **fires on harmless blips** and **fails to escalate a slow burn** that is quietly draining your error budget. Use the **Google SRE multi-window, multi-burn-rate** method (SRE Workbook, "Alerting on SLOs"): the **burn rate** is how many times faster than the sustainable rate you are consuming the error budget; `1x` burn exactly exhausts a 30-day budget in 30 days.

Alert only when a **long window** AND a **short confirmation window** are BOTH over the burn-rate threshold — the short window cuts noise (auto-resolves fast when the spike ends) and prevents alerting on a single bad minute.

| Tier | Burn rate | Long window | Short (confirm) window | Budget consumed when it fires | Page? | Meaning |
|------|-----------|-------------|------------------------|-------------------------------|-------|---------|
| Fast burn | **14.4x** | 1 hour | 5 minutes | **2%** of 30-day budget | P0 page | Exhausts the entire 30-day budget in **~2 days** if unchecked |
| Medium burn | **6x** | 6 hours | 30 minutes | **5%** | P1 page | Sustained degradation |
| Slow burn | **1x** | 3 days | 6 hours | **10%** | Ticket, not page | Chronic low-grade errors |

Both the long and the short window must exceed the threshold for the alert to fire (`AND`), which is what makes it self-resolving and low-noise.

```promql
# Fast-burn (14.4x): 1h window AND 5m window both above 14.4x the SLO error ratio.
# For a 99.9% SLO the sustainable error ratio is 0.001, so 14.4x ≈ 0.0144 (1.44%).
(
  job:slo_errors_per_request:ratio_rate1h{job="webapp"}  > (14.4 * 0.001)
and
  job:slo_errors_per_request:ratio_rate5m{job="webapp"}  > (14.4 * 0.001)
)
```

**Static threshold (bootstrap ONLY — use until you have a measured SLO and recording rules)**:

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Error rate (5xx) | >0.5% | >2% | Investigate / auto-rollback |
| p95 latency | >800ms | >2s | Investigate / scale up |
| Uptime | <99.95% | <99.9% | Incident response |
| CPU usage | >70% | >90% | Scale up |
| Memory usage | >75% | >90% | Investigate leaks |

**Transition**: Start with static thresholds. Once you have ~2 weeks of data and a defined SLO, switch to the burn-rate windows above. Keep static thresholds as absolute safety nets, not as the primary alert. Source: sre.google/workbook/alerting-on-slos (retrieved 2026-06-13).

### MO4: SLA/SLO/SLI Targets

When defining service level objectives:

| Tier | SLA Target | Monthly Downtime Budget | Use Case |
|------|-----------|------------------------|----------|
| Standard | 99.95% | ~22 minutes | Most web apps |
| High | 99.99% | ~4.3 minutes | E-commerce, SaaS |
| Enterprise | 99.999% | ~26 seconds | Financial, healthcare |

**Define SLIs for each SLO**:

| SLO | SLI (how to measure) | Tool |
|-----|---------------------|------|
| Availability >=99.95% | Successful requests / total requests | Uptime Kuma, Prometheus |
| Latency p95 <=500ms | 95th percentile response time | Prometheus histogram |
| Error rate <=0.1% | 5xx responses / total responses | Application metrics |

**Error budget**: If SLO is 99.95%, you have 22 minutes of downtime per month. Track consumption. When >50% consumed, freeze deployments and investigate.

### MO5: Alert Severity Tiers

When routing alerts, classify by severity and response time:

| Severity | Response Time | Channel | Triggers |
|----------|--------------|---------|----------|
| P0 Critical | Immediate (<5 min) | PagerDuty + Phone | Site down, data loss, security breach |
| P1 High | <1 hour | Slack #incidents + PagerDuty | Error rate >2%, p95 >2s, partial outage |
| P2 Medium | Next business day | Slack #monitoring | Warning thresholds, degraded performance |
| P3 Low | Sprint backlog | Dashboard only | Trending metrics, capacity planning |

**Anti-fatigue rules**:
- Aggregate: same error within 5 minutes = 1 notification, not 50
- Suppress during maintenance windows
- Auto-resolve when metric returns to normal
- Weekly review: delete alerts that never fire or always fire

### MO6: Four Core Dashboard Metrics

When building a monitoring dashboard, always include these four:

1. **Error rate**: 5xx responses as percentage of total (target: <0.1%)
2. **p95 latency**: 95th percentile response time (target: <500ms)
3. **Uptime**: Percentage of successful health checks (target: >=99.95%)
4. **Deploy frequency**: Deploys per week (indicator of delivery velocity)

Show **trends** (this week vs last week), not just current values. A p95 of 400ms is fine in isolation but alarming if last week was 200ms.

### MO7: Sentry Error Monitoring Setup

When configuring Sentry for error monitoring:

```typescript
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,  // DSN from env, NEVER hardcoded
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  replaysSessionSampleRate: 0.01,  // 1% of sessions
  replaysOnErrorSampleRate: 1.0,   // 100% of error sessions
});
```

**Rules**:
- DSN MUST come from environment variable (L3 Config level — it is a public identifier, not a secret, but still should not be hardcoded)
- `tracesSampleRate: 0.1` in production (10% sampling). `1.0` = cost explosion on high-traffic sites
- `replaysOnErrorSampleRate: 1.0` to capture ALL error sessions for debugging
- Upload source maps in CI (not at runtime):
  ```bash
  npx @sentry/cli sourcemaps upload --auth-token $SENTRY_AUTH_TOKEN ./dist
  ```

### MO8: DORA 2025 Deploy-Health Targets

When setting deploy-quality SLOs, anchor them to the **DORA** (DevOps Research & Assessment) metrics rather than "monitor your deploys". Note a 2025 reporting change: the **2025 DORA report retired the four-tier Elite/High/Medium/Low classification** in favor of **seven team archetypes** that blend delivery performance with human factors (burnout, friction). It no longer publishes a single "Elite" bucket; the top-tier delivery targets below are the elite/top thresholds carried over from the **2024** four-tier report (the last year that named bands were published). Concrete targets for the top tier:

| DORA metric | What it measures | Top-tier target (2024 elite band) | Where to source it |
|-------------|------------------|-----------------------------|--------------------|
| Change Failure Rate (CFR) | % of deploys causing a failure needing remediation (hotfix/rollback) | **≤ 5%** (elite band; tightened from the old 0-15% to ≤5% in the 2024 report) | failed deploys / total deploys |
| Failed deployment recovery time (MTTR) | Time to restore service after a failed change | **< 1 hour** | incident start → resolved (Uptime Kuma / PagerDuty) |
| Deployment frequency | How often you ship to prod | On-demand / multiple per day | CI deploy events |
| Lead time for changes | commit → running in prod | < 1 day | CI pipeline timestamps |

**Wire these into the dashboard (MO6)**: CFR and MTTR are your two **deploy-health SLOs** — a rising CFR means your CI gates (tests, attestations) are leaking defects; an MTTR over 1h usually means rollback is too slow (see rollback rules — prefer atomic/blue-green so MTTR is one command). Source: 2024 Google Cloud DORA report (elite CFR ≤5%, MTTR <1h) + 2025 DORA report (four-tier model retired for seven team archetypes), retrieved 2026-06-13.

---

## Anti-Patterns

- **Monitoring without alerting**: A dashboard nobody watches is decoration. Every monitored metric needs an alert threshold.
- **All alerts same severity**: P0 + P2 in the same Slack channel = alert fatigue. P0 gets PagerDuty; P2 gets a quiet channel.
- **Sentry DSN hardcoded**: `Sentry.init({ dsn: "https://..." })` in source code. Use env var.
- **`tracesSampleRate: 1.0` in production**: Full sampling on 100K requests/day = $500+/month Sentry bill. Start at 0.1.
- **No SLO definition**: "The site should be fast" is not measurable. Define p95 <= 500ms, availability >= 99.95%.
- **Flat-threshold alerting (">5% for 2 min")**: fires on harmless blips and misses slow budget burns. Use multi-window multi-burn-rate (14.4x/6x/1x) gated on a short confirmation window.
- **No deploy-health SLOs**: "monitor your deploys" is not a target. Track CFR (top-tier ≤5%) and MTTR (<1h) per the DORA elite band — a rising CFR means CI gates are leaking defects.
