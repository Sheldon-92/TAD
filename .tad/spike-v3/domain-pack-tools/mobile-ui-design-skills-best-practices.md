# Mobile UI Design Skills Best Practices — Research Summary

**Sources**: 5 GitHub repositories + 6 reference guidelines + 3 platform docs researched (2026-04-01)
**Purpose**: Reference for mobile-ui-design.yaml domain pack creation

---

## Repositories Analyzed

| Repo | Stars | Last Updated | Key Focus |
|------|-------|-------------|-----------|
| [awesome-skills/mobile-app-design](https://github.com/awesome-skills/mobile-app-design) | ~13 | 2026-03 | Comprehensive mobile UI/UX: iOS guidelines, Android guidelines, accessibility checklist, React Native patterns, contrast/touch-target validation scripts |
| [axiaoge2/Apple-Hig-Designer](https://github.com/axiaoge2/Apple-Hig-Designer) | ~50+ | 2026-03 | Apple HIG compliance: SF Pro font system, 8pt grid, system colors, glass panels, Apple-standard easing curves |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | ~16.9k | 2026-03 | Multi-platform design intelligence: iOS/Android/Web, 50+ styles, touch targets, gesture patterns, Dynamic Type, navigation rules |
| [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) | ~100+ | 2026-03 | Apple platform skills: HIG compliance, SwiftUI patterns, accessibility, App Store review prep |
| [wilwaldon/Claude-Code-Frontend-Design-Toolkit](https://github.com/wilwaldon/Claude-Code-Frontend-Design-Toolkit) | ~1k+ | 2026-02 | Meta-collection: responsive design specialist, 830-line accessibility guide, Fitts's Law/Hick's Law, 4px spacing grid |

### Additional Reference Sources

| Source | Type | Key Contribution |
|--------|------|-----------------|
| [Apple HIG](https://developer.apple.com/design/human-interface-guidelines) | Official docs | Touch targets, Dynamic Type, SF Pro, tab bar rules, safe areas |
| [Material Design 3](https://m3.material.io) | Official docs | 15 typography tokens, 48dp touch targets, layout breakpoints, component specs |
| [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | W3C standard | 24x24 CSS px minimum targets, 4.5:1 contrast, pointer target size |
| [Cursor Rules — SwiftUI](https://gist.github.com/harryworld/1c8ce39049b5aecaaed96f3030ee5337) | Cursor rules | @Observable patterns, NavigationStack, Dynamic Type, SF Symbols 5 |
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | Collection | SwiftUI guidelines, React Native Expo rules, mobile testing configs |
| [Axiom HIG Skill](https://charleswiltgen.github.io/Axiom/skills/ui-design/hig.html) | Claude skill | Quick HIG decision frameworks, font weight guidance, semantic color selection |

---

## By Capability

### platform_guidelines — iOS HIG / Material Design Rules

**iOS Human Interface Guidelines (Apple)**:

| Rule | Specification |
|------|--------------|
| Touch target minimum | 44x44 pt (research: <44pt causes 25%+ tap error rate) |
| Tab bar items | 3-5 maximum on iPhone |
| Navigation bar height | 44 pt (standard, locked by UINavigationController) |
| Tab bar height | 49-83 pt (varies by device/safe area; 49pt base, 83pt with home indicator) |
| Status bar height | 20 pt (pre-notch), 44 pt (notch devices), 59 pt (Dynamic Island) |
| Home indicator safe area | 34 pt bottom inset |
| SF Pro Text | Used at 19 pt and below |
| SF Pro Display | Used at 20 pt and above |
| 8pt grid system | All spacing/sizing in multiples of 8pt (4pt for small adjustments) |
| Color contrast minimum | 4.5:1 normal text, 3:1 large text (WCAG AA) |
| Corner radius | System default 10pt (small cards), 13pt (medium), 20pt (large cards/sheets) |
| Font weight guidance | Avoid Ultralight/Thin/Light; prefer Regular/Medium/Semibold/Bold |
| Back button placement | Top-left always |
| Action button placement | Top-right |
| Tabs placement | Bottom bar |

**iOS Dynamic Type — Default Sizes (at "Large" content size)**:

| Text Style | Size (pt) | Weight |
|------------|-----------|--------|
| Large Title | 34 | Regular |
| Title 1 | 28 | Regular |
| Title 2 | 22 | Regular |
| Title 3 | 20 | Regular |
| Headline | 18 | Semibold |
| Body | 17 | Regular |
| Callout | 16 | Regular |
| Subheadline | 15 | Regular |
| Footnote | 13 | Regular |
| Caption 1 | 12 | Regular |
| Caption 2 | 11 | Regular |

- Dynamic Type scales across 12 size categories: xSmall, Small, Medium, Large (default), xLarge, xxLarge, xxxLarge, AX1, AX2, AX3, AX4, AX5
- Body text at AX5 (max accessibility): 53 pt
- Minimum readable size: 11 pt (Caption 2)

**Material Design 3 (Google/Android)**:

| Rule | Specification |
|------|--------------|
| Touch target minimum | 48x48 dp |
| Bottom navigation items | Maximum 5 items with labels + icons |
| FAB placement | Bottom-right |
| Menu placement | Top-right |
| Back button placement | Top-left |
| Layout breakpoints | Mobile: <600dp, Tablet: 601-1294dp, Desktop: 1295dp+ |
| Base spacing unit | 8dp grid (4dp for dense layouts) |
| Font family | Roboto (all tokens) |

**Material Design 3 — 15 Typography Tokens**:

| Token | Size (sp) | Weight |
|-------|-----------|--------|
| Display Large | 57 | Regular (400) |
| Display Medium | 45 | Regular (400) |
| Display Small | 36 | Regular (400) |
| Headline Large | 32 | Regular (400) |
| Headline Medium | 28 | Regular (400) |
| Headline Small | 24 | Regular (400) |
| Title Large | 22 | Regular (400) |
| Title Medium | 16 | Medium (500) |
| Title Small | 14 | Medium (500) |
| Body Large | 16 | Regular (400) |
| Body Medium | 14 | Regular (400) |
| Body Small | 12 | Regular (400) |
| Label Large | 14 | Medium (500) |
| Label Medium | 12 | Medium (500) |
| Label Small | 11 | Medium (500) |

**Line Heights (M3)**: Body Large 24sp, Body Medium 20sp, Body Small 16sp

---

### mobile_navigation — Tab Bar / Stack Nav / Drawer Patterns

**Best practices** (from ui-ux-pro-max, awesome-skills/mobile-app-design, cursor rules):

**iOS Navigation Patterns**:
- Use `NavigationStack` with type-safe navigation for single-column flows
- Use `NavigationSplitView` for multi-column layouts on iPad/larger displays
- Use `navigationDestination()` for programmatic navigation and deep linking
- Bottom Tab Bar for top-level navigation (3-5 tabs)
- Back button always top-left; action buttons top-right
- Preserve scroll position and state on back navigation
- All key screens reachable via deep link URL for sharing

**Android Navigation Patterns**:
- Top App Bar with navigation icon (hamburger/back)
- Bottom Navigation Bar for primary destinations (max 5)
- Navigation Drawer for 6+ top-level destinations
- FAB (Floating Action Button) bottom-right for primary action
- Back behavior must be predictable and consistent

**Cross-Platform Rules**:
- Current location must be visually highlighted in nav
- Primary nav vs secondary nav must be clearly separated
- Core navigation must remain reachable from deep pages
- Never silently reset navigation stack or jump to home unexpectedly
- Bottom nav is for top-level screens only — never nest sub-navigation inside
- Modals must not be used for primary navigation flows
- Tab + Sidebar + Bottom Nav must not coexist at the same hierarchy level

**Anti-patterns**:
- Hamburger menu hiding primary navigation on mobile (use visible tab bar instead)
- More than 5 tabs on phone — creates cramped targets and cognitive overload
- Navigation that loses scroll position on back press
- Nested scrollable regions within a single screen without clear boundaries
- Deep linking that skips required onboarding/auth states

---

### mobile_wireframing — Mobile Wireframe Techniques

**Best step design** (synthesized from multiple repos):

1. **Platform Declaration**: Confirm target — iOS, Android, or cross-platform (React Native/Flutter). This determines nav patterns, component library, and gesture conventions
2. **Screen Inventory**: List all screens with hierarchy level (L1 = tab destination, L2 = detail, L3 = modal/sheet)
3. **Safe Area Layout**: Account for platform-specific safe areas:
   - iOS: Status bar (44-59pt top), Home indicator (34pt bottom), Dynamic Island
   - Android: Status bar (24dp top), Navigation bar (48dp bottom), camera cutout
4. **Thumb Zone Mapping**: Primary actions in the bottom 1/3 of screen (easy reach), secondary in middle 1/3, rarely-used in top 1/3
5. **Touch Target Audit**: All interactive elements minimum 44x44pt (iOS) / 48x48dp (Android) with 8pt/dp minimum gap between targets
6. **Content Priority**: Progressive disclosure — show essential content first, detail on interaction
7. **B&W Wireframe Rules**: Strict grayscale palette (#000, #333, #666, #999, #ccc, #eee, #fff), system fonts only, solid borders, numbered annotations
8. **Responsive Variants**: Create wireframes for smallest supported device (iPhone SE: 375x667pt) AND largest (iPhone Pro Max: 430x932pt / iPad: 1024x1366pt)

**Wireframe-to-Code Tools** (from research):
- Claude Code with design skills: text-based wireframe description to SwiftUI/React Native code
- Figma MCP integration: extract frames, components, tokens directly into code
- `scripts/validate-touch-targets.sh` (from awesome-skills/mobile-app-design): audits interactive element sizing
- `scripts/check-contrast.py` (from awesome-skills/mobile-app-design): validates contrast ratios

**Quality standards**:
- Every wireframe must show status bar, navigation bar, and tab bar/home indicator
- Sheet/modal wireframes must show dismissal mechanism (swipe-down handle, close button, or both)
- Loading states must be wireframed (skeleton screens preferred over spinners)
- Empty states must be wireframed with actionable CTAs
- Error states must show recovery path

---

### mobile_visual_design — Platform Colors / Fonts / Icons

**iOS Visual System**:
- **System font**: SF Pro (auto-selects Text <19pt / Display 20pt+)
- **Monospace**: SF Mono
- **Rounded variant**: SF Pro Rounded (for playful/friendly UIs)
- **System colors**: Use semantic colors (`UIColor.label`, `.secondaryLabel`, `.systemBackground`, `.secondarySystemBackground`) — auto-adapt to light/dark mode
- **Tint color**: Single brand tint color applied to interactive elements, nav bar items, tab bar items
- **SF Symbols 5**: 5,000+ symbols with variable-color and variable-width glyphs; use `symbolEffect()` for animations
- **Dark mode**: Use desaturated/lighter tonal variants, NOT inverted colors
- **Vibrancy effects**: System materials with blur + vibrancy for overlays (`.ultraThinMaterial`, `.thinMaterial`, `.regularMaterial`, `.thickMaterial`)
- **Backdrop blur**: 20px blur + 180% saturate for glass effects

**Android/Material You Visual System**:
- **Font**: Roboto (system default); Google Fonts for custom
- **Material You**: Dynamic color from user wallpaper — extract primary, secondary, tertiary, neutral, neutral-variant tonal palettes
- **Color tokens**: primary, onPrimary, primaryContainer, onPrimaryContainer, secondary, tertiary, error, surface, onSurface, outline, surfaceVariant
- **Semantic tokens**: Define colors by role, never raw hex in components
- **Icons**: Material Symbols (variable weight, fill, grade, optical size)
- **Dark mode**: Surface colors use tonal elevation (lighter surfaces = higher elevation)

**Cross-Platform Color Rules**:
- Normal text contrast: 4.5:1 minimum (WCAG AA)
- Large text (18pt+ regular, 14pt+ bold) contrast: 3:1 minimum
- UI components/graphical objects: 3:1 minimum
- Never rely on color alone to convey information (use icons, labels, patterns)
- Test with color blindness simulators (protanopia, deuteranopia, tritanopia)
- Placeholder text must still meet 4.5:1 contrast (common failure point)

---

### gesture_interaction — Swipe / Long-Press / Pinch Patterns

**Standard Platform Gestures**:

| Gesture | iOS Convention | Android Convention |
|---------|---------------|-------------------|
| Swipe back | Edge swipe from left (UINavigationController) | System back gesture (edge swipe) |
| Pull to refresh | Pull down from top of scrollable content | Pull down (SwipeRefreshLayout) |
| Swipe to delete | Swipe left on list row → red "Delete" action | Swipe left/right on list item |
| Long press | Context menu (UIContextMenuInteraction) | Context menu / selection mode |
| Pinch zoom | Standard on images/maps | Standard on images/maps |
| Double tap | Zoom in (photos/maps) | Zoom in |
| Two-finger rotate | Rotation on maps | Rotation on maps |

**Gesture Specifications**:

| Parameter | Value |
|-----------|-------|
| Tap recognition threshold | Movement <10pt from touch-down point |
| Long press minimum duration | 500ms (iOS default: `UILongPressGestureRecognizer.minimumPressDuration`) |
| Swipe minimum distance | 50-100pt horizontal or vertical |
| Swipe maximum duration | ~300-600ms from touch-start to touch-end |
| Drag movement threshold | Movement >10pt before drag begins (prevents accidental drags) |
| Pinch zoom minimum distance | Distance change >20pt between two fingers |
| Edge swipe recognition zone | 20pt from screen edge (iOS back gesture) |

**Gesture Design Rules** (from ui-ux-pro-max, awesome-skills/mobile-app-design):
- Never require gesture-only interactions — always provide visible button alternatives
- Use platform-standard gestures; don't invent custom gestures for standard actions
- Provide haptic feedback on gesture recognition (`.sensoryFeedback()` in SwiftUI)
- Respect system gesture areas — don't place custom gestures in edge zones
- Show affordances: drag handles (4pt x 36pt rounded bar) for draggable sheets, swipe hints on first use
- Destructive swipe actions (delete) must require confirmation or support undo
- Multi-finger gestures (3+ fingers) are reserved by the system — don't use them

**Anti-patterns**:
- Hover-dependent interactions — no hover state on touch devices
- Hidden gestures with no discoverability (e.g., double-tap that's never taught)
- Conflicting gesture recognizers on nested scrollable views
- Custom back gesture that conflicts with system edge-swipe navigation
- Force Touch / 3D Touch reliance — deprecated; use long press + context menu instead

---

### mobile_design_system — Native vs Custom Components

**When to Use Native Components**:
- Navigation bars, tab bars, status bars — always use native (system appearance updates automatically)
- Alert dialogs, action sheets — always use native (consistent with OS behavior)
- Keyboard handling, text input fields — native provides auto-correct, auto-fill, password integration
- Share sheets — native provides system-wide sharing
- Date/time pickers — native provides accessibility, localization
- Pull-to-refresh — native provides consistent physics

**When Custom Components Are Acceptable**:
- Cards, tiles, product listings — visual brand differentiation
- Custom buttons (but respect 44x44pt minimum touch targets)
- Onboarding flows / tutorials
- Custom charts, data visualizations
- Branded loading animations (but respect `prefers-reduced-motion`)
- Bottom sheets with custom content (but use native drag handle physics)

**Design Token Architecture** (from Frontend-Design-Toolkit, ui-ux-pro-max):
- **Spacing scale**: 4px base unit — 0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128
- **Border radius scale**: 0, 4, 8, 12, 16, 20, 24, 9999 (pill)
- **Shadow elevation**: 3 levels — sm (0 1px 2px), md (0 4px 8px), lg (0 12px 40px)
- **Color tokens**: primary, secondary, error, surface, onSurface, outline (semantic, not raw hex)
- **Typography tokens**: displayLarge through labelSmall (see platform_guidelines tables)
- **Breakpoints**: 375 (small phone), 390 (standard phone), 430 (large phone), 768 (tablet portrait), 1024 (tablet landscape)

**Component Sizing Rules**:

| Component | iOS Size | Android Size |
|-----------|----------|-------------|
| Button minimum height | 44pt | 48dp |
| Button minimum padding | 8pt vertical, 16pt horizontal | 12dp vertical, 24dp horizontal |
| Input field height | 44pt | 56dp (filled), 56dp (outlined) |
| List row minimum height | 44pt | 48dp (single-line), 64dp (two-line), 88dp (three-line) |
| Icon size (navigation) | 22-28pt | 24dp |
| Icon size (tab bar) | 25pt (selected), 22pt (unselected) | 24dp |
| Avatar (small) | 28pt | 24dp |
| Avatar (medium) | 40pt | 40dp |
| Avatar (large) | 60pt | 56dp |
| FAB (standard) | N/A (not iOS pattern) | 56dp |
| FAB (small) | N/A | 40dp |
| FAB (large) | N/A | 96dp |
| Chip height | 32pt | 32dp |
| Bottom sheet handle | 4pt x 36pt, centered | 4dp x 32dp, centered |

---

### mobile_usability — Touch Targets, Reachability, Dynamic Type

**Touch Target Standards**:

| Standard | Minimum Size | Source |
|----------|-------------|--------|
| Apple HIG | 44x44 pt | Apple Developer Documentation |
| Material Design | 48x48 dp | m3.material.io |
| WCAG 2.2 (Level AA) | 24x24 CSS px | W3C — minimum for pointer targets |
| Best practice | 48-56 pt/dp for primary actions | 2026 mobile UX research |

- Minimum gap between interactive elements: 8pt/dp
- Avoid placing touch targets near screen edges (accidental activation from grip)
- Primary actions in thumb-friendly zone (bottom 1/3 of screen)
- Never overlap touch targets (even if visually separated)

**Reachability Zones** (for one-handed use):

| Zone | Screen Area | Usage |
|------|------------|-------|
| Natural (easy) | Bottom center 1/3 | Primary actions, FAB, tab bar, key CTAs |
| Stretch (moderate) | Middle and bottom sides | Secondary actions, list items, content |
| Hard to reach | Top corners, top center | Infrequent actions, settings, profile icons |

- iPhone: 67% of users use one hand — design for thumb reachability
- Large phones (>6.1"): bottom sheet pattern preferred over top-anchored modals
- Place destructive actions in hard-to-reach zones (top) to prevent accidental taps

**Dynamic Type / Text Scaling**:
- iOS: Support all 12 Dynamic Type sizes (xSmall through AX5)
- Android: Support `sp` (scale-independent pixels) — scales with user font size preference
- Body text baseline: 16sp/pt minimum (avoids iOS auto-zoom on form inputs)
- Line height: 1.5-1.75x font size for body text
- Line length: 35-60 characters per line on phone
- Never truncate text as it grows — use scrollable containers or layout reflow
- Test at both smallest (xSmall) and largest (AX5) size categories
- Labels must grow with text; never use fixed-width containers for text
- `UIFontMetrics` (iOS) / `TextAppearance` (Android) for scaling custom fonts

**Animation & Motion**:

| Animation Type | Duration | Notes |
|---------------|----------|-------|
| Micro-interactions (button press, toggle) | 150-300ms | Quick, responsive feel |
| Screen transitions (push/pop) | 300-350ms | iOS default: 350ms |
| Complex transitions (shared element) | 300-400ms | Never exceed 400ms |
| Exit animations | 60-70% of enter duration | Exits feel faster |
| Loading spinners | Appear after 200ms delay | Avoid flash of spinner for fast loads |
| Skeleton screens | Appear immediately | Preferred over spinners for content loading |

- Easing: iOS uses `curveEaseInOut` (default), Material uses `emphasized` (Bezier: 0.2, 0, 0, 1)
- Always respect `prefers-reduced-motion` / `UIAccessibility.isReduceMotionEnabled`
- When reduced motion is on: replace animations with instant cuts or simple opacity fades
- Animate only `transform` and `opacity` for GPU acceleration; avoid animating `width`, `height`, `top`, `left`
- Use `Phase Animations` in SwiftUI for complex multi-stage transitions
- Haptic feedback via `.sensoryFeedback()` (SwiftUI) on key interactions

**Performance Thresholds**:

| Metric | Target | Source |
|--------|--------|--------|
| Tap-to-response latency | <100ms | Google RAIL model |
| Time to Interactive (TTI) | <3 seconds | 2026 mobile UX best practices |
| Cumulative Layout Shift (CLS) | <0.1 | Web Vitals (mobile web) |
| Initial app size | <4MB (React Native), varies native | Performance research |
| Network per screen | <50KB | Mobile-first performance |
| List virtualization threshold | 50+ items → virtualize | FlatList/LazyVStack guidance |
| Image format | WebP/AVIF with lazy loading | Performance optimization |
| Font loading | `font-display: swap` | Avoid invisible text flash |

**Form Usability**:
- Always use visible labels — never placeholder-only
- Validation on blur (not on keystroke); show error after user finishes
- Error message placement: below the related field with clear recovery path
- Use semantic input types: `email`, `tel`, `number`, `url` for correct mobile keyboard
- Helper text persistent below complex inputs (not tooltip-only)
- Auto-focus first field on form entry
- Password fields: show/hide toggle, strength indicator
- Multi-step forms: progress indicator showing current step / total steps

**Accessibility Checklist** (from awesome-skills/mobile-app-design, WCAG 2.2):
- [ ] All interactive elements have `accessibilityLabel` and `accessibilityHint`
- [ ] Screen reader logical reading order matches visual order
- [ ] Focus rings visible: 2-4px rings on interactive elements
- [ ] Tab/focus order matches visual layout order
- [ ] Icon-only buttons have descriptive `aria-label` / `accessibilityLabel`
- [ ] Meaningful images have alt text; decorative images marked `accessibilityHidden`
- [ ] Color is never the sole indicator of state (use icons, labels, patterns)
- [ ] All text meets 4.5:1 contrast ratio (3:1 for large text)
- [ ] Reduced motion preference respected
- [ ] Dynamic Type / font scaling supported (test at AX5)
- [ ] VoiceOver (iOS) and TalkBack (Android) tested on real devices
- [ ] Keyboard navigation fully supported (external keyboard)
- [ ] No content auto-plays or auto-advances without user control
- [ ] Time-based interactions have adjustable or removable time limits
- [ ] Automation catches 30-40% of issues — real-device testing mandatory for the rest

---

## Key Differences: iOS vs Android Design

| Dimension | iOS | Android |
|-----------|-----|---------|
| Primary navigation | Bottom Tab Bar (3-5 items) | Bottom Navigation / Navigation Drawer |
| Back navigation | Edge swipe from left; back button top-left | System back gesture; top-left arrow |
| Primary action | Text button top-right / bottom toolbar | FAB (Floating Action Button) |
| Touch target minimum | 44x44 pt | 48x48 dp |
| Font system | SF Pro (Text/Display auto-switch at 19pt) | Roboto |
| Typography tokens | 11 text styles (Large Title through Caption 2) | 15 tokens in 5 groups x 3 sizes |
| Grid system | 8pt grid | 8dp grid |
| Modal presentation | Bottom sheet (detents: .medium, .large) | Bottom sheet / Dialog |
| Deletion pattern | Swipe-left on row → red "Delete" button | Swipe with undo snackbar |
| Long press | Context menu with preview | Context menu / selection mode |
| Share | UIActivityViewController (system share sheet) | Intent-based sharing |
| Status bar | Matches app background or blurs | Matches system theme or custom |
| Haptics | UIFeedbackGenerator / .sensoryFeedback() | HapticFeedbackConstants |

---

## Tool Validation Scripts

From awesome-skills/mobile-app-design repository:
- `scripts/validate-touch-targets.sh` — Audits interactive element sizing against 44pt/48dp minimums
- `scripts/check-contrast.py` — Validates color contrast ratios against WCAG AA (4.5:1/3:1)
- `examples/profile-screen-example.tsx` — Complete screen implementation with accessibility
- `examples/optimized-list-example.tsx` — FlatList performance patterns with virtualization

---

## Summary: Top 10 Non-Negotiable Mobile Design Rules

1. **44pt / 48dp minimum touch targets** with 8pt/dp gap between them
2. **Dynamic Type support** — test at xSmall AND AX5; never truncate growing text
3. **4.5:1 color contrast** for normal text (3:1 for large text and UI components)
4. **Bottom 1/3 for primary actions** — thumb-friendly zone for one-handed use
5. **3-5 tab bar items max** — use navigation drawer if you have more
6. **150-300ms micro-interactions**, 300-400ms transitions, never exceed 400ms
7. **Respect platform conventions** — native nav bars, tab bars, system gestures
8. **Always provide button alternatives to gestures** — no gesture-only interactions
9. **Respect reduced motion** — replace animations with cuts or simple fades
10. **Test on real devices** with VoiceOver/TalkBack — automation catches only 30-40%
