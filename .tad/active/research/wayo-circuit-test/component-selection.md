# Wayo Elephant Tracker — Component Selection Report

> Generated: 2026-04-02
> Domain Pack: hw-circuit-design v1.0.0 / capability: component_selection

---

## 1. System Requirements

**Product**: Wayo 大象追踪器
**Function**: GPS/BLE tracker with 7-color E-ink display, battery-powered, RTC for scheduled wake
**Use Cases**:
1. **Wildlife researchers**: Long deployment (months), infrequent data refresh, rugged environment
2. **Zoo/sanctuary staff**: Daily status display, moderate battery life, indoor/outdoor
3. **Conservation education**: Visual display for public, color graphics, periodic update

---

## 2. Component Candidates & Analysis

### 2.1 MCU Module

| Parameter | ESP32-C3-MINI-1-N4 | ESP32-C3-MINI-1-H4 | ESP32-S3-MINI-1-N8 |
|-----------|---------------------|---------------------|---------------------|
| Core | RISC-V single-core 160MHz | RISC-V single-core 160MHz | Xtensa dual-core 240MHz |
| Flash | 4MB | 4MB | 8MB |
| GPIO | 22 (15 usable on module) | 22 (15 usable on module) | 36 |
| WiFi/BLE | WiFi 4 + BLE 5.0 | WiFi 4 + BLE 5.0 | WiFi 4 + BLE 5.0 |
| Deep Sleep | ~5uA (chip), ~8.14uA (module measured) | ~5uA (chip), ~8uA (module) | ~7uA (chip) |
| Active TX | ~350mA peak | ~350mA peak | ~500mA peak |
| Package | 13.2x16.6mm (PCB antenna) | 13.2x16.6mm (IPEX antenna) | 15.4x20.5mm |
| LCSC Price (1K) | ~$2.01 | ~$2.17 | ~$2.86 |
| Supply Status | In stock, multi-source | In stock | In stock |

**Sources**:
- ESP32-C3 Datasheet: https://www.elecrow.com/download/product/DIS12824D/esp32-c3_datasheet.pdf
- LCSC ESP32-C3-MINI-1-N4: https://lcsc.com/product-detail/RF-Modules_Espressif-Systems-ESP32-C3-MINI-1-N4_C2838502.html
- ESP-IDF Power Measurement: https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/api-guides/current-consumption-measurement-modules.html

**Selection**: **ESP32-C3-MINI-1-N4** (Primary)
- Rationale: 15 usable GPIOs sufficient for SPI E-ink + I2C RTC + UART debug. Lowest deep sleep current. Cheapest. PCB antenna simplifies design.
- Backup: ESP32-C3-MINI-1-H4 (pin-compatible, adds IPEX connector for external antenna if RF range insufficient)
- [TRADEOFF]: GPIO count is tight. ESP32-C3 has only 22 GPIOs (some occupied by flash). If sensor expansion needed later, may need to move to ESP32-S3.

**Supply Chain Risk**: **LOW** — Espressif is multi-source (LCSC, DigiKey, Mouser all stock). Active product, no EOL notice.

---

### 2.2 Display Module

| Parameter | Waveshare 4.01" ACeP (F) | Waveshare 5.65" ACeP (F) | Waveshare 7.3" ACeP (F) |
|-----------|---------------------------|---------------------------|---------------------------|
| Resolution | 640x400 | 600x448 | 800x480 |
| Size | 86.4x54.0mm display | ~114.9x85.8mm display | ~163.2x97.9mm display |
| Colors | 7 (Black/White/Red/Green/Blue/Yellow/Orange) | 7 | 7 |
| Interface | SPI (4-wire) | SPI (3/4-wire) | SPI (4-wire) |
| Refresh Time | ~26s [INFERRED from similar ACeP] | ~35s (spec) | ~35s [INFERRED] |
| Refresh Power | ~50mW typical [INFERRED from 5.65" spec] | 50mW typical (spec) | ~65mW [INFERRED] |
| Standby Current | <0.01uA | <0.01uA (spec) | <0.01uA |
| Logic Voltage | 3.3V/5V (onboard translator) | 3.3V/5V | 3.3V/5V |
| Price | ~$25 (retail) | ~$35 (retail) | ~$50 (retail) |
| Driver IC | Built-in on FPC | Built-in on FPC | Built-in on FPC |

**Sources**:
- Waveshare 5.65" spec: https://www.waveshare.com/w/upload/7/7a/5.65inch_e-Paper_(F)_Sepecification.pdf
- Waveshare 4.01" product page: https://www.waveshare.com/4.01inch-e-paper-hat-f.htm
- Waveshare 7.3" product page: https://www.waveshare.com/7.3inch-e-paper-hat-f.htm

**Selection**: **Waveshare 5.65" ACeP 7-Color (F)** (Primary)
- Rationale: Best balance of display area vs. physical size for a tracker device. 600x448 sufficient for status graphics. 50mW refresh power is manageable. 35s refresh is acceptable for infrequent updates.
- Backup: Waveshare 4.01" ACeP (F) — smaller, cheaper, pin-compatible SPI interface. Use if enclosure size is constrained.
- [TRADEOFF]: All ACeP displays have slow refresh (~35s). Not suitable for real-time data display. Acceptable for elephant tracker (update every 1-24 hours).

**Supply Chain Risk**: **MEDIUM** — Waveshare is sole manufacturer of these specific modules. Available on Waveshare direct, Amazon, AliExpress. No LCSC listing for the module itself.

---

### 2.3 RTC (Real-Time Clock)

| Parameter | DS3231SN | DS3231M | PCF8563 |
|-----------|----------|---------|---------|
| Accuracy | ±2 ppm (±3.5 ppm -40~85°C) | ±5 ppm | ±20 ppm (ext crystal dependent) |
| Interface | I2C (400kHz) | I2C (400kHz) | I2C (400kHz) |
| Active Current | 200-300uA @ 3.3V | 100-170uA | 0.25-200uA |
| Timekeeping (VBAT) | ~0.84uA @ 3V | ~1uA @ 3V | ~0.25uA @ 3V |
| Alarm | 2 alarms | 2 alarms | 1 alarm + 1 timer |
| Temp Sensor | Yes (±3°C) | No | No |
| Package | SO-16W / SO-8 | SO-8 | SO-8 / TSSOP-8 |
| LCSC Price (1K) | ~$1.50 [ESTIMATED] | ~$2.00 [ESTIMATED] | ~$0.12 |
| Supply | Analog Devices (DigiKey, Mouser, LCSC) | Analog Devices | NXP + clones (LCSC multiple sources) |

**Sources**:
- DS3231 Datasheet: https://www.analog.com/media/en/technical-documentation/data-sheets/ds3231.pdf
- PCF8563 Datasheet: https://www.nxp.com/docs/en/data-sheet/PCF8563.pdf
- PCF8563 LCSC: https://lcsc.com/product-detail/Real-time-Clocks-RTC_IDCHIP-PCF8563_C5795601.html
- RTC Comparison: https://www.switchdoc.com/2014/12/benchmarks-realtime-clocks-ds3231-pcf8563-mcp79400-ds1307/

**Selection**: **DS3231SN** (Primary)
- Rationale: Built-in TCXO gives ±2ppm accuracy — critical for long-term unattended deployment where clock drift accumulates. 2 alarms useful for scheduled wake. Built-in temperature sensor is a bonus for wildlife monitoring.
- Backup: PCF8563 — pin-incompatible (different I2C register map, needs software change). But 10x cheaper and 3x lower standby current. Use if cost is primary concern and ±20ppm accuracy is acceptable.
- [TRADEOFF]: DS3231 draws more power than PCF8563. For elephant tracker deployed months at a time, the accuracy advantage justifies the extra ~0.6uA.

**Supply Chain Risk**: **LOW** — DS3231 is mature Analog Devices product. Available LCSC + DigiKey + Mouser. No EOL notice.

---

### 2.4 Battery Charger IC

| Parameter | TP4056 (TPOWER) | TP4056 (TECH PUBLIC) | BQ24072 (TI) |
|-----------|-----------------|----------------------|---------------|
| Charge Current | Up to 1A (programmable) | Up to 1A | Up to 1.5A |
| Charge Voltage | 4.2V ±1% | 4.2V ±1% | 4.2V ±0.5% |
| Input Voltage | 4.0-8.0V | 4.0-8.0V | 4.35-6.4V |
| Path Management | No | No | Yes (power path) |
| Thermal Protection | Yes (135°C foldback) | Yes | Yes |
| Package | SOP-8 / ESOP-8 | SOP-8 | QFN-10 (3x3mm) |
| LCSC Price (1K) | $0.065 | $0.034 | ~$1.50 [ESTIMATED] |
| Supply | Multiple CN sources | Multiple CN sources | TI (DigiKey, Mouser) |

**Sources**:
- TP4056 Datasheet: https://datasheet.lcsc.com/lcsc/1809261820_TOPPOWER-Nanjing-Extension-Microelectronics-TP4056-42-ESOP8_C16581.pdf
- TP4056 LCSC TPOWER: https://lcsc.com/product-detail/Battery-Management-ICs_TPOWER-TP4056_C382139.html
- TP4056 LCSC TECH PUBLIC: https://www.lcsc.com/product-detail/Battery-Management-ICs_TECH-PUBLIC-TP4056_C5311018.html

**Selection**: **TP4056 (TPOWER)** (Primary)
- Rationale: Proven, ultra-cheap, simple circuit. 1A charge is sufficient for 1000-3000mAh LiPo. Massive community support with ESP32 projects.
- Backup: TP4056 (TECH PUBLIC) — functionally identical, even cheaper. Pin-compatible.
- [TRADEOFF]: No power path management. When USB connected while battery charging, system powered from battery not USB. Acceptable for tracker (rarely connected to USB).

**Supply Chain Risk**: **LOW** — TP4056 has 10+ manufacturers on LCSC. Commodity part.

---

### 2.5 LDO Voltage Regulator (3.3V)

| Parameter | ME6211C33M5G | RT9080-33GJ5 | AMS1117-3.3 |
|-----------|--------------|--------------|-------------|
| Output | 3.3V / 500mA | 3.3V / 600mA | 3.3V / 1A |
| Dropout Voltage | 100mV @ 100mA | 310mV @ 600mA | 1.3V @ 1A |
| Quiescent Current | 50uA (typ) | 2uA (typ) | 5mA (typ) |
| Standby Current | 0.1uA | ~0.01uA | N/A |
| Input Range | 2.0-6.0V | 1.2-5.5V | 4.5-12V |
| PSRR | 70dB @ 1kHz | 65dB @ 1kHz [INFERRED] | 60dB [INFERRED] |
| Package | SOT-23-5 | TSOT-23-5 | SOT-223 |
| LCSC Price (1K) | ~$0.03 | ~$0.15 | ~$0.03 |

**Sources**:
- ME6211 Datasheet: https://datasheet.lcsc.com/lcsc/Nanjing-Micro-One-Elec-ME6211C33M5G-N_C82942.pdf
- RT9080 Datasheet: https://www.richtek.com/assets/product_file/RT9080/DS9080-09.pdf
- RT9080 Product Page: https://www.richtek.com/Products/Linear%20Regulator/Single%20Output%20Linear%20Regulator/RT9080

**Selection**: **RT9080-33GJ5** (Primary)
- Rationale: 2uA quiescent current is critical for deep-sleep battery life. 600mA output handles ESP32-C3 TX peak current. TSOT-23-5 is hand-solderable.
- Backup: ME6211C33M5G — pin-compatible with TSOT-23-5 footprint variant. 50uA Iq is acceptable if RT9080 unavailable. Much cheaper.
- [TRADEOFF]: RT9080 costs 5x more than ME6211. The 48uA Iq difference saves ~0.4mAh/day — meaningful over months of deployment.

**Supply Chain Risk**: **MEDIUM** — RT9080 is Richtek single-source. Available DigiKey + Mouser. LCSC availability varies. ME6211 backup provides risk mitigation.

---

## 3. Selection Summary

| Module | Primary | Backup | Risk |
|--------|---------|--------|------|
| MCU | ESP32-C3-MINI-1-N4 ($2.01) | ESP32-C3-MINI-1-H4 ($2.17) | LOW |
| Display | Waveshare 5.65" ACeP (F) (~$35) | Waveshare 4.01" ACeP (F) (~$25) | MEDIUM |
| RTC | DS3231SN (~$1.50 [ESTIMATED]) | PCF8563 ($0.12) | LOW |
| Charger | TP4056 TPOWER ($0.065) | TP4056 TECH PUBLIC ($0.034) | LOW |
| LDO 3.3V | RT9080-33GJ5 (~$0.15) | ME6211C33M5G (~$0.03) | MEDIUM |

## 4. Design Constraints & Notes

1. **GPIO Budget (ESP32-C3-MINI-1-N4)**:
   - SPI for E-ink: MOSI, CLK, CS, DC, RST, BUSY = 6 pins
   - I2C for RTC: SDA, SCL = 2 pins
   - Charger status: CHRG, STDBY = 2 pins
   - Battery voltage ADC: 1 pin
   - UART debug: TX, RX = 2 pins
   - Boot control: GPIO0, EN = 2 pins (strapping)
   - **Total used: ~15 pins. Remaining: 0-2 spare** [TRADEOFF: very tight]

2. **E-ink Refresh Timing**: 35s refresh means the system must stay active for 35s per display update. This dominates the power budget during active periods.

3. **Temperature Range**: DS3231 operates -40°C to +85°C. ESP32-C3 operates -40°C to +105°C. LiPo battery operating range 0°C to +45°C (discharge), -20°C to +45°C with derating. **Battery is the limiting factor for cold environments.**

4. **All ACeP 7-color E-ink displays** have a minimum operating temperature of 15°C for refresh. Below that, refresh quality degrades significantly. [Source: Waveshare wiki notes]
