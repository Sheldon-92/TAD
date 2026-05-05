# Accessibility Test Design — Menu Snap iOS

## Strategy: Two-Layer Coverage

| Layer | Coverage | Tools |
|-------|----------|-------|
| Automated (30-40%) | Static lint + RNTL queries | eslint-plugin-react-native-a11y, RNTL getByRole/getByLabelText |
| Manual (60-70%) | VoiceOver navigation, touch targets, dynamic type | Human tester with VoiceOver enabled |

## WCAG 2.2 AA Compliance Targets

| Criterion | Requirement | Menu Snap Specifics |
|-----------|-------------|---------------------|
| 1.1.1 Non-text Content | All images have alt text | Menu photos, dish images, dietary icons |
| 1.4.3 Contrast | >= 4.5:1 text, >= 3:1 large text | Especially camera overlay text on varying backgrounds |
| 2.5.5 Target Size | >= 44x44pt | Capture button, filter chips, favorite button |
| 4.1.2 Name/Role/Value | All interactive elements labeled | Dietary filter toggles, tab bar items |

## ESLint Configuration

```json
// .eslintrc.json (a11y rules)
{
  "plugins": ["react-native-a11y"],
  "rules": {
    "react-native-a11y/has-accessibility-props": "error",
    "react-native-a11y/has-valid-accessibility-role": "error",
    "react-native-a11y/has-valid-accessibility-state": "error",
    "react-native-a11y/has-valid-accessibility-value": "error",
    "react-native-a11y/has-valid-accessibility-actions": "error",
    "react-native-a11y/has-valid-accessibility-live-region": "warn",
    "react-native-a11y/no-nested-touchables": "error",
    "react-native-a11y/has-valid-accessibility-descriptors": "error",
    "react-native-a11y/has-valid-important-for-accessibility": "warn"
  }
}
```

### Run command:
```bash
npx eslint src/ --ext .tsx,.ts --rule 'react-native-a11y/has-accessibility-props: error'
```

## VoiceOver Manual Test Checklist

### Page 1: Camera Screen

| Element | accessibilityLabel | Focus Order | Action Hint | PASS/FAIL |
|---------|-------------------|-------------|-------------|-----------|
| Camera viewfinder | "Camera viewfinder, point at menu" | 1 | - | |
| Flash toggle | "Toggle flash, currently {off/on/auto}" | 2 | "Double tap to toggle" | |
| Capture button | "Take photo of menu" | 3 | "Double tap to capture" | |
| Gallery button | "Choose from photo library" | 4 | "Double tap to open" | |
| Guide text | "Align menu within the frame" | - | - (decorative after first use) | |

### Page 2: Results Screen

| Element | accessibilityLabel | Focus Order | Action Hint | PASS/FAIL |
|---------|-------------------|-------------|-------------|-----------|
| Back/retake button | "Take new photo" | 1 | "Double tap" | |
| Filter button | "Filter by dietary preferences, {N} active" | 2 | "Double tap to open filters" | |
| Menu card (each) | "{Original name}, {translated name}, {price}" | 3+ (sequential) | "Double tap for details" | |
| Dietary badge (each) | "Dietary: {type}" | Within card group | - | |
| Empty state | "No dishes match your filters" | - | - | |

### Page 3: Dish Detail

| Element | accessibilityLabel | Focus Order | Action Hint | PASS/FAIL |
|---------|-------------------|-------------|-------------|-----------|
| Back button | "Back to menu results" | 1 | "Double tap" | |
| Dish image | "{Dish name} photo" | 2 | - | |
| Dish name | "{Original} — {Translated}" | 3 | - | |
| Price | "Price: {amount}" | 4 | - | |
| Dietary badges | "Dietary information: {list}" | 5 | - | |
| AI recommendation | "AI recommendation: {text}" | 6 | - | |
| Favorite button | "Save to favorites" / "Remove from favorites" | 7 | "Double tap to toggle" | |

### Page 4: Dietary Filter Sheet

| Element | accessibilityLabel | Focus Order | Action Hint | PASS/FAIL |
|---------|-------------------|-------------|-------------|-----------|
| Sheet title | "Dietary filters" | 1 | - | |
| Vegetarian toggle | "Vegetarian filter, {on/off}" | 2 | "Double tap to toggle" | |
| Vegan toggle | "Vegan filter, {on/off}" | 3 | "Double tap to toggle" | |
| Gluten-free toggle | "Gluten-free filter, {on/off}" | 4 | "Double tap to toggle" | |
| Nut-free toggle | "Nut-free filter, {on/off}" | 5 | "Double tap to toggle" | |
| Apply button | "Apply filters" | 6 | "Double tap" | |
| Clear button | "Clear all filters" | 7 | "Double tap" | |

### Page 5: Favorites

| Element | accessibilityLabel | Focus Order | Action Hint | PASS/FAIL |
|---------|-------------------|-------------|-------------|-----------|
| Tab: Favorites | "Favorites tab, {N} saved dishes" | Tab bar | "Double tap" | |
| Favorite item (each) | "{Dish name}, {translated}, {price}" | Sequential | "Double tap for details, swipe left to remove" | |
| Empty state | "No saved dishes yet. Scan a menu to get started." | - | - | |

## Dynamic Type Testing

| Font Size | What to Check |
|-----------|---------------|
| Default | Baseline — everything should be correct |
| Large (accessibility) | Text wraps correctly, no truncation of critical info |
| Extra Large (accessibility) | Layout doesn't break, scrollable if needed |
| Maximum | App is still usable (may not be pretty, but functional) |

## Color & Contrast

| Element | Foreground | Background | Ratio (target >= 4.5:1) |
|---------|-----------|-----------|-------------------------|
| Menu card text | [ASSUMPTION] #1A1A1A | #FFFFFF | ~17:1 |
| Dietary badge text | #FFFFFF | varies by type | Must verify per badge color |
| Camera overlay text | #FFFFFF | Camera feed (varies) | Use text shadow/backdrop for guarantee |
| Price text | [ASSUMPTION] #333333 | #FFFFFF | ~12:1 |

**Camera overlay is the highest risk** — text over live camera feed has unpredictable contrast. Solution: semi-transparent dark backdrop behind all overlay text.
