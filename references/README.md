# References

The plate geometry in `well_plate.scad` and `well_plates.scad` follows the ANSI/SLAS
microplate standards, published by the Society for Laboratory Automation and
Screening (SLAS):

| Standard | Covers | Used for |
| --- | --- | --- |
| ANSI/SLAS 1-2004 (R2012) | Footprint dimensions | plate length, width and corner radius |
| ANSI/SLAS 2-2004 (R2012) | Height dimensions | plate height |
| ANSI/SLAS 3-2004 (R2012) | Bottom outside flange dimensions | flange heights and wall thickness |
| ANSI/SLAS 4-2004 (R2012) | Well positions | rows, columns, pitch and the A1 offsets |
| ANSI/SLAS 6 | Well bottom elevation | not modelled yet |

The standards are available from SLAS:
<https://www.slas.org/education/ansi-slas-microplate-standards/>.

The other fields of each plate definition (well diameter, depth, shape and bottom
radius) are not set by the standards. They come from the plate maker's datasheet or
from measuring the plate.
