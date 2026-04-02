# Pair Testing Plan (4D Protocol) — Menu Snap iOS

## Session Focus

**Primary focus areas:**
1. Camera interaction feel — capture responsiveness, viewfinder smoothness
2. Gesture smoothness — scrolling menu results, swipe actions, filter sheet
3. Dietary filter UX — discoverability, filter application feedback

## Pre-Session Setup

- [ ] App running on physical device (iPhone 15 preferred — baseline device)
- [ ] Screen recording enabled (Settings > Control Center > Screen Recording)
- [ ] Flipper connected for real-time FPS monitoring
- [ ] Screenshot tool ready: `xcrun simctl io booted screenshot round-{N}.png`

## Planned Rounds

### Round 1: Camera Launch & Capture (Gesture + Feel)

**Human focuses on:**
- Time from app open to camera ready — does it "feel" instant?
- Capture button responsiveness — tap-to-feedback delay
- Haptic feedback on capture — appropriate intensity?
- Viewfinder smoothness — any stuttering when moving phone?

**AI analyzes:**
- Screenshot of camera overlay layout
- Safe area compliance
- Guide frame alignment
- Button sizing and positioning

**Decision template:** Each finding → Fix Now / Fix Later / Won't Fix

### Round 2: Results Display & Scrolling (Performance + Layout)

**Human focuses on:**
- Scroll feel — buttery 60fps or noticeable jank?
- Menu card loading — instant or progressive?
- Translation text appearance — pop-in or smooth fade?
- "Trustworthiness" of translated text presentation

**AI analyzes:**
- Screenshot of results list with multiple cards
- Text truncation, alignment, spacing
- Dietary badge visibility and color contrast
- Card layout consistency

### Round 3: Dietary Filter Interaction (UX + Discoverability)

**Human focuses on:**
- Can you find the filter button without instructions?
- Filter sheet gesture — smooth bottom sheet or janky modal?
- Toggle feedback — clear on/off state?
- After applying: is it obvious which filters are active?
- Clearing filters: intuitive?

**AI analyzes:**
- Screenshot of filter sheet layout
- Toggle states visual clarity
- Active filter badge visibility on results screen
- Empty state when filters are too restrictive

### Round 4: Network Edge Cases (Resilience + Feel)

**Human focuses on:**
- Slow network (throttled): does the app feel "alive" during loading?
- Offline capture: does the error message make sense?
- Recovery after reconnection: smooth or need to restart?
- Loading indicators: informative or just a spinner?

**AI analyzes:**
- Error screen layout and messaging
- Loading state screenshots
- Retry flow screenshots

### Round 5: Favorites & Cross-Flow Navigation (Cohesion)

**Human focuses on:**
- Save animation — satisfying?
- Favorites tab discovery — obvious?
- Navigation between scan results and favorites — disorienting or clear?
- Remove from favorites — confirmation or instant?

**AI analyzes:**
- Favorites screen layout
- Empty state design
- Navigation transition screenshots
- Button state changes (favorite/unfavorite)

## Output Format

Per round:
```
## Round N: {Focus}
### Findings
| # | Finding | Screenshot | Severity (Human) | Decision | Solution |
|---|---------|-----------|-------------------|----------|----------|
| 1 | ... | round-N-1.png | ... | Fix Now/Later/Won't Fix | ... |

### AI Observations
- Layout: ...
- Accessibility: ...
- Performance indicator: ...
```

## Session Rules

1. Human controls the device — AI never decides severity alone
2. "This feels off" from human is a valid finding even without measurable data
3. Every finding gets a decision IN-SESSION (4D: Discover → Discuss → Decide → Deliver)
4. Fix Now items get immediately added to a handoff for Blake
5. Screenshots are mandatory evidence for every finding
