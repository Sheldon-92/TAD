# Environmental Test Analysis: Wayo Elephant Tracker

## Product Environment Classification

| Question | Answer |
|----------|--------|
| Where will it be used? | Outdoor, tropical/savanna environment (Africa/Asia). Mounted on tree, fence post, or vehicle near elephants. |
| What weather exposure? | Direct sun, rain, dust, humidity. Temperature range: ~5C (cold dawn) to ~55C (direct sun on dark enclosure). |
| What abuse will it see? | Elephant interaction (trunk push, trampling risk), dropping during installation, vibration on vehicle. |
| Expected lifetime? | 2–5 years field deployment |
| Power source? | 18650 Li-ion + solar. Battery replacement expected annually. |
| Ingress protection needed? | Yes — dust (savanna) and rain (monsoon/rainy season). River crossing immersion unlikely but possible. |

---

## Test Selection Matrix

| # | Test | Applicable? | Standard | Severity Level | Reason | Sample Size |
|---|------|------------|----------|---------------|--------|-------------|
| 1 | High temperature operation | **YES** | IEC 60068-2-2 (Test Bd) | +60C, 16h | Direct sun on enclosure can reach 55C+ | 3 units |
| 2 | Low temperature operation | **YES** | IEC 60068-2-1 (Test Ad) | -10C, 16h | Cold dawn in highland areas; also tests 18650 at low temp | 3 units |
| 3 | Temperature cycling | **YES** | IEC 60068-2-14 (Test Na) | -10C to +60C, 5C/min ramp, 10 cycles | Daily thermal stress simulation | 3 units |
| 4 | Damp heat (steady state) | **YES** | IEC 60068-2-78 (Test Cab) | 40C / 93% RH, 96 hours | Tropical humidity, monsoon season | 3 units |
| 5 | Drop/shock | **YES** | IEC 60068-2-31 (Test Ec) | 1.5m height, 6 faces, onto concrete | Installation handling, accidental drop | 3 units |
| 6 | Vibration (sinusoidal) | **YES** | IEC 60068-2-6 (Test Fc) | 10–500Hz sweep, 1 octave/min | Vehicle transport, wind vibration | 3 units |
| 7 | Dust protection | **YES** | IEC 60529 (IP6X) | 8h dust chamber | Savanna dust | 2 units |
| 8 | Water protection | **YES** | IEC 60529 (IPX7) | 1m immersion, 30 min | Rain + possible river crossing | 2 units |
| 9 | Water jet (rain) | **YES** | IEC 60529 (IPX5) | 12.5 L/min, 3m distance | Heavy tropical rain | 2 units |
| 10 | UV aging | **CONSIDER** | IEC 60068-2-5 (Test Sa) | 1000h UV exposure [UNVALIDATED duration] | Outdoor sun exposure degrades enclosure plastic | 2 units |
| 11 | Salt spray | **NO** | N/A | N/A | Not a coastal/marine application | — |
| 12 | Altitude | **NO** | N/A | N/A | Device operates at ground level | — |

---

## Per-Test Notes

### Test 1: High Temperature (+60C)
- **Battery concern**: 18650 discharge at 60C accelerates aging but capacity is near-nominal. Safety concern if enclosure traps heat above 60C.
- **E-ink concern**: Waveshare ACeP displays typically rated 0–50C operating. At 60C, display may show degraded contrast [UNVALIDATED — check Waveshare datasheet for exact operating range].
- **Pass criteria**: Device boots, all functions work, display readable, no physical damage, battery does not vent.

### Test 2: Low Temperature (-10C)
- **Battery concern**: At -10C, 18650 capacity drops to ~60% of nominal. Device must still operate. Source: [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/)
- **E-ink concern**: E-ink refresh time increases at low temperature. Typical response time 2–3x slower below 0C [UNVALIDATED].
- **Pass criteria**: Device boots, WiFi connects, display updates (may be slower), battery powers device for at least 50% of room-temp duration.

### Test 3: Temperature Cycling (-10C to +60C)
- **Solder joint concern**: Thermal cycling is the #1 cause of solder joint failure on prototype boards. After 10 cycles, inspect under magnification for cracking.
- **Seal concern**: If enclosure uses gaskets/O-rings, thermal cycling can compress or harden seals.
- **Pass criteria**: No solder joint failures (visual + functional test), enclosure integrity maintained, all functions work.

### Test 5: Drop Test (1.5m)
- **Enclosure concern**: Will the 18650 battery stay secured? Battery ejection = safety hazard.
- **E-ink concern**: E-ink glass panel is fragile. May crack on drop if not properly mounted with foam/gasket.
- **Pass criteria**: Enclosure intact, display uncracked, battery secured, device boots and all functions work.

### Tests 7–9: Ingress Protection
- **Recommendation**: Target IP67 (dust-tight + 1m immersion). Also test IPX5 (rain jet) separately since IP67 does not imply IPX5 compliance (per IEC 60529).
- **Design implication**: All cable entries, button openings, and USB charge ports must be sealed. Consider using wireless charging or magnetic pogo pins to avoid exposed ports.

---

## Total Sample Allocation

| Test Type | Units Needed | Notes |
|-----------|-------------|-------|
| Non-destructive (temperature, humidity, vibration) | 3 | Same units can be reused across non-destructive tests |
| Drop test (potentially destructive) | 3 | Dedicated units — may be damaged |
| IP testing (potentially destructive) | 2 | Dedicated units — may have water ingress |
| UV aging (long duration) | 2 | Dedicated — tied up for weeks |

**Minimum total prototype units needed**: 10 units (some can be reused if non-destructive tests are sequenced first)

**Test order**: Non-destructive first (temperature, humidity, vibration), then IP, then drop (most destructive last).
