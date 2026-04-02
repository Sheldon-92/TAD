# Component Research: Menu Snap iOS

## Native vs Custom Component Decision Matrix

### Native Components (Use iOS Standard)

| # | Component | iOS Implementation | Usage in Menu Snap | Size/Spec |
|---|---|---|---|---|
| 1 | **Navigation Bar** | UINavigationBar / NavigationStack | All pages with back/title/action | H: 44pt, title 17pt semibold |
| 2 | **Tab Bar** | UITabBar / TabView | Bottom navigation (4 tabs) | H: 49pt + 34pt Home Indicator = 83pt |
| 3 | **List/Table** | UITableView / List | History, Favorites, Settings | Row min-H: 44pt |
| 4 | **Button (Standard)** | UIButton / Button | "Rescan", "Save", "Share" | Min touch: 44x44pt |
| 5 | **Text Field** | UITextField / TextField | Search (History/Favorites) | H: 44pt, 16pt text, 8pt padding |
| 6 | **Bottom Sheet** | UISheetPresentationController | Dietary preferences modal | Detents: .medium (50%), .large (100%) |
| 7 | **Alert Dialog** | UIAlertController | Delete confirmation, error alerts | System standard |
| 8 | **Context Menu** | UIContextMenuConfiguration | Long-press on dish card | System standard with haptic |
| 9 | **Segmented Control** | UISegmentedControl | [ASSUMPTION] Filter mode (if needed) | H: 32pt, 13pt text |
| 10 | **Toggle/Switch** | UISwitch | Settings toggles | W: 51pt, H: 31pt (system size) |
| 11 | **Pull-to-Refresh** | UIRefreshControl | Results list, History list | System spinner |
| 12 | **Activity Indicator** | UIActivityIndicatorView | Processing scan | System spinner |

### Custom Components (Native doesn't satisfy need)

| # | Component | Why Not Native | Design Spec |
|---|---|---|---|
| 13 | **Camera Overlay** | No standard camera overlay component; needs custom viewfinder frame + controls | See detailed spec below |
| 14 | **Dietary Badge** | No native badge with color-coded severity (safe/warning/danger) | See detailed spec below |
| 15 | **Dish Card** | No native card matching translation + dietary + AI layout | See detailed spec below |
| 16 | **Filter Chip Bar** | iOS has no native chip/tag component (unlike Material Chip) | See detailed spec below |
| 17 | **AI Recommendation Tag** | Unique visual treatment for AI-generated content | See detailed spec below |

## Detailed Custom Component Specs

### 13. Camera Overlay Component

```
┌─────────────────────────────────────┐
│  [Flash ⚡]              [Tip 💡]   │  ← Top controls (44pt height)
│                                      │
│     ┌─┐                    ┌─┐      │
│     │ │                    │ │      │  ← Scan frame corners
│     └─┘                    └─┘      │     (24pt, 3pt blue border)
│                                      │
│         Point camera at menu         │  ← Hint text (15pt, secondaryLabel)
│                                      │
│     ┌─┐                    ┌─┐      │
│     │ │                    │ │      │
│     └─┘                    └─┘      │
│                                      │
│   [🔄]      [◯ Capture]    [📸]    │  ← Bottom controls
└─────────────────────────────────────┘
```

| Property | Value |
|---|---|
| Background | Transparent (over AVFoundation preview) |
| Scan Frame | 300x380pt, blue (#007AFF) corner markers, 3pt border, 8pt radius |
| Capture Button | 72pt outer ring (4pt white border), 60pt inner circle (solid white) |
| Side Buttons | 44pt diameter, rgba(255,255,255,0.15) background |
| Hint Text | 15pt SF Pro Text Regular, rgba(174,174,178,1.0) |
| States | Idle, Focusing (yellow square), Processing (spinner overlay), Error (red banner) |
| Accessibility | Capture button label: "Take Photo", VoiceOver: all controls labeled |

### 14. Dietary Badge Component

```
┌──────────────┐
│ ✓ Gluten Free │  ← Safe (green)
└──────────────┘
┌───────────────────┐
│ ⚠ Contains Peanuts │  ← Warning (yellow)
└───────────────────┘
┌───────────────────┐
│ ⚠ ALLERGEN MATCH  │  ← Danger (red)
└───────────────────┘
```

| Property | Value |
|---|---|
| Height | Auto (min 24pt, padded to touch target if interactive) |
| Padding | 4pt vertical, 10pt horizontal |
| Border Radius | 8pt |
| Font | SF Pro Text, 12pt, weight 500 (Medium) |
| Icon | SF Symbol: checkmark.circle.fill (safe), exclamationmark.triangle.fill (warning/danger) |
| Variants | safe (green), warning (amber), danger (red), info (blue) |
| Light Mode | See design-tokens.json dietary_badge_colors |
| Dark Mode | Darker background, lighter text (maintains >= 4.5:1 contrast) |
| States | Default only (non-interactive badge). If tappable: pressed state with 0.7 opacity |
| Accessibility | VoiceOver reads icon + text: "Safe: Gluten Free" or "Warning: Contains Peanuts" |

### 15. Dish Card Component

```
┌─────────────────────────────────────┐
│ Pad Thai                      $14   │  ← Name (Headline 17pt) + Price
│ ผัดไทย                              │  ← Original (Subheadline 15pt, secondaryLabel)
│                                      │
│ Stir-fried rice noodles with...     │  ← Description (Body 17pt, 2 lines max)
│                                      │
│ [✓ Gluten Free] [⚠ Peanuts]        │  ← Dietary badges
│                                      │
│ ✨ AI Pick — Great for first-timers │  ← AI tag (optional)
└─────────────────────────────────────┘
```

| Property | Value |
|---|---|
| Width | Full width minus 32pt (16pt margins each side) |
| Padding | 16pt all sides |
| Background | systemBackground (white light / elevated dark) |
| Border Radius | 13pt (iOS medium) |
| Shadow | None (iOS grouped style uses background contrast instead) |
| Description | 2 lines max, truncated with "..." |
| States | Default, Pressed (0.95 scale, 100ms), Context Menu active |
| Accessibility | Card is one VoiceOver element: "{name}, {price}, {description}, {badges}" |

### 16. Filter Chip Bar Component

```
┌──────────────────────────────────────────────┐
│ [All (12)] [✓ Safe for me] [⭐ AI Picks] ... │
└──────────────────────────────────────────────┘
```

| Property | Value |
|---|---|
| Scroll Direction | Horizontal, clips to content width |
| Chip Height | 36pt visible, 44pt touch target (4pt padding top/bottom) |
| Chip Padding | 8pt vertical, 16pt horizontal |
| Border Radius | 20pt (pill shape) |
| Active State | Background: systemBlue, Text: white |
| Default State | Background: systemFill (tertiarySystemFill), Text: label |
| Font | SF Pro Text, 14pt, Regular |
| Gap | 8pt between chips |
| Content Inset | 16pt left/right (matches content margin) |
| Accessibility | Each chip is a toggle button, VoiceOver: "Filter: All, selected" |

### 17. AI Recommendation Tag Component

```
┌────────────────────────────────────────┐
│ ✨ AI Pick — Great choice for...       │
└────────────────────────────────────────┘
```

| Property | Value |
|---|---|
| Padding | 6pt vertical, 10pt horizontal |
| Background | Light: #F5F3FF (very light purple), Dark: #2E1065 |
| Border Radius | 8pt |
| Font | SF Pro Text, 13pt, Regular |
| Text Color | Light: #5B21B6, Dark: #C4B5FD |
| Icon | sparkles SF Symbol, same color as text |
| Accessibility | VoiceOver: "AI Recommendation: {text}" |

## Atomic Design Hierarchy

### Atoms
- Button, Icon (SF Symbol), Label, Badge (Dietary), Toggle, Divider

### Molecules
- **Dish Card Header**: Name + Original Name + Price
- **Dietary Badge Row**: Array of Badge atoms
- **AI Tag**: Icon + Label
- **Settings Row**: Icon + Label + Value/Chevron/Toggle
- **Filter Chip**: Icon (optional) + Label
- **Search Bar**: TextField + Icon

### Organisms
- **Navigation Bar**: Back button + Title + Action button
- **Tab Bar**: 4 Tab Items (Icon + Label)
- **Dish Card**: Header + Description + Badge Row + AI Tag
- **Camera Overlay**: Flash toggle + Scan Frame + Capture Button + Hint
- **Filter Chip Bar**: Horizontal scroll of Filter Chips
- **Settings Group**: Group Title + Array of Settings Rows
- **Favorite Card**: Thumbnail + Info (name + restaurant + badge) + Heart icon
