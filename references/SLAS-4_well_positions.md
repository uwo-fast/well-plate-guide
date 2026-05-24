# ANSI SLAS 4-2004 (R2012) — Well Positions

Source: `ANSI_SLAS_4-2004_WellPositions.pdf`

## Overview

Defines well center positions for 96, 384, and 1536 well plates.
Origin is top-left corner; measured from outside edges per SLAS-1 datum zones.

## Well position summary

| Parameter | 96-well | 384-well | 1536-well |
|-----------|---------|----------|-----------|
| Layout | 8 rows × 12 cols | 16 rows × 24 cols | 32 rows × 48 cols |
| A1 col offset (from left edge) | 14.38 mm | 12.13 mm | 11.005 mm |
| A1 row offset (from top edge) | 11.24 mm | 8.99 mm | 7.865 mm |
| Column pitch | 9.00 mm | 4.50 mm | 2.25 mm |
| Row pitch | 9.00 mm | 4.50 mm | 2.25 mm |
| Positional tolerance (⌀) | 0.70 mm | 0.70 mm | 0.50 mm |

## Edge reference

- Left and top edges defined by the two 12.7 mm areas measured from each corner (per SLAS-1).

## Derived geometry (from figures)

| Parameter | 96-well | 384-well | 1536-well |
|-----------|---------|----------|-----------|
| Column span (pitch × (n−1)) | 99.00 mm | 103.50 mm | 105.75 mm |
| Row span (pitch × (n−1)) | 63.00 mm | 67.50 mm | 69.75 mm |
| Last col to right edge | 14.38 mm | 12.13 mm | 11.005 mm |
| Last row to bottom edge | 11.24 mm | 8.99 mm | 7.865 mm |

(Symmetric: first and last offsets are equal.)

## Positional tolerance method

- "True Position" per ASME Y14.5M-1994.
- Applied at RFS (regardless of feature size).

## Well markings

- Top-left well (A1) must be distinguishable (letter "A", numeral "1", etc.).
- Additional markings optional.

## Notes

- All dims at 20 °C.
- Tolerances do not include draft.
