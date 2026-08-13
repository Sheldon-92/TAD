# Review Checklist — Personas + Gate Standards

Reviewer personas and checklists preserved from source pack (v1.0). Use for expert review of hardware testing work and for Gate 2 / Gate 4 acceptance.

## Per-Capability Reviewer Personas

### Power-On Test

**Hardware Test Engineer**
- Power-on sequence matches schematic power tree?
- All rails have ±5% tolerance and measurement points?
- Current limit set before first power-on?
- Smoke test included as explicit step?

**Safety Engineer**
- Protection circuits documented and tested?
- No high-voltage rails measured without proper equipment?
- ESD precautions mentioned?

### Functional Test

**Embedded Systems Engineer**
- All peripherals from BOM covered?
- I2C addresses verified against datasheet?
- Test scripts match the actual MCU platform (Arduino/MicroPython/ESP-IDF)?

**QA Engineer**
- Pass/fail criteria quantitative?
- Test results include actual measurements?
- Regression test list updated?

### Power Measurement

**Power Electronics Engineer**
- Measurement setup correct (ammeter placement, range selection)?
- Deep sleep current within datasheet expectations?
- Battery life calculation formula correct?
- Derating factor applied?

**Product Manager**
- Usage profile matches real product scenario?
- Battery life meets product requirement?
- Optimization plan prioritized by impact/effort?

### Environmental Test

**Reliability Engineer**
- Standards correctly referenced?
- Test conditions appropriate for product category?
- Sample sizes adequate?
- Non-destructive tests scheduled before destructive?

**Mechanical Engineer**
- Drop test height appropriate for product form factor?
- Temperature range covers worst-case deployment scenario?
- Ingress protection level justified by use case?

### EMC Pre-Compliance

**EMC Engineer**
- All clock harmonics analyzed against emission limits?
- ESD protection on every external interface?
- Ground plane integrity verified?
- Near-field probe measurement methodology correct?

**Compliance Manager**
- Target markets identified with correct standards?
- Pre-compliance testing covers critical frequency ranges?
- Formal test lab budget and timeline estimated?

### Test Fixture

**Manufacturing Engineer**
- Fixture compatible with production line workflow?
- Cycle time <30 seconds achievable?
- Operator instructions clear for non-engineers?
- Pogo pin lifecycle adequate for production volume?

**Test Engineer**
- All critical test points accessible?
- Programming interface reliable (SWD/JTAG)?
- Self-test firmware covers all peripherals?
- Test result logging automated?

### HW Pair Testing

**Senior HW Engineer**
- Measurement methodology correct for each test point?
- Anomaly root cause analysis plausible?
- Hardware fix recommendations safe and practical?

**QA Lead**
- All measurements recorded with traceability?
- Decisions documented for every finding?
- Action items have owners and deadlines?

## Gate 2 (Design) Checklist

- Test plan covers all 7 capabilities relevant to the product
- Power-on checklist complete with all voltage rails identified
- Peripheral test list matches BOM (every IC has a test)
- Environmental test conditions reference applicable standards
- EMC pre-compliance checklist addresses all external interfaces
- Test fixture design matches PCB test point layout

## Gate 4 (Acceptance) Checklist

- Power-on: all voltage rails within ±5% of nominal
- Power-on: quiescent current within datasheet typical ±20%
- Functional: E-ink display refreshes without artifacts, <3s full refresh
- Functional: all I2C devices respond at expected addresses
- Functional: WiFi/BLE scan returns results, RSSI >-70 dBm at 1m
- Power: deep sleep current measured on µA range, <10µA for ESP32-C3
- Power: battery life calculation shows formula with actual measured values
- Environmental: test plan ready for lab submission with standard references
- EMC: design review complete, ESD protection on all external ports verified
- Fixture: test point map matches PCB, pogo pin specs selected
- All measurement values are from actual instruments — 编造数据 = FAIL
