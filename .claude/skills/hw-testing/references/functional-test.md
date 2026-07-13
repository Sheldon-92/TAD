# Functional Test (Code B: select → execute → verify → optimize)

Peripheral-by-peripheral verification — display, sensors, buttons, wireless, storage. Each subsystem tested independently.

## 1. Enumerate Peripherals (Select)

List all peripherals/subsystems on the board:
1. Display: type (E-ink/LCD/OLED), interface (SPI/I2C/parallel), resolution
2. Sensors: type (temp, humidity, IMU, light), interface, I2C address
3. User input: buttons, touch, rotary encoder — GPIO pins, debounce needed?
4. Wireless: WiFi, BLE, LoRa, Zigbee — module type, antenna
5. Storage: SD card, SPI flash, EEPROM — interface, capacity
6. Audio: speaker, microphone, codec — interface (I2S/PDM/analog)
7. Motor/actuator: type, driver IC, PWM frequency
8. Other: RTC, USB, LED strips, etc.

For each: mark as CRITICAL (must work) or OPTIONAL (nice to have).
Priority order: power → comms (serial/USB) → display → sensors → wireless → storage → others.
Output: `functional-test-plan.md` (peripheral inventory).

## 2. Display Test (Execute)

For E-ink (e.g., GDEW0154T8, SSD1681 controller):
1. Full refresh: fill screen white → black → white (verify no stuck pixels)
2. Pattern test: checkerboard pattern (verify all pixels addressable)
3. Text rendering: display "Hello World" + timestamp (verify font rendering)
4. Partial refresh: update a region (verify partial update works)
5. Measure refresh time: expect 2-3s full refresh for typical 1.54" E-ink

For LCD/OLED:
1. Color bars (R/G/B/W/K) → verify color channels
2. Brightness levels (0%, 50%, 100%) → verify backlight PWM
3. Touch calibration (if touchscreen)

Generate as Python/MicroPython script or Arduino sketch depending on platform (`test-display.py`).

## 3. Remaining Peripheral Tests (Execute)

── SENSORS ──
Temperature/humidity (e.g., SHT40, BME280):
- Read 10 samples, 1s interval → verify values in sane range (15-35°C, 20-80% RH)
- Compare with reference thermometer (±2°C acceptable for most sensors)
- I2C scan: verify device responds at expected address

IMU (e.g., MPU6050, LSM6DS3):
- Read accel at rest → expect ~0, 0, ±9.8 m/s² (±0.5)
- Read gyro at rest → expect ~0, 0, 0 °/s (±5)
- Tilt test: rotate 90° → accel axis should shift by ~9.8

── BUTTONS/INPUT ──
- Press each button → verify GPIO interrupt/poll triggers
- Debounce test: rapid press → verify no double triggers
- Long press: hold 3s → verify long-press event fires

── WIRELESS ──
WiFi:
- Scan networks → expect ≥1 SSID found
- Connect to known AP → verify DHCP, ping gateway
- RSSI measurement: expect >-70 dBm at 1m from AP

BLE:
- Start advertising → verify visible from phone (nRF Connect app)
- GATT service discovery → verify custom service UUID
- Data transfer: send 100 bytes → verify received correctly

── STORAGE ──
SD card / SPI flash:
- Write 1KB test pattern → read back → verify byte-for-byte match
- Write speed measurement: write 1MB → measure time (expect >100KB/s for SD)
- Filesystem: mount, create file, list directory

Generate individual test scripts for each peripheral (`test-peripherals/`, one script per peripheral).

## 4. Verify Functional (Verify)

Run all peripheral tests and compile results:

| Peripheral | Test | Expected | Actual | PASS/FAIL | Notes |
|-----------|------|----------|--------|-----------|-------|
| E-ink     | Full refresh | <3s, no artifacts | | | |
| SHT40     | Temp reading | 15-35°C | | | |
| WiFi      | Scan networks | ≥1 SSID | | | |
| BLE       | Advertise | Visible on phone | | | |
| SD card   | Write/read | 1KB match | | | |
| Button A  | Press detect | GPIO trigger | | | |

Criteria for PASS: all CRITICAL peripherals pass. OPTIONAL failures noted but don't block.
Output: `functional-test-results.md`.

## 5. Optimize (document known issues and workarounds)

1. Failed peripherals: root cause analysis (hardware? software? configuration?)
2. Marginal results: document and add to regression test
3. Generate a consolidated functional test report with:
   - Board revision, serial number, test date
   - Per-peripheral PASS/FAIL with measurements
   - Known issues and workarounds
   - Recommended firmware version for each test
4. Create a quick-test script that runs all automated tests in sequence

Output: `functional-test-report.pdf` (consolidated results).

## Quality Criteria (pass/fail for this capability's artifacts)

- Every peripheral on the BOM has a test procedure
- Each test has quantitative pass/fail criteria (not just "works")
- Sensor readings compared against reference instrument or datasheet typical values
- Wireless tests include RSSI/signal quality measurement
- Storage tests include write-read-verify pattern
- Test completeness measured by coverage (% of BOM peripherals tested), not by test count — source: awesome-open-hardware-verification pattern
- Hardware mocking path defined for CI: pyvisa-sim or equivalent for automated regression without physical hardware — source: awesome-hardware-test
- 编造数据 = FAIL — sensor readings, RSSI values, timing measurements must be real
