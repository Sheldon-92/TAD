# Unit Test Design — Menu Snap iOS

## Framework Stack

| Layer | Tool | Version |
|-------|------|---------|
| Test runner | Jest 30+ | Native TS support (no ts-jest needed) |
| Component testing | React Native Testing Library (RNTL) | Latest |
| Mocking | MSW for network, jest.mock for native modules | - |
| Coverage | Jest built-in (Istanbul) | - |

## Query Priority (RNTL official)

```
getByRole > getByLabelText > getByText > getByTestId
```

**Forbidden**: `getByType`, direct component instance access.

## Mock Strategy

| Dependency | Mock Approach |
|-----------|---------------|
| Camera module | `jest.mock('react-native-camera')` — returns static image URI |
| Navigation | `jest.mock('@react-navigation/native')` — mock `useNavigation`, `useRoute` |
| Translation API | MSW interceptor returning canned translations |
| AsyncStorage | `jest.mock('@react-native-async-storage/async-storage')` — in-memory map |
| Haptic feedback | `jest.mock('react-native-haptic-feedback')` — noop |

## Coverage Targets

| Module | Target | Rationale |
|--------|--------|-----------|
| Components (MenuCard, DietaryBadge, etc.) | >= 85% | Core UI, high change frequency |
| Hooks (useCamera, useTranslation, useFavorites) | >= 90% | Business logic containers |
| Utils (dietary-filter, price-format) | >= 95% | Pure functions, easy to test |
| Navigation / Screens | >= 60% | Integration-heavy, covered more by E2E |
| **Overall** | **>= 70%** | Balanced with E2E coverage |

## Test Files (co-located)

| Component | Test File |
|-----------|-----------|
| MenuCard | `src/components/__tests__/MenuCard.test.tsx` |
| DietaryBadge | `src/components/__tests__/DietaryBadge.test.tsx` |
| FavoriteButton | `src/components/__tests__/FavoriteButton.test.tsx` |
| TranslationText | `src/components/__tests__/TranslationText.test.tsx` |
| CameraOverlay | `src/components/__tests__/CameraOverlay.test.tsx` |

## Optimization Notes

- Snapshot tests: Only for stable layout components (DietaryBadge). NOT for dynamic components (MenuCard with API data).
- Edge cases to cover: empty arrays, null translation, very long dish names (30+ chars), network error states
- No shared mutable state between tests — each test sets up its own render context
