# Domain Pack Roadmap

> 目标：先覆盖软件开发全链路（Web + Mobile），再按需扩展。
> 基于用户实际项目需求排序。

---

## 全景进度

```
Web 链路:     想法 → 定义 → 设计 → 前端 → 后端 → 测试 → 部署 → 运营
               ✅     ✅     ✅     ✅     ✅     ✅     ✅     🔲

Mobile 链路:  想法 → 定义 → 设计 → 开发 → 测试 → 发布
               ✅     ✅     🔲     🔲     🔲     🔲
              (复用)  (复用)
```

---

## Phase 1: Web 全链路（接近完成）

| # | Pack | 状态 | 压力测试 |
|---|------|------|---------|
| 1 | product-definition | ✅ | ✅ 深度迭代通过 |
| 2 | web-ui-design | ✅ | ✅ SaaS PM 7/7 |
| 3 | web-frontend | ✅ | ✅ SaaS PM 7/7 |
| 4 | web-backend | ✅ | ✅ SaaS Billing 7/7 |
| 5 | web-testing | ✅ | 🔲 |
| 6 | web-deployment | 🔄 执行中 | 🔲 |

**剩余**: web-deployment 完成后 Web 链路闭环。

---

## Phase 2: Mobile 链路（下一优先级）

**驱动力**：Menu Snap iOS 版即将发布。

```
Mobile 链路复用 Web 链路的通用 pack:
  product-definition  → 复用（产品定义是通用的）
  web-ui-design       → 部分复用（但 iOS 有 HIG 规范差异）

Mobile 需要新建的 pack:
  mobile-ui-design    → iOS/Android 平台设计规范
  mobile-development  → React Native / Swift / Flutter
  mobile-testing      → 设备测试 + 模拟器 + 性能
  mobile-release      → App Store / TestFlight / Play Store
```

| # | Pack | 做什么 | 关键工具 | 优先级 |
|---|------|--------|---------|--------|
| 7 | **mobile-ui-design** | iOS HIG / Material Design 规范、平台适配、原生组件 | Figma MCP, SF Symbols | 高 — Menu Snap iOS |
| 8 | **mobile-development** | React Native / Swift 实现、原生模块、导航 | Expo CLI, Xcode CLI, CocoaPods | 高 — Menu Snap iOS |
| 9 | **mobile-testing** | 模拟器测试、设备兼容性、性能 profiling | xcrun simctl, Detox, XCTest | 中 |
| 10 | **mobile-release** | App Store 审核准备、TestFlight、元数据 | fastlane, App Store Connect API | 中 — 发布时需要 |

### Mobile 和 Web 的区别

| 维度 | Web Pack | Mobile Pack |
|------|---------|-------------|
| 设计规范 | 自由度高 | **平台强制**（iOS HIG, Material Design） |
| 开发工具 | npm/vite/Next.js | **Expo/Xcode/Android Studio CLI** |
| 测试 | Playwright (浏览器) | **模拟器 + 真机**（xcrun simctl） |
| 发布 | Vercel 一键 | **App Store 审核流程**（fastlane） |
| 性能 | Lighthouse | **Instruments/Profiler** |

**核心差异**：Mobile 有平台审核（App Store Review），设计有强制规范（HIG），发布流程复杂度远超 Web。

### 建议执行顺序

1. **mobile-ui-design** — 先做设计（iOS HIG 差异最大）
2. **mobile-development** — 再做开发（Expo/RN 或 Swift）
3. **mobile-release** — 发布时做（fastlane + App Store）
4. **mobile-testing** — 可以和 release 并行

---

## Phase 3: 硬件开发链路

**驱动力**：toy 课程项目（PSAM 5320 Making Wireless Toys）— 已有 4+ 个硬件项目。

**项目背景**（来自 toy/PROJECT_CONTEXT.md）：
- Mimikyu Emotional Pet（ESP32-S3 + OLED + Haptic）
- HeartBeatZoo（ESP32-S3 + OLED + Haptic + WiFi）
- Wayo Elephant Tracker（ESP32-C3 + 7-color E-ink）
- Piano Coach（ESP32-S3 Audio Board + FFT + AI）
- Spotify Controller（ESP32-S3 Touch LCD）
- 技术栈：arduino-cli, ESP32 系列, OLED/E-ink 显示, 触摸/触觉反馈, WiFi/BLE

```
硬件链路:  概念 → 电路设计 → 固件开发 → 外壳设计 → 测试 → 展示
                    🔲          🔲          🔲        🔲     🔲
           (复用 product-definition)
```

| # | Pack | 做什么 | 关键工具 | 优先级 |
|---|------|--------|---------|--------|
| 11 | **hw-circuit-design** | 原理图 + PCB + BOM + 元器件选型 | KiCad CLI, D2 (已有) | 高 |
| 12 | **hw-firmware** | ESP32 固件开发 (Arduino/PlatformIO) | arduino-cli, platformio | 高 — toy 项目直接用 |
| 13 | **hw-enclosure** | 3D 外壳设计 + 打印 | OpenSCAD, FreeCAD CLI | 中 |
| 14 | **hw-testing** | 硬件测试 + 调试 + 功耗优化 | serial monitor, 示波器指导 | 中 |

### 硬件和软件的关键区别

| 维度 | Web/Mobile Pack | Hardware Pack |
|------|----------------|---------------|
| 构建工具 | npm/vite/Xcode | **arduino-cli / platformio** |
| 验证方式 | 浏览器/模拟器 | **实际硬件上电测试**（无法纯自动化） |
| 调试 | console.log / DevTools | **Serial Monitor / 示波器** |
| 迭代速度 | 秒级热更新 | **分钟级编译上传** |
| 物料 | 无 | **BOM + 采购 + 焊接** |
| 产出 | 代码文件 | **代码 + 物理原型** |

### 你已有的硬件基础设施

从 toy 项目提取的可复用模式：
- `_template/` — 可复用的 ESP32 项目模板（WiFi + Haptic + Touch + Sprite）
- `devices/` — 设备文档（3 个 Waveshare 板子的 pinout + 能力）
- `generate_sprites.py` — PNG → C header 精灵图管线
- HeartBeatZoo 的数据驱动架构（动物作为 struct，per-animal timing）

**这些是 hw-firmware pack 的天然输入** — pack 可以引用这些已有模式。

### 建议执行顺序

1. **hw-firmware** — 最急需（你当前就在写 ESP32 固件），arduino-cli 工具成熟
2. **hw-circuit-design** — KiCad CLI 有但生态小，可能需要更多研究
3. **hw-enclosure** — OpenSCAD 有 CLI，但 3D 设计复杂度高
4. **hw-testing** — 硬件测试很难自动化，可能更偏文档类

---

## Phase 4: 按需扩展

| Pack | 触发条件 | 对应项目 |
|------|---------|---------|
| content-creation | Sober Creator 开始做内容时 | Sober Creator |
| ai-agent-design | 改进 OpenClaw agents 时 | OpenClaw |
| data-analytics | 项目需要数据分析时 | 通用 |
| security-compliance | 合规AI 项目启动时 | 合规AI |

**有真实项目需求时用模板 1-2 天做一个。**

---

## 全部 Pack 状态汇总

| # | Pack | 阶段 | 状态 | 行数 | 工具数 |
|---|------|------|------|------|--------|
| 1 | product-definition | Web | ✅ | ~260 | 通用 |
| 2 | web-ui-design | Web | ✅ | ~660 | +4 |
| 3 | web-frontend | Web | ✅ | 744 | +8 |
| 4 | web-backend | Web | ✅ | 756 | +4 |
| 5 | web-testing | Web | ✅ | 663 | +5 |
| 6 | web-deployment | Web | ✅ | 764 | +4 |
| 7 | mobile-ui-design | Mobile | 🔲 | — | — |
| 8 | mobile-development | Mobile | 🔲 | — | — |
| 9 | mobile-testing | Mobile | 🔲 | — | — |
| 10 | mobile-release | Mobile | 🔲 | — | — |
| 11 | hw-circuit-design | Hardware | 🔲 | — | — |
| 12 | hw-firmware | Hardware | 🔲 | — | — |
| 13 | hw-enclosure | Hardware | 🔲 | — | — |
| 14 | hw-testing | Hardware | 🔲 | — | — |
| — | tools-registry | 共享 | 持续更新 | 701+ | 27+ |

---

*Last updated: 2026-04-02*
