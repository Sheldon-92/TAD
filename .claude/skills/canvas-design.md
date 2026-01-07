# Canvas Design Skill

---
title: "Canvas Design"
version: "3.0"
last_updated: "2026-01-06"
tags: [canvas, svg, design, visualization, accessibility]
domains: [frontend, design]
level: intermediate
estimated_time: "40min"
prerequisites: [html, css, javascript]
sources:
  - "MDN Canvas API"
  - "W3C SVG Specification"
  - "WCAG 2.1 Guidelines"
enforcement: recommended
tad_gates: [Gate2_Design, Gate4_Review]
---

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架和可访问性标准

## TL;DR Quick Checklist

```
1. [ ] Set canvas dimensions for high-DPI displays
2. [ ] Use semantic colors with sufficient contrast
3. [ ] Provide text alternatives for canvas content
4. [ ] Support keyboard navigation where applicable
5. [ ] Test with color blindness simulators
6. [ ] Export in appropriate format (SVG for scalable)
```

**Red Flags:**
- Low contrast text (< 4.5:1 ratio)
- No fallback content for canvas
- Relying solely on color to convey information
- Fixed pixel dimensions without DPI scaling
- Missing alt text for decorative canvas

---

## 触发条件

当用户需要创建视觉设计、绘制图形、生成图表或创作数字艺术时，自动应用此 Skill。

---

## 核心能力

```
视觉设计工具箱
├── Canvas 绘图
│   ├── 基础形状
│   ├── 路径绘制
│   └── 图像处理
├── SVG 图形
│   ├── 矢量图形
│   ├── 路径动画
│   └── 滤镜效果
├── 设计原则
│   ├── 配色理论
│   ├── 排版规则
│   └── 视觉层次
└── 输出格式
    ├── PNG/JPEG
    ├── SVG
    └── PDF
```

---

## HTML5 Canvas 基础

### 设置画布

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    canvas { border: 1px solid #ddd; }
  </style>
</head>
<body>
  <canvas id="canvas" width="800" height="600"></canvas>
  <script>
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');

    // 设置高清屏支持
    const dpr = window.devicePixelRatio || 1;
    canvas.width = 800 * dpr;
    canvas.height = 600 * dpr;
    canvas.style.width = '800px';
    canvas.style.height = '600px';
    ctx.scale(dpr, dpr);
  </script>
</body>
</html>
```

### 基础形状

```javascript
const ctx = canvas.getContext('2d');

// 矩形
ctx.fillStyle = '#4472C4';
ctx.fillRect(50, 50, 200, 100);

ctx.strokeStyle = '#2E5090';
ctx.lineWidth = 3;
ctx.strokeRect(50, 50, 200, 100);

// 圆形
ctx.beginPath();
ctx.arc(400, 100, 50, 0, Math.PI * 2);
ctx.fillStyle = '#ED7D31';
ctx.fill();

// 椭圆
ctx.beginPath();
ctx.ellipse(550, 100, 80, 40, 0, 0, Math.PI * 2);
ctx.fillStyle = '#70AD47';
ctx.fill();

// 圆角矩形
function roundRect(ctx, x, y, width, height, radius) {
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + width - radius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
  ctx.lineTo(x + width, y + height - radius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
  ctx.lineTo(x + radius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
}

roundRect(ctx, 50, 200, 200, 100, 15);
ctx.fillStyle = '#5B9BD5';
ctx.fill();
```

### 渐变与阴影

```javascript
// 线性渐变
const linearGradient = ctx.createLinearGradient(0, 0, 200, 0);
linearGradient.addColorStop(0, '#667eea');
linearGradient.addColorStop(1, '#764ba2');

ctx.fillStyle = linearGradient;
ctx.fillRect(50, 50, 200, 100);

// 径向渐变
const radialGradient = ctx.createRadialGradient(150, 150, 0, 150, 150, 100);
radialGradient.addColorStop(0, '#f093fb');
radialGradient.addColorStop(1, '#f5576c');

ctx.beginPath();
ctx.arc(150, 150, 100, 0, Math.PI * 2);
ctx.fillStyle = radialGradient;
ctx.fill();

// 阴影
ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
ctx.shadowBlur = 15;
ctx.shadowOffsetX = 5;
ctx.shadowOffsetY = 5;

ctx.fillStyle = '#4472C4';
ctx.fillRect(300, 50, 150, 100);

// 清除阴影
ctx.shadowColor = 'transparent';
```

### 文字绘制

```javascript
// 基础文字
ctx.font = 'bold 48px Arial';
ctx.fillStyle = '#1a365d';
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';
ctx.fillText('Hello World', 400, 100);

// 描边文字
ctx.strokeStyle = '#4472C4';
ctx.lineWidth = 2;
ctx.strokeText('Outlined Text', 400, 180);

// 渐变文字
const textGradient = ctx.createLinearGradient(200, 0, 600, 0);
textGradient.addColorStop(0, '#667eea');
textGradient.addColorStop(0.5, '#764ba2');
textGradient.addColorStop(1, '#f093fb');

ctx.font = 'bold 60px Arial';
ctx.fillStyle = textGradient;
ctx.fillText('Gradient Text', 400, 280);

// 多行文字
function wrapText(ctx, text, x, y, maxWidth, lineHeight) {
  const words = text.split(' ');
  let line = '';

  for (const word of words) {
    const testLine = line + word + ' ';
    const metrics = ctx.measureText(testLine);

    if (metrics.width > maxWidth && line !== '') {
      ctx.fillText(line, x, y);
      line = word + ' ';
      y += lineHeight;
    } else {
      line = testLine;
    }
  }
  ctx.fillText(line, x, y);
}
```

---

## SVG 图形

### 基础 SVG

```html
<svg width="800" height="600" xmlns="http://www.w3.org/2000/svg">
  <!-- 矩形 -->
  <rect x="50" y="50" width="200" height="100"
        fill="#4472C4" stroke="#2E5090" stroke-width="2" rx="10"/>

  <!-- 圆形 -->
  <circle cx="400" cy="100" r="50" fill="#ED7D31"/>

  <!-- 椭圆 -->
  <ellipse cx="550" cy="100" rx="80" ry="40" fill="#70AD47"/>

  <!-- 多边形 -->
  <polygon points="150,200 200,300 100,300" fill="#FFC000"/>

  <!-- 路径 -->
  <path d="M 300 200 Q 350 250 400 200 T 500 200"
        stroke="#5B9BD5" stroke-width="3" fill="none"/>

  <!-- 文字 -->
  <text x="400" y="400" font-size="48" font-weight="bold"
        text-anchor="middle" fill="#1a365d">SVG Text</text>
</svg>
```

### SVG 渐变和滤镜

```html
<svg width="800" height="600">
  <defs>
    <!-- 线性渐变 -->
    <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#667eea"/>
      <stop offset="100%" style="stop-color:#764ba2"/>
    </linearGradient>

    <!-- 径向渐变 -->
    <radialGradient id="gradient2" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#f093fb"/>
      <stop offset="100%" style="stop-color:#f5576c"/>
    </radialGradient>

    <!-- 阴影滤镜 -->
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="5" dy="5" stdDeviation="5" flood-opacity="0.3"/>
    </filter>

    <!-- 模糊滤镜 -->
    <filter id="blur">
      <feGaussianBlur stdDeviation="5"/>
    </filter>
  </defs>

  <rect x="50" y="50" width="200" height="100" fill="url(#gradient1)"/>
  <circle cx="400" cy="100" r="60" fill="url(#gradient2)"/>
  <rect x="50" y="200" width="150" height="100" fill="#4472C4" filter="url(#shadow)"/>
</svg>
```

---

## Python 绘图（Pillow/Cairo）

### Pillow 基础

```python
from PIL import Image, ImageDraw, ImageFont

# 创建画布
width, height = 800, 600
image = Image.new('RGB', (width, height), color='white')
draw = ImageDraw.Draw(image)

# 绘制矩形
draw.rectangle([50, 50, 250, 150], fill='#4472C4', outline='#2E5090', width=2)

# 绘制圆形
draw.ellipse([350, 50, 450, 150], fill='#ED7D31')

# 绘制多边形
draw.polygon([(150, 200), (200, 300), (100, 300)], fill='#FFC000')

# 绘制文字
try:
    font = ImageFont.truetype('Arial.ttf', 48)
except:
    font = ImageFont.load_default()

draw.text((400, 400), 'Hello World', fill='#1a365d', font=font, anchor='mm')

# 保存
image.save('output.png', quality=95)
```

### Cairo（更专业的矢量绘图）

```python
import cairo

# 创建 SVG 表面
with cairo.SVGSurface('output.svg', 800, 600) as surface:
    ctx = cairo.Context(surface)

    # 设置背景
    ctx.set_source_rgb(1, 1, 1)
    ctx.paint()

    # 绘制渐变矩形
    gradient = cairo.LinearGradient(50, 50, 250, 50)
    gradient.add_color_stop_rgb(0, 0.4, 0.49, 0.65)  # #667eea
    gradient.add_color_stop_rgb(1, 0.46, 0.29, 0.64)  # #764ba2

    ctx.rectangle(50, 50, 200, 100)
    ctx.set_source(gradient)
    ctx.fill()

    # 绘制圆形
    ctx.arc(400, 100, 50, 0, 2 * 3.14159)
    ctx.set_source_rgb(0.93, 0.49, 0.19)  # #ED7D31
    ctx.fill()

    # 绘制文字
    ctx.select_font_face('Arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(48)
    ctx.set_source_rgb(0.1, 0.21, 0.36)  # #1a365d

    text = 'Cairo Graphics'
    extents = ctx.text_extents(text)
    ctx.move_to(400 - extents.width / 2, 400)
    ctx.show_text(text)
```

---

## 设计原则

### 配色理论

```
色彩模式:
┌─────────────────────────────────────────┐
│  单色 (Monochromatic)                    │
│  • 同一色相的不同明度/饱和度              │
│  • 和谐、统一                            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  互补色 (Complementary)                  │
│  • 色轮上相对的两种颜色                   │
│  • 对比强烈、活力十足                     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  三元色 (Triadic)                        │
│  • 色轮上等距的三种颜色                   │
│  • 平衡、丰富                            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  类似色 (Analogous)                      │
│  • 色轮上相邻的颜色                       │
│  • 自然、舒适                            │
└─────────────────────────────────────────┘
```

### 常用配色方案

| 风格 | 主色 | 辅助色 | 点缀色 |
|------|------|--------|--------|
| 商务专业 | #1a365d | #f7fafc | #d69e2e |
| 科技创新 | #553c9a | #38b2ac | #1a202c |
| 自然环保 | #276749 | #fffaf0 | #8b4513 |
| 简约现代 | #000000 | #ffffff | #e53e3e |
| 温暖活力 | #fc8181 | #feebc8 | #805ad5 |

### 视觉层次

```
1. 大小层次
   ┌──────────────────────────────┐
   │  大元素 → 首先被注意          │
   │  中元素 → 其次被注意          │
   │  小元素 → 最后被注意          │
   └──────────────────────────────┘

2. 对比层次
   ┌──────────────────────────────┐
   │  高对比 → 突出重要信息        │
   │  低对比 → 次要信息            │
   └──────────────────────────────┘

3. 位置层次
   ┌──────────────────────────────┐
   │  上方/左侧 → 先被阅读         │
   │  中心位置 → 焦点              │
   │  边缘位置 → 辅助信息          │
   └──────────────────────────────┘
```

---

## 输出与导出

### Canvas 导出为图片

```javascript
// 导出为 PNG
const dataURL = canvas.toDataURL('image/png');

// 导出为 JPEG（可设置质量）
const jpegURL = canvas.toDataURL('image/jpeg', 0.9);

// 下载图片
function downloadCanvas(canvas, filename) {
  const link = document.createElement('a');
  link.download = filename;
  link.href = canvas.toDataURL('image/png');
  link.click();
}

downloadCanvas(canvas, 'my-design.png');
```

### SVG 导出

```javascript
// 获取 SVG 字符串
const svgElement = document.querySelector('svg');
const serializer = new XMLSerializer();
const svgString = serializer.serializeToString(svgElement);

// 下载 SVG
function downloadSVG(svgString, filename) {
  const blob = new Blob([svgString], { type: 'image/svg+xml' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}

// SVG 转 PNG
function svgToPng(svgString, width, height) {
  return new Promise((resolve) => {
    const img = new Image();
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;

    img.onload = () => {
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      resolve(canvas.toDataURL('image/png'));
    };

    img.src = 'data:image/svg+xml;base64,' + btoa(svgString);
  });
}
```

---

## Accessibility (可访问性)

Canvas and SVG content must be accessible to all users, including those with visual impairments.

### Color Contrast Requirements

```javascript
// WCAG 2.1 Contrast Ratios
// Normal text: 4.5:1 minimum
// Large text (18px+ bold or 24px+): 3:1 minimum
// UI components: 3:1 minimum

// Contrast ratio calculator
function getLuminance(r, g, b) {
  const [rs, gs, bs] = [r, g, b].map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

function getContrastRatio(color1, color2) {
  const l1 = getLuminance(...color1);
  const l2 = getLuminance(...color2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// Example usage
const textColor = [26, 54, 93];    // #1a365d
const bgColor = [255, 255, 255];   // #ffffff
const ratio = getContrastRatio(textColor, bgColor);
console.log(`Contrast ratio: ${ratio.toFixed(2)}:1`);  // 12.63:1 ✅

// Verify before drawing
function validateContrast(fgColor, bgColor, minRatio = 4.5) {
  const ratio = getContrastRatio(fgColor, bgColor);
  if (ratio < minRatio) {
    console.warn(`Low contrast: ${ratio.toFixed(2)}:1 (minimum: ${minRatio}:1)`);
    return false;
  }
  return true;
}
```

### Color Blindness Safe Palettes

```javascript
// Colors distinguishable by most color blind users
const colorBlindSafePalette = {
  // Paul Tol's Color Schemes
  qualitative: [
    '#332288', // indigo
    '#88CCEE', // cyan
    '#44AA99', // teal
    '#117733', // green
    '#999933', // olive
    '#DDCC77', // sand
    '#CC6677', // rose
    '#882255', // wine
    '#AA4499', // purple
  ],

  // IBM Design Color Blind Safe
  ibm: [
    '#648FFF', // ultramarine
    '#785EF0', // indigo
    '#DC267F', // magenta
    '#FE6100', // orange
    '#FFB000', // gold
  ],
};

// Don't rely solely on color - use patterns/shapes too
function drawDataPointWithShape(ctx, x, y, category) {
  const shapes = {
    'A': () => { ctx.arc(x, y, 8, 0, Math.PI * 2); },          // circle
    'B': () => { ctx.rect(x - 6, y - 6, 12, 12); },            // square
    'C': () => {                                                // triangle
      ctx.moveTo(x, y - 8);
      ctx.lineTo(x + 7, y + 6);
      ctx.lineTo(x - 7, y + 6);
      ctx.closePath();
    },
    'D': () => {                                                // diamond
      ctx.moveTo(x, y - 8);
      ctx.lineTo(x + 8, y);
      ctx.lineTo(x, y + 8);
      ctx.lineTo(x - 8, y);
      ctx.closePath();
    }
  };

  ctx.beginPath();
  shapes[category]();
  ctx.fill();
}
```

### Canvas Fallback Content

```html
<!-- Always provide fallback content for screen readers -->
<canvas id="chart" width="600" height="400" role="img" aria-label="Sales chart showing monthly revenue">
  <!-- Fallback content for screen readers and when JS is disabled -->
  <h2>Monthly Sales Revenue 2025</h2>
  <table>
    <caption>Sales data by month</caption>
    <tr><th>Month</th><th>Revenue</th></tr>
    <tr><td>January</td><td>$45,000</td></tr>
    <tr><td>February</td><td>$52,000</td></tr>
    <tr><td>March</td><td>$48,500</td></tr>
  </table>
  <p>Trend: Revenue increased 7% from January to March.</p>
</canvas>

<!-- For complex interactive canvases -->
<canvas id="interactive-chart" aria-describedby="chart-description">
</canvas>
<div id="chart-description" class="sr-only">
  Interactive bar chart showing quarterly sales. Use Tab to navigate between bars,
  Enter to see details. Currently showing Q1 2025 data with 4 categories.
</div>
```

### SVG Accessibility

```html
<!-- Accessible SVG with proper ARIA -->
<svg width="600" height="400"
     role="img"
     aria-labelledby="chart-title chart-desc">

  <!-- Title and description -->
  <title id="chart-title">Monthly Revenue Chart</title>
  <desc id="chart-desc">
    Bar chart showing monthly revenue from January to March 2025.
    Revenue grew from $45,000 in January to $52,000 in February,
    then decreased slightly to $48,500 in March.
  </desc>

  <!-- Chart content -->
  <g role="list" aria-label="Revenue bars">
    <g role="listitem">
      <rect x="50" y="200" width="80" height="150" fill="#4472C4"
            aria-label="January: $45,000" tabindex="0"/>
      <text x="90" y="380" text-anchor="middle">Jan</text>
    </g>
    <g role="listitem">
      <rect x="150" y="170" width="80" height="180" fill="#4472C4"
            aria-label="February: $52,000" tabindex="0"/>
      <text x="190" y="380" text-anchor="middle">Feb</text>
    </g>
    <g role="listitem">
      <rect x="250" y="185" width="80" height="165" fill="#4472C4"
            aria-label="March: $48,500" tabindex="0"/>
      <text x="290" y="380" text-anchor="middle">Mar</text>
    </g>
  </g>
</svg>
```

### Keyboard Navigation for Interactive Canvas

```javascript
class AccessibleCanvasChart {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.focusedIndex = -1;
    this.items = [];  // Chart data items

    // Make canvas focusable
    canvas.tabIndex = 0;
    canvas.setAttribute('role', 'application');
    canvas.setAttribute('aria-label', 'Interactive chart. Use arrow keys to navigate.');

    this.setupKeyboardNavigation();
    this.setupScreenReaderAnnouncements();
  }

  setupKeyboardNavigation() {
    this.canvas.addEventListener('keydown', (e) => {
      switch (e.key) {
        case 'ArrowRight':
        case 'ArrowDown':
          e.preventDefault();
          this.focusNext();
          break;
        case 'ArrowLeft':
        case 'ArrowUp':
          e.preventDefault();
          this.focusPrevious();
          break;
        case 'Enter':
        case ' ':
          e.preventDefault();
          this.selectCurrent();
          break;
        case 'Escape':
          this.clearFocus();
          break;
      }
    });
  }

  setupScreenReaderAnnouncements() {
    // Create live region for announcements
    this.liveRegion = document.createElement('div');
    this.liveRegion.setAttribute('role', 'status');
    this.liveRegion.setAttribute('aria-live', 'polite');
    this.liveRegion.className = 'sr-only';
    document.body.appendChild(this.liveRegion);
  }

  announce(message) {
    this.liveRegion.textContent = message;
  }

  focusNext() {
    this.focusedIndex = (this.focusedIndex + 1) % this.items.length;
    this.render();
    this.announce(this.items[this.focusedIndex].ariaLabel);
  }

  focusPrevious() {
    this.focusedIndex = this.focusedIndex <= 0
      ? this.items.length - 1
      : this.focusedIndex - 1;
    this.render();
    this.announce(this.items[this.focusedIndex].ariaLabel);
  }

  render() {
    // Draw with focus indicator for current item
    this.items.forEach((item, index) => {
      if (index === this.focusedIndex) {
        // Draw focus ring
        this.ctx.strokeStyle = '#005FCC';
        this.ctx.lineWidth = 3;
        this.ctx.setLineDash([5, 3]);
        this.ctx.strokeRect(item.x - 2, item.y - 2, item.width + 4, item.height + 4);
        this.ctx.setLineDash([]);
      }
    });
  }
}
```

### Accessibility Testing Checklist

```markdown
## Canvas/SVG Accessibility Verification

### Color & Contrast
- [ ] Text contrast ratio ≥ 4.5:1 (normal) or ≥ 3:1 (large)
- [ ] UI element contrast ≥ 3:1
- [ ] Tested with color blindness simulator (Sim Daltonism, Coblis)
- [ ] Not relying solely on color to convey information
- [ ] Added patterns/shapes/labels as secondary indicators

### Screen Reader Support
- [ ] Fallback content provided in canvas element
- [ ] SVG has title and desc elements
- [ ] Proper ARIA roles and labels
- [ ] Live regions for dynamic updates
- [ ] Meaningful reading order

### Keyboard Navigation
- [ ] All interactive elements reachable via Tab
- [ ] Arrow key navigation within charts
- [ ] Visible focus indicators
- [ ] Escape key to exit
- [ ] Enter/Space for selection

### Motion & Animation
- [ ] Respects prefers-reduced-motion
- [ ] No flashing content (< 3 flashes per second)
- [ ] Animation can be paused
```

---

## 与 TAD 框架的集成

在 TAD 的设计流程中：

```
设计需求 → 探索风格 → 绘制原型 → 可访问性验证 → 输出成品
               ↓
          [ 此 Skill ]
```

### Gate Mapping

```yaml
Gate2_Design:
  visual_design:
    - Color palette defined
    - Contrast ratios verified
    - Target dimensions specified
    - Accessibility requirements identified

Gate4_Review:
  design_quality:
    - Contrast compliance checked
    - Screen reader tested
    - Color blindness simulation passed
    - Fallback content provided
```

### Evidence Template

```markdown
## Design Accessibility Evidence - [Asset Name]

**Date:** [Date]
**Designer:** [Name]

---

### 1. Color Contrast Verification

| Element | Foreground | Background | Ratio | WCAG Level |
|---------|------------|------------|-------|------------|
| Heading | #1a365d | #ffffff | 12.63:1 | AAA ✅ |
| Body text | #4a5568 | #ffffff | 7.02:1 | AAA ✅ |
| Button | #ffffff | #4472C4 | 5.21:1 | AA ✅ |
| Link | #3182ce | #ffffff | 4.54:1 | AA ✅ |

**Tool Used:** WebAIM Contrast Checker

### 2. Color Blindness Test

| Type | Simulation Tool | Status |
|------|-----------------|--------|
| Protanopia (red-blind) | Sim Daltonism | ✅ Distinguishable |
| Deuteranopia (green-blind) | Sim Daltonism | ✅ Distinguishable |
| Tritanopia (blue-blind) | Sim Daltonism | ✅ Distinguishable |
| Achromatopsia (monochrome) | Grayscale filter | ✅ Readable |

### 3. Screen Reader Test

| Reader | Browser | Result |
|--------|---------|--------|
| VoiceOver | Safari | ✅ All content announced |
| NVDA | Chrome | ✅ Navigation works |

### 4. Fallback Content

- [x] Canvas has role="img" and aria-label
- [x] SVG has title and desc elements
- [x] Data table provided as fallback

---

**Accessibility Compliant:** ✅ Yes
```

**使用场景**：
- Logo 和图标设计
- 数据可视化图表
- 社交媒体图片
- 演示文稿配图
- Banner 和海报设计
- 无障碍信息图表

---

## 最佳实践

```
✅ 推荐
□ 使用矢量格式保持清晰度
□ 设计前确定目标尺寸和分辨率
□ 使用统一的配色方案
□ 保持设计简洁聚焦
□ 考虑可访问性（对比度）

❌ 避免
□ 使用过多颜色（限制 3-5 种）
□ 文字太小难以阅读
□ 元素堆砌没有留白
□ 忽略不同屏幕适配
```

---

*此 Skill 帮助 Claude 创建专业的视觉设计作品。*
