# Quality Criteria (pass/fail rules per capability)

> Apply these as Gate/acceptance checks before marking a firmware deliverable complete.
> Universal rule for EVERY capability: **编造数据 = FAIL。不确定标注 [ASSUMPTION]。**

## Firmware Architecture

- config.h 包含所有引脚定义，每个引脚有 GPIO号+物理标记 注释
- 编译零 error，零 warnings（来源: Koopman CMU 嵌入式代码审查 — 零容忍警告策略）
- Flash 使用率 < 75%，RAM 使用率 < 60%
- 函数长度 ≤50 行（一屏可读），圈复杂度 < 15（来源: Koopman checklist）
- ISR 长度 ≤ 半页（~25 行），仅设 flag/入队，不做复杂逻辑（来源: Koopman + Embedded Artistry 共识）
- loop() 中无阻塞 delay()（除 delay(1) yield）
- 嵌套深度 ≤ 2 层 if/else，switch 内 0 层嵌套（来源: Koopman checklist）
- 每个外设 init 失败有降级路径，不 while(1) 卡死
- 状态机所有状态转换有明确定义

## Peripheral Drivers

- 每个外设有独立的 driver .h 文件
- 所有 init() 返回 bool，失败时不崩溃（返回 void 的 init = 无法检测失败 — 来源: Wayo 项目审查发现 epd_init() 返回 void）
- I2C 地址无冲突（运行 i2cScan 验证）
- 每个驱动单独编译零 error
- Serial 日志用 [OK]/[WARN]/[ERR] 前缀标注
- 无 String 拼接（用 snprintf 或 F() 宏）
- 驱动代码通过静态分析（pio check 或 cppcheck）无 high severity 问题 — 来源: PlatformIO toolchain
- 代码审查速度 ≤ 200 行/小时，单次审查 ≤ 2 小时（来源: Koopman checklist — 超速审查遗漏缺陷）

## Low Power Design

- 功耗预算表包含每个阶段的电流、时间、能量
- Deep Sleep 电流 < 150μA（无外部上拉）
- RTC 变量在唤醒后正确恢复（串口日志验证）
- WiFi 重连时间 < 3s（有缓存时 < 1s）
- E-ink 在 Deep Sleep 前调用 hibernate()
- 电源管理锁使用引用计数模式（acquire/release），支持 3 种锁类型：NO_SLEEP / APB_FREQ_MAX / CPU_FREQ_MAX — 来源: ESP-IDF pm_locks API
- Light Sleep 切换延迟 0.2-40μs 可接受，CPU 最低频率 ≥10MHz 保证外设正常 — 来源: ESP-IDF power management docs
- 电池寿命估算公式和参数均可追溯

## Communication

- WiFi 连接有超时保护（默认 10s），不无限等待
- HTTPS 请求有 CA 证书验证（dev 可 setInsecure 但标注 [DEV ONLY]）
- WiFi 密码不硬编码在源码中（→ config portal 或 NVS）
- MQTT buffer size 已调整（默认 128 太小）
- 断线有重连逻辑，且为非阻塞
- HTTP/JSON 响应有大小限制：JsonDocument 指定 capacity 或用 DeserializationOption::Filter，防止异常/恶意响应 OOM（来源: Wayo 项目实测 — ArduinoJson 无限制解析可耗尽 heap）
- 通信模块编译零 error

## Build & Upload

- 编译零 error，warnings ≤3
- Flash 使用率 < 75%，RAM 使用率 < 60%
- sketch.yaml 或 platformio.ini 锁定所有库版本
- FW_VERSION 宏在 config.h 定义且 Serial 启动时打印
- 上传后串口输出确认所有外设初始化状态

## Firmware Testing

- L1 编译测试脚本存在且可运行
- L3 自测函数覆盖所有外设
- 所有测试输出用 [TEST] name: PASS/FAIL 格式
- Flash < 75% 和 RAM < 60% 作为自动化检查
- WiFi 超时和 I2C 缺失有测试覆盖

## Firmware Documentation

- 引脚映射表与 config.h 完全一致（逐行可对照）
- 所有公开函数有参数+返回值文档
- 数据流图覆盖主要使用场景
- README 包含从零开始的编译步骤（新人 clone 能直接跑）
- 图表用 D2 生成（可版本控制、可重新生成）
