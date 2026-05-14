// ============================================================
//  Well-Plate Pipette Guide — Parameterized
//  A guide/jig that sits on top of a standard well plate so
//  a pipette tip can be inserted into each well accurately.
//
//  Usage: set `plate_type` to "24" or "96", or override any
//         parameter below for a custom plate format.
//
//  Units: mm
// ============================================================

$fn = 64;

// ---- Plate type selector ----
// Set to "24" or "96". Presets are applied automatically.
// Override any derived value after this block for custom plates.

plate_type = "96";   // "24" or "96"

// ---- Standard presets (SBS/ANSI format) ----
// Plate envelope is the same for both; well layout differs.

plate_length = 127.76;
plate_width  = 85.48;

rows = (plate_type == "24") ? 4  : 8;
cols = (plate_type == "24") ? 6  : 12;

a1_offset_x = (plate_type == "24") ? 18.83 : 14.38;  // left edge to A1 center
a1_offset_y = (plate_type == "24") ? 15.69 : 11.24;   // top edge to A1 center
well_spacing = (plate_type == "24") ? 18.00 : 9.00;    // center-to-center

// Reference plate height (top of plate surface)
plate_height = (plate_type == "24") ? 14.35 : 14.40;

// ---- Pipette tip parameters ----
// VWR 200 µL Universal tip — adjust for your tips.

pipette_tip_od = 1.20;      // outer diameter at the guide bore
pipette_clearance = 0.15;   // added clearance for snug fit
pipette_hole_d = pipette_tip_od + pipette_clearance;

// ---- Guide plate hole geometry ----
// Each hole has a conical entry divot on top and a straight
// bore below that holds the tip steady.

// Scale divot size with well spacing so it doesn't crowd neighbors
divot_top_d    = (plate_type == "24") ? 7.00 : 5.80;
divot_depth    = (plate_type == "24") ? 4.00 : 3.00;
snug_bore_depth = 4.00;

guide_plate_thickness = divot_depth + snug_bore_depth;

// ---- Frame / stand dimensions ----

plate_clearance = 0.80;     // gap around plate for easy fit
frame_wall      = 5.00;     // wall thickness
corner_radius   = 3.00;

collar_depth             = 6.00;   // shallow skirt that locates the jig
top_clearance_above_plate = 2.50;   // air gap above plate surface

// Side support rails stiffen the jig between collar and guide plate.
// Recommended for 96-well; optional for 24-well.
enable_side_rails = true;
rail_width = 3.00;

// ---- Finger lift tabs ----

tab_length = 18;
tab_width  = 9;
tab_height = 3;

// ---- Alignment offset ----
// Shift the hole grid relative to the plate if needed after test print.

align_offset_x = 0.00;
align_offset_y = 0.00;

// ---- Display options ----

show_reference_plate = false;
show_labels          = true;

// ---- Derived dimensions (do not edit) ----

guide_plate_bottom_z = plate_height + top_clearance_above_plate;
guide_plate_top_z    = guide_plate_bottom_z + guide_plate_thickness;

outer_length = plate_length + 2 * (plate_clearance + frame_wall);
outer_width  = plate_width  + 2 * (plate_clearance + frame_wall);
inner_length = plate_length + 2 * plate_clearance;
inner_width  = plate_width  + 2 * plate_clearance;

// Auto-scale labels to well spacing
label_size   = well_spacing * 0.26;
label_margin = well_spacing * 0.62;

// ============================================================
//  Main assembly
// ============================================================

if (show_reference_plate)
    reference_plate();

difference() {
    union() {
        collar_frame();
        corner_posts();
        if (enable_side_rails) side_rails();
        guide_plate();
        lift_tabs();
    }

    for (r = [0 : rows - 1])
        for (c = [0 : cols - 1])
            translate(guide_xy(r, c))
                pipette_cutout();
}

if (show_labels)
    well_labels();

// ============================================================
//  Modules
// ============================================================

// -- Shallow collar that slips over the plate edges --

module collar_frame() {
    color("lightgray")
    difference() {
        rounded_box(outer_length, outer_width, collar_depth, corner_radius);
        translate([0, 0, -0.5])
            rounded_box(inner_length, inner_width, collar_depth + 1, 2);
    }
}

// -- Corner posts connecting collar to guide plate --

module corner_posts() {
    post_h = guide_plate_bottom_z - collar_depth;

    color("lightgray")
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([
                sx * (inner_length / 2 + frame_wall / 2),
                sy * (inner_width  / 2 + frame_wall / 2),
                collar_depth
            ])
            rounded_box(frame_wall, frame_wall, post_h, 1.5);
}

// -- Side rails for extra stiffness --

module side_rails() {
    rail_h = guide_plate_bottom_z - collar_depth;

    color("lightgray") {
        for (sy = [-1, 1])
            translate([0, sy * (inner_width / 2 + frame_wall / 2), collar_depth])
                rounded_box(outer_length, rail_width, rail_h, 1.5);

        for (sx = [-1, 1])
            translate([sx * (inner_length / 2 + frame_wall / 2), 0, collar_depth])
                rounded_box(rail_width, outer_width, rail_h, 1.5);
    }
}

// -- Top guide plate (holes are subtracted later) --

module guide_plate() {
    color("lightgray")
    translate([0, 0, guide_plate_bottom_z])
        rounded_box(outer_length, outer_width, guide_plate_thickness, corner_radius);
}

// -- Finger lift tabs on both short ends --

module lift_tabs() {
    color("lightgray")
    for (sx = [-1, 1])
        translate([
            sx * (outer_length / 2 + tab_length / 2 - 1),
            0,
            guide_plate_top_z - tab_height
        ])
        rounded_box(tab_length, tab_width, tab_height, 2);
}

// -- Conical divot + snug bore for one well position --

module pipette_cutout() {
    // Straight bore through the full plate
    translate([0, 0, guide_plate_bottom_z - 0.5])
        cylinder(h = guide_plate_thickness + 1, d = pipette_hole_d);

    // Conical entry divot on the top surface
    translate([0, 0, guide_plate_top_z - divot_depth])
        cylinder(h = divot_depth + 0.5, d1 = pipette_hole_d, d2 = divot_top_d);
}

// -- Reference plate for visual checking --

module reference_plate() {
    ref_well_d     = (plate_type == "24") ? 15.00 : 7.00;
    ref_well_depth = (plate_type == "24") ? 13.20 : 10.80;

    color([1, 1, 1, 0.28])
    difference() {
        rounded_box(plate_length, plate_width, plate_height, 2);

        for (r = [0 : rows - 1])
            for (c = [0 : cols - 1])
                translate(concat(well_xy(r, c), [plate_height - ref_well_depth]))
                    cylinder(h = ref_well_depth + 0.5, d = ref_well_d);
    }
}

// -- Row (A-H) and column (1-12) labels embossed on top --

module well_labels() {
    z = guide_plate_top_z + 0.05;

    color("black") {
        for (r = [0 : rows - 1]) {
            pos = guide_xy(r, 0);
            translate([pos[0] - label_margin, pos[1], z])
                linear_extrude(0.35)
                    text(chr(65 + r), size = label_size,
                         halign = "center", valign = "center");
        }

        for (c = [0 : cols - 1]) {
            pos = guide_xy(0, c);
            translate([pos[0], pos[1] + label_margin, z])
                linear_extrude(0.35)
                    text(str(c + 1), size = label_size,
                         halign = "center", valign = "center");
        }
    }
}

// ============================================================
//  Helper functions
// ============================================================

// Well center on the physical plate
function well_xy(r, c) = [
    -plate_length / 2 + a1_offset_x + c * well_spacing,
     plate_width  / 2 - a1_offset_y - r * well_spacing
];

// Guide hole center (well center + alignment offset)
function guide_xy(r, c) = [
    -plate_length / 2 + a1_offset_x + c * well_spacing + align_offset_x,
     plate_width  / 2 - a1_offset_y - r * well_spacing + align_offset_y,
     0
];

// Rounded rectangular prism centered on XY, bottom at Z=0
module rounded_box(l, w, h, r) {
    hull()
        for (x = [-l/2 + r, l/2 - r])
            for (y = [-w/2 + r, w/2 - r])
                translate([x, y, 0])
                    cylinder(h = h, r = r);
}
