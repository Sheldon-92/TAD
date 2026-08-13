---
name: hw-testing
description: "Hardware testing capability pack. Covers power-on testing (voltage rails, smoke test), functional peripheral verification, per-mode power measurement and battery life calculation, environmental test planning (IEC/MIL standards), EMC pre-compliance (emissions/ESD), production test fixture design, and human-AI pair testing with physical instruments (4D Protocol) — embedded MCU prototypes first. Use for any hardware bring-up, prototype validation, power profiling, compliance pre-check, or production test task."
version: 0.1.0
type: reference-based
keywords: ["hardware testing", "硬件测试", "power-on", "上电测试", "smoke test", "冒烟测试", "voltage rail", "电压轨", "functional test", "功能测试", "peripheral", "外设", "power measurement", "功耗测量", "deep sleep", "深度睡眠", "battery life", "电池续航", "environmental test", "环境测试", "IEC 60068", "EMC", "电磁兼容", "ESD", "静电", "FCC", "pre-compliance", "预检", "test fixture", "测试治具", "pogo pin", "探针", "pair testing", "人机协作测试", "multimeter", "万用表", "oscilloscope", "示波器", "embedded", "嵌入式", "MCU", "prototype", "样机", "量产测试"]
---

# Hardware Testing Capability Pack

> From power-on to production validation — physical measurement + AI-guided analysis.
> **Scope (v0.1, inherited from source v1.0)**: Embedded hardware prototypes (MCU-based, battery-powered devices). Hardware testing requires PHYSICAL instruments (multimeter, oscilloscope, power analyzer) — this pack's value is what to test + how to test + pass/fail criteria + documentation.
> **UNIVERSAL RULE**: 编造数据 = FAIL. Every voltage, current, RSSI, timing, or sensor value must come from an actual instrument reading (human-reported for pair testing). Fabricated measurements, standard citations, or harmonic numbers = FAIL. Measure it or report "not measured".

---

## Step 1: Context Detection

| User Signal / Task Type | Load Reference |
|---|---|
| new board bring-up, first power-on, voltage rails, smoke test, 上电, 冒烟测试, 电源轨 | `references/power-on-test.md` |
| peripheral verification, display/sensor/button/WiFi/BLE/SD test, I2C scan, 外设, 功能测试 | `references/functional-test.md` |
| power profiling, sleep current, battery life, µA, 功耗, 续航, 深度睡眠 | `references/power-measurement.md` |
| temperature/humidity/drop/vibration test plan, IP rating, IEC 60068, MIL-STD, 环境测试 | `references/environmental-test.md` |
| EMC, radiated/conducted emissions, ESD, FCC/CE/CCC, harmonics, 电磁兼容, 预检 | `references/emc-precheck.md` |
| production test, bed-of-nails, pogo pin, jig, cycle time, 治具, 量产 | `references/test-fixture.md` |
| human at the bench with instruments, guided measurement, 4D protocol, 人机协作 | `references/hw-pair-testing.md` |
| before Gate review / reviewing hw test work / acceptance check | `references/review-checklist.md` |

**Multi-signal**: load all matched references.

---

## Step 2: Decision Entry Point

**Q1 — Where is the board in its lifecycle?**
- Fresh from fab, never powered → START with `power-on-test.md` (ALWAYS first — nothing else before rails verify)
- Powers on, peripherals unverified → `functional-test.md` (priority: power → comms → display → sensors → wireless → storage)
- Works, battery-powered product → `power-measurement.md` (per-mode profile + battery life calc)
- Heading to test lab / certification → `environmental-test.md` + `emc-precheck.md` (design review BEFORE paying for lab time)
- Heading to production → `test-fixture.md`

**Q2 — Is a human at the bench with instruments?** → `hw-pair-testing.md` (Mixed type: human operates, AI guides + analyzes; human reads every value)

**Q3 — Capability type determines workflow shape**:
- Code B (power-on, functional, power): select → execute → verify → optimize — generates scripts/checklists/procedures
- Doc A (environmental, EMC, fixture): search → analyze → derive → generate — standards MUST be looked up, never guessed
- Mixed (pair testing): prepare → discover → discuss → decide → deliver

**Q4 — Reviewing or accepting work?** → ALSO load `review-checklist.md` (personas + Gate 2/Gate 4 checklists).

---

## Step 3: Core Judgment Rules

### Power-On (`references/power-on-test.md`)
- Spec-first measurement: ALL pass/fail specs MUST be declared BEFORE executing tests (thresholds from datasheet/schematic design intent, never from the measurement itself — source: OpenHTF)
- Before power: continuity check VCC↔GND expect >1kΩ (short = DO NOT POWER ON); bench supply current limit 100mA initially
- At power-on: idle draw expect <50mA typical MCU board; >200mA immediately → POWER OFF; smoke test (5s heat/smell watch) is a mandatory explicit step
- Rails: every rail has expected value, ±5% tolerance, measurement point; any rail >±10% off nominal = FAIL; quiescent current within datasheet typical ±20%; no component >50°C at idle
- Record actual measured values, never just PASS/FAIL

### Functional (`references/functional-test.md`)
- Every peripheral on the BOM has a test; mark CRITICAL vs OPTIONAL — PASS = all CRITICAL pass
- Every test has quantitative pass/fail criteria (never "it works"); sensor readings compared to reference instrument or datasheet typicals
- Wireless MUST include RSSI (expect >-70 dBm at 1m from AP); storage MUST use write-read-verify byte match
- Completeness = % of BOM peripherals covered, not test count; define a hardware-mocking path (pyvisa-sim or equivalent) for CI regression

### Power Measurement (`references/power-measurement.md`)
- Deep sleep on µA range, never auto-range (injects noise); switch range BEFORE entering sleep; wait 10s for stable reading
- Sleep current >100µA → suspect a peripheral not powered down; flag if > datasheet typical ×2
- Sanity: deep sleep < idle < active, or the measurements are inconsistent
- Battery life: formula shown with actual measured values (I_avg over a realistic usage profile), then apply 80% derating; compare against the product requirement

### Environmental (`references/environmental-test.md`)
- Every test condition traceable to a specific IEC/MIL/ISO standard clause — look up, never guess
- Severity matches the product's real environment; sample size ≥3 units per test; non-destructive tests BEFORE destructive
- Battery behavior at temperature extremes explicitly addressed (LiPo degrades below 0°C)

### EMC Pre-Compliance (`references/emc-precheck.md`)
- Design review BEFORE measurement (cheaper to fix on paper); inventory ALL clock frequencies and calculate harmonics from actual values
- ESD protection verified on EVERY external port: USB ≥±8kV contact (IEC 61000-4-2 Level 4), other ports ≥±4kV contact
- Thresholds = FCC Part 15 Class B radiated (3m): 40.0 dBµV/m @30-88MHz, 43.5 @88-216MHz, 46.0 @216-960MHz, 54.0 @>960MHz; conducted (QP): 66→56 dBµV @150-500kHz, 56 @0.5-5MHz, 60 @5-30MHz
- Standards cited with edition/year and matched to target market (FCC/CE/CCC)

### Test Fixture (`references/test-fixture.md`)
- Test point map from actual PCB design files, never assumed; every PCB test point mapped to a fixture contact
- Pogo pins: ≥2A rating for power, ≥0.5A signal, contact resistance <50mΩ, >100K cycle life for production; alignment repeatability <±0.2mm
- Test sequence <30s per board; pass/fail automated via UART self-test parsing; operator guide requires no engineering knowledge
- Fixture BOM complete with part numbers; maintenance plan included (pogo pins wear out)

### HW Pair Testing (`references/hw-pair-testing.md`)
- ONLY the human reads instruments — AI never produces a measurement value; AI specifies instrument + range for every measurement request
- Anomalies get differential diagnosis (ranked causes), not "it failed"; AI analysis cites datasheet values and tolerances
- Decide in-session while the probe is on the board; human makes severity/priority decisions and approves any hardware modification
- Record instrument model/calibration status for traceability; log complete enough to reproduce the session

---

## Anti-Patterns

### Power-On
- ❌ Powering on without checking for shorts first (can destroy board)
- ❌ Setting bench supply to unlimited current (use 100mA limit initially)
- ❌ Skipping visual inspection (solder bridges are the #1 prototype killer)
- ❌ Recording only PASS/FAIL without actual measured values
- ❌ Testing with battery before bench supply verification (battery has no current limit)
- ❌ Measuring first, then deciding pass/fail (spec-first measurement: declare thresholds from datasheet/design BEFORE testing — source: OpenHTF)

### Functional
- ❌ Testing only happy path ('it displayed something' without checking correctness)
- ❌ Skipping I2C address scan (address conflicts are common on prototype boards)
- ❌ Not recording actual sensor values (only PASS/FAIL loses diagnostic data)
- ❌ Testing wireless without RSSI measurement (range problems hide in 'connected = pass')
- ❌ Assuming SD card works after 1 write (test with larger payload for reliability)
- ❌ No hardware abstraction layer in test scripts (tests coupled to specific instruments = can't run in CI — source: awesome-hardware-test)
- ❌ Paper/Excel-based test management (no traceability, no version control — source: OpenHTF test database pattern)

### Power Measurement
- ❌ Using auto-range multimeter for µA measurements (injects measurement noise)
- ❌ Calculating battery life from datasheet typical values instead of actual measurements
- ❌ Not derating battery life estimate (real-world is 70-80% of calculated)
- ❌ Measuring deep sleep current immediately after entering sleep (wait for stabilization)
- ❌ Ignoring peripheral quiescent current (LDO Iq can dominate in deep sleep)

### Environmental
- ❌ Applying MIL-STD-810H to a consumer desk gadget (overkill, expensive)
- ❌ Not testing at temperature extremes with battery powered (LiPo at -20°C is a real failure mode)
- ❌ Testing only 1 sample (insufficient for reliability conclusions)
- ❌ Doing drop test before temperature test (drop test may damage device, invalidating later tests)
- ❌ Specifying IP67 without understanding the test cost and design implications

### EMC
- ❌ Skipping design review and going straight to measurement (cheaper to fix on paper)
- ❌ Not testing ESD on USB port (most common compliance failure)
- ❌ Assuming shielding solves everything (shielding without proper grounding makes it worse)
- ❌ Ignoring cable radiation (cables are often the dominant emission source)
- ❌ Using unshielded DCDC inductor and hoping for the best
- ❌ Testing without chamber calibration (must verify 16 points in 1.5m×1.5m area first — source: GTEM cell testing guide)
- ❌ Frequency step size >1% of current frequency or dwell time <0.5s/frequency (insufficient resolution — source: IEC 61000-4-3)
- ❌ EUT cables touching reference ground plane (must be elevated ≥30mm — source: EMC pre-compliance testing guide)

### Test Fixture
- ❌ Designing fixture without PCB test point layout (fixture must match PCB exactly)
- ❌ Using undersized pogo pins for power rails (need ≥2A rating for VCC/GND)
- ❌ No alignment mechanism (operator will misalign, pogo pins will miss pads)
- ❌ Manual pass/fail judgment (automate with UART self-test output parsing)
- ❌ Forgetting maintenance plan (pogo pins wear out, contact resistance increases)

### HW Pair Testing
- ❌ AI fabricating measurement values (only human reads the instrument)
- ❌ Deferring all decisions to 'review meeting later' (decide while probe is on board)
- ❌ Measuring without specifying instrument range (auto-range on µA measurements = noise)
- ❌ AI deciding hardware modifications without human approval
- ❌ Not recording instrument model/calibration status (traceability)

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "Board looks fine, just power it on" | MUST run pre-power checks in `power-on-test.md`: visual inspection + VCC↔GND continuity (>1kΩ) + 100mA supply limit first |
| "I'll decide pass/fail once I see the numbers" | MUST declare measurement specs from datasheet/schematic BEFORE testing (spec-first, OpenHTF pattern) |
| "It connected to WiFi, wireless passes" | MUST record RSSI (>-70 dBm at 1m) per `functional-test.md` — connected-only hides range problems |
| "Datasheet says 5µA sleep, use that for battery life" | MUST measure actual sleep current on µA range and apply 80% derating per `power-measurement.md` |
| "Standard conditions are roughly -20 to +60°C" | MUST cite the specific IEC/MIL clause per `environmental-test.md` — never guess test conditions |
| "We'll find EMC issues at the lab" | MUST complete the design review + harmonic inventory in `emc-precheck.md` first — lab time is $5K-$15K |
| "Fixture layout from the board photos" | MUST derive test points from actual PCB design files per `test-fixture.md` |
| "I'll estimate the reading, human is busy" | Only the human reads instruments (`hw-pair-testing.md`). Fabricated values = FAIL across every capability |
