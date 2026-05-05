#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #text(size: 20pt, weight: "bold")[Power Optimization Report]
  #v(0.3em)
  #text(size: 14pt)[Wayo Prototype --- ESP32-C3 Elephant Tracker]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[Date: 2026-04-02 | Status: Pre-measurement (datasheet values)]
]

#line(length: 100%)

= 1. Power Profile Summary

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, left),
  [*Mode*], [*Expected Current*], [*Duration/Cycle*], [*Source*],
  [Active (WiFi TX)], [180--240 mA peak], [5s], [ESP32-C3 Datasheet v2.2],
  [Active (idle)], [~24 mA], [3s], [Espressif C3 Book Ch.12],
  [Light Sleep], [~0.8 mA], [N/A (not used in profile)], [Espressif docs],
  [Deep Sleep (chip)], [~5 uA], [892s], [ESP32-C3 Datasheet v2.2],
  [E-ink refresh], [~15 mA (50mW)], [\<35s full refresh], [Waveshare 5.65" spec],
  [E-ink standby], [\<0.01 uA], [Always (when not refreshing)], [Waveshare 5.65" spec],
)

= 2. Battery Life Estimates

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Scenario*], [*I\_deep\_sleep*], [*I\_avg*], [*Battery Life (derated)*],
  [Best case (chip only)], [5 uA], [1.072 mA], [93 days],
  [Typical board], [100 uA], [1.166 mA], [86 days],
  [Bad board (LED leakage)], [500 uA], [1.561 mA], [64 days],
  [Worst case (peripheral awake)], [2 mA], [3.048 mA], [33 days],
)

#text(size: 9pt, fill: gray)[Battery: 3000mAh 18650 Li-ion. Cycle: 15 min (8s active + 892s deep sleep). Derating: 80%.]

= 3. Optimization Recommendations

== Priority 1: Deep Sleep Current (HIGH IMPACT)

Deep sleep dominates battery life (device sleeps 99.1% of the time).

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Action*], [*Saving*], [*Complexity*], [*Do?*],
  [Configure all unused GPIO as input with pulldown], [10--50 uA], [Low], [YES],
  [Disable internal pullups on unused pins], [1--10 uA/pin], [Low], [YES],
  [Add MOSFET switch to cut power to peripherals in sleep], [50--500 uA], [Medium], [YES],
  [Verify LDO quiescent current matches datasheet], [5--50 uA], [Low], [CHECK],
  [Remove/disconnect power LED (or add MOSFET gate)], [100--500 uA], [Low], [YES],
  [Ensure SPI flash enters deep power-down mode], [~1 uA], [Low], [YES],
)

== Priority 2: Active Mode Current (MEDIUM IMPACT)

Active time is only 8s per 15-min cycle, but high current during this period.

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Action*], [*Saving*], [*Complexity*], [*Do?*],
  [Reduce WiFi TX power: 20 dBm to 10 dBm], [~50 mA peak], [Low (firmware)], [IF range OK],
  [Use BLE instead of WiFi for short data packets], [~100 mA], [Medium], [CONSIDER],
  [Batch sensor reads (read all, then transmit all)], [~2s active time], [Low], [YES],
  [Pre-connect WiFi before sensor read (overlap)], [~1s active time], [Medium], [YES],
)

== Priority 3: Duty Cycle (HIGH IMPACT, product decision)

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Action*], [*Impact*], [*Complexity*], [*Do?*],
  [Extend cycle from 15 min to 30 min], [Nearly 2x battery life], [Low], [IF acceptable],
  [Adaptive wake: more frequent when elephant moving], [30--50% savings in calm], [High], [FUTURE],
  [Skip WiFi TX if no change detected], [Eliminates unnecessary TX], [Medium], [YES],
)

== Priority 4: Energy Harvesting

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Action*], [*Impact*], [*Complexity*], [*Do?*],
  [Add 1W solar panel + MPPT charger], [Indefinite field life in sun], [Medium (HW)], [YES],
  [Solar + supercapacitor for cloudy days], [Bridge 2--3 day gaps], [High], [FUTURE],
)

= 4. Measurement Checklist

Before applying optimizations, establish baseline:

+ Measure board-level deep sleep current (uA range, wait 10s for stabilization)
+ Measure active idle current (no WiFi)
+ Measure WiFi TX peak and average current
+ Calculate actual I\_avg from measurements
+ Re-run battery life calculation with actuals

After each optimization:
+ Re-measure affected mode
+ Update power profile chart
+ Verify no regression in other modes

= 5. Data Sources

All values in this report are from:
- ESP32-C3 Datasheet v2.2 (Espressif)
- ESP32-C3 Wireless Adventure Book, Chapter 12 (Espressif)
- Waveshare 5.65" E-Paper Module (F) Technical Specification
- Battery University (BU-501a: Discharge Characteristics of Li-ion)

*Board-level deep sleep estimates (50--150 uA) are marked \[UNVALIDATED\] --- must be confirmed with actual measurement.*
