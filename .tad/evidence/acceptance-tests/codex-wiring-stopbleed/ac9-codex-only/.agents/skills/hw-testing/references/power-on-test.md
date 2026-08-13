# Power-On Test (Code B: select → execute → verify → optimize)

Power-on sequence verification — voltage rails, current limits, LED indicators, smoke test. First test on every new board.

## 1. Identify Power Rails (Select)

Identify all power rails and their expected values from schematic:
1. List every voltage rail: VIN, 3V3, 1V8, VBAT, VBUS, etc.
2. For each rail: expected voltage ±5% tolerance, max current rating, regulator type (LDO/DCDC)
3. Identify power-on sequence order (which rail must be stable before the next)
4. Identify test points (TP) or accessible measurement locations for each rail
5. Note protection circuits: reverse polarity, overcurrent, overvoltage, TVS diodes

If schematic not available → list known rails from MCU datasheet + board markings.

Output: `power-on-test-plan.md` (rail identification + sequence).

## 2. Declare Measurement Specs BEFORE Testing (source: OpenHTF spec-first measurement pattern)

⚠️ MUST complete BEFORE any measurements. Declare pass/fail specs upfront:

For each voltage rail from the rail identification step:

```yaml
measurement:
  name: "{rail_name}_voltage"
  expected: {nominal_value}   # from schematic
  tolerance: ±5%              # or tighter per regulator datasheet
  unit: "V"
  validator: "in_range({min}, {max})"
```

For current draw:

```yaml
measurement:
  name: "idle_current"
  expected: "<50mA"           # typical for MCU board without WiFi
  abort_threshold: ">200mA"   # immediate power-off
  unit: "mA"
```

This prevents the "measure first, decide pass/fail after" anti-pattern.
All thresholds from datasheet or schematic design intent — not from actual measurement.
Output: measurement spec table (`measurement-specs.md`, used by all subsequent test steps).

## 3. Power-On Checklist (execute in exact order)

── PRE-POWER CHECKS ──
1. Visual inspection: solder bridges, missing components, reversed polarity marks
2. Continuity check: VCC to GND must NOT be short (multimeter beep mode)
   - Expect: >1kΩ (short = DO NOT POWER ON)
3. Set bench supply current limit to 100mA initially (prevent damage)

── POWER-ON SEQUENCE ──
4. Apply VIN at nominal voltage (e.g., 5V USB or 3.7V LiPo)
5. Monitor current draw: expect <50mA at idle for typical MCU board
   - If >200mA immediately → POWER OFF, check for shorts
6. SMOKE TEST: observe 5 seconds for heat, smoke, burning smell
   - Any anomaly → POWER OFF IMMEDIATELY

── RAIL VERIFICATION ──
7. Measure each rail with multimeter:

   | Rail | Expected | Tolerance | Actual | PASS/FAIL |
   |------|----------|-----------|--------|-----------|
   | 3V3  | 3.300V   | ±165mV    |        |           |
   | 1V8  | 1.800V   | ±90mV     |        |           |

8. LED indicator check: power LED on? status LED blinking?

── POST-POWER ──
9. MCU responds to serial/JTAG/SWD? (probe with logic analyzer or UART terminal)
10. Record all measurements in test log

Generate as executable checklist with checkboxes; printable PDF for the bench (`power-on-checklist.pdf`).

## 4. Serial Probe Script (Execute)

Generate serial port probe script for initial MCU communication check:

```python
# power_on_probe.py — verify MCU is alive via serial
import serial, sys, time
PORT = sys.argv[1] if len(sys.argv) > 1 else '/dev/tty.usbserial-0001'
BAUD = int(sys.argv[2]) if len(sys.argv) > 2 else 115200
try:
    ser = serial.Serial(PORT, BAUD, timeout=3)
    time.sleep(2)  # wait for boot message
    data = ser.read(1024)
    if data:
        print(f"✓ MCU responding: {data.decode(errors='replace')[:200]}")
    else:
        print("⚠ No data received — check UART TX/RX, baud rate, boot mode")
    ser.close()
except serial.SerialException as e:
    print(f"✗ Serial error: {e}")
```

Also generate a simple voltage logging template (CSV format) for recording measurements.

## 5. Verify Power-On (Verify)

Verify all power-on criteria met:
1. All voltage rails within ±5% of nominal
2. Quiescent current within expected range (datasheet typical ±20%)
3. No thermal anomalies (touch test: no component >50°C at idle)
4. MCU serial/debug port responsive
5. All protection circuits verified (if testable without destructive test)

Generate PASS/FAIL verdict with supporting measurements (`power-on-results.md`).
Any rail >±10% off nominal = FAIL (investigate before proceeding).

## 6. Optimize the Procedure (Optimize)

Refine power-on procedure based on results:
1. If any rail was marginal (>±3% but <±5%): add to watch list
2. If current draw was higher than expected: identify which subsystem draws most
3. Update checklist with actual measured values as baseline
4. Add board-specific notes (e.g., "J3 must be jumpered for USB power")
5. Generate final power-on SOP (Standard Operating Procedure) as PDF (`power-on-sop.pdf`)

## Quality Criteria (pass/fail for this capability's artifacts)

- Every voltage rail has expected value, tolerance, and measurement point documented
- Power-on sequence order matches schematic design intent
- Current limit set on bench supply BEFORE first power-on
- Smoke test explicitly included as a mandatory step
- Spec-first measurement: ALL pass/fail specs MUST be declared BEFORE executing tests (not decided after seeing results) — source: OpenHTF pattern
- All measurements recorded with actual values (not just PASS/FAIL)
- 编造数据 = FAIL — every voltage/current value must come from actual measurement
