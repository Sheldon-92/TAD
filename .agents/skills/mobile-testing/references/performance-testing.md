# Mobile Performance Testing

启动时间、内存占用、帧率、包大小测试。

## Step 1: Define Metrics and Thresholds

性能指标和阈值（参考 senaiverse 性能预算），每个指标必须有具体阈值和测量方法：

| 指标 | 阈值 | 备注 |
|---|---|---|
| 冷启动时间 | < 2s | 从点击图标到首屏可交互 |
| JS Bundle 大小 | < 1.5MB | 生产版 |
| 帧率 | > 55 FPS | 滚动/动画时 |
| 内存占用 | < 250MB 活跃态, < 50MB 后台 | |
| 帧渲染 | 16ms 阈值 | 60FPS = 16.67ms/帧 |
| App 二进制大小 | < 50MB | 下载大小 |

## Step 2: Bundle Analysis

分析 JS Bundle 大小：

```
npx source-map-explorer main.jsbundle --json bundle-report.json
```

检查: 大文件（>100KB 的依赖）、重复依赖、tree-shaking 效果。
如无 bundle 文件 → 生成 bundle 分析配置，供构建后执行。

## Step 3: Performance Test Scripts

1. 启动时间测量（Detox/Maestro 计时 + Xcode Instruments）
2. 帧率监控（React Native Performance Monitor 或 Flipper）
3. 内存泄漏检测（重复导航 10 次后内存不持续增长）
4. CI 集成: 性能指标作为 pass/fail 门控

## Step 4: Report

综合为性能测试报告（PDF），含指标表、bundle 分析图、优化建议。

## Quality Criteria (pass/fail)

- 冷启动 < 2s
- JS Bundle < 1.5MB
- 帧率 > 55 FPS（动画/滚动时）
- 内存 < 250MB 活跃态
- 有 bundle 大小分析（按依赖拆分）
- Fabricated performance numbers = FAIL. Run actual measurements.
