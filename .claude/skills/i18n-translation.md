# Internationalization & Translation Skill

> 综合自 Lokalise 最佳实践和 i18n 标准，已适配 TAD 框架

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

### ICU MessageFormat

```javascript
// 使用 ICU MessageFormat 处理复杂场景
const message = `{count, plural,
  =0 {No items}
  one {# item}
  other {# items}
} in your cart`;

// 中文
const zhMessage = `购物车中有 {count, plural,
  =0 {没有商品}
  other {# 件商品}
}`;
```

---

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
