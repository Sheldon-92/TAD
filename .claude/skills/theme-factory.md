# Theme Factory Skill

---
title: "Theme Factory"
version: "3.0"
last_updated: "2026-01-06"
tags: [theme, colors, design-system, accessibility, dark-mode]
domains: [frontend, design]
level: intermediate
estimated_time: "35min"
prerequisites: [css]
sources:
  - "WCAG 2.1 Guidelines"
  - "Material Design Color System"
  - "Tailwind CSS Documentation"
enforcement: recommended
tad_gates: [Gate2_Design, Gate4_Review]
---

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架和 WCAG 可访问性标准

## TL;DR Quick Checklist

```
1. [ ] Define primary, secondary, and semantic colors
2. [ ] Generate full color scales (50-950)
3. [ ] Verify contrast ratios (AA minimum: 4.5:1)
4. [ ] Test with color blindness simulators
5. [ ] Implement dark mode with CSS variables
6. [ ] Document color tokens in design system
```

**Red Flags:**
- Text contrast below 4.5:1
- No dark mode support
- Hardcoded color values instead of variables
- Red/green only indicators (color blind issue)
- No semantic color mapping (success, error, warning)

---

## 触发条件

当用户需要创建配色方案、设计系统主题、生成品牌色彩或构建 UI 主题时，自动应用此 Skill。

---

## 核心能力

```
主题工厂工具箱
├── 配色生成
│   ├── 色轮理论
│   ├── 情感配色
│   └── 品牌配色
├── 主题系统
│   ├── 明暗模式
│   ├── 语义化颜色
│   └── 色阶生成
├── 设计令牌
│   ├── CSS 变量
│   ├── Tailwind 配置
│   └── 设计系统导出
└── 可访问性
    ├── 对比度检查
    ├── 色盲友好
    └── WCAG 合规
```

---

## 色彩理论基础

### 色轮配色法

```
┌────────────────────────────────────────────────────┐
│                    色轮 (Color Wheel)               │
│                                                    │
│                    红 (0°/360°)                     │
│                        ●                           │
│               橙●           ●品红                   │
│                                                    │
│          黄●                     ●紫               │
│                                                    │
│              黄绿●         ●蓝紫                   │
│                        ●                           │
│                    青 (180°)                       │
└────────────────────────────────────────────────────┘
```

### 配色方案类型

| 类型 | 描述 | 适用场景 |
|------|------|----------|
| 单色 (Monochromatic) | 同色相不同明度 | 简约、统一 |
| 互补 (Complementary) | 色轮对面两色 | 高对比、活力 |
| 分裂互补 (Split-Complementary) | 互补色的相邻色 | 平衡、和谐 |
| 三元 (Triadic) | 色轮等距三色 | 丰富、平衡 |
| 四元 (Tetradic) | 色轮等距四色 | 复杂、多样 |
| 类似 (Analogous) | 色轮相邻颜色 | 自然、舒适 |

---

## 配色方案生成

### JavaScript 配色工具

```javascript
// HSL 颜色工具类
class ColorFactory {
  // 单色方案
  static monochromatic(hue, count = 5) {
    const colors = [];
    for (let i = 0; i < count; i++) {
      const lightness = 20 + (60 / (count - 1)) * i;
      colors.push(`hsl(${hue}, 70%, ${lightness}%)`);
    }
    return colors;
  }

  // 互补色方案
  static complementary(hue) {
    return {
      primary: `hsl(${hue}, 70%, 50%)`,
      complement: `hsl(${(hue + 180) % 360}, 70%, 50%)`
    };
  }

  // 三元色方案
  static triadic(hue) {
    return {
      primary: `hsl(${hue}, 70%, 50%)`,
      secondary: `hsl(${(hue + 120) % 360}, 70%, 50%)`,
      tertiary: `hsl(${(hue + 240) % 360}, 70%, 50%)`
    };
  }

  // 类似色方案
  static analogous(hue, spread = 30) {
    return {
      primary: `hsl(${hue}, 70%, 50%)`,
      secondary: `hsl(${(hue + spread) % 360}, 70%, 50%)`,
      tertiary: `hsl(${(hue - spread + 360) % 360}, 70%, 50%)`
    };
  }

  // 分裂互补
  static splitComplementary(hue, spread = 30) {
    return {
      primary: `hsl(${hue}, 70%, 50%)`,
      secondary: `hsl(${(hue + 180 + spread) % 360}, 70%, 50%)`,
      tertiary: `hsl(${(hue + 180 - spread + 360) % 360}, 70%, 50%)`
    };
  }
}
```

### 色阶生成

```javascript
// 生成从深到浅的色阶
function generateScale(baseHue, saturation = 70) {
  return {
    50:  `hsl(${baseHue}, ${saturation * 0.3}%, 97%)`,
    100: `hsl(${baseHue}, ${saturation * 0.5}%, 92%)`,
    200: `hsl(${baseHue}, ${saturation * 0.6}%, 85%)`,
    300: `hsl(${baseHue}, ${saturation * 0.7}%, 75%)`,
    400: `hsl(${baseHue}, ${saturation * 0.8}%, 65%)`,
    500: `hsl(${baseHue}, ${saturation}%, 50%)`,        // 基础色
    600: `hsl(${baseHue}, ${saturation * 0.9}%, 43%)`,
    700: `hsl(${baseHue}, ${saturation * 0.85}%, 35%)`,
    800: `hsl(${baseHue}, ${saturation * 0.8}%, 27%)`,
    900: `hsl(${baseHue}, ${saturation * 0.75}%, 20%)`,
    950: `hsl(${baseHue}, ${saturation * 0.7}%, 12%)`
  };
}

// 使用示例
const blueScale = generateScale(220);
// 输出: { 50: "hsl(220, 21%, 97%)", 100: "hsl(220, 35%, 92%)", ... }
```

---

## 预设主题模板

### 商务专业主题

```css
:root {
  /* 主色调 - 深蓝 */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-200: #bfdbfe;
  --color-primary-300: #93c5fd;
  --color-primary-400: #60a5fa;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  --color-primary-800: #1e40af;
  --color-primary-900: #1e3a8a;

  /* 中性色 */
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;

  /* 语义色 */
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;
}
```

### 科技创新主题

```css
:root {
  /* 主色调 - 紫色 */
  --color-primary-50: #faf5ff;
  --color-primary-100: #f3e8ff;
  --color-primary-200: #e9d5ff;
  --color-primary-300: #d8b4fe;
  --color-primary-400: #c084fc;
  --color-primary-500: #a855f7;
  --color-primary-600: #9333ea;
  --color-primary-700: #7e22ce;
  --color-primary-800: #6b21a8;
  --color-primary-900: #581c87;

  /* 强调色 - 青色 */
  --color-accent-400: #22d3ee;
  --color-accent-500: #06b6d4;
  --color-accent-600: #0891b2;

  /* 背景 */
  --color-bg-primary: #0f0f23;
  --color-bg-secondary: #1a1a2e;
  --color-bg-tertiary: #16213e;
}
```

### 自然环保主题

```css
:root {
  /* 主色调 - 森林绿 */
  --color-primary-50: #f0fdf4;
  --color-primary-100: #dcfce7;
  --color-primary-200: #bbf7d0;
  --color-primary-300: #86efac;
  --color-primary-400: #4ade80;
  --color-primary-500: #22c55e;
  --color-primary-600: #16a34a;
  --color-primary-700: #15803d;
  --color-primary-800: #166534;
  --color-primary-900: #14532d;

  /* 大地色系 */
  --color-earth-100: #fef3c7;
  --color-earth-200: #fde68a;
  --color-earth-500: #92400e;
  --color-earth-700: #78350f;
}
```

---

## 明暗模式系统

### CSS 变量切换

```css
/* 亮色模式（默认） */
:root {
  --color-bg: #ffffff;
  --color-bg-secondary: #f3f4f6;
  --color-text: #111827;
  --color-text-secondary: #6b7280;
  --color-border: #e5e7eb;
  --color-primary: #3b82f6;
}

/* 暗色模式 */
[data-theme="dark"] {
  --color-bg: #111827;
  --color-bg-secondary: #1f2937;
  --color-text: #f9fafb;
  --color-text-secondary: #9ca3af;
  --color-border: #374151;
  --color-primary: #60a5fa;
}

/* 系统偏好检测 */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-bg: #111827;
    --color-bg-secondary: #1f2937;
    --color-text: #f9fafb;
    --color-text-secondary: #9ca3af;
    --color-border: #374151;
    --color-primary: #60a5fa;
  }
}
```

### JavaScript 主题切换

```javascript
// 主题管理器
const ThemeManager = {
  init() {
    const saved = localStorage.getItem('theme');
    if (saved) {
      this.setTheme(saved);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.setTheme('dark');
    }

    // 监听系统主题变化
    window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', (e) => {
        if (!localStorage.getItem('theme')) {
          this.setTheme(e.matches ? 'dark' : 'light');
        }
      });
  },

  setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  },

  toggle() {
    const current = document.documentElement.getAttribute('data-theme');
    this.setTheme(current === 'dark' ? 'light' : 'dark');
  }
};
```

---

## Tailwind CSS 配置

### 自定义主题

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        accent: {
          light: '#fef3c7',
          DEFAULT: '#f59e0b',
          dark: '#b45309',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Lexend', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '112': '28rem',
        '128': '32rem',
      },
    },
  },
  plugins: [],
}
```

---

## 可访问性检查

### 对比度计算

```javascript
// WCAG 对比度计算
function getLuminance(r, g, b) {
  const [rs, gs, bs] = [r, g, b].map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

function getContrastRatio(color1, color2) {
  const l1 = getLuminance(...hexToRgb(color1));
  const l2 = getLuminance(...hexToRgb(color2));
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return [
    parseInt(result[1], 16),
    parseInt(result[2], 16),
    parseInt(result[3], 16)
  ];
}

// WCAG 标准
// AA 级: 4.5:1 (正常文字), 3:1 (大文字)
// AAA 级: 7:1 (正常文字), 4.5:1 (大文字)

function checkAccessibility(textColor, bgColor) {
  const ratio = getContrastRatio(textColor, bgColor);
  return {
    ratio: ratio.toFixed(2),
    normalAA: ratio >= 4.5,
    normalAAA: ratio >= 7,
    largeAA: ratio >= 3,
    largeAAA: ratio >= 4.5
  };
}

// 示例
console.log(checkAccessibility('#1f2937', '#ffffff'));
// { ratio: "13.13", normalAA: true, normalAAA: true, largeAA: true, largeAAA: true }
```

### 色盲友好配色

```javascript
// 避免使用的颜色组合（色盲用户难以区分）
const problematicCombinations = [
  ['red', 'green'],           // 红绿色盲
  ['blue', 'purple'],         // 蓝色盲
  ['green', 'brown'],         // 红绿色盲
  ['light green', 'yellow'],  // 红绿色盲
];

// 推荐的色盲友好配色
const colorBlindFriendly = {
  categorical: [
    '#0077BB',  // 蓝色
    '#EE7733',  // 橙色
    '#009988',  // 青色
    '#CC3311',  // 红色
    '#33BBEE',  // 天蓝
    '#EE3377',  // 品红
    '#BBBBBB',  // 灰色
  ],
  diverging: {
    negative: '#D55E00',  // 橙红
    neutral: '#F0E442',   // 黄色
    positive: '#009E73',  // 青绿
  }
};
```

---

## 情感配色指南

| 情感/场景 | 推荐色系 | 色相范围 |
|----------|---------|---------|
| 信任/专业 | 蓝色系 | 200-230 |
| 活力/兴奋 | 红橙色系 | 0-30 |
| 自然/健康 | 绿色系 | 90-150 |
| 创意/奢华 | 紫色系 | 270-300 |
| 温暖/友好 | 黄橙色系 | 30-60 |
| 简约/高端 | 中性色系 | 任意低饱和度 |
| 科技/未来 | 蓝紫色系 | 230-280 |

---

## 与 TAD 框架的集成

在 TAD 的设计流程中：

```
品牌需求 → 情感定位 → 配色生成 → 可访问性验证 → 主题系统 → 应用实施
               ↓
          [ 此 Skill ]
```

### Gate Mapping

```yaml
Gate2_Design:
  theme_design:
    - Brand colors defined
    - Color scales generated
    - Semantic colors mapped
    - Dark mode strategy planned

Gate4_Review:
  theme_accessibility:
    - All text meets AA contrast (4.5:1)
    - UI elements meet 3:1 contrast
    - Color blindness tested
    - Dark mode fully implemented
    - Design tokens documented
```

### Evidence Template

```markdown
## Theme Accessibility Evidence - [Project Name]

**Date:** [Date]
**Designer:** [Name]

---

### 1. Color Palette Definition

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| --color-primary | #3b82f6 | #60a5fa | Primary actions, links |
| --color-secondary | #64748b | #94a3b8 | Secondary text |
| --color-bg | #ffffff | #111827 | Page background |
| --color-text | #111827 | #f9fafb | Body text |

### 2. Contrast Ratio Verification

| Combination | Light Mode | Dark Mode | WCAG Level |
|-------------|------------|-----------|------------|
| Text on Background | 15.23:1 | 16.41:1 | AAA ✅ |
| Primary on Background | 3.84:1 | 4.12:1 | AA Large ✅ |
| Primary on Primary-bg | 7.21:1 | 6.89:1 | AAA ✅ |
| Secondary on Background | 5.42:1 | 4.87:1 | AA ✅ |

**Tool Used:** WebAIM Contrast Checker

### 3. Color Blindness Simulation

| Type | Tool | Light Mode | Dark Mode |
|------|------|------------|-----------|
| Protanopia | Sim Daltonism | ✅ Pass | ✅ Pass |
| Deuteranopia | Sim Daltonism | ✅ Pass | ✅ Pass |
| Tritanopia | Sim Daltonism | ✅ Pass | ✅ Pass |
| Achromatopsia | Grayscale | ✅ Pass | ✅ Pass |

**Additional Measures:**
- [x] Icons accompany color indicators
- [x] Error states use both color and icon
- [x] Chart data uses patterns in addition to color

### 4. Dark Mode Implementation

- [x] CSS custom properties for all colors
- [x] System preference detection (`prefers-color-scheme`)
- [x] Manual toggle with localStorage persistence
- [x] No flash of wrong theme on load
- [x] Images adapted for dark mode (where needed)

### 5. Design Token Export

\`\`\`
Exported formats:
- CSS Custom Properties ✅
- Tailwind config ✅
- JSON tokens ✅
- Figma variables ✅
\`\`\`

---

**Theme Accessibility Compliant:** ✅ Yes
**Design System URL:** [Link to documentation]
```

**使用场景**：
- 新项目品牌配色
- 设计系统构建
- 明暗模式实现
- 可访问性优化
- 营销物料配色

---

## 最佳实践

```
✅ 推荐
□ 从品牌核心色出发生成色阶
□ 确保文字和背景对比度达 AA 级
□ 为语义化场景定义专用颜色
□ 测试色盲用户可辨识度
□ 提供明暗模式切换

❌ 避免
□ 使用过多主色（限制 1-2 个）
□ 仅依赖颜色传达信息
□ 忽略不同屏幕的显示差异
□ 硬编码颜色值（使用变量）
```

---

## 工具推荐

- [Coolors](https://coolors.co/) - 配色方案生成器
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - 对比度检查
- [Color Hunt](https://colorhunt.co/) - 配色灵感
- [Tailwind CSS Color Generator](https://uicolors.app/) - Tailwind 色阶生成

---

*此 Skill 帮助 Claude 创建专业的配色方案和主题系统。*
