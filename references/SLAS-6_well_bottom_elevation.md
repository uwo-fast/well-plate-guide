# ANSI SLAS 6-2012 — Well Bottom Elevation

Source: `ASNI_SLAS_6-WellBottomElevation.pdf`

## Overview

Defines **measurement methodology** for well bottom elevation on flat-bottom microplates.
Unlike SLAS 1–4, this standard specifies **no dimensional limits** — only definitions and a test procedure (Section 7 states this explicitly).

## Key definitions

| Term | Abbrev. | Definition |
|------|---------|------------|
| Well Bottom Elevation | WBE | Distance from Datum A to inside bottom surface at SBS well coordinates. Reported as nominal ± tolerance. |
| Well Bottom Elevation Variation | WBEV | Max spread (WBE_max − WBE_min) across all wells on one plate. Reported as max value. |
| Intra-Well Bottom Elevation Variation | IWBEV | Range (max − min) of distance from Datum A across the inside bottom of a single well. Reported as max value. |
| Well Depth | — | Distance from max projection of well top to inside bottom. Nominal ± tolerance. |
| Bottom Thickness | — | Mean thickness of all well bottoms on a plate. Nominal value. |
| Well Bottom Width | — | Internal flat-bottom diameter/width measured to theoretical sharp corner (tangent between bottom and sidewall). Nominal value. |

## Measurement relationships (from Figure 4)

```
Plate Height (SLAS-2)
├── Well Depth (top of well rim to inside bottom)
├── Bottom Thickness (inside bottom to outside bottom)
└── External Clearance (outside bottom to Datum A, min 1 mm per SLAS-2)
```

WBE = External Clearance + Bottom Thickness (measured from Datum A up to inside bottom)

## Test conditions

- Temperature: 25 °C ± 2 °C
- Parts in as-manufactured condition
- Measurement force must not distort part (significance: >10% of tolerance)
- Measurement perpendicular to Datum A
- Plate placed Datum A down, NOT constrained flat

## Test procedure

1. Position plate with Datum A down (unconstrained)
2. Establish datums B-C and D-E
3. Set origin at datum intersection
4. Measure distance from Datum A to inside bottom at each well center (per SLAS-4 coordinates)
5. Record: WBE (average), WBE_max, WBE_min, WBEV, IWBE_max, IWBE_min, IWBEV

## Notes

- No pass/fail limits defined — instrument manufacturers must specify their own WBE/WBEV/IWBEV requirements.
- References SLAS-2 (height) and SLAS-4 (well positions).
- Applies only to flat-bottom wells.
