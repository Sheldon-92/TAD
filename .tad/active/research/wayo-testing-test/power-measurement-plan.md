# Power Measurement Plan: Wayo Prototype

## Device Under Test
- **MCU**: ESP32-C3 (RISC-V, 160MHz, single core)
- **Display**: Waveshare 5.65" ACeP 7-Color E-ink (SPI, 600x448)
- **Battery**: 18650 Li-ion, 3.7V nominal, ~3000mAh
- **Connectivity**: WiFi 802.11 b/g/n + BLE 5.0
- **Use case**: Outdoor elephant tracker — long sleep cycles, periodic wake for GPS/sensor read + wireless transmit

---

## 1. Power Modes Identification

| # | Mode | CPU State | WiFi/BLE | Display | Expected Current | Source |
|---|------|-----------|----------|---------|-----------------|--------|
| 1 | **Active (WiFi TX)** | Running 160MHz | WiFi transmitting | Refreshing | 180–240mA peak | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| 2 | **Active (idle)** | Running 160MHz | Off | Static | ~24mA | [Espressif C3 Book](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html) |
| 3 | **Modem sleep** | Running | WiFi off | Static | ~15mA [UNVALIDATED — extrapolated from ESP32 modem sleep] | ESP32 Forum references |
| 4 | **Light sleep** | Paused, RAM retained | Off | Static | ~0.8mA | [Espressif docs](https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.2.html) |
| 5 | **Deep sleep** | Off, RTC only | Off | Static (zero power) | ~5uA (chip only), 10–150uA with peripherals | [ESP32-C3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf) |
| 6 | **Power-off / shipping** | Everything off | Off | Off | <1uA (battery disconnect) | N/A |

### E-ink Display Power Notes
- Refresh power: 50mW typical (~15mA at 3.3V) — [Waveshare 5.65" spec](https://www.waveshare.com/5.65inch-e-paper-module-f.htm)
- Refresh time: <35s for full ACeP 7-color refresh (significantly longer than B/W e-ink)
- Standby current: <0.01uA — effectively zero
- **Key insight**: E-ink only draws power during refresh. For an elephant tracker that updates every 15–60 minutes, display power is negligible in average calculation.

## 2. Measurement Setup

### Instrument Requirements

| Mode | Instrument | Range | Why |
|------|-----------|-------|-----|
| Active (WiFi TX) | Bench supply current readout OR oscilloscope + 0.1 Ohm shunt | mA range | Peak current ~240mA, need transient capture |
| Active (idle) | Multimeter on mA range | mA range | Steady state ~24mA |
| Light sleep | Multimeter on mA range | mA range | ~0.8mA, stable |
| Deep sleep | Multimeter on uA range | uA range | ~5uA — **MUST use uA range, NOT auto-range** |
| Transition profiling | Oscilloscope + current sense resistor | Both | Capture sleep-to-wake transient |

### Measurement Circuit
```
                    ┌──────────────┐
  18650 (+) ──┤►├── ┤  AMMETER     ├──── Board VBAT (+)
              diode │  (break here)│
                    └──────────────┘
  18650 (-) ──────────────────────────── Board GND
```

**Where to break the circuit**: 
- Remove any jumper/header on the battery positive line
- OR cut a trace and add a 2-pin header for ammeter insertion
- For oscilloscope: solder a 0.1 Ohm (for mA) or 10 Ohm (for uA) sense resistor in series

**CRITICAL**: Switch multimeter to uA range BEFORE entering deep sleep. Auto-range injects measurement noise (burden voltage changes) and gives unreliable readings at uA levels.

## 3. Wayo-Specific Considerations

### Elephant Tracker Usage Profile
The Wayo device is an outdoor elephant tracker. Realistic usage profile:
- **Wake every 15 minutes**: read GPS + sensors, transmit via WiFi/BLE
- **Active duration per wake**: ~5–10 seconds (WiFi connect + transmit)
- **Deep sleep**: remaining ~14 minutes 50 seconds
- **Display refresh**: once per hour or on significant event (elephant movement detected)
- **Solar charging**: supplements 18650, extends field life indefinitely in good conditions

### Temperature Impact on Battery
- 18650 performance degrades significantly below 0 degrees C
- Outdoor in tropical/savanna climate: expect 15–45 degrees C range
- At 45 degrees C: battery delivers slightly higher capacity but faster aging
- Source: [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/)
