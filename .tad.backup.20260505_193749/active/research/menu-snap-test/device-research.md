# Device Compatibility Research — Menu Snap iOS

## iOS Version Distribution (March 2026, Real Data)

Source: [TelemetryDeck](https://telemetrydeck.com/survey/apple/iOS/majorSystemVersions/), [StatCounter](https://gs.statcounter.com/ios-version-market-share/)

| iOS Version | Market Share | Support Decision |
|-------------|-------------|------------------|
| iOS 26.x | ~79% | **Primary target** |
| iOS 26.3 | 61.45% | Most common minor version |
| iOS 26.4 | 10.10% | Newest release |
| iOS 26.2 | 11.36% | Still significant |
| iOS 18.x | ~16% | **Must support** (18.6 at 7.71%) |
| iOS 17.x | ~4% | **Consider dropping** |
| iOS 16.x and below | <1% | Not supported |

**Decision: Minimum deployment target = iOS 18.0**
- Covers ~95% of active devices (iOS 26 + iOS 18)
- Drops iOS 17 and below (~5%) — acceptable tradeoff for modern API access

## iPhone Model Distribution (March 2026, Real Data)

Source: [TelemetryDeck](https://telemetrydeck.com/survey/apple/iPhone/models/)

| Model | Market Share | Screen Size |
|-------|-------------|-------------|
| iPhone 15 | 11.60% | 6.1" |
| iPhone 16 Pro | 11.58% | 6.3" |
| iPhone 14 | ~9-10% | 6.1" |
| iPhone 15 Pro | ~9-10% | 6.1" |
| iPhone 16 | ~9-10% | 6.1" |
| iPhone 16 Pro Max | ~9-10% | 6.9" |
| iPhone 17 Pro | 8.32% | 6.3" [ASSUMPTION] |
| iPhone 17 Pro Max | 8.11% | 6.9" [ASSUMPTION] |

## Test Matrix (4 devices minimum)

| Device | Screen | OS Versions | Why This Device |
|--------|--------|-------------|-----------------|
| **iPhone SE 3** | 4.7" (750x1334) | iOS 18.6 | Smallest actively sold iPhone. Tests layout compression, touch target sizing. Camera scan UI must not overflow. |
| **iPhone 15** | 6.1" (1179x2556) | iOS 26.3 | Highest market share single model (11.6%). Baseline device for all testing. |
| **iPhone 16 Pro Max** | 6.9" (1320x2868) | iOS 26.4 | Largest screen. Tests layout stretching, Dynamic Island interaction, ProMotion 120Hz scroll. |
| **iPad mini (6th gen)** | 8.3" (1488x2266) | iOS 26.3 | Tablet layout — tests multitasking, split view, different aspect ratio. Camera usage on iPad. |

## Per-Device Test Checklist

### All devices:
- [ ] App launches without crash
- [ ] Camera overlay fits within safe area
- [ ] Capture button is reachable with thumb
- [ ] Menu card text is readable (no truncation on small screens)
- [ ] Dietary filter sheet doesn't overflow
- [ ] Keyboard doesn't cover input fields
- [ ] Rotation handling (if supported)

### iPhone SE 3 specific:
- [ ] Touch targets >= 44pt (smaller screen = higher risk of cramped UI)
- [ ] Bottom tab bar doesn't crowd content
- [ ] Camera guide frame fits in viewport
- [ ] No horizontal scroll on results list

### iPhone 16 Pro Max specific:
- [ ] Content doesn't float in center (uses full width)
- [ ] Dynamic Island doesn't overlap camera UI
- [ ] 120Hz ProMotion animations are smooth
- [ ] Large screen doesn't expose excessive whitespace

### iPad mini specific:
- [ ] Landscape orientation works (or gracefully locks to portrait)
- [ ] Split View / Slide Over doesn't crash
- [ ] Camera viewfinder scales appropriately
- [ ] Touch targets still appropriate for larger screen
