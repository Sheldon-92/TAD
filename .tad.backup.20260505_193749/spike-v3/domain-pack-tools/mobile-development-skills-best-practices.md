# Mobile Development Skills Best Practices — Research Summary

**Sources**: 4 GitHub repos + cursor rules + performance guides (2026-04-02 Blake research)

---

## Repositories Researched

| # | Repository | Key Strength |
|---|-----------|-------------|
| 1 | callstackincubator/agent-skills | Most comprehensive RN skills — profiling, FPS, re-render detection, list virtualization, bundle analysis |
| 2 | expo/skills | Official Expo team — building UI, data fetching, deployment, auto-discovery |
| 3 | PatrickJS/awesome-cursorrules (RN Expo) | Conventions — functional components, Expo Router, folder structure |
| 4 | filipemerker/flatlist-performance-tips + RN official docs | FlatList optimization — getItemLayout, windowSize, maxToRenderPerBatch |

---

## Capability: Project Scaffold
**Best practices**: Use Expo for most cases (managed workflow), RN CLI only for custom native modules. TypeScript mandatory. Expo Router for navigation (file-based).
**Folder structure**: assets/, src/components/, src/screens/, src/hooks/, src/lib/, App.tsx
**Anti-patterns**: ❌ Starting without TypeScript. ❌ Using React Navigation when Expo Router suffices.

## Capability: Native Components
**Best practices**: Functional components + hooks. StyleSheet.create() for styles. React.memo() for list items. Expo vector icons.
**Anti-patterns**: ❌ Inline styles. ❌ Class components. ❌ Direct DOM manipulation patterns from web.

## Capability: State Management
**Best practices**: Zustand or React Context for client state. React Query for server state. AsyncStorage for persistence. Expo SecureStore for sensitive data.
**Anti-patterns**: ❌ Redux for simple apps. ❌ Storing sensitive data in AsyncStorage (use SecureStore).

## Capability: API Integration
**Best practices**: React Query with offline cache. NetInfo for network status. Retry with exponential backoff. Typed responses.
**Anti-patterns**: ❌ Assuming always-online. ❌ No error handling for network failures.

## Capability: Platform Features
**Best practices**: expo-camera, expo-location, expo-notifications, expo-local-authentication. Always check/request permissions before use. Graceful degradation when denied.
**Anti-patterns**: ❌ Not handling permission denial. ❌ Requesting all permissions at app start (ask in context).

## Capability: Performance
**FlatList (critical)**: getItemLayout (highest impact — eliminates layout measurement), React.memo for items, keyExtractor, windowSize=5-7 (reduce from default 21), maxToRenderPerBatch=10, removeClippedSubviews=true (Android).
**Images**: expo-image with disk+memory caching.
**Architecture**: Enable New Architecture first (Fabric + TurboModules, ~30% smoother rendering).
**Anti-patterns**: ❌ Anonymous renderItem functions. ❌ Default windowSize=21 for simple lists. ❌ Not using getItemLayout for fixed-height items.

## Capability: Code Quality
**Tools**: ESLint + TypeScript strict + Expo CLI lint.
**Anti-patterns**: ❌ any types. ❌ Ignoring platform-specific issues. ❌ Not testing on both iOS and Android.
