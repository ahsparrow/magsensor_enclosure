include <BOSL2/std.scad>

$fn = 30;
eps = 1E-2;

board_length = 55.9;
board_width = 41.4;
board_thickness = 1.6;
board_clearance = 0.5;

mount_xoffset = 2.5;
mount_yoffset1 = 2.5;
mount_yoffset2 = 15;

pico_length = 51;
pico_width = 21;
pico_thickness = 1;
pico_yoffset = 0;

mount_height = 3;
mount_base_diameter = 5;
mount_diameter = 2;

flange_width = 10;

fixing_width = 7.5;

d_height = 12.5;
d_cutout_height = 10.5;
d_cutout_width = 31;

usb_height = 2.5;
usb_yoffset = 14.8;
usb_cutout_height = 7.5;
usb_cutout_width = 11;

wall_thickness = 2;
rounding = 2;

standoff_height = 50;
standoff_fixing_radius = 70;
standoff_text = "5";

enclosure_width = board_width + board_clearance * 2 + fixing_width * 2;
enclosure_length = board_length + board_clearance * 2 + wall_thickness * 2;
enclosure_height = mount_height + board_thickness + d_height + 1;

//---------------------------------------------------------------------
module board() {
  color([0.7, 0.7, 0.7])
    up(mount_height)
      linear_extrude(board_thickness)
        rect([board_width, board_length]);
}

//---------------------------------------------------------------------
module base() {
  base_width = enclosure_width;
  base_length = enclosure_length + flange_width * 2;
  base_height = wall_thickness;

  hole_diameter = 4.5;
  hole_xoffset = flange_width / 2;
  hole_yoffset = hole_xoffset;

  difference() {
    // Base plate
    cuboid(
      [base_width, base_length, base_height], anchor=TOP+CENTER,
      rounding=rounding,
      edges="Z");

    // 4 off fixing holes
    for (x = [-(base_width / 2 - hole_xoffset), base_width / 2 - hole_xoffset])
      for (y = [-(base_length / 2 - hole_yoffset), base_length / 2 - hole_yoffset])
        translate([x, y, 0])
          cylinder(h=base_height * 3, d = hole_diameter, center=true);
  }
}

// Enclosure wall
module wall() {
  difference() {
      rect_tube(
        size=[enclosure_width, enclosure_length],
        height=enclosure_height,
        wall=wall_thickness,
        rounding=rounding
      );

      // D-connector cutout
      fwd(enclosure_length / 2 - wall_thickness / 2)
        up(mount_height + board_thickness + d_height / 2 - d_cutout_height / 2)
          // Add 5mm to height to clear above the cut out
          cuboid(
            [d_cutout_width, wall_thickness * 2, d_cutout_height + 5],
            rounding=rounding,
            edges="Y",
            anchor=BOTTOM
          );

      // Micro-USB cutout
        up(mount_height + board_thickness + usb_height / 2 - usb_cutout_height / 2)
          back(usb_yoffset)
            left(enclosure_width / 2 - wall_thickness / 2)
              cuboid(
                [wall_thickness * 2, usb_cutout_width, usb_cutout_height],
                rounding=rounding,
                edges="X",
                anchor=BOTTOM
              );
    }
}

// Enclosure corners and lid fixing holes
module corners() {
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
          cyl(enclosure_height, d = 2, center=false);
      }
}

// PCB mounting
module can_mounting() {
  x1 = board_width / 2 - mount_xoffset;
  y1 = board_length / 2 - mount_yoffset1;
  y2 = board_length / 2 - mount_yoffset2;

  for (x = [x1, -x1])
    for (y = [y1, -y2])
      translate([x, y]) {
        cyl(mount_height, d = mount_base_diameter, anchor = BOTTOM);
        cyl(mount_height + board_thickness, d = mount_diameter, anchor=BOTTOM);
      }
}

// PICO W mounting
module pico_mounting() {
  width = 5.5;
  length = 5;
  clearance = 0.5;

  x1 = (pico_length + clearance) / 2;
  y1 = (pico_width  + clearance) / 2;
  thickness = pico_thickness + clearance;

  back(usb_yoffset + usb_cutout_width / 2 - ((pico_width + clearance) / 2 - length / 2))
    difference() {
      for (x = [x1, -x1])
        for (y = [y1, -y1])
          translate([x, y])
            cube([width - eps, length, enclosure_height], anchor = BOTTOM);

      right(0.5)
        up(enclosure_height - thickness + eps)
          cube([pico_length + clearance, pico_width + clearance, thickness], anchor = BOTTOM);
    }
}

//---------------------------------------------------------------------
module lid() {
  clearance = 0.5;

  module lid_volume() {
    module top() {
      cuboid(
        [enclosure_width, enclosure_length, wall_thickness],
        rounding=rounding,
        edges="Z",
        anchor=TOP);

      // D connector cutout
      d_top = enclosure_height - (mount_height + board_thickness + d_height / 2 + d_cutout_height / 2);
      fwd(enclosure_length / 2)
        cube([d_cutout_width - 2 * clearance, wall_thickness, d_top], anchor=BOTTOM + FRONT);
    }

    module usb_cover() {
      cover_len = usb_cutout_width;
        right(enclosure_width / 2 - wall_thickness - clearance)
          back(usb_yoffset)
            cube([wall_thickness, cover_len, enclosure_height - 1], anchor=BOTTOM + RIGHT);
    }

    module hold_downs() {
      size = 4;
      height = enclosure_height - mount_height - board_thickness - clearance;

      width = (enclosure_width / 2 - wall_thickness - clearance) - (board_width / 2 - mount_xoffset);
      x1 = enclosure_width / 2 - width / 2 - wall_thickness - clearance;
      fwd(board_length / 2 - mount_yoffset2)
        for (x = [x1, -x1])
          right(x)
            cube([width, size, height], anchor=BOTTOM);

      x2 = board_width / 2 - mount_xoffset;
      length = mount_yoffset1 + mount_diameter / 2;
      back(board_length / 2 - length / 2)
        for (x = [x2, -x2])
          right(x)
            cube([size, length, height], anchor=BOTTOM);
    }

    module locating_lugs() {
      y = enclosure_length / 2 - wall_thickness - clearance;
      back(y)
        cube(
          [enclosure_width - fixing_width * 2 - 2, wall_thickness, 2],
          anchor=BOTTOM + BACK
        );

      width = (enclosure_width - fixing_width * 2 - 2 - d_cutout_width) / 2;
      x1 = (d_cutout_width + width) / 2;
      for (x = [x1, -x1])
        translate([x, -y])
          cube([width, wall_thickness, 2], anchor=BOTTOM+FRONT);
    }

    union() {
        top();
        //usb_cover();
        hold_downs();
        locating_lugs();
      }
  }

  // Add cutouts
  difference() {
    lid_volume();

    // Fixing holes
    x1 = enclosure_width / 2 - fixing_width / 2;
    y1 = enclosure_length / 2 - fixing_width / 2;
    for (x = [x1, -x1])
      for (y = [y1, -y1])
        translate([x, y])
          cyl(d = 2.5, l = wall_thickness * 3);

    // Logo text
    height = wall_thickness;
    down(wall_thickness * 0.75)
      xflip()
        text3d("CAN-Bell", size=9, anchor=CENTER + TOP, atype="ycenter", h=height);

    // Logo bell
    down(wall_thickness * 1.75)
      fwd(17)
        linear_extrude(wall_thickness)
          scale(0.08)
            import("bell.svg", center = true);

    // Target marker
    marker_size = 12;
    marker_offset = 7.5;
    down(wall_thickness * 0.75)
      back(enclosure_length / 2 - marker_offset) {
        marker_h = wall_thickness;
        for (x = [0, 90, 180, 270])
          rotate(x)
            left(marker_size / 2 - 2)
              cube([2, 1, marker_h], anchor=TOP);

        or = marker_size / 2 - 2;
        tube(marker_h, or=or, ir=or - 1, anchor=TOP);
        cyl(marker_h, d=2, anchor=TOP);
      }
  }
}

//---------------------------------------------------------------------
module standoff() {
  width = enclosure_width + 20;
  length = enclosure_length + flange_width * 2;

  cutout_height = 10;

  hole_diameter = 4.6;
  hole_xoffset = flange_width / 2;
  hole_yoffset = hole_xoffset;

  tw_width = 7;
  tw_height = 2.5;

  difference() {
    union() {
      cuboid(
        [width, length, wall_thickness], anchor=BOTTOM+CENTER,
        rounding=rounding,
        edges="Z");

      cuboid(
        [enclosure_width - flange_width * 2, length, standoff_height], anchor=BOTTOM+CENTER,
        rounding=rounding,
        edges="Z");

      cuboid(
        [width, length - flange_width * 2, standoff_height], anchor=BOTTOM+CENTER,
        rounding=rounding,
        edges="Z");
    }

    // 4 off fixing holes
    for (x = [-(enclosure_width / 2 - hole_xoffset), enclosure_width / 2 - hole_xoffset])
      for (y = [-(length / 2 - hole_yoffset), length / 2 - hole_yoffset])
        translate([x, y, -eps])
          cylinder(h=wall_thickness + 2 * eps, d=hole_diameter, anchor=BOTTOM + CENTER);

    // Tie wrap holes
    tw_offset = length / 2 - flange_width - tw_width / 2 - rounding * 2;
    for (y = [-tw_offset, tw_offset])
      back(y)
        up(standoff_fixing_radius + wall_thickness)
          tube(
            h=tw_width,
            or=standoff_fixing_radius,
            ir=standoff_fixing_radius - tw_height,
            orient=FRONT);

    // Ident text
    offset = (width - (width - enclosure_width) / 2) / 2;
    for (x = [offset, -offset])
      up(-eps)
        xflip()
          left(x)
            text3d(
              standoff_text,
              size=9,
              anchor=CENTER + BOTTOM,
              atype="ycenter",
              h=wall_thickness / 4 + eps);
  }
}

/*
union() {
  base();
  wall();
  corners();
  can_mounting();
  pico_mounting();
}
*/

/*
up(enclosure_height + 0)
  yrot(180)
    lid();
*/

//lid();
//board();
standoff();
