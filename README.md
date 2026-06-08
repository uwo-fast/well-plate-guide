# well-plate-guide

Well plate guide made in OpenSCAD.

This project contains a parametric 3D-printable pipette guide for laboratory well plates. The guide is designed to help users align pipette tips more consistently over each well, especially during repeated pipetting workflows where accuracy and repeatability matter.

The model is written in OpenSCAD so that the guide can be adjusted by changing parameters instead of redrawing the part. Plate type, guide hole size, taper, support style, shrink allowance, labels, and optional interstitial positions can all be changed in the code.

## Project Purpose

The main purpose of this guide is to improve pipette tip alignment over well plates. When working by hand, especially with small wells or sensitive samples, it can be difficult to keep the pipette tip centered and at a consistent angle. This can lead to inconsistent liquid delivery, accidental contact with the well wall, or disturbance of the sample.

The guide provides a physical template that sits above the well plate and directs the pipette tip through tapered openings. The top of each guide hole is wider to make tip insertion easier, while the bottom is narrower to help center the tip before it reaches the well area.

This is especially useful for workflows involving delicate biological samples such as organoids, where consistent pipetting position and controlled handling are important.

## Main Features

* Parametric OpenSCAD design
* Supports multiple well plate layouts
* Adjustable top and bottom guide diameters
* Tapered pipette guide openings
* Optional interstitial guide holes
* Adjustable shrink allowance for different materials
* Support style options such as posts or collar-style supports
* Lift tabs for easier removal
* Optional engraved labels
* Cross-section view option for checking internal geometry
* Separate tip checker models for testing hole sizes before printing the full guide

## Supported Plate Definitions

The project is not limited to only 96-well and 24-well plates. The guide can use any plate definition included in `well_plates.scad`.

Current supported plate definitions include:

| Plate variable      |      Plate name | Rows | Columns |    Pitch |
| ------------------- | --------------: | ---: | ------: | -------: |
| `WP24_CYTOVIEW_MEA` | 24 CytoView MEA |    4 |       6 | 18.00 mm |
| `WP96_FLAT_SHORT`   |   96 flat short |    8 |      12 |  9.00 mm |
| `WP96_ROUND_MEDIUM` | 96 round medium |    8 |      12 |  9.00 mm |
| `WP384_FLAT_SHORT`  |  384 flat short |   16 |      24 |  4.50 mm |
| `WP1536_FLAT_SHORT` | 1536 flat short |   32 |      48 |  2.25 mm |

Example plate definition list:

```scad
//                       [0]            [1]  [2]    [3]    [4]      [5]     [6]      [7]    [8]       [9]    [10]    [11]   [12]
//                       name          rows  cols  pitch   a1_x     a1_y    well_d  depth   shape     bot_r  fl_h   fl_h_l  clr
WP24_CYTOVIEW_MEA = ["24 CytoView MEA",  4,    6,  18.00,  18.83,   15.69,  15.00,  13.20,  "round",   0,    2.41,    0,    true];
WP96_FLAT_SHORT   = ["96 flat short",    8,   12,   9.00,  14.38,   11.24,   6.86,  10.67,  "round",   0,    2.41,    0,    true];
WP96_ROUND_MEDIUM = ["96 round medium",  8,   12,   9.00,  14.38,   11.24,   6.86,  10.67,  "round",   3.43, 6.10,    0,    true];
WP384_FLAT_SHORT  = ["384 flat short",   16,  24,   4.50,  12.13,   8.99,    3.63,  11.56,  "round",   0,    2.41,    0,    true];
WP1536_FLAT_SHORT = ["1536 flat short",  32,  48,   2.25,  11.005,  7.865,   1.50,   5.00,  "square",  0,    2.41,    0,    true];

well_plates = [
    WP24_CYTOVIEW_MEA,
    WP96_FLAT_SHORT,
    WP96_ROUND_MEDIUM,
    WP384_FLAT_SHORT,
    WP1536_FLAT_SHORT
];

use <well_plate.scad>

// Example usage:
// well_plate(WP96_FLAT_SHORT);
```

Because the guide is parametric, additional plate types can be added by creating another plate definition using the same array format.

## Guide Hole Design

The guide holes are tapered from a larger top opening to a smaller bottom opening. One commonly used setup is:

```scad
top_diameter = 3.6;
bottom_diameter = 2.6;
```

The larger top diameter makes it easier to place the pipette tip into the guide. The smaller bottom diameter helps center the pipette tip before it reaches the well. This tapered shape is preferred over a simple straight cylindrical hole because it guides the pipette tip smoothly instead of only acting as a loose pass-through hole.

The bottom diameter can be adjusted depending on the pipette tips being used. If the fit is too tight, increase the bottom diameter slightly. If the fit is too loose or does not center the tip well enough, decrease the bottom diameter.

For very dense plates, such as 384-well and 1536-well formats, the guide hole size may need to be reduced because the well spacing is much smaller. Always check the pitch and well diameter before printing.

## Interstitial Holes

Interstitial holes are optional guide holes placed between the main well locations. These are useful when the user wants access between wells or wants to test alternative pipetting positions.

Example setting:

```scad
guide_interstitial_protrusions = true;
```

Set this to `false` if only the normal well-centered guide holes are needed.

Interstitial layouts are more practical on plates with larger spacing. On dense plates such as 384-well or 1536-well plates, interstitial features may become too small or too close together to print reliably.

## Tip Checker

A separate tip checker model is included to help test pipette tip fit before printing the full guide. This is important because printed holes are often slightly smaller than the modelled hole size due to printer tolerances, material shrinkage, slicer settings, and cooling behavior.

The tip checker can be printed as a small rectangular or square test piece with multiple hole sizes. One version tests a range of hole diameters from 3.0 mm to 4.0 mm in 0.1 mm increments. Another version uses a grid where the top diameter changes across the columns and the bottom diameter changes down the rows.

This allows the user to physically test which hole size works best with their specific pipette tips before committing to a full well plate guide print.

## Recommended Workflow

1. Print the tip checker first.
2. Test the pipette tips in the different holes.
3. Choose the best top and bottom diameter.
4. Update the guide parameters in OpenSCAD.
5. Select the correct plate definition.
6. Render only the selected guide version.
7. Export the STL.
8. Print the full guide.
9. Test the guide on an empty well plate before using it with samples.

Printing the tip checker first saves time and material because it helps avoid printing a full guide with holes that are too tight or too loose.

## Important Parameters

Some of the main parameters to adjust are:

```scad
plate = "96";                 // Selects the well plate type
support_style = "posts";      // Options may include "posts" or "collar"
top_diameter = 3.6;           // Top opening of the pipette guide hole
bottom_diameter = 2.6;        // Bottom opening of the pipette guide hole
shrink_allowance = 0.2;       // Clearance added for material shrinkage
label_depth = 0.3;            // Engraving depth for labels
```

These values can be changed depending on the selected plate, pipette tips, and printing material.

## Printing with Polypropylene (PP)

PP shrinks and warps more than PETG, so increase `shrink_allowance` (e.g. `0.35`) to loosen clearances.

* Use a brim or raft if corners lift.
* Use low cooling fan.
* Use a PP-compatible bed surface or adhesive.
* Print in PETG first if possible to confirm geometry before printing PP.

## General Printing Notes

The guide should be printed with enough wall thickness around each hole so the part remains strong. Smaller layer heights may improve the smoothness of the tapered guide holes. If the guide holes are rough, tight, or inconsistent, check the printer calibration and consider increasing the clearance slightly.

Before using the guide with real samples, test it on an empty well plate. Make sure the guide sits flat, does not rock, and does not interfere with the wells. The pipette tip should enter the top opening easily and pass through the taper without needing excessive force.

For organoid work or other delicate biological workflows, make sure the guide does not force the pipette tip too deep into the well. The guide should help with alignment while still allowing the user to control the final pipetting height.

## File Organization

The project is organized into separate OpenSCAD files so the geometry is easier to manage and update.

Typical files include:

```text
pipette_guide.scad    Main guide model and render options
well_plate.scad       Well plate geometry logic
well_plates.scad      Plate dimension definitions
utils.scad            Helper modules such as rounded boxes and cross-section tools
tip_checker.scad      Hole-size test print
```

This structure keeps the model easier to maintain. Plate definitions can be updated separately from the guide geometry, and utility functions can be reused across the project.

## Rendering Notes

Large well plate guides can be slow to render in OpenSCAD, especially when using many holes, rounded geometry, labels, or interstitial features. If rendering online, it may be easier to use a simplified standalone version of the code or render one part at a time.

Useful strategies:

* Render only the selected plate version.
* Turn off features that are not needed.
* Use a cross-section view to inspect the hole shape before rendering the full model.
* Test with a smaller model before rendering the full plate.
* Use the tip checker before printing the full guide.

## Design Notes

The design should stay parametric whenever possible. Instead of copying the entire model to make a small change, add or update parameters so the design can be reused. This makes the project easier to edit and reduces the chance of creating mismatched versions.

For example, hole dimensions should be controlled with top and bottom diameter parameters instead of hardcoded cylinder sizes throughout the file. Plate selection should also be controlled through a plate variable rather than separate duplicated models.

## Summary

The `well-plate-guide` project is a customizable OpenSCAD pipette guide for improving pipette alignment over laboratory well plates. It supports multiple well plate formats, adjustable tapered holes, optional interstitial guide positions, and material shrinkage compensation.

The project is intended to be practical, printable, and easy to modify. Users should print a tip checker first, choose the best hole dimensions, select the correct plate definition, adjust the OpenSCAD parameters, and then print the final guide for their specific well plate and pipette tips.

