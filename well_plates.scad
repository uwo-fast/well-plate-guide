//
// Well plate standard definitions per ANSI/SLAS 1-4 (2004, R2012)
//
// Each entry is a flat array describing one plate variant.
// Standard grid parameters (rows, cols, pitch, A1 offsets) come from SLAS-4.
// Flange heights come from SLAS-3. Manufacturer-specific fields (well_d,
// well_depth, well_shape, bottom_r) must be measured or sourced from datasheets.
//
//  Index  Field          Unit    Description
//  ─────  ─────────────  ──────  ──────────────────────────────────────────────
//   0     name           —       Human-readable identifier
//   1     rows           —       Number of rows
//   2     cols           —       Number of columns
//   3     pitch          mm      Well-to-well spacing (equal X & Y per SLAS-4)
//   4     a1_x           mm      Left edge to first column center (SLAS-4)
//   5     a1_y           mm      Top edge to first row center (SLAS-4)
//   6     well_d         mm      Well opening diameter (or side length if square)
//   7     well_depth     mm      Well depth from plate top surface
//   8     well_shape     —       "round" or "square"
//   9     bottom_r       mm      Well bottom fillet radius (0 = flat)
//  10     flange_h       mm      Flange height, short sides (from Datum A down)
//  11     flange_h_long  mm      Flange height, long sides (0 = same as [10])
//  12     has_clearance  bool    true = SLAS-2 §4.1 (1mm clearance below wells)
//
// DO NOT APPLY FORMATTERS TO THIS FILE, IT IS MANUALLY LAID OUT FOR READABILITY

//                       [0]            [1]  [2]    [3]    [4]      [5]     [6]      [7]    [8]       [9]    [10]    [11]   [12]
//                       name          rows  cols  pitch   a1_x     a1_y    well_d  depth   shape     bot_r  fl_h   fl_h_l  clr
WP96_FLAT_SHORT   = ["96 flat short",    8,   12,   9.00,  14.38,   11.24,   6.86,  10.67,  "round",   0,    2.41,    0,    true];
WP96_ROUND_MEDIUM = ["96 round medium",  8,   12,   9.00,  14.38,   11.24,   6.86,  10.67,  "round",   3.43, 6.10,    0,    true];
WP384_FLAT_SHORT  = ["384 flat short",   16,   24,  4.50,  12.13,   8.99,    3.63,  11.56,  "round",   0,    2.41,    0,    true];
WP1536_FLAT_SHORT = ["1536 flat short",  32,   48,  2.25,  11.005,  7.865,   1.50,   5.00,  "square",  0,    2.41,    0,    true];

well_plates = [WP96_FLAT_SHORT, WP96_ROUND_MEDIUM, WP384_FLAT_SHORT, WP1536_FLAT_SHORT];

use <well_plate.scad>
