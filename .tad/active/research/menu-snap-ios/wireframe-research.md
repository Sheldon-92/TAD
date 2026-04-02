# Wireframe Research: Menu Snap iOS

## 1. Layout Pattern Analysis (from competitive research)

| App | Layout Pattern | Info Organization |
|---|---|---|
| Menu Explain | Camera → scrollable list of dishes | Linear list, each dish expandable |
| Google Translate Camera | Real-time overlay on viewfinder | Inline overlay, no separate results page |
| Yelp Menu | Scrollable card list | Cards with photos + price + rating |
| Apple Camera | Full-screen viewfinder, minimal chrome | Bottom controls row, top toggles row |

## 2. Three UX Approaches

### Approach A: Camera-First (Recommended)

**Philosophy**: The camera IS the app. Launch → viewfinder → capture → results push in.
- Launch opens directly to camera viewfinder (full-screen)
- Capture → processing overlay → results page pushes in
- Results: scrollable list of translated dish cards
- Drill into any dish for detail

| Criterion | Score (1-5) | Notes |
|---|---|---|
| Learning Cost | 5 | Camera apps are universally understood |
| Info Density | 3 | One page at a time (camera → results → detail) |
| Platform Compliance | 5 | Follows Apple Camera app pattern exactly |
| Single-hand Friendliness | 4 | Capture button at bottom center, natural thumb reach |
| **Total** | **17/20** | |

### Approach B: List-First (History-Centric)

**Philosophy**: Past scans are the home. Camera is a secondary action (FAB or tab).
- Launch opens to history/recent scans list
- FAB or prominent button to start new scan
- Results live as entries in the history
- Good for frequent users who reference past scans often

| Criterion | Score (1-5) | Notes |
|---|---|---|
| Learning Cost | 4 | Standard list app pattern |
| Info Density | 5 | Immediately shows all past data |
| Platform Compliance | 4 | Standard but camera is not primary |
| Single-hand Friendliness | 3 | FAB is reachable but adds an extra tap to core action |
| **Total** | **16/20** | |

### Approach C: Map-First (Location-Aware)

**Philosophy**: Nearby restaurants on a map. Tap restaurant → scan its menu.
- Launch shows map with nearby restaurants
- Tap restaurant → option to scan menu or view past scans
- Results linked to restaurant location
- Social: see what others scanned at this restaurant

| Criterion | Score (1-5) | Notes |
|---|---|---|
| Learning Cost | 2 | Complex mental model (map + camera + social) |
| Info Density | 4 | Rich contextual data |
| Platform Compliance | 3 | MapKit compliant but unusual for camera apps |
| Single-hand Friendliness | 2 | Map interaction requires two hands (pinch/pan) |
| **Total** | **11/20** | |

## 3. Decision: Approach A — Camera-First

**Winner**: Camera-First (17/20)

**Rationale**:
- Highest platform compliance (mirrors Apple Camera pattern)
- Lowest learning cost (universal camera metaphor)
- Core action (scan) is immediate — zero taps to start
- Single-hand friendly with capture button at bottom
- History/Favorites available via tab bar for secondary flows

**Trade-off acknowledged**: Lower info density at launch (just viewfinder), but this is acceptable because the primary use case is "I'm at a restaurant NOW, let me scan THIS menu" — not browsing past data.
