#set page(paper: "a4", flipped: true, margin: 1.5cm)
#set text(font: "Helvetica", size: 10pt)

// ============================================================
// Assembly Guide — Wayo Elephant Tracker Enclosure
// Domain Pack: hw-enclosure / enclosure_documentation
// ============================================================

#align(center)[
  #text(size: 24pt, weight: "bold")[Assembly Guide]
  #v(0.3em)
  #text(size: 16pt)[Wayo Elephant Tracker Enclosure]
  #v(0.3em)
  #text(size: 11pt, fill: gray)[Version 1.0 | 2026-04-02 | hw-enclosure Domain Pack]
  #v(0.5em)
  #line(length: 60%, stroke: 0.5pt)
]

#v(2em)

= BOM (Bill of Materials)

#table(
  columns: (0.5fr, 2fr, 1fr, 1fr, 1.5fr),
  stroke: 0.5pt,
  align: (center, left, left, center, left),
  [*\#*], [*Part*], [*Specification*], [*Qty*], [*Source*],
  [1], [Bottom Shell], [ASA, FDM printed], [1], [Self-print],
  [2], [Top Shell (Display Frame)], [ASA, FDM printed], [1], [Self-print],
  [3], [ESP32-C3-DevKitM-1], [54.4 x 18.0mm], [1], [Espressif / distributor],
  [4], [Waveshare 5.65" E-ink Module (F)], [138.5 x 100.5mm], [1], [Waveshare],
  [5], [18650 Li-ion Battery (protected)], [3.7V, 2600--3500mAh], [1], [Battery supplier],
  [6], [M2 x 8mm Self-Tapping Screws], [Stainless steel, pan head], [4], [Hardware store],
  [7], [Closed-Cell Foam Gasket Strip], [1.5mm thick, 2.0mm wide], [1], [Cut to perimeter ~490mm],
  [8], [SMA Antenna Connector + Cable], [U.FL to SMA pigtail], [1], [Electronics supplier],
  [9], [Slide Power Switch], [SPDT, 12 x 5mm body], [1], [Electronics supplier],
  [10], [FPC Cable], [24-pin, 0.5mm pitch], [1], [Waveshare (included)],
)

#v(1em)

= Tools Required

#table(
  columns: (2fr, 2fr),
  stroke: 0.5pt,
  [*Tool*], [*Notes*],
  [Phillips screwdriver (PH0)], [For M2 screws],
  [Tweezers (flat tip)], [For FPC cable handling],
  [Small pliers / fingers], [For battery insertion],
  [Scissors], [For gasket strip cutting],
)

#v(1em)

= Assembly Steps

#v(0.5em)

== Step 1: Install Gasket Strip in Bottom Shell

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[1]
  #h(0.5em)
  Press closed-cell foam gasket strip into the gasket groove on the mating face of the *bottom shell*.

  - Cut gasket strip to perimeter length (~490mm)
  - Start at one corner, press into groove (2.0mm wide x 1.5mm deep)
  - Ensure gasket sits flush with shell rim
  - Overlap ends by ~3mm and trim clean

  #text(fill: rgb("#E65100"), weight: "bold")[Warning:] Gasket must be continuous with no gaps -- gaps compromise IP54 rating.
]

#v(0.5em)

== Step 2: Install Power Switch

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[2]
  #h(0.5em)
  Insert slide switch into the left-side cutout (12 x 5mm opening).

  - Direction: push from outside inward
  - Solder wires *before* insertion (2 wires, 80mm length)
  - Route wires along bottom shell wall
]

#v(0.5em)

== Step 3: Insert 18650 Battery

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[3]
  #h(0.5em)
  Place 18650 battery horizontally into the cradle in the bottom shell.

  - Direction: lay battery into semicircular cradle from above
  - Positive terminal toward SMA antenna side (top edge)
  - Connect battery wires to power management circuit
  - Route wires away from screw bosses

  #text(fill: rgb("#E65100"), weight: "bold")[Warning:] Verify polarity before connecting. Reversed polarity will damage ESP32.
]

#v(0.5em)

== Step 4: Mount ESP32-C3 PCB

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[4]
  #h(0.5em)
  Place ESP32-C3-DevKitM-1 onto the two M2 standoff posts above the battery compartment.

  - Direction: from above, USB-C port facing bottom edge (toward USB-C cutout)
  - Align M2 mounting holes with standoff posts
  - Secure with 2x M2 screws (hand-tight, ~0.15 Nm)
  - Verify USB-C port aligns with bottom edge cutout (tolerance: +/-0.5mm)

  #text(fill: rgb("#1565C0"))[Tip:] Connect all wires (battery, switch, antenna, E-ink FPC) to PCB *before* screwing down.
]

#v(0.5em)

== Step 5: Connect SMA Antenna

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[5]
  #h(0.5em)
  Thread SMA antenna connector through the top-edge hole (8mm diameter).

  - From outside: insert SMA bulkhead connector through hole
  - From inside: tighten SMA nut with fingers (hand-tight, do not overtighten)
  - Connect U.FL pigtail end to ESP32-C3 antenna pad
  - Route cable away from battery and display FPC

  #text(fill: rgb("#E65100"), weight: "bold")[Warning:] Keep 15mm clearance around antenna -- no metal or dense plastic near antenna.
]

#v(0.5em)

== Step 6: Connect E-ink Display FPC

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[6]
  #h(0.5em)
  Connect the 24-pin FPC cable from E-ink module to ESP32-C3 HAT/adapter.

  - Insert FPC cable into connector (blue side up / contacts down -- check module manual)
  - Close FPC latch gently with tweezers
  - Leave enough FPC length for the display to reach the top shell (allow 90-degree bend)
  - Minimum bend radius: 5mm for 0.5mm pitch FPC

  #text(fill: rgb("#1565C0"))[Tip:] Do a quick display test at this point before closing the enclosure.
]

#v(0.5em)

== Step 7: Seat E-ink Display in Top Shell

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[7]
  #h(0.5em)
  Place the E-ink module into the display lip recess on the inside of the *top shell*.

  - Direction: place module face-down into the 0.8mm recess
  - Active area must align with the display window opening (116.9 x 87.8mm)
  - Module edges rest on the lip -- do not force
  - FPC cable exits from one edge, routed toward interior
]

#v(0.5em)

== Step 8: Close Enclosure

#rect(stroke: 1pt + rgb("#1565C0"), inset: 8pt, radius: 4pt)[
  #text(size: 14pt, fill: rgb("#1565C0"), weight: "bold")[8]
  #h(0.5em)
  Mate top shell to bottom shell and secure with 4x M2 screws.

  - Align top shell mating lip with bottom shell rim
  - Gently lower top shell -- ensure no wires are pinched
  - Check FPC cable bend is within the wire clearance zone (2mm gap)
  - Insert 4x M2 x 8mm screws through top shell into screw bosses
  - Tighten in cross pattern: top-left, bottom-right, top-right, bottom-left
  - Torque: 0.15--0.20 Nm (finger-tight + 1/4 turn)

  #text(fill: rgb("#E65100"), weight: "bold")[Warning:] Do NOT overtighten -- ASA screw bosses can crack above 0.3 Nm.
]

#v(1.5em)

= Troubleshooting

#table(
  columns: (1.5fr, 2fr),
  stroke: 0.5pt,
  [*Problem*], [*Solution*],
  [Top shell won't seat flush], [Check FPC cable routing -- may be bulging. Re-route with gentler bend.],
  [USB-C cable doesn't fit cutout], [FDM tolerance may be tight. File cutout edges with fine sandpaper.],
  [Display shows artifacts], [Reseat FPC cable. Check latch is fully closed.],
  [Water ingress despite gasket], [Check gasket continuity at overlap joint. Apply silicone sealant at overlap.],
  [Screw boss cracked], [Print replacement shell. Reduce torque to 0.10 Nm. Consider brass inserts for repeated assembly.],
)

#v(1em)

= Print Parameters Quick Reference

#table(
  columns: (1.5fr, 1.5fr),
  stroke: 0.5pt,
  [*Parameter*], [*Value*],
  [Material], [ASA (e.g., Polymaker PolyLite)],
  [Nozzle temp], [240--260 degrees C],
  [Bed temp], [90--110 degrees C],
  [Layer height], [0.2mm],
  [Perimeters], [3--4],
  [Infill], [20% gyroid],
  [Support], [Not needed (design optimized)],
  [Orientation], [Bottom shell: face down. Top shell: face down.],
  [Estimated time], [4--6 hours per shell],
  [Estimated weight], [60--80g total (both shells)],
)
