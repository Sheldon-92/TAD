# Mobile Test Strategy

移动端测试策略设计 — 测试金字塔、CI/CD 集成、设备策略。

## Step 1: Research

搜索移动端测试策略最佳实践（web search）：
1. 移动端测试金字塔分布
2. CI/CD 中的移动端测试集成方案
3. 云测试平台（Firebase Test Lab, BrowserStack）

Example queries: `"mobile testing" pyramid strategy unit E2E ratio`, `"React Native" CI CD testing GitHub Actions`.

## Step 2: Test Pyramid Distribution

确定测试金字塔（参考 senaiverse 70/20/10 起点）：

| 层级 | 比例 | 覆盖什么 | 运行频率 |
|---|---|---|---|
| 单元 | 70% | 组件/逻辑/工具函数 | 每次 commit |
| 集成 | 20% | API 调用/状态管理/导航 | 每次 PR |
| E2E | 10% | 10-20 个核心流程 | 每次合并到 main |

调整因素: App 类型（UI 重 → 更多 E2E，逻辑重 → 更多单元）。
移动端特有: 设备矩阵测试 → 每周/每个 release。
Quality bar: 金字塔比例必须有项目类型依据（不是通用 70/20/10）。

## Step 3: Derive the Full Strategy

1. 按模块的覆盖率目标（不是全局平均）
2. CI 流水线: lint → unit → build → e2e（模拟器）→ deploy (TestFlight)
3. 片状率政策: >5% = P0 必须修复
4. 设备测试策略: 模拟器 (CI) + 云测试 (release) + 真机（关键版本）
5. 性能回归: 每个 release 前跑性能基准对比

## Step 4: Strategy Document

综合为测试策略文档（PDF），含金字塔图、CI 配置、设备矩阵、质量门控。

## Quality Criteria (pass/fail)

- 测试金字塔适配项目类型（非通用比例）
- 按模块覆盖率目标（非全局平均）
- CI 流水线有明确的阶段和失败策略
- 片状率 >5% 有处理政策
- 设备测试有分层策略（模拟器/云/真机）
- Fabricated coverage or metrics = FAIL
