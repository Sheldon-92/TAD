# Low Power Design (低功耗设计)

> Deep Sleep 模式、RTC 记忆、唤醒策略、功耗预算。

## 1. Select — 选择睡眠策略

ESP32 睡眠模式参考：

| 模式 | 电流 | 保留 | 唤醒时间 | 用途 |
|------|------|------|----------|------|
| Active | 80-240mA | 全部 | N/A | 正常运行 |
| Modem Sleep | 20-30mA | CPU+RAM | 即时 | WiFi 间歇 |
| Light Sleep | 0.8mA | CPU+RAM | <1ms | 快速响应 |
| Deep Sleep | 10-150μA | RTC MEM (8KB) | ~250ms | 周期唤醒 |
| Hibernation | 2.5μA | RTC Timer | ~250ms | 极长待机 |

唤醒源选择：

| 唤醒源 | API | 适用场景 |
|--------|-----|----------|
| 定时器 | esp_sleep_enable_timer_wakeup(us) | 周期采集 |
| GPIO | esp_sleep_enable_ext0_wakeup(pin, level) | 按钮唤醒 |
| Touch | esp_sleep_enable_touchpad_wakeup() | 触摸唤醒 |
| ULP | esp_sleep_enable_ulp_wakeup() | 传感器阈值 |

决策流程：
1. 计算一个工作周期的时间（唤醒→采集→传输→显示→睡眠）
2. 计算 duty cycle: 工作时间 / 总周期时间
3. 如果 duty cycle < 5% → Deep Sleep 收益最大
4. 如果需要快速响应（<1ms）→ Light Sleep
5. 如果只需定时唤醒（无外部触发）→ Hibernation

## 2. Execute — 实现 Deep Sleep 周期

```cpp
#include <esp_sleep.h>
#include <driver/rtc_io.h>

// RTC memory survives Deep Sleep (max 8KB)
RTC_DATA_ATTR int bootCount = 0;
RTC_DATA_ATTR time_t lastSyncTime = 0;
RTC_DATA_ATTR uint8_t cachedData[256];

void enterDeepSleep(uint64_t sleepTimeSec) {
  // 1. Save state to RTC memory
  lastSyncTime = time(nullptr);

  // 2. Deinit peripherals (prevent current leak)
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
  btStop();
  // E-ink: put to sleep mode BEFORE deep sleep
  display.hibernate();

  // 3. Configure GPIO hold (prevent floating pins)
  gpio_deep_sleep_hold_en();

  // 4. Configure wake source
  esp_sleep_enable_timer_wakeup(sleepTimeSec * 1000000ULL);

  // 5. Enter deep sleep
  Serial.println(F("[SLEEP] Entering deep sleep for ") + String(sleepTimeSec) + "s");
  Serial.flush();
  esp_deep_sleep_start();
  // ← execution stops here, resumes from setup()
}

void setup() {
  bootCount++;
  esp_sleep_wakeup_cause_t wakeup = esp_sleep_get_wakeup_cause();
  if (wakeup == ESP_SLEEP_WAKEUP_TIMER) {
    // Fast path: skip splash, restore from RTC
    quickBoot();
  } else {
    // Cold boot: full init
    fullBoot();
  }
}
```

关键实现细节：
1. **RTC 变量**: 用 RTC_DATA_ATTR 标记需要跨 sleep 保留的变量
2. **外设断电**: WiFi.disconnect(true) + WiFi.mode(WIFI_OFF) 确保射频关闭
3. **GPIO hold**: gpio_deep_sleep_hold_en() 防止引脚浮空导致外设异常
4. **E-ink 特殊处理**: Deep Sleep 前必须调 display.hibernate()，否则 E-ink 持续耗电
5. **快速启动路径**: 定时器唤醒跳过 splash，直接从 RTC 恢复状态

## 3. Verify — 验证功耗

1. **编译验证**: 包含 esp_sleep.h 的代码编译无 error
   `arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 ./project/`
2. **串口验证**: 检查 boot 计数和唤醒原因
   输出示例: "[BOOT] count=5, wakeup=TIMER"
3. **功耗预算计算**（无万用表时的理论计算）:
   | 阶段 | 电流 (mA) | 时间 (s) | 能量 (mAs) |
   |------|-----------|----------|------------|
   | Boot + Init | 80 | 0.5 | 40 |
   | WiFi Connect | 240 | 3 | 720 |
   | Data Fetch | 80 | 2 | 160 |
   | Display Update | 40 | 1 | 40 |
   | Deep Sleep | 0.01 | 3594 | 35.94 |
   | **周期合计** | | 3600 | 995.94 |
   平均电流 = 995.94 / 3600 = 0.277 mA
   电池寿命 = 容量(mAh) / 平均电流
   1000mAh 电池 ≈ 150 天
4. **RTC 变量验证**: 变量在 Deep Sleep 后保持值
5. **唤醒延迟**: 从触发到 setup() 第一行 Serial 输出的时间

## 4. Optimize — 功耗优化策略（按影响排序）

1. **WiFi 优化（影响最大）**:
   - 存储上次 WiFi channel + BSSID → 快速重连（3s → 0.5s）
   - 用 RTC_DATA_ATTR 缓存: wifi_channel, bssid[6]
   - WiFi.begin(ssid, pass, channel, bssid) 跳过 scan
2. **传输优化**:
   - 批量发送: 累积 N 次采集 → 一次 WiFi 传输
   - 压缩: 二进制协议替代 JSON（省 60-80% 字节）
   - MQTT QoS 0 替代 QoS 1（省一个 RTT）
3. **显示优化**:
   - E-ink: 局部刷新替代全刷（省 50-70% 时间和功耗）
   - OLED: 降低亮度 + 减少刷新率
4. **CPU 优化**:
   - 降频: setCpuFrequencyMhz(80) 替代默认 240MHz
   - 计算在 Light Sleep 间完成（比持续 Active 省电）
5. **GPIO 优化**:
   - 未使用引脚设为 INPUT（不要 OUTPUT + HIGH）
   - rtc_gpio_isolate() 断开 RTC GPIO 漏电

ESP-IDF pm_locks API 要点（来源: ESP-IDF power management docs）：
- 电源管理锁使用引用计数模式（acquire/release），3 种锁类型：NO_SLEEP / APB_FREQ_MAX / CPU_FREQ_MAX
- Light Sleep 切换延迟 0.2-40μs 可接受，CPU 最低频率 ≥10MHz 保证外设正常

Pass/fail: see `quality-criteria.md` §Low Power Design. Reviewer checklist: see `review-checklist.md` §低功耗设计专家.
