#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #text(size: 22pt, weight: "bold")[Environmental Test Plan]
  #v(0.3em)
  #text(size: 16pt)[Wayo Elephant Tracker Prototype]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[
    Product: ESP32-C3 + 5.65" E-ink + 18650 Battery \
    Plan Version: 1.0 | Date: 2026-04-02 | Target: Outdoor (Tropical/Savanna)
  ]
]

#line(length: 100%)

= 1. Test Overview

The Wayo prototype is an outdoor elephant tracking device deployed in tropical/savanna environments. Environmental testing ensures reliable operation under temperature extremes, humidity, mechanical shock, and ingress conditions expected in the field.

*Standards applied*: IEC 60068 series (temperature, humidity, mechanical), IEC 60529 (ingress protection).

*Decision*: MIL-STD-810H NOT applied --- overkill for wildlife tracker. IEC 60068 provides sufficient coverage at lower cost.

= 2. Test Matrix

#table(
  columns: (auto, 1fr, auto, auto, auto, auto),
  align: (center, left, left, center, center, center),
  [*\#*], [*Test*], [*Standard*], [*Condition*], [*Duration*], [*Samples*],
  [T1], [High temp operation], [IEC 60068-2-2 Bd], [+60C], [16h], [3],
  [T2], [Low temp operation], [IEC 60068-2-1 Ad], [-10C], [16h], [3],
  [T3], [Temperature cycling], [IEC 60068-2-14 Na], [-10C to +60C], [10 cycles], [3],
  [T4], [Damp heat], [IEC 60068-2-78 Cab], [40C / 93% RH], [96h], [3],
  [T5], [Drop test], [IEC 60068-2-31 Ec], [1.5m, 6 faces], [~1h], [3],
  [T6], [Vibration], [IEC 60068-2-6 Fc], [10--500Hz, 2g], [6h], [3],
  [T7], [Dust (IP6X)], [IEC 60529], [Dust chamber], [8h], [2],
  [T8], [Immersion (IPX7)], [IEC 60529], [1m depth], [30min], [2],
  [T9], [Water jet (IPX5)], [IEC 60529], [12.5 L/min], [~15min], [2],
)

*Total samples needed*: 10 prototype units minimum.

= 3. Test Sequence

Non-destructive tests run first to maximize data per sample.

*Week 1*: T1 (high temp) then T2 (low temp) then T3 (temp cycling) --- same 3 units \
*Week 2*: T4 (damp heat, 96h) --- same or fresh 3 units \
*Week 3*: T6 (vibration) then T7+T8+T9 (IP tests) --- 2 dedicated IP units \
*Week 4*: T5 (drop test) --- 3 dedicated units, most destructive = last

= 4. Key Concerns for Wayo

== 4.1 Battery (18650 Li-ion)
- At -10C: capacity drops to ~60% of nominal (Battery University BU-501a)
- At +60C: accelerated aging but capacity near-nominal
- Under drop shock: battery retention mechanism must prevent ejection (safety critical)

== 4.2 E-ink Display (5.65" Waveshare ACeP)
- Low temperature: refresh time increases 2--3x below 0C \[UNVALIDATED\]
- Drop shock: glass substrate is fragile --- foam/gasket mounting required
- High temperature: contrast may degrade above 50C

== 4.3 Enclosure
- IP67 target requires sealed cable entries, button openings, and charge port
- Thermal cycling can degrade gasket/O-ring seals over time
- UV exposure degrades ABS/polycarbonate --- consider UV-stabilized material

= 5. Pass/Fail Criteria Summary

#table(
  columns: (auto, 1fr, 1fr),
  align: (center, left, left),
  [*Test*], [*PASS*], [*FAIL*],
  [T1/T2], [Device functional during and after exposure], [Boot failure, permanent function loss],
  [T3], [No solder cracks, all functions work post-cycle], [Solder joint failure, display delamination],
  [T4], [No moisture inside enclosure], [Condensation on PCB, corrosion],
  [T5], [Enclosure intact, display intact, battery retained], [Display cracked, battery ejected],
  [T7--T9], [No dust/water ingress], [Any ingress to electronics],
)

= 6. Equipment and Lab Requirements

#table(
  columns: (1fr, 1fr, auto),
  [*Equipment*], [*Specification*], [*For Tests*],
  [Temperature chamber], [-40C to +85C, ramp 1--5C/min], [T1, T2, T3],
  [Humidity chamber], [10--98% RH, +10C to +85C], [T4],
  [Drop test fixture], [Adjustable height, orientation control], [T5],
  [Vibration shaker], [10--500Hz, up to 5g, 3-axis], [T6],
  [Dust chamber (IEC 60529)], [Talc powder, sealed], [T7],
  [IP water test setup], [Immersion tank 1m+, jet nozzle 6.3mm], [T8, T9],
)

*Estimated lab cost*: \$3,000--\$10,000 USD \[UNVALIDATED --- varies by region\] \
*Estimated lead time*: 2--4 weeks including lab queue

= 7. Data Sources

- IEC 60068-2-1/2/14/78/31/6: Environmental testing standards (referenced by clause)
- IEC 60529: Ingress Protection test procedures
- ESP32-C3 Datasheet v2.2 (Espressif): Operating temperature range
- Waveshare 5.65" E-Paper (F) Technical Specification: Display operating conditions
- Battery University BU-501a: Li-ion discharge characteristics vs temperature

= 8. Revision History

#table(
  columns: (auto, auto, 1fr),
  [*Version*], [*Date*], [*Change*],
  [1.0], [2026-04-02], [Initial environmental test plan from hw-testing domain pack],
)
