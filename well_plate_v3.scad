// Well-Plate Pipette Guide v0.5.0
// Two-part design: reusable stand + removable guide insert with multi-stage bore.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026
// License: AGPL-3.0 (see LICENSE)

// ===== Global settings =====

$fn = $preview ? 32 : 128;
z_fight = 0.05; // boolean overlap only — not a design dimension

// ===== User parameters =====

render_part = "assembly"; // ["assembly", "stand", "insert"]
plate = "24"; // ["24", "96"]

// --- Bore geometry (multi-stage, bottom to top) ---
tip_guide_diameter = 1.40; // narrow bore at bottom — steadies the tip end
tip_shaft_diameter = 3.60; // wider bore for the tip shaft
tip_entry_diameter = 3.80; // top funnel opening — catches the tip on entry
guide_straight = 2.0; // length of the narrow straight section
shaft_straight = 4.0; // straight shaft bore between guide taper and funnel

// --- Downward socket (extends into the well) ---
socket_depth = 4.0; // how far the socket protrudes below the insert
socket_wall = 1.0; // socket sleeve wall thickness

// --- Clearances ---
fit_clearance = 0.80; // gap between plate and frame walls
shrink_allowance = 0.0; // extra clearance for shrink-prone materials (PP: ~0.35)
snap_clearance = 0.40; // gap between stand pocket and insert lip

// --- Frame / structure ---
wall = 5.0; // guide plate frame wall thickness
support_style = "legs"; // ["legs", "rails"]
support_width = 3.5; // leg or rail cross-section width
leg_arm_length = 18; // L-shaped corner leg arm length
air = 2.5; // gap between plate top and insert underside

// --- Stand receiving frame ---
rim_height = 3.0; // height of the pocket rim the insert drops into

// --- Snap-fit (set snap_bump to 0 for drop-in, >0 for clip) ---
snap_lip_height = 2.0; // locator lip depth below insert
snap_lip_width = 1.8; // locator lip wall thickness
snap_bump = 0.05; // interference beyond snap_clearance (0 = no clip)
snap_bump_length = 10.0; // bump extent along each side
snap_bump_height = 0.8; // bump vertical height

// --- Lift tabs ---
tab_length = 18;
tab_width = 9;
tab_height = 3;

// --- Labels ---
labels = true;
label_depth = 0.5;

module dummy(){} // customizer fence

// ===== Plate specs (SBS/ANSI standard) =====

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
plate_length = 127.76; // SBS/ANSI footprint
plate_width = 85.48;

// ===== Derived dimensions =====

fit = fit_clearance + shrink_allowance;

// Bore diameters (with shrink compensation)
guide_bore = tip_guide_diameter + shrink_allowance;
shaft_bore = tip_shaft_diameter + shrink_allowance;
entry_bore = tip_entry_diameter + shrink_allowance;

// Funnel geometry
funnel_depth = entry_bore / 2; // ~45° entry cone
slab = funnel_depth + shaft_straight; // insert plate thickness

// Socket outer diameters
socket_od_bottom = guide_bore + 2 * socket_wall;
socket_od_top = shaft_bore + 2 * socket_wall;

// Vertical layout
top_z = plate_height + air;
insert_height = slab;

// Envelope
outer_length = plate_length + 2 * (fit + wall);
outer_width = plate_width + 2 * (fit + wall);
inner_length = plate_length + 2 * fit;
inner_width = plate_width + 2 * fit;

// Stand support envelope
support_outer_length = inner_length + 2 * support_width;
support_outer_width = inner_width + 2 * support_width;

// Insert locator lip sits inside the stand pocket
locator_length = inner_length;
locator_width = inner_width;
pocket_length = locator_length + 2 * snap_clearance;
pocket_width = locator_width + 2 * snap_clearance;

// Snap bump total protrusion
bump_depth = snap_clearance + snap_bump;

// ===== Render selector =====

if (render_part == "stand" || render_part == "assembly") {
  stand(
    outer_length,
    outer_width,
    inner_length,
    inner_width,
    support_outer_length,
    support_outer_width,
    top_z,
    wall,
    support_width,
    support_style,
    leg_arm_length,
    rim_height,
    pocket_length,
    pocket_width
  );
}
if (render_part == "insert" || render_part == "assembly") {
  translate([0, 0, render_part == "assembly" ? top_z - socket_depth : 0])
    insert(
      outer_length,
      outer_width,
      wall,
      plate_length,
      plate_width,
      rows,
      cols,
      a1_x,
      a1_y,
      pitch,
      shaft_straight,
      guide_bore,
      shaft_bore,
      entry_bore,
      guide_straight,
      socket_depth,
      socket_wall,
      tab_length,
      tab_width,
      tab_height,
      labels,
      label_depth,
      snap_lip_height,
      snap_lip_width,
      bump_depth,
      snap_bump_length,
      snap_bump_height
    );
}

// ===== Stand module =====

module stand(
  outer_length,
  outer_width,
  inner_length,
  inner_width,
  support_outer_length,
  support_outer_width,
  top_z,
  wall,
  support_width,
  support_style,
  leg_arm_length,
  rim_height,
  pocket_length,
  pocket_width
) {
  union() {
    supports(
      outer_length,
      outer_width,
      inner_length,
      inner_width,
      support_outer_length,
      support_outer_width,
      top_z,
      support_width,
      support_style,
      leg_arm_length
    );
    stand_frame(
      outer_length,
      outer_width,
      pocket_length,
      pocket_width,
      top_z,
      rim_height,
      wall
    );
  }
}

// ===== Insert module =====

module insert(
  outer_length,
  outer_width,
  wall,
  plate_length,
  plate_width,
  rows,
  cols,
  a1_x,
  a1_y,
  pitch,
  shaft_straight,
  guide_bore,
  shaft_bore,
  entry_bore,
  guide_straight,
  socket_depth,
  socket_wall,
  tab_length,
  tab_width,
  tab_height,
  labels,
  label_depth,
  snap_lip_height,
  snap_lip_width,
  bump_depth,
  snap_bump_length,
  snap_bump_height
) {
  // Derived locally
  funnel_depth = entry_bore / 2;
  slab = funnel_depth + shaft_straight;
  base_z = socket_depth;
  locator_length = outer_length - 2 * wall;
  locator_width = outer_width - 2 * wall;
  socket_od_bottom = guide_bore + 2 * socket_wall;
  socket_od_top = shaft_bore + 2 * socket_wall;
  difference() {
    union() {
      // Guide plate body
      translate([0, 0, base_z])
        rbox(outer_length, outer_width, slab, wall / 2);

      // Downward sockets into wells
      for (r = [0:rows - 1], c = [0:cols - 1]) {
        p = well_xy(r, c, plate_length, plate_width, a1_x, a1_y, pitch);
        tip_socket(
          p.x,
          p.y,
          base_z,
          socket_depth,
          socket_od_bottom,
          socket_od_top
        );
      }

      // Locator lip (+ optional snap bumps)
      snap_lip(
        base_z,
        locator_length,
        locator_width,
        snap_lip_height,
        snap_lip_width,
        bump_depth,
        snap_bump_length,
        snap_bump_height
      );

      // Lift tabs
      for (sx = [-1, 1])
        translate([sx * (outer_length / 2), 0, base_z + slab - tab_height])
          rbox(tab_length, tab_width, tab_height, wall / 2);
    }

    // Multi-stage bore at each well
    for (r = [0:rows - 1], c = [0:cols - 1]) {
      p = well_xy(r, c, plate_length, plate_width, a1_x, a1_y, pitch);
      bore_cutout(
        p.x,
        p.y,
        base_z,
        guide_bore,
        shaft_bore,
        entry_bore,
        guide_straight,
        socket_depth,
        shaft_straight
      );
    }

    // Engraved labels
    if (labels) {
      well_labels(
        base_z + slab,
        label_depth,
        rows,
        cols,
        pitch,
        plate_length,
        plate_width,
        a1_x,
        a1_y
      );
    }
  }
}

// ===== Sub-modules =====

module stand_frame(
  outer_length,
  outer_width,
  pocket_length,
  pocket_width,
  top_z,
  rim_height,
  wall
) {
  difference() {
    translate([0, 0, top_z - rim_height])
      rbox(outer_length, outer_width, rim_height + z_fight, wall / 2);
    translate([0, 0, top_z - rim_height - z_fight])
      rbox(pocket_length, pocket_width, rim_height + 3 * z_fight, wall / 2);
  }
}

module supports(
  outer_length,
  outer_width,
  inner_length,
  inner_width,
  support_outer_length,
  support_outer_width,
  top_z,
  support_width,
  support_style,
  leg_arm_length
) {
  if (support_style == "rails") {
    // Side rails — plate slides in from front
    for (sx = [-1, 1])
      translate([sx * (inner_length / 2 + support_width / 2), 0, 0])
        rbox(support_width, support_outer_width, top_z + z_fight, support_width / 2);
    // Back stop
    translate([0, inner_width / 2 + support_width / 2, 0])
      rbox(support_outer_length, support_width, top_z + z_fight, support_width / 2);
  } else {
    // "legs"
    for (sx = [-1, 1], sy = [-1, 1])
      corner_leg(
        sx,
        sy,
        outer_length,
        outer_width,
        support_width,
        leg_arm_length,
        top_z
      );
  }
}

module corner_leg(
  sx,
  sy,
  outer_length,
  outer_width,
  leg_width,
  arm_length,
  height
) {
  arm = min(arm_length, min(outer_length, outer_width) / 2);
  // X arm
  translate([sx * (outer_length / 2 - (arm + leg_width) / 2), sy * (outer_width / 2 - leg_width / 2), 0])
    rbox(arm + leg_width, leg_width, height + z_fight, leg_width / 2);
  // Y arm
  translate([sx * (outer_length / 2 - leg_width / 2), sy * (outer_width / 2 - (arm + leg_width) / 2), 0])
    rbox(leg_width, arm + leg_width, height + z_fight, leg_width / 2);
}

module tip_socket(
  x,
  y,
  base_z,
  socket_depth,
  od_bottom,
  od_top
) {
  translate([x, y, base_z - socket_depth])
    cylinder(h=socket_depth + z_fight, d1=od_bottom, d2=od_top);
}

module bore_cutout(
  x,
  y,
  base_z,
  guide_bore,
  shaft_bore,
  entry_bore,
  guide_straight,
  socket_depth,
  shaft_straight
) {
  funnel_depth = entry_bore / 2;
  slab = funnel_depth + shaft_straight;

  // 1. Narrow guide bore (bottom of socket)
  translate([x, y, base_z - socket_depth - z_fight])
    cylinder(h=guide_straight + 2 * z_fight, d=guide_bore);

  // 2. Taper from guide bore to shaft bore
  taper_start = base_z - socket_depth + guide_straight;
  taper_height = socket_depth + shaft_straight - guide_straight;
  translate([x, y, taper_start - z_fight])
    cylinder(h=taper_height + 2 * z_fight, d1=guide_bore, d2=shaft_bore);

  // 3. Top funnel (shaft bore → entry bore)
  translate([x, y, base_z + slab - funnel_depth])
    cylinder(h=funnel_depth + z_fight, d1=shaft_bore, d2=entry_bore);
}

module snap_lip(
  base_z,
  locator_length,
  locator_width,
  lip_height,
  lip_width,
  bump_depth,
  bump_length,
  bump_height
) {
  // Hollow rectangular lip
  difference() {
    translate([0, 0, base_z - lip_height])
      rbox(locator_length, locator_width, lip_height + z_fight, lip_width / 2);
    translate([0, 0, base_z - lip_height - z_fight])
      rbox(locator_length - 2 * lip_width, locator_width - 2 * lip_width, lip_height + 3 * z_fight, lip_width / 2);
  }

  // Snap bumps (omitted when bump_depth ≤ 0)
  if (bump_depth > 0) {
    for (sx = [-1, 1])
      translate([sx * (locator_length / 2 + bump_depth / 2), 0, base_z - lip_height])
        rbox(bump_depth, bump_length, bump_height, bump_depth / 2);
    for (sy = [-1, 1])
      translate([0, sy * (locator_width / 2 + bump_depth / 2), base_z - lip_height])
        rbox(bump_length, bump_depth, bump_height, bump_depth / 2);
  }
}

module well_labels(
  top_z,
  label_depth,
  rows,
  cols,
  pitch,
  plate_length,
  plate_width,
  a1_x,
  a1_y
) {
  label_size = pitch / 4;
  label_margin = pitch * 2 / 3;

  // Row letters (A, B, C, ...)
  for (r = [0:rows - 1]) {
    p = well_xy(r, 0, plate_length, plate_width, a1_x, a1_y, pitch);
    translate([p.x - label_margin, p.y, top_z - label_depth])
      linear_extrude(label_depth + z_fight)
        text(chr(65 + r), size=label_size, halign="center", valign="center");
  }
  // Column numbers (1, 2, 3, ...)
  for (c = [0:cols - 1]) {
    p = well_xy(0, c, plate_length, plate_width, a1_x, a1_y, pitch);
    translate([p.x, p.y + label_margin, top_z - label_depth])
      linear_extrude(label_depth + z_fight)
        text(str(c + 1), size=label_size, halign="center", valign="center");
  }
}

// ===== Helpers =====

function well_xy(
  row,
  col,
  plate_length,
  plate_width,
  a1_x,
  a1_y,
  pitch
) =
  [
    -plate_length / 2 + a1_x + col * pitch,
    plate_width / 2 - a1_y - row * pitch,
    0,
  ];

module rbox(length, width, height, radius) {
  // Rounded-corner box: cube minus corners + corner cylinders.
  // More efficient than hull() of 4 cylinders.
  translate([0, 0, height / 2])
    union() {
      difference() {
        cube([length, width, height], center=true);
        for (i = [-1, 1], j = [-1, 1])
          translate([i * length / 2, j * width / 2, 0])
            cube([2 * radius, 2 * radius, height + 0.1], center=true);
      }
      for (i = [-1, 1], j = [-1, 1])
        translate([i * (length / 2 - radius), j * (width / 2 - radius), 0])
          cylinder(h=height, r=radius, center=true);
    }
}
