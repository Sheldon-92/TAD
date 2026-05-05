# Low Power Design — Wayo Elephant Tracker

## Step 1: Sleep Strategy Selection

### ESP32-C3 Sleep Modes (from datasheet v2.1)

| Mode | Current (chip) | Current (XIAO board) | Retention | Wake Time | Source |
|------|---------------|----------------------|-----------|-----------|--------|
| Active (WiFi TX) | 240 mA peak | ~240 mA | All | N/A | Datasheet Section 4.4 |
| Active (CPU only) | 22-80 mA | ~80 mA | All | N/A | Datasheet Section 4.4 |
| Modem Sleep | 15-20 mA | ~20 mA | CPU+RAM | Instant | Datasheet Section 4.4 |
| Light Sleep | 0.13 mA | ~0.8 mA | CPU+RAM | <1ms | Datasheet Section 4.4 |
| Deep Sleep | 5 uA | 44 uA | RTC MEM (8KB) | ~250ms | Datasheet Section 4.4, Seeed spec PDF |
| Hibernation | 1 uA | [UNVALIDATED] | RTC Timer only | ~250ms | ESP-IDF docs |

**Board vs Chip gap**: The XIAO ESP32-C3 board draws 44uA in deep sleep (vs 5uA bare chip) due to onboard components (USB-C, LDO, charge IC). Community reports range from 44-230uA depending on configuration.

Source: [Seeed Studio XIAO ESP32C3 Power Consumption Tests (PDF)](https://files.seeedstudio.com/wiki/XIAO_WiFi/Resources/Seeed_Studio_XIAO_ESP32C3_Power_Consumption_Tests.pdf)

### Wayo Duty Cycle Analysis

```
Active phase:  ~22 seconds (boot + WiFi + fetch + render + e-ink refresh)
Sleep phase:   ~1778 seconds (30 min - 22s)
Duty cycle:    22/1800 = 1.22%
```

With duty cycle <5%, **Deep Sleep is optimal**. Hibernation would save marginally more (1uA vs 5uA on chip) but loses RTC memory — and Wayo needs RTC_DATA_ATTR for bootCount and ntpSyncedToday.

### Selected Strategy: Deep Sleep + RTC Alarm + GPIO Wake

| Wake Source | Purpose | API (ESP32-C3) |
|-------------|---------|----------------|
| DS3231 RTC alarm | Periodic 30-min wake | `esp_deep_sleep_enable_gpio_wakeup()` on GPIO 2 |
| Button press | Manual refresh | Same GPIO 2 (shared with RTC INT) |
| ESP32 timer (fallback) | If RTC unavailable | `esp_sleep_enable_timer_wakeup()` |

**Design choice**: RTC alarm (DS3231) is preferred over ESP32 internal timer because:
1. DS3231 has +/-2ppm accuracy vs ESP32 RTC +/-5% drift
2. DS3231 keeps real wall-clock time (needed for NTP sync scheduling)
3. Alarm fires on INT/SQW pin (open-drain LOW) — directly compatible with GPIO wake

## Step 2: Sleep/Wake Implementation

### Critical Platform Bug Found

The current Wayo firmware uses `esp_sleep_enable_ext0_wakeup()` which does **NOT exist on ESP32-C3**. This was confirmed by:
1. Compile test: `error: 'esp_sleep_enable_ext0_wakeup' was not declared in this scope`
2. [ESP-IDF docs](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/system/sleep_modes.html): C3 only supports gpio_wakeup, timer, and UART wake
3. [arduino-esp32 Issue #7005](https://github.com/espressif/arduino-esp32/issues/7005): confirmed C3 lacks ext0/ext1

### Correct Implementation for ESP32-C3

```cpp
#include "esp_sleep.h"

// Works on ESP32-C3 (replaces ext0):
void enter_deep_sleep() {
    // 1. Set RTC alarm for next wake
    ds3231_set_alarm_minutes(UPDATE_INTERVAL_MIN);

    // 2. Shut down peripherals
    wifi_disconnect();
    epd_sleep();       // E-ink into deep sleep (critical — otherwise ~50mW leak)
    led_off();

    // 3. Configure GPIO wake (ESP32-C3 specific API)
    //    GPIO 2 = DS3231 INT/SQW + button (both active LOW)
    //    Bitmask: 1ULL << 2
    esp_deep_sleep_enable_gpio_wakeup(
        1ULL << PIN_BUTTON,              // GPIO bitmask
        ESP_GPIO_WAKEUP_GPIO_LOW         // Wake when LOW
    );

    // 4. Timer fallback (in case RTC fails)
    esp_sleep_enable_timer_wakeup(
        (uint64_t)UPDATE_INTERVAL_MIN * 60 * 1000000ULL
    );

    // 5. Enter deep sleep
    Serial.flush();
    esp_deep_sleep_start();
    // Execution stops. Resumes from setup() on wake.
}
```

### RTC Memory Usage

| Variable | Type | Size | Purpose |
|----------|------|------|---------|
| bootCount | int | 4B | Cycle counter |
| ntpSyncedToday | bool | 1B | NTP sync flag |
| lastSyncDay | int | 4B | Day-of-month tracking |
| **Total** | | **9 bytes** | of 8KB limit (0.1%) |

**Recommendation**: Add WiFi fast-reconnect cache:
```cpp
RTC_DATA_ATTR uint8_t savedBSSID[6] = {};
RTC_DATA_ATTR int32_t savedChannel = 0;
```
This adds 10 bytes (total 19 bytes, still <0.3% of 8KB). WiFi reconnect time: 3s -> ~0.5s.

### Wake Cause Differentiation

```cpp
void setup() {
    esp_sleep_wakeup_cause_t reason = esp_sleep_get_wakeup_cause();
    switch (reason) {
        case ESP_SLEEP_WAKEUP_GPIO:     // RTC alarm OR button
            // Check DS3231 alarm flag to distinguish
            if (ds3231_alarm_fired()) {
                Serial.println("Wake: RTC alarm (scheduled)");
            } else {
                Serial.println("Wake: Button press (manual)");
            }
            break;
        case ESP_SLEEP_WAKEUP_TIMER:    // ESP32 timer fallback
            Serial.println("Wake: Timer fallback (RTC may have failed)");
            break;
        default:                         // Power-on / reset
            Serial.println("Wake: Cold boot");
            break;
    }
}
```

[NOTE] ESP32-C3 reports `ESP_SLEEP_WAKEUP_GPIO` (not ESP_SLEEP_WAKEUP_EXT0) for GPIO deep sleep wake.

## Step 3: Power Budget Verification

### Detailed Power Budget (per 30-minute cycle)

| Phase | Current (mA) | Duration (s) | Energy (mAs) | Source |
|-------|-------------|-------------|-------------|--------|
| Boot + Init | 80 | 0.5 | 40.00 | ESP32-C3 active current, datasheet |
| WiFi Connect | 160 | 3.0 | 480.00 | WiFi STA avg (scan+connect), datasheet |
| HTTP GET | 80 | 2.0 | 160.00 | CPU + WiFi RX, datasheet |
| NTP Sync (amortized) | ~0 | ~0 | ~0 | Once/day = negligible per cycle |
| E-ink Render (CPU) | 40 | 1.0 | 40.00 | CPU only, SPI idle [ASSUMPTION] |
| E-ink Refresh | 15 | 15.0 | 225.00 | 50mW @ 3.3V = 15.2mA, Waveshare spec |
| Sleep prep | 20 | 0.3 | 6.00 | WiFi off, GPIO config |
| Deep Sleep (ESP32-C3) | 0.044 | 1778.2 | 78.24 | XIAO board spec: 44uA |
| DS3231 RTC (always-on) | 0.0008 | 1800.0 | 1.51 | DS3231 datasheet: 0.84uA typ |
| **TOTAL** | | **1800.0** | **1030.75** | |

### Average Current and Battery Life

```
Average current = 1030.75 mAs / 1800 s = 0.573 mA (573 uA)
```

| Battery | Capacity | Estimated Life | Notes |
|---------|----------|---------------|-------|
| CR2032 | 225 mAh | ~16 days | Not recommended — too small |
| LiPo 500 mAh | 500 mAh | ~36 days | Minimum viable |
| LiPo 1000 mAh | 1000 mAh | ~73 days (~2.4 months) | Good choice |
| 18650 Li-ion | 3000 mAh | ~218 days (~7.3 months) | Best for untethered deployment |

**Formula**: Life (hours) = Battery capacity (mAh) / Average current (mA)

### Dominant Power Consumers

```
WiFi Connect:     480 mAs  (46.6% of total)
E-ink Refresh:    225 mAs  (21.8%)
HTTP GET:         160 mAs  (15.5%)
Deep Sleep:        78 mAs   (7.6%)
Everything else:   88 mAs   (8.5%)
```

**So What**: WiFi is the #1 power consumer by a wide margin. Optimizing WiFi reconnect time from 3s to 0.5s would save ~400 mAs/cycle, reducing average current to ~0.35 mA and nearly doubling battery life.

## Step 4: Power Optimization Recommendations

### Priority 1: WiFi Fast Reconnect (saves ~40% energy)

```cpp
// Store in RTC memory (survives deep sleep)
RTC_DATA_ATTR uint8_t savedBSSID[6] = {};
RTC_DATA_ATTR int32_t savedChannel = 0;

bool wifi_connect() {
    WiFi.mode(WIFI_STA);
    if (savedChannel > 0) {
        WiFi.begin(WIFI_SSID, WIFI_PASS, savedChannel, savedBSSID, true);
        // Fast path: skip scan, ~0.5s connect
    } else {
        WiFi.begin(WIFI_SSID, WIFI_PASS);
        // Slow path: full scan, ~3s connect
    }
    // ... timeout handling ...
    // Cache on success:
    memcpy(savedBSSID, WiFi.BSSID(), 6);
    savedChannel = WiFi.channel();
}
```

**Impact**: WiFi energy 480 -> 80 mAs. Total average current 0.573 -> 0.35 mA. 1000mAh battery: 73 -> 119 days.

Source: [ESP32-C3 Book — Power Optimization](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html)

### Priority 2: CPU Frequency Reduction (saves ~15% active energy)

```cpp
// In setup(), before WiFi:
setCpuFrequencyMhz(80);  // Default 160MHz -> 80MHz
// WiFi still works at 80MHz. Current drops ~30%.
```

[UNVALIDATED] Exact savings depend on whether WiFi stack requires higher clock.

### Priority 3: E-ink Power Isolation

The current firmware correctly calls `epd_sleep()` before deep sleep, sending the 0x07+0xA5 deep sleep command to the display controller. This is critical — without it, the display controller continues drawing standby current.

**Verified in code**: `epd_sleep()` sends command 0x07 (DSLP) with check code 0xA5, then releases SPI. Waveshare spec: standby current <0.01uA after sleep command.

### Priority 4: GPIO Isolation

```cpp
// Before deep sleep, isolate unused GPIOs to prevent leakage
#include <driver/rtc_io.h>
// ESP32-C3 doesn't have rtc_gpio_isolate() — use gpio_hold_en() instead
gpio_hold_en(GPIO_NUM_3);  // LED pin — hold LOW
gpio_hold_en(GPIO_NUM_5);  // SPI CS — hold HIGH (prevent e-ink wake)
gpio_deep_sleep_hold_en();
```

### Optimization Impact Summary

| Optimization | Energy Saved | Implementation Effort |
|-------------|-------------|----------------------|
| WiFi fast reconnect | ~400 mAs/cycle (40%) | Low (add 10 lines + 10B RTC) |
| CPU 80MHz | ~50 mAs/cycle (5%) | Trivial (1 line) |
| E-ink sleep | Already done | N/A |
| GPIO hold | ~5 mAs/cycle (<1%) | Low (3 lines) |

### Sources
- [ESP32-C3 Datasheet v2.1 — Section 4.4 Power Consumption](https://cdn-shop.adafruit.com/product-files/5337/esp32-c3_datasheet_en.pdf)
- [Seeed XIAO ESP32-C3 Power Tests PDF](https://files.seeedstudio.com/wiki/XIAO_WiFi/Resources/Seeed_Studio_XIAO_ESP32C3_Power_Consumption_Tests.pdf)
- [DS3231 Datasheet — Analog Devices](https://www.analog.com/media/en/technical-documentation/data-sheets/ds3231.pdf)
- [Waveshare 5.65" ACeP Product Page](https://www.waveshare.com/5.65inch-e-paper-module-f.htm)
- [ESP-IDF Sleep Modes — ESP32-C3](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/system/sleep_modes.html)
- [ESP32-C3 Power Consumption Book Chapter](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html)
- [Seeed Forum — XIAO ESP32-C3 Deep Sleep](https://forum.seeedstudio.com/t/external-wakeup-from-deep-sleep-on-xiao-esp32c3/267532)
- [arduino-esp32 Issue #7005 — ext0 not on C3](https://github.com/espressif/arduino-esp32/issues/7005)
