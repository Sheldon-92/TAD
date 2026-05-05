# Gesture Interaction Spec: Menu Snap iOS

## Per-Page Gesture Summary

### Camera/Scan Page
| Gesture | Target | Action | Haptic |
|---|---|---|---|
| Tap | Viewfinder | Focus + exposure at point | Light impact |
| Double-tap | Viewfinder | Toggle 2x zoom | Medium impact |
| Pinch | Viewfinder | Continuous zoom (1x-5x) | None |
| Tap | Capture button | Capture photo | Medium impact |
| Tap | Flash toggle | Cycle: Auto/On/Off | Light impact |

### Menu Results Page
| Gesture | Target | Action | Haptic |
|---|---|---|---|
| Tap | Dish card | Push to Dish Detail | None |
| Long-press (500ms) | Dish card | Context menu (Save/Share) | Medium impact |
| Pull down (60pt) | Scroll view (at top) | Rescan menu | Medium impact |
| Vertical scroll | Results list | Browse dishes | None |
| Left-edge swipe | Screen | Navigate back to camera | None (system) |

### Dish Detail Page
| Gesture | Target | Action | Haptic |
|---|---|---|---|
| Pinch | Dish photo | Zoom (1x-5x) | None |
| Double-tap | Dish photo | Toggle 2x zoom | Medium impact |
| Tap | Save button | Toggle favorite | Medium impact |
| Tap | Share button | Open system share sheet | None |
| Left-edge swipe | Screen | Navigate back | None (system) |
| Vertical scroll | Content | Browse description/ingredients | None |

### Favorites Page
| Gesture | Target | Action | Haptic |
|---|---|---|---|
| Tap | Favorite card | Push to Dish Detail | None |
| Left-swipe (50pt) | Favorite card | Reveal delete button | Medium impact |
| Tap | Delete button | Remove + undo toast | Heavy impact |
| Pull down | Scroll view | Refresh favorites | Light impact |

### Settings Page
| Gesture | Target | Action | Haptic |
|---|---|---|---|
| Tap | Settings row | Navigate to detail / toggle | Light impact (toggle) |
| Tap | Dietary Restrictions | Present bottom sheet | None |

## Gesture Discoverability Plan

### First Launch (Onboarding)
1. **Camera gesture coach mark**: Animated hand showing tap-to-focus (appears once)
2. **Capture hint**: Pulsing capture button with "Tap to scan" text

### First Scan Results
3. **Long-press coach mark**: "Long-press any dish to save it" tooltip (appears once, on first dish card)
4. **Pull-to-rescan hint**: Subtle downward arrow at top of results

### First Favorites Entry
5. **Swipe-to-delete hint**: First favorite item shows slight left offset (revealing red background edge)

### Ongoing Hints
- All gestures have button alternatives (no gesture is the ONLY way)
- VoiceOver custom actions mirror all gestures
- Settings > Accessibility can disable gesture coach marks

## Accessibility Alternatives (Complete)

| Gesture | Non-Gesture Alternative | VoiceOver Action |
|---|---|---|
| Tap-to-focus | Auto-focus (always on) | N/A (auto-focus) |
| Pinch-to-zoom | Double-tap toggles 2x | VoiceOver zoom |
| Long-press save | "..." button on card | Custom action "Save to Favorites" |
| Pull-to-rescan | "Rescan" button at bottom | Double-tap Rescan button |
| Swipe-to-delete | Edit mode with delete buttons | Custom action "Delete" |
| Horizontal dish swipe | Vertical scroll through list | Swipe left/right between elements |
