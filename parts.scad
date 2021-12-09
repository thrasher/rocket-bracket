// all dimensions in millimeters

// see: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#$fa,_$fs_and_$fn
$fs = 2; // minimum size of a circle fragment, default=2, min=0.01
$fa = 15; // a circle has fragments = 360 divided by this number, default=12, min=0.01
$fn = $preview ? 24 : 80; // number of fragments in a circle, when non-zero $fs and $fa are ignored, default=0
chamfer_extrude = $preview ? 4 : 12;

use<scad-utils/morphology.scad>

// parameterized dimensions and measurements
WALL_TO_CENTERLINE = 80; // clearence from wall to centerline of rocket for fins
ENGINE_DIA = 17.5; //17.5 - 17.8 as measured
ENGINE_HT = 69.5; // 69.75 as measured
ENGINE_EXHAUST_DIA = 12.0; // 12.6 as measured
WALLPLATE_THICKNESS = 5;
WALLPLATE_W = 20;
WALLPLATE_H = 100;
MOUNT_OFFSET = 30; // leave 15mm clearence below engine

module engine() {
	color("brown")
	cylinder(d = ENGINE_DIA, h = ENGINE_HT);
}

module engine_blank() {
	cylinder(d1 = 8, d2 = ENGINE_EXHAUST_DIA, h = MOUNT_OFFSET);
	translate([0,0,MOUNT_OFFSET])
	engine();
}

module wall_bracket() {
	// translate([-WALL_TO_CENTERLINE/2, 0, 5])
	// cube([WALL_TO_CENTERLINE, WALLPLATE_W, 10], center = true);

	// translate([-WALL_TO_CENTERLINE + WALLPLATE_THICKNESS/2, 0, WALLPLATE_H/2])
	// cube([WALLPLATE_THICKNESS, WALLPLATE_W, WALLPLATE_H], center = true);
	difference() {
		union() {
			arm();
			rotate([0,0,45/2])
			cylinder(d = WALLPLATE_W / cos(45/2), h = WALLPLATE_W, $fn = 8);
		}
		translate([0,0,-.1])
		engine_blank();

		// screw holes
		translate([WALL_TO_CENTERLINE - WALLPLATE_THICKNESS, 0, WALLPLATE_W*1.5])
		rotate([0, -90, 0])
		drywall_screw();
		translate([WALL_TO_CENTERLINE - WALLPLATE_THICKNESS, 0, WALLPLATE_H - WALLPLATE_W/2])
		rotate([0, -90, 0])
		drywall_screw();
	}
}

module arm() {
	rotate([90, 0, 0])
	linear_extrude(height = WALLPLATE_W, center = true)
	difference() {
		fillet(r = WALL_TO_CENTERLINE - WALLPLATE_THICKNESS - WALLPLATE_W)
		bracket_2d();
		// translate([WALLPLATE_W/2, WALLPLATE_W/2])
		// circle(d = WALLPLATE_W/2);
		// translate([WALLPLATE_W/2 * 3, WALLPLATE_W/2])
		// circle(d = WALLPLATE_W/2 * 1.2);
	}
}

module bracket_2d() {
	polygon([
		[0,0],
		[WALL_TO_CENTERLINE, 0],
		[WALL_TO_CENTERLINE, WALLPLATE_H],
		[WALL_TO_CENTERLINE - WALLPLATE_THICKNESS, WALLPLATE_H],
		[WALL_TO_CENTERLINE - WALLPLATE_THICKNESS, WALLPLATE_W],
		[0, WALLPLATE_W]
	]);
}

// screw hole
module screw_hole(head_dia, body_dia) {
    depth = 200;

    CONE = (head_dia - body_dia);

    // head shaft
    translate([0, 0, -0.01])
    cylinder(d = head_dia, h = depth);

    // thread shaft
    translate([0, 0, -depth - CONE])
    cylinder(d = body_dia, h = depth+ 0.01);

    // cone for drywall screws
    translate([0, 0, -CONE])
    cylinder(d2 = head_dia, d1 = body_dia, h = CONE);
}

// drywall screw
module drywall_screw(screw_head_dia = 9, screw_body_dia = 5) {
    screw_hole(screw_head_dia, screw_body_dia);
}



// #####################################################

// move parts depending on single view (rendering) or group view (all parts)
module render(part, location, named) {
	if (part == "all" || part == named) {
		MOVE = (part != "all") ?  [0, 0, 0] : location;
		translate(MOVE) children();
	}
	// echo(parent_module(0));
}

PART = "all";
echo(str("render ", PART));
render(PART, [0, 0, 0], "wall_bracket") wall_bracket();
render(PART, [0, 0, 0], "engine_blank") engine_blank();
