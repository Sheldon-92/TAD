# EMC Pre-Compliance (Doc A: search → analyze → derive → generate)

EMC pre-compliance checklist — radiated emissions, conducted emissions, ESD immunity. Catch issues before expensive lab testing.

## 1. Search EMC Standards

1. Market-specific requirements:
   - USA: FCC Part 15 (Class B for consumer, Class A for industrial)
   - EU: EN 55032 (emissions), EN 55035 (immunity), CE marking
   - China: GB 9254 (emissions), GB/T 17618 (immunity), CCC if applicable
2. Product-specific standards:
   - All electronics: IEC 61000-4-2 (ESD), IEC 61000-4-3 (radiated immunity)
   - Wireless devices: additional radio-specific (e.g., FCC Part 15.247 for WiFi/BLE)
3. Search for common EMC failure modes (web research):
   - "EMC failure common causes PCB design"
   - "radiated emissions pre-compliance testing"
   - "ESD protection circuit design best practices"
   - "EN 55032 / EN 55035 limits consumer electronics"
   - "FCC Part 15 Class B radiated emission limits"
   - "IEC 61000-4-2 ESD test levels"
4. Identify the pre-compliance test equipment available:
   - Near-field probe set + spectrum analyzer (most useful for pre-compliance)
   - ESD gun (IEC 61000-4-2 levels: ±2kV contact, ±4kV air minimum)

Quality bar: Standards must specify edition/year. EMC standards update frequently — cite current versions.
Output: `emc-research.md`.

## 2. Analyze the Design for EMC Risks

1. Clock frequencies inventory:
   - List all oscillators, clock signals, switching converters
   - Calculate harmonics: a 48MHz USB clock has 3rd harmonic at 144MHz, 5th at 240MHz
   - FCC Class B limit at 240MHz: ~40 dBµV/m at 3m — this WILL be close
2. PCB layout review checklist:

   | Risk Factor | Status | Severity | Notes |
   |------------|--------|----------|-------|
   | Ground plane continuous under ICs? | | High | Gaps in ground plane = antenna |
   | Decoupling caps <5mm from IC pins? | | High | Long traces add inductance |
   | Crystal/oscillator trace length? | | Medium | Keep <10mm, ground guard |
   | DCDC inductor shielded? | | High | Unshielded inductors radiate |
   | USB/HDMI impedance controlled? | | Medium | Mismatch = emissions |
   | Cable entry points filtered? | | High | Cables are the #1 antenna |
   | ESD protection on all external ports? | | Critical | Missing = instant fail |

3. Identify top 3 highest-risk signals (highest frequency × longest trace = most radiation).

Quality bar: Risk assessment must reference actual clock frequencies from the design, not generic advice.
Output: `emc-risk-analysis.md`.

## 3. Derive the Pre-Compliance Checklist

── DESIGN REVIEW (before board spin) ──
- □ Ground plane: continuous, no splits under high-speed signals
- □ Decoupling: 100nF + 10µF per power pin, placed <5mm from pin
- □ Crystal: guard ring, short traces, ground plane underneath
- □ DCDC: shielded inductor, input/output caps close, snubber if needed
- □ Connectors: filter caps or ferrite beads on all external-facing signals
- □ ESD: TVS diodes on USB, buttons, antenna feed, any user-touchable signal
  - USB: minimum ±8kV contact (IEC 61000-4-2 Level 4)
  - Other ports: minimum ±4kV contact
- □ Antenna: keep-out zone respected, ground plane extends ≥λ/4 beyond antenna

── PRE-COMPLIANCE MEASUREMENTS (with near-field probe) ──
1. Radiated emissions scan (30MHz - 1GHz):
   - Use near-field H-probe, sweep over PCB surface
   - Identify hotspots (>6 dB above average)
   - Compare peaks against FCC/EN limit with estimated margin
2. Conducted emissions check:
   - Measure on power cable with LISN (if available)
   - Check 150kHz - 30MHz range
3. ESD testing:
   - ±2kV contact discharge to all metal parts
   - ±4kV air discharge to all external ports
   - ±8kV contact to USB connector specifically
   - Pass criteria: no reset, no data loss, no damage
   - Acceptable: momentary display glitch if self-recovers within 2s

── FIXES FOR COMMON FAILURES ──
Radiated emissions too high:
- Add ferrite bead on offending trace/cable
- Add shielding can over noisy IC
- Reduce clock frequency if possible (80MHz vs 240MHz for ESP32)

ESD failure:
- Add TVS diode (response time <1ns)
- Add series resistor (100Ω) before TVS for energy limiting
- Verify ground path impedance (TVS ground must be low impedance)

Output: `emc-pre-compliance-checklist.md`.

## 4. Generate the EMC Pre-Compliance Report

Generate as PDF:
1. Executive summary: overall EMC risk assessment (High/Medium/Low)
2. Standards applicability table: which standards, which markets
3. Design review findings: per-item status from checklist
4. Pre-compliance measurement results (if measurements were taken)
5. Risk items ranked by severity with remediation plan
6. Estimated cost for formal compliance testing ($5K-$15K typical for FCC+CE)
7. Timeline: design fixes → re-test → formal submission

Generate PCB EMC annotation diagram with D2 (show hotspots, ground plane gaps, etc.)
Output: `emc-pre-compliance-report.pdf`.

## Quality Criteria (pass/fail for this capability's artifacts)

- All clock frequencies inventoried with harmonic analysis
- ESD protection verified on every external port
- PCB layout review covers ground plane, decoupling, trace routing
- Pre-compliance test procedure references specific frequency ranges and limit levels
- FCC radiated emission limits used as thresholds: Class B (3m) 40.0 dBuV/m @30-88MHz, 43.5 @88-216MHz, 46.0 @216-960MHz, 54.0 @>960MHz — source: FCC Title 47 CFR Part 15
- FCC conducted emission limits: Class B (QP) 66→56 dBuV @150kHz-500kHz, 56 @500kHz-5MHz, 60 @5-30MHz — source: FCC Part 15
- Applicable standards identified per target market (FCC, CE, CCC)
- 编造数据 = FAIL — harmonic frequencies must be calculated from actual clock values
