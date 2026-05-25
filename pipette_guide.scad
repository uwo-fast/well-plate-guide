// Pipette Guide v4
// Two-part design: reusable stand + removable guide plate with multi-stage bore.
// All plate geometry sourced from well_plate.scad / well_plates.scad.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026
// License: AGPL-3.0 (see LICENSE)
//
// Out of scope:
//   - 24-well plates (non-standard, to be added later)
//

// TODO / Future work:
//   - 24-well plate support (non-SLAS, needs height override in well_plates.scad)
//   - Well taper in plate model (does not affect guide geometry)

include <well_plates.scad>
include <well_plate.scad>

// ═══════════════════════════════════════════════════════════════════════════════
// User parameters
// ═══════════════════════════════════════════════════════════════════════════════

// --- What to render ---
render_part = "assembly"; // ["assembly", "stand", "guide"]
offset_assembly = true; // Shift guide up by stand height to show fit (assembly mode only)
render_well_plate = true; // Show the well plate using the model from well_plate.scad

// --- Plate selection ---
plate_selection = 0; // [0:WP96 flat, 1:WP96 round, 2:WP384 flat, 3:WP1536 flat]

// --- Tip geometry (measure your pipette tips) ---
tip_diameter = 2;
protrusion_extension = 2; // Extra length to protrude beyond guide lip to help better guide into wells

// --- Fit & print tuning ---
fit_clearance = 0.80; // snap_lip_height between well plate edge and stand inner wall
shrink = 0.0; // Extra clearance for shrink-prone materials (PP: ~0.35)

// --- Structure ---
wall = 5.0; // Frame wall thickness

// --- Snap-fit / locator ---
snap_clearance = 0.40; // snap_lip_height between stand pocket and guide lip
snap_lip_height = 2.5; // Locator lip depth below guide
snap_lip_width = 1.8; // Locator lip wall thickness
snap_bump = 0.05; // Interference beyond snap_clearance (0 = no clip)
snap_bump_length = 10.0; // Bump extent along each side
snap_bump_height = 0.8; // Bump vertical height

// --- Lift tabs ---
tab_length = 18;
tab_width = 9;
tab_height = 3;

// --- Labels ---
label_depth = 0.5;

guide_height = 4; // guide thickness

module dummy(){} // ── customizer fence ──

// ═══════════════════════════════════════════════════════════════════════════════
// Derived dimensions
// ═══════════════════════════════════════════════════════════════════════════════

$fn = $preview ? 32 : 128;
z_fight = 0.05;

// Derived from plate selection, corresponding to well_plates array in well_plates.scad
plate_type = well_plates[plate_selection];

// Plate accessors
rows = wp_rows(plate_type);
cols = wp_cols(plate_type);
pitch = wp_pitch(plate_type);
a1_x = wp_a1_x(plate_type);
a1_y = wp_a1_y(plate_type);

// Bore diameters (with shrink compensation)
fit = fit_clearance + shrink;

// Vertical positions
stand_height = WP_HEIGHT + wp_flange_h(plate_type) + snap_lip_height; // Z of plate underside

// Envelope
outer_length = WP_LENGTH + 2 * (fit + wall);
outer_width = WP_WIDTH + 2 * (fit + wall);
inner_length = WP_LENGTH + 2 * fit;
inner_width = WP_WIDTH + 2 * fit;

// Snap-fit derived
bump_depth = snap_clearance + snap_bump;
pocket_length = inner_length + 2 * snap_clearance;
pocket_width = inner_width + 2 * snap_clearance;

// ═══════════════════════════════════════════════════════════════════════════════
// Render selector
// ═══════════════════════════════════════════════════════════════════════════════

if (render_well_plate)
  color("LightGray", alpha=0.5)
    well_plate(plate_type);

if (render_part == "stand" || render_part == "assembly")
  stand();

guide_z_pos =
(offset_assembly ? stand_height : 0) + (render_part == "assembly" ? stand_height : 0);

if (render_part == "guide" || render_part == "assembly")
  translate([0, 0, guide_z_pos])
    guide();

// ═══════════════════════════════════════════════════════════════════════════════
// Stand
// ═══════════════════════════════════════════════════════════════════════════════

module stand() {
  difference() {
    translate([0, 0, 0])
      rbox(outer_length, outer_width, stand_height, wall / 2);
    translate([0, 0, 0 - z_fight / 2])
      rbox(pocket_length, pocket_width, stand_height + z_fight, wall / 2);

    translate([0, outer_width, 0])
      rotate([90, 0, 0])
        scale([pocket_length / stand_height, 1.5, 1])
          cylinder(d=stand_height, h=outer_width * 2, $fn=64);

    translate([-outer_length, 0, 0])
      rotate([0, 90, 0])
        scale([1.5, pocket_width / stand_height, 1])
          cylinder(d=stand_height, h=outer_length * 2, $fn=64);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// guide
// ═══════════════════════════════════════════════════════════════════════════════

module guide() {

  // Ensure that the user has not set a protrusion extension that is too long 
  // and may cause the guide to touch the bottom of the wells, which could lead 
  // to damage of the specimen, well plate, or tip of the pipette.
  assert(
    protrusion_extension <= wp_well_depth(plate_type) * 0.80,
    "Protrusion extension is too long and may touch the bottom."
  );

  difference() {
    union() {
      // Guide plate body
      translate([0, 0, 0])
        rbox(outer_length, outer_width, guide_height, wall / 2);

      // Protrusions to guide tips into well plate
      for (r = [0:rows - 1], c = [0:cols - 1]) {
        p = well_xy(r, c);
        translate([p.x, p.y, -snap_lip_height - protrusion_extension])
          cylinder(h=snap_lip_height + guide_height + protrusion_extension, d1=tip_diameter * 1.5, d2=tip_diameter * 2, $fn=32);
      }
      // Locator lip + snap bumps
      translate([0, 0, -(snap_lip_height - fit / 2)])
        snap_lip(snap_lip_height);

      // Lift tabs
      for (sx = [-1, 1])
        translate([sx * (outer_length / 2), 0, 0 + guide_height - tab_height])
          rbox(tab_length, tab_width, tab_height, tab_width / 4);
    }

    // bore at each well
    for (r = [0:rows - 1], c = [0:cols - 1]) {
      p = well_xy(r, c);
      translate([p.x, p.y, -snap_lip_height - protrusion_extension - z_fight / 2])
        cylinder(h=guide_height + snap_lip_height + protrusion_extension + z_fight, d=tip_diameter);
    }

    // Engraved labels
    translate([0, 0, guide_height])
      well_labels();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-modules
// ═══════════════════════════════════════════════════════════════════════════════

module snap_lip(lip_height) {
  // Hollow rectangular lip
  difference() {
    translate([0, 0, 0])
      rbox(inner_length, inner_width, lip_height + z_fight, snap_lip_width / 2);
    translate([0, 0, -z_fight / 2])
      rbox(
        inner_length - 2 * snap_lip_width,
        inner_width - 2 * snap_lip_width,
        lip_height + z_fight,
        snap_lip_width / 2
      );
  }

  // Snap bumps
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

  // Row letters (A, B, C, ...)
  for (r = [0:rows - 1]) {
    p = well_xy(r, 0);
    translate([p.x - label_size * 2, p.y, -label_depth])
      linear_extrude(label_depth + z_fight)
        text(chr(65 + r), size=label_size, halign="center", valign="center");
  }
  // Column numbers (1, 2, 3, ...)
  for (c = [0:cols - 1]) {
    p = well_xy(0, c);
    translate([p.x, p.y + label_size * 2, -label_depth])
      linear_extrude(label_depth + z_fight)
        text(str(c + 1), size=label_size, halign="center", valign="center");
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════════

function well_xy(row, col) =
  [
    -WP_LENGTH / 2 + a1_x + col * pitch,
    WP_WIDTH / 2 - a1_y - row * pitch,
    0,
  ];

// Rounded-corner box centered on XY, base at Z=0
module rbox(length, width, height, radius) {
  r = min(radius, min(length, width) / 2);
  translate([0, 0, height / 2])
    hull()for (i = [-1, 1], j = [-1, 1])
      translate([i * (length / 2 - r), j * (width / 2 - r), 0])
        cylinder(r=r, h=height, center=true);
}
