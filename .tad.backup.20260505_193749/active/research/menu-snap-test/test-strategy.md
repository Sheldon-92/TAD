# Mobile Test Strategy — Menu Snap iOS

## Test Pyramid (Adapted for Camera-Heavy App)

Standard mobile: 70% unit / 20% integration / 10% E2E.
**Menu Snap adjustment:** Camera + translation pipeline is the core value — needs heavier integration/E2E.

| Layer | Ratio | Count (est.) | What It Covers | Run When |
|-------|-------|-------------|----------------|----------|
| Unit | **60%** | ~120 tests | Components, hooks, utils, dietary filter logic, price formatting | Every commit |
| Integration | **25%** | ~50 tests | Camera→OCR pipeline, Translation API, AsyncStorage, Navigation flows | Every PR |
| E2E | **15%** | ~15 flows | 5 core + 5 error/edge + 5 device-specific | Every merge to main |

**Rationale for 60/25/15 (not 70/20/10):**
- Camera scan → translate → display is a multi-service pipeline. Pure unit tests can't validate the pipeline.
- Dietary filter + AI recommendation depend on translation output — integration layer validates this chain.
- 15% E2E (vs 10%) because camera UX is the product's core differentiator.

## Coverage Targets (Per Module)

| Module | Unit | Integration | E2E | Rationale |
|--------|------|------------|-----|-----------|
| Camera / OCR | 40% | 80% | Full flow | Hardware-dependent, integration matters more |
| Translation | 70% | 90% | Full flow | API contract + fallback logic |
| Dietary Filter | 95% | 60% | Full flow | Pure logic, highly unit-testable |
| UI Components | 85% | 30% | Covered by flow | Visual, needs render tests |
| Favorites | 80% | 70% | Full flow | State persistence matters |
| Navigation | 50% | 80% | Covered by flow | Integration-heavy |

## CI/CD Pipeline

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐     ┌────────────┐
│   Lint       │────>│  Unit Tests  │────>│    Build     │────>│  E2E Tests   │────>│  Deploy     │
│  (30s)       │     │  (2-3 min)   │     │  (5-8 min)   │     │ (10-15 min)  │     │ (TestFlight)│
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘     └────────────┘
     │                    │                     │                    │                    │
  ESLint +            Jest +               Xcode build         Detox on             Fastlane
  a11y lint           Coverage             + bundle size       iOS Simulator        upload
  Prettier            report               analysis            (iPhone 15)
```

### GitHub Actions Configuration

```yaml
# .github/workflows/ci.yml
name: Menu Snap CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npx eslint src/ --ext .ts,.tsx
      - run: npx prettier --check src/

  unit-test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npx jest --coverage --ci
      - name: Check coverage thresholds
        run: |
          # Jest --coverageThreshold in jest.config.js handles this
          echo "Coverage report generated"
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/

  build:
    runs-on: macos-14
    needs: unit-test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - name: Bundle size check
        run: |
          npx react-native bundle --platform ios --dev false \
            --entry-file index.js --bundle-output /tmp/main.jsbundle
          SIZE=$(wc -c < /tmp/main.jsbundle)
          MAX=1572864
          if [ "$SIZE" -gt "$MAX" ]; then
            echo "::error::Bundle size ${SIZE} exceeds 1.5MB limit"
            exit 1
          fi
      - name: Build iOS
        run: |
          cd ios && pod install
          xcodebuild -workspace MenuSnap.xcworkspace \
            -scheme MenuSnap -configuration Release \
            -sdk iphonesimulator -derivedDataPath build \
            | xcpretty

  e2e-test:
    runs-on: macos-14
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - name: Boot simulator
        run: |
          xcrun simctl boot "iPhone 15"
      - name: Run Detox E2E
        run: |
          npx detox test --configuration ios.sim.release \
            --cleanup --artifacts-location /tmp/detox-artifacts
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: detox-artifacts
          path: /tmp/detox-artifacts/

  deploy-testflight:
    runs-on: macos-14
    needs: [e2e-test]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to TestFlight
        run: |
          cd ios && fastlane beta
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_KEY }}
```

## Flake Rate Policy

| Flake Rate | Action |
|-----------|--------|
| < 2% | Acceptable — monitor |
| 2-5% | Warning — investigate within 1 sprint |
| > 5% | **P0** — must fix before next release |

Track per-test flake rate via CI history. Quarantine flaky tests (skip + track) rather than letting them erode CI trust.

## Device Testing Strategy (3 Tiers)

| Tier | Devices | When | Purpose |
|------|---------|------|---------|
| **Simulator (CI)** | iPhone 15 simulator | Every merge to main | Automated E2E validation |
| **Cloud (Release)** | BrowserStack: SE 3 + 15 + 16 Pro Max + iPad mini | Every release candidate | Device matrix coverage |
| **Physical (Critical)** | Team's physical devices | Major releases + camera features | Real camera, real haptics, real feel |

## Quality Gates (Test-Related)

| Gate | Tests Required | Fail = Block |
|------|---------------|--------------|
| PR merge | Lint + Unit (100% pass) + Coverage thresholds | Yes |
| Merge to main | + E2E on simulator (100% pass) | Yes |
| Release candidate | + Cloud device matrix (100% core flows) | Yes |
| App Store submit | + Performance benchmarks + a11y audit | Yes |

## Risk Areas Specific to Menu Snap

| Risk | Mitigation |
|------|-----------|
| Camera on different devices | Cloud device testing tier |
| OCR accuracy varies by menu quality | Integration tests with diverse menu images |
| Translation API downtime | Offline fallback + retry E2E test |
| Large menu = many cards = scroll perf | FPS monitoring + memory leak test |
| Dietary filter logic complexity | 95% unit coverage target |
