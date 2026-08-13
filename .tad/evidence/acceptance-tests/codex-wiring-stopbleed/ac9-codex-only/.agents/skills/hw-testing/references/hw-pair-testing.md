# HW Pair Testing (Mixed type: prepare → discover → discuss → decide → deliver)

Human + AI collaborative hardware testing using the 4D Protocol — Human operates instruments (multimeter, oscilloscope, logic analyzer), AI guides measurement sequence + analyzes readings + identifies anomalies.

## 1. Prepare Session

Before starting a HW pair testing session:
1. Confirm available instruments:
   - Multimeter (DMM): brand/model, resolution (4.5 digit preferred for µA)
   - Oscilloscope: bandwidth (≥100MHz for digital), probe count
   - Logic analyzer: sample rate, channel count
   - Power supply: voltage/current range, current readback resolution
   - Optional: thermal camera, LCR meter, spectrum analyzer
2. Confirm board under test:
   - Board revision, serial number
   - Firmware version loaded
   - Known issues from previous tests
3. Define session focus (human decides):
   - "I want to debug why deep sleep current is too high"
   - "I want to verify the new display controller works"
   - "I want to check EMC before sending to lab"
4. AI prepares measurement sequence for the focus area

Output: `hw-pair-session-plan.md`.

## 2. Discover — Human Measures, AI Analyzes

Iterative discovery cycle (repeat for each measurement):
1. AI instructs: "Measure voltage at TP3 (3V3 rail) with multimeter on DC V range"
2. Human measures and reports: "Reading: 3.287V"
3. AI analyzes:
   - Expected: 3.300V ±5% (3.135V - 3.465V)
   - Actual: 3.287V → PASS (within spec, -0.4% deviation)
   - Context: slight low reading could indicate load regulation — check current draw
4. AI guides next measurement based on findings:
   - If nominal → move to next test point
   - If anomaly → drill down (measure upstream, check load, probe with scope)
5. For oscilloscope measurements:
   - Human captures screenshot/photo of scope display
   - AI analyzes waveform: frequency, amplitude, rise time, ringing, noise
   - "Take photo of scope screen showing SPI clock to E-ink display"
6. For current measurements:
   - Guide human through ammeter insertion point
   - Specify range selection (start high, go lower for resolution)

Each round: one measurement → analysis → decision on next step.
Output: `hw-pair-findings/` (measurement logs).

## 3. Discuss — Interpret Results Together

For each finding, discuss (4D Protocol):
1. What does this measurement mean?
   - AI: "3.287V is within spec but 13mV low. At 200mA load, this suggests ~65mΩ total path resistance (trace + connector). Normal for prototype."
2. Is this a problem?
   - Human judges: "Acceptable for prototype, but trace width should increase for production."
3. What could cause anomalies?
   - AI provides differential diagnosis:
     "Deep sleep current of 150µA (expected <10µA) → possible causes:
      a) GPIO pin left floating (most common, ~50µA per pin)
      b) LDO quiescent current higher than expected (check datasheet Iq)
      c) Peripheral not fully powered down (check enable pin state)
      d) LED leakage through reverse-biased GPIO"
4. What should we check next?
   - Human and AI decide together based on the diagnosis

Key: "1M context means we remember every measurement from round 1. No need to re-measure."
Output: `hw-pair-discussion.md` (append per round).

## 4. Decide — Make Decisions In-Session

For each finding, decide NOW:
1. Hardware fix needed — document: what to modify, which component, expected improvement
   - Example: "Add 10kΩ pull-down on GPIO4 to eliminate 50µA leakage"
2. Firmware fix needed — document: what to change in code
   - Example: "Configure GPIO4 as input with pull-down before entering deep sleep"
3. Acceptable as-is — document reasoning
   - Example: "3V3 rail at 3.287V is within ±5% spec, no action needed"
4. Needs further investigation — document what equipment/test is needed
   - Example: "Need spectrum analyzer to identify 240MHz peak source"

Decisions made with probe still on the board > decisions made from memory later.
Output: `hw-pair-decisions.md`.

## 5. Deliver — Compile Session Report

Generate session report:
1. Session summary: board ID, instruments used, focus area, rounds completed
2. Measurement log table:

   | Round | Test Point | Expected | Measured | Verdict | Decision |
   |-------|-----------|----------|----------|---------|----------|
   | 1 | TP3 (3V3) | 3.300V ±5% | 3.287V | PASS | Accept |
   | 2 | TP5 (VBAT) | 4.200V | 4.187V | PASS | Accept |
   | 3 | Deep sleep I | <10µA | 150µA | FAIL | Fix GPIO4 |

3. Action items: hardware modifications, firmware changes, follow-up tests
4. Updated baseline measurements (for regression comparison)

Generate as PDF with measurement summary table.
Output: `hw-pair-test-report.pdf`.

## Quality Criteria

- Every measurement has: test point, expected value, actual value, instrument used
- AI analysis references datasheet values and tolerances
- Anomalies investigated with differential diagnosis (not just "it failed")
- Decisions made in-session for every finding
- Measurement log complete enough to reproduce the session
- Human makes severity/priority decisions (not AI alone)
- 编造数据 = FAIL — all measurement values must come from human-reported instrument readings
