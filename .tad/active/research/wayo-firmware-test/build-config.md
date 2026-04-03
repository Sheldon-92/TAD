# Build & Upload Configuration — Wayo Elephant Tracker

## Step 1: Build Configuration

### Board Selection

| Parameter | Value | Source |
|-----------|-------|--------|
| FQBN | `esp32:esp32:esp32c3` | sketch.yaml, verified via `arduino-cli board listall` |
| Also valid | `esp32:esp32:XIAO_ESP32C3` | Seeed-specific board variant [UNVALIDATED — may not be in core] |
| Platform | esp32:esp32 v3.3.6 | Verified installed |
| CPU | RISC-V single-core, 160MHz | ESP32-C3 spec |
| Flash | 4MB | XIAO ESP32-C3 spec |
| SRAM | 400KB (320KB usable + 16KB RTC) | Datasheet |

### Partition Table (Default for 4MB Flash)

| Partition | Offset | Size | Purpose |
|-----------|--------|------|---------|
| nvs | 0x9000 | 20KB | WiFi config, NVS storage |
| otadata | 0xE000 | 8KB | OTA boot selection |
| app0 | 0x10000 | 1.25MB (1,310,720 bytes) | Main firmware |
| app1 | 0x150000 | 1.25MB | OTA update slot |
| spiffs | 0x290000 | 1.5MB | File system |

**Note**: Wayo currently uses 72% of app0 (minimal test). Full firmware with ArduinoJson and renderer may push to ~80%. If space becomes tight, consider `huge_app.csv` partition (3MB app, no OTA) — acceptable since Wayo is USB-flashed.

### Library Dependencies

| Library | Required Version | Installed Version | Status |
|---------|-----------------|-------------------|--------|
| ArduinoJson | 7.3.0 (sketch.yaml) | 6.21.5 (arduino-cli) | **MISMATCH** |
| WiFi | built-in | 3.3.6 | OK |
| Wire | built-in | 3.3.6 | OK |
| SPI | built-in | 3.3.6 | OK |
| HTTPClient | built-in | 3.3.6 | OK |
| RTClib | 2.1.4 (sketch.yaml) | [not used in code] | sketch.yaml lists but code uses custom driver |

**Issue Found**: The sketch.yaml specifies ArduinoJson 7.3.0, but the installed version is 6.21.5. ArduinoJson v7 has API changes — `JsonDocument` constructor is different. The code uses `JsonDocument doc;` which is v7 syntax (v6 uses `StaticJsonDocument<N>` or `DynamicJsonDocument`).

**Fix**: Either install ArduinoJson 7.3.0 or update code to v6 API:
```bash
# Option A: Install matching version
arduino-cli lib install "ArduinoJson@7.3.0"

# Option B: Adapt code to v6
# Replace: JsonDocument doc;
# With:    DynamicJsonDocument doc(JSON_DOC_CAPACITY);
```

## Step 2: Compile Workflow

### Compile Commands

```bash
# Step 1: Ensure correct library version
arduino-cli lib install "ArduinoJson@7.3.0"

# Step 2: Compile
arduino-cli compile \
  --fqbn esp32:esp32:esp32c3 \
  ./projects/Wayo/firmware/

# Step 3: Upload (when board connected)
arduino-cli upload \
  -p /dev/cu.usbmodem* \
  --fqbn esp32:esp32:esp32c3 \
  ./projects/Wayo/firmware/

# Step 4: Monitor
arduino-cli monitor -p /dev/cu.usbmodem* --config baudrate=115200
```

**Note**: The firmware directory is named `firmware/` but the .ino file is `Wayo.ino`. Arduino requires the .ino filename to match the directory name. Either:
- Rename directory to `Wayo/`, or
- Use a temporary copy for compilation (as done in this test)

### sketch.yaml Configuration

```yaml
default_fqbn: esp32:esp32:XIAO_ESP32C3
profiles:
  default:
    fqbn: esp32:esp32:XIAO_ESP32C3
    platforms:
      - platform: esp32:esp32 (3.3.6)
    libraries:
      - ArduinoJson (7.3.0)
      - RTClib (2.1.4)
```

**Issue**: FQBN `esp32:esp32:XIAO_ESP32C3` may not exist in the standard esp32 core. Verified boards include `esp32:esp32:esp32c3` (generic C3 dev module). The XIAO-specific variant may require Seeed's board package.

## Step 3: Compile Verification Results

### Test 1: Full Wayo Firmware

**Command**: `arduino-cli compile --fqbn esp32:esp32:esp32c3 /tmp/wayo-compile-test/Wayo`

**Result**: FAILED (6 errors)

| # | Error | File:Line | Root Cause | Fix |
|---|-------|-----------|-----------|-----|
| 1 | `esp_sleep_enable_ext0_wakeup` not declared | Wayo.ino:262 | ESP32-C3 lacks ext0 API | Use `esp_deep_sleep_enable_gpio_wakeup()` |
| 2 | `esp_sleep_enable_ext0_wakeup` not declared | Wayo.ino:393 | Same as above | Same fix |
| 3 | `JsonDocument()` is protected | Wayo.ino:204 | ArduinoJson v6 vs v7 API | Install v7 or use DynamicJsonDocument |
| 4 | `JsonDocument::~JsonDocument()` is protected | Wayo.ino:204 | Same as above | Same fix |
| 5 | `weak declaration must be public` | renderer.cpp:11 | const + weak attribute conflict | Remove `const` or use different linkage |
| 6 | `weak declaration must be public` | renderer.cpp:12 | Same as above | Same fix |

**Warnings**: 0 (only errors)

### Test 2: Minimal Deep Sleep Sketch (Correct API)

**Command**: `arduino-cli compile --fqbn esp32:esp32:esp32c3 /tmp/wayo-minimal-test/WayoMinimal`

**Result**: PASS

```
Sketch uses 954440 bytes (72%) of program storage space. Maximum is 1310720 bytes.
Global variables use 34588 bytes (10%) of dynamic memory, leaving 293092 bytes for local variables. Maximum is 327680 bytes.
```

| Metric | Value | Limit | Percentage | Budget | Status |
|--------|-------|-------|------------|--------|--------|
| Flash | 954,440 B | 1,310,720 B | 72% | <75% | PASS |
| RAM (global) | 34,588 B | 327,680 B | 10% | <60% | PASS |

### Minimal Test Sketch (proves correct API compiles)

```cpp
#include <WiFi.h>
#include <Wire.h>
#include "esp_sleep.h"

RTC_DATA_ATTR int bootCount = 0;

void enter_deep_sleep() {
    // ESP32-C3 correct API:
    esp_deep_sleep_enable_gpio_wakeup(1ULL << 2, ESP_GPIO_WAKEUP_GPIO_LOW);
    esp_sleep_enable_timer_wakeup(30ULL * 60 * 1000000);
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    Serial.flush();
    esp_deep_sleep_start();
}

void setup() {
    Serial.begin(115200);
    bootCount++;
    Serial.printf("Boot #%d\n", bootCount);
    esp_sleep_wakeup_cause_t reason = esp_sleep_get_wakeup_cause();
    Serial.printf("Wake reason: %d\n", reason);
    Wire.begin(6, 7);
    pinMode(2, INPUT_PULLUP);
    pinMode(3, OUTPUT);
    delay(100);
    enter_deep_sleep();
}

void loop() { delay(100); }
```

## Step 4: Build Optimization

### Recommended Build Fixes (Priority Order)

1. **Fix ext0 wakeup** (blocks compilation):
   - Replace `esp_sleep_enable_ext0_wakeup(GPIO_NUM_2, 0)` with `esp_deep_sleep_enable_gpio_wakeup(1ULL << PIN_BUTTON, ESP_GPIO_WAKEUP_GPIO_LOW)` in both locations (line 262 and 393)

2. **Fix ArduinoJson version** (blocks compilation):
   - Run `arduino-cli lib install "ArduinoJson@7.3.0"` to match sketch.yaml
   - Or change code to v6 API: `DynamicJsonDocument doc(JSON_DOC_CAPACITY);`

3. **Fix weak symbol visibility** (blocks compilation):
   - In renderer.cpp, change:
     ```cpp
     // From:
     const uint8_t __attribute__((weak)) base_map_data[] PROGMEM = {};
     // To:
     __attribute__((weak)) const uint8_t base_map_data[] PROGMEM = {};
     ```
   - Or remove `const` from the weak definitions

4. **Fix directory name** (workflow issue):
   - Rename `firmware/` to `Wayo/` so the .ino filename matches the directory

### Build Reproducibility

The sketch.yaml provides reproducible build configuration with pinned library versions and platform version. This is good practice. However, the FQBN `esp32:esp32:XIAO_ESP32C3` should be verified to exist in the standard esp32 core or documented that it requires Seeed's board package.

### Sources
- arduino-cli compile output (actual test run, 2026-04-03)
- [ESP-IDF Sleep Modes — ESP32-C3](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-reference/system/sleep_modes.html)
- [ArduinoJson v7 Migration Guide](https://arduinojson.org/v7/how-to/upgrade-from-v6/)
- [arduino-esp32 Issue #7005](https://github.com/espressif/arduino-esp32/issues/7005)
- [ESP32-C3 Deep Sleep Wake-up Issue #8510](https://github.com/espressif/arduino-esp32/issues/8510)
