use <BOSL/masks.scad>

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
r3 = 4/2;

module body() {
    union() {
        cylinder(h=h1, r=r1);
        
        translate([r1+r2, 0, 0]) {
            cylinder(h=h2, r=r2);
        }
        
        translate([-(r1+r2), 0, 0]) {
            cylinder(h=h2, r=r2);
        }
        
        a = acos((r1-r2)/(r1+r2));
        x1 = r1*cos(a);
        y1 = r1*sin(a);
        x2 = r1+r2+r2*cos(a);
        y2 = r2*sin(a);
        linear_extrude(height=h2) {
            polygon([[x1, y1], [x2, y2], [x2, -y2], [x1, -y1], [-x1, -y1], [-x2, -y2], [-x2, y2], [-x1, y1]]);
        }
    }
}

module screw_hole(x) {
    union() {
        translate([x, 0, -1]) {
            cylinder(h=h2+2, r=r3+0.15);
        }
        
        translate([x, 0, h2-r3*2.1+0.001]) {
           cylinder(r1=0, r2=r3*2.1, h=r3*2.1);
        } 
    }
}

difference() {
    body();
    
    translate([0, 0, -0.001]) {
        cylinder(h=h+0.2, r=r+0.1);
    }
    
    screw_hole(r1+r2);
    screw_hole(-(r1+r2));
    
    cube(size=[1.5, 10, 50], center=true);
    cube(size=[10, 1.5, 50], center=true);
    
    translate([0, 0, h1]) {
        fillet_cylinder_mask(r=r1, fillet=2);
    }
}
