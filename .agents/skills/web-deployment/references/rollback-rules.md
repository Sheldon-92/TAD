# Rollback Strategy Rules
<!-- capability: rollback_strategy -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| RB1 | Immutable deploys: every deploy is a snapshot, rollback = point to previous | All deployment architectures |
| RB2 | Blue-green: two identical environments, load balancer switches instantly | Zero-downtime critical apps |
| RB3 | Canary: 1% > 10% > 50% > 100%, halt on error spike | High-traffic gradual rollout |
| RB4 | Atomic: symlink swap for instant revert | Self-hosted / VPS deploys |
| RB5 | Docker SHA rollback: tag every image with commit SHA | Container-based deploys |
| RB6 | Auto-rollback trigger: error rate >5% for 2 minutes | Production safety net |
| RB7 | Rollback SOP: <5 minutes total, documented steps | Every production system |
| RB8 | Quarterly rollback drills — test the plan before you need it | Operational readiness |

---

## Rules

### RB1: Immutable Deploys (Cross-Cutting Foundation)

Every deploy MUST produce an immutable artifact that can be re-deployed identically. "Update the server in place" is not a deployment strategy — it is a prayer.

**Platform-native immutability**:
- **Vercel**: Every deploy is an immutable snapshot. `vercel rollback` points to previous snapshot.
- **Netlify**: Every deploy is immutable. Rollback = "Publish deploy" on any previous build.
- **Docker**: Tag with commit SHA. `docker run myapp:abc123` is deterministic.
- **Fly.io**: `flyctl releases` lists all releases. `flyctl deploy --image myapp:abc123` redeploys.

**Verification**: After every deploy, confirm you can reproduce it by re-running the same image/snapshot without any additional manual steps.

### RB2: Blue-Green Deployment

When zero downtime is required and you can afford 2x resources:

```
[Load Balancer]
    |
    |--- [Blue Environment] (current production, v1.2.3)
    |--- [Green Environment] (new version, v1.2.4)

Deploy steps:
1. Deploy v1.2.4 to Green (inactive)
2. Run smoke tests against Green
3. Switch load balancer to Green
4. Green is now production
5. Blue becomes the rollback target
```

**Rollback**: Switch load balancer back to Blue. Total time: <30 seconds.

**Platform-specific**:
```bash
# AWS ECS blue-green
aws ecs update-service --cluster prod --service webapp --task-definition webapp:NEW

# Kubernetes
kubectl set image deployment/webapp webapp=myapp:v1.2.4
kubectl rollout undo deployment/webapp  # instant rollback
```

**Cost**: 2x infrastructure during deployment. Blue env can be scaled down (not deleted) after verification.

### RB3: Canary Deployment

When serving high traffic and wanting gradual rollout:

```
Traffic split:
  Phase 1: 1% to canary   (5 min observation)
  Phase 2: 10% to canary  (15 min observation)
  Phase 3: 50% to canary  (30 min observation)
  Phase 4: 100% (full rollout)

Halt condition: error rate increase >0.5% OR p95 increase >200ms
```

**Vercel Progressive Rollouts** (Vercel Flags):
```typescript
// flags.ts — gradual traffic shift
export const newFeature = flag({
  key: 'new-checkout',
  decide: ({ percentage }) => percentage < 10,  // 10% canary
});
```

**Manual canary with Nginx**:
```nginx
upstream backend {
    server v1_server weight=90;
    server v2_server weight=10;  # 10% canary
}
```

### RB4: Atomic Deployment (Symlink Swap)

When deploying to a VPS or self-hosted environment:

```bash
# Directory structure
/var/www/
  releases/
    20260515-001/   # previous release
    20260515-002/   # current release
    20260515-003/   # new release (deploying)
  current -> releases/20260515-002/  # symlink

# Deploy
ln -sfn /var/www/releases/20260515-003 /var/www/current
# Rollback (instant)
ln -sfn /var/www/releases/20260515-002 /var/www/current

# Cleanup: keep last 5 releases, delete older
ls -dt /var/www/releases/*/ | tail -n +6 | xargs rm -rf
```

**Why**: Symlink swap is atomic at the filesystem level. No half-deployed state. Rollback is one command.

### RB5: Docker SHA Rollback

When using Docker containers, tag EVERY image with its commit SHA:

```bash
# Build and tag with commit SHA
export SHA=$(git rev-parse --short HEAD)
docker build -t myapp:$SHA .
docker push registry.example.com/myapp:$SHA

# Deploy specific version
docker run -d registry.example.com/myapp:abc123

# Rollback to previous known-good version
docker run -d registry.example.com/myapp:def456

# Docker Compose rollback
# docker-compose.yml:
#   image: registry.example.com/myapp:${DEPLOY_SHA}
DEPLOY_SHA=def456 docker compose up -d
```

**NEVER use `latest` tag for production**. `latest` is mutable — you cannot tell which version is running or roll back to a specific state.

### RB6: Auto-Rollback Triggers

When monitoring detects a deploy has gone wrong, auto-rollback before humans notice:

| Trigger | Threshold | Grace Period | Action |
|---------|-----------|-------------|--------|
| Error rate spike | >5% of requests return 5xx | 2 minutes | Auto-rollback |
| Health check failure | 3 consecutive failures | 90 seconds | Auto-rollback |
| Latency degradation | p95 >3x baseline | 5 minutes | Alert + manual decision |
| Memory leak | >90% memory for 5 min | 5 minutes | Restart + alert |

> **Not the same as MO3's SLO alert threshold.** This `>5% for 2 min` is a **coarse, fast-acting deploy-window safety net** scoped to the minutes immediately after a new release — it trades sensitivity for speed so a broken deploy auto-reverts before a human is paged. It is deliberately distinct from `monitoring-rules.md` MO3's **multi-window multi-burn-rate** method, which governs ongoing **SLO error-budget paging** (catching slow burns and suppressing harmless blips over hours/days). MO3 explicitly condemns a flat `>5% for 2 min` *as an SLO pager*; that condemnation does NOT apply to this deploy-time circuit-breaker. Use BOTH: this safety net during the deploy window, MO3 burn-rate alerts for steady-state SLO.

**GitHub Actions auto-rollback**:
```yaml
- name: Deploy
  run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}

- name: Smoke test
  run: |
    sleep 30  # wait for deploy propagation
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://myapp.com/api/health)
    if [ "$STATUS" != "200" ]; then
      echo "Health check failed — rolling back"
      vercel rollback --token=${{ secrets.VERCEL_TOKEN }}
      exit 1
    fi
```

### RB7: Rollback SOP (Standard Operating Procedure)

When an incident requires rollback, follow this SOP in <5 minutes total:

| Step | Time Budget | Action |
|------|------------|--------|
| 1. Confirm | <2 min | Verify the issue exists (check error rate, user reports, health endpoints) |
| 2. Decide | <1 min | Rollback vs Forward Fix decision tree (see below) |
| 3. Execute | <1 min | Run platform rollback command |
| 4. Verify | <1 min | Confirm health check passes, error rate drops |
| 5. Notify | Immediate | Post in #incidents: what happened, what was done, what's next |
| 6. Post-mortem | <48 hours | Root cause analysis, prevention measures |

**Decision tree**:
- Impact >50% users -> **Rollback immediately**
- Impact <10% + known fix ready -> **Forward fix** (deploy the fix)
- Data corruption -> **Rollback + database restore**
- Unknown cause -> **Rollback first**, investigate after

**Platform commands**:
```bash
# Vercel
vercel rollback

# Netlify (no CLI rollback — use API)
# Dashboard: Deploys > click previous deploy > "Publish deploy"

# Docker
docker run -d myapp:<previous-commit-sha>

# Kubernetes
kubectl rollout undo deployment/webapp
kubectl rollout status deployment/webapp  # verify

# Fly.io
flyctl releases
flyctl deploy --image myapp:<previous-sha>
```

### RB8: Quarterly Rollback Drills

When you have a rollback plan, TEST it before you need it:

**Quarterly drill checklist**:
1. Deploy a known-broken version to staging
2. Trigger rollback using documented SOP
3. Measure actual rollback time (target: <5 minutes)
4. Verify all services recovered
5. Document findings: what worked, what was slow, what was unclear

**Why**: A rollback plan that has never been executed is a hypothesis. Drills convert hypotheses into verified procedures.

---

## Anti-Patterns

- **No rollback plan**: "We'll figure it out when it happens" = panic-debugging in production at 2 AM.
- **Mutable deploys**: Updating files in place means you cannot revert to a known-good state. Every deploy must be immutable.
- **`docker run myapp:latest`**: `latest` is whatever was last pushed. You cannot rollback to "the previous latest." Use commit SHA tags.
- **Application rollback without database rollback**: Rolling back code to v1.2.3 while the database schema is at v1.2.4 = data corruption. Plan database migrations as reversible.
- **Never practicing rollback**: The first time you run your rollback procedure should NOT be during a production incident.
- **Forward-fix bias**: Under pressure, engineers prefer "just push a fix" over rollback. If impact >50% users, rollback FIRST, then investigate.
