include <BOSL2/std.scad>
include <BOSL2/screws.scad>

eps = 0.001;

$fa = 1;
$fs = 0.4;

// Magnet radius and height
r = 10;
h = 10;

// Magnet holder outer dimensions
r1 = r + 2;
h1 = h + 2;

// Flange radius and height
r2 = 5;
h2 = 5;

// Fixing 
r3 = 4 / 2;

module body() {
  union() {
    cyl(h=h1, r=r1, anchor=BOTTOM, rounding2=2);
    
    left(r1+r2)
      cyl(h=h2, r=r2, anchor=BOTTOM);
    
    right(r1+r2)
      cyl(h=h2, r=r2, anchor=BOTTOM);
    
    a = acos((r1 - r2) / (r1 + r2));
    x1 = r1 * cos(a);
    y1 = r1 * sin(a);
    x2 = r1 + r2 + r2 * cos(a);
    y2 = r2 * sin(a);
    linear_extrude(height=h2) {
        polygon([
          [x1, y1],
          [x2, y2],
          [x2, -y2],
          [x1, -y1],
          [-x1, -y1],
          [-x2, -y2],
          [-x2, y2],
          [-x1, y1]
        ]);
    }
  }
}

difference() {
  body();
 
  // Magnet cut out
  clearance = 0.1;
  down(eps)
    cyl(h=h + clearance * 2, r=r + 0.1, anchor=BOTTOM);
 
  // Screw holes
  for (x = [r1 + r2, -r1 - r2])
    right(x)
      up(h2)
        screw_hole("M3.5", head="flat", length=10, anchor=TOP);
 
  // Logo
  up((h + h1) / 2 + (h1 - h) / 4)
    linear_extrude(5)
      scale(0.08)
        import("magnet.svg", center = true);
}
