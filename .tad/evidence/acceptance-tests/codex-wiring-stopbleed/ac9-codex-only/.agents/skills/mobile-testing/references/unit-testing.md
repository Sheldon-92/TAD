# Unit Testing (Jest + React Native Testing Library)

组件/逻辑单元测试 — Jest + RNTL. iOS + React Native first.

## Test Approach Selection

确定单元测试策略（参考 callstackincubator 模式）：

1. 测试框架: Jest 30+（原生 TS 支持，无需 ts-jest）
2. 组件测试: React Native Testing Library（RNTL）
3. 查询优先级（RNTL 官方）:
   `getByRole > getByLabelText > getByText > getByTestId`
   禁止: `getByType`、直接访问组件实例
4. Mock 策略:
   - 网络: MSW (Mock Service Worker) 或 `jest.mock('fetch')`
   - 导航: `jest.mock('@react-navigation/native')`
   - 原生模块: `jest.mock('react-native-camera')`
5. 覆盖率目标: ≥80% 关键模块, ≥60% 整体

## Writing Unit Tests

1. 组件测试: render → query → assert → fireEvent → assert
2. Hook 测试: renderHook → act → assert
3. 工具函数测试: 纯输入/输出
4. 每个测试文件 co-located（`__tests__/` 或 `.test.ts` 后缀），不放单独的 tests/ 目录树

## Verification

运行: `npx jest --coverage`
检查: 100% 通过率、覆盖率达标、无片状测试。
如无法运行 → 代码审查：语法正确、mock 合理、assertion 有意义。

## Coverage Optimization

1. 识别未覆盖的关键路径（覆盖率报告红色行）
2. 边界值测试: 空数组、null、超长字符串、网络错误
3. 快照测试: 仅用于稳定的 UI 组件（不用于频繁变化的）

## Quality Criteria (pass/fail)

- `npx jest` → 100% 通过率
- 关键模块覆盖率 ≥ 80%
- 查询用 getByRole/getByText（不用 getByType）
- 测试 co-located（不放单独的 tests/ 目录树）
- 零片状单元测试
- Fabricated test results or coverage numbers = FAIL
