# Review Checklists (Personas + Gates)

Expert review personas + per-capability checklists from the source Domain Pack, plus Gate 2 / Gate 4 checklists. Use during Gate review or when reviewing mobile test work.

## Per-Capability Review Personas

### E2E 测试 — 移动端 QA 工程师
- E2E 是否覆盖核心用户流程？
- 是否有片状率监控？
- CI 中是否可运行？

### 单元测试 — React Native 开发者
- 测试是否验证行为而非实现？
- Mock 是否合理（不过度）？
- 覆盖率是否达标？

### 设备兼容性 — QA 主管
- 设备矩阵是否覆盖关键分布？
- 是否有逐设备截图？
- OS 版本覆盖是否合理？

### 性能测试 — 性能工程师
- 阈值是否合理（对比行业标准）？
- 是否在 Release 模式测量？
- 是否有回归检测机制？

### 可访问性 — 可访问性专家
- VoiceOver 能否完成所有核心流程？
- 所有 label 是否描述性而非通用？
- 触控目标是否达标？

### 人机协作测试 — 产品经理
- 核心流程是否测过？
- 发现的问题是否有决策（不只是 bug 列表）？

### 测试策略 — QA 主管
- 金字塔是否匹配项目特点？
- CI 集成是否完整？
- 设备策略是否分层？

## Gate 2 (Design) Checklist

- E2E 框架选型有对比表
- 测试金字塔适配项目类型
- 设备矩阵 ≥ 4 台
- 可访问性有自动化 + 手动双层
- 性能指标有具体阈值

## Gate 4 (Acceptance) Checklist

- E2E 测试覆盖 ≥5 核心流程
- 单元测试覆盖率 ≥ 80% 关键模块
- eslint a11y 零 error
- 性能指标全部达标
- 设备兼容性报告有截图

## Deliverable Set (from source pack, per-project research dir)

E2E 设计/测试文件/验证结果、单元测试设计/验证、设备研究 + 多设备截图 + 兼容性报告、性能设计 + bundle 分析 + 性能报告、a11y 设计 + lint 结果 + VoiceOver 清单 + 可访问性报告、协作测试计划/发现/报告、策略研究 + 测试策略文档（报告类为 PDF, Typst 渲染）。
