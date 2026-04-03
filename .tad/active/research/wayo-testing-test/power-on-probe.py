#!/usr/bin/env python3
"""
power_on_probe.py — Verify ESP32-C3 MCU is alive via serial port.
Part of Wayo prototype power-on test procedure.

Usage:
    python power_on_probe.py [PORT] [BAUD]
    python power_on_probe.py /dev/tty.usbserial-0001 115200

Expected output on successful boot:
    ESP32-C3 boot log with "rst:0x1 (POWERON)" or similar reset reason.
"""

import serial
import sys
import time
import csv
from datetime import datetime

# --- Configuration ---
PORT = sys.argv[1] if len(sys.argv) > 1 else '/dev/tty.usbserial-0001'
BAUD = int(sys.argv[2]) if len(sys.argv) > 2 else 115200
TIMEOUT = 5  # seconds to wait for boot message
LOG_FILE = 'power-on-serial-log.txt'


def probe_serial(port: str, baud: int, timeout: int) -> bool:
    """Attempt to read boot message from ESP32-C3 via UART."""
    print(f"[PROBE] Opening {port} at {baud} baud...")
    try:
        ser = serial.Serial(port, baud, timeout=timeout)
        time.sleep(2)  # Wait for ESP32-C3 boot (typical boot time ~200ms for direct boot)

        data = ser.read(4096)
        ser.close()

        if data:
            decoded = data.decode(errors='replace')
            print(f"[PASS] MCU responding. Received {len(data)} bytes:")
            print("-" * 60)
            print(decoded[:500])
            print("-" * 60)

            # Log to file
            with open(LOG_FILE, 'w') as f:
                f.write(f"Timestamp: {datetime.now().isoformat()}\n")
                f.write(f"Port: {port}, Baud: {baud}\n")
                f.write(f"Bytes received: {len(data)}\n\n")
                f.write(decoded)
            print(f"[LOG] Serial output saved to {LOG_FILE}")

            # Check for known ESP32-C3 boot indicators
            if 'ESP-IDF' in decoded or 'esp32c3' in decoded.lower() or 'rst:' in decoded:
                print("[INFO] ESP32-C3 boot signature detected.")
            return True
        else:
            print(f"[WARN] No data received after {timeout}s.")
            print("  Possible causes:")
            print("  - Wrong UART TX/RX pin connection")
            print("  - Wrong baud rate (try 74880 for boot ROM output)")
            print("  - MCU not booting (check power rails first)")
            print("  - Boot mode stuck in download mode (check BOOT/GPIO9 pin)")
            return False

    except serial.SerialException as e:
        print(f"[FAIL] Serial error: {e}")
        print("  Check: Is the USB-UART adapter connected? Is the port correct?")
        print(f"  List ports: python -m serial.tools.list_ports")
        return False


def record_voltage_measurement():
    """Template for recording voltage rail measurements as CSV."""
    csv_file = 'voltage-measurements.csv'
    print(f"\n[TEMPLATE] Voltage measurement CSV template: {csv_file}")

    headers = ['Rail', 'Expected_V', 'Tolerance_V', 'Measured_V', 'PASS_FAIL', 'Timestamp', 'Notes']
    rails = [
        ['VBAT', '3.7', 'N/A (3.0-4.2)', '', '', '', '18650 nominal'],
        ['VDD3P3', '3.300', '0.165', '', '', '', 'Main 3.3V rail'],
        ['VDD3P3_CPU', '3.300', '0.165', '', '', '', 'ESP32-C3 digital core'],
        ['VDD3P3_RTC', '3.300', '0.165', '', '', '', 'RTC domain'],
        ['VDD_SPI', '3.300', '0.165', '', '', '', 'Flash power'],
        ['E-ink_VDD', '3.300', '0.165', '', '', '', 'Display logic'],
    ]

    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rails)

    print(f"  Fill in 'Measured_V' and 'PASS_FAIL' columns with actual multimeter readings.")
    print(f"  PASS criteria: Measured within Expected ± Tolerance")


if __name__ == '__main__':
    print("=" * 60)
    print("  Wayo Prototype — Power-On Serial Probe")
    print("=" * 60)

    # Step 1: Generate voltage measurement template
    record_voltage_measurement()

    # Step 2: Probe serial port
    print()
    success = probe_serial(PORT, BAUD, TIMEOUT)

    # Summary
    print()
    if success:
        print("[RESULT] Power-on serial probe: PASS")
        print("  MCU is alive and communicating via UART.")
    else:
        print("[RESULT] Power-on serial probe: FAIL")
        print("  Verify power rails, then re-check serial connection.")

    sys.exit(0 if success else 1)
