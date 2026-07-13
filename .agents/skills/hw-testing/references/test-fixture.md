# Test Fixture Design (Doc A: search → analyze → derive → generate)

Test fixture design for production testing — pogo pin contact, programming header, test point access, reproducibility.

## 1. Search Fixture Design Practices

1. Fixture types for electronics:
   - Bed-of-nails: pogo pins contact PCB test points (most common for production)
   - Clamshell: hinged fixture with alignment pins (faster operator cycle time)
   - Flying probe: automated but slow (for prototyping, not production)
2. Component selection (web research):
   - "pogo pin spring contact PCB test" — pitch, stroke, current rating
   - "PCB alignment pin press-fit fixture" — accuracy ±0.1mm
   - "test fixture 3D printed jig" — rapid prototyping approach
   - "Tag-Connect pogo pin programming cable footprint"
3. Programming interface requirements:
   - SWD/JTAG: need SWDIO, SWCLK, GND, VCC (4 pins minimum)
   - UART: need TX, RX, GND (3 pins for serial flash)
   - Tag-Connect: pogo pin programming cable (no headers needed on PCB)
4. Production test sequence research:
   - "production test fixture cycle time" (target: <30 seconds per board)
   - "automated test sequence programming + verification"

Quality bar: Fixture design must reference actual pogo pin specifications (pitch, stroke, contact resistance).
Output: `fixture-research.md`.

## 2. Analyze Fixture Requirements for This Board

1. Test point inventory from PCB (MUST come from actual PCB design files, not assumed):

   | Test Point | Signal | Purpose | Pin Type | Location (mm) |
   |-----------|--------|---------|----------|--------------|
   | TP1 | 3V3 | Rail verify | Pogo | Top, (12, 45) |
   | TP2 | GND | Reference | Pogo | Top, (14, 45) |
   | TP3 | SWDIO | Programming | Pogo | Bottom, (8, 20) |
   | TP4 | SWCLK | Programming | Pogo | Bottom, (10, 20) |
   | TP5 | UART_TX | Serial log | Pogo | Top, (30, 10) |
   | TP6 | UART_RX | Serial cmd | Pogo | Top, (32, 10) |

2. Fixture requirements:
   - Single-side or dual-side contact? (prefer single-side to simplify fixture)
   - Board alignment method: edge guides, alignment holes, or vision system
   - Operator interface: manual press, pneumatic clamp, or lever
   - Cycle time target: <30 seconds (insert + test + remove)
3. Production volume estimate:
   - <100 units: manual fixture with 3D-printed jig is sufficient
   - 100-10K units: aluminum fixture with pogo pins, manual operation
   - >10K units: automated fixture with pneumatic clamp + test software

Output: `fixture-requirements.md`.

## 3. Derive the Fixture Design

1. Mechanical design:
   - Base plate: material (aluminum for production, 3D print for prototype)
   - Board cradle: edge guides with 0.2mm clearance per side
   - Alignment pins: 2× press-fit pins matching PCB mounting holes
   - Pogo pin selection:

     | Parameter | Specification |
     |-----------|--------------|
     | Pitch | ≥2.54mm (standard), 1.27mm (fine pitch) |
     | Stroke | 1.0-2.0mm (allows for board warpage) |
     | Contact resistance | <50mΩ |
     | Current rating | ≥2A for power pins, ≥0.5A for signal |
     | Tip shape | Crown/serrated for through-hole pads, flat for SMD pads |
     | Lifecycle | >100K cycles for production |

2. Electrical design:
   - Wiring from pogo pins to test controller (shielded for analog signals)
   - Power injection: supply 5V/3.3V through fixture (or USB connector)
   - Programming connection: SWD/JTAG header to J-Link/ST-Link debugger
   - Serial connection: UART to USB adapter for test log capture
3. Test sequence (automated):
   - Step 1: Apply power, verify rails (power-on test subset)
   - Step 2: Flash firmware via SWD (5-15 seconds)
   - Step 3: Run self-test firmware (tests all peripherals, reports via UART)
   - Step 4: Verify UART output matches expected pattern
   - Step 5: Record serial number + test result to database/CSV
   - Step 6: Power off, operator removes board
4. Fixture BOM: list all components needed to build the fixture.

Output: `fixture-design-spec.md`.

## 4. Generate Fixture Documentation

1. Fixture design drawing (top view, side view with dimensions) using D2
2. BOM (Bill of Materials) for fixture construction
3. Assembly instructions for building the fixture
4. Test sequence flowchart (D2 diagram)
5. Operator guide: step-by-step with expected pass/fail indicators
   - Green LED = PASS, Red LED = FAIL, Yellow LED = RETEST
6. Maintenance schedule: pogo pin replacement every 100K cycles

Generate as PDF for manufacturing handoff (`test-fixture-design.pdf`).

## Quality Criteria (pass/fail for this capability's artifacts)

- Every test point on PCB mapped to fixture contact point
- Pogo pin specifications match PCB pad size and pitch
- Test sequence completes in <30 seconds per board
- Alignment method achieves <±0.2mm repeatability
- Fixture BOM includes all components with part numbers
- Operator guide requires no engineering knowledge to follow
- 编造数据 = FAIL — fixture dimensions, pogo pin specs must match actual PCB design
