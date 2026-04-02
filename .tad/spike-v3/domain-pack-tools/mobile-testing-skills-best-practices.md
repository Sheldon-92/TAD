# Mobile Testing Skills Best Practices — Research Summary

**Sources**: 5 GitHub repos + framework docs + performance guides (2026-04-01 research)

---

## Repositories Researched

| # | Repository | Stars | Key Strength |
|---|-----------|-------|-------------|
| 1 | [callstackincubator/agent-skills](https://github.com/callstackincubator/agent-skills) | ~500 | Callstack's official RN skills — Jest/RNTL patterns, performance profiling, bundle analysis |
| 2 | [mobile-dev-inc/Maestro](https://github.com/mobile-dev-inc/Maestro) + [Discussion #2985](https://github.com/mobile-dev-inc/Maestro/discussions/2985) | 10.8K | Maestro E2E framework + first Claude Code skill for mobile E2E testing |
| 3 | [senaiverse/claude-code-reactnative-expo-agent-system](https://github.com/senaiverse/claude-code-reactnative-expo-agent-system) | ~200 | 7-agent system: accessibility (WCAG 2.2), performance budgets, security (OWASP Mobile Top 10) |
| 4 | [conorluddy/ios-simulator-skill](https://github.com/conorluddy/ios-simulator-skill) | ~150 | 21 production scripts for iOS simulator — semantic UI navigation via accessibility APIs, not pixel coords |
| 5 | [new-silvermoon/awesome-android-agent-skills](https://github.com/new-silvermoon/awesome-android-agent-skills) + [dpconde/claude-android-skill](https://github.com/dpconde/claude-android-skill) | ~300 | Android testing SKILL.md — JUnit5, Compose testing, Espresso, no-mock-library philosophy |

---

## Capability 1: mobile_e2e — E2E Testing Patterns

### Framework Comparison (2026 state)

| Aspect | Detox | Maestro | Appium |
|--------|-------|---------|--------|
| Approach | Gray-box (inside app process) | Black-box (YAML declarative) | Black-box (WebDriver protocol) |
| Language | JavaScript/TypeScript | YAML (no code) | Any (JS, Python, Java) |
| Platform | React Native only | Android, iOS, Web (framework-agnostic) | iOS, Android, hybrid, web |
| Flakiness | <2% (JS thread sync) | Low (auto-retry assertions) | 10-15% typical |
| Speed | Fastest (internal sync) | 12-18s per flow | Slowest (external comms) |
| GitHub Stars | ~11.5K | ~10.8K | ~21.2K |
| Best For | RN-dedicated teams | Cross-platform, fast adoption | Enterprise, multi-tech |

### Detox Patterns (from callstackincubator + Detox docs)

```javascript
// Setup pattern — launch once, reload between tests
beforeAll(async () => { await device.launchApp(); });
beforeEach(async () => { await device.reloadReactNative(); });

// Element selection — ALWAYS use testID, never text for stability
await element(by.id('login-button')).tap();
await element(by.id('email-input')).typeText('test@example.com');

// Wait pattern — explicit timeout, never sleep()
await waitFor(element(by.id('home-screen')))
  .toBeVisible()
  .withTimeout(5000);

// Scroll pattern
await element(by.id('scroll-view')).scroll(200, 'down');
await waitFor(element(by.id('bottom-item')))
  .toBeVisible()
  .whileElement(by.id('scroll-view'))
  .scroll(100, 'down');

// Device operations
await device.setLocation(37.7749, -122.4194); // GPS mock
await device.shake(); // Gesture
await device.setURLBlacklist(['.*analytics.*']); // Network stub
```

**Anti-patterns**: `sleep(3000)` instead of `waitFor`. Text matchers for dynamic content. Not using `device.reloadReactNative()` between tests.

### Maestro YAML Patterns (from Maestro Claude Skill — Discussion #2985)

```yaml
# Basic flow
appId: com.example.app
---
- launchApp
- assertVisible: "Welcome!"
- tapOn: "Log In"
- tapOn:
    id: "email-input"
- inputText: "test@example.com"
- tapOn:
    id: "password-input"
- inputText: "password123"
- tapOn: "Submit"
- assertVisible: "Dashboard"

# Scroll until visible
- scrollUntilVisible:
    element: "Settings"
    direction: DOWN
    timeout: 10000

# Conditional flows (auth state detection)
- runFlow:
    when:
      visible: "Sign In"
    file: login-flow.yaml

# GraalJS constraints (LLM COMMON MISTAKE)
# NO async/await, NO fetch() — use http.get() and json()
- evalScript: ${output.data = json(http.get('https://api.example.com/data').body)}

# OTP testing — digit-by-digit for split fields
- tapOn:
    id: "otp-digit-1"
- inputText: "1"
- tapOn:
    id: "otp-digit-2"
- inputText: "2"
```

**Maestro Skill Key Learnings** (patterns LLMs get wrong):
- `clearState` does NOT clear iOS Keychain — expo-secure-store tokens persist across resets
- Auth pre-flight: use zero-size marker elements + `extendedWaitUntil` to avoid race conditions
- Optimistic update verification: short timeouts (3s) to catch UI regressions
- GraalJS: no async/await, no fetch(), use `http.get()` and `json()` instead

### iOS Native — XCTest/XCUITest (from conorluddy/ios-simulator-skill)

```swift
// XCUITest pattern
let app = XCUIApplication()
app.launch()

// Semantic navigation via accessibility — NOT pixel coordinates
let loginButton = app.buttons["Login"]
XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
loginButton.tap()

// Accessibility-driven element finding
let emailField = app.textFields["Email Address"]
emailField.tap()
emailField.typeText("test@example.com")
```

**ios-simulator-skill scripts** (21 production-ready):
- `simctl_boot.py` — Boot simulator
- `app_launcher.py` — Launch app
- `navigator.py` — Semantic UI navigation (accessibility APIs)
- `accessibility_audit.py` — Run accessibility audit
- `screenshot.py` — Capture screenshots

### Android — Compose Testing (from dpconde/claude-android-skill + awesome-android-agent-skills)

```kotlin
// Compose test rule
@get:Rule
val composeTestRule = createComposeRule()

@Test
fun loginScreen_displaysCorrectly() {
    composeTestRule.setContent { LoginScreen() }
    composeTestRule.onNodeWithText("Email").assertIsDisplayed()
    composeTestRule.onNodeWithContentDescription("Login").performClick()
}

// No mocking libraries — interfaces + test doubles
class FakeUserRepository : UserRepository {
    override suspend fun getUser(id: String) = User("test", "test@email.com")
}
```

**Android testing philosophy**: interfaces + test doubles, no mocking libraries (Mockito/MockK). Testing-by-design.

### CLI Commands Reference

```bash
# Detox
npx detox build --configuration ios.sim.debug
npx detox test --configuration ios.sim.debug
npx detox test --configuration ios.sim.debug --reuse  # Skip rebuild

# Maestro
maestro test flow.yaml                    # Run single flow
maestro test flows/                       # Run all flows in directory
maestro studio                           # Interactive test builder
maestro record flow.yaml                 # Record with video

# Appium
appium driver install uiautomator2      # Android driver
appium driver install xcuitest          # iOS driver
appium --port 4723                      # Start server

# iOS Simulator
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl install booted app.app
xcrun xcodebuild test -scheme MyApp -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

---

## Capability 2: mobile_unit_test — Jest + RNTL Patterns

### Query Priority (from callstackincubator + RNTL docs)

```
1. getByRole('button', { name: 'Submit' })  — Best: accessibility-first
2. getByText('Welcome')                      — Good: user-visible text
3. getByPlaceholderText('Email')             — OK: form inputs
4. getByTestId('submit-btn')                 — Last resort: no semantic match
```

### Modern RNTL Patterns (2026 — Jest 30 + RNTL v13+)

```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';

// Use screen object (modern pattern, not destructuring)
test('login form submits correctly', async () => {
  const onSubmit = jest.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  // Query by role (accessibility-first)
  fireEvent.changeText(
    screen.getByRole('textbox', { name: 'Email' }),
    'test@example.com'
  );

  fireEvent.press(screen.getByRole('button', { name: 'Login' }));

  // Async assertion
  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' });
  });
});

// Error state testing (CRITICAL — often missed)
test('shows error on network failure', async () => {
  jest.spyOn(api, 'login').mockRejectedValueOnce(new Error('Network error'));
  render(<LoginForm />);

  fireEvent.press(screen.getByRole('button', { name: 'Login' }));

  await waitFor(() => {
    expect(screen.getByText('Network error')).toBeTruthy();
  });
});

// Snapshot testing — only for stable UI components
test('header renders correctly', () => {
  render(<Header title="Home" />);
  expect(screen.toJSON()).toMatchSnapshot();
});
```

### What to Unit Test vs E2E Test

| Unit Test (Jest + RNTL) | E2E Test (Detox/Maestro) |
|--------------------------|--------------------------|
| Pure business logic functions | Full user journeys (login, checkout) |
| Component rendering & interactions | Cross-screen navigation flows |
| Error states & edge cases | Deep linking |
| Hook behavior | Push notification handling |
| Redux/Zustand store logic | Device-specific features (camera, GPS) |
| API response transformation | Offline/online transitions |

### CLI Commands

```bash
# Jest
npx jest                              # Run all tests
npx jest --watch                      # Watch mode
npx jest --coverage                   # Coverage report
npx jest --testPathPattern=Login      # Run matching tests
npx jest -u                           # Update snapshots

# Coverage thresholds (jest.config.js)
coverageThreshold: {
  global: { branches: 80, functions: 80, lines: 80, statements: 80 }
}
```

**Anti-patterns**: Testing implementation details (state values, internal methods). Using `getByTestId` when `getByRole` works. Not testing error/loading states. Snapshot-testing dynamic content.

---

## Capability 3: device_compatibility — Multi-Device Testing

### Minimum Device Matrix

| Platform | Must-Test Devices | Rationale |
|----------|------------------|-----------|
| iOS | iPhone SE 3rd (4.7") | Smallest active iPhone |
| iOS | iPhone 15 (6.1") | Mainstream |
| iOS | iPhone 15 Pro Max (6.7") | Largest |
| iOS | iPad 10th gen (10.9") | Tablet breakpoint |
| Android | Pixel 7 (6.3") | Stock Android reference |
| Android | Samsung Galaxy S24 (6.2") | #1 Android OEM |
| Android | Samsung Galaxy A14 (6.6") | Low-end, high volume |
| Android | Pixel Tablet (10.95") | Android tablet |

### OS Version Coverage

- **iOS**: Current (iOS 18) + previous (iOS 17) = ~95% coverage
- **Android**: API 26+ (Android 8.0+) = ~95% coverage. Focus: API 31+ (Android 12+) for ~85% of active devices

### Cloud Testing Services

```bash
# Firebase Test Lab (Google)
gcloud firebase test android run \
  --type instrumentation \
  --app app.apk \
  --test test.apk \
  --device model=Pixel7,version=34 \
  --device model=samsung_s24,version=34

# BrowserStack App Automate
browserstack-cli app upload --path app.apk
browserstack-cli test run --config browserstack.yml

# Maestro Cloud
maestro cloud --app app.apk flows/
```

### Screen Size Testing Strategy

```javascript
// React Native responsive breakpoints to test
const BREAKPOINTS = {
  small: 320,   // iPhone SE
  medium: 375,  // iPhone 15
  large: 428,   // iPhone 15 Pro Max
  tablet: 768,  // iPad
};

// Use react-native-responsive-screen for percentage-based layouts
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from 'react-native-responsive-screen';
```

### Platform-Specific Test Guards

```javascript
// Detox — run platform-specific tests
describe(':ios: iOS-specific tests', () => {
  it('should handle haptic feedback', async () => {
    // iOS only
  });
});

describe(':android: Android-specific tests', () => {
  it('should handle back button', async () => {
    await device.pressBack();
  });
});
```

**Anti-patterns**: Only testing on one device/simulator. Ignoring low-end Android devices. Not testing landscape orientation. Assuming consistent font rendering across OEMs.

---

## Capability 4: mobile_performance — Performance Testing

### Key Metrics & Thresholds

| Metric | Target | Critical | Tool |
|--------|--------|----------|------|
| Cold launch time | <2s | >3s = P0 | Flashlight, Perf Monitor |
| Hot launch time | <1s | >1.5s = P0 | Flashlight |
| JS FPS | >55 FPS | <45 FPS = P0 | React DevTools Profiler |
| UI FPS | 60 FPS (steady) | <50 FPS = P0 | systrace / Instruments |
| Frame render time | <16ms | >32ms = P0 | Flipper, Instruments |
| Memory (idle) | <150MB | >300MB = P0 | Xcode Instruments / Android Profiler |
| Memory (active) | <250MB | >400MB = P0 | Xcode Instruments / Android Profiler |
| JS bundle size | <1.5MB | >3MB = P1 | metro-bundle-analyzer |
| App binary size (iOS) | <50MB | >100MB = P1 | Xcode archive |
| App binary size (Android) | <30MB (AAB) | >80MB = P1 | bundletool |
| TTI (Time to Interactive) | <3s | >5s = P0 | Lighthouse (web), manual (native) |
| API response (P95) | <500ms | >2s = P0 | Network profiler |
| Crash rate | <0.5% | >1% = P0 | Sentry, Crashlytics |
| ANR rate (Android) | <0.1% | >0.5% = P0 | Play Console |

### Performance Profiling Commands

```bash
# React Native — JS bundle analysis (from callstackincubator)
npx react-native-bundle-visualizer      # Bundle size treemap
npx metro-bundle-analyzer main.jsbundle  # Detailed analysis

# React Native — Hermes profiling
adb shell setprop debug.hermes.sampling_profiler 1
# Then open chrome://tracing with .cpuprofile

# iOS — Instruments
xcrun xctrace record --template "Time Profiler" --launch -- com.example.app
xcrun xctrace record --template "Allocations" --launch -- com.example.app
xcrun xctrace record --template "Core Animation" --launch -- com.example.app

# Android — systrace
python systrace.py -t 5 -o trace.html sched gfx view wm am

# Android — Profiler (memory)
adb shell dumpsys meminfo com.example.app

# Flipper (cross-platform)
# Install via: brew install flipper
# Provides: Layout Inspector, Network, Databases, Shared Preferences, React DevTools
```

### Performance Budget Enforcement (from senaiverse agent system)

```javascript
// CI performance gates — fail build on regression
// package.json script
"perf:check": "node scripts/check-bundle-size.js --max-size 1500000",
"perf:startup": "maestro test flows/perf-cold-start.yaml --timeout 3000"

// Bundle size check script
const stats = fs.statSync('main.jsbundle');
if (stats.size > MAX_BUNDLE_SIZE) {
  console.error(`Bundle size ${stats.size} exceeds limit ${MAX_BUNDLE_SIZE}`);
  process.exit(1);
}
```

### FlatList Performance Checklist (from callstackincubator)

```javascript
<FlatList
  data={items}
  renderItem={MemoizedItem}          // React.memo() wrapper
  keyExtractor={(item) => item.id}   // Stable keys
  getItemLayout={(data, index) => (  // HIGHEST IMPACT — skip measurement
    { length: ITEM_HEIGHT, offset: ITEM_HEIGHT * index, index }
  )}
  windowSize={5}                     // Reduce from default 21
  maxToRenderPerBatch={10}           // Batch render
  removeClippedSubviews={true}       // Android memory optimization
  initialNumToRender={10}            // First render batch
/>
```

**Anti-patterns**: No performance baseline. Testing only on high-end devices. Ignoring Android ANR rate. Not measuring cold start on real devices (simulators are faster).

---

## Capability 5: mobile_accessibility — VoiceOver/TalkBack Testing

### WCAG 2.2 Level AA Checklist for Mobile

| Requirement | iOS | Android | Auto-testable? |
|-------------|-----|---------|----------------|
| Touch target >= 44x44 dp | `accessibilityFrame` | `minWidth/minHeight: 48dp` | Yes |
| Color contrast >= 4.5:1 (text) | Accessibility Inspector | Accessibility Scanner | Yes |
| Screen reader labels | `accessibilityLabel` | `contentDescription` | Yes (missing check) |
| Focus order logical | VoiceOver swipe test | TalkBack swipe test | Partial |
| Dynamic type support | UIFontMetrics | `sp` units for text | No — manual |
| Motion reduction | `UIAccessibility.isReduceMotionEnabled` | `Settings.Global.ANIMATOR_DURATION_SCALE` | No — manual |
| Error identification | Announce via `accessibilityLiveRegion` | `AccessibilityEvent.TYPE_ANNOUNCEMENT` | No — manual |

### React Native Accessibility Props

```jsx
// Required accessible props
<TouchableOpacity
  accessible={true}
  accessibilityLabel="Add item to cart"       // What VoiceOver/TalkBack reads
  accessibilityHint="Double tap to add"       // Additional context
  accessibilityRole="button"                  // Semantic role
  accessibilityState={{ disabled: false }}     // State info
  style={{ minWidth: 44, minHeight: 44 }}     // Touch target
>
  <Icon name="cart-plus" />
</TouchableOpacity>

// Live regions for dynamic content
<Text
  accessibilityLiveRegion="polite"   // "polite" or "assertive"
  accessibilityRole="alert"
>
  {errorMessage}
</Text>

// Group related elements
<View accessibilityRole="header" accessible={true}>
  <Text>Section Title</Text>
</View>
```

### Automated Accessibility Testing

```bash
# iOS — Accessibility Inspector (Xcode)
# Xcode > Open Developer Tool > Accessibility Inspector
# Audit tab > Run Audit (finds missing labels, contrast issues)

# iOS — axe DevTools
# npm install @axe-core/react-native

# Android — Accessibility Scanner
# Settings > Accessibility > Accessibility Scanner > ON
# Blue FAB appears > tap to scan current screen

# Android — Espresso accessibility checks
AccessibilityChecks.enable()  // Add to test setup

# React Native — jest-axe (unit level)
npm install --save-dev jest-axe
```

```javascript
// jest-axe for component-level a11y testing
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

test('LoginForm has no accessibility violations', async () => {
  const { container } = render(<LoginForm />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Manual VoiceOver/TalkBack Testing Protocol

1. **Enable screen reader**: iOS Settings > Accessibility > VoiceOver ON / Android Settings > Accessibility > TalkBack ON
2. **Navigate entire screen**: Swipe right through every element — verify order is logical
3. **Check every interactive element**: Must have label + role + state
4. **Test with display off**: Can you complete the core flow without seeing the screen?
5. **Test Dynamic Type**: iOS Settings > Display > Text Size > Maximum. Verify no text truncation
6. **Test color blindness**: iOS Settings > Accessibility > Color Filters > Protanopia/Deuteranopia

**Key insight**: Automated tools catch 30-40% of accessibility issues. Manual screen reader testing is mandatory for the remaining 60-70%.

**Anti-patterns**: Only testing with sighted mode. Missing `accessibilityLabel` on icon-only buttons. Touch targets <44dp. Not testing with actual screen reader (just checking props exist).

---

## Capability 6: mobile_pair_testing — Human-AI 4D Protocol for Mobile

### Mobile-Specific 4D Adaptations

The standard 4D Protocol (Discover > Discuss > Decide > Document) applies to mobile with these additions:

#### Discovery Phase — Mobile-Specific Checks

```
Round types for mobile pair testing:
1. Visual Regression — Screenshot comparison across devices/themes
2. Gesture Testing — Swipe, pinch, long-press, 3D Touch, back gesture
3. State Transitions — Background/foreground, low memory, interrupted
4. Network Conditions — Offline, slow 3G, WiFi-to-cellular handoff
5. Accessibility — VoiceOver/TalkBack walkthrough of core flows
6. Performance — Scroll FPS, launch time, memory under load
7. Platform Parity — Same flow on iOS vs Android side-by-side
```

#### Mobile Pair Testing Session Template

```markdown
## Session: [Feature] Mobile Pair Test
**Device Matrix**: iPhone 15 (iOS 18), Pixel 7 (Android 14), iPhone SE (small screen)
**Themes**: Light + Dark mode

### Round 1: Happy Path (Device: iPhone 15)
- [ ] Core flow completes
- [ ] All animations smooth (>55 FPS)
- [ ] Dark mode renders correctly

### Round 2: Edge Cases (Device: Pixel 7)
- [ ] Offline behavior
- [ ] Back button handling
- [ ] App backgrounded mid-flow

### Round 3: Accessibility (Device: iPhone 15 + VoiceOver)
- [ ] All elements announced
- [ ] Focus order logical
- [ ] Actions discoverable

### Round 4: Small Screen (Device: iPhone SE)
- [ ] No text truncation
- [ ] Touch targets adequate
- [ ] Scroll behavior correct
```

#### AI Agent Role in Mobile Pair Testing

The AI agent can:
- Analyze screenshots for visual regressions
- Check accessibility props in code while human tests with screen reader
- Verify performance metrics against thresholds
- Cross-reference platform-specific behavior differences
- Generate device-specific test commands

The AI agent CANNOT:
- Test actual gesture feel (human judgment required)
- Assess animation smoothness subjectively
- Verify haptic feedback quality
- Judge "does this feel right" on a real device

---

## Capability 7: mobile_test_strategy — Test Pyramid for Mobile

### Recommended Ratio

```
        /  E2E  \        5-10%  |  Detox/Maestro: 10-20 critical flows
       / Integr. \       15-20% |  Jest + RNTL: screen-level, API mocking
      /   Unit    \       70-80% |  Jest: pure functions, hooks, stores
```

### What Goes Where

| Layer | What to Test | Framework | Speed | Cost |
|-------|-------------|-----------|-------|------|
| Unit (70-80%) | Business logic, utilities, transformations, hooks, store reducers | Jest | <1ms/test | Low |
| Integration (15-20%) | Screen rendering, navigation transitions, API integration (mocked), component composition | Jest + RNTL | 10-100ms/test | Medium |
| E2E (5-10%) | Login flow, checkout flow, onboarding, deep links, push notifications | Detox/Maestro | 10-60s/flow | High |

### CI Pipeline Structure

```yaml
# GitHub Actions mobile test pipeline
name: Mobile Tests
on: [pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - run: npx jest --ci --coverage
      - name: Coverage gate
        run: |
          COVERAGE=$(npx jest --ci --coverageReporters=text-summary | grep Lines | awk '{print $3}')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then exit 1; fi

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - run: npx jest --ci --testPathPattern="__integration__"

  e2e-ios:
    runs-on: macos-latest
    steps:
      - run: npx detox build --configuration ios.sim.release
      - run: npx detox test --configuration ios.sim.release --cleanup

  e2e-android:
    runs-on: ubuntu-latest
    steps:
      - run: npx detox build --configuration android.emu.release
      - run: npx detox test --configuration android.emu.release --cleanup

  # OR Maestro alternative
  e2e-maestro:
    runs-on: macos-latest
    steps:
      - run: maestro test flows/ --format junit --output results.xml
```

### When to Choose Which Framework

```
Decision tree:
1. React Native only? → Detox (gray-box, lowest flakiness)
2. Cross-platform (RN + native + web)? → Maestro (YAML, fastest adoption)
3. Enterprise, multi-technology? → Appium (WebDriver ecosystem)
4. Need AI-driven exploratory testing? → Arbigent (AI agent for Android/iOS/Web)
5. iOS-only Swift/SwiftUI? → XCUITest (native, best Xcode integration)
6. Android-only Compose? → Compose Test + Espresso (native)
```

### Test Quality Signals

| Signal | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Unit test coverage | >80% | 60-80% | <60% |
| E2E flakiness rate | <2% | 2-5% | >5% |
| CI test time (total) | <15 min | 15-30 min | >30 min |
| Test-to-code ratio | 1:1 to 2:1 | 0.5:1 | <0.5:1 |
| Crash-free rate | >99.5% | 99-99.5% | <99% |
| Mean time to detect | <1 day | 1-3 days | >3 days |

---

## Cross-Cutting Best Practices (from all repos)

### 1. testID Strategy
- Use consistent naming: `screen-name.element-type.identifier` (e.g., `login.input.email`)
- Add testIDs during development, not as afterthought
- Never use testIDs as sole accessibility mechanism — they are invisible to screen readers

### 2. Test Data Management
- Use factories (faker.js) for dynamic test data, not hardcoded values
- Maestro has built-in faker support: `${faker.name().firstName()}`
- Isolate test state: each test should set up and tear down its own data

### 3. CI/CD Integration
- Unit tests: every PR (blocking)
- Integration tests: every PR (blocking)
- E2E tests: every PR to main (blocking), or nightly for full suite
- Performance regression: weekly on real devices (Firebase Test Lab / BrowserStack)
- Accessibility audit: every PR (automated) + monthly manual (VoiceOver/TalkBack)

### 4. Flakiness Management
- Quarantine flaky tests immediately (don't let them block pipeline)
- Track flakiness rate per test — auto-disable at >3 failures in 10 runs
- Root cause: 80% of flakiness is timing issues — use `waitFor` patterns, not `sleep`

---

## Sources

- [Maestro Mobile Testing Skill Discussion](https://github.com/mobile-dev-inc/Maestro/discussions/2985)
- [Callstack agent-skills (RN Best Practices)](https://github.com/callstackincubator/agent-skills)
- [senaiverse RN Expo Agent System](https://github.com/senaiverse/claude-code-reactnative-expo-agent-system)
- [conorluddy iOS Simulator Skill](https://github.com/conorluddy/ios-simulator-skill)
- [dpconde claude-android-skill](https://github.com/dpconde/claude-android-skill)
- [new-silvermoon awesome-android-agent-skills](https://github.com/new-silvermoon/awesome-android-agent-skills)
- [Detox vs Maestro vs Appium Comparison (PkgPulse)](https://www.pkgpulse.com/blog/detox-vs-maestro-vs-appium-react-native-e2e-testing-2026)
- [QA Wolf Mobile Testing Frameworks 2026](https://www.qawolf.com/blog/best-mobile-app-testing-frameworks-2026)
- [BrowserStack Mobile Performance Testing](https://www.browserstack.com/guide/mobile-app-performance-testing-checklist)
- [Bitrise Mobile Testing Pyramid](https://bitrise.io/blog/post/mastering-the-mobile-testing-pyramid)
- [React Native Testing Guide 2026](https://reactnativerelay.com/article/complete-guide-testing-react-native-apps-2026-unit-tests-e2e-maestro)
- [RNTL GitHub (Callstack)](https://github.com/callstack/react-native-testing-library)
- [BrowserStack Accessibility Testing](https://www.browserstack.com/guide/accessibility-testing-for-mobile-apps)
- [Corpowid Mobile Accessibility Guide 2026](https://corpowid.ai/blog/mobile-application-accessibility-practical-humancentered-guide-android-ios)
- [Anthropic Skills Repo](https://github.com/anthropics/skills)
