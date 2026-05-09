# Platform Design Decisions: Menu Snap iOS

## Decision 1: Target Platform — iOS-First

**Choice**: iOS-only for v1.0
**Rationale**:
- International travelers (primary users) skew iOS in high-spend demographics
- AVFoundation + Vision framework = best on-device OCR pipeline
- SwiftUI enables rapid iteration with native feel
- Higher ARPU on iOS App Store for utility/travel apps

## Decision 2: Adaptation Strategy — Fully Native

**Choice**: Fully native (platform-specific design per OS)
**Rationale**:
- Camera-heavy apps demand native API access (AVFoundation has no cross-platform equivalent)
- SwiftUI components feel native (vs Flutter/RN which approximate nativeness)
- Cost justified by single-platform initial scope

## Decision 3: Device Targets

| Device | Support | Notes |
|---|---|---|
| iPhone 15/16 (6.1") | Primary | 390x844 pt design target |
| iPhone 15/16 Pro Max (6.7") | Supported | Scaled layout |
| iPhone SE (4.7") | Minimum viable | Reduced layout, no Dynamic Island |
| iPad | Phase 2 | SwiftUI adaptive layout |

## Decision 4: iOS Version Support

**Choice**: iOS 17+ minimum
**Rationale**:
- VisionKit improvements in iOS 17 (DataScanner API)
- SwiftUI Observable macro (iOS 17+)
- [ASSUMPTION] ~90% of active iPhones run iOS 17+ by mid-2026

## Decision 5: Camera Implementation

| Aspect | Decision | Rationale |
|---|---|---|
| Capture Framework | AVFoundation + VisionKit | Full camera control + native OCR |
| Text Recognition | On-device Vision framework first, cloud fallback for complex scripts | Privacy-first, works offline |
| Menu Detection | Vision + Core ML custom model | Identify menu structure (columns, prices, dish names) |
| Real-time Preview | AVCaptureVideoPreviewLayer | Standard iOS camera preview |

## Decision 6: Platform-Specific Handling

| Scenario | iOS Approach |
|---|---|
| Navigation Back | System edge-swipe gesture (no custom override) |
| Delete/Remove Favorite | Swipe-to-delete (UIKit/SwiftUI standard) |
| Quick Actions | Context Menu (long-press, iOS 13+ standard) |
| Sharing | UIActivityViewController (system share sheet) |
| Notifications | UNUserNotificationCenter for scan completion |
| Haptic Feedback | UIImpactFeedbackGenerator for key interactions |
