#set page(paper: "a4", margin: 2cm)
#set text(font: "Helvetica", size: 10pt)

#align(center)[
  #text(size: 20pt, weight: "bold")[Material Selection Report]
  #v(0.5em)
  #text(size: 14pt)[Wayo 大象追踪器外壳]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[Date: 2026-04-02 · Domain Pack: hw-enclosure / material_selection]
]

#v(1em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

= Product Constraints

#table(
  columns: (1fr, 2fr),
  stroke: 0.5pt,
  [*Parameter*], [*Value*],
  [Environment], [Outdoor, -10°C to 55°C, IP54 (rain splash)],
  [UV Exposure], [High — daily direct sunlight],
  [Manufacturing], [Prototype: FDM · Small batch: SLA],
  [Hardware], [ESP32-C3 + 5.65" E-ink + 18650 battery],
  [Drop Survival], [~1m onto soil/rock],
)

#v(1em)

= Candidate Material Properties (FDM)

#table(
  columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  stroke: 0.5pt,
  align: center,
  [*Property*], [*PLA*], [*PETG*], [*ABS*], [*ASA*], [*Nylon*],
  [Tensile (MPa)], [60], [50], [40], [44], [70],
  [HDT 0.45MPa (°C)], [55], [63–80], [98], [85–96], [180],
  [UV Resistance], [Poor], [Moderate], [Poor], [#text(fill: rgb("#2e7d32"))[Excellent]], [Poor],
  [Moisture Abs (%)], [0.5], [0.2], [0.3], [0.2], [2.5],
  [Print Difficulty], [Easy], [Easy], [Medium], [Medium], [Hard],
)

#v(0.5em)
#text(size: 8pt, fill: gray)[Sources: UnionFab comparison, Ultimaker PETG TDS, Wevolver ASA article, Filalab outdoor test]

#v(1em)

= Weighted Decision Matrix

Weight justification: UV (0.25) highest — outdoor exposure is primary risk. Heat (0.20) — tropical climate. Moisture (0.15) — IP54 rain exposure.

#table(
  columns: (1.5fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr),
  stroke: 0.5pt,
  align: center,
  [*Criterion*], [*Weight*], [*PLA*], [*PETG*], [*ABS*], [*ASA*], [*Nylon*],
  [UV Resistance], [0.25], [1], [3], [1], [#text(weight: "bold")[5]], [1],
  [Heat Resistance], [0.20], [1], [3], [5], [#text(weight: "bold")[4]], [5],
  [Strength], [0.15], [4], [3], [2], [3], [5],
  [Printability], [0.15], [5], [5], [3], [3], [1],
  [Moisture Resist], [0.15], [3], [5], [4], [#text(weight: "bold")[5]], [1],
  [Cost], [0.10], [5], [4], [4], [3], [2],
  [#text(weight: "bold")[Total]], [], [#text(fill: red)[2.80]], [3.70], [2.95], [#text(fill: rgb("#2e7d32"), weight: "bold")[3.95]], [2.45],
)

#v(1em)

= Recommendation

#rect(stroke: 2pt + rgb("#2e7d32"), inset: 10pt)[
  #text(weight: "bold", size: 12pt)[Primary: ASA (Polymaker PolyLite ASA)]
  #v(0.3em)
  Best UV resistance + adequate HDT (85–96°C) + low moisture absorption.
  Requires enclosed printer. Print at 240–260°C, bed 90–110°C.

  #v(0.5em)
  #text(weight: "bold")[Fallback: PETG + UV clear coat] — if no enclosed printer available.
]

#v(1em)

= Manufacturing Phase Plan

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr, 0.8fr, 1fr),
  stroke: 0.5pt,
  [*Phase*], [*Method*], [*Material*], [*Unit Cost*], [*MOQ*], [*Lead Time*],
  [Prototype (1--10)], [FDM self-print], [ASA], [\$3--8], [1], [1--2 days],
  [Small batch (10--50)], [SLA external], [ABS-like resin], [\$10--25], [1], [3--5 days],
  [Medium (50--200)], [SLS], [Nylon PA12], [\$15--35], [1], [5--7 days],
  [Mass (500+)], [Injection mold], [ABS/PC-ABS], [\$1--3 + mold], [500], [3--6 weeks],
)

#v(0.5em)
#text(size: 8pt, fill: gray)[Cost sources: JLC3DP, PCBWay, Jaycon 2025 guide. SLA/SLS per-unit are ESTIMATED based on enclosure volume.]

#v(1em)

= Honest Caveats

- Injection molding NOT recommended below 500 units (mold \$2K--\$8K amortization kills unit economics)
- SLA resin outdoor durability beyond 6 months is *\[UNVALIDATED\]* --- UV coating required
- Nylon disqualified due to 2.5% moisture absorption --- fatal for outdoor IP54 device
- ASA + FDM is the practical sweet spot for wildlife research (\<100 units)
