# Performance Optimization Skill

---
title: "Performance Optimization"
version: "2.0"
last_updated: "2026-01-06"
tags: [performance, optimization, profiling, caching, engineering]
domains: [frontend, backend, all]
level: intermediate
estimated_time: "35min"
prerequisites: []
sources:
  - "High Performance Browser Networking - Ilya Grigorik"
  - "Web Vitals - Google"
  - "Systems Performance - Brendan Gregg"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Measure first - establish baseline metrics
2. [ ] Profile to find actual bottleneck (don't guess)
3. [ ] Optimize the critical path only
4. [ ] Verify improvement with data
5. [ ] Document the optimization
```

**Red Flags:**
- Optimizing without profiling data
- Premature optimization of non-critical code
- Sacrificing readability for unmeasured gains
- Not considering caching strategies
- Ignoring N+1 query patterns

---

## Overview

This skill guides data-driven performance analysis and optimization across frontend and backend systems.

**Core Principle:** "Measure first, optimize second. Without data, optimization is just guessing."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Slow response times | User complaints or metrics | Profile and optimize |
| High resource usage | CPU/memory alerts | Identify bottleneck |
| Before launch | Pre-production review | Establish baselines |
| Code review | Performance-sensitive code | Validate approach |

---

## Inputs

- Performance metrics/baselines
- User-perceived slowness reports
- Profiling data
- System resource metrics
- Target performance goals

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `baseline_metrics` | Before optimization measurements | `.tad/evidence/` |
| `profiling_data` | Flamegraph/profile output | `.tad/evidence/` |
| `improvement_metrics` | After optimization measurements | `.tad/evidence/` |

### Acceptance Criteria

```
[ ] Baseline established before optimization
[ ] Bottleneck identified with profiling
[ ] Optimization targeted at actual bottleneck
[ ] Improvement verified with metrics
[ ] No regression in other areas
```

---

## Procedure

### Step 1: Establish Performance Baseline

**Frontend (Web Vitals):**

| Metric | Meaning | Target |
|--------|---------|--------|
| LCP | Largest Contentful Paint | < 2.5s |
| FID/INP | First Input Delay / Interaction to Next Paint | < 100ms |
| CLS | Cumulative Layout Shift | < 0.1 |
| TTFB | Time to First Byte | < 800ms |
| FCP | First Contentful Paint | < 1.8s |

**Backend Metrics:**
```
Response Time:
□ P50 (median) - typical user experience
□ P95 - most users' worst case
□ P99 - tail latency

Throughput:
□ Requests per second (RPS)
□ Concurrent connections

Resources:
□ CPU utilization
□ Memory usage
□ Database query time
□ External API latency
```

### Step 2: Profile to Find Bottlenecks

**Frontend Profiling:**

```javascript
// Performance API
performance.mark('start');
// ... code to measure
performance.mark('end');
performance.measure('operation', 'start', 'end');

const measures = performance.getEntriesByType('measure');
console.log(measures[0].duration);

// React Profiler
import { Profiler } from 'react';

<Profiler id="Component" onRender={(id, phase, duration) => {
  console.log(`${id} ${phase}: ${duration}ms`);
}}>
  <MyComponent />
</Profiler>
```

**Backend Profiling:**

```bash
# Node.js
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Python
python -m cProfile -o output.prof script.py
python -m pstats output.prof

# Database
EXPLAIN ANALYZE SELECT * FROM users WHERE status = 'active';
```

### Step 3: Apply Frontend Optimizations

#### Loading Performance

```javascript
// ❌ Synchronous import of large module
import { heavyModule } from 'heavy-library';

// ✅ Dynamic import (code splitting)
const heavyModule = await import('heavy-library');

// ✅ React lazy loading
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

```html
<!-- Resource hints -->
<link rel="preload" href="critical.css" as="style">
<link rel="preload" href="hero.jpg" as="image">
<link rel="prefetch" href="next-page.js">
<link rel="preconnect" href="https://api.example.com">
```

#### Rendering Performance

```javascript
// ❌ Expensive computation on every render
function Component({ items }) {
  const sorted = items.sort((a, b) => a.name.localeCompare(b.name));
  return <List items={sorted} />;
}

// ✅ Memoize expensive computations
function Component({ items }) {
  const sorted = useMemo(() =>
    [...items].sort((a, b) => a.name.localeCompare(b.name)),
    [items]
  );
  return <List items={sorted} />;
}

// ✅ Prevent unnecessary child re-renders
const MemoizedChild = React.memo(ChildComponent);

// ✅ Stable callback references
const handleClick = useCallback((id) => {
  doSomething(id);
}, []);

// ✅ Virtual list for large datasets
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={400}
  itemCount={10000}
  itemSize={35}
  width="100%"
>
  {({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  )}
</FixedSizeList>
```

#### Asset Optimization

```
Images:
□ Modern formats (WebP, AVIF)
□ Responsive images (srcset)
□ Lazy loading (loading="lazy")
□ Proper sizing (no oversized images)

JavaScript:
□ Tree shaking enabled
□ Code splitting by route
□ Minification
□ Remove console.log in production

CSS:
□ Remove unused styles (PurgeCSS)
□ Critical CSS inlined
□ Minification
□ Avoid @import
```

### Step 4: Apply Backend Optimizations

#### Database Optimization

```sql
-- ❌ Missing index
SELECT * FROM orders WHERE user_id = 123;

-- ✅ Add index
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- ❌ SELECT * wastes bandwidth
SELECT * FROM users WHERE id = 1;

-- ✅ Select only needed columns
SELECT id, name, email FROM users WHERE id = 1;

-- ❌ Function in WHERE prevents index use
SELECT * FROM orders WHERE YEAR(created_at) = 2024;

-- ✅ Use range for index-friendly query
SELECT * FROM orders
WHERE created_at >= '2024-01-01'
  AND created_at < '2025-01-01';
```

#### N+1 Query Prevention

```javascript
// ❌ N+1 Problem
const users = await User.findAll();
for (const user of users) {
  const orders = await Order.findAll({ where: { userId: user.id } });
  // ...
}

// ✅ Eager loading
const users = await User.findAll({
  include: [{ model: Order }]
});

// ✅ Batch query
const userIds = users.map(u => u.id);
const orders = await Order.findAll({
  where: { userId: { [Op.in]: userIds } }
});
```

#### Caching Strategy

```
Cache Hierarchy:
┌─────────────┐
│   Browser   │ ← Cache-Control headers, Service Worker
└─────┬───────┘
      ↓
┌─────────────┐
│     CDN     │ ← Static assets, API responses
└─────┬───────┘
      ↓
┌─────────────┐
│   Redis     │ ← Session, computed values, hot data
└─────┬───────┘
      ↓
┌─────────────┐
│  Database   │ ← Query cache, materialized views
└─────────────┘
```

```javascript
// Redis caching pattern
async function getUser(id) {
  const cacheKey = `user:${id}`;

  // Try cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  // Fetch from database
  const user = await db.users.findById(id);

  // Cache with TTL
  await redis.setex(cacheKey, 3600, JSON.stringify(user));

  return user;
}

// Cache invalidation on update
async function updateUser(id, data) {
  await db.users.update(id, data);
  await redis.del(`user:${id}`);
}
```

#### Async Processing

```javascript
// ❌ Blocking on slow operation
app.post('/send-email', async (req, res) => {
  await sendEmail(req.body);  // Takes 2-5 seconds
  res.json({ success: true });
});

// ✅ Queue for async processing
app.post('/send-email', async (req, res) => {
  await queue.add('send-email', req.body);
  res.json({ success: true, message: 'Email queued' });
});

// Worker processes queue
queue.process('send-email', async (job) => {
  await sendEmail(job.data);
});
```

### Step 5: Optimize Algorithms

**Time Complexity Reference:**

| Complexity | Name | Example |
|------------|------|---------|
| O(1) | Constant | Hash table lookup |
| O(log n) | Logarithmic | Binary search |
| O(n) | Linear | Array iteration |
| O(n log n) | Linearithmic | Merge sort |
| O(n²) | Quadratic | Nested loops |
| O(2ⁿ) | Exponential | Recursive Fibonacci |

```javascript
// ❌ O(n²) - Nested loop for duplicates
function findDuplicates(arr) {
  const duplicates = [];
  for (let i = 0; i < arr.length; i++) {
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[i] === arr[j]) duplicates.push(arr[i]);
    }
  }
  return duplicates;
}

// ✅ O(n) - Use Set for O(1) lookups
function findDuplicates(arr) {
  const seen = new Set();
  const duplicates = new Set();
  for (const item of arr) {
    if (seen.has(item)) {
      duplicates.add(item);
    }
    seen.add(item);
  }
  return [...duplicates];
}
```

---

## Checklists

### Before Optimizing

```
[ ] Baseline metrics established
[ ] Bottleneck identified with profiling
[ ] Optimization goal defined
[ ] Impact of change understood
```

### Frontend Performance

```
[ ] Images optimized and lazy-loaded
[ ] JavaScript bundle split
[ ] Critical CSS inlined
[ ] Third-party scripts async/deferred
[ ] Web Vitals meet targets
```

### Backend Performance

```
[ ] Database queries optimized
[ ] Indexes cover key queries
[ ] N+1 patterns eliminated
[ ] Caching strategy implemented
[ ] Async processing for slow tasks
```

### After Optimizing

```
[ ] Improvement measured
[ ] No regressions introduced
[ ] Documentation updated
[ ] Monitoring in place
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Premature optimization | Wastes time on non-issues | Profile first |
| Guessing bottlenecks | Often wrong | Use profiling data |
| Over-caching | Stale data, complexity | Cache strategically |
| Micro-optimizations | Negligible gains | Focus on big wins |
| No baseline | Can't measure improvement | Establish metrics first |

---

## Tools / Commands

### Frontend

```bash
# Lighthouse audit
lighthouse https://example.com --output=html --view

# Chrome DevTools
# - Performance tab (record/analyze)
# - Network tab (waterfall)
# - Coverage tab (unused CSS/JS)

# Bundle analysis
npx webpack-bundle-analyzer stats.json
npx source-map-explorer build/static/js/*.js
```

### Backend

```bash
# Load testing
ab -n 1000 -c 100 http://localhost:3000/api/users
wrk -t4 -c100 -d30s http://localhost:3000/api/users
k6 run loadtest.js

# Node.js profiling
node --prof app.js
node --prof-process isolate-*.log > processed.txt
clinic doctor -- node app.js

# Python profiling
python -m cProfile -o output.prof script.py
py-spy record -o profile.svg -- python app.py
```

### Database

```sql
-- PostgreSQL query analysis
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM users WHERE status = 'active';

-- Find slow queries
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

---

## TAD Integration

### Gate Mapping

```yaml
Performance_Optimization:
  skill: performance-optimization.md
  enforcement: RECOMMENDED
  triggers:
    - Performance issues reported
    - Before production deployment
    - Code review of critical paths
  evidence_required:
    - baseline_metrics
    - profiling_data (for optimization work)
    - improvement_metrics
  acceptance:
    - Bottleneck identified with data
    - Optimization targeted correctly
    - Improvement verified
```

### Evidence Template

```markdown
## Performance Optimization Evidence

### Baseline Metrics
- API Response Time (P95): 450ms
- LCP: 3.2s
- Database query time: 200ms

### Profiling Results
Bottleneck identified: N+1 queries in /api/users endpoint
- 50 users = 51 queries (1 + 50 for orders)
- Each additional query: ~3ms

### Optimization Applied
Changed from lazy loading to eager loading:
```javascript
// Before
const users = await User.findAll();
// After
const users = await User.findAll({ include: [Order] });
```

### Results
- API Response Time (P95): 120ms (73% improvement)
- Database query time: 25ms (87% improvement)
- Single query instead of 51
```

---

## Related Skills

- `database-patterns.md` - Database-specific optimization
- `testing-strategy.md` - Performance testing approaches
- `software-architecture.md` - System-level performance design
- `refactoring.md` - Clean code without sacrificing performance

---

## References

- [High Performance Browser Networking](https://hpbn.co/)
- [Web Vitals](https://web.dev/vitals/)
- [Systems Performance - Brendan Gregg](https://www.brendangregg.com/systems-performance-2nd-edition-book.html)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [React Performance](https://react.dev/learn/render-and-commit)

---

*This skill guides Claude in data-driven performance analysis and optimization.*
