# Platform Research: Menu Snap iOS

## 1. iOS HIG Constraints (iPhone 15/16 — 390x844pt logical)

| Constraint | Value | Source |
|---|---|---|
| Touch Target Minimum | 44x44 pt | Apple HIG - Buttons and Controls |
| Tab Bar Items | ≤ 5 | Apple HIG - Tab Bars |
| Navigation Bar Height | 44 pt | Apple HIG - Navigation Bars |
| Tab Bar Height | 49 pt (without Home Indicator) / 83 pt (with 34pt Home Indicator) | Apple HIG - Tab Bars |
| Status Bar Height (Notch) | 47 pt | Apple HIG - Bars |
| Status Bar Height (Dynamic Island) | 54 pt | Apple HIG - Layout |
| Home Indicator Safe Area | 34 pt bottom | Apple HIG - Layout |
| Grid System | 8 pt (4 pt for fine adjustments) | Apple HIG - Layout |
| SF Pro Text | ≤ 19 pt | Apple Typography |
| SF Pro Display | ≥ 20 pt | Apple Typography |
| Corner Radius | 10 pt (small) / 13 pt (medium) / 20 pt (large) | Apple HIG - Layout |
| Back Button | Top-left | Apple HIG - Navigation |
| Action Button | Top-right | Apple HIG - Navigation |
| Tab Bar | Bottom | Apple HIG - Tab Bars |
| Safe Area — Top (Dynamic Island) | 59 pt (54 + 5 gap) | Apple Developer Forums |
| Safe Area — Bottom | 34 pt | Apple HIG - Layout |

## 2. Camera UI Guidelines (AVFoundation Patterns)

| Guideline | Detail | Source |
|---|---|---|
| Viewfinder Priority | Camera viewfinder must dominate the screen; UI defers to content | Apple HIG - Camera |
| Capture Button | Centered bottom, ≥ 66 pt diameter, prominent | Apple Camera app pattern |
| Flash/Torch Toggle | Top-left or top-right of viewfinder | Apple Camera pattern |
| Camera Switch | Top corner, secondary to capture | Apple Camera pattern |
| Overlay Transparency | Controls overlay on semi-transparent background over viewfinder | Apple HIG - Deference |
| Permission Dialog | Camera permission requested on first use with clear purpose string | Apple Privacy Guidelines |
| AVFoundation | Primary framework for camera capture on iOS | Apple Developer Docs |
| Vision Framework | Used alongside AVFoundation for text recognition (OCR) | Apple Developer Docs |
| Live Text | iOS 15+ native OCR; can be leveraged for menu text extraction | Apple Developer Docs |

## 3. Competitive App Analysis

| App | Key UX Pattern | Strength | Weakness |
|---|---|---|---|
| Menu Explain (AI Food Guide) | Photo → AI analysis → dish descriptions + images | Rich dish descriptions, 50+ languages | [ASSUMPTION] May have slower processing |
| View Menu (AI Menu Reader) | Snap → instant translation → dish details | 50+ language support, clean UI | [ASSUMPTION] Translation-focused, less dietary info |
| MenuGuide (AI Menu Translator) | AI-powered contextual translation (not literal) | Understands food context and cultural nuances | [ASSUMPTION] Narrower feature set |
| Google Translate (Camera) | Real-time camera overlay translation | Fast, accurate, well-known | Not food-specific, no dietary info |

## 4. Cross-Platform Decision

### Decision: iOS-First

| Factor | Rationale |
|---|---|
| Target Demographic | International travelers — iPhone overrepresented in high-spend travel demographics |
| Camera API Quality | AVFoundation + Vision framework provides best-in-class OCR on-device |
| Design Consistency | Single platform = focused, polished experience |
| Revenue Potential | iOS App Store has higher ARPU for utility apps |
| Future Expansion | iPad support (shared codebase via SwiftUI), then Android |

### Platform Adaptation Strategy
- **Phase 1**: iOS-only (SwiftUI + AVFoundation + Vision)
- **Phase 2**: iPad adaptation (shared SwiftUI, adjusted layouts)
- **Phase 3**: Android (separate Material Design 3 implementation)
- **Strategy**: Platform-native design per platform (not cross-platform framework)
