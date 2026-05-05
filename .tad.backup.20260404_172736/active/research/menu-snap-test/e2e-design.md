# E2E Test Design — Menu Snap iOS

## Framework Selection

| Dimension | Detox | Maestro | Appium |
|-----------|-------|---------|--------|
| Approach | Grey-box (in-process) | Black-box (YAML declarative) | Black-box (WebDriver) |
| Flakiness | <2% | Low (auto-retry) | 10-15% |
| Speed | Fastest (internal sync) | Medium (12-18s/flow) | Slowest |
| Learning curve | Medium (JS) | Low (YAML) | High (WebDriver) |
| Best for | React Native | Cross-framework | Enterprise |

**Decision: Detox**
- Menu Snap is a React Native app — Detox is purpose-built for RN with grey-box synchronization
- JS/TS test authoring matches the team's existing stack
- Lowest flake rate (<2%) is critical for CI trust
- Native synchronization with RN bridge eliminates timing hacks

## Core Flows (5 E2E tests)

| # | Flow | File | Priority |
|---|------|------|----------|
| 1 | Camera Scan -> Results Display | `e2e/camera-scan-flow.test.ts` | P0 |
| 2 | Dish Detail View | `e2e/dish-detail-flow.test.ts` | P0 |
| 3 | Save to Favorites | `e2e/save-favorite-flow.test.ts` | P0 |
| 4 | Dietary Filter Application | `e2e/dietary-filter-flow.test.ts` | P0 |
| 5 | Offline / Error Recovery | `e2e/error-recovery-flow.test.ts` | P1 |

## Detox Configuration

```js
// .detoxrc.js
module.exports = {
  testRunner: {
    args: { $0: 'jest', config: 'e2e/jest.config.js' },
    jest: { setupTimeout: 120000 },
  },
  apps: {
    'ios.release': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Release-iphonesimulator/MenuSnap.app',
      build: 'xcodebuild -workspace ios/MenuSnap.xcworkspace -scheme MenuSnap -configuration Release -sdk iphonesimulator -derivedDataPath ios/build',
    },
  },
  devices: {
    simulator: { type: 'ios.simulator', device: { type: 'iPhone 15' } },
  },
  configurations: {
    'ios.sim.release': { device: 'simulator', app: 'ios.release' },
  },
};
```

## Conventions

- Element selection: ALWAYS use `testID` (never text matchers — menu items are multilingual)
- Waiting: `waitFor(element(by.id(...))).toBeVisible().withTimeout(5000)` — zero `sleep()` calls
- Startup: `beforeAll` -> `device.launchApp()`, `beforeEach` -> `device.reloadReactNative()`
- Scrolling: `whileElement(by.id('scroll-view')).scroll(200, 'down')`
- Screenshots: `device.takeScreenshot('failure-name')` on failure via Jest afterEach

## Camera Mock Strategy

[ASSUMPTION] Camera hardware is mocked in E2E tests since simulators lack a physical camera.
- Use a Detox `device.setURLBlacklist` + pre-loaded test images injected via a mock camera module
- The mock returns a static menu image for OCR/translation testing
- This ensures deterministic results regardless of simulator camera support

## Optimization

1. **Parallelization**: Flows 1-4 are independent — can run on 2 simulators in parallel
2. **Data isolation**: Each test uses fresh app state (`device.launchApp({ delete: true })` for critical flows)
3. **Screenshots on failure**: Jest `afterEach` hook captures screenshot if test failed
4. **CI integration**: GitHub Actions with `macos-14` runner + Xcode 16 + pre-built simulator
5. **Flake monitoring**: Track pass rate per test — >5% flake rate = P0 fix required
