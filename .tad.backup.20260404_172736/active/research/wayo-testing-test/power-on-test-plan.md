# Power-On Test Plan: Wayo Prototype (ESP32-C3 Elephant Tracker)

## Board Overview
- **MCU**: ESP32-C3 (RISC-V, single core, 160MHz)
- **Display**: Waveshare 5.65" ACeP 7-Color E-ink (600x448, SPI)
- **Power Source**: 18650 Li-ion (3.7V nominal, ~3000mAh)
- **Connectivity**: WiFi 802.11 b/g/n + BLE 5.0
- **Target Environment**: Outdoor (elephant tracking, solar charging possible)

---

## 1. Power Rails Identification

| # | Rail Name | Expected Voltage | Tolerance (±5%) | Max Current | Source / Regulator | Measurement Point |
|---|-----------|-----------------|-----------------|-------------|-------------------|-------------------|
| 1 | VBAT (18650 direct) | 3.0V–4.2V | N/A (battery range) | 3000mAh capacity | 18650 Li-ion cell | Battery connector + / - |
| 2 | VDD3P3 (main 3.3V) | 3.300V | ±165mV (3.135–3.465V) | ~500mA (regulator dependent) | LDO/DCDC from VBAT | LDO output cap / TP if available |
| 3 | VDD3P3_CPU | 3.300V | ±165mV | ~350mA (ESP32-C3 peak active) | From VDD3P3 via ferrite/filter | Decoupling cap near pin 17 |
| 4 | VDD3P3_RTC | 3.300V | ±165mV | ~50mA | From VDD3P3 | RTC power pin decoupling cap |
| 5 | VDD_SPI (flash power) | 3.300V | ±165mV | ~50mA | From VDD3P3_CPU via RSPI | Near flash chip VCC pin |
| 6 | E-ink VDD (logic) | 3.300V | ±165mV | ~20mA (during refresh) | From VDD3P3 | E-ink module power pin |

**Sources:**
- ESP32-C3 operating voltage: 3.0V–3.6V (VDD3P3, VDD3P3_CPU, VDDA) — [ESP32-C3 Datasheet v2.2](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf)
- ESP32-C3 hardware design: 10µF + 0.1µF decoupling recommended — [ESP32-C3 Hardware Design Guidelines](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32c3/schematic-checklist.html)
- Waveshare 5.65" E-ink: SPI interface, compatible with 3.3V/5V MCUs — [Waveshare 5.65" E-Paper Module (F)](https://www.waveshare.com/5.65inch-e-paper-module-f.htm)

## 2. Power-On Sequence

1. **VBAT** → 18650 connects, voltage present (3.0–4.2V depending on charge state)
2. **VDD3P3** → LDO/DCDC regulates to 3.3V (must stabilize within ~10ms)
3. **VDD3P3_CPU** → ESP32-C3 digital core powers up
4. **VDD3P3_RTC** → RTC domain powers up
5. **VDD_SPI** → Internal flash accessible
6. **E-ink VDD** → Display logic powered (display does NOT refresh until commanded)

**Note:** E-ink display draws negligible standby current (<0.01µA per Waveshare spec) — no sequencing concern for display power.

## 3. Protection Circuits to Verify

| Protection | Expected Behavior | How to Verify |
|-----------|-------------------|---------------|
| Battery reverse polarity | No damage if battery inserted backwards | Check for protection diode/MOSFET near battery connector |
| Battery overcurrent | Board protected if short occurs | Look for PTC fuse or protection IC on battery line |
| Battery undervoltage | Cut off below ~2.5V to prevent cell damage | Verify BMS/protection IC cutoff voltage |
| LDO thermal shutdown | LDO shuts down if overheated | [UNVALIDATED] — depends on specific LDO used |
| ESD protection on USB (if present) | TVS diodes on USB data lines | Visual inspection of USB connector area |

## 4. Test Equipment Required

- Bench power supply (0–5V, 0–3A, with current limiting)
- Digital multimeter (True RMS, µA range capability)
- USB-to-UART adapter (for serial console)
- Magnifying glass / microscope (for visual inspection)
- Anti-static wrist strap and ESD mat
