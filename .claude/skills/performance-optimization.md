# Performance Optimization Skill

---
title: "Performance Optimization"
version: "3.0"
last_updated: "2026-01-06"
tags: [performance, optimization, profiling, caching, apm, load-testing, engineering]
domains: [frontend, backend, all]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "High Performance Browser Networking - Ilya Grigorik"
  - "Web Vitals - Google"
  - "Systems Performance - Brendan Gregg"
  - "k6 Documentation"
  - "OpenTelemetry Specification"
enforcement: recommended
tad_gates: [Gate2_Design, Gate4_Review]
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

### Artifacts

| Artifact            | Path                                  |
|---------------------|---------------------------------------|
| Baseline Profile    | `.tad/evidence/perf/baseline.md`      |
| Improved Profile    | `.tad/evidence/perf/improved.md`      |
| APM Trace/Report    | `.tad/evidence/perf/traces/`          |

---

## Procedure

### Step 1: Define Performance Budget

**What is a Performance Budget?**
A performance budget is a set of limits on metrics that affect user experience. Budgets create accountability and prevent performance regressions.

**Performance Budget Template:**
```yaml
# .performance-budget.yaml
budgets:
  # Core Web Vitals (Google ranking factors)
  web_vitals:
    LCP: 2500ms      # Largest Contentful Paint
    FID: 100ms       # First Input Delay
    INP: 200ms       # Interaction to Next Paint
    CLS: 0.1         # Cumulative Layout Shift
    TTFB: 800ms      # Time to First Byte
    FCP: 1800ms      # First Contentful Paint

  # Bundle Size Budgets
  bundle_size:
    total_js: 300KB          # Compressed JS
    total_css: 100KB         # Compressed CSS
    largest_chunk: 150KB     # Lazy-loaded chunk limit
    initial_bundle: 170KB    # Main bundle limit
    images_per_page: 500KB   # Image weight per page

  # API Performance Budgets
  api_latency:
    p50: 100ms       # Median response time
    p95: 500ms       # 95th percentile
    p99: 1000ms      # 99th percentile
    error_rate: 0.1% # Max error rate

  # Resource Budgets
  resources:
    third_party_requests: 5  # Max external requests
    total_requests: 50       # Max requests per page
    fonts: 2                 # Max font files
```

**Budget Enforcement in CI/CD:**
```javascript
// lighthouse-budget.json (Lighthouse CI)
{
  "ci": {
    "collect": {
      "numberOfRuns": 3,
      "url": ["http://localhost:3000"]
    },
    "assert": {
      "assertions": {
        "first-contentful-paint": ["error", {"maxNumericValue": 1800}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "interactive": ["error", {"maxNumericValue": 3500}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "resource-summary:script:size": ["error", {"maxNumericValue": 300000}]
      }
    }
  }
}
```

```yaml
# GitHub Actions - Performance Budget Check
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v10
  with:
    urls: |
      https://staging.example.com
      https://staging.example.com/dashboard
    budgetPath: ./lighthouse-budget.json
    uploadArtifacts: true
```

### Step 2: Establish Performance Baseline

**Frontend (Web Vitals):**

| Metric | Meaning | Good | Needs Improvement | Poor |
|--------|---------|------|-------------------|------|
| LCP | Largest Contentful Paint | < 2.5s | 2.5s - 4s | > 4s |
| FID/INP | Input Delay / Interaction | < 100ms/200ms | 100-300ms | > 300ms |
| CLS | Cumulative Layout Shift | < 0.1 | 0.1 - 0.25 | > 0.25 |
| TTFB | Time to First Byte | < 800ms | 800ms - 1.8s | > 1.8s |
| FCP | First Contentful Paint | < 1.8s | 1.8s - 3s | > 3s |

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

### Step 3: Profile to Find Bottlenecks

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

### Step 4: Apply Frontend Optimizations

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

### Step 5: Apply Backend Optimizations

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

### Step 6: Optimize Algorithms

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

### Step 7: APM and Distributed Tracing

**What is APM (Application Performance Monitoring)?**
APM provides end-to-end visibility into application performance, from browser to database. Distributed tracing tracks requests across microservices.

#### OpenTelemetry Setup (Node.js)

```typescript
// tracing.ts - Initialize at app start
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'my-api-service',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-http': {
        ignoreIncomingPaths: ['/health', '/metrics'],
      },
      '@opentelemetry/instrumentation-express': {},
      '@opentelemetry/instrumentation-pg': {},
      '@opentelemetry/instrumentation-redis': {},
    }),
  ],
});

sdk.start();
process.on('SIGTERM', () => sdk.shutdown());
```

#### Custom Spans for Business Logic

```typescript
import { trace, SpanStatusCode, context } from '@opentelemetry/api';

const tracer = trace.getTracer('my-service');

async function processOrder(orderId: string) {
  // Create custom span
  return tracer.startActiveSpan('processOrder', async (span) => {
    try {
      // Add attributes
      span.setAttribute('order.id', orderId);
      span.setAttribute('order.source', 'web');

      // Child span for validation
      await tracer.startActiveSpan('validateOrder', async (validationSpan) => {
        const isValid = await validateOrder(orderId);
        validationSpan.setAttribute('order.valid', isValid);
        validationSpan.end();
      });

      // Child span for payment
      await tracer.startActiveSpan('processPayment', async (paymentSpan) => {
        const payment = await chargePayment(orderId);
        paymentSpan.setAttribute('payment.method', payment.method);
        paymentSpan.setAttribute('payment.amount', payment.amount);
        paymentSpan.end();
      });

      span.setStatus({ code: SpanStatusCode.OK });
      return { success: true };
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

#### Context Propagation (Microservices)

```typescript
// Service A: Outgoing request
import { propagation, context } from '@opentelemetry/api';

async function callServiceB(data: any) {
  const headers: Record<string, string> = {};

  // Inject trace context into headers
  propagation.inject(context.active(), headers);

  const response = await fetch('http://service-b/api/process', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...headers,  // Includes traceparent, tracestate
    },
    body: JSON.stringify(data),
  });

  return response.json();
}
```

```typescript
// Service B: Incoming request (Express middleware)
import { propagation, context, trace } from '@opentelemetry/api';

app.use((req, res, next) => {
  // Extract trace context from headers
  const ctx = propagation.extract(context.active(), req.headers);

  // Run handler with extracted context
  context.with(ctx, () => {
    const span = trace.getActiveSpan();
    if (span) {
      span.setAttribute('http.user_agent', req.headers['user-agent']);
      span.setAttribute('http.client_ip', req.ip);
    }
    next();
  });
});
```

#### APM Dashboard Metrics

```yaml
# Key metrics to monitor in APM dashboard
dashboard_panels:
  # Request Performance
  - name: "Request Latency"
    metrics:
      - http_server_duration_p50
      - http_server_duration_p95
      - http_server_duration_p99
    alert: "p95 > 500ms"

  # Error Rate
  - name: "Error Rate"
    metrics:
      - http_server_requests_total{status_code=~"5.."}
      - http_server_requests_total
    formula: "errors / total * 100"
    alert: "> 1%"

  # Database Performance
  - name: "DB Query Latency"
    metrics:
      - db_client_duration_p50
      - db_client_duration_p95
    alert: "p95 > 100ms"

  # External Dependencies
  - name: "External API Latency"
    metrics:
      - http_client_duration_by_host
    group_by: "peer.service"

  # Trace Analysis
  - name: "Slow Traces"
    filter: "duration > 1s"
    show: "trace_id, service, operation, duration"
```

### Step 8: Load Testing with k6

#### Basic k6 Test Script

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const apiDuration = new Trend('api_duration');

// Test configuration
export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up to 50 users
    { duration: '3m', target: 50 },   // Stay at 50 users
    { duration: '1m', target: 100 },  // Ramp up to 100 users
    { duration: '3m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],  // 95% < 500ms
    errors: ['rate<0.01'],                           // Error rate < 1%
    api_duration: ['p(95)<400'],                     // Custom metric
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // Test scenario
  const loginRes = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
    email: 'test@example.com',
    password: 'password123',
  }), {
    headers: { 'Content-Type': 'application/json' },
  });

  check(loginRes, {
    'login status is 200': (r) => r.status === 200,
    'login has token': (r) => JSON.parse(r.body).token !== undefined,
  }) || errorRate.add(1);

  const token = JSON.parse(loginRes.body).token;

  // Authenticated request
  const start = Date.now();
  const productsRes = http.get(`${BASE_URL}/api/products`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  apiDuration.add(Date.now() - start);

  check(productsRes, {
    'products status is 200': (r) => r.status === 200,
    'products has data': (r) => JSON.parse(r.body).length > 0,
  }) || errorRate.add(1);

  sleep(1);  // Think time between requests
}

// Lifecycle hooks
export function setup() {
  console.log('Test starting...');
  // Seed test data if needed
}

export function teardown(data) {
  console.log('Test complete!');
  // Cleanup test data
}
```

#### k6 Scenarios for Different Load Patterns

```javascript
// scenarios.js - Different load testing patterns
export const options = {
  scenarios: {
    // Scenario 1: Constant load
    constant_load: {
      executor: 'constant-vus',
      vus: 50,
      duration: '5m',
    },

    // Scenario 2: Ramping load
    ramping_load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 100 },
        { duration: '5m', target: 100 },
        { duration: '2m', target: 200 },
        { duration: '5m', target: 200 },
        { duration: '2m', target: 0 },
      ],
    },

    // Scenario 3: Spike test
    spike_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 100 },   // Instant spike
        { duration: '1m', target: 100 },
        { duration: '10s', target: 500 },   // Massive spike
        { duration: '3m', target: 500 },
        { duration: '10s', target: 100 },   // Back to normal
        { duration: '3m', target: 100 },
        { duration: '10s', target: 0 },
      ],
    },

    // Scenario 4: Stress test (find breaking point)
    stress_test: {
      executor: 'ramping-arrival-rate',
      startRate: 50,
      timeUnit: '1s',
      preAllocatedVUs: 500,
      stages: [
        { duration: '2m', target: 50 },
        { duration: '5m', target: 200 },
        { duration: '5m', target: 500 },
        { duration: '5m', target: 1000 },  // Breaking point?
        { duration: '2m', target: 50 },
      ],
    },

    // Scenario 5: Soak test (long-running)
    soak_test: {
      executor: 'constant-vus',
      vus: 100,
      duration: '4h',  // Run for 4 hours
    },
  },
};
```

#### k6 with Browser Testing

```javascript
// browser-test.js - Real browser metrics with k6 browser module
import { browser } from 'k6/experimental/browser';
import { check } from 'k6';

export const options = {
  scenarios: {
    ui: {
      executor: 'shared-iterations',
      options: {
        browser: {
          type: 'chromium',
        },
      },
    },
  },
  thresholds: {
    'browser_web_vital_lcp': ['p(95)<2500'],
    'browser_web_vital_fid': ['p(95)<100'],
    'browser_web_vital_cls': ['p(95)<0.1'],
  },
};

export default async function () {
  const page = browser.newPage();

  try {
    await page.goto('https://example.com');

    // Wait for page load
    await page.waitForSelector('h1');

    // Interact with page
    await page.locator('input[name="search"]').type('product');
    await page.locator('button[type="submit"]').click();

    // Check results
    const results = await page.locator('.search-results').count();
    check(results, {
      'search results exist': (r) => r > 0,
    });

    // Get Web Vitals
    const lcp = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          resolve(entries[entries.length - 1].startTime);
        }).observe({ type: 'largest-contentful-paint', buffered: true });
      });
    });

    console.log(`LCP: ${lcp}ms`);
  } finally {
    page.close();
  }
}
```

#### k6 CI/CD Integration

```yaml
# .github/workflows/load-test.yml
name: Load Test

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:      # Manual trigger

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run k6 load test
        uses: grafana/k6-action@v0.3.1
        with:
          filename: tests/load/scenarios.js
          flags: --out influxdb=http://influxdb:8086/k6
        env:
          BASE_URL: ${{ secrets.STAGING_URL }}

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: k6-results
          path: results/

      - name: Check thresholds
        run: |
          if [ -f results/summary.json ]; then
            FAILED=$(jq '.metrics.http_req_duration.thresholds.["p(95)<500"]' results/summary.json)
            if [ "$FAILED" = "false" ]; then
              echo "Performance threshold failed!"
              exit 1
            fi
          fi
```

---

## Checklists

### Performance Budget

```
[ ] Performance budget defined (.performance-budget.yaml)
[ ] Web Vitals thresholds set (LCP < 2.5s, FID < 100ms, CLS < 0.1)
[ ] Bundle size limits defined
[ ] API latency thresholds set (p95 < 500ms)
[ ] Budget enforcement in CI/CD
[ ] Alert thresholds configured
```

### Before Optimizing

```
[ ] Baseline metrics established
[ ] Bottleneck identified with profiling
[ ] Optimization goal defined
[ ] Impact of change understood
[ ] Performance budget constraints known
```

### Frontend Performance

```
[ ] Images optimized and lazy-loaded
[ ] JavaScript bundle split
[ ] Critical CSS inlined
[ ] Third-party scripts async/deferred
[ ] Web Vitals meet budget targets
[ ] Bundle size within budget
```

### Backend Performance

```
[ ] Database queries optimized
[ ] Indexes cover key queries
[ ] N+1 patterns eliminated
[ ] Caching strategy implemented
[ ] Async processing for slow tasks
[ ] API latency within budget (p50/p95/p99)
```

### APM and Observability

```
[ ] OpenTelemetry/tracing configured
[ ] Custom spans for business logic
[ ] Context propagation between services
[ ] APM dashboard configured
[ ] Alerting on latency/error thresholds
[ ] Slow trace investigation workflow
```

### Load Testing

```
[ ] k6 test scenarios defined
[ ] Thresholds match performance budget
[ ] Load test in CI/CD pipeline
[ ] Spike/stress test scenarios ready
[ ] Soak test for memory leaks
[ ] Results tracked over time
```

### After Optimizing

```
[ ] Improvement measured against baseline
[ ] No regressions introduced
[ ] Performance budget still met
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
  tad_gates: [Gate2_Design, Gate4_Review]
  triggers:
    - Performance issues reported
    - Before production deployment
    - Code review of critical paths
    - New API endpoint created
    - Bundle size increase detected
  evidence_required:
    - performance_budget (defined and enforced)
    - baseline_metrics (before optimization)
    - profiling_data (for optimization work)
    - apm_traces (for distributed systems)
    - load_test_results (k6 output)
    - improvement_metrics (after optimization)
  acceptance:
    - Performance budget defined
    - Bottleneck identified with data
    - Optimization targeted correctly
    - Improvement verified against budget
    - Load test thresholds passing
    - APM tracing configured
```

### Evidence Template

```markdown
## Performance Optimization Evidence - [Feature/Area]

**Date:** YYYY-MM-DD
**Author:** [Name]
**Gate:** Gate4_Review

---

### 1. Performance Budget Status

**Defined Budget:**
| Metric | Budget | Current | Status |
|--------|--------|---------|--------|
| LCP | < 2.5s | 2.1s | ✅ Pass |
| FID/INP | < 100ms | 85ms | ✅ Pass |
| CLS | < 0.1 | 0.05 | ✅ Pass |
| API p95 | < 500ms | 320ms | ✅ Pass |
| JS Bundle | < 300KB | 275KB | ✅ Pass |

**CI/CD Enforcement:** ✅ Lighthouse CI configured

---

### 2. Baseline Metrics (Before Optimization)

**Frontend:**
- LCP: 3.2s
- FCP: 2.1s
- Bundle Size: 420KB

**Backend:**
- API Response Time (P50): 180ms
- API Response Time (P95): 450ms
- Database query time: 200ms

---

### 3. Profiling Results

**Bottleneck Identified:** N+1 queries in /api/users endpoint

**Evidence:**
\`\`\`
Trace ID: abc123
Span: GET /api/users
Duration: 450ms
  └─ db.query (users): 5ms
  └─ db.query (orders): 3ms × 50 = 150ms  ← N+1 PROBLEM
  └─ db.query (orders): 3ms × 50 = 150ms
  └─ serialization: 45ms
\`\`\`

**Root Cause:** Lazy loading orders for each user

---

### 4. Optimization Applied

**Change:**
\`\`\`javascript
// Before
const users = await User.findAll();

// After
const users = await User.findAll({
  include: [{ model: Order, attributes: ['id', 'total'] }]
});
\`\`\`

**PR:** #1234

---

### 5. Load Test Results (k6)

\`\`\`
scenarios: { default: 100 VUs for 5m }

     ✓ http_req_duration..............: avg=95.2ms  p(95)=120ms  p(99)=180ms
     ✓ http_req_failed................: 0.00%
     ✓ errors.........................: 0.00%
     ✓ iterations.....................: 28,450

     checks.........................: 100.00% ✓ 28450  ✗ 0
\`\`\`

**Threshold Status:** All passing

---

### 6. APM Verification

**Trace After Optimization:**
\`\`\`
Trace ID: def456
Span: GET /api/users
Duration: 120ms  ← 73% improvement
  └─ db.query (users + orders JOIN): 25ms
  └─ serialization: 45ms
\`\`\`

**Dashboard Screenshot:** [Link to APM dashboard]

---

### 7. Results Summary

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| API P50 | 180ms | 65ms | 64% |
| API P95 | 450ms | 120ms | 73% |
| DB Queries | 51 | 1 | 98% |
| DB Time | 200ms | 25ms | 87% |

**Budget Compliance:** ✅ All metrics within budget

---

### Sign-off

**Optimization Complete:** ✅
**Budget Met:** ✅
**Load Test Passing:** ✅
**Ready for Gate4:** Yes
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
