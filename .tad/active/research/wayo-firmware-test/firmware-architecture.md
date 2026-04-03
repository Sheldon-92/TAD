# Firmware Architecture — Wayo Elephant Tracker

## Step 1: Architecture Pattern Selection

### Project Requirements Analysis
- **MCU**: Seeed XIAO ESP32-C3 (single-core RISC-V, 160MHz, 400KB SRAM, 4MB Flash)
- **Peripherals**: E-ink display (SPI), DS3231 RTC (I2C), button (GPIO), LED (GPIO)
- **Duty cycle**: ~22s active per 30-minute cycle (<1.2% duty cycle)
- **Primary behavior**: Wake -> Fetch -> Render -> Sleep

### Selected: Event-Driven (Deep Sleep dominant)

| Criteria | Assessment |
|----------|-----------|
| External peripherals | 3 (E-ink, RTC, button) — well under 5 threshold |
| Real-time requirement | None — E-ink refresh takes 15s anyway |
| Duty cycle | <1.2% — Deep Sleep yields massive power savings |
| Concurrency needed | No — phases are strictly sequential |
| ESP32-C3 cores | Single-core only (no FreeRTOS multi-core benefit) |

**Decision**: Event-driven with Deep Sleep is the correct choice. The existing Wayo firmware already implements this correctly — `setup()` runs the full cycle, `loop()` is never reached in normal operation. This is the canonical ESP32 deep sleep pattern.

**Why NOT Super Loop**: The device spends 99% of time sleeping. A super loop with `millis()` gating would waste power keeping the CPU active.

**Why NOT FreeRTOS**: ESP32-C3 is single-core. FreeRTOS tasks add overhead with no parallelism benefit. All operations are sequential (WiFi -> fetch -> render -> sleep).

## Step 2: Module Structure Design

### Current Wayo Module Layout (Analyzed from source)

```
Wayo/firmware/
  Wayo.ino          — setup() cycle orchestrator + WiFi + NTP + API fetch + sleep
  config.h          — All pins, thresholds, API URLs, display params, GPS bounds
  ds3231.h/.cpp     — DS3231 RTC driver (I2C, alarm set, time get/set)
  epd_driver.h/.cpp — 7-color ACeP e-ink driver (SPI, line-by-line streaming)
  renderer.h/.cpp   — Line-by-line display rendering (map + text overlay)
  font8x8.h         — 8x8 bitmap font in PROGMEM (760 bytes)
  sketch.yaml       — arduino-cli project config (FQBN + library deps)
```

### Module Dependency Graph

```
config.h (standalone — no includes)
    |
    +-- ds3231.h/.cpp (depends: config.h, Wire.h)
    +-- epd_driver.h/.cpp (depends: config.h, SPI.h)
    +-- font8x8.h (standalone)
    +-- renderer.h/.cpp (depends: config.h, epd_driver.h, font8x8.h)
    |
    +-- Wayo.ino (depends: all of the above + WiFi.h, HTTPClient.h, ArduinoJson.h)
```

### Assessment Against Domain Pack Standards

| Criterion | Status | Notes |
|-----------|--------|-------|
| config.h is single source of truth | PASS | All pins have GPIO# + physical label comments |
| I2C addresses centralized | PASS | DS3231 at 0x68, defined in ds3231.h |
| Time constants use _MS suffix | PARTIAL | WIFI_CONNECT_TIMEOUT_MS, HTTP_TIMEOUT_MS (good), but UPDATE_INTERVAL_MIN uses _MIN |
| Drivers return bool from init() | PASS | ds3231_init() returns bool, epd_init() is void [ISSUE] |
| No delay() in drivers | PARTIAL | epd_wait_busy() uses delay(100) polling — acceptable for e-ink |
| Serial logging prefix | PARTIAL | Uses "WiFi:", "API:", "RTC:" — not [OK]/[WARN]/[ERR] format |

### Recommended Improvements

1. **Missing: power.h module** — Deep sleep logic is embedded in Wayo.ino. Should be extracted to a `power.h` with `enter_deep_sleep()`, `print_wake_reason()`.
2. **Missing: network.h module** — WiFi connect/disconnect and HTTP fetch are in Wayo.ino. Should be extracted (matches _template pattern).
3. **epd_init() should return bool** — Currently void, no way to detect display failure.
4. **state.h not needed** — The firmware has no persistent state machine (it's a one-shot cycle), so a dedicated state module is unnecessary. The `ElephantData` struct in renderer.h serves as the data contract.

## Step 3: Architecture Verification

### Compile Test Results

**FQBN**: `esp32:esp32:esp32c3`

**Full Wayo firmware compile**: FAILED (6 errors)

| Error | File | Issue |
|-------|------|-------|
| `esp_sleep_enable_ext0_wakeup` not declared | Wayo.ino:262, 393 | **ESP32-C3 does NOT support ext0/ext1 wakeup** [BUG] |
| `JsonDocument()` is protected | Wayo.ino:204 | ArduinoJson v7 API change (installed 6.21.5 but sketch.yaml says 7.3.0) |
| `weak declaration must be public` | renderer.cpp:11,12 | Weak attribute on const PROGMEM arrays |

**Critical Bug Found**: `esp_sleep_enable_ext0_wakeup()` is NOT available on ESP32-C3. The C3 uses `esp_deep_sleep_enable_gpio_wakeup()` instead. This is a **platform API difference** between ESP32 (has ext0/ext1) and ESP32-C3 (has GPIO wakeup only).

**Fix**: Replace both calls with:
```cpp
esp_deep_sleep_enable_gpio_wakeup(1ULL << PIN_BUTTON, ESP_GPIO_WAKEUP_GPIO_LOW);
```

**Minimal compile test** (with correct API): PASS
- Flash: 954,440 bytes (72%) of 1,310,720 bytes
- RAM: 34,588 bytes (10%) of 327,680 bytes

Source: [ESP-IDF docs — ESP32-C3 Sleep Modes](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/system/sleep_modes.html)

### Memory Budget (from minimal test)

| Resource | Used | Total | Percentage | Budget Limit | Status |
|----------|------|-------|------------|-------------|--------|
| Flash | 954 KB | 1280 KB | 72% | <75% | PASS (close) |
| RAM | 34 KB | 320 KB | 10% | <60% | PASS |

[NOTE] Full firmware will use more due to ArduinoJson, renderer, fonts. Estimate ~80% Flash after fixes.

### Init Sequence Analysis

```
setup()
  1. Serial.begin(115200)        — UART
  2. Wire.begin(SDA=6, SCL=7)   — I2C bus
  3. ds3231_init()               — RTC on I2C (returns bool, OK)
  4. pinMode(PIN_BUTTON)         — GPIO
  5. epd_init()                  — SPI + display (creates SPIClass)
  6. WiFi connect                — WiFi STA (heaviest, last — CORRECT)
  7. HTTP fetch                  — Network
  8. E-ink render + refresh      — Display
  9. epd_sleep()                 — Display power down
  10. Deep Sleep                 — MCU power down
```

**Bus sharing**: I2C (RTC) and SPI (E-ink) are separate buses — no conflict.
**Init order**: Correct — lightweight peripherals first, WiFi last.

## Step 4: Optimization Assessment

| Check | Status | Notes |
|-------|--------|-------|
| Config centralization | PASS | All pins, timeouts, GPS bounds in config.h |
| No magic numbers | PASS | Constants defined with descriptive names |
| Error recovery | PARTIAL | RTC failure has fallback (ESP32 timer), WiFi failure shows error screen, but epd_init failure has no recovery |
| Non-blocking loop() | N/A | loop() is never reached in normal operation |
| PROGMEM for large data | PASS | font8x8, base_map_data both use PROGMEM |
| Line-by-line rendering | PASS | 300-byte line buffer instead of 134KB full framebuffer — essential for C3's limited RAM |

### State Machine Completeness

The Wayo firmware does NOT use a traditional state machine — it uses a **single-pass pipeline**:

```
[Boot] -> [Init HW] -> [WiFi] -> [Fetch] -> [Render] -> [Sleep]
                          |fail      |fail
                          v          v
                       [Error Screen] -> [Sleep]
```

This is the correct pattern for a deep-sleep-dominant device. A state machine would add complexity with no benefit since there are no persistent states across sleep cycles (only RTC_DATA_ATTR variables survive).

### Sources
- [ESP32-C3 Datasheet v2.1](https://cdn-shop.adafruit.com/product-files/5337/esp32-c3_datasheet_en.pdf)
- [ESP-IDF Sleep Modes — ESP32-C3](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/system/sleep_modes.html)
- [Seeed XIAO ESP32-C3 Power Consumption Tests (PDF)](https://files.seeedstudio.com/wiki/XIAO_WiFi/Resources/Seeed_Studio_XIAO_ESP32C3_Power_Consumption_Tests.pdf)
- [espressif/arduino-esp32 Issue #7005 — ext0 not available on C3](https://github.com/espressif/arduino-esp32/issues/7005)
- [Waveshare 5.65" ACeP Module Wiki](https://www.waveshare.com/wiki/5.65inch_e-Paper_Module_(F)_Manual)
