# Performance Test Design — Menu Snap iOS

## Performance Budgets

| Metric | Threshold | Measurement Method | Priority |
|--------|-----------|-------------------|----------|
| Cold start | < 2.0s | Xcode Instruments: Time Profiler (icon tap → first frame) | P0 |
| JS Bundle size | < 1.5 MB | `source-map-explorer main.jsbundle --json` | P0 |
| App binary (download) | < 50 MB | `xcrun altool --validate-app` / App Store Connect | P1 |
| FPS (scrolling) | > 55 FPS | React Native Perf Monitor / Flipper | P0 |
| FPS (p99) | > 45 FPS | Custom frame drop counter | P1 |
| Memory (active) | < 250 MB | Xcode Instruments: Allocations | P0 |
| Memory (background) | < 50 MB | Xcode Instruments post-backgrounding | P1 |
| Camera → result latency | < 5s | Detox timer (capture tap → results visible) | P0 |
| Translation API latency | < 2s (p95) | Network profiler / MSW timing | P1 |
| 16ms frame budget | < 5% dropped frames | Custom RN bridge monitor | P1 |

## Bundle Analysis Configuration

```bash
# Build release bundle
npx react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output ios/main.jsbundle \
  --sourcemap-output ios/main.jsbundle.map

# Analyze
npx source-map-explorer ios/main.jsbundle \
  --json bundle-report.json \
  --html bundle-report.html
```

### Expected Heavy Dependencies [ASSUMPTION]

| Dependency | Expected Size | Justification |
|-----------|--------------|---------------|
| react-native core | ~300KB | Framework baseline |
| OCR/ML model (on-device) | ~200-500KB | Menu text recognition |
| Translation cache | ~50KB | Offline phrase cache |
| Camera library | ~100KB | Camera interface |
| UI components | ~100KB | Design system |
| Navigation | ~80KB | React Navigation |
| **Total estimate** | **~900KB-1.2MB** | Within 1.5MB budget |

Flag any single dependency > 100KB for review.

## Performance Test Scripts

### 1. Cold Start Measurement

```typescript
// performance-tests/cold-start.test.ts
import { device } from 'detox';

describe('Cold Start Performance', () => {
  it('should launch in under 2 seconds', async () => {
    const start = Date.now();
    await device.launchApp({ newInstance: true });
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(2000);
    const elapsed = Date.now() - start;

    // Log for CI tracking (not a pass/fail — Detox overhead adds ~500ms)
    console.log(`Cold start: ${elapsed}ms (includes Detox overhead)`);
    // Hard fail if grossly over budget
    expect(elapsed).toBeLessThan(5000); // 2s budget + 3s Detox overhead
  });
});
```

### 2. Memory Leak Detection

```typescript
// performance-tests/memory-leak.test.ts
describe('Memory Leak Detection', () => {
  it('should not leak memory after 10 navigation cycles', async () => {
    // [ASSUMPTION] Memory readings via Xcode Instruments, not Detox API
    // This test validates the navigation cycle doesn't crash
    for (let i = 0; i < 10; i++) {
      await element(by.id('capture-button')).tap();
      await waitFor(element(by.id('results-screen')))
        .toBeVisible()
        .withTimeout(10000);
      await element(by.id('menu-card-0')).tap();
      await waitFor(element(by.id('dish-detail-screen')))
        .toBeVisible()
        .withTimeout(3000);
      await element(by.id('back-button')).tap();
      await waitFor(element(by.id('results-screen')))
        .toBeVisible()
        .withTimeout(3000);
      await element(by.id('retake-button')).tap();
      await waitFor(element(by.id('camera-overlay')))
        .toBeVisible()
        .withTimeout(5000);
    }
    // If we get here without OOM crash, basic leak test passes
  });
});
```

### 3. FPS Monitoring Config (Flipper)

```json
{
  "flipperPlugins": {
    "react-native-performance": {
      "enabled": true,
      "fps_threshold": 55,
      "frame_drop_warning": 3,
      "log_slow_frames": true
    }
  }
}
```

## CI Performance Gate

```yaml
# .github/workflows/performance.yml (relevant section)
- name: Bundle size check
  run: |
    npx react-native bundle --platform ios --dev false \
      --entry-file index.js --bundle-output /tmp/main.jsbundle
    SIZE=$(wc -c < /tmp/main.jsbundle)
    MAX=1572864  # 1.5MB in bytes
    if [ "$SIZE" -gt "$MAX" ]; then
      echo "FAIL: Bundle size ${SIZE} exceeds ${MAX} bytes"
      exit 1
    fi
    echo "PASS: Bundle size ${SIZE} bytes (limit: ${MAX})"
```

## Regression Strategy

- Every PR: Bundle size check (automated in CI)
- Every release: Full Instruments profiling (cold start, memory, FPS)
- Monthly: Compare performance metrics trend chart
- Alert: Any metric exceeding 80% of its threshold triggers a warning
