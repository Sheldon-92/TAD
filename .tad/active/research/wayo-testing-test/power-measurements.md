# Power Measurements: Wayo Prototype

> **Status**: MEASUREMENT TEMPLATE — replace expected values with actuals during testing.
> **Board Rev**: ____ | **Date**: ____ | **Tester**: ____ | **Ambient Temp**: ____ C

---

## Measurement Procedure

### Active Mode (WiFi TX) — Worst Case
1. Firmware: trigger display refresh + WiFi TX + sensor read simultaneously
2. Instrument: bench supply current readout (or oscilloscope for peak capture)
3. Measurement window: full active cycle from wake to sleep entry

| Parameter | Expected (from datasheet/research) | Measured | Source |
|-----------|------------------------------------|----------|--------|
| Peak current (WiFi TX burst) | 180–240mA | ___ mA | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| Average current (active period) | ~120mA | ___ mA | Estimated: WiFi TX + MCU + display |
| E-ink refresh current contribution | ~15mA (50mW/3.3V) | ___ mA | [Waveshare spec](https://www.waveshare.com/5.65inch-e-paper-module-f.htm) |
| Active duration | 5–10 seconds | ___ seconds | Firmware-dependent |

### Active Mode (Idle, No WiFi)
1. WiFi and BLE off, display static, CPU running
2. Wait >5 seconds for stabilization
3. Record over 30-second window

| Parameter | Expected | Measured | Source |
|-----------|----------|----------|--------|
| Average current | ~24mA | ___ mA | [Espressif C3 Book Ch.12](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html) |

### Light Sleep
1. Enter light sleep via `esp_light_sleep_start()`
2. Timer wakeup configured (e.g., 60s)
3. Measure on mA range

| Parameter | Expected | Measured | Source |
|-----------|----------|----------|--------|
| Light sleep current | ~0.8mA | ___ mA | [Espressif light sleep docs](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.2.html) |

### Deep Sleep — CRITICAL for Battery Life
1. Enter deep sleep via `esp_deep_sleep_start()`
2. **Switch multimeter to uA range BEFORE entering sleep**
3. Wait 10 seconds for reading to stabilize
4. Record multiple readings over 30 seconds

| Parameter | Expected | Measured | Source |
|-----------|----------|----------|--------|
| Deep sleep current (chip only) | ~5uA | ___ uA | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| Deep sleep current (with board peripherals) | 10–150uA [UNVALIDATED] | ___ uA | Board-dependent (LDO Iq, LED leakage, pullups) |

**Red flag**: If deep sleep reading >150uA, suspect:
- Peripheral not powered down (check LDO quiescent current)
- LED leakage through GPIO (~100uA per LED)
- Floating GPIO pin (enable internal pulldown)
- Flash chip not entering sleep mode

### Self-Consistency Check
| Check | Expected | Result |
|-------|----------|--------|
| Deep sleep < Light sleep? | Yes (5uA << 800uA) | ___ |
| Light sleep < Active idle? | Yes (800uA << 24mA) | ___ |
| Active idle < Active WiFi TX? | Yes (24mA << 120mA) | ___ |

If any check fails, re-measure — likely a measurement error or peripheral not entering expected state.
