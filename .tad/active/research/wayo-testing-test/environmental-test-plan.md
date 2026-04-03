# Environmental Test Plan: Wayo Elephant Tracker

**Product**: Wayo Prototype (ESP32-C3 + 5.65" E-ink + 18650)
**Revision**: R1 (prototype)
**Plan Version**: 1.0
**Date**: 2026-04-02
**Author**: TAD hw-testing Domain Pack

---

## Test Summary

| # | Test | Standard | Condition | Duration | Samples | Priority |
|---|------|----------|-----------|----------|---------|----------|
| T1 | High temp operation | IEC 60068-2-2 Bd | +60C | 16h | 3 | HIGH |
| T2 | Low temp operation | IEC 60068-2-1 Ad | -10C | 16h | 3 | HIGH |
| T3 | Temp cycling | IEC 60068-2-14 Na | -10C to +60C, 10 cycles | ~20h | 3 | HIGH |
| T4 | Damp heat | IEC 60068-2-78 Cab | 40C/93% RH | 96h | 3 | MEDIUM |
| T5 | Drop/shock | IEC 60068-2-31 Ec | 1.5m, 6 faces, concrete | ~1h | 3 | HIGH |
| T6 | Vibration | IEC 60068-2-6 Fc | 10-500Hz sweep | ~4h | 3 | MEDIUM |
| T7 | Dust (IP6X) | IEC 60529 | 8h dust chamber | 8h | 2 | HIGH |
| T8 | Immersion (IPX7) | IEC 60529 | 1m depth, 30 min | 30min | 2 | HIGH |
| T9 | Water jet (IPX5) | IEC 60529 | 12.5 L/min, 3m | ~15min | 2 | HIGH |

**Total estimated lab time**: ~7 days (excluding queue time)
**Total samples needed**: 10 units minimum

---

## Detailed Procedures

### T1: High Temperature Operation (+60C, 16h)

**Standard**: IEC 60068-2-2, Test Bd (with heat dissipation)

**Pre-test**:
1. Perform baseline functional test at 25C (room temp)
2. Record: all voltage rails, display refresh time, WiFi RSSI, sensor readings
3. Charge 18650 to 100% (4.2V)

**Test procedure**:
1. Place DUT in temperature chamber, connect via long USB-UART cable for monitoring
2. Ramp to +60C at 1C/min (per IEC 60068-2-2 guidance)
3. Soak at +60C for 16 hours minimum
4. During soak, at hours 1, 4, 8, 16: trigger device wake cycle (WiFi TX + display refresh)
5. Monitor: serial output, current draw, any error logs
6. Record battery voltage at each check point (expect faster discharge at 60C)

**Post-test**:
1. Return to 25C (ramp down 1C/min)
2. Repeat baseline functional test
3. Compare: display quality, sensor accuracy, battery capacity remaining

**Pass criteria**:
- Device functional at all check points during 60C exposure
- No physical damage (no enclosure warping, no battery venting)
- Post-test functional test matches baseline within +-10%
- E-ink display readable at 60C (contrast may degrade — note but do not fail if still usable)

**FAIL criteria**:
- Device fails to boot at 60C
- Battery vents or swells
- Enclosure deforms
- Any function permanently lost after returning to 25C

---

### T2: Low Temperature Operation (-10C, 16h)

**Standard**: IEC 60068-2-1, Test Ad (with heat dissipation)

**Pre-test**: Same as T1

**Test procedure**:
1. Place DUT in temperature chamber at 25C
2. Ramp to -10C at 1C/min
3. Soak at -10C for 16 hours
4. At hours 1, 4, 8, 16: trigger device wake cycle
5. Specifically monitor: battery voltage (expect significant drop), E-ink refresh time (expect 2-3x slower)

**Pass criteria**:
- Device boots and connects to WiFi at -10C
- Battery sustains operation (even if at reduced capacity — expect ~60% of 25C capacity)
- E-ink display updates (slower refresh acceptable, must complete)
- Post-test at 25C: full functionality restored, battery capacity check

**Battery-specific concern**: 18650 Li-ion performance drops significantly below 0C. At -10C, internal resistance increases, voltage sag under load may cause brownout if LDO dropout is too tight. Monitor VDD3P3 during WiFi TX bursts.

---

### T3: Temperature Cycling (-10C to +60C, 10 cycles)

**Standard**: IEC 60068-2-14, Test Na

**Profile per cycle**:
1. Start at -10C, soak 30 minutes
2. Ramp to +60C at 5C/min (14 minutes ramp time)
3. Soak at +60C, 30 minutes
4. Ramp to -10C at 5C/min (14 minutes ramp)
5. Total per cycle: ~88 minutes
6. 10 cycles total: ~15 hours

**Post-test inspection**:
1. Visual: magnified inspection of all solder joints, especially BGA/QFN packages
2. Visual: enclosure seal integrity (gaskets, O-rings)
3. Visual: E-ink display for delamination or contrast changes
4. Functional: full test suite

**Pass criteria**:
- No solder joint cracking visible under 10x magnification
- All functions work post-cycling
- Enclosure seal integrity maintained (no visible gaps)

---

### T4: Damp Heat Steady State (40C / 93% RH, 96h)

**Standard**: IEC 60068-2-78, Test Cab

**Test procedure**:
1. Place DUT in humidity chamber
2. Set 40C, 93% relative humidity
3. Maintain for 96 hours (4 days)
4. Trigger device at 24h intervals

**Pass criteria**:
- No condensation inside enclosure (indicates seal failure)
- All electronics functional after 96h
- No corrosion visible on PCB or connectors

**Note**: This test is critical for tropical deployment. If the enclosure is not IP-rated yet, this test will likely reveal moisture ingress quickly.

---

### T5: Drop Test (1.5m, 6 faces)

**Standard**: IEC 60068-2-31, Test Ec

**Test procedure**:
1. Drop from 1.5m (approximate pocket/hand height) onto concrete floor
2. Orientations: 6 faces (top, bottom, front, back, left, right)
3. One drop per orientation (6 drops total per sample)
4. After each drop: quick functional check (device boots? display intact? battery secured?)
5. After all 6 drops: full functional test

**Pass criteria**:
- Enclosure intact (cracks noted but device still functional = marginal pass)
- E-ink display uncracked and functional
- Battery did NOT eject from compartment (safety critical)
- Device boots and all functions work after all 6 drops

**Special concern for Wayo**:
- 18650 battery is heavy (~48g) — under shock, it exerts significant force on battery holder. Verify retention mechanism.
- 5.65" E-ink glass panel is the most fragile component. Must have foam/gasket mounting.

---

### T6: Vibration (Sinusoidal Sweep)

**Standard**: IEC 60068-2-6, Test Fc

**Profile**: 10–500 Hz, 1 octave/min, 2g acceleration, 3 axes, 2 hours per axis

**Pass criteria**: No rattling, no component dislodged, functional after test.

---

### T7–T9: Ingress Protection (IP67 + IPX5)

**T7: Dust (IP6X)** — IEC 60529
- 8 hours in dust chamber with talc powder
- Post-test: disassemble, inspect for dust ingress
- Pass: no dust penetration to electronics

**T8: Immersion (IPX7)** — IEC 60529
- Submerge to 1m depth for 30 minutes
- Post-test: disassemble, inspect for water ingress
- Pass: no water inside enclosure

**T9: Water jet (IPX5)** — IEC 60529
- 12.5 L/min from 6.3mm nozzle, 3m distance, all directions, 3 minutes
- Post-test: inspect for water ingress
- Pass: no water inside enclosure

---

## Test Sequence (Recommended Order)

```
Week 1:  T1 (High temp) → T2 (Low temp) → T3 (Temp cycling)
         [Non-destructive, same 3 units]
Week 2:  T4 (Damp heat, 96h)
         [Same or fresh 3 units]
Week 3:  T6 (Vibration) → T7+T8+T9 (IP tests)
         [2 dedicated units for IP]
Week 4:  T5 (Drop test — last, most destructive)
         [3 dedicated units]
```

**Rationale**: Non-destructive tests first to maximize data from each sample. Drop test last because it may physically damage units.

---

## Test Equipment Requirements

| Equipment | Specification | For Tests |
|-----------|--------------|-----------|
| Temperature chamber | Range: -40C to +85C, ramp 1-5C/min | T1, T2, T3 |
| Humidity chamber | Range: 10-98% RH, +10C to +85C | T4 |
| Drop test fixture | Adjustable height, orientation control | T5 |
| Vibration shaker | 10-500Hz, up to 5g, 3-axis | T6 |
| Dust chamber | IEC 60529 compliant | T7 |
| IP water test setup | Immersion tank (1m+), water jet nozzle | T8, T9 |

**Estimated test lab cost**: [UNVALIDATED — varies by region, typically $3,000–$10,000 USD for full suite at a third-party lab]

**Estimated lead time**: 2–4 weeks (including queue time at commercial test labs)
