# hw-firmware 迭代记录

## 来自研究的改进

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| Koopman CMU checklist | Zero warning tolerance policy | firmware_architecture quality_criteria: 警告标准 | "warnings ≤3" | "零 warnings（零容忍警告策略）" |
| Koopman checklist | Function length + complexity thresholds | firmware_architecture quality_criteria: 新增 | 无 | 函数 ≤50 行, 圈复杂度 < 15 |
| Koopman + Embedded Artistry | ISR length limit | firmware_architecture quality_criteria: 新增 | 无 | ISR ≤ 半页 (~25 行), 仅设 flag/入队 |
| Koopman checklist | Nesting depth limit | firmware_architecture quality_criteria: 新增 | 无 | if/else ≤2 层, switch 内 0 层 |
| 所有嵌入式 repo 共识 | ISR complexity anti-pattern | firmware_architecture anti_patterns: 新增 | 无 | ISR 中禁止循环/复杂逻辑/I2C/SPI |
| Koopman checklist | #define abuse | firmware_architecture anti_patterns: 新增 | 无 | 用 const/inline/enum 替代 #define |
| ESP-IDF power management API | Deep sleep state assumption | firmware_architecture anti_patterns: 新增 | 无 | 唤醒后必须重新初始化外设 |
| PlatformIO toolchain | Static analysis requirement | peripheral_drivers quality_criteria: 新增 | 无 | pio check 或 cppcheck 无 high severity |
| Koopman checklist | Code review pace | peripheral_drivers quality_criteria: 新增 | 无 | ≤200 行/小时, 单次 ≤2 小时 |
| Koopman + ESP-IDF | Lock/interrupt duration | peripheral_drivers anti_patterns: 新增 | 无 | 最小化临界区，尽快释放 |
| PlatformIO best practice | Static analysis before review | peripheral_drivers anti_patterns: 新增 | 无 | 先跑 pio check，再人工审查 |
| ESP-IDF pm_locks API | Power management lock types | low_power_design quality_criteria: 新增 | 无 | 引用计数模式, 3 种锁类型 |
| ESP-IDF power management | Light Sleep latency thresholds | low_power_design quality_criteria: 新增 | 无 | 0.2-40μs 延迟, CPU ≥10MHz |
| ESP-IDF + 所有嵌入式资源 | Power as first-class concern | low_power_design anti_patterns: 新增 | 无 | 功耗管理必须架构阶段设计 |

### 第二轮改进：工作流 + 步骤 + 工具集成

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| PlatformIO + Koopman | 静态分析应在人工审查前执行 | firmware_architecture: 新增 verify_static_analysis step | 无（直接从编译跳到优化） | 编译检查 → pio check → 代码度量 → #define 审计，作为 Layer 3.5 |
| PlatformIO | tool_ref 缺失 | 新 step 引用 platformio_cli | 无 tool_ref | tool_ref: platformio_cli |
| PlatformIO | tools-registry 缺条目 | tools-registry: 新增 platformio_check | 只有 platformio_cli | 新增 platformio_check（pio check 静态分析专用） |

## 改动统计
- 新增 quality_criteria: 8
- 新增 anti_patterns: 6
- 新增 steps: 1 (verify_static_analysis — 静态分析 Layer 3.5)
- 新增 tool_ref: 1 (platformio_cli)
- 新增 tools-registry 条目: 1 (platformio_check)
- 修改 existing criteria: 1 (warnings ≤3 → 零 warnings)
- 涉及 capabilities: firmware_architecture, peripheral_drivers, low_power_design (3 个)
- Git diff hunks: 9
