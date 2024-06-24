include <BOSL2/std.scad>

$fn = 15;
eps = 1E-2;

board_length = 55.9;
board_width = 41.4;
board_thickness = 1.6;
board_clearance = 0.5;

mount_height = 3;

flange_width = 10;

fixing_width = 7.5;

d_height = 12.5;

wall_thickness = 2;
rounding = 2;

enclosure_width = board_width + board_clearance * 2 + fixing_width * 2;
enclosure_length = board_length + board_clearance * 2 + wall_thickness * 2;
enclosure_height = mount_height + board_thickness + d_height + 1;

module board() {
  color([0.7, 0.7, 0.7])
    up(mount_height)
      linear_extrude(board_thickness)
        rect([board_width, board_length]);
}

module base() {
  base_width = enclosure_width + flange_width * 2;
  base_length = enclosure_length;
  base_height = wall_thickness;

  hole_diameter = 4.5;
  hole_xoffset = flange_width / 2;
  hole_yoffset = hole_xoffset;

  difference() {
    translate([0, 0, -(base_height - eps)])
      linear_extrude(base_height)
        rect([base_width, base_length], rounding = rounding);

    for (x = [-(base_width / 2 - hole_xoffset), base_width / 2 - hole_xoffset])
      for (y = [-(base_length / 2 - hole_yoffset), base_length / 2 - hole_yoffset])
        translate([x, y, 0])
          cyl(base_height * 3, d = hole_diameter);
  }
}

module wall() {
  d_cutout_height = 13;
  d_cutout_width = 31;

  usb_height = 2.5;
  usb_yoffset = 14.8;
  usb_cutout_height = 7.5;
  usb_cutout_width = 11;

  difference() {
      linear_extrude(enclosure_height)
        rect([enclosure_width, enclosure_length], rounding = rounding);

      linear_extrude(enclosure_height + eps)
          rect([enclosure_width - wall_thickness * 2,
                enclosure_length - wall_thickness * 2], rounding = rounding);

      // D-connector cutout
      offset = 10;
      up(mount_height + board_thickness + d_height / 2 + offset / 2)
        xrot(90)
          linear_extrude(enclosure_length)
            rect([d_cutout_width, d_cutout_height + offset], rounding = rounding);

      // Micro-USB cutout
      up(mount_height + board_thickness + usb_height / 2)
        back(usb_yoffset)
          yrot(-90)
            zrot(90)
              linear_extrude(enclosure_width)
                rect([usb_cutout_width, usb_cutout_height], rounding = rounding);
    }
}

module fixing_holes() {
  x1 = enclosure_width / 2 - fixing_width / 2 - eps;
  y1 = enclosure_length / 2 - fixing_width / 2 - eps;
  for (x = [x1, -x1])
    for (y = [y1, -y1])
      difference() {
        linear_extrude(enclosure_height)
          translate([x, y, 0]) {
            if (x * y > 0)
              rect(fixing_width, rounding = [rounding, 0, rounding, 0]);
            else
              rect(fixing_width, rounding = [0, rounding, 0, rounding]);
          }

        translate([x, y, enclosure_height - 10])
          cyl(enclosure_height, d = 2.5, center=false);
      }
}

module mounting() {
  x1 = board_width / 2 - 2.5;
  y1 = board_length / 2 - 2.5;
  y2 = board_length / 2 - 15;

  for (x = [x1, -x1])
    for (y = [y1, -y2])
      translate([x, y]) {
        cyl(mount_height, d = 5, anchor = BOTTOM);
        cyl(mount_height + 2, d = 2, anchor=BOTTOM);
      }
}

base();
wall();
fixing_holes();
mounting();

//board();
