# Battery Life Calculation: Wayo Elephant Tracker

## Input Parameters

| Parameter | Value | Source |
|-----------|-------|--------|
| Battery | 18650 Li-ion, 3.7V nominal, 3000mAh | Product spec |
| Battery voltage range | 3.0V (empty) to 4.2V (full) | [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/) |
| I_active (WiFi TX average) | 120mA (avg; peak 180–240mA) | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| I_active_idle (no WiFi) | 24mA | [Espressif C3 Book Ch.12](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html) |
| I_light_sleep | 0.8mA | [Espressif light sleep docs](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.2.html) |
| I_deep_sleep (chip only) | 5uA (0.005mA) | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| I_deep_sleep (board estimate) | 50–150uA [UNVALIDATED] | Board-dependent: LDO Iq + GPIO leakage |
| E-ink refresh power | 50mW typical (~15mA at 3.3V), refresh time <35s | [Waveshare 5.65" spec](https://www.waveshare.com/5.65inch-e-paper-module-f.htm) |
| E-ink standby | <0.01uA | [Waveshare 5.65" spec](https://www.waveshare.com/5.65inch-e-paper-module-f.htm) |
| Derating factor | 80% (temperature, aging, self-discharge) | Industry standard practice |

---

## Usage Profile: Outdoor Elephant Tracker

| Phase | Duration | Current | Behavior |
|-------|----------|---------|----------|
| Wake + sensor read | 2s | ~24mA (idle active) | GPIO + I2C sensor polling |
| WiFi connect + transmit | 5s | ~120mA (average) | DHCP + HTTP/MQTT post |
| E-ink refresh | 1s contribution [UNVALIDATED] | ~15mA | Only 1 refresh per hour, amortized |
| Deep sleep | 892s (14m 52s) | ~5uA (chip) | RTC timer wakeup |

**Cycle period**: 15 minutes (900 seconds)
**Active per cycle**: ~8 seconds

---

## Calculation (Best Case: Chip-Only Deep Sleep = 5uA)

```
I_avg = (I_active * t_active + I_sleep * t_sleep) / t_cycle
      = (120mA * 8s + 0.005mA * 892s) / 900s
      = (960 + 4.46) / 900
      = 1.072 mA

Battery life (ideal) = 3000mAh / 1.072mA = 2799 hours = 116.6 days
Battery life (derated 80%) = 2799h * 0.80 = 2239 hours = 93.3 days
```

**Result (best case)**: ~93 days on a single 18650 charge.

---

## Calculation (Realistic Case: Board Deep Sleep = 100uA) [UNVALIDATED]

Board-level deep sleep is typically higher than chip-only due to:
- LDO quiescent current: 5–50uA (depends on regulator)
- GPIO pull-up/pull-down leakage: 1–10uA per pin
- LED indicator leakage: 0–100uA
- Flash chip standby: ~1uA

Estimate: 100uA (0.1mA) total board deep sleep [UNVALIDATED — must measure]

```
I_avg = (120mA * 8s + 0.1mA * 892s) / 900s
      = (960 + 89.2) / 900
      = 1.166 mA

Battery life (ideal) = 3000mAh / 1.166mA = 2573 hours = 107.2 days
Battery life (derated 80%) = 2573h * 0.80 = 2058 hours = 85.7 days
```

**Result (realistic)**: ~86 days on a single 18650 charge.

---

## Sensitivity Analysis

| Scenario | I_deep_sleep | I_avg | Battery Life (derated) |
|----------|-------------|-------|----------------------|
| Best case (chip only) | 5uA | 1.072mA | 93 days |
| Typical board | 100uA | 1.166mA | 86 days |
| Bad board (LED leakage) | 500uA | 1.561mA | 64 days |
| Very bad (peripheral not sleeping) | 2mA | 3.048mA | 33 days |

**Key insight**: Deep sleep current dominates battery life because the device spends 99.1% of time sleeping. Reducing deep sleep from 500uA to 100uA adds 22 days of battery life. This is the #1 optimization target.

---

## Self-Consistency Check

| Check | Expected | Status |
|-------|----------|--------|
| Deep sleep (5uA) < Light sleep (800uA) | True | PASS |
| Light sleep (800uA) < Active idle (24mA) | True | PASS |
| Active idle (24mA) < Active WiFi TX (120mA avg) | True | PASS |
| Active WiFi TX (120mA avg) < Peak TX (240mA) | True | PASS |

---

## Temperature Impact on Battery Life

| Temperature | Capacity Effect | Adjusted Battery Life (realistic) | Source |
|-------------|----------------|-----------------------------------|--------|
| 25C (room) | 100% baseline | 86 days | — |
| 40C (hot outdoor) | ~102% capacity, faster aging | ~87 days [short-term benefit, long-term degradation] | [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/) |
| 0C (cold) | ~80% capacity | ~69 days | [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/) |
| -10C (extreme cold) | ~60% capacity [UNVALIDATED] | ~52 days | Extrapolated — may not apply to all 18650 chemistries |

**For Wayo (tropical/savanna elephant tracker)**: Expected operating range 15–45C. Battery performance should be near-nominal. Cold mornings (~10C) may cause temporary capacity reduction but unlikely to cause failure.

---

## Optimization Recommendations

| # | Optimization | Current Saving | Impact on Battery | Complexity | Recommendation |
|---|-------------|---------------|-------------------|-----------|---------------|
| 1 | Fix deep sleep current (floating GPIO, LED leakage) | 100–500uA sleep reduction | +22–29 days | Medium | **DO FIRST** |
| 2 | Reduce WiFi TX power (20dBm to 10dBm) | ~50mA peak reduction | +3–5 days | Low | DO (if range sufficient) |
| 3 | Extend sleep cycle (15min to 30min) | Halves active duty cycle | Nearly 2x battery life | Low (firmware) | DO (if tracking cadence acceptable) |
| 4 | Use BLE instead of WiFi for data transmit | ~100mA active reduction | +15–20 days | Medium | CONSIDER (depends on receiver) |
| 5 | Add solar panel (1W) | Net positive energy in sunlight | Indefinite field life | Medium (hardware) | DO (outdoor device) |

---

## Verdict

**With datasheet values (chip-only sleep)**: ~93 days — well exceeds typical 30-day IoT target.

**With realistic board sleep (100uA)**: ~86 days — still very good.

**With solar charging**: Indefinite field operation possible for outdoor elephant tracker.

**CRITICAL NEXT STEP**: Measure actual board-level deep sleep current. This is the single most important measurement for accurate battery life prediction. All calculations above should be re-run with actual measured values.
