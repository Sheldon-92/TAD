# API Integration

API calls with offline-first architecture — cache, retry, network awareness.
Workflow shape: select → execute → verify → optimize.

## 1. Select API strategy

Design the API layer for mobile (offline-first):

1. React Query as data layer (caching, retry, background refetch)
2. Optimistic updates for mutations (instant UI feedback)
3. Queue mutations when offline, replay on reconnect
4. NetInfo-based fetch policy: online → network, offline → cache
5. Typed responses from OpenAPI spec if available

Document the strategy (api-strategy.md).

## 2. Execute API layer

1. API client in `src/lib/api/` with typed fetch wrappers
2. React Query hooks in `src/hooks/use{Resource}.ts`
3. Mutation queue in `src/lib/mutation-queue.ts` (persist to AsyncStorage)
4. Offline banner component triggered by NetInfo
5. Retry with exponential backoff for transient failures

## 3. Verify API layer

1. `npx tsc --noEmit` → all API calls typed
2. Every fetch has error handling
3. Offline: mutations queued, replayed on reconnect
4. Loading states for all async operations

## 4. Optimize

1. Prefetch critical data on app start
2. Background refetch interval for frequently updated data
3. Request deduplication (React Query built-in)
4. Image URLs: use expo-image cache, not fetch

## Quality criteria (pass/fail)

- All API responses typed (no any)
- Offline: mutations queued and replayed
- Every fetch has error handling + loading state
- Retry with backoff for network errors
- Fabricated API responses or invented offline behavior = FAIL
