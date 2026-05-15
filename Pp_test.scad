// Well-Plate Pipette Guide - Polypropylene Version
// Sits on a well plate; funneled holes guide pipette tips into each well.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026
//
// PP printing recommendations:
// - PP shrinks/warps more than PETG, so clearances are loosened.
// - Use a brim or raft if corners lift.
// - Use low cooling fan.
// - Use a PP-compatible bed surface or adhesive.
// - Print PETG first if possible to confirm geometry before printing PP.

// ===== Global settings =====

$fn = $preview ? 32 : 128;
z_fight = 0.05;

// ===== Parameters =====

plate = "96"; // "24" or "96"

// PP adjustment:
// Increased from 0.15/0.35 because small printed holes can shrink.
tip_diameter = 1.20;
tip_clearance = 0.50;

// PP adjustment:
// Increased because the collar may shrink and become too tight on the well plate.
fit_clearance = 1.50;

wall = 5.0;
collar = 6.0;
air = 2.5;
labels = true;

// PP adjustment:
// Slightly thicker guide plate to reduce flex.
slab = 7.5;

// PP adjustment:
// Deeper engraving so labels remain visible after printing.
label_depth = 0.8;

module dummy(){};

// ===== Plate specs =====
//                      rows cols  a1_x   a1_y  pitch  height
//
// 24-well plate = 4 rows x 6 columns
// 96-well plate = 8 rows x 12 columns

spec =
  (plate == "24") ?
    [4, 6, 18.83, 15.69, 18.0, 14.35]
  :
    [8, 12, 14.38, 11.24, 9.0, 14.40];

rows = spec[0];
cols = spec[1];
a1_x = spec[2];
a1_y = spec[3];
pitch = spec[4];
plate_height = spec[5];

plate_length = 127.76;
plate_width = 85.48;

echo(str("Plate = ", plate, ", holes = ", rows * cols));

// ===== Derived Dimensions =====

bore = tip_diameter + tip_clearance;

straight = 4.0;
funnel_depth = slab - straight;

// Larger funnel for 24-well plate.
// Smaller funnel for 96-well plate because the wells are closer together.
funnel = (plate == "24") ? 8.0 : 5.4;

top_z = plate_height + air;
height = top_z + slab;

outer_length = plate_length + 2 * (fit_clearance + wall);
outer_width = plate_width + 2 * (fit_clearance + wall);

inner_length = plate_length + 2 * fit_clearance;
inner_width = plate_width + 2 * fit_clearance;

tab_length = 18;
tab_width = 9;
tab_height = 3;

// Bigger labels for 24-well plate.
// Smaller labels for 96-well plate so they fit between wells.
label_size = (plate == "24") ? 4.5 : 3.0;
label_margin = pitch * 2 / 3;

// ===== Model =====

difference() {
  union() {

    // Registration collar
    // This skirt drops around the well plate to locate the guide.
    difference() {
      rbox(outer_length, outer_width, collar, wall / 2);

      translate([0, 0, -z_fight])
        rbox(inner_length, inner_width, collar + 2 * z_fight, wall);
    }

    // Corner posts
    // These support the top guide plate above the well plate.
    for (sx = [-1, 1], sy = [-1, 1])
      translate([
        sx * (inner_length / 2 + wall / 2),
        sy * (inner_width / 2 + wall / 2),
        collar
      ])
        cylinder(d = wall, h = top_z - collar);

    // Guide plate
    // PP version is slightly thicker to reduce flex.
    translate([0, 0, top_z])
      rbox(outer_length, outer_width, slab, wall / 2);

    // Lift tabs
    // Small side tabs make the guide easier to remove from the plate.
    for (sx = [-1, 1])
      translate([
        sx * (outer_length / 2),
        0,
        height - tab_height
      ])
        rbox(tab_length, tab_width, tab_height, wall / 2);
  }

  // Bore + funnel at each well
  // Bore is the straight hole for the pipette tip.
  // Funnel helps guide the tip into the bore.
  for (row = [0 : rows - 1], col = [0 : cols - 1]) {
    p = well_position(row, col);

    // Straight bore
    translate([p[0], p[1], top_z - z_fight])
      cylinder(
        h = slab + 2 * z_fight,
        d = bore
      );

    // Tapered funnel
    translate([p[0], p[1], height - funnel_depth - z_fight])
      cylinder(
        h = funnel_depth + 2 * z_fight,
        d1 = bore,
        d2 = funnel
      );
  }

  // Engraved labels
  // Labels are cut into the top surface, not extruded outward.
  if (labels) {

    // Row labels: A, B, C, etc.
    for (row = [0 : rows - 1]) {
      p = well_position(row, 0);

      translate([
        p[0] - label_margin,
        p[1],
        height - label_depth
      ])
        linear_extrude(label_depth + z_fight)
          text(
            chr(65 + row),
            size = label_size,
            halign = "center",
            valign = "center"
          );
    }

    // Column labels: 1, 2, 3, etc.
    for (col = [0 : cols - 1]) {
      p = well_position(0, col);

      translate([
        p[0],
        p[1] + label_margin,
        height - label_depth
      ])
        linear_extrude(label_depth + z_fight)
          text(
            str(col + 1),
            size = label_size,
            halign = "center",
            valign = "center"
          );
    }
  }
}

// ===== Helpers =====

function well_position(row, col) =
  [
    -plate_length / 2 + a1_x + col * pitch,
     plate_width / 2 - a1_y - row * pitch,
     0
  ];

module rbox(length, width, height, radius) {
  hull()
    for (
      x = [-length / 2 + radius, length / 2 - radius],
      y = [-width / 2 + radius, width / 2 - radius]
    )
      translate([x, y, 0])
        cylinder(h = height, r = radius);
}