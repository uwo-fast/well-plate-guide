// Pipette Guide v4
// Two-part design: reusable stand + removable guide plate with multi-stage bore.
// All plate geometry sourced from well_plate.scad / well_plates.scad.
// Units: mm
// Main editable values:
// - tip_diameter controls the upper pipette opening.
// - bottom_hole_diameter controls the smaller lower guide hole.
// - protrusion_* controls the outside cone that enters the well.
// By Cameron Brooks and Hadden Christ, May 2026
// License: AGPL-3.0 (see LICENSE)

include <well_plates.scad>
include <well_plate.scad>
use <utils.scad> // For cross_section() module

// ═══════════════════════════════════════════════════════════════════════════════
// User parameters
// ═══════════════════════════════════════════════════════════════════════════════

/* [Render] */
render_part = "assembly"; // ["assembly", "stand", "guide", "base"]
offset_assembly = true; // Lifts guide onto stand in assembly view
render_well_plate = true; // Shows transparent reference well plate
view_cross_section = false; // Hides part geometry and shows cross section instead

/* [Plate Selection] */
plate_selection = 0; // [0:WP24 CytoView MEA, 1:WP96 flat, 2:WP96 round, 3:WP384 flat, 4:WP1536 flat]

/* [Base] */
base_thickness = 2.4; // Thickness of optional base plate for extra stability

/* [Stand] */
wall_thickness = 5.0;
snap_lip_height = 2.4; // Depth of locator lip below guide plate
snap_lip_width = 1.8; // Thickness of locator lip wall
snap_bump = 0.05; // Small snap interference; set 0 for no snap bump

/* [Guide] */
guide_height = 4;

// Upper pipette opening.
// Change this if the pipette body/tip needs more clearance at the top.
tip_diameter = 3.6;

// Smaller bottom opening.
// Change this to make only the lower guide hole tighter or looser.
bottom_hole_diameter = 2.6;

// Top hole stays tied to tip diameter unless you want independent control.
top_hole_diameter = tip_diameter;

// Extra protrusion length below the snap lip into the well.
protrusion_extension = 3;

/* [Bottom Protrusion Shape] */
// Controls the OUTSIDE of the lower cone.
// This does not control the actual hole size.
protrusion_bottom_mode = "angle"; // ["angle", "radius"]

// Top outside radius of cone.
protrusion_top_radius = tip_diameter;

// Bottom outside radius, only used when protrusion_bottom_mode = "radius".
protrusion_bottom_radius = tip_diameter * 0.75;

// Taper angle, only used when protrusion_bottom_mode = "angle".
// Bigger angle = smaller outside radius at the bottom.
protrusion_taper_angle = 5.5;

// Minimum wall around the bottom hole so the cone does not get too thin.
protrusion_min_wall = 0.8;

/* [Lift Tabs] */
tab_length = 18;
tab_width = 9;
tab_height = 3;

/* [Labels] */
label_depth = 0.5;

/* [Fit + Print Tuning] */
fit_clearance = 0.2; // General clearance for fit between stand and guide

module dummy(){} // Customizer fence

// ═══════════════════════════════════════════════════════════════════════════════
// Derived dimensions
// ═══════════════════════════════════════════════════════════════════════════════

$fn = $preview ? 32 : 128;
z_fight = 0.05;

plate_type = well_plates[plate_selection];

rows = wp_rows(plate_type);
cols = wp_cols(plate_type);
pitch = wp_pitch(plate_type);
a1_x = wp_a1_x(plate_type);
a1_y = wp_a1_y(plate_type);

// Overall guide/stand envelope around the well plate
outer_length = WP_LENGTH + 2 * (fit_clearance + wall_thickness);
outer_width = WP_WIDTH + 2 * (fit_clearance + wall_thickness);

inner_length = WP_LENGTH + 2 * fit_clearance;
inner_width = WP_WIDTH + 2 * fit_clearance;

pocket_length = inner_length + 2 * fit_clearance;
pocket_width = inner_width + 2 * fit_clearance;

// Stand height reaches the plate top/flange plus snap-lip engagement
stand_height = WP_HEIGHT + wp_flange_h(plate_type) + snap_lip_height;

// Height of lower cone section
protrusion_height = snap_lip_height + guide_height + protrusion_extension;

// Minimum outside radius allowed based on bottom hole and wall thickness
protrusion_min_radius = bottom_hole_diameter / 2 + protrusion_min_wall;

// Bottom outside radius calculated from taper angle
protrusion_bottom_radius_from_angle =
protrusion_top_radius - protrusion_height * tan(protrusion_taper_angle);

// Final outside radii for lower protrusion
protrusion_r1 = max(
  protrusion_min_radius,
  protrusion_bottom_mode == "angle" ? protrusion_bottom_radius_from_angle
  : protrusion_bottom_radius
);

protrusion_r2 = max(protrusion_min_radius, protrusion_top_radius);

// Snap bump sizing
snap_bump_length = outer_width / 10;
snap_bump_height = snap_lip_height / 3;
bump_depth = snap_bump;

// ═══════════════════════════════════════════════════════════════════════════════
// Render selector
// ═══════════════════════════════════════════════════════════════════════════════

if (render_well_plate)
  cross_section(active=view_cross_section)
    color("LightGray", alpha=0.5)
      well_plate(plate_type);

if (render_part == "stand" || render_part == "assembly")
  cross_section(active=view_cross_section)
    stand();

if (render_part == "guide" || render_part == "assembly")
  cross_section(active=view_cross_section)
    translate([0, 0, render_part == "assembly" && offset_assembly ? stand_height : 0])
      guide();

if (render_part == "base" || render_part == "assembly")
  cross_section(active=view_cross_section)
    base();

// ═══════════════════════════════════════════════════════════════════════════════
// Base (optional)
// ═══════════════════════════════════════════════════════════════════════════════
module base() {
  // Optional base plate for extra stability.
  // Slightly larger than the stand footprint with a pocket for the stand to nest into.
  base_length = outer_length + base_thickness * 2;
  base_width = outer_width + base_thickness * 2;
  r = wall_thickness / 2; // Match stand corner radius

  translate([0, 0, -base_thickness])
    difference() {
      rbox(base_length, base_width, base_thickness * 2, r);
      translate([0, 0, base_thickness])
        rbox(outer_length + fit_clearance, outer_width + fit_clearance, base_thickness + z_fight, r);
      // Well viewing cutouts through floor
      at_wells()
        translate([0, 0, -z_fight / 2])
          cylinder(h = base_thickness + z_fight, d = wp_well_d(plate_type), $fn = 32);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stand
// ═══════════════════════════════════════════════════════════════════════════════

module stand() {
  difference() {
    // Main outer stand body
    rbox(outer_length, outer_width, stand_height, wall_thickness / 2);

    // Inner pocket for well plate
    translate([0, 0, -z_fight / 2])
      rbox(pocket_length, pocket_width, stand_height + z_fight, wall_thickness / 2);

    // Side relief cut
    translate([0, outer_width, 0])
      rotate([90, 0, 0])
        scale([pocket_length / stand_height, 1.5, 1])
          cylinder(d=stand_height, h=outer_width * 2, $fn=64);

    // Front/back relief cut
    translate([-outer_length, 0, 0])
      rotate([0, 90, 0])
        scale([1.5, pocket_width / stand_height, 1])
          cylinder(d=stand_height, h=outer_length * 2, $fn=64);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Guide
// ═══════════════════════════════════════════════════════════════════════════════

module guide() {
  // Prevents protrusions from going too deep into the well
  assert(
    protrusion_extension <= wp_well_depth(plate_type) * 0.80,
    "Protrusion extension is too long and may touch the bottom."
  );

  difference() {
    union() {
      // Main guide plate
      rbox(outer_length, outer_width, guide_height, wall_thickness / 2);

      // Lower protrusions that enter the wells
      at_wells()
        translate([0, 0, -snap_lip_height - protrusion_extension])
          cylinder(
            h=protrusion_height,
            r1=protrusion_r1,
            r2=protrusion_r2,
            $fn=32
          );

      // Locator lip underneath guide plate
      translate([0, 0, -(snap_lip_height - fit_clearance / 2)])
        snap_lip(snap_lip_height);

      // Side lift tabs
      for (sx = [-1, 1])
        translate([sx * outer_length / 2, 0, guide_height - tab_height])
          rbox(tab_length, tab_width, tab_height, tab_width / 4);
    }

    // Tapered bore cut through each protrusion
    // d1 = bottom hole diameter
    // d2 = top hole diameter
    at_wells()
      translate([0, 0, -snap_lip_height - protrusion_extension - z_fight / 2])
        cylinder(
          h=protrusion_height + z_fight,
          d1=bottom_hole_diameter,
          d2=top_hole_diameter,
          $fn=32
        );

    // Engraved row/column labels
    translate([0, 0, guide_height])
      well_labels();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-modules
// ═══════════════════════════════════════════════════════════════════════════════

module snap_lip(h) {
  // Hollow rectangular locator lip
  difference() {
    rbox(inner_length, inner_width, h + z_fight, snap_lip_width / 2);

    translate([0, 0, -z_fight / 2])
      rbox(
        inner_length - 2 * snap_lip_width,
        inner_width - 2 * snap_lip_width,
        h + z_fight,
        snap_lip_width / 2
      );
  }

  // Small bumps for snap fit
  if (snap_bump > 0) {
    for (sx = [-1, 1])
      translate([sx * (inner_length / 2 + bump_depth / 2), 0, 0])
        rbox(bump_depth, snap_bump_length, snap_bump_height, bump_depth / 2);

    for (sy = [-1, 1])
      translate([0, sy * (inner_width / 2 + bump_depth / 2), 0])
        rbox(snap_bump_length, bump_depth, snap_bump_height, bump_depth / 2);
  }
}

module well_labels() {
  label_size = pitch / 3;

  // Row letters: A, B, C, ...
  for (r = [0:rows - 1]) {
    p = well_xy(r, 0);

    translate([p[0] - 2 * label_size, p[1], -label_depth])
      linear_extrude(label_depth + z_fight)
        text(chr(65 + r), size=label_size, halign="center", valign="center");
  }

  // Column numbers: 1, 2, 3, ...
  for (c = [0:cols - 1]) {
    p = well_xy(0, c);

    translate([p[0], p[1] + 2 * label_size, -label_depth])
      linear_extrude(label_depth + z_fight)
        text(str(c + 1), size=label_size, halign="center", valign="center");
  }
}

// Applies child geometry at every well location
module at_wells() {
  for (r = [0:rows - 1], c = [0:cols - 1])
    translate(well_xy(r, c))
      children();
}

// Converts row/column index into XY location
function well_xy(row, col) =
  [
    -WP_LENGTH / 2 + a1_x + col * pitch,
    WP_WIDTH / 2 - a1_y - row * pitch,
    0,
  ];

// Rounded rectangle box centered in XY, base at Z=0.
// Avoids hull() by using 2D offset + linear_extrude.
module rbox(length, width, height, radius, center=true) {
  r = min(radius, min(length, width) / 2 - 0.01);

  linear_extrude(height)
    offset(r=r)
      square([length - 2 * r, width - 2 * r], center=center);
}
