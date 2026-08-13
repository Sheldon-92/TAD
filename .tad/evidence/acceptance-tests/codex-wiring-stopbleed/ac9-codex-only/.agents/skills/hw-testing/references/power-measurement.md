# Power Measurement (Code B: select → execute → verify → optimize)

Per-mode power profiling — active, idle, deep sleep. Battery life calculation based on actual measurements.

## 1. Define Power Modes (Select)

Identify all power modes for the device:
1. Active mode: CPU running, all peripherals on, display updating, wireless active
2. Idle mode: CPU running, peripherals on standby, display static, wireless connected but idle
3. Light sleep: CPU paused, RAM retained, wakeup sources active (GPIO, timer, UART)
4. Deep sleep: CPU off, only RTC + wakeup logic powered, RAM lost
5. Power-off / shipping mode: everything off, <1µA (battery disconnect or ultra-low-power shutdown)

For each mode: expected current (from MCU datasheet), measurement instrument needed:
- Active/Idle: multimeter on mA range (or bench supply current readout)
- Deep sleep: multimeter on µA range (CRITICAL: use µA range, not auto-range — auto-range injects noise)
- For dynamic profiling: oscilloscope + current sense resistor (10Ω for µA, 0.1Ω for mA)

Document the measurement circuit: where to insert ammeter (break battery line or use current sense header).
Output: `power-measurement-plan.md` (mode definitions + setup).

## 2. Measure Each Mode (Execute)

── ACTIVE MODE ──
1. Trigger worst-case scenario: display refresh + WiFi TX + sensor read simultaneously
2. Measure peak current (use oscilloscope for transients, multimeter for average)
3. Record: average current (mA), peak current (mA), duration of active period

── IDLE MODE ──
4. Wait for all peripherals to settle (>5s after last activity)
5. Measure steady-state current on mA range
6. Record: average current (mA) over 30s window

── DEEP SLEEP ──
7. Trigger deep sleep via firmware command
8. Switch multimeter to µA range (BEFORE entering sleep — switching causes glitch)
9. Wait 10s for stable reading
10. Record: sleep current (µA) — typical ESP32-C3: ~5µA, ESP32-S3: ~7µA, nRF52840: ~1.5µA
11. If reading is >100µA: suspect peripheral not powered down (check LDO quiescent, LED leakage)

── TRANSITION PROFILING ──
12. Optional: capture sleep→wake→active→sleep cycle on oscilloscope
13. Measure wake-up time: time from wakeup trigger to first instruction (~ms)

Visualization script (matplotlib, log scale because sleep current is 1000x less):

```python
# power_profile_chart.py — visualize power modes
import matplotlib.pyplot as plt
modes = ['Active', 'Idle', 'Light Sleep', 'Deep Sleep']
current_mA = [120, 25, 0.8, 0.005]  # Replace with actual measurements
fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.bar(modes, current_mA, color=['#e74c3c', '#f39c12', '#3498db', '#2ecc71'])
ax.set_ylabel('Current (mA)')
ax.set_title('Power Profile by Mode')
ax.set_yscale('log')
for bar, val in zip(bars, current_mA):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height(),
            f'{val} mA' if val >= 1 else f'{val*1000:.0f} µA',
            ha='center', va='bottom', fontweight='bold')
plt.tight_layout()
plt.savefig('power-profile.png', dpi=150)
print('Saved power-profile.png')
```

Output: `power-measurements.md` (raw data) + `power-profile.png`.

## 3. Calculate Battery Life (Verify)

1. Define usage profile (example for IoT sensor):
   - Active: 5s every 15min (sensor read + BLE transmit)
   - Idle: 0s (not used in this profile)
   - Deep sleep: remaining time (~14min 55s per cycle)
2. Calculate average current:
   `I_avg = (I_active × t_active + I_sleep × t_sleep) / t_cycle`
   Example: (120mA × 5s + 0.005mA × 895s) / 900s = 0.672 mA
3. Calculate battery life:
   Battery capacity (e.g., 500mAh LiPo) / I_avg = 744 hours = 31 days
4. Apply 80% derating for real-world conditions (temperature, aging, self-discharge):
   Practical battery life = 744h × 0.8 = 595h ≈ 25 days
5. Compare against product requirement (e.g., "must last 30 days"):
   25 days < 30 days → FAIL → need to optimize (reduce active time, lower TX power, etc.)

Verify: measurements are self-consistent (deep sleep < idle < active).
Flag if deep sleep current > datasheet typical × 2 (something is not sleeping).
Output: `battery-life-calculation.md`.

## 4. Optimize Power (Optimize)

1. If deep sleep current too high:
   - Check: all GPIO pins configured (floating pins leak current)
   - Check: all peripherals powered down (LDO enable pins, MOSFET switches)
   - Check: pull-up/pull-down resistors not creating current paths
   - Check: LED leakage through GPIO (even 'off' LEDs can leak ~100µA)
2. If active current too high:
   - Reduce CPU clock frequency (80MHz vs 240MHz for ESP32)
   - Use DMA for data transfers instead of CPU polling
   - Reduce WiFi TX power (lower dBm = less range but less current)
   - Batch sensor reads instead of continuous polling
3. Generate optimization recommendation table:

   | Optimization | Current Savings | Complexity | Recommendation |
   |--------------|-----------------|------------|----------------|
   | Lower TX power 20→10 dBm | ~50mA peak reduction | Low | DO |
   | CPU 240→80 MHz | ~20mA active reduction | Low | DO |
   | Fix floating GPIO | ~50-500µA sleep reduction | Medium | DO |

4. Re-measure after optimizations, update power profile chart.

Output: `power-optimization-report.pdf`.

## Quality Criteria (pass/fail for this capability's artifacts)

- All power modes measured with actual instrument readings
- Deep sleep measured on µA range (not auto-range)
- Battery life calculation shows formula with actual measured values
- Usage profile matches realistic product scenario
- 80% derating applied for real-world battery life estimate
- Power profile chart generated from actual data
- 编造数据 = FAIL — current values must come from multimeter/oscilloscope readings
