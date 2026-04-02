# Rollback Strategy: Todo App

## Deployment Strategy Comparison

| Strategy | How It Works | Rollback Speed | Risk Level | Best For |
|---|---|---|---|---|
| **Instant Rollback (Vercel)** | Vercel keeps every deployment as immutable snapshot; "Promote" previous deployment | < 30 seconds | Very Low | SPA/SSR apps on Vercel (our choice) |
| **Blue-Green** | Two identical environments; switch traffic via DNS/LB | 1-5 minutes | Low | Stateful apps, database-coupled deploys |
| **Canary** | Route % of traffic to new version; monitor; gradually increase | 5-15 minutes (instant if canary fails) | Medium | High-traffic apps needing gradual validation |
| **Rolling Update** | Replace instances one by one | 5-10 minutes | Medium | Kubernetes/container deployments |
| **Feature Flags** | Deploy code dark; toggle feature on/off | Instant (flag toggle) | Very Low | Partial features, A/B testing |

### Selected: Instant Rollback (Vercel) + Feature Flags

**Rationale**: Vercel's immutable deployment model means every successful deploy is a rollback target. Combined with feature flags for granular control, this gives us both infrastructure-level and application-level rollback capability.

## Rollback SOP (Standard Operating Procedure)

### Target: Complete rollback within 5 minutes of incident detection

| Step | Action | Time Target | Owner |
|---|---|---|---|
| 0 | Alert fires (P0) | T+0:00 | Automated |
| 1 | Acknowledge alert, assess impact | T+1:00 | On-call engineer |
| 2 | **Decision**: Forward Fix or Rollback? (see decision tree below) | T+2:00 | On-call engineer |
| 3a | **If Rollback**: Execute `vercel rollback` or promote previous deployment in dashboard | T+3:00 | On-call engineer |
| 3b | **If Forward Fix**: Create hotfix branch, PR with expedited review | T+varies | On-call + reviewer |
| 4 | Verify health check passes on rolled-back version | T+4:00 | Automated + on-call |
| 5 | Post-incident communication (Slack #incidents) | T+5:00 | On-call engineer |
| 6 | Post-mortem within 48 hours | T+48h | Team |

### Rollback Commands

```bash
# Option A: Vercel CLI (fastest)
vercel rollback                              # Roll back to previous production deployment
vercel promote <deployment-url>              # Promote a specific deployment to production

# Option B: Vercel Dashboard
# Deployments > Find last known good > "..." menu > "Promote to Production"

# Option C: Git revert (creates audit trail)
git revert HEAD --no-edit
git push origin main                         # Triggers new deploy of reverted code
```

### Database Rollback Considerations

| Scenario | Action | Risk |
|---|---|---|
| Code-only change (no schema migration) | Vercel rollback is safe | None |
| Additive migration (new column, new table) | Rollback code; migration is backwards-compatible | Low — unused columns remain |
| Destructive migration (drop column, rename) | **CANNOT** simply rollback code — old code expects old schema | HIGH — requires forward fix or data restoration |
| Data migration (backfill, transform) | Requires dedicated rollback migration script | Medium |

**Rule**: Never deploy destructive schema migrations and code changes in the same deployment. Always split into: (1) additive migration, (2) code update, (3) cleanup migration.

## Forward Fix vs Rollback Decision Tree

```
Incident Detected
    |
    v
Is the root cause known?
    |-- NO --> ROLLBACK immediately
    |-- YES
        |
        v
    Can it be fixed in < 15 minutes?
        |-- NO --> ROLLBACK immediately
        |-- YES
            |
            v
        Does the fix involve database schema changes?
            |-- YES --> ROLLBACK if possible; forward fix carefully
            |-- NO
                |
                v
            Is the fix a one-line / config change?
                |-- YES --> FORWARD FIX (with expedited PR review)
                |-- NO --> ROLLBACK, then fix properly
```

### Decision Criteria Summary

| Factor | Rollback | Forward Fix |
|---|---|---|
| Root cause unknown | YES | NO |
| Fix time > 15 min | YES | NO |
| Database migration involved | DEPENDS | CAREFULLY |
| One-line fix | NO | YES |
| Multiple files affected | YES | NO |
| Customer-facing impact ongoing | YES (urgency) | Only if faster |

## Rollback Verification Checklist

After any rollback, verify:
- [ ] Health check endpoint returns 200 (`/api/health`)
- [ ] Error rate returns to baseline (< 0.1%)
- [ ] p95 latency returns to baseline (< 500ms)
- [ ] Core user flows work (login, create todo, list todos)
- [ ] No database connection errors in logs
- [ ] Sentry error rate drops within 5 minutes
- [ ] Notify team in #incidents channel

## Prevention: Reducing Rollback Frequency

1. **Preview deploys**: Every PR gets a preview URL; test before merge
2. **Staged rollout**: Use Vercel's deployment protection for production
3. **Feature flags**: Ship code dark, enable gradually
4. **Smoke tests in CI**: Health check + critical path tests post-deploy
5. **Database migrations**: Always backwards-compatible (additive first)
