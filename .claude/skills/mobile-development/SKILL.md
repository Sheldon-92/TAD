---
name: mobile-development
description: "Mobile development capability pack. Covers Expo/React Native/Swift framework selection, native UI components, offline-first state and API architecture, platform features (camera, location, notifications, biometrics), mobile performance optimization, and mobile code quality. Use for any mobile app development, React Native/Expo build, offline-first architecture, or mobile performance task."
version: 0.1.0
type: reference-based
keywords: ["mobile development", "移动开发", "React Native", "Expo", "Swift", "SwiftUI", "iOS", "Android", "移动应用", "app", "offline-first", "离线优先", "FlatList", "性能优化", "移动端", "推送通知", "权限", "EAS Build", "AsyncStorage", "SecureStore"]
---

# Mobile Development Capability Pack

> Cross-agent portable judgment for mobile development — from design to running mobile app: scaffold, implement, optimize, ship. Covers React Native/Expo/Swift, offline-first architecture, platform permissions, and performance optimization.
> **CONSUMES**: Requirements/design docs, optional OpenAPI spec for typed responses.
> **PRODUCES**: A runnable mobile project (Expo default) with `src/screens/`, `src/components/`, `src/hooks/`, `src/lib/` structure, plus TAD planning/verification docs per capability.

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| new app, init project, scaffold, create-expo-app, framework choice, Expo vs RN CLI vs Swift, 新建应用 | `references/project-scaffold.md` |
| screen, component, navigation, list, form, gesture, styling, UI 组件, 导航, 列表 | `references/native-components.md` |
| state, store, Zustand, React Query, AsyncStorage, SecureStore, token storage, 状态管理, 存储 | `references/state-management.md` |
| API, fetch, mutation, offline sync, retry, network error, 接口, 离线 | `references/api-integration.md` |
| camera, location, GPS, push notification, biometrics, Face ID, permission, 相机, 定位, 通知, 权限 | `references/platform-features.md` |
| slow, jank, fps, startup time, bundle size, memory leak, profiling, 性能, 卡顿 | `references/performance.md` |
| lint, type-check, ESLint, Prettier, CI, pre-commit, platform compatibility, 代码质量 | `references/code-quality.md` |
| before Gate review, reviewing mobile dev work, acceptance check, Gate 2/Gate 4 for a mobile task, 验收 | `references/review-checklist.md` |

**Multi-signal**: Load all matched references. Each reference carries step-level procedures, commands, quality criteria (pass/fail), and reviewer focus for its capability.

---

## Step 2: Decision Entry Point — Framework Selection

**Q1 — Which framework?** Decision must tie to THIS project's requirements, not preference:
- **Expo (managed)** — default for most projects. Managed native modules, OTA updates, single codebase. Choose when: standard features (camera, location, notifications), fast iteration, no custom native code.
- **React Native CLI** — only when custom native modules needed. Choose when: Bluetooth, custom C++ modules, brownfield integration.
- **Swift/SwiftUI** — iOS only. Choose when: iOS-exclusive app, maximum native performance, Apple ecosystem deep integration.

Document the choice with project-specific reasoning (a Gate 2 checklist item).

**Q2 — Does the app need network data?**
- Yes → offline-first is MANDATORY, not optional: load `references/state-management.md` + `references/api-integration.md`. Key difference from web: the app MUST handle offline gracefully.

**Q3 — Does the app use device capabilities (camera/location/notifications/biometrics/files)?**
- Yes → load `references/platform-features.md` BEFORE writing the permission flow.

---

## Step 3: Core Judgment Rules (always apply)

These constraints hold regardless of which reference is loaded:

1. **TypeScript strict mode from day one** — never start without TypeScript; no `any` types, no `@ts-ignore`, no `// eslint-disable` without justification.
2. **Enable New Architecture** in app.json when Expo SDK ≥52 (`"newArchEnabled": true`) — ~30% smoother rendering from Fabric + TurboModules.
3. **FlatList, never ScrollView, for long lists** (>20 items). Items wrapped in `React.memo`, `renderItem` extracted to a named component, `getItemLayout` for fixed-height items (highest-impact optimization), windowSize 5-7 (NOT the default 21).
4. **StyleSheet.create() only** — zero inline styles. Functional components + hooks only; no class components.
5. **Sensitive data (tokens/keys) in Expo SecureStore, NEVER AsyncStorage.** AsyncStorage is for non-sensitive persistent state only.
6. **Remote images via expo-image with caching** — never the default Image component, never fetch images through the API layer.
7. **Permissions requested IN CONTEXT** (when the user needs the feature), never all at app launch. Permission denial must be handled gracefully — no crash, show a helpful message. iOS NSUsageDescription strings present for every used permission (missing = App Store rejection).
8. **Mutations must handle failure** — no fire-and-forget. Offline: queue mutations, replay on reconnect. Transient network errors: retry with exponential backoff.
9. **Monitor network state** (NetInfo listener + offline banner). App shows cached data when the network is unavailable.
10. **Animations on the UI thread** via react-native-reanimated (60fps) — never JS-thread animations (janky 30fps).
11. **Measure FIRST, then optimize** — never optimize without profiling (React DevTools Profiler + Flipper). Test on mid-range devices, not only high-end.
12. **Platform-specific code needs a Platform.OS guard**, and both iOS AND Android must be tested — never one platform only.
13. **Fabricated results = FAIL** — fabricated build results, component APIs, offline behavior, permission APIs, performance numbers, or lint results fail the capability's quality gate. Measure, don't guess.

---

## Quick Rule Index

### Project Scaffold (`references/project-scaffold.md`)
- Framework decision criteria (Expo / RN CLI / Swift) + scaffold commands (`npx create-expo-app`) → directory structure, strict TS, expo-router
- Verify: `npx expo start` clean + `npx tsc --noEmit` zero errors; post-scaffold: New Architecture, EAS Build config, .env via expo-constants

### Native Components (`references/native-components.md`)
- Per-element strategy: Expo Router (file-based, recommended) or React Navigation; FlatList; react-hook-form + Zod; react-native-gesture-handler
- File conventions: one file per screen, typed props, named exports, `function` keyword, styles at file bottom

### State Management (`references/state-management.md`)
- 5-way state split: server (React Query + offline cache) / client (Zustand) / persistent (AsyncStorage vs SecureStore) / form (react-hook-form + Zod) / network (NetInfo)
- Tuning: staleTime per resource, sliced stores, AsyncStorage batch ops (multiGet/multiSet)

### API Integration (`references/api-integration.md`)
- Offline-first layer: React Query caching/retry/background refetch, optimistic updates, mutation queue persisted to AsyncStorage, NetInfo fetch policy
- Optimization: prefetch on start, background refetch intervals, request deduplication

### Platform Features (`references/platform-features.md`)
- Module map: expo-camera / expo-location / expo-notifications / expo-local-authentication / expo-file-system
- Permission flow: check → request → handle denial; app.json plugins; iOS NSUsageDescription; battery-saving location mode

### Performance (`references/performance.md`)
- 5 bottleneck classes: lists, images, startup, bundle, animations — with targets (60fps scroll, <3s cold start on mid-range device)
- Advanced: Hermes (default SDK ≥49), bytecode precompile, route code splitting, tree-shaking expo-* modules

### Code Quality (`references/code-quality.md`)
- Toolchain: strict tsc + ESLint (@react-native/eslint-config) + Prettier + Metro clean start; all four must pass
- CI: husky + lint-staged pre-commit; tsc + eslint + expo export on PR; iOS + Android test matrix

### Review Checklist (`references/review-checklist.md`)
- Reviewer personas + checklists for all 7 capabilities (Mobile Architect, RN Performance Expert, Mobile Security Reviewer, Offline Architecture Reviewer, Mobile API Architect, Platform Integration Reviewer, Mobile Performance Engineer, Mobile Code Quality Reviewer)
- Gate 2 design checklist + Gate 4 acceptance checklist

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll just use React Native CLI to be safe" | MUST justify against the framework criteria in `project-scaffold.md` — RN CLI without a custom-native-module need is unnecessary complexity |
| "ScrollView works fine here" | MUST use FlatList for lists >20 items with the optimization props in `native-components.md` |
| "Token in AsyncStorage for now, migrate later" | MUST use SecureStore from the start — see `state-management.md` |
| "Offline support can come in v2" | MUST design offline-first from the start — queued mutations and cache policy are architectural, see `api-integration.md` |
| "Request all permissions at startup, simpler" | MUST request in context with graceful denial handling — see `platform-features.md` |
| "It feels faster now" | MUST profile before/after and verify against the measurable targets in `performance.md` — fabricated numbers = FAIL |
| "Tested on my iPhone, ship it" | MUST test both iOS and Android, on mid-range devices — see `code-quality.md` and `performance.md` |
| "Skipping the reviewer checklists, code looks good" | Before Gate review of mobile work, MUST run the persona checklists in `review-checklist.md` |

---

## Anti-Patterns

### Project Scaffold
- ❌ Using RN CLI when Expo managed suffices (unnecessary complexity)
- ❌ Starting without TypeScript
- ❌ Not enabling New Architecture (missing ~30% perf gain)
- ❌ Flat directory without src/ separation

### Native Components
- ❌ ScrollView for long lists (must use FlatList)
- ❌ Inline styles (style={{color: 'red'}})
- ❌ Anonymous renderItem in FlatList (extract + memo)
- ❌ Default Image component for remote images (use expo-image)
- ❌ Class components

### State Management
- ❌ Storing tokens in AsyncStorage (use SecureStore)
- ❌ No offline handling (app crashes without network)
- ❌ Not monitoring network state
- ❌ Single monolithic store (split by concern)

### API Integration
- ❌ No offline handling (app broken without network)
- ❌ Fire-and-forget mutations (must handle failure)
- ❌ Fetching images via API (use expo-image cache)
- ❌ No retry logic for transient network errors

### Platform Features
- ❌ Requesting all permissions at app launch
- ❌ App crashes when permission denied
- ❌ Missing iOS usage description strings (App Store rejection)
- ❌ Always-on location tracking (kills battery)

### Performance
- ❌ Default windowSize=21 for FlatList (reduce to 5-7)
- ❌ Default Image for remote images (use expo-image)
- ❌ JS thread animations (use reanimated for UI thread)
- ❌ Optimizing without profiling first
- ❌ Not testing on mid-range devices (only high-end)

### Code Quality
- ❌ any types
- ❌ // eslint-disable without justification
- ❌ @ts-ignore
- ❌ Platform-specific code without Platform.OS guard
- ❌ Testing only on one platform
