# Review Checklist

Reviewer personas + checklists for mobile development work. Use before Gate review
(Gate 2 design review, Gate 3/4 implementation and acceptance review) or whenever
reviewing mobile dev work.

## Reviewer personas by capability

### Project Scaffold — Mobile Architect
- Framework choice appropriate for requirements?
- New Architecture enabled?
- Directory structure follows conventions?

### Native Components — React Native Performance Expert
- FlatList optimized with getItemLayout?
- List items memoized?
- Images cached properly?

### State Management — Mobile Security Reviewer
- Sensitive data in SecureStore?
- Offline cache works?
- Network state handled?

### State Management — Offline Architecture Reviewer
- Offline-first pattern implemented?
- Cache invalidation strategy defined?
- Data conflicts handled on reconnect?

### API Integration — Mobile API Architect
- Offline-first architecture implemented?
- Mutations queue when offline?
- Error handling at every boundary?

### API Integration — Mobile Security Reviewer
- Auth tokens stored in SecureStore?
- API keys not in client bundle?
- Certificate pinning considered?

### Platform Features — Platform Integration Reviewer
- Permissions requested contextually?
- Denial handled gracefully?
- iOS privacy strings complete?

### Performance — Mobile Performance Engineer
- FlatList fully optimized?
- Image caching implemented?
- Startup time acceptable?

### Code Quality — Mobile Code Quality Reviewer
- Zero type errors?
- Zero lint errors?
- Both platforms tested?

## Gate 2 — Design checklist

- Framework choice documented (Expo/RN CLI/Swift)
- Component list with FlatList optimization plan
- State management strategy with offline handling
- Platform features identified with permission plan
- Performance optimization targets defined

## Gate 4 — Acceptance checklist

- `npx expo start` → no errors
- `npx tsc --noEmit` → zero type errors
- `npx eslint .` → zero lint errors
- Offline mode works (shows cached data)
- FlatList optimized (getItemLayout + memo)
- Permissions requested contextually
- No `any` types in codebase
