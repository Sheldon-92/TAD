# hw-testing 迭代记录

## 来自研究的改进

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| OpenHTF (651★) | Spec-first measurement pattern | power_on_test quality_criteria: 新增 | 无 | ALL pass/fail specs declared BEFORE execution |
| OpenHTF | Measurement-before-spec anti-pattern | power_on_test anti_patterns: 新增 | 无 | 先测量后定标准 = 反模式 |
| awesome-open-hardware-verification | Coverage as completeness metric | functional_test quality_criteria: 新增 | 无 | 用 BOM 外设覆盖率衡量完整度 |
| awesome-hardware-test | Hardware mocking for CI | functional_test quality_criteria: 新增 | 无 | pyvisa-sim 等模拟路径用于 CI |
| awesome-hardware-test | Hardware abstraction requirement | functional_test anti_patterns: 新增 | 无 | 测试脚本耦合具体仪器 = 无法 CI |
| OpenHTF test database | Paper-based test management | functional_test anti_patterns: 新增 | 无 | Excel 管理无追溯性、无版本控制 |
| FCC Title 47 CFR Part 15 | Radiated emission numeric limits | emc_precheck quality_criteria: 新增 | "references specific frequency ranges and limit levels" (无具体数值) | Class B: 40.0/43.5/46.0/54.0 dBuV/m 四频段 |
| FCC Part 15 | Conducted emission numeric limits | emc_precheck quality_criteria: 新增 | 无 | Class B (QP): 66→56/56/60 dBuV 三频段 |
| GTEM cell testing guide | Chamber calibration requirement | emc_precheck anti_patterns: 新增 | 无 | 测试前验证 16 点 1.5m×1.5m 区域 |
| IEC 61000-4-3 | Frequency step + dwell time | emc_precheck anti_patterns: 新增 | 无 | 步进 >1% 或驻留 <0.5s = 分辨率不足 |
| EMC pre-compliance guide | EUT cable grounding | emc_precheck anti_patterns: 新增 | 无 | 线缆触碰参考地平面 → 抬高 ≥30mm |

### 第二轮改进：工作流 + 步骤

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| OpenHTF (651★) | Spec-first measurement 是核心模式 | power_on_test: 新增 declare_measurement_specs step | 无（直接写 checklist） | 测试前必须声明所有 measurement spec（name, expected, tolerance, validator） |

## 改动统计
- 新增 quality_criteria: 6
- 新增 anti_patterns: 5
- 新增 steps: 1 (declare_measurement_specs — OpenHTF spec-first 模式)
- 修改 existing criteria: 0
- 涉及 capabilities: power_on_test, functional_test, emc_precheck (3 个)
- Git diff hunks: 7
