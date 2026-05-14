// Well-Plate Pipette Guide
// Sits on a well plate; funneled holes guide pipette tips into each well.
// Units: mm
// By Cameron Brooks and Hadden Christ, May 2026

// ===== Global settings =====

$fn = $preview ? 32 : 128; // facets for curves; fewer in preview for speed
z_fight = $preview ? 0.05 : 0.0; // coplanar-face offset; avoids Z-fighting in preview

// ===== Parameters =====

plate = "96"; // "24" or "96"
tip_d = 1.20; // pipette tip OD at guide bore -- measure your tips
tip_clr = 0.15; // tip bore clearance
fit_clr = 0.80; // plate fit clearance -- loosen if jig is too snug
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
a1x = spec[2];
a1y = spec[3];
pitch = spec[4];
ph = spec[5];
pl = 127.76;
pw = 85.48;

// ===== Derived =====

bore = tip_d + tip_clr;
funnel = pitch * 3 / 5; // 60% of pitch -- clears neighbors
fdepth = funnel / 2; // ~45 deg entry cone
straight = 4; // straight bore below funnel
slab = fdepth + straight; // guide plate thickness
top_z = ph + air;
ht = top_z + slab;

ol = pl + 2 * (fit_clr + wall); // outer envelope
ow = pw + 2 * (fit_clr + wall);
il = pl + 2 * fit_clr; // inner cavity
iw = pw + 2 * fit_clr;

tab_l = 18; // lift tab length
tab_w = 9; // lift tab width
tab_h = 3; // lift tab height
emboss = 0.3; // label extrusion height

// ===== Model =====

difference() {
  union() {
    // Registration collar
    difference() {
      rbox(ol, ow, collar, wall / 2);
      translate([0, 0, -z_fight])
        rbox(il, iw, collar + 2 * z_fight, wall);
    }

    // Corner posts
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx * (il / 2 + wall / 2), sy * (iw / 2 + wall / 2), collar])
        cylinder(d=wall, h=top_z - collar);

    // Guide plate
    translate([0, 0, top_z])
      rbox(ol, ow, slab, wall / 2);

    // Lift tabs
    for (sx = [-1, 1])
      translate([sx * (ol / 2), 0, ht - tab_h])
        rbox(tab_l, tab_w, tab_h, wall / 2);
  }

  // Bore + funnel at each well
  for (r = [0:rows - 1], c = [0:cols - 1]) {
    p = wpos(r, c);
    translate([p.x, p.y, top_z - z_fight])
      cylinder(h=slab + 2 * z_fight, d=bore);
    translate([p.x, p.y, ht - fdepth])
      cylinder(h=fdepth + z_fight, d1=bore, d2=funnel);
  }
}

// Labels
if (labels) {
  lsz = pitch / 4; // 1/4 pitch
  lmg = pitch * 2 / 3; // 2/3 pitch from well center
  color("black") {
    for (r = [0:rows - 1]) {
      p = wpos(r, 0);
      translate([p.x - lmg, p.y, ht])
        linear_extrude(emboss)
          text(chr(65 + r), size=lsz, halign="center", valign="center");
    }
    for (c = [0:cols - 1]) {
      p = wpos(0, c);
      translate([p.x, p.y + lmg, ht])
        linear_extrude(emboss)
          text(str(c + 1), size=lsz, halign="center", valign="center");
    }
  }
}

// ===== Helpers =====

function wpos(r, c) =
  [
    -pl / 2 + a1x + c * pitch,
    pw / 2 - a1y - r * pitch,
    0,
  ];

module rbox(l, w, h, r) {
  hull()for (x = [-l / 2 + r, l / 2 - r], y = [-w / 2 + r, w / 2 - r])
    translate([x, y, 0])
      cylinder(h=h, r=r);
}
