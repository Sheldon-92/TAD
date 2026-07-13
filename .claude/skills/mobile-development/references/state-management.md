# State Management

State management for mobile — server cache, client state, persistent storage, secure storage.
Workflow shape: select → execute → verify → optimize.

## 1. Select state strategy

Categorize state for mobile (extra categories vs web):

1. **Server state** → React Query (TanStack Query) with offline cache
2. **Client state** → Zustand (lightweight, <1KB)
3. **Persistent state** → AsyncStorage for non-sensitive, Expo SecureStore for tokens/keys
4. **Form state** → react-hook-form + Zod
5. **Network state** → NetInfo listener (mobile-specific: detect online/offline)

Key difference from web: MUST handle offline gracefully. Document the strategy (state-strategy.md).

## 2. Execute state layer

1. React Query with persistQueryClient for offline cache
2. Zustand store in `src/lib/store/`
3. AsyncStorage wrapper in `src/lib/storage.ts`
4. SecureStore wrapper in `src/lib/secure-storage.ts`
5. Network listener: `useNetInfo()` hook, show offline banner

## 3. Verify state

1. `npx tsc --noEmit` → all state typed
2. Offline scenario: app works with cached data when network off
3. Sensitive data in SecureStore (not AsyncStorage)

## 4. Optimize for mobile

1. React Query `staleTime` tuned per resource (user profile: 5min, feed: 30s)
2. Zustand store sliced (separate UI store from data store)
3. AsyncStorage batch operations (`multiGet`/`multiSet`)

## Quality criteria (pass/fail)

- All state fully typed (no any)
- Offline support: app shows cached data when network unavailable
- Sensitive data in SecureStore, NOT AsyncStorage
- Network status monitored (NetInfo)
- Fabricated offline behavior or invented storage APIs = FAIL
