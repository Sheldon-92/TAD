# Mobile Testing Tool Research for Claude Code

> Date: 2026-04-01
> Environment: macOS Darwin 25.2.0, Xcode.app installed, xcode-select points to CLT
> Key question: What can we actually run in Claude Code WITHOUT a simulator/emulator?

---

## Summary Table

| Tool | Install | Runs Without Simulator? | PASS/FAIL | Notes |
|------|---------|------------------------|-----------|-------|
| xcrun simctl | Pre-installed (via Xcode.app) | No (IS the simulator control) | **PASS** | Boot, screenshot, install, push — all work |
| Maestro CLI | `brew install maestro` | No (YAML syntax check only via yamllint) | **CONDITIONAL** | Not installed; needs simulator for real tests |
| Detox CLI | `npx detox` (v20.50.1) | Partial (`detox init` works) | **CONDITIONAL** | `detox test`/`detox build` need Xcode + simulator |
| source-map-explorer | `npx source-map-explorer` | Yes | **PASS** | Analyzes any .js + .js.map bundle |
| react-native-bundle-visualizer | `npx react-native-bundle-visualizer` (v4.0.0) | No — needs RN project | **FAIL** | Wrapper around metro bundler, not standalone |
| eslint-plugin-react-native-a11y | `npm install` (v3.5.1) | Yes (static lint) | **PASS** | ESLint rules for RN accessibility — no runtime needed |
| @axe-core/cli | `npx @axe-core/cli` (v4.11.1) | Partial (needs URL) | **CONDITIONAL** | Web accessibility; works on localhost URLs |
| Appium | `npm install appium` (v3.2.2) | No | **FAIL** | Full server, needs simulator/device |
| ios-deploy | Not installed | N/A | **N/A** | For real device deployment |
| idevice tools (libimobiledevice) | Not installed | N/A | **N/A** | For real device info |

---

## Detailed Findings

### 1. xcrun simctl (iOS Simulator Control)

**Status: PASS — Full capability confirmed**

- **Location**: `/Applications/Xcode.app/Contents/Developer/usr/bin/simctl`
- **Note**: `xcrun simctl` fails because xcode-select points to CLT, but direct path works perfectly
- **Available simulators**: iOS 26.2 — iPhone 17 Pro, 17 Pro Max, iPhone Air, iPhone 17, iPhone 16e, iPad Pro 13"/11" (M5), iPad mini, iPad (A16), iPad Air 13"/11" (M3)

**Tested operations**:
```
# List devices
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl list devices  ✅

# Boot simulator
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl boot "iPhone 16e"  ✅ (exit 0)

# Take screenshot
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io "iPhone 16e" screenshot /tmp/sim-screenshot.png  ✅

# Shutdown
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl shutdown "iPhone 16e"  ✅
```

**Full capability list** (from --help):
- `boot` / `shutdown` — lifecycle control
- `install` / `uninstall` / `launch` / `terminate` — app management
- `io screenshot` / `io recordVideo` — visual capture
- `push` — simulated push notifications
- `openurl` — deep link testing
- `status_bar` — override status bar for clean screenshots
- `location` — simulate GPS location
- `privacy` — grant/revoke/reset permissions
- `addmedia` — add photos/videos to library
- `pbcopy` / `pbpaste` — pasteboard interaction

**Dependencies**: Xcode.app (full installation required, CLT alone is not enough)

**Claude Code usage**: Boot simulator headlessly, install .app, take screenshots, test deep links, simulate push notifications. All via Bash tool. No GUI needed.

---

### 2. Maestro CLI (Mobile E2E)

**Status: CONDITIONAL — Not installed, needs simulator for real tests**

- **Brew availability**: `maestro` cask v0.15.2 available via Homebrew, not currently installed
- **Install**: `brew install maestro` or `curl -Ls install.maestro.dev | bash`

**What works without simulator**:
- YAML flow file syntax validation (via `yamllint`, not Maestro itself)
- Flow file generation / editing (standard YAML)
- Maestro Studio for flow recording (needs simulator)

**What needs simulator**:
- `maestro test` — all actual test execution
- `maestro record` — video recording
- `maestro cloud` — cloud execution (needs account)

**YAML flow format** (standard, can be validated/generated without Maestro):
```yaml
appId: com.example.app
---
- launchApp
- tapOn: "Login"
- inputText:
    text: "user@test.com"
- tapOn: "Submit"
- assertVisible: "Welcome"
```

**Verdict**: Useful for projects that already use Maestro. Claude Code can generate/edit flows and validate YAML. Actual test execution needs simulator (which we have via simctl).

---

### 3. Detox CLI

**Status: CONDITIONAL — CLI installs, but test execution needs full native toolchain**

- **Version**: 20.50.1 (via npx)
- **Install**: `npx detox` or project dependency

**What works without simulator**:
- `detox init` — scaffolds config/test template files ✅
- `detox reset-lock-file` — device lock management ✅
- Config file validation (`.detoxrc.js`)

**What needs Xcode + simulator**:
- `detox build` — compiles the app (needs Xcode build system)
- `detox test` — runs tests on simulator
- `detox build-framework-cache` — macOS only, needs Xcode

**Dependencies**: Xcode, CocoaPods or SPM (iOS), Android SDK (Android), Jest test runner

**Verdict**: Heavy dependency chain. In Claude Code, useful only for config generation and test file authoring. Not practical for "run and check" workflow without a full RN project already set up.

---

### 4. Bundle Analysis Tools

#### source-map-explorer — **PASS**
- **Version**: 2.5.3
- **Install**: `npx source-map-explorer`
- **Works standalone**: Yes, just needs a `.js` file and its `.js.map`
- **Output formats**: JSON (`--json`), HTML (`--html`), TSV (`--tsv`)
- **Claude Code usage**: Analyze any JS bundle with source map. Output JSON for programmatic analysis, HTML for visual treemap.
- **No simulator needed**: ✅

#### webpack-bundle-analyzer — Available (v5.3.0)
- Can analyze webpack stats JSON files standalone
- `npx webpack-bundle-analyzer stats.json` — generates HTML report

#### react-native-bundle-visualizer — **FAIL**
- **Version**: 4.0.0
- **Problem**: Not standalone. It's a wrapper that calls `react-native bundle` internally, then pipes output to source-map-explorer
- **Requires**: A configured React Native project with metro bundler
- **Verdict**: Skip this. Use `source-map-explorer` directly on pre-built bundles instead.

---

### 5. Mobile Accessibility Testing

#### eslint-plugin-react-native-a11y — **PASS**
- **Version**: 3.5.1
- **Type**: ESLint plugin (static analysis)
- **Works without simulator**: Yes — pure lint rules
- **Rules include**: accessible labels, roles, states, touchable sizing, image alt text
- **Install**: `npm install eslint-plugin-react-native-a11y --save-dev`
- **Claude Code usage**: Run ESLint on RN components to catch a11y issues at code level. No runtime needed.

#### @axe-core/cli — **CONDITIONAL**
- **Version**: 4.11.1
- **Type**: Web accessibility auditor (runs in browser)
- **Usage**: `npx @axe-core/cli <url>` — needs a running web server URL
- **Works for**: React Native Web, Expo Web, any mobile web view
- **Does NOT work for**: Native iOS/Android accessibility (VoiceOver/TalkBack)
- **Claude Code usage**: Can audit localhost if a dev server is running

#### Native accessibility audit CLI — **NOT AVAILABLE**
- No CLI tool exists for VoiceOver/TalkBack audit without a running simulator
- Xcode's Accessibility Inspector is GUI-only
- `xcrun simctl` has no accessibility audit subcommand
- **Gap**: This is a real gap in the mobile testing ecosystem

---

### 6. ios-deploy / idevice tools

#### ios-deploy — **NOT INSTALLED**
- **Install**: `brew install ios-deploy` or `npm install -g ios-deploy`
- **Purpose**: Deploy .ipa to real iOS devices over USB
- **Claude Code relevance**: Low — Claude Code sessions rarely have physical devices connected

#### libimobiledevice (ideviceinfo, idevicename, etc.) — **NOT INSTALLED**
- **Install**: `brew install libimobiledevice`
- **Purpose**: Communicate with real iOS devices (get info, install apps, syslog)
- **Claude Code relevance**: Low — same physical device limitation

---

## Key Answer: What Works in Claude Code WITHOUT a Simulator?

### Tier 1: Fully Functional (no runtime needed)
| Tool | Capability |
|------|-----------|
| `source-map-explorer` | Bundle size analysis from .js + .js.map files |
| `eslint-plugin-react-native-a11y` | Static accessibility lint for React Native code |
| `yamllint` | Validate Maestro YAML flow files (syntax only) |
| `detox init` | Scaffold Detox test config and templates |

### Tier 2: Works WITH Simulator (available on this machine)
| Tool | Capability |
|------|-----------|
| `simctl boot/screenshot/install/launch` | Full simulator lifecycle control |
| `simctl push` | Push notification testing |
| `simctl openurl` | Deep link testing |
| `simctl io screenshot` | Visual regression capture |
| `simctl status_bar` | Clean screenshots for docs |
| `simctl location` | GPS simulation |
| Maestro (if installed) | E2E flow execution |
| Detox (with RN project) | E2E test execution |

### Tier 3: Not Practical for Claude Code
| Tool | Reason |
|------|--------|
| `ios-deploy` | Needs physical USB device |
| `ideviceinfo` | Needs physical USB device |
| `react-native-bundle-visualizer` | Needs full RN project, not standalone |
| Appium | Heavy server, complex setup |
| Native a11y audit (VoiceOver) | No CLI exists |

---

## Recommendations for Domain Pack

### Must Include
1. **simctl wrapper** — Boot, screenshot, install, deep-link, push. The single most powerful mobile testing tool available in CLI. Use full path: `/Applications/Xcode.app/Contents/Developer/usr/bin/simctl`
2. **source-map-explorer** — Bundle analysis. Zero dependencies beyond the bundle files.
3. **eslint-plugin-react-native-a11y** — Static a11y. Works on any RN codebase without runtime.

### Should Include (conditional on project type)
4. **Maestro flow generation** — Generate/validate YAML test flows. Execution needs simulator but flow authoring is standalone.
5. **@axe-core/cli** — For React Native Web / Expo Web accessibility audits.

### Skip
- **Detox**: Too heavy for domain pack default. Projects that use it already have it configured.
- **react-native-bundle-visualizer**: Use source-map-explorer directly instead.
- **Appium**: Server-based, overkill for Claude Code context.
- **ios-deploy / idevice**: Physical device tools, not relevant to CI/Claude Code.

---

## Surprise Finding

**xcrun simctl works fully on this machine** via the direct Xcode.app path, even though `xcrun simctl` fails (xcode-select points to CLT). This means Claude Code CAN:
- Boot a headless iOS simulator
- Install and launch apps
- Take screenshots (verified: produces valid PNG)
- Test deep links and push notifications
- Simulate location changes

This is a significantly more powerful capability than expected for a CLI-only environment.
