# Changelog

All notable changes to this project will be documented in this file. Remember to update this file as well as the version comment in `well_plate_pipette_guide.scad` header with each release.

Format based on [Keep a Changelog](https://keepachangelog.com/).

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
