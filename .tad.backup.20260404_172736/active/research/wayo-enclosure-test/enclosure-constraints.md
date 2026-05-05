# Enclosure Constraints: Wayo 大象追踪器

> Domain Pack: hw-enclosure / enclosure_design (Code B)
> Date: 2026-04-02

---

## Step 1: gather_constraints — Hardware Parameters

### PCB: ESP32-C3-DevKitM-1
- Board dimensions: 54.4 × 18.0 mm (L × W) [Source: [Espressif official docs](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitm-1/index.html) — dimensions from DXF reference drawing]
- PCB thickness: 1.6mm (standard FR4)
- Max component height (top): ~3mm (USB-C connector)
- Max component height (bottom): ~1mm (solder joints)
- Mounting holes: 2× M2, pitch ~48mm along length [UNVALIDATED — DXF not downloaded, estimated from board photos]
- USB-C connector: at one short edge, centered

### Display: Waveshare 5.65" E-Paper Module (F)
- Active area: 114.9 × 85.8 mm [Source: [Waveshare product page](https://www.waveshare.com/5.65inch-e-paper-module-f.htm)]
- Module outline: 138.5 × 100.5 mm [Source: [Waveshare wiki](https://www.waveshare.com/wiki/5.65inch_e-Paper_Module_(F))]
- Module thickness: ~1.2mm (bare panel) + ~2mm (FPC connector area)
- FPC connector: 0.5mm pitch, rear-flip 2.0H [Source: [Waveshare spec PDF](https://www.waveshare.com/w/upload/7/7a/5.65inch_e-Paper_%28F%29_Sepecification.pdf)]
- Resolution: 600 × 448 pixels, ACeP 7-Color

### Battery: 18650 Li-ion
- Dimensions: 18.0 ± 0.4mm diameter × 65.0 ± 0.25mm length [Source: [Wikipedia 18650](https://en.wikipedia.org/wiki/18650_battery)]
- With protection circuit: up to 67-68mm length
- Orientation: horizontal (side-lay), below PCB
- Weight: ~45-48g typical

### Connectors & Interfaces
| Component | Type | Position | Opening Size (with FDM tolerance) |
|-----------|------|----------|-----------------------------------|
| USB-C | Charging + debug | Bottom edge, centered | 9.5 × 3.5mm |
| SMA antenna | External antenna | Top edge or side | 8mm diameter hole |
| Power switch | Slide switch | Side edge | 12 × 5mm |
| Reset button | Tactile | Side or recessed | 4mm diameter |
| E-ink display | Window | Front face | 116.9 × 87.8mm (active + 1mm/side) |

### Environment
- Operating temperature: -10°C to 55°C
- IP rating: IP54 (splash-proof, dust-protected)
- Primary material: ASA (FDM prototype) — per material_selection result
- UV exposure: High (outdoor)

---

## Step 2: select_enclosure_type

### Selected Type: Clamshell (上下壳体) with gasket seal

**Rationale:**
- E-ink display dominates the front face → top shell acts as display frame
- Battery needs to be replaceable → clamshell allows bottom access
- IP54 requires splash protection but not submersion → gasket groove sufficient (no O-ring needed)
- FDM manufacturing → clamshell is the most reliable print geometry (flat bottom on build plate)

### Key Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| wall_thickness | 2.0mm | FDM minimum 1.5mm + IP54 structural margin |
| corner_radius | 3.0mm | Outdoor handheld device — reduce stress + comfortable edges |
| tolerance | 0.2mm | FDM standard tolerance |
| draft_angle | 0° | 3D printing, no draft needed |
| screw_boss_od | 5.0mm | M2 screw × 2.5 = 5.0mm |
| screw_pilot_hole | 1.6mm | M2 self-tapping in ASA |
| gasket_groove_width | 2.0mm | For 1.5mm foam gasket, slight compression |
| gasket_groove_depth | 1.5mm | Gasket sits flush when compressed |
| display_window_lip | 0.8mm | Step to hold E-ink panel |
| antenna_clearance | 15mm | Minimum clearance around SMA — no plastic walls touching antenna |

---

## Step 5: verify_dimensions — Dimension Check

### Internal Cavity Requirements

The enclosure must fit (stacked vertically from bottom):
1. Battery compartment: 18mm dia × 68mm (with protection PCB) + 2mm clearance = 20mm height zone
2. ESP32-C3 PCB: 54.4 × 18.0 × 1.6mm + standoffs (4mm) + top clearance (3mm for components) = ~8.6mm zone
3. E-ink module: 138.5 × 100.5 × ~3mm + FPC bend space (~5mm)
4. Wiring channels: ~3mm between layers

**Minimum internal height**: 20mm (battery) + 8.6mm (PCB zone) + 3mm (display) + 5mm (FPC + wiring) = ~36.6mm
**With wall thickness**: 36.6 + 2×2.0mm = ~40.6mm total height

**Internal footprint**: E-ink module drives size at 138.5 × 100.5mm + 2mm clearance each side = 142.5 × 104.5mm internal
**External footprint**: 142.5 + 2×2.0mm walls = 146.5 × 108.5mm

### Summary Dimensions

| Dimension | Internal | External |
|-----------|----------|----------|
| Width | 142.5mm | 146.5mm |
| Depth | 104.5mm | 108.5mm |
| Height | ~37mm | ~41mm |

### Printability Assessment

- FDM build volume needed: ~150 × 110 × 45mm — fits standard 220×220 bed easily
- Largest overhang: display window lip (0.8mm step) — printable without support
- Print orientation: bottom shell face-down, top shell face-down (display window up = overhang issue)
- Estimated print time: ~4-6 hours per shell at 0.2mm layer height
- Estimated material: ~60-80g ASA total (both shells)

---

## Step 6: optimize_printability

### FDM Optimization Notes

- All overhangs ≤45° by design (rounded walls, no horizontal bridges)
- Screw bosses grow from bottom shell floor — no floating support needed
- Battery compartment walls printed vertically — maximum layer-to-layer strength
- Display window opening: printed with lip facing build plate (no support needed)
- First layer contact area: ~146.5 × 108.5mm bottom face = 100% bed adhesion
- Bridge distance: none >10mm (gasket groove is 2mm wide, easily bridged)
- Suggested: 3-4 perimeters for wall strength, 20% infill for weight reduction
