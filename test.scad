// Well-Plate Pipette Guide
// Sits on a well plate; funneled holes guide pipette tips into each well.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026

// ===== Global settings =====

$fn = $preview ? 32 : 128;
z_fight = 0.05;

// ===== Parameters =====

plate = "24"; // "24" or "96"
tip_diameter = 1.20;
tip_clearance = 0.15;
fit_clearance = 0.80;
wall = 5.0;
collar = 6.0;
air = 2.5;
labels = true;

module dummy(){};

// ===== Plate specs =====
//                      rows cols  a1_x   a1_y  pitch  height
spec =
  (plate == "96") ?
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

// ===== Derived =====

bore = tip_diameter + tip_clearance;

slab = 6.7;
straight = 4.0;
funnel_depth = slab - straight;

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

label_depth = 0.5; // engraved label depth

// ===== Model =====

difference() {
  union() {
    // Registration collar
    difference() {
      rbox(outer_length, outer_width, collar, wall / 2);
      translate([0, 0, -z_fight])
        rbox(inner_length, inner_width, collar + 2 * z_fight, wall);
    }

    // Corner posts
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx * (inner_length / 2 + wall / 2), sy * (inner_width / 2 + wall / 2), collar])
        cylinder(d=wall, h=top_z - collar);

    // Guide plate
    translate([0, 0, top_z])
      rbox(outer_length, outer_width, slab, wall / 2);

    // Lift tabs
    for (sx = [-1, 1])
      translate([sx * (outer_length / 2), 0, height - tab_height])
        rbox(tab_length, tab_width, tab_height, wall / 2);
  }

  // Bore + funnel at each well
  for (row = [0:rows - 1], col = [0:cols - 1]) {
    p = well_position(row, col);

    translate([p.x, p.y, top_z - z_fight])
      cylinder(h=slab + 2 * z_fight, d=bore);

    translate([p.x, p.y, height - funnel_depth - z_fight])
      cylinder(h=funnel_depth + 2 * z_fight, d1=bore, d2=funnel);
  }

  // Engraved labels
  if (labels) {
    label_size = pitch / 4;
    label_margin = pitch * 2 / 3;

    for (row = [0:rows - 1]) {
      p = well_position(row, 0);
      translate([p.x - label_margin, p.y, height - label_depth])
        linear_extrude(label_depth + z_fight)
          text(chr(65 + row), size=label_size, halign="center", valign="center");
    }

    for (col = [0:cols - 1]) {
      p = well_position(0, col);
      translate([p.x, p.y + label_margin, height - label_depth])
        linear_extrude(label_depth + z_fight)
          text(str(col + 1), size=label_size, halign="center", valign="center");
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
    for (x = [-length / 2 + radius, length / 2 - radius],
         y = [-width / 2 + radius, width / 2 - radius])
      translate([x, y, 0])
        cylinder(h=height, r=radius);
}