# Monitoring Rules
<!-- capability: monitoring -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| MO1 | Uptime Kuma for self-hosted uptime monitoring — 1 Docker command | Any web project |
| MO2 | Prometheus + Grafana for metrics and dashboards | Self-hosted / K8s stacks |
| MO3 | Baseline-based alerting, not static thresholds — reduces alert fatigue | Alert configuration |
| MO4 | SLA targets: 99.95% (standard) to 99.99% (enterprise) | SLO/SLI definition |
| MO5 | Alert severity tiers: P0 immediate / P1 1-hour / P2 next business day | Alert routing |
| MO6 | Four core dashboard metrics: error rate, p95 latency, uptime, deploy frequency | Dashboard design |
| MO7 | Sentry DSN from env var, sampling rate 0.1 in production | Error monitoring setup |

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

### MO3: Baseline-Based Alerting (MANDATORY)

When configuring alerts, use behavior-based baselines instead of static thresholds. Static thresholds cause alert fatigue — a p95 of 450ms triggers a 500ms alert during peak hours when 450ms is normal.

**Pattern**:
1. Collect 2 weeks of baseline data
2. Alert on deviation from baseline (e.g., >2 standard deviations)
3. Separate baselines for peak vs off-peak hours

**Static threshold (for bootstrapping when no baseline exists)**:

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Error rate (5xx) | >0.5% | >2% | Investigate / auto-rollback |
| p95 latency | >800ms | >2s | Investigate / scale up |
| Uptime | <99.95% | <99.9% | Incident response |
| CPU usage | >70% | >90% | Scale up |
| Memory usage | >75% | >90% | Investigate leaks |

**Transition**: Start with static thresholds. After 2 weeks of data, switch to baseline-based. Keep static thresholds as absolute safety nets.

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

---

## Anti-Patterns

- **Monitoring without alerting**: A dashboard nobody watches is decoration. Every monitored metric needs an alert threshold.
- **All alerts same severity**: P0 + P2 in the same Slack channel = alert fatigue. P0 gets PagerDuty; P2 gets a quiet channel.
- **Sentry DSN hardcoded**: `Sentry.init({ dsn: "https://..." })` in source code. Use env var.
- **`tracesSampleRate: 1.0` in production**: Full sampling on 100K requests/day = $500+/month Sentry bill. Start at 0.1.
- **No SLO definition**: "The site should be fast" is not measurable. Define p95 <= 500ms, availability >= 99.95%.
- **Static thresholds only**: A 500ms alert on a service that normally runs at 480ms fires constantly. Use baselines.
