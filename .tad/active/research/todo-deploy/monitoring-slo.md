# SLO/SLI Definitions: Todo App

## Service Level Indicators (SLIs) & Objectives (SLOs)

| Metric | SLI Definition | SLO Target | Measurement Window | Alert Threshold |
|---|---|---|---|---|
| **Availability** | Successful responses (2xx+3xx) / Total requests | >= 99.9% | 30-day rolling | < 99.5% (P0) |
| **Latency (p50)** | Median response time | <= 200ms | 5-min window | > 300ms (P2) |
| **Latency (p95)** | 95th percentile response time | <= 500ms | 5-min window | > 800ms (P1) |
| **Latency (p99)** | 99th percentile response time | <= 1000ms | 5-min window | > 1500ms (P1) |
| **Error Rate** | 5xx responses / Total responses | <= 0.1% | 5-min window | > 1% (P0) |
| **TTFB** | Time to First Byte (server response start) | <= 300ms (p95) | Per request | > 500ms (P1) |
| **FCP** | First Contentful Paint (Core Web Vital) | <= 1.5s (p75) | Daily aggregate | > 2.5s (P2) |
| **LCP** | Largest Contentful Paint (Core Web Vital) | <= 2.5s (p75) | Daily aggregate | > 4.0s (P1) |
| **CLS** | Cumulative Layout Shift (Core Web Vital) | <= 0.1 (p75) | Daily aggregate | > 0.25 (P2) |

## Error Budget

- 99.9% availability = 43.8 minutes downtime/month allowed
- Burn rate alert: If error budget consumed > 10% in 1 hour -> P0

## Alert Rules

### P0 — Immediate Response (< 5 minutes)

| Rule | Condition | Duration | Channel |
|---|---|---|---|
| Site Down | Uptime check fails 3 consecutive times | 3 min | PagerDuty + Slack #incidents |
| Error Spike | 5xx rate > 5% of traffic | 2 min | PagerDuty + Slack #incidents |
| Error Budget Burn | > 10% budget consumed in 1 hour | 1 hour | PagerDuty |
| Database Unreachable | DB connection failures > 50% | 1 min | PagerDuty + Slack #incidents |

### P1 — Urgent Response (< 1 hour)

| Rule | Condition | Duration | Channel |
|---|---|---|---|
| High Latency | p95 > 800ms | 5 min | Slack #alerts |
| Elevated Errors | 5xx rate > 1% | 5 min | Slack #alerts |
| Deployment Failed | Production deploy returns non-200 health check | Immediate | Slack #deployments |
| SSL Expiry | Certificate expires in < 14 days | Daily check | Slack #alerts + Email |

### P2 — Next Business Day

| Rule | Condition | Duration | Channel |
|---|---|---|---|
| Performance Degradation | Lighthouse score < 0.8 | Weekly CI | Slack #quality |
| Slow Pages | p95 > 500ms for specific routes | 1 hour | Slack #quality |
| High Memory | Serverless function memory > 80% limit | 15 min | Slack #alerts |
| Error Rate Elevated | 5xx rate > 0.5% | 30 min | Email |

## Alert Fatigue Prevention

1. **Aggregation**: Same error grouped within 5-minute window (Sentry issue grouping)
2. **Deduplication**: Identical alerts suppressed for 30 minutes after first fire
3. **Maintenance Windows**: Scheduled deploys suppress non-P0 alerts for 15 minutes
4. **Escalation Path**: P0 not acknowledged in 10 min -> escalate to secondary on-call
5. **Weekly Review**: Review all P2 alerts; tune or delete alerts that fire > 5x/week without action
