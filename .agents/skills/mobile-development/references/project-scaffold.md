# Project Scaffold

Initialize a mobile project — Expo (default) / React Native CLI / Swift.
Workflow shape: select → execute → verify → optimize.

## 1. Select framework

Choose framework based on requirements:

1. **Expo (managed)** — default for most projects. Managed native modules, OTA updates, single codebase.
   - Choose when: standard features (camera, location, notifications), fast iteration, no custom native code.
2. **React Native CLI** — when custom native modules needed.
   - Choose when: Bluetooth, custom C++ modules, brownfield integration.
3. **Swift/SwiftUI** — iOS only.
   - Choose when: iOS-exclusive app, maximum native performance, Apple ecosystem deep integration.

Decision must tie to THIS project's requirements, not preference. Document the plan (scaffold-plan.md).

## 2. Execute scaffold (Expo default)

1. `npx create-expo-app@latest {project} --template blank-typescript`
2. Set up directory structure: `src/components/`, `src/screens/`, `src/hooks/`, `src/lib/`
3. Configure TypeScript strict mode
4. Install core dependencies: expo-router (if navigation needed)

## 3. Verify scaffold

1. `npx expo start` → Metro bundler starts without errors
2. `npx tsc --noEmit` → zero type errors
3. Check app.json has correct config (name, slug, version)

Record results (scaffold-verification.md).

## 4. Optimize scaffold

1. Enable New Architecture in app.json if Expo SDK ≥52 (`"newArchEnabled": true`) — ~30% smoother rendering from Fabric + TurboModules
2. Configure EAS Build for CI (eas.json)
3. Set up .env with expo-constants for environment variables

## Quality criteria (pass/fail)

- `npx expo start` → Metro bundler runs without errors
- `npx tsc --noEmit` → zero type errors
- Framework choice documented with project-specific reasoning
- TypeScript strict mode enabled
- New Architecture enabled (Expo SDK ≥52)
- Fabricated build results = FAIL

## Target output structure

```
{project}/
├── App.tsx              # Entry point
├── app.json             # Expo config
├── tsconfig.json        # TypeScript config
├── src/
│   ├── screens/         # Screen components
│   ├── components/      # Reusable components
│   ├── hooks/           # Custom hooks
│   ├── lib/
│   │   ├── api/         # API layer
│   │   ├── store/       # Zustand stores
│   │   ├── storage.ts   # AsyncStorage wrapper
│   │   └── secure-storage.ts  # SecureStore wrapper
│   └── navigation/      # Navigation config
├── assets/              # Images, fonts
└── eas.json             # EAS Build config
```

TAD planning/verification docs live under `.tad/active/mobile/{project}/` (scaffold-plan.md, component-plan.md, state-strategy.md, api-strategy.md, platform-features-plan.md, performance-baseline.md, quality-verification.md). Project code is scaffolded at the repository root.
