# Navigation Research: Menu Snap iOS

## 1. Competitive Navigation Patterns

| App | Primary Nav | Drill-Down | Modal Usage |
|---|---|---|---|
| Menu Explain | Camera-first → results list | List → dish detail | Settings modal |
| Google Translate | Input method tabs (camera/text/voice) | Translation detail expand | Language picker modal |
| Yelp | Tab bar (Search, Delivery, Me) | Restaurant → Menu → Dish | Filters as bottom sheet |
| Apple Camera | Full-screen viewfinder, bottom mode selector | Photo → Edit | Settings sheet |

## 2. Page Inventory

| Page | Usage Frequency | Depth Level | Needs Tab? |
|---|---|---|---|
| Camera/Scan | Very High (core action) | L0 (Root) | Yes — Tab 1 |
| Menu Results | Very High (after every scan) | L1 (Push from Camera) | No — Stack child |
| Dish Detail | High (per dish) | L2 (Push from Results) | No — Stack child |
| Scan History | Medium (review past scans) | L0 (Root) | Yes — Tab 2 |
| History Detail | Medium | L1 (Push from History) | No — Stack child |
| Favorites | Medium (saved dishes) | L0 (Root) | Yes — Tab 3 |
| Settings | Low (one-time setup) | L0 (Root) | Yes — Tab 4 |
| Dietary Preferences | Low (setup + occasional edit) | Modal (from Settings or Onboarding) | No — Modal |
| Language Preferences | Low | L1 (Push from Settings) | No — Stack child |
| Onboarding | Once (first launch) | Full-screen modal | No — Modal |

## 3. Navigation Model

### Tab Bar (4 items)

| Position | Tab | Icon (SF Symbol) | Label |
|---|---|---|---|
| 1 | Scan | camera.viewfinder | Scan |
| 2 | History | clock.arrow.circlepath | History |
| 3 | Favorites | heart.fill | Favorites |
| 4 | Settings | gearshape | Settings |

**Rationale**: 4 tabs (under 5 limit). Camera/Scan is Tab 1 (leftmost = most used + thumb-reachable for right-hand). History and Favorites are medium-frequency. Settings is low-frequency rightmost.

### Stack Navigation (per Tab)

- **Tab 1 (Scan)**: Camera → Menu Results → Dish Detail
- **Tab 2 (History)**: History List → Scan Detail → Dish Detail
- **Tab 3 (Favorites)**: Favorites List → Dish Detail
- **Tab 4 (Settings)**: Settings → Dietary Preferences / Language Preferences / About

### Modal Presentations

| Trigger | Modal Type | Content |
|---|---|---|
| First launch | Full-screen cover | Onboarding (camera permission + dietary setup) |
| "Edit Dietary Preferences" | .medium detent sheet | Dietary filter checkboxes |
| Share dish | System sheet | UIActivityViewController |
| Scan in progress | Overlay (not modal) | Processing indicator on camera view |

## 4. Reachability Analysis (Thumb Zone)

```
┌─────────────────────┐
│   COLD ZONE          │  ← Nav bar (back button, title, action)
│   (stretch needed)   │     Keep actions here minimal
│                      │
│   NEUTRAL ZONE       │  ← Content area (scrollable)
│   (comfortable)      │     Dish cards, results list
│                      │
│   HOT ZONE           │  ← Bottom area
│   (natural thumb)    │     Tab bar, capture button, filters
└─────────────────────┘
```

- Tab Bar is in HOT ZONE (bottom)
- Camera capture button is in HOT ZONE (bottom center)
- Dietary filter chips are placed above Tab Bar for easy reach
- "Rescan" button on results page is at bottom

## 5. Deep Link Paths

| Page | Deep Link | Use Case |
|---|---|---|
| Scan | menusnap://scan | Widget "Quick Scan" |
| History | menusnap://history | Notification tap |
| History Detail | menusnap://history/{scanId} | Share link |
| Dish Detail | menusnap://dish/{dishId} | Share specific dish |
| Favorites | menusnap://favorites | Widget |
| Settings | menusnap://settings | System settings redirect |
| Dietary | menusnap://settings/dietary | Onboarding reminder |
