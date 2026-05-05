# Performance Review Output Format

> Extracted from performance-optimization skill - use this for performance audits

## Quick Checklist

```
1. [ ] Bundle size < 200KB (gzipped JS)
2. [ ] First Contentful Paint < 1.8s
3. [ ] Time to Interactive < 3.8s
4. [ ] No N+1 queries in database
5. [ ] Images optimized (WebP, lazy loading)
6. [ ] Caching strategy implemented
```

## Red Flags

- Bundle > 500KB without code splitting
- Synchronous API calls blocking render
- No pagination on large data sets
- Missing database indexes on filtered columns
- Full table scans in production
- No CDN for static assets

## Output Format

### Performance Audit Report

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Bundle Size (gzip) | < 200KB | [value] | Pass/Fail |
| FCP | < 1.8s | [value] | Pass/Fail |
| LCP | < 2.5s | [value] | Pass/Fail |
| TTI | < 3.8s | [value] | Pass/Fail |
| CLS | < 0.1 | [value] | Pass/Fail |

### Database Performance

| Query | Execution Time | Index Used | Recommendation |
|-------|---------------|------------|----------------|
| [query] | [time] | Yes/No | [suggestion] |

### Bottleneck Analysis

| Component | Issue | Impact | Fix |
|-----------|-------|--------|-----|
| [component] | [issue] | High/Med/Low | [solution] |

### Optimization Recommendations

1. **Critical**: ...
2. **Important**: ...
3. **Nice to have**: ...
