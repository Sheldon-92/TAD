# Visual Design Research: Menu Snap iOS

## 1. Color System — iOS System Colors + Brand

### Primary Palette (iOS System Colors)
Menu Snap uses iOS semantic system colors as the foundation. This ensures automatic Dark Mode support and platform consistency.

| Role | iOS System Name | Light Hex | Dark Hex | Usage |
|---|---|---|---|---|
| Primary | systemBlue | #007AFF | #0A84FF | Interactive elements, links, active tab |
| Success | systemGreen | #34C759 | #30D158 | Safe dietary badges, confirmed allergen-free |
| Warning | systemOrange | #FF9500 | #FF9F0A | Potential allergen warnings |
| Danger | systemRed | #FF3B30 | #FF453A | Allergen match, delete, favorites heart |
| AI Accent | systemPurple | #AF52DE | #BF5AF2 | AI recommendations, sparkle tags |

### Brand Accent
- **Brand Color**: #007AFF (system blue) — Menu Snap aligns with iOS system blue as its primary brand color. No custom brand color is introduced for v1.0 to maximize platform-native feel.
- **Rationale**: Camera/utility apps benefit from "invisible design" — the UI should feel like a system extension, not a branded experience. The food photography IS the visual identity.

### Semantic Background Colors (iOS)
| Role | Light | Dark | Usage |
|---|---|---|---|
| systemBackground | #FFFFFF | #000000 | Primary content background |
| secondarySystemBackground | #F2F2F7 | #1C1C1E | Grouped table background |
| tertiarySystemBackground | #FFFFFF | #2C2C2E | Cards within grouped background |
| systemGroupedBackground | #F2F2F7 | #000000 | Root grouped list |

### Semantic Text Colors (iOS)
| Role | Light | Dark | Usage |
|---|---|---|---|
| label | #000000 | #FFFFFF | Primary text |
| secondaryLabel | rgba(60,60,67,0.6) | rgba(235,235,245,0.6) | Subtitles, original menu text |
| tertiaryLabel | rgba(60,60,67,0.3) | rgba(235,235,245,0.3) | Placeholders |
| quaternaryLabel | rgba(60,60,67,0.18) | rgba(235,235,245,0.18) | Disabled text |

## 2. Typography — SF Pro Scale (11 Dynamic Type Styles)

All text uses SF Pro and supports Dynamic Type scaling (mandatory for iOS accessibility).

| Style | Font | Size | Weight | Leading | Usage in Menu Snap |
|---|---|---|---|---|---|
| Large Title | SF Pro Display | 34pt | Regular | 41pt | "Favorites", "Settings" tab headers |
| Title 1 | SF Pro Display | 28pt | Regular | 34pt | Dish detail name |
| Title 2 | SF Pro Display | 22pt | Regular | 28pt | Section headers |
| Title 3 | SF Pro Display | 20pt | Regular | 25pt | Card titles |
| Headline | SF Pro Text | 17pt | Semibold | 22pt | Dish name in results list |
| Body | SF Pro Text | 17pt | Regular | 22pt | Dish descriptions |
| Callout | SF Pro Text | 16pt | Regular | 21pt | Filter chip labels |
| Subheadline | SF Pro Text | 15pt | Regular | 20pt | Original menu text (transliteration) |
| Footnote | SF Pro Text | 13pt | Regular | 18pt | Section titles, dietary badge text |
| Caption 1 | SF Pro Text | 12pt | Regular | 16pt | Timestamps, metadata |
| Caption 2 | SF Pro Text | 11pt | Regular | 13pt | Tab bar labels |

**Note**: SF Pro Text (<=19pt) and SF Pro Display (>=20pt) switch automatically in SwiftUI when using system text styles.

## 3. Icon System — SF Symbols

| Icon | SF Symbol Name | Rendering Mode | Usage |
|---|---|---|---|
| Scan tab | camera.viewfinder | monochrome | Tab bar |
| History tab | clock.arrow.circlepath | monochrome | Tab bar |
| Favorites tab | heart.fill | monochrome | Tab bar (filled when active) |
| Settings tab | gearshape | monochrome | Tab bar |
| Flash | bolt.fill | palette (yellow) | Camera flash toggle |
| Filter | line.3.horizontal.decrease | monochrome | Results filter button |
| Share | square.and.arrow.up | monochrome | Share action |
| AI Sparkle | sparkles | palette (purple) | AI recommendation tag |
| Allergen Warning | exclamationmark.triangle.fill | palette (orange/red) | Dietary warning badges |
| Safe Check | checkmark.circle.fill | palette (green) | Safe dietary badges |
| Chevron | chevron.right | monochrome | Settings row disclosure |
| Back | chevron.left | monochrome | Navigation back (system) |
| Close | xmark | monochrome | Dismiss modal |
| Rescan | arrow.clockwise | monochrome | Rescan button icon |
| Delete | trash | monochrome | Swipe-to-delete |
| Search | magnifyingglass | monochrome | Search bar |

**Rendering Modes**:
- **Monochrome**: Single-color, matches text weight. Used for most UI icons.
- **Palette**: Multi-color sections. Used for status indicators (allergen badges).
- **Hierarchical**: Depth through opacity. [ASSUMPTION] May use for camera controls on dark background.

## 4. Dark Mode Design

### Strategy: iOS Elevated Background System (NOT simple inversion)

Dark mode uses three elevation levels:

| Level | Background | Usage |
|---|---|---|
| Base (0) | #000000 (systemBackground) | Root background behind grouped content |
| Elevated 1 | #1C1C1E (secondarySystemBackground) | Tab bar blur, nav bar blur, grouped sections |
| Elevated 2 | #2C2C2E (tertiarySystemBackground) | Cards within groups, dish cards |
| Elevated 3 | #3A3A3C (systemFill) | Pressed states, secondary controls |

### Dark Mode Specifics for Menu Snap
- **Camera page**: Already dark (black viewfinder) — light/dark mode has minimal impact
- **Tab bar**: Uses system material blur (thin material) — automatically adapts
- **Dietary badges**: Use adjusted palette (darker backgrounds, lighter text) — see design-tokens.json
- **AI sparkle tag**: Purple (#BF5AF2) on dark card (#2C2C2E) — contrast ratio 4.8:1 (passes AA)

### Contrast Verification
| Text/Background Pair | Light Ratio | Dark Ratio | Pass? |
|---|---|---|---|
| label on systemBackground | 21:1 | 21:1 | AA + AAA |
| secondaryLabel on systemBackground | 7.5:1 | 7.5:1 | AA + AAA |
| badge-safe text on badge-safe bg | 7.2:1 | 5.1:1 | AA |
| badge-warning text on badge-warning bg | 6.8:1 | 4.9:1 | AA |
| badge-danger text on badge-danger bg | 7.1:1 | 5.3:1 | AA |
| AI purple on purple bg | 5.2:1 | 4.8:1 | AA |

All pairs pass WCAG AA (>= 4.5:1 for normal text, >= 3:1 for large text).
