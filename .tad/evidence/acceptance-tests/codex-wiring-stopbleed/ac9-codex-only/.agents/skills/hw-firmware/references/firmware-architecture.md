# Firmware Architecture (固件架构设计)

> Main loop 结构、状态机、任务调度、模块划分。Platform scope: ESP32-S3/C3 primary, Arduino framework (STM32/nRF deferred to v1.1).
> Standard kit context: Seeed XIAO ESP32-S3 (FQBN `esp32:esp32:XIAO_ESP32S3`), ESP32-C3 (FQBN `esp32:esp32:esp32c3`); SH1106 OLED 128x64 (I2C 0x3C); E-ink (SPI, GxEPD2); SparkFun DA7280 Haptic (I2C 0x4A); capacitive touch (built-in `touchRead()`); WiFi STA/AP, BLE (NimBLE), MQTT; arduino-cli v1.4.1 + esp32 core 3.3.6 (verified installed).

## 1. Select — 选择架构模式

根据项目需求选择架构模式：

1. **Super Loop（默认）**: 单线程 loop() 轮询，millis() 定时器
   - 适用：外设 ≤5 个，无实时性要求，简单状态机
   - 参考模板：_template.ino 的 loop() 结构
2. **FreeRTOS 多任务**: `xTaskCreatePinnedToCore()` 多核并行
   - 适用：WiFi + 显示 + 传感器并行，需要优先级调度
   - Core 0: WiFi/BLE 协议栈（系统保留）
   - Core 1: 用户任务（显示、传感器、业务逻辑）
3. **Event-driven**: 中断 + 事件队列 + 状态机
   - 适用：低功耗场景，大部分时间休眠，事件触发唤醒

选型决策表：

| 条件 | 推荐模式 |
|------|----------|
| 外设 ≤5, 无实时要求 | Super Loop |
| WiFi + 显示 + 传感器并行 | FreeRTOS |
| Deep Sleep 为主, 周期唤醒 | Event-driven |
| 混合（唤醒后需并行处理） | Event-driven + FreeRTOS |

## 2. Execute — 设计模块划分

参考 _template 的 .h 分离模式：

1. **config.h** — 所有引脚定义、阈值、时间常量（唯一硬件配置源）
   - 每个引脚必须有注释：GPIO号 + 物理标记 + 用途
   - 所有 I2C 地址集中定义
   - 所有时间常量用 `_MS` 后缀
2. **state.h** — 状态机定义 + 状态转换矩阵
   - enum 定义所有状态
   - 转换函数带 guard condition
3. **drivers/*.h** — 每个外设一个驱动封装
   - init() 返回 bool（检测外设是否存在）
   - 所有 I2C/SPI 操作封装在驱动内
4. **network.h** — WiFi/BLE/MQTT 通信封装
5. **power.h** — 电源管理（Deep Sleep、RTC、唤醒源）
6. **main.ino** — setup() + loop() 仅做调度

模块依赖规则：
- config.h 被所有模块包含，不包含任何其他头文件
- drivers 只依赖 config.h + 库头文件
- network 可依赖 config.h + state.h
- main.ino 包含所有模块

## 3. Verify — 验证架构设计

1. **编译验证**: 创建骨架代码并编译
   `arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 ./project/`
   目标：零 error，warnings ≤3
2. **内存预算检查**:
   - Flash: 编译输出 "Sketch uses X bytes (Y%)"
   - RAM: "Global variables use X bytes (Y%)"
   - ESP32-S3: Flash 8MB, SRAM 512KB
   - 预算：Flash < 75%, RAM < 60%（留余量给运行时）
3. **模块独立性**: 每个 .h 文件单独 #include 到空 .ino 能编译通过
4. **初始化顺序**: 验证外设 init 顺序不冲突
   - I2C bus init (Wire.begin) → OLED → Haptic → 其他 I2C 设备
   - SPI bus init → E-ink → SD card（如有）
   - WiFi/BLE init 放最后（耗时最长）

## 3.5 Verify — 静态分析（来源: PlatformIO + Koopman checklist）

在人工审查前先跑静态分析（便宜的检查先做，贵的检查后做 — Ralph Loop 原则）：

1. **编译检查** (零 warnings):
   `arduino-cli compile --warnings all --fqbn esp32:esp32:XIAO_ESP32S3 ./project/ 2>&1`
   如果有 warnings → 必须修复，不能 suppress
2. **静态分析** (如果有 PlatformIO):
   `pio check --skip-packages --severity=high ./project/`
   关注: null pointer, buffer overflow, uninitialized var, dead code
3. **代码度量** (Koopman thresholds):
   - 函数长度: 每个函数 ≤50 行（一屏可读）
   - 圈复杂度: < 15（用 `cppcheck --enable=all` 或手动检查）
   - ISR 长度: ≤ 25 行，仅设 flag/入队
   - 嵌套深度: if/else ≤2 层
4. **#define 审计**: 搜索项目内 #define，确认用 const/inline/enum 替代的没有遗漏

分析结果输出为检查报告。静态分析 0 high severity → 进入人工审查。

## 4. Optimize — 优化架构

1. **Config 集中化**: 确认所有魔法数字已移入 config.h
2. **状态机完整性**: 检查是否有未处理的状态转换
3. **错误恢复**: 每个 init 失败有优雅降级路径
   - OLED 失败 → Serial 替代输出
   - Haptic 失败 → PWM fallback → 跳过
   - WiFi 失败 → 离线模式继续运行
4. **Non-blocking 检查**: loop() 中无 delay() 调用（除 yield delay(1)）
   - 所有定时用 millis() 差值比较
   - 所有 I2C 操作有超时保护
5. **PROGMEM 检查**: 大数组（sprite、字符串表）是否用 PROGMEM

Pass/fail: see `quality-criteria.md` §Firmware Architecture. Reviewer checklist: see `review-checklist.md` §嵌入式架构师.
