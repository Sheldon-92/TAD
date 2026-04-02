# Gesture Research: Menu Snap iOS

## 1. System-Level Gestures (DO NOT OVERRIDE)

| Gesture | Trigger | System Action | Platform |
|---|---|---|---|
| Left edge right-swipe | Start from left 20pt edge | Navigate back | iOS system |
| Bottom edge up-swipe | Start from bottom edge | Go to Home / App Switcher | iOS system |
| Top-right pull-down | Start from top-right | Control Center | iOS system |
| Top-left pull-down | Start from top-left | Notification Center | iOS system |

## 2. Custom Gesture Catalog

### 2.1 Swipe Between Dishes (Menu Results)

| Property | Value |
|---|---|
| **Gesture** | Horizontal swipe on dish card |
| **Trigger** | Swipe distance >= 50pt |
| **Direction** | Left = next dish, Right = previous dish |
| **Target Element** | Dish card in results list |
| **Animation** | Card slides out, next card slides in (300ms, spring) |
| **Haptic** | UIImpactFeedbackGenerator(.light) on card snap |
| **Conflict** | None (vertical scroll is orthogonal) |
| **Accessibility Alt** | Scroll list vertically, tap any card |
| **Discoverability** | Subtle peek of next card edge (8pt visible) |

### 2.2 Long-Press to Save Favorite

| Property | Value |
|---|---|
| **Gesture** | Long press on dish card |
| **Trigger** | >= 500ms press duration |
| **Target Element** | Dish card (results or detail) |
| **Feedback** | UIImpactFeedbackGenerator(.medium) at 500ms |
| **Visual** | Card scales to 0.97x, context menu appears |
| **Menu Items** | Save to Favorites / Share / Copy Name |
| **Animation** | iOS standard context menu (UIContextMenu) |
| **Conflict** | None (tap is < 200ms, long-press is > 500ms) |
| **Accessibility Alt** | "..." overflow button on each card, VoiceOver custom action |
| **Discoverability** | First-time coach mark: "Long-press any dish to save" |

### 2.3 Pull-to-Rescan

| Property | Value |
|---|---|
| **Gesture** | Pull down on results list |
| **Trigger** | Pull distance >= 60pt |
| **Target Element** | Menu Results scroll view |
| **Feedback** | UIImpactFeedbackGenerator(.medium) on trigger |
| **Visual** | Camera icon spinner at top, "Rescanning..." text |
| **Action** | Re-runs OCR + translation on last captured image |
| **Animation** | Standard iOS pull-to-refresh (UIRefreshControl) |
| **Conflict** | None (only at top of scroll) |
| **Accessibility Alt** | "Rescan Menu" button at bottom of results |
| **Discoverability** | Standard iOS pattern, universally known |

### 2.4 Pinch-to-Zoom on Menu Image

| Property | Value |
|---|---|
| **Gesture** | Pinch (two-finger) |
| **Trigger** | Any pinch gesture on image view |
| **Target Element** | Original menu photo (Dish Detail) + Camera viewfinder |
| **Scale Range** | Min 1.0x (no zoom-out below original), Max 5.0x |
| **Animation** | Real-time transform follow, spring snap back on release |
| **Conflict** | Scroll disabled during pinch (gesture recognizer priority) |
| **Accessibility Alt** | Double-tap to toggle 2x zoom, VoiceOver zoom |
| **Discoverability** | Standard iOS pattern |

### 2.5 Camera Tap-to-Focus

| Property | Value |
|---|---|
| **Gesture** | Single tap on viewfinder |
| **Trigger** | Tap anywhere on camera preview |
| **Target Element** | Camera viewfinder area |
| **Visual** | Yellow focus square (68pt) appears at tap point, shrinks to 44pt, fades after 1s |
| **Haptic** | UIImpactFeedbackGenerator(.light) |
| **Action** | AVCaptureDevice.setFocusPointOfInterest + setExposurePointOfInterest |
| **Conflict** | None (double-tap reserved for zoom toggle) |
| **Accessibility Alt** | Auto-focus (VoiceOver users), "Focus" button in controls |
| **Discoverability** | Standard camera pattern, universally known |

### 2.6 Swipe-to-Delete (Favorites)

| Property | Value |
|---|---|
| **Gesture** | Left swipe on favorite card |
| **Trigger** | Swipe distance >= 50pt |
| **Target Element** | Favorite item row |
| **Visual** | Red "Delete" button revealed (iOS standard) |
| **Haptic** | UIImpactFeedbackGenerator(.medium) |
| **Undo** | Toast notification "Removed from favorites" with "Undo" button (5s timeout) |
| **Conflict** | Left edge swipe (back) — resolved by swipe start position (edge = back, interior = delete) |
| **Accessibility Alt** | VoiceOver custom action "Delete", trailing swipe action |
| **Discoverability** | Standard iOS list pattern |

## 3. Animation Timing Reference

| Animation Type | Duration | Curve | Notes |
|---|---|---|---|
| Micro-interaction (badge tap) | 150ms | ease-out | Quick feedback |
| Card expand/collapse | 250ms | ease-in-out | Content reveal |
| Page transition (push) | 350ms | spring(0.5, 0.8) | iOS standard |
| Page transition (pop) | 245ms (70% of push) | spring(0.5, 0.8) | Faster exit |
| Modal present | 350ms | spring(0.5, 0.85) | Bottom sheet slide up |
| Modal dismiss | 250ms | ease-in | Faster dismiss |
| Pull-to-refresh spinner | continuous | linear | Until data loads |
| Focus square appear | 200ms | ease-out | Quick appear |
| Focus square fade | 1000ms | ease-in (after 500ms hold) | Slow fade |

## 4. Gesture Conflict Resolution

| Conflict Pair | Resolution Strategy |
|---|---|
| Left-swipe delete vs Left-edge back | **Start position**: edge (within 20pt from left) = system back; interior = swipe action |
| Horizontal dish swipe vs Vertical scroll | **Direction lock**: first 10pt of movement determines axis lock |
| Pinch-zoom vs Scroll | **Gesture priority**: pinch recognizer takes priority, scroll disabled during two-finger touch |
| Tap-to-focus vs Tap-to-dismiss (overlay) | **Target specificity**: tap on viewfinder = focus; tap on overlay UI = button action |
| Long-press context menu vs Drag | **Timing**: long-press at 500ms triggers menu; if finger moves > 10pt before 500ms, it's a drag/scroll |
