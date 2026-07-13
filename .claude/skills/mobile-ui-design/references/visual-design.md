# Mobile Visual Design (Platform-Native Color / Type / Icon Systems + Tokens)

## Workflow

### Layer 1 — Research visual references
Web search:
1. Comparable apps' visual styles in the target domain
2. Apple 系统颜色 / Material 3 Dynamic Color references
3. Current mobile design trends

Example queries:
- `"{领域}" iOS app visual design color scheme 2026`
- `"Material You" dynamic color theme design`

Output: `visual-research.md`.

### Layer 2 — Define the visual system (platform-native, never invented)
1. **色彩系统**
   - iOS: 语义系统颜色（systemBlue, systemRed, label, secondaryLabel, systemBackground, secondarySystemBackground）+ 1 个品牌色
   - Android: Material 3 Color Scheme（primary, onPrimary, primaryContainer, secondary, surface, background）
2. **字体系统**
   - iOS: SF Pro（11 种 Dynamic Type style，必须支持 Dynamic Type 缩放）
   - Android: Roboto（15 种 Material Typography tokens）
3. **图标系统**
   - iOS: SF Symbols（weight 匹配文本 weight；rendering mode: monochrome/hierarchical/palette/multicolor）
   - Android: Material Icons（Outlined / Rounded / Sharp / Two-tone）
4. **间距系统**: 8pt 网格（iOS/Android 共用）
5. **暗色模式**
   - iOS: 使用 Elevated 背景色（不是简单反转；iOS 暗色模式有 3 级灰度）
   - Android: 使用 Surface tones（不是纯黑）

Quality bar: color/type/icons all use the platform-native system, never self-invented; dark mode is designed, not derived. Append to `visual-research.md`.

### Layer 3 — Derive Design Tokens (JSON)
Tokens must distinguish iOS vs Android system values. Template:

```json
{
  "color": {
    "primary": {"ios": "systemBlue", "android": "#6750A4", "hex": "#007AFF"},
    "background": {"ios": "systemBackground", "android": "surface"},
    "text": {"ios": "label", "android": "onSurface"},
    "textSecondary": {"ios": "secondaryLabel", "android": "onSurfaceVariant"},
    "error": {"ios": "systemRed", "android": "error"}
  },
  "typography": {
    "largeTitle": {"ios": "34pt Regular", "android": "57sp Display Large"},
    "title": {"ios": "28pt Regular", "android": "32sp Headline Large"},
    "body": {"ios": "17pt Regular", "android": "16sp Body Large"},
    "caption": {"ios": "12pt Regular", "android": "12sp Body Small"}
  },
  "spacing": {"xs": "4pt", "sm": "8pt", "md": "16pt", "lg": "24pt", "xl": "32pt"},
  "radius": {"sm": "10pt", "md": "13pt", "lg": "20pt"},
  "touchTarget": {"ios": "44pt", "android": "48dp"}
}
```

Verify ALL text-background contrast ratios ≥ 4.5:1. Output: `design-tokens.json`.

### Layer 4 — Generate artifacts
- Style Dictionary → CSS variables for HTML prototypes: `design-tokens.css`
- Mobile style guide PDF (Typst): 色彩板 + 字体层级 + 图标规范 + 暗色模式 → `mobile-style-guide.pdf`

## Quality Criteria (pass/fail)
- 使用平台原生色彩系统（iOS systemColor / Material Color Scheme）
- 支持 Dynamic Type 缩放（iOS）或 Material Typography（Android）
- 图标使用 SF Symbols（iOS）或 Material Icons（Android），不用自定义 PNG
- 有暗色模式设计（不是简单颜色反转）
- 对比度 ≥ 4.5:1（WCAG AA）
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
