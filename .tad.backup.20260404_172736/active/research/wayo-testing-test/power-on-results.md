# Power-On Test Results: Wayo Prototype

> **Status**: TEMPLATE — fill in actual measurements during physical testing.
> **Board Rev**: ____ | **Serial**: ____ | **Date**: ____ | **Tester**: ____

## Verification Criteria

All criteria derived from ESP32-C3 Datasheet v2.2 and Waveshare 5.65" E-ink specs.

### 1. Voltage Rail Verification

| Rail | Expected | ±5% Range | Measured | Deviation | PASS/FAIL |
|------|----------|-----------|----------|-----------|-----------|
| VBAT | 3.700V | 3.0–4.2V (battery range) | ___ V | ___ % | ___ |
| VDD3P3 | 3.300V | 3.135–3.465V | ___ V | ___ % | ___ |
| VDD3P3_CPU | 3.300V | 3.135–3.465V | ___ V | ___ % | ___ |
| VDD3P3_RTC | 3.300V | 3.135–3.465V | ___ V | ___ % | ___ |
| VDD_SPI | 3.300V | 3.135–3.465V | ___ V | ___ % | ___ |
| E-ink VDD | 3.300V | 3.135–3.465V | ___ V | ___ % | ___ |

**Verdict**: ☐ All rails within ±5% → PASS | ☐ Any rail >±10% → FAIL

### 2. Quiescent Current

| Condition | Expected (from datasheet) | Measured | PASS/FAIL |
|-----------|--------------------------|----------|-----------|
| Active idle (no WiFi) | ~24mA [Source: ESP32-C3 datasheet, active mode idle] | ___ mA | ___ |
| Expected range | 24mA ±20% = 19–29mA | ___ mA | ___ |

**If >200mA at power-on**: IMMEDIATE FAIL — suspect short circuit.

### 3. Thermal Check

| Check | Criteria | Result |
|-------|----------|--------|
| Hottest component after 60s | <50°C (touch-safe) | ___ °C estimated |
| Any component abnormally warm? | No | ☐ Yes / ☐ No |

### 4. MCU Communication

| Check | Expected | Result |
|-------|----------|--------|
| Serial boot message | ESP32-C3 boot log within 5s | ☐ Received / ☐ Not received |
| Reset reason | POWERON (rst:0x1) | ___ |

### 5. Protection Circuits

| Protection | Verified? | Method | Result |
|-----------|-----------|--------|--------|
| Battery reverse polarity | [UNVALIDATED] | Requires schematic review | ___ |
| Overcurrent | [UNVALIDATED] | Requires intentional overload test | ___ |
| Undervoltage cutoff | [UNVALIDATED] | Requires slow battery drain test | ___ |

> **Note**: Protection circuit verification marked [UNVALIDATED] — requires schematic access and potentially destructive testing. Do NOT perform without proper safety precautions.

## Overall Verdict

| Criteria | Status |
|----------|--------|
| All rails within ±5% | ☐ PASS / ☐ FAIL |
| Quiescent current within expected range | ☐ PASS / ☐ FAIL |
| No thermal anomalies | ☐ PASS / ☐ FAIL |
| MCU serial responsive | ☐ PASS / ☐ FAIL |

**OVERALL**: ☐ PASS (all 4 criteria met) / ☐ FAIL (any criteria failed)
