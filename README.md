# well-plate-guide

A parametric, 3D-printable pipette guide for laboratory well plates, written in
OpenSCAD. It sits over a standard plate and steers the pipette tip into the centre of
each well, through a tapered hole and a short cone that reaches into the well. That
keeps the tip off the well wall and the sample, which matters for delicate work such
as organoid culture.

By Cameron Brooks and Hadden Christ, 2026. The guide has been printed and used with
24- and 96-well plates.

## Parts

`pipette_guide.scad` draws three parts around one plate definition:

- **Stand**: a frame that sits around the well plate, with arched cut-outs in all
  four sides.
- **Guide**: the plate the pipette goes through, which sits on the stand. Each well
  gets a tapered hole, wider at the top, inside a cone that enters the well. Under
  the guide, a lip with small snap bumps locates it in the stand. Lift tabs on the
  ends make it easy to take off, and row letters and column numbers are engraved in
  the top.
- **Base** (optional): a tray the stand nests in, with a hole under each well.

With `guide_interstitial_protrusions = true` (the default), the guide also has solid
cones, with no hole, between each group of four wells. They press on the plate to
hold it down.

## Plates

The plate definitions are in `well_plates.scad`. `plate_selection` picks one:

| `plate_selection` | Plate | Wells | Pitch | Well diameter | Default guide fits |
| --- | --- | --- | --- | --- | --- |
| 0 | 24 CytoView MEA | 4 x 6 | 18.00 mm | 15.00 mm | yes |
| 1 | 96 flat short | 8 x 12 | 9.00 mm | 6.86 mm | yes |
| 2 | 96 round medium | 8 x 12 | 9.00 mm | 6.86 mm | yes |
| 3 | 384 flat short | 16 x 24 | 4.50 mm | 3.63 mm | no |
| 4 | 1536 flat short | 32 x 48 | 2.25 mm | 1.50 mm (square) | no |

The default holes and cones are sized for the 24- and 96-well plates. On the 384- and
1536-well plates, the cones (5.97 mm across where they enter a well) are wider than
the wells, and the render stops with a message naming the parameter to change. A
guide for those plates needs smaller holes and cones, which nobody has designed or
printed yet.

A plate definition is one array. The comment block in `well_plates.scad` lists each
field: rows, columns, pitch, the A1 offsets, well diameter, depth and shape, bottom
radius and flange heights. The grid and the outer dimensions follow the ANSI/SLAS
microplate standards, cited in [`references/`](references/README.md). The well
dimensions come from the plate maker's datasheet. To add a plate, add an array in
the same format to `well_plates.scad` and to the `well_plates` list, and add it to the
`plate_selection` options in `pipette_guide.scad`.

## Parameters

The main ones, at the top of `pipette_guide.scad`, with their defaults:

| Parameter | Default | What it sets |
| --- | --- | --- |
| `render_part` | `"assembly"` | `"assembly"`, `"stand"`, `"guide"` or `"base"` |
| `render_well_plate` | `true` | draws a transparent reference plate |
| `view_cross_section` | `false` | cuts the view in half to show the holes |
| `plate_selection` | `0` | the plate, from the table above |
| `tip_diameter` | 3.6 mm | the top of each guide hole |
| `bottom_hole_diameter` | 2.6 mm | the bottom of each guide hole |
| `protrusion_extension` | 3 mm | how far the cones reach into the wells |
| `protrusion_top_radius` | `tip_diameter` | the cone's outside radius at the guide |
| `protrusion_taper_angle` | 5.5 deg | how much the cone narrows towards its tip |
| `guide_interstitial_protrusions` | `true` | the solid cones between wells |
| `fit_clearance` | 0.2 mm | clearance between the plate, stand and guide |
| `label_depth` | 0.5 mm | how deep the labels are engraved |

To print, set `render_part` to one part at a time and turn `render_well_plate` off.

## Tip checker

`tip_checker.scad` is a small test plate for finding the hole size that suits your
tips before printing a whole guide. It has an 11 x 11 grid of tapered holes: the top
diameter steps from 6.0 to 8.0 mm across the columns, and the bottom diameter from
4.0 to 6.0 mm down the rows, both by 0.2 mm. Both are engraved on the plate. These are
the same quantities as the guide's `tip_diameter` and `bottom_hole_diameter`, so the
numbers of the hole that fits go straight into the guide.

The checker's range does not include the guide's defaults (3.6 and 2.6 mm). To test
around other sizes, edit `top_diameters` and `bottom_diameters` at the top of the file.

## Workflow

1. Print the tip checker and try your pipette tips in it.
2. Set `tip_diameter` and `bottom_hole_diameter` to the hole that fits best.
3. Set `plate_selection` to your plate.
4. Render and export the stand, the guide and, if you want it, the base, one at a
   time.
5. Print them, and try the guide on an empty plate before using it with samples. It
   should sit flat, and the tip should pass through without force.

## Rendering

Render with the Manifold backend (`openscad --backend=Manifold`, or the Manifold
option in OpenSCAD's preferences). Each part of the 24- and 96-well guides rendered in
2 s or less with OpenSCAD 2026.10.15.

## Files

| File | Contents |
| --- | --- |
| `pipette_guide.scad` | the stand, guide and base, and their parameters |
| `well_plates.scad` | the plate definitions |
| `well_plate.scad` | a model of a standard plate, drawn from a definition |
| `tip_checker.scad` | the hole-size test plate |
| `utils.scad` | `cross_section()`, used for the cross-section view |
| `references/` | the ANSI/SLAS standards the plate geometry follows |
| `CHANGELOG.md` | changes by version |

## Licence

GNU Affero General Public License v3.0. See [`LICENSE`](LICENSE).
