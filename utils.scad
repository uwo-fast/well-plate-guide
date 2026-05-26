// utils.scad - some utility modules for dev

// A simple module to create a cross section of a 3D object. 
// @param dim: The size of the bounding box for the cross section.
// @param flip: If true, the cross section will be flipped along the Y-axis.
// @param active: If false, the cross section will not be rendered.
module cross_section(dim = 100, flip = false, active = true) {
  flip_factor = flip ? 0 : -1;
  if (active) {
    difference() {
      children();
      translate([-dim, dim * flip_factor, -dim])
        cube([2 * dim, dim, 2 * dim]);
    }
  } else {
    children();
  }
}
