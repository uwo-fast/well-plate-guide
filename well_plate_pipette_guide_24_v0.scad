// By Hadden Christ May 2026

// Units: mm

$fn = 80;

// Datasheet plate dimensions

plate_length = 127.76;
plate_width  = 85.48;

a1_offset_row = 15.69;
a1_offset_col = 18.83;
well_spacing  = 18.00;

well_top_d    = 15.00;
well_bottom_d = 5.40;
well_height   = 13.20;
well_bottom_elevation = 1.15;

rows = 4;
cols = 6;

real_plate_height = well_bottom_elevation + well_height;

// Display options

show_reference_plate = false;    // set true if you want to see the MEA plate underneath
show_labels = true;

// Stand dimensions

// Loose fit around actual plate.
// Increase to 1.00 if it is too tight after printing.
plate_clearance = 0.80;

frame_wall = 5.00;
corner_radius = 3.00;

// Shallow skirt helps locate the jig but does not grip the full plate height
collar_depth = 6.00;

// Gap between top of actual plate and underside of guide plate
top_clearance_above_plate = 2.50;

// VWR 200 uL Universal pipette tip 

// VWR tip length 
pipette_tip_total_length = 50.75;   // mm

// Measure the actual tip OD where it enters the snug bore.
// Start with 1.20 mm, then tune after a test print.
pipette_tip_od_at_guide = 1.20;

// Snug clearance:
pipette_clearance = 0.15;

pipette_hole_d = pipette_tip_od_at_guide + pipette_clearance;

// 24-well version has more space, so the V divot can be larger
divot_top_d = 7.00;
divot_depth = 4.00;

// Straight section that holds the pipette tip steady
snug_bore_depth = 4.00;

// Total guide plate thickness
guide_plate_thickness = divot_depth + snug_bore_depth;

// Stand dimensions

guide_plate_bottom_z = real_plate_height + top_clearance_above_plate;
guide_plate_top_z = guide_plate_bottom_z + guide_plate_thickness;

outer_length = plate_length + 2 * plate_clearance + 2 * frame_wall;
outer_width  = plate_width  + 2 * plate_clearance + 2 * frame_wall;

inner_length = plate_length + 2 * plate_clearance;
inner_width  = plate_width  + 2 * plate_clearance;

// Electrode alignment offset

// Adjust after testing if needed.
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
        top_guide_plate();
        lift_tabs();
    }

    // Cut the recessed divots and pipette guide holes
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

//Shallow frame that slips around the real plate

module shallow_collar_frame() {
    color("lightgray")
    difference() {
        rounded_box(outer_length, outer_width, collar_depth, corner_radius);

        translate([0, 0, -0.5])
            rounded_box(inner_length, inner_width, collar_depth + 1.0, 2);
    }
}

// Corner supports connecting collar to top guide plate
// These avoid a full-height tight wall around the plate.

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
        // Straight snug bore section.
        // This keeps the pipette tip from moving around.
        translate([0, 0, guide_plate_bottom_z - 0.5])
            cylinder(
                h = guide_plate_thickness + 1.0,
                d = pipette_hole_d,
                center = false,
                $fn = 80
            );

        // V-shaped divot cut into the top surface.
        // Wide at top, narrows to pipette snug bore.
        translate([0, 0, guide_plate_top_z - divot_depth])
            cylinder(
                h = divot_depth + 0.5,
                d1 = pipette_hole_d,
                d2 = divot_top_d,
                center = false,
                $fn = 80
            );
    }
}

// Optional reference MEA plate for visualization only

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

    // Orange target marker showing electrode target center
    for (r = [0:rows-1]) {
        for (c = [0:cols-1]) {
            translate(well_center(r, c))
                electrode_target_marker();
        }
    }
}

// Reference well shape

module reference_well_cutout() {
    transition_h = 1.4;
    straight_h = well_height - transition_h;

    union() {
        // Mostly straight circular well
        translate([0, 0, well_bottom_elevation + transition_h])
            cylinder(
                h = straight_h + 0.6,
                d = well_top_d,
                center = false,
                $fn = 96
            );

        // Small bottom taper
        translate([0, 0, well_bottom_elevation - 0.02])
            cylinder(
                h = transition_h + 0.05,
                d1 = well_bottom_d,
                d2 = well_top_d,
                center = false,
                $fn = 96
            );
    }
}

// Visual electrode target marker

module electrode_target_marker() {
    z = well_bottom_elevation + 0.04;

    color("orange")
    difference() {
        translate([0, 0, z])
            cylinder(h = 0.03, d = 1.40, center = false, $fn = 80);

        translate([0, 0, z - 0.01])
            cylinder(h = 0.06, d = 1.05, center = false, $fn = 80);
    }

    color("black")
    translate([0, 0, z + 0.04])
        cylinder(h = 0.02, d = 0.20, center = false, $fn = 24);
}

// Row and column labels

module row_col_labels() {
    label_z = guide_plate_top_z + 0.05;
    label_size = 3.2;
    row_names = ["A", "B", "C", "D"];

    color("black") {
        // Row labels
        for (r = [0:rows-1]) {
            translate([
                guide_center(r, 0)[0] - 11,
                guide_center(r, 0)[1] - 1.5,
                label_z
            ])
                linear_extrude(height = 0.35)
                    text(
                        row_names[r],
                        size = label_size,
                        halign = "center",
                        valign = "center"
                    );
        }

        // Column labels
        for (c = [0:cols-1]) {
            translate([
                guide_center(0, c)[0],
                guide_center(0, c)[1] + 11,
                label_z
            ])
                linear_extrude(height = 0.35)
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
                        $fn = 32
                    );
            }
        }
    }
}