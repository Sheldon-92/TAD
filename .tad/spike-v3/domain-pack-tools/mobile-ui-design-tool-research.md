# Mobile UI Design — Tool Research

> Date: 2026-04-01
> Environment: macOS Darwin 25.2.0, Node 22+, Playwright 1.54.2
> Xcode: Command Line Tools only (no full Xcode / no Simulator runtime)

## Summary

| Tool | Status | Install | Notes |
|------|--------|---------|-------|
| Playwright mobile viewport | WORKS | Already installed | `--viewport-size` with chromium; `--device` needs webkit |
| Playwright dark mode | WORKS | Already installed | `--color-scheme dark` flag |
| xcrun simctl | NOT AVAILABLE | Needs full Xcode (~12GB) | Only CLT installed, no Simulator runtime |
| adb / Android emulator | NOT AVAILABLE | Needs Android SDK | Not installed |
| SF Symbols app | NOT INSTALLED | `brew install --cask sf-symbols` | macOS GUI app, no CLI export |
| sf-symbols-typescript | AVAILABLE (npm) | `npm i sf-symbols-typescript` | TypeScript types only — symbol name autocomplete, no SVGs |
| @bradleyhodges/sfsymbols | AVAILABLE (npm) | 46.7MB package | React components with actual icon data for Apple platforms |
| expo / react-native CLI | NOT AVAILABLE | Heavy install | No preview-only CLI tool exists |
| SVG device frames | WORKS | No install needed | Hand-craft or template SVG phone frames |
| style-dictionary | Already in registry | -- | Design token export for mobile (iOS/Android) |
| d2 | Already in registry | -- | Architecture diagrams, navigation flows |

## Detailed Findings

### 1. Playwright Mobile Viewport Simulation — RECOMMENDED

**Status: WORKS (primary tool for mobile UI design)**

The existing `html_screenshot` tool (Playwright) supports mobile simulation via viewport sizing and color scheme.

**Working command pattern:**
```bash
# iPhone 14 viewport
npx playwright screenshot -b chromium --viewport-size "390,844" "file:///path/to/mockup.html" output.png

# Dark mode
npx playwright screenshot -b chromium --viewport-size "390,844" --color-scheme dark "file:///path/to/mockup.html" output.png

# iPad Pro 11"
npx playwright screenshot -b chromium --viewport-size "834,1194" "file:///path/to/mockup.html" output.png
```

**Device viewport reference (for `--viewport-size` flag):**

| Device | Viewport | Use case |
|--------|----------|----------|
| iPhone SE | 375x667 | Small phone, compatibility |
| iPhone 14 | 390x844 | Standard iPhone |
| iPhone 14 Pro Max | 430x932 | Large iPhone |
| iPhone 15 Pro | 393x852 | Latest standard |
| iPad Mini | 768x1024 | Small tablet |
| iPad Pro 11" | 834x1194 | Standard tablet |
| iPad Pro 12.9" | 1024x1366 | Large tablet |
| Pixel 7 | 412x915 | Standard Android |
| Galaxy S23 | 360x780 | Samsung flagship |

**Limitation:** The `--device` flag (e.g., `--device "iPhone 14"`) requires WebKit browser which is not installed. The `--viewport-size` approach with Chromium is functionally equivalent for design mockups (sets correct dimensions). The only missing piece is the exact user-agent string, which doesn't affect visual rendering.

**Verified output:** iOS-style Settings screen rendered correctly at 390x844 with status bar, navigation bar, cards, and tab bar all rendering at appropriate mobile proportions.

### 2. SF Symbols — Reference Only (No CLI Export)

**Status: No CLI tool exists for SF Symbols**

Findings:
- **SF Symbols app** (`brew install --cask sf-symbols`): macOS GUI application for browsing/exporting. No CLI interface. Not installed on this machine.
- **sf-symbols-typescript** (npm): TypeScript type definitions only. Provides autocomplete for ~6,000 symbol names. No actual icon data/SVGs.
- **@bradleyhodges/sfsymbols** (npm, 46.7MB): React components with actual icon rendering for Apple platforms. Proprietary license. Heavy dependency.

**Recommendation for Domain Pack:**
- Embed a curated symbol name reference list (top 200 common symbols by category) directly in the domain pack config
- Claude can reference symbol names in design specs without needing the actual SVG
- For visual mockups, use Unicode equivalents or emoji approximations in HTML prototypes
- Example: `chevron.right` -> `>`, `gear` -> Unicode gear symbol, `person.fill` -> person emoji

### 3. xcrun simctl (iOS Simulator) — NOT AVAILABLE

**Status: Requires full Xcode installation**

```
$ xcrun simctl list devices
xcrun: error: unable to find utility "simctl", not a developer tool or in PATH
$ xcode-select -p
/Library/Developer/CommandLineTools
```

Only Command Line Tools are installed. The Simulator requires full Xcode (~12GB download + ~35GB disk after install). This is too heavy to recommend as a domain pack dependency.

**If full Xcode were installed, capabilities would include:**
- `xcrun simctl list devices` — list available simulators
- `xcrun simctl boot <device-id>` — start a simulator
- `xcrun simctl io <device-id> screenshot output.png` — capture screenshot
- `xcrun simctl openurl <device-id> <url>` — open URL in simulator Safari

**Recommendation:** Document as optional enhancement. Not required for design workflow — Playwright viewport simulation covers the visual design use case.

### 4. Android Emulator / ADB — NOT AVAILABLE

**Status: Android SDK not installed**

```
$ which adb
adb not found
```

Android Studio / SDK is not installed. Like Xcode, it's too heavy (~8GB) to recommend as a required dependency.

**Recommendation:** Document as unavailable. Playwright viewport simulation with Android device dimensions (Pixel 7: 412x915) is sufficient for design mockups.

### 5. React Native / Expo Preview — NO CLI Preview Tool

**Status: No standalone preview CLI exists**

Neither `expo` nor `react-native` CLI is installed. More importantly, there is no "preview-only" CLI tool in the React Native ecosystem. All preview requires either:
- A running Metro bundler + simulator/device
- Expo Go app on a physical device
- Storybook for React Native (requires full project setup)

**Recommendation:** Not suitable for domain pack. Use HTML/CSS mockups with Playwright for design preview.

### 6. SVG Device Frames — WORKS (Template Approach)

**Status: No install needed, use hand-crafted SVGs**

SVG device frames can be created as reusable templates and composited with screenshot content. Combined with `svgo` (already in registry) for optimization.

**Use case:** Wrap Playwright screenshots in device frames for presentation-quality mockups.

**Template approach:** Pre-built SVG templates for iPhone (notch, Dynamic Island), iPad, and Android devices stored in the domain pack.

## Recommended Tool Stack for Mobile UI Design Domain Pack

### Tier 1: Core (Already Available)
| Tool | Purpose | Command |
|------|---------|---------|
| **Playwright** (viewport mode) | Mobile UI screenshot with device dimensions | `npx playwright screenshot -b chromium --viewport-size "390,844"` |
| **Playwright** (dark mode) | Dark mode preview | Add `--color-scheme dark` flag |
| **d2** | Navigation flows, architecture diagrams | Already in registry |
| **style-dictionary** | Design tokens (iOS/Android export) | Already in registry |
| **svgo** | Optimize SVG assets | Already in registry |
| **pa11y** | Accessibility testing | Already in registry |

### Tier 2: Enhance (Light Install)
| Tool | Purpose | Install |
|------|---------|---------|
| **sf-symbols-typescript** | Symbol name reference/autocomplete | `npm i sf-symbols-typescript` (284KB) |

### Tier 3: Optional (Heavy Install, Document Only)
| Tool | Purpose | Install Size |
|------|---------|-------------|
| SF Symbols app | Visual symbol browser | ~100MB via brew cask |
| Full Xcode + Simulator | Native iOS preview | ~35GB |
| Android Studio + emulator | Native Android preview | ~8GB |

### Not Recommended
| Tool | Reason |
|------|--------|
| @bradleyhodges/sfsymbols | 46.7MB, Proprietary license, React-only |
| expo/react-native CLI | No standalone preview capability |

## Key Insight

**Playwright viewport simulation is the killer tool for mobile UI design in Claude Code.** It already works, requires no additional install, supports all device sizes via `--viewport-size`, handles dark mode via `--color-scheme`, and produces real screenshots that Claude can view and iterate on. The workflow is:

1. Claude generates HTML/CSS mobile mockup (using iOS/Android design system CSS)
2. Playwright screenshots at target device viewport
3. Claude views screenshot, iterates on design
4. Export final design specs with style-dictionary tokens

This covers 90%+ of mobile UI design needs without any native toolchain.
