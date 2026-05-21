// Well-Plate Pipette Guide v0.4.0
// STAND ONLY
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026
// License: AGPL-3.0 (see LICENSE)


// ===== Global settings =====

$fn = $preview ? 32 : 128;

// Keep this nonzero even during full render.
// This is only boolean overlap, not a real design dimension.
z_fight = 0.05;


// ===== User parameters =====

plate = "24"; // "24" or "96"


// ===== Fit / support controls =====

fit_clearance = 0.80;
slide_clearance = 0.45;
shrink_allowance = 0.0;

wall = 5.0;             // top frame wall thickness
support_width = 3.5;    // bottom slide rail / corner leg width

support_style = "corner_legs"; // ["corner_legs", "slide"]

air = 2.5;


// ===== Corner-leg support controls =====

corner_leg_length = 18;
corner_leg_width = support_width;
corner_leg_height = -1;


// ===== Stand / insert fit controls =====

stand_rim_height = 3.0;

// Clearance between the stand opening and insert lip.
// This gives room for printing tolerance.
// The insert bump is slightly larger than this for a light clip effect.
snap_clearance = 0.40;


// ===== Plate specs =====
//                      rows cols  a1_x   a1_y  pitch  height

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


// ===== Derived values =====

fit =
  ((support_style == "slide") ? slide_clearance : fit_clearance)
  + shrink_allowance;

top_z = plate_height + air;

outer_length = plate_length + 2 * (fit + wall);
outer_width = plate_width + 2 * (fit + wall);

inner_length = plate_length + 2 * fit;
inner_width = plate_width + 2 * fit;

support_outer_length = inner_length + 2 * support_width;
support_outer_width = inner_width + 2 * support_width;

// The insert locator lip is based on the inner plate opening.
locator_length = inner_length;
locator_width = inner_width;

stand_opening_length = locator_length + 2 * snap_clearance;
stand_opening_width = locator_width + 2 * snap_clearance;


// ===== Render stand =====

stand_part();


// ===== Stand modules =====

module stand_part() {
  union() {
    supports();
    stand_receiving_frame();
  }
}


module stand_receiving_frame() {
  // Top frame that the removable insert rests on.
  difference() {
    translate([0, 0, top_z - stand_rim_height])
      rbox(outer_length, outer_width, stand_rim_height + z_fight, wall / 2);

    translate([0, 0, top_z - stand_rim_height - z_fight])
      rbox(
        stand_opening_length,
        stand_opening_width,
        stand_rim_height + 3 * z_fight,
        wall / 2
      );
  }
}


// ===== Support styles =====

module supports() {
  if (support_style == "slide") {
    // Full-length side rails; plate slides in from the front (-Y side)
    for (sx = [-1, 1]) {
      translate([
        sx * (inner_length / 2 + support_width / 2),
        0,
        0
      ])
        rbox(
          support_width,
          support_outer_width,
          top_z + z_fight,
          support_width / 2
        );
    }

    // Back stop
    translate([0, inner_width / 2 + support_width / 2, 0])
      rbox(
        support_outer_length,
        support_width,
        top_z + z_fight,
        support_width / 2
      );

  } else if (support_style == "corner_legs") {
    for (sx = [-1, 1], sy = [-1, 1]) {
      corner_leg(sx, sy);
    }
  }
}


module corner_leg(sx, sy) {
  leg_w = max(corner_leg_width, 0.1);
  leg_h = (corner_leg_height > 0) ? corner_leg_height : top_z + z_fight;

  // Keep the arms short enough that they do not become full side rails.
  arm = min(corner_leg_length, min(inner_length, inner_width) / 2);

  // X-direction arm.
  // Outside face is flush with the stand's outer edge.
  translate([
    sx * (outer_length / 2 - (arm + leg_w) / 2),
    sy * (outer_width / 2 - leg_w / 2),
    0
  ])
    rbox(
      arm + leg_w,
      leg_w,
      leg_h,
      leg_w / 2
    );

  // Y-direction arm.
  // Outside face is flush with the stand's outer edge.
  translate([
    sx * (outer_length / 2 - leg_w / 2),
    sy * (outer_width / 2 - (arm + leg_w) / 2),
    0
  ])
    rbox(
      leg_w,
      arm + leg_w,
      leg_h,
      leg_w / 2
    );
}


// ===== Helper modules/functions =====

module rbox(length, width, height, radius) {
  translate([0, 0, height / 2]) {
    union() {
      // Rectangular prism with corners removed
      difference() {
        cube([length, width, height], center = true);

        for (i = [-1, 1], j = [-1, 1]) {
          translate([length / 2 * i, width / 2 * j, 0])
            cube([2 * radius, 2 * radius, height * 2], center = true);
        }
      }

      // Rounded corners
      for (i = [-1, 1], j = [-1, 1]) {
        translate([
          (length / 2 - radius) * i,
          (width / 2 - radius) * j,
          0
        ])
          cylinder(
            h = height,
            r = radius,
            center = true
          );
      }
    }
  }
}