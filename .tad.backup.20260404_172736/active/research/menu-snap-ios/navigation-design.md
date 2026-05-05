# Navigation Design: Menu Snap iOS

## Navigation Architecture Summary

### Primary: Tab Bar (4 Tabs)
1. **Scan** (camera.viewfinder) — Core action, camera viewfinder
2. **History** (clock.arrow.circlepath) — Past scans chronologically
3. **Favorites** (heart.fill) — Saved dishes
4. **Settings** (gearshape) — Preferences, dietary, language

### Secondary: Stack Navigation (Push/Pop)
- Scan → Menu Results → Dish Detail
- History → Scan Detail → Dish Detail
- Favorites → Dish Detail
- Settings → Dietary Preferences | Language | About

### Tertiary: Modal Sheets
- Onboarding (full-screen cover, first launch only)
- Dietary Preferences edit (.medium detent bottom sheet)
- Share (system UIActivityViewController)

### Gesture Navigation
- **System edge-swipe left**: Back (never override)
- **Tab switching**: Tap tab icons (no swipe between tabs — avoids conflict with camera gestures)
- **Pull-to-refresh**: History list, Favorites list

## Key Design Decisions

1. **Camera as Tab 1 (not floating button)**: The scan function is THE core action. Making it Tab 1 ensures it's the default view and always one tap away. A floating camera button (like Instagram stories) was considered but rejected — it adds a layer and the camera IS the app.

2. **4 Tabs not 5**: Keeping one slot free for potential future features (e.g., "Explore" for nearby restaurants). 4 tabs also give more horizontal space per tab on smaller devices.

3. **Results as Stack Push (not new tab)**: After scanning, results push onto the Scan tab's stack. This maintains context (user can swipe back to re-scan) and doesn't pollute the tab bar.

4. **Dietary Preferences as Bottom Sheet**: Users edit dietary preferences infrequently. A .medium detent sheet (iOS 16+) keeps context visible behind the sheet and feels lightweight.
