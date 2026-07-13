# E2E Testing (Detox / Maestro)

Simulator/real-device user-flow E2E testing for mobile apps. iOS + React Native first.

## Layer 1: Framework Selection

Select the E2E framework with an explicit comparison (based on Maestro Claude Skill + Callstack research):

| 维度 | Detox | Maestro | Appium |
|---|---|---|---|
| 方式 | 灰盒（进程内） | 黑盒（YAML 声明） | 黑盒（WebDriver） |
| 片状率 | <2% | 低（自动重试） | 10-15% |
| 速度 | 最快（内部同步） | 中（12-18s/流） | 最慢 |
| 学习曲线 | 中（JS） | 低（YAML） | 高（WebDriver） |
| 适用 | RN 专用 | 跨框架 | 企业级 |

选择依据：项目框架（RN → Detox，原生 → Maestro）、团队技术栈、CI 集成需求。
Quality bar: 选型必须有对比表和项目匹配理由。

## Layer 2: Writing E2E Tests

编写核心流程 E2E 测试（≥5 个关键流程）。

**Detox 模式**（参考 callstackincubator）：
- 元素选择: 始终用 `testID`（不用 text，防动态内容不稳定）
- 等待: `waitFor().toBeVisible().withTimeout(5000)`（禁止 `sleep()`）
- 启动: `beforeAll → launchApp`, `beforeEach → reloadReactNative`
- 滚动: `whileElement().scroll()` 模式

**Maestro YAML 模式**：
- 流程骨架: `launchApp → assertVisible → tapOn → inputText → assertVisible`
- 禁用 JavaScript 表达式（GraalJS 限制多）
- `clearState` 不清 Keychain → 需额外 `clearKeychain`

每个测试文件有明确的 Arrange/Act/Assert 结构。
Artifacts: E2E design doc + `e2e/*.test.ts` 或 `e2e/*.yaml`.

## Layer 3: Verification

验证 E2E 测试（需要模拟器）：
- Detox: `npx detox test --configuration ios.sim.release`
- Maestro: `maestro test e2e/flow.yaml`

如果无法运行模拟器 → 代码审查验证：
- 测试文件语法正确？
- 所有 `element(by.id())` 的 testID 在源码中存在？
- 无 `sleep()` 调用？
- 每个测试有独立状态（不依赖前一个测试）？

## Layer 4: Optimization

1. 并行化: 独立流程可以多模拟器并行
2. 测试数据隔离: 每个测试用独立数据（不共享状态）
3. 截图策略: 失败时自动截图（Detox: `takeScreenshot`，Maestro: 自动）
4. CI 集成: GitHub Actions + 模拟器 setup
5. 片状率监控: >5% 片状率 = 必须修复

## Quality Criteria (pass/fail)

- ≥5 个核心流程有 E2E 测试
- 零 `sleep()` 调用（用显式等待）
- 元素选择用 testID（不用 text matcher）
- 每个测试独立（不依赖执行顺序）
- 失败时有自动截图
- Fabricated test results or pass rates = FAIL
