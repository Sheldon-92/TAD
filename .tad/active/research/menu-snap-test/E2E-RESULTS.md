# Menu Snap iOS — Mobile Testing Domain Pack Results

> Generated: 2026-04-01
> Domain Pack: mobile-testing v1.0.0
> All 7 capabilities executed

---

## 1. mobile_e2e — E2E Tests (Detox)

**Framework: Detox** (grey-box, RN-native, <2% flake rate)

**5 core flow test files written:**

| Flow | File | Test Count |
|------|------|-----------|
| Camera Scan -> Results | `e2e/camera-scan-flow.test.ts` | 4 tests |
| Dish Detail View | `e2e/dish-detail-flow.test.ts` | 4 tests |
| Save to Favorites | `e2e/save-favorite-flow.test.ts` | 3 tests |
| Dietary Filter | `e2e/dietary-filter-flow.test.ts` | 5 tests |
| Error Recovery / Offline | `e2e/error-recovery-flow.test.ts` | 3 tests |
| **Total** | | **19 test cases** |

**Conventions enforced:**
- Zero `sleep()` calls — all waits use `waitFor().toBeVisible().withTimeout()`
- All element selection via `testID` (not text — critical for multilingual menu app)
- Each test is independent (no execution order dependency)
- Camera mocked with static menu images for deterministic results [ASSUMPTION]
- Screenshots on failure via Jest afterEach hook

**Design doc:** `e2e-design.md`

---

## 2. mobile_unit_test — Jest + RNTL

**5 component test files written:**

| Component | File | Test Count | Key Coverage |
|-----------|------|-----------|-------------|
| MenuCard | `unit-tests/MenuCard.test.tsx` | 8 tests | Rendering, navigation, a11y labels, truncation |
| DietaryBadge | `unit-tests/DietaryBadge.test.tsx` | 8 tests | All badge types, a11y, unknown type resilience |
| FavoriteButton | `unit-tests/FavoriteButton.test.tsx` | 6 tests | Toggle states, haptic, touch target, null safety |
| TranslationText | `unit-tests/TranslationText.test.tsx` | 7 tests | Loading, error, fallback, CJK, comparison mode |
| CameraOverlay | `unit-tests/CameraOverlay.test.tsx` | 9 tests | Capture, flash, disabled state, guide frame, VoiceOver |
| **Total** | | **38 test cases** |

**Query priority followed:** `getByRole > getByLabelText > getByText > getByTestId`
**No `getByType` usage** (tests behavior, not implementation)

**Design doc:** `unit-test-design.md`

---

## 3. device_compatibility — Test Matrix

**Real data sourced from TelemetryDeck + StatCounter (March 2026)**

### iOS Version Distribution
- iOS 26.x: ~79% (iOS 26.3 dominant at 61.45%)
- iOS 18.x: ~16% (18.6 at 7.71%)
- **Minimum deployment target: iOS 18.0** (covers ~95%)

### Device Matrix (4 devices)

| Device | Screen | OS | Rationale |
|--------|--------|----|-----------|
| iPhone SE 3 | 4.7" | iOS 18.6 | Smallest screen — layout compression test |
| iPhone 15 | 6.1" | iOS 26.3 | Highest market share (11.6%) — baseline |
| iPhone 16 Pro Max | 6.9" | iOS 26.4 | Largest screen — stretching + Dynamic Island |
| iPad mini 6th | 8.3" | iOS 26.3 | Tablet — multitasking, different aspect ratio |

Per-device checklists included with safe area, touch target, and orientation checks.

**Design doc:** `device-research.md`

---

## 4. mobile_performance — Thresholds & Bundle Analysis

### Performance Budgets

| Metric | Threshold | Measurement |
|--------|-----------|-------------|
| Cold start | < 2.0s | Xcode Instruments Time Profiler |
| JS Bundle | < 1.5 MB | source-map-explorer |
| FPS (scroll) | > 55 FPS | RN Perf Monitor / Flipper |
| FPS (p99) | > 45 FPS | Custom frame counter |
| Memory (active) | < 250 MB | Xcode Instruments Allocations |
| Memory (background) | < 50 MB | Post-background measurement |
| Camera -> result | < 5s | Detox timer |
| App binary | < 50 MB | App Store Connect |

### Test Scripts Written
- Cold start measurement (Detox-based)
- Memory leak detection (10 navigation cycles)
- FPS monitoring config (Flipper plugin)
- CI bundle size gate (GitHub Actions)

**Estimated bundle: ~900KB-1.2MB** [ASSUMPTION] — within 1.5MB budget.

**Design doc:** `performance-design.md`

---

## 5. mobile_accessibility — Static Lint + VoiceOver Checklist

### Automated Layer
- `eslint-plugin-react-native-a11y` config with 9 rules (all `error` or `warn`)
- RNTL queries in unit tests implicitly validate a11y props

### Manual VoiceOver Checklist (5 pages)

| Page | Elements Audited | Key Risk |
|------|-----------------|----------|
| Camera Screen | 5 elements | Overlay text contrast on live camera feed |
| Results Screen | 4+ elements | Dynamic menu card labels |
| Dish Detail | 7 elements | AI recommendation readability |
| Dietary Filter Sheet | 7 elements | Toggle state announcements |
| Favorites | 3+ elements | Empty state guidance |

### High-Risk Accessibility Area
**Camera overlay text** — text over live camera feed has unpredictable contrast. Recommendation: semi-transparent dark backdrop behind all overlay text elements.

### Dynamic Type Testing
Checklist covers Default, Large, Extra Large, and Maximum font sizes.

**Design doc:** `a11y-design.md`

---

## 6. mobile_pair_testing — 4D Protocol Session Plan

**5 planned rounds:**

| Round | Focus | Human Checks | AI Checks |
|-------|-------|-------------|-----------|
| 1 | Camera launch & capture | Haptic feel, capture responsiveness | Layout, safe area, button sizing |
| 2 | Results & scrolling | Scroll smoothness, translation pop-in | Text truncation, card alignment |
| 3 | Dietary filter UX | Discoverability, toggle clarity | Filter sheet layout, active badges |
| 4 | Network edge cases | Loading "aliveness", error clarity | Error screen layout, retry flow |
| 5 | Favorites & navigation | Save animation, tab discovery | Favorites layout, state changes |

**Session rules:**
- Human controls device and decides severity
- Every finding gets in-session decision (Fix Now / Fix Later / Won't Fix)
- Screenshots mandatory for every finding
- Fix Now items immediately become Blake handoffs

**Design doc:** `pair-test-plan.md`

---

## 7. mobile_test_strategy — Test Pyramid + CI Pipeline

### Adapted Pyramid: 60/25/15

| Layer | Standard | Menu Snap | Rationale |
|-------|----------|-----------|-----------|
| Unit | 70% | **60%** | Camera pipeline needs more integration coverage |
| Integration | 20% | **25%** | Multi-service pipeline (camera → OCR → translate) |
| E2E | 10% | **15%** | Camera UX is the core differentiator |

### CI Pipeline
```
Lint (30s) → Unit (2-3m) → Build + Bundle Check (5-8m) → E2E Simulator (10-15m) → TestFlight
```

### Device Strategy (3 Tiers)
1. **Simulator** (CI, every merge) — iPhone 15
2. **Cloud** (release) — BrowserStack with 4-device matrix
3. **Physical** (critical releases) — real camera + haptics testing

### Flake Policy
- < 2%: acceptable
- 2-5%: investigate within 1 sprint
- \> 5%: **P0 — must fix before release**

**Design doc:** `test-strategy.md`

---

## File Inventory

```
.tad/active/research/menu-snap-test/
├── E2E-RESULTS.md                          # This summary
├── e2e-design.md                           # E2E framework selection + conventions
├── e2e/
│   ├── camera-scan-flow.test.ts            # 4 tests
│   ├── dish-detail-flow.test.ts            # 4 tests
│   ├── save-favorite-flow.test.ts          # 3 tests
│   ├── dietary-filter-flow.test.ts         # 5 tests
│   └── error-recovery-flow.test.ts         # 3 tests
├── unit-test-design.md                     # Unit test strategy + coverage targets
├── unit-tests/
│   ├── MenuCard.test.tsx                   # 8 tests
│   ├── DietaryBadge.test.tsx               # 8 tests
│   ├── FavoriteButton.test.tsx             # 6 tests
│   ├── TranslationText.test.tsx            # 7 tests
│   └── CameraOverlay.test.tsx              # 9 tests
├── device-research.md                      # Real iOS distribution + 4-device matrix
├── performance-design.md                   # Thresholds + bundle analysis + CI gate
├── a11y-design.md                          # ESLint config + 5-page VoiceOver checklist
├── pair-test-plan.md                       # 5-round 4D Protocol session plan
└── test-strategy.md                        # Adapted pyramid + CI pipeline + device tiers
```

## Assumptions Made

| # | Assumption | Impact if Wrong |
|---|-----------|-----------------|
| 1 | App is React Native | Framework choice (Detox) would change |
| 2 | Camera mocked in simulator E2E | Need alternative if real camera E2E is required |
| 3 | Bundle ~900KB-1.2MB | Performance budget may need adjustment |
| 4 | Color scheme (dark text on white) | Contrast ratios need re-verification |
| 5 | iPhone 17 screen sizes | Minor — doesn't affect test matrix logic |

## Sources

- [TelemetryDeck — iOS Version Market Share 2026](https://telemetrydeck.com/survey/apple/iOS/majorSystemVersions/)
- [TelemetryDeck — iPhone Models Market Share 2026](https://telemetrydeck.com/survey/apple/iPhone/models/)
- [StatCounter — iOS Version Market Share](https://gs.statcounter.com/ios-version-market-share/)
