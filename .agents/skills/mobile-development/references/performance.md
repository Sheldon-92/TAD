# Performance

Mobile performance optimization — FlatList, images, startup, bundle size.
Workflow shape: select targets → execute → verify → optimize further.

## 1. Select optimization targets

Identify performance bottlenecks (from callstackincubator research):

1. **Lists**: FlatList with 100+ items → virtualization critical
2. **Images**: remote images without cache → flickering, memory crashes
3. **Startup**: too many imports at launch → slow cold start
4. **Bundle**: unused dependencies → large download size
5. **Animations**: JS thread animations → janky 30fps

Measure FIRST, then optimize. Use React DevTools Profiler + Flipper. Record a baseline (performance-baseline.md).

## 2. Execute optimizations

1. FlatList: `getItemLayout` + React.memo + `windowSize=5` + `keyExtractor`
2. Images: expo-image with `cachePolicy: 'disk'` (replace default Image)
3. Startup: lazy-load non-critical screens with React.lazy
4. Bundle: analyze with metro-visualizer, remove unused packages
5. Animations: react-native-reanimated (UI thread, 60fps)

## 3. Verify improvements

1. List scroll: 60fps on mid-range device (check with Profiler)
2. App startup: < 3s cold start on mid-range device
3. Bundle size: check with `npx expo export` output size
4. No memory leaks: monitor with Flipper/Instruments

Record results (performance-results.md).

## 4. Advanced optimizations (if needed)

1. Enable Hermes engine (default in Expo SDK ≥49)
2. Precompile bytecode for faster startup
3. Code splitting by route
4. Tree-shake unused expo-* modules

## Quality criteria (pass/fail)

- FlatList scroll at 60fps (no jank on mid-range device)
- Cold start < 3s on mid-range device
- Images use expo-image with caching (no flickering)
- No memory leaks in long sessions
- Fabricated performance numbers or invented benchmarks = FAIL. Measure, don't guess.
