# Changelog

All notable changes to this project will be documented in this file. Remember to update this file as well as the version comment in `well_plate_pipette_guide.scad` header with each release.

Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-06-08

### Added

* Expanded supported well plate definitions in `well_plates.scad`.
* Added support for additional plate formats:

  * `WP24_CYTOVIEW_MEA`
  * `WP96_FLAT_SHORT`
  * `WP96_ROUND_MEDIUM`
  * `WP384_FLAT_SHORT`
  * `WP1536_FLAT_SHORT`
* Added `well_plates` list containing all currently supported plate definitions.
* Added support for smaller high-density plate formats, including 384-well and 1536-well layouts.
* Added square-well plate support through the `shape` field for `WP1536_FLAT_SHORT`.
* Added documentation for the full plate definition array format:

  * name
  * rows
  * columns
  * pitch
  * A1 x-position
  * A1 y-position
  * well diameter
  * well depth
  * well shape
  * bottom radius
  * flange height
  * lid flange height
  * clearance flag
* Added README section listing supported plate definitions in a table.
* Added README documentation for guide hole design, including top and bottom guide diameters.
* Added README notes explaining that dense plates such as 384-well and 1536-well formats may require smaller guide holes.
* Added README notes explaining that interstitial features may be less practical on dense plate formats.
* Added recommended workflow section to the README.
* Added file organization section to the README.
* Added rendering notes for slower OpenSCAD models and online renderers.
* Added design notes emphasizing parametric edits instead of duplicated model files.
* Added tip checker documentation for testing pipette tip fit before printing the full guide.
* Added tapered tip checker concept where top diameter and bottom diameter can be tested independently.
* Added grid-style tip checker concept where top diameter changes across columns and bottom diameter changes down rows.

### Changed

* README now describes the project as supporting multiple well plate definitions, not only 24-well and 96-well plates.
* README wording updated to better explain the project purpose, especially for repeated pipetting and organoid workflows.
* Documentation now explains that plate geometry is separated from guide geometry so new plate types can be added more easily.
* Guide documentation now describes tapered guide holes as larger at the top and smaller at the bottom.
* Documentation now recommends printing a tip checker before printing the full guide.
* Documentation now recommends testing the full guide on an empty well plate before using it with samples.
* Plate support documentation updated to match the current `well_plates.scad` structure.

## [0.4.0] - 2026-05-16

### Added

- Version comment in `well_plate_pipette_guide.scad` header (update on each release).
- `support_style` parameter: choose `"collar"` (registration skirt) or `"posts"` (freestanding corner posts).
- `shrink_allowance` parameter for shrink-prone materials (e.g. PP at ~0.35).
- PP printing tips section in README.

### Changed

- Labels are now engraved (cut into surface) instead of embossed (raised). Replaces `emboss` with `label_depth`.
- All user-tunable parameters moved above the customizer dummy module.

### Removed

- Test files (`test.scad`, `diameter_test.scad`, `Pp_test.scad`) archived; their ideas consolidated into main file.

## [0.3.0] - 2026-05-15

### Added

- Experimental test files by Hadden Christ exploring collarless posts, PP clearances, and V-holder funnel concept.

### Changed

- Default plate changed from `"96"` to `"24"`.

## [0.2.0] - 2026-05-14

### Changed

- All variables renamed to be descriptive and non-cryptic.
- Magic numbers replaced with named parameters and derived values.
- Non-ASCII characters removed.
- Old versioned scripts (`v0`, `v1`, `v2`) cleaned up; single main file `well_plate_pipette_guide.scad` on root.
- Hadden's original 24-well and 96-well drafts moved to `archive/`.
- Code formatting applied.

### Added

- Global settings (`$fn`, `z_fight`).
- Attribution strings.
- `module dummy(){}` customizer fence.

## [0.1.0] - 2026-05-14

### Added

- Initial combined 24/96-well pipette guide with parametric plate selection.
- Registration collar, corner posts, guide plate, lift tabs.
- Embossed row/column labels.
- Rounded-box helper module.

## [0.0.1] - 2026-05-14

### Added

- Repository created with LICENSE and README.
- Initial drafts from Hadden (separate 24-well and 96-well scripts).
- Cam's first improved combined versions (`v0`, `v1`).
