# Wireframe Design: Menu Snap iOS

## Design Viewport
- **Target**: iPhone 15 — 390x844 pt logical resolution
- **Dynamic Island**: 59pt top safe area
- **Home Indicator**: 34pt bottom safe area
- **Content area**: 390 x (844 - 59 - 83) = 390 x 702 pt usable (with tab bar)

## Selected Approach: Camera-First (Score: 17/20)

## Page Designs (5 pages in wireframe.html)

### Page 1: Camera / Scan
- Full-screen dark viewfinder (AVFoundation preview layer)
- Blue scan frame corners guide menu alignment
- 72pt capture button bottom-center (exceeds 44pt minimum)
- Flash toggle top-right (44pt touch target)
- Scan hint text: "Point camera at menu to scan"
- Tab bar with translucent dark background
- Gesture annotations: tap-to-focus, pinch-to-zoom

### Page 2: Menu Results
- Navigation bar with "< Scan" back + "Filter" action
- Horizontal filter chips: All, Safe for me, AI Picks, dietary categories
- Dish cards with: translated name, original script, price, description
- Dietary badges: green (safe), yellow (warning), red (danger)
- AI recommendation tag (purple sparkle)
- Pull-to-rescan at top, "Rescan Menu" button at bottom
- Long-press gesture annotation on first card

### Page 3: Dish Detail
- Large dish image (260pt height) with overlay back/action buttons
- Dish name (Title 1 — 28pt), original name, price
- Dietary badges row
- Sections: Description, Key Ingredients (tag chips), AI Recommendation
- Action row: Save (red heart), Share (gray)
- Pinch-to-zoom annotation on image

### Page 4: Favorites
- Large title navigation bar ("Favorites" — 34pt)
- Horizontal cards: thumbnail (64pt) + name + restaurant + dietary badge
- Heart icon on each card
- Swipe-to-delete annotation

### Page 5: Settings
- Large title navigation bar ("Settings")
- Grouped iOS table style
- Sections: Dietary Preferences, Translation, Camera, General
- Toggles for on/off options (allergen alerts, show original text)
- Chevron disclosure for drill-down options
- All rows >= 44pt height

## Touch Target Compliance
All interactive elements meet 44pt minimum:
- Capture button: 72pt (exceeds)
- Flash toggle: 44pt
- Tab bar items: ~97pt wide x 43pt visible + 34pt indicator = safe
- Filter chips: 36pt height (padded to 44pt touch area via contentEdgeInsets)
- Settings rows: 44pt height minimum
- Dish cards: full-width tap target (>>44pt)
- Back button: 44pt hit area (iOS system default)

## Safe Area Compliance
- Top: 59pt reserved (Dynamic Island + gap)
- Bottom: 34pt reserved (Home Indicator)
- Content never underlaps safe areas except camera viewfinder (intentional full-bleed)
- Red dashed lines in wireframe annotate both safe areas
