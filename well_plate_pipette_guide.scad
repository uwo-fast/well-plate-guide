// Well-Plate Pipette Guide
// Sits on a well plate; funneled holes guide pipette tips into each well.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026

// ===== Global settings =====

$fn = $preview ? 32 : 128; // facets for curves; fewer in preview for speed
z_fight = $preview ? 0.05 : 0.0; // coplanar-face offset; avoids Z-fighting in preview

// ===== Parameters =====

plate = "96"; // "24" or "96"
tip_diameter = 1.20; // pipette tip OD at guide bore -- measure your tips
tip_clearance = 0.15; // tip bore clearance
fit_clearance = 0.80; // plate fit clearance -- loosen if jig is too snug
wall = 5.0; // frame wall / post thickness
collar = 6.0; // registration skirt height
air = 2.5; // gap above plate surface to guide plate underside
labels = true;

module dummy(){}; // dummy module to stop customizer from picking up internal parameters as user parameters

// ===== Plate specs (SBS/ANSI standard) =====
//                      rows cols  a1_x   a1_y  pitch  height
spec =
  (plate == "24") ? 
  [4, 6, 18.83, 15.69, 18.0, 14.35]
  : [8, 12, 14.38, 11.24, 9.0, 14.40];

rows = spec[0];
cols = spec[1];
a1_x = spec[2];
a1_y = spec[3];
pitch = spec[4];
plate_height = spec[5];
plate_length = 127.76;
plate_width = 85.48;

// ===== Derived =====

bore = tip_diameter + tip_clearance;
funnel = pitch * 3 / 5; // 60% of pitch -- clears neighbors
funnel_depth = funnel / 2; // ~45 deg entry cone
straight = 4; // straight bore below funnel
slab = funnel_depth + straight; // guide plate thickness
top_z = plate_height + air;
height = top_z + slab;

outer_length = plate_length + 2 * (fit_clearance + wall); // outer envelope
outer_width = plate_width + 2 * (fit_clearance + wall);
inner_length = plate_length + 2 * fit_clearance; // inner cavity
inner_width = plate_width + 2 * fit_clearance;

tab_length = 18; // lift tab length
tab_width = 9; // lift tab width
tab_height = 3; // lift tab height
emboss = 0.3; // label extrusion height

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
  for (r = [0:rows - 1], c = [0:cols - 1]) {
    p = well_pos(r, c);
    translate([p.x, p.y, top_z - z_fight])
      cylinder(h=slab + 2 * z_fight, d=bore);
    translate([p.x, p.y, height - funnel_depth])
      cylinder(h=funnel_depth + z_fight, d1=bore, d2=funnel);
  }
}

// Labels
if (labels) {
  label_size = pitch / 4; // 1/4 pitch
  label_margin = pitch * 2 / 3; // 2/3 pitch from well center
  color("black") {
    for (r = [0:rows - 1]) {
      p = well_pos(r, 0);
      translate([p.x - label_margin, p.y, height])
        linear_extrude(emboss)
          text(chr(65 + r), size=label_size, halign="center", valign="center");
    }
    for (c = [0:cols - 1]) {
      p = well_pos(0, c);
      translate([p.x, p.y + label_margin, height])
        linear_extrude(emboss)
          text(str(c + 1), size=label_size, halign="center", valign="center");
    }
  }
}

// ===== Helpers =====

function well_pos(r, c) =
  [
    -plate_length / 2 + a1_x + c * pitch,
    plate_width / 2 - a1_y - r * pitch,
    0,
  ];

module rbox(length, width, height, radius) {
  hull()for (x = [-length / 2 + radius, length / 2 - radius], y = [-width / 2 + radius, width / 2 - radius])
    translate([x, y, 0])
      cylinder(h=height, r=radius);
}
