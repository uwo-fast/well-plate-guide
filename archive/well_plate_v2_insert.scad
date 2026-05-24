// Well-Plate Pipette Guide v0.4.0
// INSERT ONLY
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


// ===== Pipette hole / taper controls =====

// Top funnel opening:        3.80 mm
// Upper guide bore:          3.60 mm
// Lower straight guide bore: 1.40 mm
tip_top_diameter = 3.60;
tip_guide_diameter = 1.40;
funnel_top_diameter = 3.80;

// Downward tapered socket controls.
// This is the part that extends down from the removable insert into the well.
tip_socket_depth = 4.0;
tip_socket_wall = 1.0;

// Small straight guide cylinder at the bottom of the socket.
// This helps stop the pipette tip from wobbling.
tip_guide_height = 2.0;


// ===== Fit controls =====
// These must match the stand file.

fit_clearance = 0.80;
slide_clearance = 0.45;
shrink_allowance = 0.0;

wall = 5.0;

// This does not render supports in this file,
// but it must match the stand file because it affects fit.
support_style = "corner_legs"; // ["corner_legs", "slide"]

air = 2.5;

labels = true;

tab_length = 18;
tab_width = 9;
tab_height = 3;

label_depth = 0.5;

// Main insert body height.
// This makes the insert height match the side tab height.
insert_thickness = tab_height;


// ===== Snap-fit / removable insert controls =====

snap_lip_height = 2.0;

// Thicker original snap-on wall.
// This keeps the single original rectangle, but makes it stronger.
snap_lip_width = 1.8;

// Match the stand clearance here so the snap bump can be controlled properly.
snap_clearance_ref = 0.40;

// Small interference amount for clip effect.
// 0.05 means the bump is slightly larger than the stand clearance.
snap_interference = 0.05;

// Actual bump depth.
// 0.40 clearance + 0.05 interference = 0.45 mm bump.
snap_bump_depth = snap_clearance_ref + snap_interference;

snap_bump_length = 10;
snap_bump_height = 0.8;


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

// Small straight guide bore for the narrow pipette tip
tip_guide_bore = tip_guide_diameter + shrink_allowance;

// Wider part of the pipette tip near the upper guide bore
bore = tip_top_diameter + shrink_allowance;

// Larger top funnel for pipette collar/body
funnel = funnel_top_diameter + shrink_allowance;

// Outer socket follows the internal guide/taper shape
socket_outer_bottom = tip_guide_bore + 2 * tip_socket_wall;
socket_outer_top = bore + 2 * tip_socket_wall;

funnel_depth = funnel / 2;

// The insert body height is now the same as tab_height.
// The straight/tapered section above the socket is adjusted to fit inside this height.
slab = insert_thickness;
straight = max(slab - funnel_depth, 0.1);

top_z = plate_height + air;
height = top_z + slab;

outer_length = plate_length + 2 * (fit + wall);
outer_width = plate_width + 2 * (fit + wall);

inner_length = plate_length + 2 * fit;
inner_width = plate_width + 2 * fit;

// The removable insert keeps the same outer size as the original guide plate.
insert_length = outer_length;
insert_width = outer_width;

// The underside lip is based on the stand opening dimensions.
locator_length = inner_length;
locator_width = inner_width;

// Lift the insert for standalone printing so the bottom of the downward sockets starts at z = 0.
insert_base_z = tip_socket_depth;


// ===== Render insert =====

guide_insert_part(insert_base_z);


// ===== Insert modules =====

module guide_insert_part(base_z) {
  difference() {
    union() {
      // Removable guide plate
      translate([0, 0, base_z])
        rbox(insert_length, insert_width, slab, wall / 2);

      // Downward tapered sockets.
      // These extend into the wells and help hold the pipette tip steady.
      for (row = [0 : rows - 1], col = [0 : cols - 1]) {
        p = well_position(row, col);
        tapered_tip_socket(p.x, p.y, base_z);
      }

      // Single underside locator/snap lip.
      // The previous second alignment rectangle has been removed.
      insert_locator_lip(base_z);

      // Lift tabs stay attached to the removable insert.
      // Since slab = tab_height, the tabs now match the full insert height.
      for (sx = [-1, 1]) {
        translate([sx * (insert_length / 2), 0, base_z + slab - tab_height])
          rbox(tab_length, tab_width, tab_height, wall / 2);
      }
    }

    // Guide hole + funnel at each well
    for (row = [0 : rows - 1], col = [0 : cols - 1]) {
      p = well_position(row, col);

      // Small straight lower guide cylinder.
      // This is the anti-wobble section for the narrow pipette tip.
      translate([p.x, p.y, base_z - tip_socket_depth - z_fight])
        cylinder(
          h = tip_guide_height + 2 * z_fight,
          d = tip_guide_bore
        );

      // Tapered middle guide.
      // This transitions from the small lower guide bore
      // up to the wider 3.60 mm upper guide bore.
      translate([
        p.x,
        p.y,
        base_z - tip_socket_depth + tip_guide_height - z_fight
      ])
        cylinder(
          h = tip_socket_depth + straight - tip_guide_height + 2 * z_fight,
          d1 = tip_guide_bore,
          d2 = bore
        );

      // Smaller top funnel for pipette collar/body.
      // Goes from 3.60 mm to 3.80 mm.
      funnel_extra_d = (funnel - bore) * z_fight / funnel_depth;

      translate([p.x, p.y, base_z + slab - funnel_depth])
        cylinder(
          h = funnel_depth + z_fight,
          d1 = bore,
          d2 = funnel + funnel_extra_d
        );
    }

    // Engraved labels
    if (labels) {
      label_size = pitch / 4;
      label_margin = pitch * 2 / 3;

      for (row = [0 : rows - 1]) {
        p = well_position(row, 0);

        translate([p.x - label_margin, p.y, base_z + slab - label_depth])
          linear_extrude(label_depth + z_fight)
            text(
              chr(65 + row),
              size = label_size,
              halign = "center",
              valign = "center"
            );
      }

      for (col = [0 : cols - 1]) {
        p = well_position(0, col);

        translate([p.x, p.y + label_margin, base_z + slab - label_depth])
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
}


// ===== Downward tapered socket module =====

module tapered_tip_socket(x, y, base_z) {
  // Solid tapered sleeve below the removable insert.
  // The guide hole is removed later by the small straight + tapered cutters.
  translate([x, y, base_z - tip_socket_depth])
    cylinder(
      h = tip_socket_depth + z_fight,
      d1 = socket_outer_bottom,
      d2 = socket_outer_top
    );
}


// ===== Snap / locator modules =====

module insert_locator_lip(base_z) {
  // Single original underside locator/snap lip.
  // The second alignment rectangle has been removed.
  // This lip is now thicker and uses small side bumps for a light clip effect.
  difference() {
    translate([0, 0, base_z - snap_lip_height])
      rbox(
        locator_length,
        locator_width,
        snap_lip_height + z_fight,
        snap_lip_width / 2
      );

    translate([0, 0, base_z - snap_lip_height - z_fight])
      rbox(
        locator_length - 2 * snap_lip_width,
        locator_width - 2 * snap_lip_width,
        snap_lip_height + 3 * z_fight,
        snap_lip_width / 2
      );
  }

  // Small snap/friction bumps on the original lip.
  // These create the actual clip effect.
  if (snap_bump_depth > 0) {
    for (sx = [-1, 1]) {
      translate([
        sx * (locator_length / 2 + snap_bump_depth / 2),
        0,
        base_z - snap_lip_height
      ])
        rbox(
          snap_bump_depth,
          snap_bump_length,
          snap_bump_height,
          snap_bump_depth / 2
        );
    }

    for (sy = [-1, 1]) {
      translate([
        0,
        sy * (locator_width / 2 + snap_bump_depth / 2),
        base_z - snap_lip_height
      ])
        rbox(
          snap_bump_length,
          snap_bump_depth,
          snap_bump_height,
          snap_bump_depth / 2
        );
    }
  }
}


// ===== Helper modules/functions =====

function well_position(row, col) =
  [
    -plate_length / 2 + a1_x + col * pitch,
     plate_width / 2 - a1_y - row * pitch,
     0
  ];


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