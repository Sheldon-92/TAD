#!/usr/bin/env python3
"""
power_profile_chart.py — Visualize Wayo prototype power modes.
Generates bar chart of current consumption per power mode.

Usage:
    python power_profile_chart.py

Outputs: power-profile.png

Values below are from ESP32-C3 datasheet + Waveshare 5.65" E-ink specs.
Replace with ACTUAL MEASUREMENTS before using in reports.

Sources:
    - ESP32-C3 Datasheet v2.2: https://www.espressif.com/sites/default/files/documentation/esp32-c3_datasheet_en.pdf
    - ESP32-C3 Wireless Adventure Ch.12: https://espressif.github.io/esp32-c3-book-en/chapter_12/12.2/12.2.4.html
    - Waveshare 5.65" E-Paper: https://www.waveshare.com/5.65inch-e-paper-module-f.htm
"""

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import numpy as np

# ============================================================
# POWER PROFILE DATA — Replace with actual measurements!
# ============================================================
# Current values in mA
MODES = {
    'Active\n(WiFi TX)': {
        'current_mA': 180.0,    # Peak ~180-240mA, using conservative estimate
        'source': 'ESP32-C3 Datasheet',
        'note': 'WiFi TX + MCU + display refresh',
    },
    'Active\n(Idle)': {
        'current_mA': 24.0,     # ~23.88mA per Espressif docs
        'source': 'Espressif C3 Book',
        'note': 'CPU running, peripherals idle',
    },
    'Light\nSleep': {
        'current_mA': 0.8,      # ~0.8mA per Espressif docs
        'source': 'Espressif light sleep docs',
        'note': 'CPU paused, RAM retained',
    },
    'Deep\nSleep': {
        'current_mA': 0.005,    # ~5µA typical (chip only)
        'source': 'ESP32-C3 Datasheet',
        'note': 'RTC only, ~5µA chip, board may add 10-150µA',
    },
}

# ============================================================
# BATTERY LIFE CALCULATION — Wayo Elephant Tracker Profile
# ============================================================
BATTERY_CAPACITY_mAh = 3000  # 18650 cell
DERATING_FACTOR = 0.80       # Real-world derating (temperature, aging, self-discharge)

# Usage profile: wake every 15 minutes, active ~8 seconds
CYCLE_SECONDS = 15 * 60          # 900 seconds = 15 minutes
ACTIVE_SECONDS = 8               # WiFi connect + sensor read + transmit
SLEEP_SECONDS = CYCLE_SECONDS - ACTIVE_SECONDS  # 892 seconds

I_active = 120.0   # mA average during active (mix of TX peak + idle transitions)
I_sleep = 0.005     # mA (5µA deep sleep, chip only — board may be higher)

I_avg = (I_active * ACTIVE_SECONDS + I_sleep * SLEEP_SECONDS) / CYCLE_SECONDS

battery_hours_ideal = BATTERY_CAPACITY_mAh / I_avg
battery_hours_real = battery_hours_ideal * DERATING_FACTOR
battery_days_real = battery_hours_real / 24


def create_power_profile_chart():
    """Generate power profile bar chart."""
    modes = list(MODES.keys())
    currents = [MODES[m]['current_mA'] for m in modes]
    colors = ['#e74c3c', '#f39c12', '#3498db', '#2ecc71']

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left: Power profile bar chart (log scale) ---
    bars = ax1.bar(modes, currents, color=colors, edgecolor='white', linewidth=1.5)
    ax1.set_ylabel('Current Consumption (mA)', fontsize=12)
    ax1.set_title('Wayo Prototype — Power Profile by Mode', fontsize=14, fontweight='bold')
    ax1.set_yscale('log')
    ax1.set_ylim(0.001, 500)
    ax1.grid(axis='y', alpha=0.3)

    for bar, val in zip(bars, currents):
        if val >= 1:
            label = f'{val:.0f} mA'
        elif val >= 0.1:
            label = f'{val:.1f} mA'
        else:
            label = f'{val*1000:.0f} uA'
        ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() * 1.3,
                label, ha='center', va='bottom', fontweight='bold', fontsize=11)

    # --- Right: Battery life breakdown ---
    # Pie chart: energy spent in each mode per cycle
    energy_active = I_active * ACTIVE_SECONDS   # mA * s
    energy_sleep = I_sleep * SLEEP_SECONDS       # mA * s
    total_energy = energy_active + energy_sleep

    pie_labels = [
        f'Active ({ACTIVE_SECONDS}s)\n{energy_active/total_energy*100:.1f}%',
        f'Deep Sleep ({SLEEP_SECONDS}s)\n{energy_sleep/total_energy*100:.1f}%',
    ]
    pie_sizes = [energy_active, energy_sleep]
    pie_colors = ['#e74c3c', '#2ecc71']

    ax2.pie(pie_sizes, labels=pie_labels, colors=pie_colors, startangle=90,
            textprops={'fontsize': 11}, autopct='', pctdistance=0.5)
    ax2.set_title(f'Energy Distribution per {CYCLE_SECONDS//60}-min Cycle', fontsize=14, fontweight='bold')

    # Add battery life text
    textstr = (
        f'Battery: {BATTERY_CAPACITY_mAh} mAh (18650)\n'
        f'I_avg: {I_avg:.3f} mA\n'
        f'Ideal life: {battery_hours_ideal:.0f} h ({battery_hours_ideal/24:.0f} days)\n'
        f'Derated ({DERATING_FACTOR*100:.0f}%): {battery_hours_real:.0f} h ({battery_days_real:.0f} days)'
    )
    props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
    ax2.text(0, -1.3, textstr, fontsize=10, verticalalignment='top',
            ha='center', bbox=props, family='monospace')

    plt.tight_layout(pad=2.0)
    plt.savefig('power-profile.png', dpi=150, bbox_inches='tight')
    print('Saved power-profile.png')


def print_battery_calculation():
    """Print detailed battery life calculation."""
    print("=" * 60)
    print("  BATTERY LIFE CALCULATION — Wayo Elephant Tracker")
    print("=" * 60)
    print()
    print(f"  Battery: {BATTERY_CAPACITY_mAh} mAh (18650 Li-ion, 3.7V nominal)")
    print(f"  Cycle period: {CYCLE_SECONDS}s ({CYCLE_SECONDS//60} minutes)")
    print(f"  Active time per cycle: {ACTIVE_SECONDS}s")
    print(f"  Deep sleep time per cycle: {SLEEP_SECONDS}s")
    print()
    print(f"  I_active (avg during active): {I_active} mA")
    print(f"  I_sleep (deep sleep): {I_sleep} mA ({I_sleep*1000:.0f} uA)")
    print()
    print(f"  I_avg = ({I_active} * {ACTIVE_SECONDS} + {I_sleep} * {SLEEP_SECONDS}) / {CYCLE_SECONDS}")
    print(f"        = ({I_active * ACTIVE_SECONDS:.1f} + {I_sleep * SLEEP_SECONDS:.3f}) / {CYCLE_SECONDS}")
    print(f"        = {I_avg:.4f} mA")
    print()
    print(f"  Ideal battery life: {BATTERY_CAPACITY_mAh} / {I_avg:.4f} = {battery_hours_ideal:.0f} hours = {battery_hours_ideal/24:.0f} days")
    print(f"  Derated (x{DERATING_FACTOR}): {battery_hours_real:.0f} hours = {battery_days_real:.0f} days")
    print()

    if battery_days_real >= 30:
        print(f"  VERDICT: PASS — {battery_days_real:.0f} days >= 30 day target")
    else:
        print(f"  VERDICT: REVIEW — {battery_days_real:.0f} days. Check if target is met.")
    print()
    print("  NOTE: These are DATASHEET values. Replace with actual measurements!")
    print("  Board-level deep sleep may be 10-150uA (not 5uA) due to LDO Iq + leakage.")


if __name__ == '__main__':
    print_battery_calculation()
    print()
    try:
        create_power_profile_chart()
    except ImportError as e:
        print(f"[WARN] matplotlib not available: {e}")
        print("  Install: pip install matplotlib")
        print("  Chart generation skipped, but calculation is complete.")
