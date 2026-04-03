# Wayo Elephant Tracker — Power Design Report

> Generated: 2026-04-02
> Domain Pack: hw-circuit-design v1.0.0 / capability: power_design

---

## 1. Power Architecture

### 1.1 Input Sources
- **USB 5V**: Charging input via USB-C (or Micro-USB)
- **LiPo 3.7V**: Primary runtime power source (1S LiPo, 3.0-4.2V range)

### 1.2 Voltage Domains
| Domain | Voltage | Consumers | Source |
|--------|---------|-----------|--------|
| VBUS | 5V | TP4056 charger input | USB |
| VBAT | 3.0-4.2V | Battery terminal, LDO input | LiPo battery |
| VCC_3V3 | 3.3V | ESP32-C3, E-ink logic, DS3231 | RT9080 LDO from VBAT |

### 1.3 Power Topology

```
USB 5V ──→ [TP4056 Charger] ──→ LiPo Battery (3.7V nom)
                                      │
                                      ├──→ [RT9080 LDO 3.3V] ──→ ESP32-C3
                                      │         │                    │ (SPI)
                                      │         ├──→ DS3231 RTC     ├──→ E-ink display
                                      │         │ (I2C)             │
                                      │         └──→ E-ink logic    └──→ BLE antenna
                                      │
                                      └──→ DS3231 VBAT pin (backup timekeeping)
```

### 1.4 Architecture Decisions
- **LDO chosen over DCDC**: Battery voltage (3.0-4.2V) to 3.3V has small dropout (<0.9V). LDO simpler, lower noise, no inductor needed. DCDC efficiency advantage negligible at low average currents (<1mA).
- **No separate E-ink power rail**: E-ink module has onboard boost for VCOM/gate drive. Powered from 3.3V logic rail. Simplifies design.
- **RTC dual-power**: DS3231 VCC from 3.3V rail (normal operation). VBAT from battery direct (backup timekeeping when LDO disabled). This ensures time is never lost.

---

## 2. Power Budget (Detailed)

### 2.1 Component Current Consumption

All values from datasheets unless marked otherwise.

| Module | Mode | Voltage (V) | Current (mA) | Source |
|--------|------|-------------|---------------|--------|
| **ESP32-C3 (module)** | Active WiFi TX | 3.3 | 350 | Datasheet Table 14 |
| | Active WiFi RX | 3.3 | 80 | Datasheet Table 14 |
| | Modem Sleep | 3.3 | 15 | Datasheet Table 14 |
| | Deep Sleep | 3.3 | 0.00814 | ESP-IDF measured (module) |
| **E-ink 5.65" ACeP** | Refresh | 3.3 | 15.15 | Spec: 50mW typical |
| | Standby | 3.3 | 0.00001 | Spec: <0.01uA |
| **DS3231 RTC** | Active I2C | 3.3 | 0.200 | Datasheet typ @3.3V |
| | Idle on VCC | 3.3 | 0.100 | Datasheet typ @3.3V |
| | Timekeeping (VBAT) | 3.0 | 0.00084 | Datasheet typ @3V |
| **RT9080 LDO** | Quiescent | — | 0.002 | Datasheet typ |

**Sources**:
- ESP32-C3 Datasheet: https://www.elecrow.com/download/product/DIS12824D/esp32-c3_datasheet.pdf
- ESP-IDF Current Measurement: https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-guides/current-consumption-measurement-modules.html
- Waveshare 5.65" Spec: https://www.waveshare.com/w/upload/7/7a/5.65inch_e-Paper_(F)_Sepecification.pdf
- DS3231 Datasheet: https://www.analog.com/media/en/technical-documentation/data-sheets/ds3231.pdf
- RT9080 Datasheet: https://www.richtek.com/assets/product_file/RT9080/DS9080-09.pdf

### 2.2 Scenario Analysis

**Battery**: 2000 mAh LiPo
**Usable capacity**: 1440 mAh (0.8 derating x 0.9 temp derating)

#### Scenario 1: Normal Mode (Hourly Wake, Daily Display Refresh)
- Wake every 1 hour for 10s (BLE beacon, sensor read)
- Display refresh once per day (35s active)
- **Average current: 0.371 mA**
- **Battery life: 162 days (~5.4 months)**

| Phase | Duration | Current | Duty Cycle |
|-------|----------|---------|------------|
| Wake (BLE beacon) | 10s/hour | 80.2 mA | 0.278% |
| Display refresh | 35s/day | 95.3 mA | 0.041% |
| Deep sleep | remainder | 0.110 mA | 99.68% |

#### Scenario 2: Power Save (6-Hourly Wake, Daily Refresh)
- Wake every 6 hours for 10s
- Display refresh once per day
- **Average current: 0.186 mA**
- **Battery life: 323 days (~10.7 months)**

#### Scenario 3: High Frequency (10-Min Wake, Hourly Refresh)
- Wake every 10 minutes for 10s
- Display refresh every hour
- **Average current: 2.371 mA**
- **Battery life: 25 days**

### 2.3 "So What" — What This Data Means

1. **Deep sleep current dominates**: In Normal mode, 99.68% of the time is spent in deep sleep. The 0.110 mA sleep current (dominated by DS3231 idle 100uA + LDO Iq 2uA) accounts for ~30% of total energy consumption. **Optimizing sleep current matters more than optimizing wake current.**

2. **E-ink refresh is expensive but infrequent**: Each refresh costs 95.3mA x 35s = 0.926 mAh. At once/day, this is only 0.926 mAh/day out of ~8.9 mAh/day total (Normal mode). Acceptable.

3. **If PCF8563 were used instead of DS3231**: Sleep current drops from 0.110 mA to ~0.012 mA (100uA saved from RTC idle). This would extend Normal mode from 162 days to ~550 days. **RTC choice significantly impacts battery life.** [TRADEOFF: accuracy vs battery life]

4. **LDO thermal is marginal at peak TX**: At 350mA peak, LDO dissipates 315mW. Junction temperature reaches ~119°C (limit 125°C) at 40°C ambient. This is technically PASS but has only 6°C margin. **Recommendation: ensure WiFi TX bursts are short (<5s) and avoid TX during charging (higher ambient temp from TP4056 heat).**

---

## 3. Verification

### 3.1 LDO Output Capacity
- RT9080 max output: 600 mA
- Peak load (realistic): 350.1 mA (WiFi TX, not simultaneous with E-ink refresh)
- **Margin: 71% — PASS** (requirement: >30%)

### 3.2 LDO Thermal
- P_dissipated = (4.2V - 3.3V) x 350mA = 315 mW
- Tj = 40°C + 315mW x 250°C/W = 118.8°C
- **PASS** (max 125°C) but **marginal — monitor in testing** [UNVALIDATED: thermal resistance 250°C/W is estimated for TSOT-23-5]

### 3.3 Battery Discharge Rate
- Peak current: 350 mA
- Battery C-rate: 350/2000 = 0.175C
- **PASS** — well within LiPo safe discharge range (typically 1-2C continuous)

### 3.4 Charging Time
- Charge current: 500 mA (TP4056, RPROG = 2.4kΩ)
- Time: 2000mAh / 500mA x 1.2 = **4.8 hours**

### 3.5 Power Sequencing
1. Battery inserted → VBAT available → DS3231 VBAT active (timekeeping)
2. LDO EN pulled high → VCC_3V3 rises → ESP32-C3 starts boot
3. ESP32 firmware initializes → configures GPIOs → enables E-ink power (if GPIO-controlled)
4. Sleep: ESP32 enters deep sleep → RTC alarm triggers wake via INT pin → GPIO wake-up

### 3.6 Abnormal Scenarios
| Scenario | Behavior | Protection |
|----------|----------|------------|
| USB unplugged during charge | TP4056 stops charging, system runs on battery seamlessly | TP4056 auto-detect |
| Battery low (3.0V) | ESP32 brown-out detection triggers safe shutdown | ESP32 BOD + software |
| Battery depleted (<2.5V) | LDO cannot regulate → system off. DS3231 runs on VBAT backup | DS3231 auto-switch to VBAT |
| Overtemp during charge | TP4056 thermal foldback reduces charge current | TP4056 135°C foldback |

---

## 4. Optimization Recommendations

1. **Switch to PCF8563 RTC** if ±20ppm accuracy is acceptable — saves ~100uA in sleep, nearly doubles battery life in Normal mode
2. **Add GPIO-controlled E-ink power switch** (MOSFET on E-ink VCC) — saves E-ink standby current and provides clean power-on for refresh
3. **Consider 3000 mAh battery** if enclosure permits — scales all scenarios proportionally (+50%)
4. **For Power Save mode, disable DS3231 SQW/32kHz outputs** via register — reduces DS3231 idle current by ~50uA
5. **LDO thermal concern**: If sustained WiFi usage needed, consider ME6211 backup (handles 500mA) or add small copper pour under LDO footprint for heat spreading
