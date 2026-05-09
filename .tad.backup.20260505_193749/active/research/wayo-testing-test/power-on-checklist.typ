#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #text(size: 20pt, weight: "bold")[Wayo Prototype — Power-On Checklist]
  #v(0.5em)
  #text(size: 12pt)[ESP32-C3 + 5.65" E-ink + 18650 Battery]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[Board Rev: \_\_\_\_ | Serial: \_\_\_\_ | Date: \_\_\_\_ | Tester: \_\_\_\_]
]

#line(length: 100%)

= PRE-POWER CHECKS

#table(
  columns: (auto, 1fr, auto),
  align: (center, left, center),
  [*\#*], [*Check*], [*Result*],
  [1], [Visual inspection: no solder bridges, no missing components, polarized components correct (battery connector, USB, electrolytic caps)], [☐ OK / ☐ NOK],
  [2], [Continuity: VDD3P3 to GND — must NOT be short. \ Expected: >1kΩ. \ Measured: \_\_\_\_Ω \ *If shorted → DO NOT POWER ON*], [☐ OK / ☐ NOK],
  [3], [Continuity: VBAT to GND — must NOT be short. \ Expected: >1kΩ. \ Measured: \_\_\_\_Ω], [☐ OK / ☐ NOK],
  [4], [ESD precautions: wrist strap connected, ESD mat grounded], [☐ OK / ☐ NOK],
  [5], [Bench supply set: voltage = 3.7V (simulating 18650 nominal), \ *current limit = 100mA* (prevent damage)], [☐ OK / ☐ NOK],
)

= POWER-ON SEQUENCE

#table(
  columns: (auto, 1fr, auto),
  align: (center, left, center),
  [*\#*], [*Step*], [*Result*],
  [6], [Connect bench supply to battery input (NOT battery yet). \ Apply 3.7V. Monitor current draw. \ Expected idle: \<50mA. \ Measured: \_\_\_\_ mA \ *If \>200mA immediately: POWER OFF, check for shorts*], [☐ OK / ☐ NOK],
  [7], [*SMOKE TEST*: Observe for 10 seconds. \ ☐ No heat \ ☐ No smoke \ ☐ No burning smell \ ☐ No component visibly hot \ *Any anomaly → POWER OFF IMMEDIATELY*], [☐ OK / ☐ NOK],
  [8], [After 10s stable: increase current limit to 500mA \ (needed for WiFi TX peak ~240mA)], [☐ OK / ☐ NOK],
)

= VOLTAGE RAIL VERIFICATION

#text(size: 9pt, fill: gray)[Source: ESP32-C3 Datasheet v2.2 — VDD operating range 3.0V–3.6V. Waveshare 5.65" E-ink — 3.3V/5V compatible.]

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  align: (left, center, center, center, center, left),
  [*Rail*], [*Expected*], [*Min (−5%)*], [*Max (+5%)*], [*Measured*], [*PASS/FAIL*],
  [VBAT (bench supply)], [3.700V], [N/A], [N/A], [\_\_\_\_V], [\_\_\_\_],
  [VDD3P3 (main 3.3V)], [3.300V], [3.135V], [3.465V], [\_\_\_\_V], [\_\_\_\_],
  [VDD3P3_CPU], [3.300V], [3.135V], [3.465V], [\_\_\_\_V], [\_\_\_\_],
  [VDD3P3_RTC], [3.300V], [3.135V], [3.465V], [\_\_\_\_V], [\_\_\_\_],
  [VDD_SPI], [3.300V], [3.135V], [3.465V], [\_\_\_\_V], [\_\_\_\_],
  [E-ink VDD], [3.300V], [3.135V], [3.465V], [\_\_\_\_V], [\_\_\_\_],
)

#text(size: 9pt)[*Criteria:* Any rail \>+-10% off nominal = *FAIL* (stop and investigate). Rail \>+-3% but \<+-5% = marginal (add to watch list).]

= POST-POWER CHECKS

#table(
  columns: (auto, 1fr, auto),
  align: (center, left, center),
  [*\#*], [*Check*], [*Result*],
  [9], [LED indicator: power LED on? \ ☐ Power LED lit \ ☐ Status LED behavior: \_\_\_\_], [☐ OK / ☐ NOK],
  [10], [Serial console: connect USB-UART adapter (115200 baud). \ ☐ Boot message received \ ☐ ESP32-C3 reset reason: \_\_\_\_ \ (Run: `python power-on-probe.py`)], [☐ OK / ☐ NOK],
  [11], [Total quiescent current at idle (no WiFi, no display refresh): \ Expected: ~24mA (ESP32-C3 active idle per Espressif docs) \ Measured: \_\_\_\_ mA], [☐ OK / ☐ NOK],
  [12], [Touch test: no component >50°C at idle after 60 seconds. \ Hottest component: \_\_\_\_ (\_\_\_\_ estimated temp)], [☐ OK / ☐ NOK],
)

= VERDICT

#table(
  columns: (1fr, auto),
  [*Overall Power-On Test*], [☐ *PASS* / ☐ *FAIL*],
  [All rails within ±5%?], [☐ Yes / ☐ No],
  [Quiescent current within expected range?], [☐ Yes / ☐ No],
  [No thermal anomalies?], [☐ Yes / ☐ No],
  [MCU serial port responsive?], [☐ Yes / ☐ No],
)

#v(1em)
*Notes / Observations:*
#v(3em)
#line(length: 100%)

*Tester Signature:* \_\_\_\_\_\_\_\_\_\_ #h(3em) *Date:* \_\_\_\_\_\_\_\_\_\_
