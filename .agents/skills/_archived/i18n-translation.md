# Internationalization & Translation Skill

---
title: "Internationalization & Translation"
version: "3.0"
last_updated: "2026-01-06"
tags: [i18n, l10n, translation, localization, icu, cldr, rtl]
domains: [frontend, fullstack, content]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "Lokalise i18n Best Practices"
  - "Unicode CLDR Project"
  - "ICU User Guide"
  - "W3C Internationalization"
enforcement: recommended
tad_gates: [Gate2_Design, Gate4_Review]
---

> 综合自 Lokalise 最佳实践、Unicode CLDR 和 ICU 标准，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] Use ICU MessageFormat for plurals/gender/select
2. [ ] Reference CLDR for locale-specific data
3. [ ] Handle RTL languages (Arabic, Hebrew, Persian)
4. [ ] Define fallback chain (zh-TW → zh-CN → en)
5. [ ] Protect variables and placeholders
6. [ ] Test with pseudo-localization
```

**Red Flags:**
- Hardcoded strings in code
- No fallback for missing translations
- Ignoring RTL layout requirements
- Using string concatenation for sentences
- Not handling plural forms properly

---

## 触发条件

当用户需要进行文本翻译、软件本地化、i18n 配置或多语言内容管理时，自动应用此 Skill。

---

## 核心能力

```
国际化工具箱
├── 翻译服务
│   ├── 文本翻译
│   ├── 术语一致性
│   └── 语境理解
├── 软件本地化
│   ├── i18n 文件处理
│   ├── 变量保护
│   └── 复数处理
├── 文化适配
│   ├── 日期/货币格式
│   ├── 文化敏感性
│   └── 市场本地化
└── 质量保证
    ├── 翻译审校
    ├── 术语库管理
    └── 一致性检查
```

---

## 翻译原则

### 翻译质量标准

```markdown
## 翻译质量检查清单

### 准确性
- [ ] 原文含义完整传达
- [ ] 专业术语翻译准确
- [ ] 无遗漏或添加信息

### 流畅性
- [ ] 符合目标语言表达习惯
- [ ] 语法正确无误
- [ ] 读起来自然流畅

### 一致性
- [ ] 术语翻译前后一致
- [ ] 风格语气保持统一
- [ ] 格式规范统一

### 文化适配
- [ ] 无文化冲突或敏感内容
- [ ] 本地化表达得当
- [ ] 度量衡/日期等已转换
```

### 翻译风格指南

```markdown
## 翻译风格参考

### 正式程度
| 场景 | 风格 | 示例 |
|------|------|------|
| 法律文档 | 极正式 | 您/贵方 |
| 商业信函 | 正式 | 您 |
| 产品界面 | 中性 | 你 |
| 社交内容 | 轻松 | 亲/小伙伴 |

### 语言特点

**英译中常见问题**:
- 避免欧化句式（"被...所..."）
- 长句拆分为短句
- 适当增减词语使表达自然

**中译英常见问题**:
- 注意时态和单复数
- 添加必要的冠词和代词
- 避免中式英语表达
```

---

## i18n 文件处理

### JSON 格式 (i18next)

```json
// en.json
{
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "confirm": "Confirm"
  },
  "greeting": "Hello, {{name}}!",
  "items": "{{count}} item",
  "items_plural": "{{count}} items",
  "cart": {
    "empty": "Your cart is empty",
    "total": "Total: {{price}}"
  }
}

// zh-CN.json
{
  "common": {
    "save": "保存",
    "cancel": "取消",
    "delete": "删除",
    "confirm": "确认"
  },
  "greeting": "你好，{{name}}！",
  "items": "{{count}} 个项目",
  "cart": {
    "empty": "购物车为空",
    "total": "总计：{{price}}"
  }
}
```

### YAML 格式 (Rails)

```yaml
# en.yml
en:
  activerecord:
    models:
      user: User
      order: Order
    attributes:
      user:
        name: Name
        email: Email
  messages:
    welcome: "Welcome, %{name}!"
    error: "An error occurred"

# zh-CN.yml
zh-CN:
  activerecord:
    models:
      user: 用户
      order: 订单
    attributes:
      user:
        name: 姓名
        email: 邮箱
  messages:
    welcome: "欢迎，%{name}！"
    error: "发生错误"
```

### 变量和占位符保护

```markdown
## 变量格式规范

### 常见变量格式
| 框架 | 格式 | 示例 |
|------|------|------|
| i18next | {{variable}} | {{name}} |
| React Intl | {variable} | {count} |
| Rails | %{variable} | %{user} |
| Android | %s, %d | %1$s |
| iOS | %@ | %@ |
| Python | {variable} | {name} |

### 翻译时注意
- ⚠️ 变量必须原样保留
- ⚠️ 不要翻译变量名
- ⚠️ 不要改变变量格式
- ⚠️ 变量位置可根据语法调整
```

---

## 复数处理

### 不同语言的复数规则

```javascript
// 英语 (2 种形式: one, other)
{
  "item": "{{count}} item",
  "item_plural": "{{count}} items"
}

// 俄语 (3 种形式: one, few, many, other)
{
  "item_one": "{{count}} товар",
  "item_few": "{{count}} товара",
  "item_many": "{{count}} товаров",
  "item_other": "{{count}} товара"
}

// 阿拉伯语 (6 种形式)
{
  "item_zero": "لا عناصر",
  "item_one": "عنصر واحد",
  "item_two": "عنصران",
  "item_few": "{{count}} عناصر",
  "item_many": "{{count}} عنصرًا",
  "item_other": "{{count}} عنصر"
}

// 中文/日文 (无复数变化)
{
  "item": "{{count}} 个项目"
}
```

### ICU MessageFormat (Comprehensive)

ICU MessageFormat is the industry standard for complex i18n scenarios. It handles plurals, gender, select, and nested patterns.

```javascript
// ===========================================
// PLURAL: Handle count variations
// ===========================================
const cartMessage = `You have {count, plural,
  =0 {no items}
  one {# item}
  other {# items}
} in your cart.`;

// Chinese (no plural forms needed)
const cartMessageZh = `购物车中有 {count, plural,
  =0 {没有商品}
  other {# 件商品}
}。`;

// Russian (4 plural forms: one, few, many, other)
const cartMessageRu = `В корзине {count, plural,
  =0 {нет товаров}
  one {# товар}
  few {# товара}
  many {# товаров}
  other {# товара}
}.`;

// ===========================================
// SELECT: Handle categories (gender, etc.)
// ===========================================
const genderMessage = `{gender, select,
  male {He liked your photo}
  female {She liked your photo}
  other {They liked your photo}
}`;

// With name interpolation
const inviteMessage = `{gender, select,
  male {{name} invited his friends}
  female {{name} invited her friends}
  other {{name} invited their friends}
}`;

// ===========================================
// SELECTORDINAL: Handle ordinal numbers
// ===========================================
const rankMessage = `You finished {place, selectordinal,
  one {#st}
  two {#nd}
  few {#rd}
  other {#th}
}`;

// ===========================================
// NESTED: Complex combinations
// ===========================================
const complexMessage = `{gender, select,
  male {{count, plural,
    =0 {He has no photos}
    one {He has # photo}
    other {He has # photos}
  }}
  female {{count, plural,
    =0 {She has no photos}
    one {She has # photo}
    other {She has # photos}
  }}
  other {{count, plural,
    =0 {They have no photos}
    one {They have # photo}
    other {They have # photos}
  }}
}`;

// ===========================================
// DATE/TIME/NUMBER formatting in ICU
// ===========================================
const dateMessage = `Last login: {date, date, medium}`;
const timeMessage = `Event starts at {time, time, short}`;
const priceMessage = `Total: {price, number, ::currency/USD}`;
```

**ICU Implementation Libraries:**

| Platform | Library | Example |
|----------|---------|---------|
| JavaScript | `intl-messageformat` | FormatJS/react-intl |
| Java | ICU4J | Built-in Android |
| Python | `babel`, `icu` | PyICU |
| PHP | `intl` extension | MessageFormatter |
| iOS | Foundation | NSLocalizedString + stringsdict |

```typescript
// React + FormatJS example
import { FormattedMessage } from 'react-intl';

<FormattedMessage
  id="cart.items"
  defaultMessage="{count, plural, =0 {Empty cart} one {# item} other {# items}}"
  values={{ count: cartItems.length }}
/>
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type  | Description               | Location                             |
|----------------|---------------------------|--------------------------------------|
| `keys_audit`   | 键值与占位符一致性审计    | `.tad/evidence/i18n/keys-audit.md`   |
| `plural_rules` | 复数规则/ICU/CLDR 映射    | `.tad/evidence/i18n/plurals.md`      |
| `screenshots`  | UI 截图（回看 QA）        | `.tad/evidence/i18n/screenshots/`    |

### Acceptance Criteria

```
[ ] 变量占位符保护到位；不翻译变量名
[ ] 复数/性别/地区规则正确映射
[ ] 回看 QA 截图无截断/溢出/错位
```

### Artifacts

| Artifact      | Path                                  |
|---------------|---------------------------------------|
| Keys Audit    | `.tad/evidence/i18n/keys-audit.md`    |
| Plural Rules  | `.tad/evidence/i18n/plurals.md`       |
| Screenshots   | `.tad/evidence/i18n/screenshots/`     |
## 日期/货币格式化

### 日期格式

```javascript
// 使用 Intl.DateTimeFormat
const date = new Date();

// 英语 (美国)
new Intl.DateTimeFormat('en-US').format(date)
// "1/6/2024"

// 英语 (英国)
new Intl.DateTimeFormat('en-GB').format(date)
// "06/01/2024"

// 中文 (中国)
new Intl.DateTimeFormat('zh-CN').format(date)
// "2024/1/6"

// 日语
new Intl.DateTimeFormat('ja-JP').format(date)
// "2024/1/6"

// 完整格式
new Intl.DateTimeFormat('zh-CN', {
  year: 'numeric',
  month: 'long',
  day: 'numeric',
  weekday: 'long'
}).format(date)
// "2024年1月6日星期六"
```

### 货币格式

```javascript
const amount = 1234.56;

// 美元
new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
}).format(amount)
// "$1,234.56"

// 人民币
new Intl.NumberFormat('zh-CN', {
  style: 'currency',
  currency: 'CNY'
}).format(amount)
// "¥1,234.56"

// 欧元 (德国)
new Intl.NumberFormat('de-DE', {
  style: 'currency',
  currency: 'EUR'
}).format(amount)
// "1.234,56 €"

// 日元
new Intl.NumberFormat('ja-JP', {
  style: 'currency',
  currency: 'JPY'
}).format(1234)
// "￥1,234"
```

---

## CLDR Locale Data (Unicode Common Locale Data Repository)

CLDR provides the definitive locale data for date/time formats, number patterns, currency symbols, calendar info, and more.

### CLDR Data Categories

```
CLDR Locale Data
├── Dates & Times
│   ├── Date formats (short/medium/long/full)
│   ├── Time formats
│   ├── Date-time patterns
│   ├── Relative time ("3 days ago")
│   └── Calendar systems (Gregorian, Buddhist, etc.)
├── Numbers
│   ├── Decimal separators (. vs ,)
│   ├── Grouping separators (1,000 vs 1.000 vs 1 000)
│   ├── Percent formats
│   └── Currency formats
├── Languages & Territories
│   ├── Language names in all locales
│   ├── Territory/country names
│   └── Script names
├── Units
│   ├── Measurement units (metric vs imperial)
│   ├── Unit display names
│   └── Unit patterns
└── Plurals
    ├── Plural rules per language
    └── Ordinal rules
```

### Using CLDR in JavaScript (Intl API)

```typescript
// CLDR data is built into modern browsers via Intl API

// List supported locales
console.log(Intl.DateTimeFormat.supportedLocalesOf(['zh-CN', 'ar-EG', 'fake']));
// ['zh-CN', 'ar-EG']

// Get locale-specific display names
const displayNames = new Intl.DisplayNames(['zh-CN'], { type: 'language' });
console.log(displayNames.of('en')); // "英语"
console.log(displayNames.of('ja')); // "日语"

// Get locale-specific list formatting
const listFormatter = new Intl.ListFormat('en', { style: 'long', type: 'conjunction' });
console.log(listFormatter.format(['Apple', 'Orange', 'Banana']));
// "Apple, Orange, and Banana"

const zhListFormatter = new Intl.ListFormat('zh', { style: 'long', type: 'conjunction' });
console.log(zhListFormatter.format(['苹果', '橙子', '香蕉']));
// "苹果、橙子和香蕉"

// Relative time formatting
const rtf = new Intl.RelativeTimeFormat('zh', { numeric: 'auto' });
console.log(rtf.format(-1, 'day'));  // "昨天"
console.log(rtf.format(-3, 'day'));  // "3天前"
console.log(rtf.format(1, 'week'));  // "下周"
```

### CLDR JSON Data (Node.js / Build-time)

```javascript
// Install: npm install cldr-json
import * as cldrDates from 'cldr-dates-full';
import * as cldrNumbers from 'cldr-numbers-full';

// Access locale-specific date patterns
const zhDateFormats = cldrDates.main['zh-Hans'].dates.calendars.gregorian.dateFormats;
// {
//   full: "y年M月d日EEEE",
//   long: "y年M月d日",
//   medium: "y年M月d日",
//   short: "y/M/d"
// }

// Access number symbols
const deNumberSymbols = cldrNumbers.main['de'].numbers['symbols-numberSystem-latn'];
// { decimal: ",", group: ".", ... }
```

### Locale Matching (BCP 47)

```typescript
// BCP 47 language tags: language-Script-REGION-variant
// Examples: zh-Hans-CN, zh-Hant-TW, sr-Latn-RS

// Locale matching strategies
const locales = ['zh-CN', 'zh-TW', 'en-US', 'en-GB'];

// Best fit matching
function findBestLocale(requested: string, available: string[]): string {
  // Try exact match
  if (available.includes(requested)) return requested;

  // Try language match (zh-Hans → zh-CN)
  const language = requested.split('-')[0];
  const languageMatch = available.find(l => l.startsWith(language));
  if (languageMatch) return languageMatch;

  // Fallback to default
  return available[0];
}

// Using Intl.Locale for parsing
const locale = new Intl.Locale('zh-Hans-CN-u-ca-buddhist');
console.log(locale.language);     // "zh"
console.log(locale.script);       // "Hans"
console.log(locale.region);       // "CN"
console.log(locale.calendar);     // "buddhist"
```

---

## Bidirectional Text (RTL) Support

Right-to-left languages (Arabic, Hebrew, Persian, Urdu) require special handling for UI layout and text rendering.

### CSS RTL Layout

```css
/* Modern approach: CSS Logical Properties */
.container {
  /* Instead of: margin-left: 20px; */
  margin-inline-start: 20px;

  /* Instead of: padding-right: 10px; */
  padding-inline-end: 10px;

  /* Instead of: text-align: left; */
  text-align: start;

  /* Instead of: float: left; */
  float: inline-start;

  /* Instead of: border-left; */
  border-inline-start: 1px solid #ccc;
}

/* Direction-aware flexbox */
.nav {
  display: flex;
  flex-direction: row; /* Respects dir attribute automatically */
}

/* Physical vs Logical properties mapping */
/*
  left/right     → inline-start/inline-end
  top/bottom     → block-start/block-end
  width          → inline-size
  height         → block-size
*/

/* RTL-specific overrides (when needed) */
[dir="rtl"] .icon-arrow {
  transform: scaleX(-1); /* Flip directional icons */
}
```

### HTML RTL Setup

```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <!-- RTL stylesheet or logical properties -->
</head>
<body>
  <!-- Content flows right-to-left -->

  <!-- Isolate LTR content within RTL -->
  <p>السعر: <bdi>$99.99</bdi> دولار</p>

  <!-- Mark direction explicitly -->
  <span dir="ltr">contact@example.com</span>

  <!-- Unicode bidirectional controls (use sparingly) -->
  <p>מחיר: &#x200E;$50&#x200F;</p>
</body>
</html>
```

### JavaScript RTL Detection

```typescript
// Detect RTL languages
const RTL_LANGUAGES = ['ar', 'he', 'fa', 'ur', 'yi', 'ps', 'sd'];

function isRTL(locale: string): boolean {
  const language = locale.split('-')[0];
  return RTL_LANGUAGES.includes(language);
}

// Dynamic direction switching
function setDocumentDirection(locale: string) {
  const dir = isRTL(locale) ? 'rtl' : 'ltr';
  document.documentElement.dir = dir;
  document.documentElement.lang = locale;
}

// React Hook for RTL
function useDirection(locale: string) {
  const isRtl = useMemo(() => isRTL(locale), [locale]);

  useEffect(() => {
    document.documentElement.dir = isRtl ? 'rtl' : 'ltr';
  }, [isRtl]);

  return isRtl;
}
```

### RTL Testing Checklist

```markdown
## RTL Layout Verification

### Layout
- [ ] Text alignment mirrors correctly
- [ ] Navigation flows from right to left
- [ ] Breadcrumbs order reversed
- [ ] Form labels align to the right
- [ ] Icons with direction (arrows, etc.) flipped

### Components
- [ ] Modals and drawers open from correct side
- [ ] Progress bars fill from right
- [ ] Sliders work in reverse direction
- [ ] Tables scroll correctly
- [ ] Date pickers show correct layout

### Mixed Content
- [ ] LTR content (code, URLs, emails) isolated correctly
- [ ] Numbers display correctly
- [ ] Punctuation positioned correctly
- [ ] Brand names preserved in original direction
```

---

## Fallback Strategies

Define robust fallback chains for missing translations.

### Fallback Chain Configuration

```typescript
// i18next fallback configuration
import i18n from 'i18next';

i18n.init({
  lng: 'zh-TW',
  fallbackLng: {
    'zh-TW': ['zh-CN', 'zh', 'en'],      // Traditional → Simplified → Generic Chinese → English
    'zh-HK': ['zh-TW', 'zh-CN', 'en'],   // Hong Kong → Taiwan → Mainland → English
    'pt-BR': ['pt-PT', 'es', 'en'],       // Brazilian → European Portuguese → Spanish → English
    'default': ['en']                      // Everything else falls back to English
  },

  // Load fallbacks on demand
  load: 'currentOnly',  // or 'all' to preload fallbacks

  // Handle missing keys
  saveMissing: true,
  missingKeyHandler: (lng, ns, key, fallbackValue) => {
    console.warn(`Missing translation: ${lng}/${ns}/${key}`);
    // Send to translation management system
    reportMissingKey({ lng, ns, key, fallbackValue });
  },

  // Return key name as fallback (for development)
  returnEmptyString: false,

  // Fallback to default namespace
  fallbackNS: 'common'
});
```

### Fallback Strategies Matrix

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Locale Chain** | zh-TW → zh-CN → zh → en | Regional variants |
| **Key Fallback** | `button.save` → `save` | Nested to flat |
| **Namespace Fallback** | `admin:save` → `common:save` | Shared strings |
| **Default Value** | Use code default if all fail | Development safety |
| **Empty String** | Return "" for missing | Hide untranslated |

### Runtime Fallback Implementation

```typescript
// Custom fallback resolver
class TranslationResolver {
  private translations: Map<string, Record<string, string>> = new Map();
  private fallbackChain: Record<string, string[]> = {
    'zh-TW': ['zh-CN', 'en'],
    'zh-CN': ['en'],
    'default': ['en']
  };

  translate(key: string, locale: string): string {
    // Try exact locale
    const exactMatch = this.translations.get(locale)?.[key];
    if (exactMatch) return exactMatch;

    // Try fallback chain
    const chain = this.fallbackChain[locale] || this.fallbackChain['default'];
    for (const fallbackLocale of chain) {
      const fallback = this.translations.get(fallbackLocale)?.[key];
      if (fallback) {
        console.debug(`Fallback: ${locale}/${key} → ${fallbackLocale}`);
        return fallback;
      }
    }

    // Ultimate fallback: return key
    console.warn(`No translation found: ${locale}/${key}`);
    return key;
  }
}

// Pseudo-localization for testing (catch missing translations)
function pseudoLocalize(text: string): string {
  const pseudoMap: Record<string, string> = {
    'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú',
    'A': 'Á', 'E': 'É', 'I': 'Í', 'O': 'Ó', 'U': 'Ú'
  };

  // Add brackets and expand text (simulate longer translations)
  const expanded = text.replace(/[aeiouAEIOU]/g, c => pseudoMap[c] || c);
  return `[${expanded}]`;  // Brackets make untranslated text obvious
}
```

### Fallback Monitoring Dashboard

```typescript
// Track fallback usage for translation prioritization
interface FallbackEvent {
  key: string;
  requestedLocale: string;
  resolvedLocale: string;
  timestamp: Date;
}

class FallbackMonitor {
  private events: FallbackEvent[] = [];

  record(key: string, requested: string, resolved: string) {
    if (requested !== resolved) {
      this.events.push({
        key,
        requestedLocale: requested,
        resolvedLocale: resolved,
        timestamp: new Date()
      });
    }
  }

  getReport(): Record<string, number> {
    // Group by requested locale to find most-needed translations
    return this.events.reduce((acc, event) => {
      const key = `${event.requestedLocale}:${event.key}`;
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
  }
}
```

---

## 术语库管理

### 术语表模板

```markdown
## 产品术语表

| 英文 | 中文 | 备注 |
|------|------|------|
| Dashboard | 仪表盘/控制台 | 统一使用"仪表盘" |
| Settings | 设置 | |
| Account | 账户 | 非"账号" |
| Sign in | 登录 | 非"登入" |
| Sign out | 退出登录 | 非"登出" |
| Sign up | 注册 | |
| Submit | 提交 | |
| Workspace | 工作区 | |
| Team | 团队 | |
| Project | 项目 | |
| Task | 任务 | |
| Due date | 截止日期 | |
| Assignee | 负责人 | |
| Priority | 优先级 | |

## 禁用词汇
- ❌ 点击这里 → ✅ 立即开始
- ❌ 更多信息 → ✅ 了解详情
- ❌ OK → ✅ 确定
```

---

## 质量检查脚本

### i18n 检查工具

```javascript
// 检查缺失的翻译键
function findMissingKeys(source, target) {
  const missing = [];

  function check(srcObj, tgtObj, path = '') {
    for (const key in srcObj) {
      const currentPath = path ? `${path}.${key}` : key;

      if (typeof srcObj[key] === 'object') {
        if (!tgtObj[key]) {
          missing.push(currentPath);
        } else {
          check(srcObj[key], tgtObj[key], currentPath);
        }
      } else {
        if (!tgtObj || !tgtObj[key]) {
          missing.push(currentPath);
        }
      }
    }
  }

  check(source, target);
  return missing;
}

// 检查变量一致性
function checkVariables(source, target) {
  const issues = [];
  const varPattern = /\{\{?\w+\}?\}/g;

  function check(srcObj, tgtObj, path = '') {
    for (const key in srcObj) {
      const currentPath = path ? `${path}.${key}` : key;

      if (typeof srcObj[key] === 'object') {
        check(srcObj[key], tgtObj[key], currentPath);
      } else if (typeof srcObj[key] === 'string' && tgtObj[key]) {
        const srcVars = srcObj[key].match(varPattern) || [];
        const tgtVars = tgtObj[key].match(varPattern) || [];

        if (srcVars.sort().join() !== tgtVars.sort().join()) {
          issues.push({
            path: currentPath,
            source: srcVars,
            target: tgtVars
          });
        }
      }
    }
  }

  check(source, target);
  return issues;
}
```

---

## 与 TAD 框架的集成

在 TAD 的本地化流程中：

```
源语言内容 → 翻译准备 → 翻译执行 → 质量检查 → 集成测试
                 ↓
            [ 此 Skill ]
```

### Gate Mapping

```yaml
Gate2_Design:
  i18n_requirements:
    - Supported locales defined
    - RTL languages identified
    - Fallback chain documented
    - ICU patterns for complex strings

Gate4_Review:
  i18n_quality:
    - All strings externalized (no hardcoded text)
    - Variables protected in translations
    - Plural rules verified per language
    - RTL layout tested (if applicable)
    - Coverage report (translations vs source)
```

### Evidence Template

```markdown
## i18n Evidence - [Feature Name]

**Date:** [Date]
**Developer:** [Name]

---

### 1. Locale Support Matrix

| Locale | Status | Coverage | Fallback |
|--------|--------|----------|----------|
| en-US | ✅ Base | 100% | - |
| zh-CN | ✅ Complete | 98% | en-US |
| zh-TW | ✅ Complete | 95% | zh-CN → en-US |
| ar-SA | 🔄 In Progress | 65% | en-US |

### 2. Translation Coverage Report

\`\`\`
Total keys: 245
Translated:
  - en-US: 245/245 (100%)
  - zh-CN: 240/245 (98%)
  - ar-SA: 159/245 (65%)

Missing critical keys (ar-SA):
  - checkout.payment_methods
  - errors.validation.*
\`\`\`

### 3. ICU Pattern Usage

| Pattern Type | Count | Example |
|--------------|-------|---------|
| Plural | 12 | `{count, plural, one {# item} other {# items}}` |
| Select | 3 | `{gender, select, male {He} female {She} other {They}}` |
| Date/Number | 8 | `{date, date, medium}` |

### 4. RTL Verification (if applicable)

- [x] CSS logical properties used
- [x] Icons with direction flipped
- [x] Layout mirrored correctly
- [x] Mixed content (LTR in RTL) handled

### 5. Quality Checks

| Check | Status |
|-------|--------|
| No hardcoded strings | ✅ Pass |
| Variables preserved | ✅ Pass |
| Plural forms correct | ✅ Pass |
| Character encoding (UTF-8) | ✅ Pass |
| Text expansion tested | ✅ Pass (German +30%) |

---

**Sign-off:** i18n Ready for Release
```

### CI/CD Integration

```yaml
# .github/workflows/i18n-check.yml
name: i18n Quality Check

on: [push, pull_request]

jobs:
  i18n-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for hardcoded strings
        run: |
          # Detect strings that should be externalized
          grep -r "TODO.*i18n\|FIXME.*translate" src/ && exit 1 || true

      - name: Validate translation files
        run: |
          npm run i18n:validate

      - name: Check translation coverage
        run: |
          npm run i18n:coverage -- --threshold 80

      - name: Verify ICU syntax
        run: |
          npx @formatjs/cli compile 'src/locales/**/*.json' --ast
```

**使用场景**：
- 产品界面本地化
- 文档多语言翻译
- i18n 文件维护
- 术语库建设
- 翻译质量审核

---

## 最佳实践

```
✅ 推荐
□ 建立并维护术语表
□ 保护变量和占位符
□ 考虑文本长度变化（德语可能比英语长 30%）
□ 测试各语言的界面显示
□ 使用专业 CAT 工具辅助

❌ 避免
□ 机翻后不审校
□ 忽视文化差异
□ 硬编码文本
□ 翻译时改变变量
□ 忽视复数规则差异
```

---

*此 Skill 帮助 Claude 进行高质量的翻译和本地化工作。*
