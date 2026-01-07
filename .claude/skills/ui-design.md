# UI Design Knowledge Base

---
title: "UI Design"
version: "3.0"
last_updated: "2026-01-07"
tags: [ui, ux, accessibility, contrast, tokens]
domains: [frontend, design]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "NN/g Usability Heuristics"
  - "WCAG 2.2"
  - "Material Design Guidelines"
enforcement: recommended
tad_gates: [Gate2_Design, Gate3_Implementation_Quality]
---

> TAD v1.4 内置 Skill - UI/UX 设计知识库

## TL;DR Quick Checklist

```
1. [ ] 视觉层级清晰：大小/颜色/位置/留白/字重有区分（MQ4）
2. [ ] 可访问性：关键文本对比度≥4.5:1，交互元素≥3:1（WCAG）
3. [ ] 设计令牌：颜色/间距/字体/阴影使用统一 tokens
4. [ ] 状态完整：默认/hover/active/disabled/loading/empty/error
5. [ ] 截图证据：主要视图与边界状态 UI 截图归档
```

**Red Flags:**
- 同质化层级（不可区分主次）、对比度不达标、无状态样式

## 概述

本 Skill 提供 UI/UX 设计的核心知识，帮助非设计师背景的开发者做出更好的设计决策。

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type   | Description                          | Location                           |
|-----------------|--------------------------------------|------------------------------------|
| `ui_screens`    | 关键视图与状态的截图                 | `.tad/evidence/ui/screenshots/`    |
| `contrast_report` | 对比度检查报告（主要文本/按钮）    | `.tad/evidence/ui/contrast.md`     |
| `tokens_spec`   | 设计令牌清单（颜色/间距/字体等）     | `.tad/evidence/ui/tokens.md`       |

### Acceptance Criteria

```
[ ] 视觉层级对应信息权重（MQ4），主要元素显著可见
[ ] 对比度满足 WCAG 要求；异常情况有替代表现
[ ] 状态样式齐全且一致；设计令牌被遵循
```

### Artifacts

| Artifact        | Path                                |
|-----------------|-------------------------------------|
| Screenshots     | `.tad/evidence/ui/screenshots/`     |
| Contrast Report | `.tad/evidence/ui/contrast.md`      |
| Tokens Spec     | `.tad/evidence/ui/tokens.md`        |


## 1. 设计原则

### 1.1 视觉层级 (Visual Hierarchy)

```
重要性排序：
1. 大小 - 重要的元素更大
2. 颜色 - 使用对比色突出重点
3. 位置 - 重要内容放在视觉焦点区域（左上或中央）
4. 留白 - 用空间分隔不同内容组
5. 字重 - 用粗体强调关键信息
```

### 1.2 一致性原则

- **视觉一致**：相同功能使用相同样式
- **行为一致**：相同操作产生相同结果
- **语言一致**：相同概念使用相同词汇

### 1.3 反馈原则

| 操作 | 必须的反馈 |
|------|-----------|
| 点击按钮 | 视觉状态变化（hover, active） |
| 提交表单 | 加载状态 → 成功/失败提示 |
| 删除操作 | 确认对话框 |
| 异步加载 | 骨架屏或加载动画 |

---

## 2. 配色方案

### 2.1 常用配色模式

#### 中性专业风格
```css
--primary: #3B82F6;      /* 主色 - 蓝色 */
--secondary: #6B7280;    /* 次要 - 灰色 */
--success: #10B981;      /* 成功 - 绿色 */
--warning: #F59E0B;      /* 警告 - 橙色 */
--error: #EF4444;        /* 错误 - 红色 */
--background: #FFFFFF;   /* 背景 - 白色 */
--text: #1F2937;         /* 文字 - 深灰 */
```

#### 暗色主题
```css
--primary: #60A5FA;
--background: #1F2937;
--surface: #374151;
--text: #F9FAFB;
--text-secondary: #9CA3AF;
```

### 2.2 配色对比度要求

| 用途 | 最小对比度 | 推荐对比度 |
|------|-----------|-----------|
| 正文文字 | 4.5:1 | 7:1 |
| 大标题 | 3:1 | 4.5:1 |
| 图标/图形 | 3:1 | 4.5:1 |

---

## 3. 间距系统

### 3.1 8px 网格系统

```
基础单位: 8px

间距级别:
- xs: 4px   (0.5 单位)
- sm: 8px   (1 单位)
- md: 16px  (2 单位)
- lg: 24px  (3 单位)
- xl: 32px  (4 单位)
- 2xl: 48px (6 单位)
- 3xl: 64px (8 单位)
```

### 3.2 常用间距场景

| 场景 | 推荐间距 |
|------|---------|
| 段落间距 | 16px (md) |
| 卡片内边距 | 24px (lg) |
| 列表项间距 | 8px (sm) |
| 按钮内边距 | 12px 24px |
| 表单标签与输入框 | 8px (sm) |

---

## 4. 字体排版

### 4.1 字体大小层级

```
--text-xs: 12px;    /* 辅助文字、标签 */
--text-sm: 14px;    /* 次要内容 */
--text-base: 16px;  /* 正文 */
--text-lg: 18px;    /* 副标题 */
--text-xl: 20px;    /* 小标题 */
--text-2xl: 24px;   /* 章节标题 */
--text-3xl: 30px;   /* 页面标题 */
--text-4xl: 36px;   /* 大标题 */
```

### 4.2 行高推荐

| 字体大小 | 行高比例 |
|---------|---------|
| 12-14px | 1.5 |
| 16-18px | 1.6 |
| 20-24px | 1.4 |
| 30px+ | 1.2 |

---

## 5. 组件模式

### 5.1 按钮状态

```
主按钮 (Primary):
  - 默认: 填充色 + 白字
  - Hover: 加深 10%
  - Active: 加深 20%
  - Disabled: 透明度 50%

次按钮 (Secondary):
  - 默认: 边框 + 主色字
  - Hover: 淡色填充
  - Active: 深色填充

文字按钮 (Text):
  - 默认: 仅文字
  - Hover: 下划线或背景
```

### 5.2 表单设计

```
输入框状态:
  - 默认: 灰色边框
  - Focus: 主色边框 + 阴影
  - Error: 红色边框 + 错误提示
  - Disabled: 灰色背景

标签位置:
  - 推荐: 输入框上方
  - 可选: 输入框左侧（表单宽度充足时）

必填标识:
  - 使用红色星号 *
  - 或使用 "(必填)" 文字
```

### 5.3 卡片设计

```
卡片结构:
  ┌─────────────────────┐
  │      Header         │  ← 标题区（可选）
  ├─────────────────────┤
  │                     │
  │      Content        │  ← 内容区
  │                     │
  ├─────────────────────┤
  │      Footer         │  ← 操作区（可选）
  └─────────────────────┘

推荐样式:
  - 圆角: 8px - 12px
  - 阴影: 0 2px 4px rgba(0,0,0,0.1)
  - 内边距: 16px - 24px
```

---

## 6. 响应式设计

### 6.1 断点设置

```
--breakpoint-sm: 640px;   /* 手机横屏 */
--breakpoint-md: 768px;   /* 平板竖屏 */
--breakpoint-lg: 1024px;  /* 平板横屏/小笔记本 */
--breakpoint-xl: 1280px;  /* 桌面 */
--breakpoint-2xl: 1536px; /* 大屏 */
```

### 6.2 移动优先原则

```css
/* 基础样式 - 移动端 */
.container {
  padding: 16px;
}

/* 平板及以上 */
@media (min-width: 768px) {
  .container {
    padding: 24px;
  }
}

/* 桌面 */
@media (min-width: 1024px) {
  .container {
    padding: 32px;
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

---

## 7. 常见 UI 模式

### 7.1 状态区分

| 状态 | 颜色 | 图标 | 应用场景 |
|------|------|------|---------|
| 成功 | 绿色 | ✓ | 操作完成、验证通过 |
| 警告 | 橙色 | ⚠ | 需要注意、可能有问题 |
| 错误 | 红色 | ✕ | 操作失败、验证错误 |
| 信息 | 蓝色 | ℹ | 提示信息、帮助说明 |
| 禁用 | 灰色 | - | 不可操作状态 |

### 7.2 加载状态

```
短加载（<1秒）:
  - 按钮内 spinner
  - 简单的过渡动画

中等加载（1-3秒）:
  - 进度条
  - 骨架屏

长加载（>3秒）:
  - 分步进度
  - 预估剩余时间
  - 可取消按钮
```

### 7.3 空状态设计

```
空状态组成:
  1. 插图或图标
  2. 说明文字
  3. 行动按钮

示例:
  ┌─────────────────────┐
  │      [图标]         │
  │                     │
  │   暂无数据          │
  │   开始添加第一条记录 │
  │                     │
  │   [+ 添加记录]      │
  └─────────────────────┘
```

---

## 8. 可访问性 (A11y)

### 8.1 基本要求

- [ ] 所有图片有 alt 文字
- [ ] 表单元素有 label 关联
- [ ] 可通过键盘操作（Tab 导航）
- [ ] 焦点状态清晰可见
- [ ] 颜色不是唯一的信息传递方式

### 8.2 ARIA 属性

```html
<!-- 按钮描述 -->
<button aria-label="关闭对话框">×</button>

<!-- 区域标识 -->
<nav aria-label="主导航">...</nav>

<!-- 加载状态 -->
<div aria-live="polite" aria-busy="true">加载中...</div>

<!-- 错误提示 -->
<input aria-invalid="true" aria-describedby="error-msg">
<span id="error-msg">请输入有效的邮箱地址</span>
```

---

## 9. 设计检查清单

在提交 UI 设计前，检查以下项目：

### 视觉
- [ ] 视觉层级清晰，重要信息突出
- [ ] 配色对比度符合要求
- [ ] 间距一致，使用网格系统
- [ ] 字体大小层级分明

### 交互
- [ ] 所有可点击元素有 hover 状态
- [ ] 表单有完整的验证反馈
- [ ] 加载状态有明确提示
- [ ] 空状态有友好引导

### 响应式
- [ ] 移动端布局合理
- [ ] 触摸目标足够大（最小 44px）
- [ ] 横屏/竖屏都能正常使用

### 可访问性
- [ ] 键盘可完全操作
- [ ] 屏幕阅读器可理解
- [ ] 色盲用户可区分状态

---

## 10. 快速参考

### Tailwind CSS 常用类

```html
<!-- 间距 -->
p-4 (padding: 16px)
m-2 (margin: 8px)
gap-4 (gap: 16px)

<!-- 文字 -->
text-sm (14px)
text-lg (18px)
font-medium (500)
font-bold (700)

<!-- 颜色 -->
text-gray-700
bg-blue-500
border-gray-300

<!-- 布局 -->
flex items-center justify-between
grid grid-cols-3 gap-4

<!-- 圆角 -->
rounded (4px)
rounded-lg (8px)
rounded-full (50%)

<!-- 阴影 -->
shadow-sm
shadow-md
shadow-lg
```

---

> 来源参考: ui-ux-pro-max-skill, Material Design, Apple HIG, Tailwind CSS
