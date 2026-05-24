include <../well_plates.scad>

// Select which plate to show (0-3)
selection = 1; // [0:1:3] 
type = well_plates[selection];

well_plate(type);
