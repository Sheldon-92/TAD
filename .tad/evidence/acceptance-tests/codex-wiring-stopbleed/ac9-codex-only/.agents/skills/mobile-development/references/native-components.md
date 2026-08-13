# Native Components

Implement mobile-native UI components — navigation, lists, forms, gestures.
Workflow shape: select → execute → verify → optimize.

## 1. Select component strategy

For each UI element, decide approach:

1. **Navigation**: Expo Router (file-based, recommended) or React Navigation
2. **Lists**: FlatList with optimization props (NOT ScrollView for long lists)
3. **Forms**: react-hook-form + Zod (same as web, cross-platform)
4. **Gestures**: react-native-gesture-handler for complex gestures
5. **Styling**: StyleSheet.create() — NOT inline styles

Use React.memo() for list items. Functional components + hooks only. Document the plan (component-plan.md).

## 2. Execute components

1. Screens in `src/screens/` — one file per screen
2. Reusable components in `src/components/` — typed props, named exports
3. Use `function` keyword for components (from cursorrules research)
4. FlatList items: React.memo(), extract renderItem to named component
5. Styles: StyleSheet.create() at file bottom, not inline

## 3. Verify components

1. `npx tsc --noEmit` → zero errors
2. All components have TypeScript interfaces for props
3. No inline styles (all via StyleSheet.create)
4. FlatList items wrapped in React.memo

## 4. Optimize for mobile

1. FlatList: add `getItemLayout` for fixed-height items (highest impact optimization)
2. FlatList: `windowSize`=5-7, `maxToRenderPerBatch`=10, `removeClippedSubviews` (Android)
3. Images: use expo-image with caching (NOT default Image component)
4. Animations: use react-native-reanimated for 60fps (runs on UI thread)

## Quality criteria (pass/fail)

- All components typed with TypeScript interfaces
- FlatList used for all lists >20 items (NOT ScrollView)
- FlatList items use React.memo + getItemLayout
- Styles via StyleSheet.create (zero inline styles)
- Navigation configured with Expo Router or React Navigation
- Fabricated component APIs or invented native module behavior = FAIL
