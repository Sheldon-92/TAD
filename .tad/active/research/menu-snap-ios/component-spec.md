# Component Spec: Menu Snap iOS

## Component System Summary

**Total**: 17 components (12 native + 5 custom)
**Custom component rationale**: Each custom component has a "why not native" justification.

## Component API Reference

### Native Components (12)

#### 1. NavigationBar
```swift
NavigationStack {
  ContentView()
    .navigationTitle("Menu Results")
    .navigationBarTitleDisplayMode(.inline) // or .large for root views
    .toolbar {
      ToolbarItem(placement: .topBarLeading) { BackButton() }
      ToolbarItem(placement: .topBarTrailing) { FilterButton() }
    }
}
```

#### 2. TabBar
```swift
TabView {
  ScanView().tabItem { Label("Scan", systemImage: "camera.viewfinder") }
  HistoryView().tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
  FavoritesView().tabItem { Label("Favorites", systemImage: "heart.fill") }
  SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
}
```

#### 3-12. Standard iOS Components
See component-research.md for full list. All use SwiftUI native implementations with system styling.

### Custom Components (5)

#### 13. CameraOverlayView
**Variants**: idle, focusing, processing, error
**Props**:
- `isFlashOn: Bool`
- `onCapture: () -> Void`
- `onFlashToggle: () -> Void`
- `focusPoint: CGPoint?`
- `processingState: ProcessingState`

#### 14. DietaryBadge
**Variants**: safe, warning, danger, info
**Props**:
- `severity: BadgeSeverity` (enum: .safe, .warning, .danger, .info)
- `text: String`
- `icon: String?` (SF Symbol name, auto-selected by severity if nil)

#### 15. DishCard
**Variants**: compact (in list), expanded (in detail)
**Props**:
- `dish: DishModel` (name, originalName, price, description, badges, aiRecommendation)
- `onTap: () -> Void`
- `onLongPress: () -> Void`

#### 16. FilterChipBar
**Props**:
- `filters: [FilterItem]` (label, count, isActive)
- `onFilterTap: (FilterItem) -> Void`

#### 17. AIRecommendationTag
**Props**:
- `text: String`

## Do / Don't Guide

### Do
- Use system SF Symbols (not custom icon PNGs)
- Use Dynamic Type text styles (not hardcoded sizes)
- Use system colors (not hardcoded hex values in SwiftUI)
- Use `.contextMenu` for long-press menus (system animation + haptic)
- Use `.sheet` with detents for dietary preferences (iOS 16+ pattern)
- Support Dark Mode via semantic colors (automatic with system colors)

### Don't
- Don't use custom tab bar implementation (lose system blur material + edge-swipe compatibility)
- Don't override system back gesture (left edge swipe)
- Don't use PNG icons where SF Symbols exist
- Don't hardcode font sizes (breaks Dynamic Type accessibility)
- Don't use custom alert dialogs (use system UIAlertController)
- Don't create custom pull-to-refresh (use system UIRefreshControl)
