---
name: hw-firmware
description: "Embedded firmware development capability pack for ESP32-S3/C3 + Arduino framework. Covers firmware architecture (super loop / FreeRTOS / event-driven), peripheral driver wrapping (I2C/SPI), low-power deep-sleep design, communication protocols (WiFi/BLE/MQTT/HTTPS/OTA), arduino-cli build & upload, three-layer firmware testing, and hardware documentation generation. Use for any embedded firmware, ESP32/Arduino, IoT device code, or hardware bring-up task."
version: 0.1.0
type: reference-based
keywords: ["firmware", "固件", "嵌入式", "embedded", "ESP32", "ESP32-S3", "ESP32-C3", "Arduino", "arduino-cli", "MCU", "单片机", "外设驱动", "peripheral driver", "I2C", "SPI", "OLED", "E-ink", "墨水屏", "deep sleep", "低功耗", "low power", "功耗预算", "RTC", "WiFi", "BLE", "MQTT", "OTA", "通信协议", "state machine", "状态机", "FreeRTOS", "编译上传", "烧录", "upload", "partition table", "分区表", "串口调试", "serial debug", "引脚映射", "pin map", "接线图"]
---

# HW Firmware Capability Pack

> Deliverable is compilable firmware code + hardware docs, not sketches. Scope: ESP32-S3/C3 primary, Arduino framework (STM32/nRF out of scope for v1). Toolchain: arduino-cli (verified) + optional PlatformIO for static analysis. Standard kit: Seeed XIAO ESP32-S3, SH1106 OLED (I2C 0x3C), E-ink (GxEPD2), DA7280 haptic (I2C 0x4A), built-in touch/WiFi/BLE.

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| new firmware, main loop, 架构设计, state machine, 状态机, FreeRTOS, task scheduling, 模块划分, config.h layout | `references/firmware-architecture.md` |
| new peripheral, 外设驱动, I2C/SPI device, OLED, E-ink, haptic, touch, sensor init, driver library choice, 驱动封装 | `references/peripheral-drivers.md` |
| battery, 电池寿命, deep sleep, 低功耗, 功耗预算, RTC memory, wake source, 唤醒, hibernation | `references/low-power-design.md` |
| WiFi, BLE, MQTT, HTTP/HTTPS API, OTA update, 联网, 配网, TLS, reconnect, 断线重连 | `references/communication.md` |
| compile, upload, 编译, 烧录, arduino-cli flags, partition table, 分区表, library version, FW version, sketch.yaml | `references/build-upload.md` |
| test, 测试, serial debug, 串口调试, self-test, [TEST] logs, regression, mock, 自动化验证 | `references/firmware-testing.md` |
| pin map, 引脚映射, wiring, 接线图, README, API docs, data flow diagram, D2/Typst 文档 | `references/firmware-documentation.md` |
| before declaring ANY firmware deliverable done — acceptance / pass-fail check, 验收 | `references/quality-criteria.md` |
| before gate review / accepting firmware work — expert persona review, 专家审查 | `references/review-checklist.md` |

**Multi-signal**: load all matched references. Every capability's reference ends with its pass/fail + reviewer pointers — follow them before calling the work complete.

---

## Step 2: Decision Entry Point

**Q1 — What stage is the request?**
- New device firmware from scratch → `firmware-architecture.md` first (pattern selection → module layout), then per-peripheral `peripheral-drivers.md`
- Adding one peripheral to existing firmware → `peripheral-drivers.md`
- Device must run on battery → `low-power-design.md` MUST be read at ARCHITECTURE time, not after (power is not a retrofit)
- Needs network/cloud/phone connection → `communication.md`
- Code done, getting it onto the board → `build-upload.md`, then `firmware-testing.md`
- Producing docs for a finished firmware → `firmware-documentation.md`

**Q2 — Architecture pattern?** (reasoned selection, never default silently)
- ≤5 peripherals, no real-time need → Super Loop (millis() timers)
- WiFi + display + sensors in parallel → FreeRTOS (Core 0 = WiFi/BLE stack reserved; user tasks pinned to Core 1)
- Deep-sleep dominant, duty cycle < 5% → Event-driven (+ FreeRTOS only if post-wake work is parallel)

**Q3 — Battery powered?**
- Yes → sleep mode chosen from the current table in `low-power-design.md` (Light Sleep for <1ms response, Deep Sleep for periodic wake, Hibernation for timer-only) and a per-phase power budget table is REQUIRED

---

## Step 3: Core Judgment Rules (always apply)

### Architecture (`references/firmware-architecture.md`)
1. **config.h is the single hardware-config source**: every pin defined there with GPIO number + physical marker comment; all I2C addresses centralized; time constants with `_MS` suffix. Magic numbers scattered in code = FAIL.
2. **Non-blocking discipline**: no `delay()` in loop() (except `delay(1)` yield); all timing via millis() diffs; all I2C ops have timeouts.
3. **Koopman-derived limits**: functions ≤50 lines, cyclomatic complexity <15, nesting ≤2, ISR ≤25 lines and only sets a flag / enqueues — never loops, logic, or I2C/SPI inside an ISR.
4. **Memory budget**: Flash <75%, RAM <60% (headroom for runtime + OTA). Verify from compile output every build.
5. **Static analysis before human review** (cheap checks first): compile with all warnings → zero warnings, no suppression; `pio check` → 0 high severity.
6. Init order respects shared buses: I2C bus → OLED → haptic → other I2C; SPI → E-ink → SD; WiFi/BLE last.

### Drivers (`references/peripheral-drivers.md`)
7. **Every driver init() returns bool and probes the bus first** (I2C address responds?) before calling library init; all public functions check the ready flag. init returning void = undetectable failure = FAIL.
8. **Graceful degradation, never while(1)**: OLED fails → Serial output; haptic fails → fallback/skip; WiFi fails → offline mode keeps running.
9. One `.h` per peripheral; Serial logs prefixed `[OK]/[WARN]/[ERR]`; `snprintf`/`F()` instead of String concatenation (heap fragmentation).

### Low Power (`references/low-power-design.md`)
10. **Power is designed at architecture stage**, never retrofitted. Deep-sleep entry sequence: save state to RTC memory (`RTC_DATA_ATTR`, 8KB max) → deinit peripherals (WiFi off, btStop, E-ink `hibernate()`) → GPIO hold → configure wake source → sleep. Everything else in RAM is lost.
11. WiFi is the top power cost: cache channel + BSSID in RTC memory for fast reconnect (<1s vs ~3s); power budget table must include the WiFi-connect phase and boot.

### Communication (`references/communication.md`)
12. **Timeout everything**: WiFi connect 10s default, never `while(!connected)` unbounded; reconnects non-blocking (millis, not delay).
13. **Security floor**: CA-cert verification in production (`setInsecure()` dev-only, tagged `[DEV ONLY]`); secrets in NVS/config portal, never hardcoded; JsonDocument capacity bounded (unbounded parse of a hostile/huge response = OOM crash).

### Build & Test (`references/build-upload.md`, `references/firmware-testing.md`)
14. **Lock library versions** (sketch.yaml / platformio.ini); inject and Serial-print `FW_VERSION` at boot; partition table matched to chip flash size and OTA needs.
15. **Three test layers**: L1 compile (mandatory, zero error), L2 host-side logic, L3 on-target hardware with machine-parseable `[TEST] name: PASS/FAIL` logs. Test failure paths (missing peripheral, WiFi timeout), not just happy path.

### Docs (`references/firmware-documentation.md`)
16. Docs derive from code: pin table extracted from config.h (must match line-for-line); diagrams in D2 (version-controllable text, not GUI screenshots); README lets a newcomer wire and flash from scratch.

### Universal
17. **编造数据 = FAIL. 不确定标注 [ASSUMPTION].** Applies to every capability — power numbers, memory figures, library versions all traceable.
18. **Acceptance gate**: before declaring any firmware capability done, check its section in `references/quality-criteria.md`; before gate review / accepting firmware work, run the matching persona checklist in `references/review-checklist.md`.

---

## Anti-Patterns

### Firmware Architecture
- ❌ 魔法数字散落在代码各处（→ 集中到 config.h）
- ❌ loop() 中用 delay(1000) 做定时（→ millis() 非阻塞）
- ❌ 外设 init 失败时 while(1) 卡死（→ 优雅降级）
- ❌ 全局变量满天飞（→ 按模块用 struct 封装状态）
- ❌ setup() 中不做 I2C scan 就假设外设存在
- ❌ FreeRTOS 任务不指定 Core（→ pinToCore 明确绑定）
- ❌ ISR 中做循环/复杂逻辑/I2C/SPI 操作（→ ISR 只设 flag，主循环处理）
- ❌ 用 #define 替代 const/inline/enum（→ 类型安全 + 调试可见）
- ❌ 假设硬件状态在 deep sleep 后保留（→ 唤醒后必须重新初始化外设）

### Peripheral Drivers
- ❌ 不检测外设就直接调用库函数（→ init 先 probe）
- ❌ 驱动内用 delay() 等待（→ 用 millis 或让调用者决定）
- ❌ 用 String 类做频繁拼接（→ snprintf + char[]，避免堆碎片）
- ❌ I2C 操作无超时（→ Wire.setTimeOut()）
- ❌ 所有外设代码堆在 main.ino（→ 每个外设独立 .h）
- ❌ init 失败 while(1) 死循环（→ return false + 降级）
- ❌ 关中断/持锁时间过长（→ 最小化临界区，尽快释放）
- ❌ 跳过静态分析直接人工 review（→ 先跑 pio check，再人工审查）

### Low Power Design
- ❌ Deep Sleep 前不关 WiFi（→ WiFi.disconnect(true) + WIFI_OFF）
- ❌ 不用 RTC_DATA_ATTR 就假设变量保留（→ Deep Sleep 清除所有 RAM）
- ❌ E-ink 不 hibernate 就 Deep Sleep（→ E-ink 控制器持续耗电）
- ❌ 功耗估算不含 WiFi 连接阶段（→ 这是最耗电的阶段）
- ❌ 定时唤醒间隔硬编码（→ 用 config.h 定义 SLEEP_DURATION_S）
- ❌ 唤醒后重新校准触摸（→ 用 RTC 存 baseline）
- ❌ 把功耗管理当事后优化（→ 必须在架构阶段设计，不能后补）

### Communication
- ❌ WiFi.begin() 后 while(!connected) 无超时（→ millis 超时）
- ❌ setInsecure() 在生产固件中使用（→ 嵌入 CA 证书）
- ❌ API key 硬编码在 .ino 文件中（→ NVS / config portal）
- ❌ MQTT 重连用 delay() 阻塞（→ millis 非阻塞重连）
- ❌ 不检查 HTTP 返回码就解析 body（→ 先检查 200）
- ❌ WiFi 每次 Deep Sleep 唤醒都全量 scan（→ RTC 缓存 channel）
- ❌ JsonDocument 不设 capacity 上限（→ 异常/恶意超大 JSON 导致 OOM crash）

### Build & Upload
- ❌ 库版本不锁定（→ sketch.yaml 指定精确版本）
- ❌ 忽略编译 warnings（→ --warnings more + 逐条解决）
- ❌ 分区表不匹配 Flash 大小（→ 先确认芯片型号和 Flash 容量）
- ❌ 上传前不检查端口（→ arduino-cli board list 确认）
- ❌ 不记录构建参数（→ 写入 build.log 或 Makefile）
- ❌ 生产固件用 debug 分区表（→ 切换到 OTA 分区表）

### Firmware Testing
- ❌ 不测试就上传（→ 至少 L1 编译测试）
- ❌ 测试日志无结构（→ [TEST] 前缀 + PASS/FAIL）
- ❌ 只测试 happy path（→ 必须测试外设缺失和超时）
- ❌ 自测代码和生产代码混在一起（→ #ifdef SELF_TEST 隔离）
- ❌ 测试依赖特定 WiFi 网络（→ AP 模式或 mock）
- ❌ 不记录内存使用变化（→ 每次编译记录 Flash/RAM %）

### Firmware Documentation
- ❌ 引脚映射表和代码不同步（→ 从 config.h 自动提取）
- ❌ README 缺少接线说明（→ 新人必须知道如何连线）
- ❌ 用截图而非文本描述引脚（→ 不可搜索、不可维护）
- ❌ API 文档只有函数名没有参数说明
- ❌ 图表用 GUI 工具画（→ D2 文本格式可版本控制）
- ❌ 文档和代码分开仓库（→ 同仓库、同 PR 更新）

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "It compiles, ship it" | MUST run L1 with warnings enabled (zero warnings) + on-target `[TEST]` self-test per `firmware-testing.md` — compile success alone proves nothing about hardware |
| "The peripheral is surely connected" | MUST probe (I2C scan / init() bool) before use; missing-device path must degrade, not while(1) |
| "I'll optimize power later" | MUST design sleep strategy + power budget at architecture stage (`low-power-design.md`) — power is not a retrofit |
| "setInsecure() is fine for now" | MUST tag `[DEV ONLY]` and embed CA cert before production per `communication.md` |
| "Latest library version is fine" | MUST pin exact versions in sketch.yaml (`build-upload.md`) — unpinned builds are unreproducible |
| "Memory is probably fine" | MUST check compile output: Flash <75%, RAM <60% — record % every build |
| "Docs can lag the code" | MUST regenerate pin table from config.h and sync docs in the same PR (`firmware-documentation.md`) |
| "Deliverable done, moving on" | MUST check `references/quality-criteria.md` pass/fail section + run the persona checklist in `references/review-checklist.md` first |
