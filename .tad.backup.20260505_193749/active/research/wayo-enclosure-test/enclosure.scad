// ============================================================
// Wayo 大象追踪器 Enclosure — Parametric OpenSCAD Model
// Domain Pack: hw-enclosure / enclosure_design
// Date: 2026-04-02
//
// All dimensions in mm. Override via -D flag:
//   openscad -D wall=2.5 -o output.stl enclosure.scad
// ============================================================

// === Global Parameters (override with -D) ===
wall         = 2.0;     // Wall thickness (FDM min 1.5mm, using 2.0 for IP54)
corner_r     = 3.0;     // External corner radius
tol          = 0.2;     // FDM tolerance
$fn          = 32;      // Preview resolution (use 64 for export)

// === E-ink Display Module (Waveshare 5.65" F) ===
// Source: https://www.waveshare.com/wiki/5.65inch_e-Paper_Module_(F)
eink_active_w  = 114.9;   // Active area width
eink_active_h  = 85.8;    // Active area height
eink_module_w  = 138.5;   // Module outline width
eink_module_h  = 100.5;   // Module outline height
eink_module_t  = 1.2;     // Module thickness (bare panel)
eink_fpc_zone  = 8.0;     // FPC connector + bend clearance

// === ESP32-C3-DevKitM-1 ===
// Source: https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitm-1/
pcb_l         = 54.4;    // PCB length
pcb_w         = 18.0;    // PCB width
pcb_t         = 1.6;     // PCB thickness (FR4)
pcb_comp_top  = 3.0;     // Max component height (top side, USB-C)
pcb_comp_bot  = 1.0;     // Max component height (bottom side)
pcb_standoff  = 4.0;     // Standoff height (above battery compartment floor)
pcb_hole_d    = 2.0;     // M2 mounting holes
pcb_hole_pitch = 48.0;   // Distance between mounting holes [UNVALIDATED]

// === 18650 Battery ===
// Source: https://en.wikipedia.org/wiki/18650_battery
batt_d        = 18.6;    // Diameter (with tolerance for protected cell)
batt_l        = 68.0;    // Length (protected cell, worst case)
batt_clearance = 1.0;    // Clearance around battery

// === Enclosure Derived Dimensions ===
// Internal cavity must fit: E-ink module (drives footprint) + battery + PCB (stacked)
inner_w       = eink_module_w + 2 * 2;    // 142.5mm
inner_d       = eink_module_h + 2 * 2;    // 104.5mm

// Height stack (bottom to top):
// Battery zone: batt_d + 2*clearance
batt_zone_h   = batt_d + 2 * batt_clearance;  // 20.6mm
// PCB zone: standoff + PCB + components
pcb_zone_h    = pcb_standoff + pcb_t + pcb_comp_top;  // 8.6mm
// Display zone: module + FPC bend
display_zone_h = eink_module_t + eink_fpc_zone;  // 9.2mm
// Wiring clearance between zones
wire_clear    = 2.0;

inner_h       = batt_zone_h + pcb_zone_h + wire_clear + display_zone_h;

// External dimensions
outer_w       = inner_w + 2 * wall;
outer_d       = inner_d + 2 * wall;
outer_h       = inner_h + 2 * wall;

// Split line: bottom shell gets battery + PCB, top shell gets display
split_h       = wall + batt_zone_h + pcb_zone_h + wire_clear;

// === Screw Boss Parameters ===
screw_od       = 5.0;    // M2 × 2.5 = 5.0mm outer diameter
screw_id       = 1.6;    // M2 pilot hole for self-tapping
screw_boss_h   = split_h - wall;  // Full height of bottom shell interior
num_screws     = 4;       // 4 corner screws

// Screw positions (relative to enclosure center)
screw_inset    = 6.0;    // Distance from inner wall to screw center
screw_positions = [
    [-inner_w/2 + screw_inset, -inner_d/2 + screw_inset],
    [ inner_w/2 - screw_inset, -inner_d/2 + screw_inset],
    [-inner_w/2 + screw_inset,  inner_d/2 - screw_inset],
    [ inner_w/2 - screw_inset,  inner_d/2 - screw_inset]
];

// === Display Window ===
display_win_w  = eink_active_w + 2 * 1.0;   // Active area + 1mm margin each side
display_win_h  = eink_active_h + 2 * 1.0;   // 116.9 × 87.8mm
display_lip    = 0.8;    // Step depth for display panel retention

// === Connector Cutouts ===
usbc_w         = 9.5;    // USB-C opening width (with FDM tolerance)
usbc_h         = 3.5;    // USB-C opening height
usbc_z_offset  = wall + batt_zone_h + pcb_standoff;  // Height from bottom

sma_d          = 8.0;    // SMA antenna hole diameter
sma_z_offset   = wall + batt_zone_h + pcb_standoff + pcb_t;

switch_w       = 12.0;   // Power switch opening
switch_h       = 5.0;
switch_z_offset = wall + batt_zone_h / 2;  // Centered in battery zone

// === Gasket Groove (IP54) ===
gasket_w       = 2.0;    // Groove width
gasket_depth   = 1.5;    // Groove depth

// === Antenna Clearance Zone ===
antenna_clear  = 15.0;   // No plastic within 15mm of SMA center

// ============================================================
// MODULES
// ============================================================

// Rounded box primitive (external shell shape)
module rounded_box(w, d, h, r) {
    translate([0, 0, h/2])
    minkowski() {
        cube([w - 2*r, d - 2*r, h - 2*r], center=true);
        sphere(r=r);
    }
}

// Screw boss (grows from floor)
module screw_boss(h, od, id) {
    difference() {
        cylinder(h=h, d=od, $fn=24);
        translate([0, 0, -0.1])
            cylinder(h=h+0.2, d=id, $fn=24);
    }
    // Reinforcement ribs (4 directions)
    for (a = [0, 90, 180, 270]) {
        rotate([0, 0, a])
        translate([0, -0.4, 0])
            cube([od/2 + 1.5, 0.8, h * 0.6]);
    }
}

// Bottom shell (battery + PCB compartment)
module bottom_shell() {
    difference() {
        // Outer shell
        intersection() {
            rounded_box(outer_w, outer_d, outer_h, corner_r);
            translate([0, 0, outer_h/2])
                cube([outer_w + 1, outer_d + 1, split_h * 2], center=true);
        }

        // Hollow interior
        translate([0, 0, wall])
        intersection() {
            rounded_box(inner_w, inner_d, inner_h, corner_r - wall);
            translate([0, 0, inner_h/2])
                cube([inner_w + 1, inner_d + 1, (split_h - wall) * 2], center=true);
        }

        // USB-C cutout (bottom edge, centered)
        translate([0, -outer_d/2 - 0.1, usbc_z_offset])
            cube([usbc_w, wall + 0.2, usbc_h], center=true);

        // Power switch cutout (left side)
        translate([-outer_w/2 - 0.1, 0, switch_z_offset])
            cube([wall + 0.2, switch_w, switch_h], center=true);

        // SMA antenna hole (top edge)
        translate([0, outer_d/2, sma_z_offset])
            rotate([-90, 0, 0])
                cylinder(h=wall + 0.2, d=sma_d, $fn=32);

        // Gasket groove on mating face
        translate([0, 0, split_h - gasket_depth])
            difference() {
                rounded_box(inner_w + tol, inner_d + tol, gasket_depth * 2 + 0.1, corner_r - wall);
                rounded_box(inner_w + tol - 2*gasket_w, inner_d + tol - 2*gasket_w, gasket_depth * 2 + 0.2, corner_r - wall - gasket_w);
            }
    }

    // Screw bosses
    for (pos = screw_positions) {
        translate([pos[0], pos[1], wall])
            screw_boss(screw_boss_h, screw_od, screw_id);
    }

    // Battery retaining walls (two semicircular cradles)
    translate([0, 0, wall]) {
        // Battery sits horizontally, along X axis
        translate([0, -inner_d/4, 0]) {
            difference() {
                cylinder(h=batt_d/2 + batt_clearance, d=batt_d + 2*batt_clearance + 2, $fn=32);
                translate([0, 0, -0.1])
                    cylinder(h=batt_d + 1, d=batt_d + 2*batt_clearance, $fn=32);
                // Open top for battery insertion
                translate([0, 0, batt_d/4])
                    cube([batt_l + 5, batt_d + 5, batt_d], center=true);
            }
        }
    }

    // PCB standoffs (2 posts for M2 mounting)
    pcb_base_z = wall + batt_zone_h;
    translate([-pcb_hole_pitch/2, 0, pcb_base_z])
        screw_boss(pcb_standoff, screw_od, screw_id);
    translate([ pcb_hole_pitch/2, 0, pcb_base_z])
        screw_boss(pcb_standoff, screw_od, screw_id);
}

// Top shell (display housing)
module top_shell() {
    top_h = outer_h - split_h;

    difference() {
        // Outer shell (top portion)
        translate([0, 0, split_h])
        intersection() {
            translate([0, 0, -split_h])
                rounded_box(outer_w, outer_d, outer_h, corner_r);
            translate([0, 0, top_h/2])
                cube([outer_w + 1, outer_d + 1, top_h * 2], center=true);
        }

        // Hollow interior
        translate([0, 0, split_h])
        intersection() {
            translate([0, 0, -split_h + wall])
                rounded_box(inner_w, inner_d, inner_h, corner_r - wall);
            translate([0, 0, top_h/2])
                cube([inner_w + 1, inner_d + 1, (top_h - wall) * 2], center=true);
        }

        // Display window opening (through top wall)
        translate([0, 0, outer_h - wall - 0.1])
            cube([display_win_w, display_win_h, wall + 0.2], center=true);

        // Display lip recess (for panel retention)
        translate([0, 0, outer_h - wall - display_lip])
            cube([eink_module_w + 0.4, eink_module_h + 0.4, display_lip + 0.1], center=true);

        // Screw holes (through top shell, aligned with bottom bosses)
        for (pos = screw_positions) {
            translate([pos[0], pos[1], split_h - 0.1])
                cylinder(h=top_h + 0.2, d=pcb_hole_d + tol, $fn=24);
        }

        // Lid mating lip (fits inside bottom shell)
        // Slightly smaller than inner cavity for snug fit
        translate([0, 0, split_h])
            difference() {
                rounded_box(inner_w + tol, inner_d + tol, 3, corner_r - wall);
                rounded_box(inner_w + tol - 2*wall, inner_d + tol - 2*wall, 3.1, corner_r - 2*wall);
            }
    }
}

// PCB placeholder (transparent, for fit verification)
module pcb_placeholder() {
    pcb_base_z = wall + batt_zone_h + pcb_standoff;
    // ESP32-C3 DevKit
    #color("green", 0.3)
    translate([-pcb_l/2, -pcb_w/2, pcb_base_z])
        cube([pcb_l, pcb_w, pcb_t]);

    // E-ink module
    eink_z = outer_h - wall - display_lip - eink_module_t;
    #color("blue", 0.3)
    translate([-eink_module_w/2, -eink_module_h/2, eink_z])
        cube([eink_module_w, eink_module_h, eink_module_t]);

    // 18650 Battery
    #color("red", 0.3)
    translate([-batt_l/2, -inner_d/4, wall + batt_d/2 + batt_clearance])
        rotate([0, 90, 0])
            cylinder(h=batt_l, d=batt_d, $fn=32);
}

// ============================================================
// ASSEMBLY
// ============================================================

// Render both shells + placeholders
// Comment/uncomment as needed for export

// Full assembly view
bottom_shell();
top_shell();
pcb_placeholder();

// For individual STL export, uncomment one:
// bottom_shell();
// top_shell();
