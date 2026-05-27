// Square Tip Checker Calibration Plate
// Top axis = top hole radius
// Left axis = bottom hole radius
//
// IMPORTANT:
// In OpenSCAD cylinder():
//   r1 = bottom radius
//   r2 = top radius
//
// This checker cuts each tapered hole from bottom to top:
//   bottom radius = bottom_radii[row]
//   top radius    = top_radii[column]
//
// For organoid work, this uses wider/gentler ranges.
// Units: mm

$fn = $preview ? 20 : 24;
z_fight = 0.05;

// ═══════════════════════════════════════════════════════════════════════════════
// Radius values
// ═══════════════════════════════════════════════════════════════════════════════





// Across the top: top radius values.
// These are larger so the pipette/tip enters easily.
top_radii =    [3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0];

// Down the left: bottom radius values.
// These are smaller so the bottom centers/guides the tip.
bottom_radii = [2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0];

assert(len(top_radii) == len(bottom_radii),
  "top_radii and bottom_radii must have the same length for a square checker.");

// ═══════════════════════════════════════════════════════════════════════════════
// Main dimensions
// ═══════════════════════════════════════════════════════════════════════════════

spacing = 11;              // spacing between holes
plate_margin = 14;         // border around the grid
plate_thickness = 4;

protrusion_extension = 3;  // amount protruding below the plate
protrusion_height = plate_thickness + protrusion_extension;

// Outside protrusion shape
outside_top_radius = 4.2;
outside_bottom_min_radius = 3.0;
min_wall = 0.8;

corner_radius = 4;

// Labels
show_labels = true;
label_size = 2.3;
axis_label_size = 4;
label_depth = 0.35;

// Grid lines
show_grid = true;
grid_line_width = 0.45;
grid_line_depth = 0.25;

// ═══════════════════════════════════════════════════════════════════════════════
// Derived values
// ═══════════════════════════════════════════════════════════════════════════════

n = len(top_radii);

grid_span = (n - 1) * spacing;
plate_side = grid_span + 2 * plate_margin;

column_shift_right = 2.5; // increase to move columns right
x0 = -grid_span / 2 + column_shift_right;

row_shift_down = 2.5; // increase this to move holes downward
y0 = grid_span / 2 - row_shift_down;;

// ═══════════════════════════════════════════════════════════════════════════════
// Render
// ═══════════════════════════════════════════════════════════════════════════════

tip_checker_square();

// ═══════════════════════════════════════════════════════════════════════════════
// Main checker module
// ═══════════════════════════════════════════════════════════════════════════════

module tip_checker_square() {
  difference() {
    union() {
      // Main square plate
      rbox(plate_side, plate_side, plate_thickness, corner_radius);

      // Solid outside protrusions under each hole
      for (r = [0:n - 1], c = [0:n - 1]) {
        bottom_r = bottom_radii[r];

        safe_outside_bottom_r = max(
          outside_bottom_min_radius,
          bottom_r + min_wall
        );

        translate(test_xy(r, c) + [0, 0, -protrusion_extension])
          cylinder(
            h = protrusion_height,

            // Outside protrusion also tapers upward:
            // smaller at bottom, larger at top
            r1 = safe_outside_bottom_r,
            r2 = outside_top_radius
          );
      }
    }

    // Tapered holes through each protrusion
    for (r = [0:n - 1], c = [0:n - 1]) {
      top_r = top_radii[c];
      bottom_r = bottom_radii[r];

      translate(test_xy(r, c) + [0, 0, -protrusion_extension - z_fight / 2])
        cylinder(
          h = protrusion_height + z_fight,

          // THIS IS THE IMPORTANT PART:
          // r1 is the radius at the bottom of the hole.
          // r2 is the radius at the top of the hole.
          r1 = bottom_r,
          r2 = top_r
        );
    }

    if (show_labels)
      labels();

    if (show_grid)
      grid_lines();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Labels
// ═══════════════════════════════════════════════════════════════════════════════

module labels() {
  // One top axis label
  translate([0, plate_side / 2 - 4, plate_thickness - label_depth])
    linear_extrude(label_depth + z_fight)
      text(
        "Top Radius",
        size = axis_label_size,
        halign = "center",
        valign = "center"
      );

  // One left axis label
  translate([-plate_side / 2 + 4, 0, plate_thickness - label_depth])
    rotate([0, 0, 90])
      linear_extrude(label_depth + z_fight)
        text(
          "Bottom Radius",
          size = axis_label_size,
          halign = "center",
          valign = "center"
        );

  // Top numbers = top radius values
  for (c = [0:n - 1]) {
    p = test_xy(0, c);

    translate([p[0], plate_side / 2 - 9, plate_thickness - label_depth])
      linear_extrude(label_depth + z_fight)
        text(
          str(top_radii[c]),
          size = label_size,
          halign = "center",
          valign = "center"
        );
  }

  // Left numbers = bottom radius values
  for (r = [0:n - 1]) {
    p = test_xy(r, 0);

    translate([-plate_side / 2 + 9, p[1], plate_thickness - label_depth])
      rotate([0, 0, 90])
        linear_extrude(label_depth + z_fight)
          text(
            str(bottom_radii[r]),
            size = label_size,
            halign = "center",
            valign = "center"
          );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Grid lines
// ═══════════════════════════════════════════════════════════════════════════════

module grid_lines() {
  line_length = grid_span + spacing * 0.55;

  // Vertical grid lines between columns
  for (c = [0:n - 2]) {
    x = x0 + c * spacing + spacing / 2;

    translate([x, 0, plate_thickness - grid_line_depth])
      cube(
        [grid_line_width, line_length, grid_line_depth + z_fight],
        center = true
      );
  }

  // Horizontal grid lines between rows
  for (r = [0:n - 2]) {
    y = y0 - r * spacing - spacing / 2;

    translate([0, y, plate_thickness - grid_line_depth])
      cube(
        [line_length, grid_line_width, grid_line_depth + z_fight],
        center = true
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════════

function test_xy(row, col) =
  [
    x0 + col * spacing,
    y0 - row * spacing,
    0
  ];

// Rounded rectangle box.
// Base is at Z = 0.
// Avoids hull().
module rbox(length, width, height, radius, center = true) {
  r = min(radius, min(length, width) / 2 - 0.01);

  translate(center ? [0, 0, 0] : [length / 2, width / 2, 0])
    linear_extrude(height)
      offset(r = r)
        square([length - 2 * r, width - 2 * r], center = true);
}