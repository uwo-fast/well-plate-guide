// Units: mm

$fn = 72;

// Standard 96-well plate dimensions

plate_length = 127.76;
plate_width  = 85.48;

// 96-well layout
rows = 8;
cols = 12;

// Standard 96-well A1 offsets and pitch
a1_offset_row = 11.24;   // from top edge to A1 center
a1_offset_col = 14.38;   // from left edge to A1 center
well_spacing  = 9.00;    // center-to-center spacing

// Reference plate dimensions for visualization
real_plate_height = 14.40;
reference_well_d = 7.00;
reference_well_depth = 10.80;

// Display options

show_reference_plate = false;   // set true if you want to see reference plate
show_labels = true;

// Easy on/off stand dimensions
// Loose fit around actual plate.
plate_clearance = 0.90;

frame_wall = 5.00;
corner_radius = 3.00;

// Shallow skirt locates the jig but does not grip the plate too hard
collar_depth = 6.00;

// Gap between top of actual plate and underside of guide plate
top_clearance_above_plate = 2.50;

// VWR 200 uL Universal pipette tip 

// VWR tip length 
pipette_tip_total_length = 50.75;   // mm

// Measure actual tip OD where it enters the snug bore.
// Start with 1.20 mm and tune after a test print.
pipette_tip_od_at_guide = 1.20;

// Snug clearance:
pipette_clearance = 0.15;

pipette_hole_d = pipette_tip_od_at_guide + pipette_clearance;

// 96-well plate has tighter spacing, so keep the divot smaller
divot_top_d = 5.80;
divot_depth = 3.00;

// Straight section that holds the pipette tip steady
snug_bore_depth = 4.00;

// Total guide plate thickness
guide_plate_thickness = divot_depth + snug_bore_depth;

// Derived stand dimensions

guide_plate_bottom_z = real_plate_height + top_clearance_above_plate;
guide_plate_top_z = guide_plate_bottom_z + guide_plate_thickness;

outer_length = plate_length + 2 * plate_clearance + 2 * frame_wall;
outer_width  = plate_width  + 2 * plate_clearance + 2 * frame_wall;

inner_length = plate_length + 2 * plate_clearance;
inner_width  = plate_width  + 2 * plate_clearance;

// Electrode alignment offset
// Adjust after testing if the electrode/target array is shifted.
electrode_offset_x = 0.00;
electrode_offset_y = 0.00;

// Main model

if (show_reference_plate) {
    reference_plate();
}

difference() {
    union() {
        shallow_collar_frame();
        corner_support_posts();
        side_support_rails();
        top_guide_plate();
        lift_tabs();
    }

    // Cut 96 recessed divots and pipette guide holes
    for (r = [0:rows-1]) {
        for (c = [0:cols-1]) {
            translate(guide_center(r, c))
                recessed_pipette_cutout();
        }
    }
}

if (show_labels) {
    row_col_labels();
}

// Shallow frame that slips around the real plate

module shallow_collar_frame() {
    color("lightgray")
    difference() {
        rounded_box(outer_length, outer_width, collar_depth, corner_radius);

        translate([0, 0, -0.5])
            rounded_box(inner_length, inner_width, collar_depth + 1.0, 2);
    }
}

// Corner supports connecting collar to top guide plate

module corner_support_posts() {
    post_l = frame_wall;
    post_w = frame_wall;
    post_h = guide_plate_bottom_z - collar_depth;

    color("lightgray")
    for (sx = [-1, 1]) {
        for (sy = [-1, 1]) {
            translate([
                sx * (inner_length / 2 + frame_wall / 2),
                sy * (inner_width  / 2 + frame_wall / 2),
                collar_depth
            ])
                rounded_box(post_l, post_w, post_h, 1.5);
        }
    }
}

// Side support rails
// These stiffen the jig without making the whole collar tight.

module side_support_rails() {
    rail_h = guide_plate_bottom_z - collar_depth;
    rail_w = 3.00;

    color("lightgray") {
        // Long side rails
        for (sy = [-1, 1]) {
            translate([
                0,
                sy * (inner_width / 2 + frame_wall / 2),
                collar_depth
            ])
                rounded_box(outer_length, rail_w, rail_h, 1.5);
        }

        // Short end rails
        for (sx = [-1, 1]) {
            translate([
                sx * (inner_length / 2 + frame_wall / 2),
                0,
                collar_depth
            ])
                rounded_box(rail_w, outer_width, rail_h, 1.5);
        }
    }
}

// Top guide plate where the V divots are cut

module top_guide_plate() {
    color("lightgray")
    translate([0, 0, guide_plate_bottom_z])
        rounded_box(outer_length, outer_width, guide_plate_thickness, corner_radius);
}

// Finger lift tabs for easy removal

module lift_tabs() {
    tab_l = 18;
    tab_w = 9;
    tab_h = 3;

    color("lightgray") {
        // Left tab
        translate([
            -outer_length / 2 - tab_l / 2 + 1,
            0,
            guide_plate_top_z - tab_h
        ])
            rounded_box(tab_l, tab_w, tab_h, 2);

        // Right tab
        translate([
            outer_length / 2 + tab_l / 2 - 1,
            0,
            guide_plate_top_z - tab_h
        ])
            rounded_box(tab_l, tab_w, tab_h, 2);
    }
}

// Recessed V-shaped divot + snug straight bore

module recessed_pipette_cutout() {
    union() {
        // Straight snug bore.
        // This is what keeps the pipette tip from moving around.
        translate([0, 0, guide_plate_bottom_z - 0.7])
            cylinder(
                h = guide_plate_thickness + 1.4,
                d = pipette_hole_d,
                center = false,
                $fn = 72
            );

        // V-shaped divot cut into top surface.
        // Wide at top, narrows into the snug bore.
        translate([0, 0, guide_plate_top_z - divot_depth])
            cylinder(
                h = divot_depth + 0.5,
                d1 = pipette_hole_d,
                d2 = divot_top_d,
                center = false,
                $fn = 72
            );
    }
}

// Reference 96-well plate for visualization only

module reference_plate() {
    color([1, 1, 1, 0.28])
    difference() {
        rounded_box(plate_length, plate_width, real_plate_height, 2);

        for (r = [0:rows-1]) {
            for (c = [0:cols-1]) {
                translate(well_center(r, c))
                    reference_well_cutout();
            }
        }
    }

    // Orange target markers showing electrode/pipette target centers
    for (r = [0:rows-1]) {
        for (c = [0:cols-1]) {
            translate(well_center(r, c))
                electrode_target_marker();
        }
    }
}

// Reference well shape

module reference_well_cutout() {
    well_bottom_z = real_plate_height - reference_well_depth;

    translate([0, 0, well_bottom_z])
        cylinder(
            h = reference_well_depth + 0.6,
            d = reference_well_d,
            center = false,
            $fn = 72
        );
}

// Visual electrode target marker

module electrode_target_marker() {
    well_bottom_z = real_plate_height - reference_well_depth;
    z = well_bottom_z + 0.05;

    color("orange")
    difference() {
        translate([0, 0, z])
            cylinder(h = 0.03, d = 1.20, center = false, $fn = 48);

        translate([0, 0, z - 0.01])
            cylinder(h = 0.06, d = 0.85, center = false, $fn = 48);
    }

    color("black")
    translate([0, 0, z + 0.04])
        cylinder(h = 0.02, d = 0.18, center = false, $fn = 24);
}

// Row and column labels

module row_col_labels() {
    label_z = guide_plate_top_z + 0.05;
    label_size = 2.3;
    row_names = ["A", "B", "C", "D", "E", "F", "G", "H"];

    color("black") {
        // Row labels A-H
        for (r = [0:rows-1]) {
            translate([
                guide_center(r, 0)[0] - 6.8,
                guide_center(r, 0)[1] - 1.0,
                label_z
            ])
                linear_extrude(height = 0.30)
                    text(
                        row_names[r],
                        size = label_size,
                        halign = "center",
                        valign = "center"
                    );
        }

        // Column labels 1-12
        for (c = [0:cols-1]) {
            translate([
                guide_center(0, c)[0],
                guide_center(0, c)[1] + 5.7,
                label_z
            ])
                linear_extrude(height = 0.30)
                    text(
                        str(c + 1),
                        size = label_size,
                        halign = "center",
                        valign = "center"
                    );
        }
    }
}

// Position functions

function well_center(r, c) =
[
    -plate_length / 2 + a1_offset_col + c * well_spacing,
     plate_width  / 2 - a1_offset_row - r * well_spacing,
    0
];

function guide_center(r, c) =
[
    -plate_length / 2 + a1_offset_col + c * well_spacing + electrode_offset_x,
     plate_width  / 2 - a1_offset_row - r * well_spacing + electrode_offset_y,
    0
];

// Rounded rectangular solid

module rounded_box(l, w, h, radius) {
    hull() {
        for (x = [-l / 2 + radius, l / 2 - radius]) {
            for (y = [-w / 2 + radius, w / 2 - radius]) {
                translate([x, y, 0])
                    cylinder(
                        h = h,
                        r = radius,
                        center = false,
                        $fn = 24
                    );
            }
        }
    }
}