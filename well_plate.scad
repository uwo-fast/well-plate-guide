//
//! Parametric well plate geometry per ANSI/SLAS 1-4 (2004, R2012).
//!
//! Models the external envelope, flange/skirt, and well array for standard
//! microplates. Driven by entries defined in well_plates.scad.
//!
//! Coordinate system:
//!   Origin = plate center at Datum A (bottom resting plane, Z=0)
//!   X = plate length (127.76 mm)
//!   Y = plate width (85.48 mm)
//!   Z = up from resting plane
//!
//! Out of scope (non-conforming or undefined by SLAS):
//!   - Rim/lip stacking features (SLAS-2 limits projection to 0.76mm max
//!     but does not define shape)
//!   - Deep-well / chimney plates (exceed SLAS-2 height of 14.35mm)
//!

// TODO / Future work:
//   - Well taper (draft angle) — real wells are conical, not straight-sided
//   - SLAS-3 §4.4 flange interruptions (centered projection on long sides)
//   - Non-circular well cross-sections for 1536-well plates (square wells)

// ──────────────────────────────────────────────────────────────────────────────
// SLAS standard values (same for all compliant plates)
// ──────────────────────────────────────────────────────────────────────────────

// SLAS-1: Footprint
WP_LENGTH = 127.76;
WP_WIDTH = 85.48;
WP_CORNER_R = 3.18;

// SLAS-2: Height
WP_HEIGHT = 14.35;

// SLAS-3: Minimum flange wall thickness
WP_FLANGE_W = 1.27;

// SLAS-2 §4.1: Minimum external clearance below wells
WP_CLEARANCE = 1.00;

// ──────────────────────────────────────────────────────────────────────────────
// Accessor functions
// ──────────────────────────────────────────────────────────────────────────────

function wp_name(type) = type[0];
function wp_rows(type) = type[1];
function wp_cols(type) = type[2];
function wp_pitch(type) = type[3];
function wp_a1_x(type) = type[4];
function wp_a1_y(type) = type[5];
function wp_well_d(type) = type[6];
function wp_well_depth(type) = type[7];
function wp_well_shape(type) = type[8];
function wp_bottom_r(type) = type[9];
function wp_flange_h(type) = type[10];
function wp_flange_h_long(type) = let (v = type[11]) v > 0 ? v : type[10];
function wp_has_clearance(type) = type[12];

// Derived
function wp_n_wells(type) = wp_rows(type) * wp_cols(type);
function wp_wall_t(type) = wp_pitch(type) - wp_well_d(type);
function wp_array_x(type) = wp_pitch(type) * (wp_cols(type) - 1);
function wp_array_y(type) = wp_pitch(type) * (wp_rows(type) - 1);

// A1 well center relative to plate center origin
function wp_a1_center(type) =
  [
    -WP_LENGTH / 2 + wp_a1_x(type),
    WP_WIDTH / 2 - wp_a1_y(type),
  ];

// ──────────────────────────────────────────────────────────────────────────────
// Geometry helpers
// ──────────────────────────────────────────────────────────────────────────────

// 2D rounded rectangle centered at origin
module wp_rounded_rect(size_x, size_y, r) {
  offset(r=r, $fn=32)
    square([size_x - 2 * r, size_y - 2 * r], center=true);
}

// Single well bore (negative space)
// Uses union (not intersection) to avoid CSG tree explosion with large arrays
module wp_single_well(type) {
  d = wp_well_d(type);
  depth = wp_well_depth(type) + ($preview ? 0.05 : 0); // Avoid z-fight in preview
  br = wp_bottom_r(type);

  if (wp_well_shape(type) == "round") {
    if (br == 0) {
      // Flat bottom
      cylinder(h=depth, d=d, $fn=32);
    } else {
      // Round bottom: cylinder + sphere at z=br
      // Sphere bottom half forms the U-bottom; top half is redundant
      // (subsumed by cylinder). Safe because this is negative space.
      translate([0, 0, br])
        cylinder(h=depth - br, d=d, $fn=32);
      translate([0, 0, br])
        sphere(r=br, $fn=32);
    }
  } else {
    // Square well
    if (br == 0) {
      cube([d, d, depth], center=false);
    } else {
      // Square with rounded bottom: cube + sphere
      translate([0, 0, br])
        cube([d, d, depth - br]);
      translate([d / 2, d / 2, br])
        sphere(r=br, $fn=32);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Main modules
// ──────────────────────────────────────────────────────────────────────────────

// Full plate: body with wells cut, plus flange below
module well_plate(type) {
  // Body: outer envelope minus wells
  difference() {
    // Solid body from Datum A (Z=0) up to plate height
    linear_extrude(WP_HEIGHT)
      wp_rounded_rect(WP_LENGTH, WP_WIDTH, WP_CORNER_R);

    // Cut wells from top
    wp_well_array(type);
  }

  // Flange / skirt below Datum A
  wp_flange(type);
}

// Array of wells positioned on the plate (negative space, cut from top down)
module wp_well_array(type) {
  a1 = wp_a1_center(type);
  p = wp_pitch(type);
  rows = wp_rows(type);
  cols = wp_cols(type);
  d = wp_well_d(type);
  depth = wp_well_depth(type);

  for (col = [0:cols - 1])
    for (row = [0:rows - 1]) {
      x = a1[0] + col * p;
      y = a1[1] - row * p;

      if (wp_well_shape(type) == "round") {
        translate([x, y, WP_HEIGHT - depth])
          wp_single_well(type);
      } else {
        // Square wells: offset so center aligns with grid position
        translate([x - d / 2, y - d / 2, WP_HEIGHT - depth])
          wp_single_well(type);
      }
    }
}

// Flange / skirt below Datum A
module wp_flange(type) {
  h_short = wp_flange_h(type);
  h_long = wp_flange_h_long(type);
  w = WP_FLANGE_W;

  if (h_short == h_long) {
    // Uniform flange on all sides
    translate([0, 0, -h_short])
      linear_extrude(h_short)
        difference() {
          wp_rounded_rect(WP_LENGTH, WP_WIDTH, WP_CORNER_R);
          wp_rounded_rect(WP_LENGTH - 2 * w, WP_WIDTH - 2 * w, WP_CORNER_R - w);
        }
  } else {
    // Dual flange: different heights on short vs long sides
    // Long sides (taller)
    translate([0, 0, -h_long])
      linear_extrude(h_long)
        intersection() {
          difference() {
            wp_rounded_rect(WP_LENGTH, WP_WIDTH, WP_CORNER_R);
            wp_rounded_rect(WP_LENGTH - 2 * w, WP_WIDTH - 2 * w, WP_CORNER_R - w);
          }
          // Mask to long sides only (central band in X)
          square([WP_LENGTH - 2 * WP_CORNER_R, WP_WIDTH], center=true);
        }

    // Short sides (shorter)
    translate([0, 0, -h_short])
      linear_extrude(h_short)
        intersection() {
          difference() {
            wp_rounded_rect(WP_LENGTH, WP_WIDTH, WP_CORNER_R);
            wp_rounded_rect(WP_LENGTH - 2 * w, WP_WIDTH - 2 * w, WP_CORNER_R - w);
          }
          // Mask to short sides only (central band in Y)
          square([WP_LENGTH, WP_WIDTH - 2 * WP_CORNER_R], center=true);
        }

    // Corners: use short flange height (conservative)
    translate([0, 0, -h_short])
      linear_extrude(h_short)
        intersection() {
          difference() {
            wp_rounded_rect(WP_LENGTH, WP_WIDTH, WP_CORNER_R);
            wp_rounded_rect(WP_LENGTH - 2 * w, WP_WIDTH - 2 * w, WP_CORNER_R - w);
          }
          // Corners only
          difference() {
            square([WP_LENGTH, WP_WIDTH], center=true);
            square([WP_LENGTH - 2 * WP_CORNER_R, WP_WIDTH], center=true);
            square([WP_LENGTH, WP_WIDTH - 2 * WP_CORNER_R], center=true);
          }
        }
  }
}
