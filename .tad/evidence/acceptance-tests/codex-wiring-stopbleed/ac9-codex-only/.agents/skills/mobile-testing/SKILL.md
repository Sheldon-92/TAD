---
name: mobile-testing
description: "Mobile testing capability pack. Covers E2E testing (Detox/Maestro), unit testing (Jest/RNTL), device compatibility matrices, performance budgets, VoiceOver accessibility, human-AI pair testing, and mobile test strategy — iOS/React Native first. Use for any mobile app testing, mobile test strategy, or mobile QA task."
version: 0.1.0
type: reference-based
keywords: ["mobile testing", "移动端测试", "E2E", "端到端测试", "Detox", "Maestro", "Appium", "React Native", "Jest", "RNTL", "unit test", "单元测试", "device compatibility", "设备兼容性", "simulator", "模拟器", "performance", "性能测试", "VoiceOver", "accessibility", "无障碍", "可访问性", "pair testing", "人机协作测试", "test strategy", "测试策略", "iOS", "flaky", "片状"]
---

# Mobile Testing Capability Pack

> Full-stack mobile testing judgment — E2E, unit, device compatibility, performance, accessibility, human-AI pair testing, and test strategy.
> **Scope (v0.1, inherited from source v1.0)**: iOS + React Native 为主线；Android（TalkBack、adb、emulator）与原生 Swift/Kotlin 单元测试为扩展方向。核心差异 vs Web：模拟器/真机、设备碎片化、VoiceOver。
> **UNIVERSAL RULE**: Fabricated test results, pass rates, coverage numbers, performance numbers, compatibility results, findings, or screenshots = FAIL. Run actual measurements or explicitly report "not run".

---

## Step 1: Context Detection

| User Signal / Task Type | Load Reference |
|---|---|
| E2E, user flow test, Detox, Maestro, Appium, 端到端, simulator flow | `references/e2e-testing.md` |
| unit test, Jest, RNTL, component test, hook test, coverage, 单元测试, mock | `references/unit-testing.md` |
| device matrix, screen sizes, OS versions, iPhone SE, iPad, 设备兼容, 碎片化 | `references/device-compatibility.md` |
| startup time, FPS, memory, bundle size, 冷启动, 性能, 帧率, 内存 | `references/performance-testing.md` |
| accessibility, VoiceOver, TalkBack, a11y, WCAG, 无障碍, 可访问性 | `references/accessibility.md` |
| pair testing, 4D protocol, human feel, 手感, 协作测试, exploratory | `references/pair-testing.md` |
| test strategy, pyramid, CI/CD testing, 测试策略, 金字塔, test plan | `references/test-strategy.md` |
| before Gate review / reviewing mobile test work / acceptance check | `references/review-checklist.md` |

**Multi-signal**: load all matched references.

---

## Step 2: Decision Entry Point

**Q1 — What kind of testing task?**
- New app / no tests yet → START with `test-strategy.md` (pyramid + CI design), then per-layer references
- Writing/fixing user-flow tests → `e2e-testing.md`
- Writing/fixing component or logic tests → `unit-testing.md`
- "Does it work on device X / iOS Y?" → `device-compatibility.md`
- "App feels slow / big" → `performance-testing.md`
- Compliance / screen reader → `accessibility.md`
- Human wants to test alongside AI → `pair-testing.md`

**Q2 — Which E2E framework?** (details + comparison table in `e2e-testing.md`)
- React Native project → Detox (灰盒, <2% 片状率, 最快)
- 原生/跨框架 → Maestro (黑盒 YAML, 低学习曲线)
- 企业级 WebDriver 需求 → Appium (accept 10-15% 片状率 + 最慢)
- Selection MUST include a comparison table and a project-match rationale.

**Q3 — Reviewing or accepting work?** → ALSO load `review-checklist.md` (personas + Gate 2/Gate 4 checklists).

---

## Step 3: Core Judgment Rules

### E2E (`references/e2e-testing.md`)
- 元素选择 MUST 用 testID；never text matchers（动态内容/语言切换会碎）
- never `sleep()` — MUST 用显式等待 `waitFor().toBeVisible().withTimeout(5000)`
- ≥5 个核心流程；每个测试独立（不依赖执行顺序）；失败自动截图
- 10-20 个核心流程是上限区间 — 超过 20 个 = 维护成本爆炸
- Maestro: 禁用 JavaScript 表达式（GraalJS 限制）；clearState 不清 Keychain
- 片状率 >5% = 必须修复（策略层定为 P0）

### Unit (`references/unit-testing.md`)
- 查询优先级 MUST 遵守: getByRole > getByLabelText > getByText > getByTestId
- 禁止 getByType 和直接访问组件实例（测行为不测实现）
- 覆盖率: ≥80% 关键模块, ≥60% 整体；100% 通过率；测试 co-located
- 快照测试仅用于稳定 UI 组件

### Device Compatibility (`references/device-compatibility.md`)
- 最小矩阵 ≥4 台（最小屏/主流/最大屏/平板），每台有"为什么测"理由
- OS 覆盖 = 当前版本 + 前一个大版本；每台设备 MUST 有截图证据
- 布局溢出/截断问题 = 0 才能通过

### Performance (`references/performance-testing.md`)
- 阈值: 冷启动 <2s；JS Bundle <1.5MB；帧率 >55 FPS；内存 <250MB 活跃/<50MB 后台；二进制 <50MB
- MUST 在 Release 模式测量（Debug 结果完全不同）
- 帧率看 p99 不只平均值；内存看趋势不只单次快照（泄漏需要时间暴露）

### Accessibility (`references/accessibility.md`)
- 自动化只覆盖 30-40% — MUST 加手动 VoiceOver 层才能宣告达标
- WCAG 2.2 AA: 对比度 ≥4.5:1；触控目标 ≥44×44pt；可交互元素全有 accessibilityLabel
- Label 描述操作（"保存到收藏"）而非元素类型（"按钮"）

### Pair Testing (`references/pair-testing.md`)
- 严重度由人类决定 — AI never 单独判断（手感/动画卡顿属于人域）
- MUST 覆盖移动端特有 round: 手势/弱网/状态转换/键盘
- 每轮有截图证据；Fix Now 决策有即时 handoff

### Strategy (`references/test-strategy.md`)
- 70/20/10 金字塔只是起点 — MUST 按 App 类型调整并给出依据
- 覆盖率目标按模块设定，never 全局平均
- 设备测试分层: 模拟器(CI) + 云测试(release) + 真机(关键版本)

---

## Anti-Patterns

### E2E
- ❌ sleep(3000) 替代 waitFor = 不稳定 + 慢
- ❌ by.text('动态内容') = 语言切换/数据变化后必 FAIL
- ❌ 测试间共享状态 = 顺序依赖 = 片状
- ❌ 只测 happy path 不测错误/边界场景
- ❌ E2E 测试超过 20 个流程 = 维护成本爆炸（10-20 个核心流程足够）

### Unit
- ❌ getByType(Button) = 测试实现细节而非行为
- ❌ 快照测试覆盖所有组件 = 每次 UI 微调都要更新快照
- ❌ 测试间共享可变状态
- ❌ mock 过度 = 测试只验证 mock 行为不验证真实逻辑

### Device Compatibility
- ❌ 只在一台设备上测试 = 小屏幕/大屏幕布局问题遗漏
- ❌ 只测最新 OS = 老版本用户遇到崩溃
- ❌ 不测横屏（如果 App 支持旋转）
- ❌ 兼容性报告没有截图 = 无法验证

### Performance
- ❌ 只在 Debug 模式测性能（Release 模式结果完全不同）
- ❌ 只看整体 bundle 大小不分析依赖拆分
- ❌ 帧率只看平均值不看 p99（偶尔卡顿用户也能感知）
- ❌ 内存测试只看单次快照不看趋势（泄漏需要时间暴露）

### Accessibility
- ❌ 只跑自动化工具就宣告 a11y 达标（自动化只覆盖 30-40%）
- ❌ accessibilityLabel 写'按钮'而非操作描述（'保存到收藏'）
- ❌ 图片装饰性标注为'图片'而非设为 accessible={false}
- ❌ VoiceOver 焦点顺序和视觉顺序不一致

### Pair Testing
- ❌ AI 单独决定严重度（人类的'感觉'无法量化但很重要）
- ❌ 只看静态截图不测动态交互（动画/手势需要人类判断）
- ❌ 跳过弱网测试（移动端最常见的体验问题）

### Strategy
- ❌ 通用 70/20/10 不根据项目调整
- ❌ 没有片状率监控 = 测试套件慢慢腐烂
- ❌ 只用模拟器不用真机 = 漏掉真机特有问题
- ❌ 性能只测一次不做回归 = 慢慢变慢没人发现

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll just pick Detox/Maestro, it's obvious" | MUST produce the comparison table + project-match rationale in `e2e-testing.md` — framework depends on project stack + CI needs |
| "A sleep() here is fine, it's one test" | MUST use explicit waits — zero-sleep is a pass/fail criterion, not a preference |
| "Tests pass on my simulator, ship it" | MUST run the ≥4-device matrix in `device-compatibility.md` with per-device screenshots |
| "Performance looks fine in dev" | MUST measure in Release mode against the thresholds in `performance-testing.md` |
| "eslint a11y passed, we're accessible" | MUST complete the manual VoiceOver checklist in `accessibility.md` — automation covers only 30-40% |
| "AI can rate this jank severity" | MUST hand severity judgment to the human per `pair-testing.md` — feel is a human-domain call |
| "70/20/10 pyramid, done" | MUST justify the ratio for THIS project type per `test-strategy.md` |
| "I'll report the numbers we expect" | Fabricated results/coverage/screenshots = FAIL across every capability. Run it or report "not run" |
