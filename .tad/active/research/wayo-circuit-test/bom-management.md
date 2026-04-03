# Wayo Elephant Tracker — BOM Management Report

> Generated: 2026-04-02
> Domain Pack: hw-circuit-design v1.0.0 / capability: bom_management

---

## 1. BOM Format Definition

Standard columns per domain pack specification. Dual-supplier strategy applied.
Quantity tier: **1K pcs** for unit pricing (prototype pricing noted separately).
All prices in **USD**. Price date: April 2026.

---

## 2. Complete BOM

### 2.1 Active Components (ICs)

| Item | Ref | Value | Footprint | Description | Manufacturer | MPN | Supplier_1 (LCSC) | LCSC_PN | Supplier_2 | Supplier_2_PN | Price_1K (USD) | Qty | Category |
|------|-----|-------|-----------|-------------|--------------|-----|--------------------|---------|------------|----------------|----------------|-----|----------|
| 1 | U1 | ESP32-C3-MINI-1-N4 | Module (13.2x16.6mm) | WiFi+BLE MCU Module, RISC-V, 4MB Flash | Espressif | ESP32-C3-MINI-1-N4 | LCSC | C2838502 | DigiKey | 1965-ESP32-C3-MINI-1-N4-ND | $2.01 | 1 | active |
| 2 | U2 | DS3231SN#T&R | SOIC-16W | RTC with TCXO, ±2ppm, I2C | Analog Devices | DS3231SN#T&R | LCSC | C9866 | DigiKey | DS3231SN#T&R-ND | $3.74 | 1 | active |
| 3 | U3 | TP4056 | SOP-8 | 1A Linear LiPo Charger | TPOWER | TP4056 | LCSC | C382139 | LCSC (alt) | C16581 | $0.065 | 1 | active |
| 4 | U4 | RT9080-33GJ5 | TSOT-23-5 | 3.3V 600mA LDO, 2uA Iq | Richtek | RT9080-33GJ5 | LCSC | C841192 | DigiKey | 1028-RT9080-33GJ5-ND | $0.15 [ESTIMATED] | 1 | active |

**Sources**:
- ESP32-C3-MINI-1-N4 LCSC: https://lcsc.com/product-detail/RF-Modules_Espressif-Systems-ESP32-C3-MINI-1-N4_C2838502.html ($2.01)
- ESP32-C3-MINI-1-N4 DigiKey: https://www.digikey.com/en/products/detail/espressif-systems/ESP32-C3-MINI-1-N4/13877574 ($3.17)
- DS3231SN#T&R LCSC: https://www.lcsc.com/product-detail/C9866.html ($3.74)
- TP4056 LCSC: https://lcsc.com/product-detail/Battery-Management-ICs_TPOWER-TP4056_C382139.html ($0.065)
- RT9080-33GJ5 LCSC: https://www.lcsc.com/product-detail/C841192.html

### 2.2 Display Module

| Item | Ref | Value | Footprint | Description | Manufacturer | MPN | Supplier_1 | PN | Supplier_2 | Supplier_2_PN | Price_1K (USD) | Qty | Category |
|------|-----|-------|-----------|-------------|--------------|-----|------------|-----|------------|----------------|----------------|-----|----------|
| 5 | DISP1 | 5.65" ACeP 7-Color | FPC 24-pin | 600x448 E-ink, SPI, 7-color | Waveshare | 5.65inch-e-Paper-Module-(F) | Waveshare Direct | — | Amazon | B0BRBJ1RB8 | $28.00 [ESTIMATED bulk] | 1 | active |

**Source**: https://www.waveshare.com/5.65inch-e-paper-module-f.htm (retail ~$35)
**Note**: Waveshare bulk pricing requires direct inquiry. $28 is estimated 20% discount at 1K qty. [ESTIMATED]

### 2.3 Passive Components

| Item | Ref | Value | Footprint | Description | Manufacturer | MPN | LCSC_PN | Price_1K (USD) | Qty | Category |
|------|-----|-------|-----------|-------------|--------------|-----|---------|----------------|-----|----------|
| 6 | C1,C2,C3,C4 | 100nF | 0402 | Decoupling cap, X7R, 16V | Generic | — | C1525 | $0.002 | 4 | passive |
| 7 | C5 | 10uF | 0603 | Bulk decoupling, X5R, 10V | Generic | — | C19702 | $0.005 | 1 | passive |
| 8 | C6,C7 | 1uF | 0402 | LDO input/output cap, X7R, 10V | Generic | — | C52923 | $0.003 | 2 | passive |
| 9 | C8 | 4.7uF | 0603 | TP4056 input cap, X5R, 10V | Generic | — | C19666 | $0.004 | 1 | passive |
| 10 | C9 | 4.7uF | 0603 | TP4056 output cap, X5R, 10V | Generic | — | C19666 | $0.004 | 1 | passive |
| 11 | R1 | 2.4kΩ | 0402 | TP4056 RPROG (sets 500mA charge) | Generic | — | C25872 | $0.001 | 1 | passive |
| 12 | R2,R3 | 10kΩ | 0402 | I2C pull-up (SDA, SCL) | Generic | — | C25744 | $0.001 | 2 | passive |
| 13 | R4 | 10kΩ | 0402 | ESP32 EN pull-up | Generic | — | C25744 | $0.001 | 1 | passive |
| 14 | R5 | 10kΩ | 0402 | ESP32 GPIO0 pull-up (boot mode) | Generic | — | C25744 | $0.001 | 1 | passive |
| 15 | R6,R7 | 100kΩ | 0402 | VBAT voltage divider for ADC | Generic | — | C25741 | $0.001 | 2 | passive |
| 16 | R8 | 1kΩ | 0402 | Charge LED current limit | Generic | — | C11702 | $0.001 | 1 | passive |
| 17 | CR1 | CR1220 | Through-hole | DS3231 backup battery (3V coin cell) | Generic | — | — | $0.10 [ESTIMATED] | 1 | passive |

**Note**: Passive component LCSC part numbers are representative (LCSC basic parts). Actual MPN selection during production should use specific manufacturer parts (Murata, Yageo, Samsung) for reliability.

### 2.4 Connectors & Mechanical

| Item | Ref | Value | Footprint | Description | Manufacturer | MPN | LCSC_PN | Price_1K (USD) | Qty | Category |
|------|-----|-------|-----------|-------------|--------------|-----|---------|----------------|-----|----------|
| 18 | J1 | USB-C | SMD 16-pin | USB-C Receptacle (power only) | Generic | — | C165948 | $0.08 [ESTIMATED] | 1 | connector |
| 19 | J2 | JST-PH 2P | Through-hole | LiPo battery connector | JST | B2B-PH-K-S | C131337 | $0.03 | 1 | connector |
| 20 | J3 | FPC 24P 0.5mm | SMD | E-ink display FPC connector | Generic | — | C11094 | $0.05 [ESTIMATED] | 1 | connector |
| 21 | J4 | 1x4 2.54mm | Through-hole | Debug header (UART TX/RX/3V3/GND) | Generic | — | C2337 | $0.02 | 1 | connector |
| 22 | LED1 | Red | 0603 | Charge indicator LED | Generic | — | C2286 | $0.005 | 1 | connector |
| 23 | LED2 | Green | 0603 | Charge complete LED | Generic | — | C72043 | $0.005 | 1 | connector |
| 24 | SW1 | Tactile | 3x6mm SMD | Reset button | Generic | — | C318884 | $0.01 | 1 | mechanical |
| 25 | SW2 | Tactile | 3x6mm SMD | Boot button (GPIO0) | Generic | — | C318884 | $0.01 | 1 | mechanical |
| 26 | BAT1 | 2000mAh LiPo | Pouch | 3.7V LiPo battery with JST-PH | Generic | — | — | $3.00 [ESTIMATED] | 1 | mechanical |

---

## 3. BOM Verification

### 3.1 Completeness Check
- Total unique items: 26
- Items with MPN: 4/5 ICs have specific MPN (passives use generic LCSC basic parts)
- Items marked [ESTIMATED] price: 6 items (display bulk, LDO, coin cell, USB-C, FPC, battery)
- Items with no supplier PN: 2 (coin cell, battery — sourced separately)
- **Dual supplier coverage: 4/5 active ICs (80%)** — TP4056 has LCSC dual-source (two manufacturers). Display is single-source (Waveshare).

### 3.2 Cost Summary

| Category | Items | Cost per Board (USD) |
|----------|-------|---------------------|
| Active ICs | U1-U4 | $5.97 |
| Display | DISP1 | $28.00 [ESTIMATED] |
| Passive (R/C) | 12 items | $0.06 |
| Connectors/LED | 6 items | $0.20 |
| Mechanical (buttons, battery) | 3 items | $3.12 |
| **Subtotal (components)** | | **$37.35** |
| PCB (2-layer, 80x60mm, JLCPCB) | | ~$0.50 [ESTIMATED at 1K qty] |
| **Total per board** | | **~$37.85** |

### 3.3 Cost Distribution
- **Display: 74%** — dominates total cost
- **Active ICs: 16%** (ESP32 + DS3231 = 95% of IC cost)
- **Battery: 8%**
- **Passives + Connectors: 1%**
- **PCB: 1%**

### 3.4 Cost Top 5

| Rank | Component | Cost | % of Total | Cost-Down Potential |
|------|-----------|------|------------|---------------------|
| 1 | E-ink Display | $28.00 | 74% | Low — ACeP 7-color premium, no cheap alternative |
| 2 | DS3231 RTC | $3.74 | 10% | HIGH — PCF8563 at $0.12 saves $3.62 (if ±20ppm OK) |
| 3 | Battery 2000mAh | $3.00 | 8% | Medium — smaller battery if power save mode sufficient |
| 4 | ESP32-C3 Module | $2.01 | 5% | Low — already cheapest WiFi+BLE module |
| 5 | RT9080 LDO | $0.15 | 0.4% | Yes — ME6211 at $0.03 saves $0.12 |

### 3.5 Supply Chain Risk Summary

| Risk Level | Components | Action |
|------------|-----------|--------|
| **HIGH** | E-ink display (Waveshare sole source) | Establish direct relationship with Waveshare, order buffer stock, evaluate Good Display as alternative panel source |
| **MEDIUM** | RT9080 LDO (Richtek single mfg) | ME6211 is drop-in backup. Keep both in BOM as approved alternates |
| **LOW** | ESP32-C3, DS3231, TP4056, all passives | Multi-source on LCSC+DigiKey+Mouser. No action needed |

---

## 4. Optimization Recommendations

### 4.1 Passive Component Consolidation
- **Unified 0402 footprint**: All resistors and small caps use 0402 — reduces pick-and-place nozzle changes
- **Merge identical values**: R2/R3/R4/R5 all 10kΩ 0402 — single reel, 5 placements
- **Consider 0603 for all caps**: Easier hand-soldering for prototypes, minimal cost difference at scale

### 4.2 Cost Reduction Path
1. **Biggest lever: Display** — If 2-color (B/W) E-ink acceptable, cost drops from $28 to ~$8 (saves $20/board). But loses 7-color feature.
2. **RTC downgrade**: PCF8563 saves $3.62/board with acceptable accuracy for most use cases
3. **Combined savings**: PCF8563 + ME6211 = $3.74 savings → **$34.11/board** (9% reduction)

### 4.3 Procurement Strategy (1K qty)

| Supplier | Components | Est. Order Value | Notes |
|----------|-----------|-----------------|-------|
| LCSC | ICs, passives, connectors | ~$6.50 x 1K = $6,500 | One-stop for SMT parts, JLCPCB assembly compatible |
| Waveshare Direct | E-ink displays | ~$28 x 1K = $28,000 | Negotiate bulk pricing, MOQ likely 100+ |
| Battery supplier | LiPo batteries | ~$3 x 1K = $3,000 | Source from Shenzhen battery manufacturers |
| JLCPCB | PCB fabrication + SMT assembly | ~$1.5 x 1K = $1,500 | 2-layer, standard process |

**Total estimated production cost (1K qty): ~$39,000 (~$39/board)**

---

## 5. BOM Files

### 5.1 LCSC Purchase List (for JLCPCB Assembly)

```csv
LCSC Part Number,Quantity,Description
C2838502,1000,ESP32-C3-MINI-1-N4
C9866,1000,DS3231SN#T&R
C382139,1000,TP4056
C841192,1000,RT9080-33GJ5
C1525,4000,100nF 0402
C19702,1000,10uF 0603
C52923,2000,1uF 0402
C19666,2000,4.7uF 0603
C25872,1000,2.4kΩ 0402
C25744,6000,10kΩ 0402
C25741,2000,100kΩ 0402
C11702,1000,1kΩ 0402
C165948,1000,USB-C Receptacle
C131337,1000,JST-PH 2P
C11094,1000,FPC 24P 0.5mm
C2337,1000,1x4 Pin Header
C2286,1000,Red LED 0603
C72043,1000,Green LED 0603
C318884,2000,Tactile Switch 3x6mm
```

### 5.2 Separate Procurement Items
- Waveshare 5.65" ACeP E-ink Module (F): 1000 pcs — contact sales@waveshare.com
- LiPo Battery 2000mAh with JST-PH: 1000 pcs — source from battery manufacturer
- CR1220 Coin Cell: 1000 pcs — generic supplier
