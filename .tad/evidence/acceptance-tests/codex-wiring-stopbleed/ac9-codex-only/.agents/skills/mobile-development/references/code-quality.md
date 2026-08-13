# Code Quality

Code quality for mobile — lint, type-check, platform compatibility.
Workflow shape: select tools → execute checks → verify → optimize.

## 1. Select quality tools

Configure the quality toolchain:

1. **TypeScript**: strict mode (same as web)
2. **ESLint**: @react-native/eslint-config
3. **Prettier**: consistent formatting
4. **Platform compatibility**: test on both iOS and Android

Document config (quality-config.md).

## 2. Execute quality checks

Run all checks:

1. `npx tsc --noEmit` → zero type errors
2. `npx eslint .` → zero lint errors
3. `npx prettier --check .` → zero formatting issues
4. `npx expo start` → Metro bundler starts clean

Record the audit (quality-audit.md).

## 3. Verify quality

1. All four checks pass
2. No `any` types in codebase
3. No platform-specific code without `Platform.OS` check
4. StyleSheet.create used everywhere (no inline)

## 4. Optimize

1. Add pre-commit hook (husky + lint-staged)
2. CI pipeline: tsc + eslint + expo export on PR
3. Platform test matrix: iOS + Android in CI

## Quality criteria (pass/fail)

- `npx tsc --noEmit` = 0 errors
- `npx eslint .` = 0 errors
- `npx prettier --check .` = 0 issues
- `npx expo start` = no errors
- No `any` types
- `Platform.OS` used for platform-specific code
- Fabricated lint results or suppressed errors = FAIL
