// Well-Plate Pipette Guide v0.4.0
// Split version: removable tapered guide insert + separate stand.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026
// License: AGPL-3.0 (see LICENSE)


// ===== Global settings =====

$fn = $preview ? 32 : 128;

// Keep this nonzero even during full render.
// This is only boolean overlap, not a real design dimension.
z_fight = 0.05;


// ===== User parameters =====

render_part = "stand"; // ["assembly", "stand", "insert", "both"]

plate = "24"; // "24" or "96"


// ===== Pipette hole / taper controls =====

tip_top_diameter = 3.60;
tip_guide_diameter = 1.40;
funnel_top_diameter = 3.80;

tip_socket_depth = 4.0;
tip_socket_wall = 1.0;
tip_guide_height = 2.0;


// ===== Fit / support controls =====

fit_clearance = 0.80;
slide_clearance = 0.45;
shrink_allowance = 0.0;

wall = 10.0;            // top frame wall thickness
support_width = 10.0;   // bottom slide rail / corner leg width

support_style = "corner_legs"; // ["corner_legs", "slide"]

air = 2.5;
labels = true;

straight = 4;

tab_length = 18;
tab_width = 9;
tab_height = 3;

label_depth = 0.5;


// ===== Corner-leg support controls =====

corner_leg_length = 18;
corner_leg_width = support_width;
corner_leg_height = -1;


// ===== Snap-fit / removable insert controls =====

stand_rim_height = 3.0;
snap_lip_height = 2.0;
snap_lip_width = 2.4;   // doubled from 1.2 mm

// Bottom snap/lip allowance
snap_clearance = 1.50;

snap_bump_depth = 0.0;
snap_bump_length = 10;
snap_bump_height = 0.8;

separation_spacing = 25;


// ===== Plate specs =====

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

tip_guide_bore = tip_guide_diameter + shrink_allowance;
bore = tip_top_diameter + shrink_allowance;
funnel = funnel_top_diameter + shrink_allowance;

socket_outer_bottom = tip_guide_bore + 2 * tip_socket_wall;
socket_outer_top = bore + 2 * tip_socket_wall;

funnel_depth = funnel / 2;
slab = funnel_depth + straight;

top_z = plate_height + air;
height = top_z + slab;

outer_length = plate_length + 2 * (fit + wall);
outer_width = plate_width + 2 * (fit + wall);

inner_length = plate_length + 2 * fit;
inner_width = plate_width + 2 * fit;

support_outer_length = inner_length + 2 * support_width;
support_outer_width = inner_width + 2 * support_width;

insert_length = outer_length;
insert_width = outer_width;

locator_length = inner_length;
locator_width = inner_width;

stand_opening_length = locator_length + 2 * snap_clearance;
stand_opening_width = locator_width + 2 * snap_clearance;


// ===== Main model selector =====

if (render_part == "assembly") {
  stand_part();
  guide_insert_part(top_z);

} else if (render_part == "stand") {
  stand_part();

} else if (render_part == "insert") {
  guide_insert_part(0);

} else if (render_part == "both") {
  translate([-(outer_length + separation_spacing) / 2, 0, 0])
    stand_part();

  translate([(outer_length + separation_spacing) / 2, 0, 0])
    guide_insert_part(0);
}


// ===== Separate printable parts =====

module stand_part() {
  union() {
    supports();
    stand_receiving_frame();
  }
}


module guide_insert_part(base_z) {
  difference() {
    union() {
      translate([0, 0, base_z])
        rbox(insert_length, insert_width, slab, wall / 2);

      for (row = [0 : rows - 1], col = [0 : cols - 1]) {
        p = well_position(row, col);
        tapered_tip_socket(p.x, p.y, base_z);
      }

      insert_locator_lip(base_z);

      for (sx = [-1, 1]) {
        translate([sx * (insert_length / 2), 0, base_z + slab - tab_height])
          rbox(tab_length, tab_width, tab_height, wall / 2);
      }
    }

    for (row = [0 : rows - 1], col = [0 : cols - 1]) {
      p = well_position(row, col);

      translate([p.x, p.y, base_z - tip_socket_depth - z_fight])
        cylinder(
          h = tip_guide_height + 2 * z_fight,
          d = tip_guide_bore
        );

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

      funnel_extra_d = (funnel - bore) * z_fight / funnel_depth;

      translate([p.x, p.y, base_z + slab - funnel_depth])
        cylinder(
          h = funnel_depth + z_fight,
          d1 = bore,
          d2 = funnel + funnel_extra_d
        );
    }

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
  translate([x, y, base_z - tip_socket_depth])
    cylinder(
      h = tip_socket_depth + z_fight,
      d1 = socket_outer_bottom,
      d2 = socket_outer_top
    );
}


// ===== Stand / snap modules =====

module stand_receiving_frame() {
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


module insert_locator_lip(base_z) {
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


// ===== Support styles =====

module supports() {
  if (support_style == "slide") {
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


// ===== Helper modules/functions =====

module corner_leg(sx, sy) {
  leg_w = max(corner_leg_width, 0.1);
  leg_h = (corner_leg_height > 0) ? corner_leg_height : top_z + z_fight;

  arm = min(corner_leg_length, min(inner_length, inner_width) / 2);

  // X-direction arm: outer face flush with outside stand edge
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

  // Y-direction arm: outer face flush with outside stand edge
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


function well_position(row, col) =
  [
    -plate_length / 2 + a1_x + col * pitch,
     plate_width / 2 - a1_y - row * pitch,
     0
  ];


module rbox(length, width, height, radius) {
  translate([0, 0, height / 2]) {
    union() {
      difference() {
        cube([length, width, height], center = true);

        for (i = [-1, 1], j = [-1, 1]) {
          translate([length / 2 * i, width / 2 * j, 0])
            cube([2 * radius, 2 * radius, height * 2], center = true);
        }
      }

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