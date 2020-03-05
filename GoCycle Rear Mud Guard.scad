$fn=400;
tyre_width=45;
tyre_radius=260;
tyre_diameter=tyre_radius * 2;

clearance=30;
guard_radius=tyre_radius + clearance / 2;
guard_diameter=guard_radius * 2;
guard_width=tyre_width + 30;
guard_thickness=3;
lip_length=4;

circle_deg=45;

mount_side_cutout_diameter = 32;

mount_width = 30;
bar_height = 15;

tap_length = 25;
thumb_nut_diameter = 15.9;
thumb_nut_cutout_diameter = 26.3;
nut_mount_height = 10;
nut_mount_diameter = 40;

tolerance = 0.6;

module nutMountProfile() {
	thumb_nut_radius = (thumb_nut_diameter + tolerance) / 2;
	nut_mount_radius = nut_mount_diameter / 2;
	difference() {
		union() {
			translate([-18, 14.5]) difference() {
				square(15);
				translate([15,15]) circle(10);
			}
			circle(d=nut_mount_diameter);
			translate([-0.6,-1]) circle(d=nut_mount_diameter);
		}		
		circle(d=thumb_nut_diameter + tolerance);
	}
}

module mountProfile(width, new_height) {
	height = new_height ? new_height : bar_height;
	translate([(guard_width / 2) - 2, 0, 0]) resize([height - tolerance, width - tolerance]) circle();
}

module guardProfile() {
	inner_width = guard_width - guard_thickness;
	union() {
		difference() {	
			resize([guard_width + 10, guard_width]) circle(d=guard_width);
			translate([12, 0, 0]) resize([inner_width / 2, inner_width - 6]) circle(d=guard_width - guard_thickness);
			difference() {
				circle(d=guard_width - guard_thickness);				
				translate([inner_width - 20, 0, 0]) square(inner_width, center=true);
			}
			translate([-guard_width + 20, -guard_width / 2, 0]) square(guard_width);
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height + tolerance, mount_width + tolerance]) circle();
		}

		// Reinforcement for shaft
		difference() {
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height + guard_thickness * 2, mount_width + guard_thickness * 2]) circle();
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height + tolerance, mount_width + tolerance]) circle();
			//translate([5, -mount_width / 2, 0]) #square(mount_width);
			
		}
	}
}

module guardBar(bar_radius, bar_angle) {
	translate([-bar_radius - 5, 0]) {
		rotate_extrude(angle=bar_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) mountProfile(mount_width);	
	}
}

module guardBarTap(bar_radius, os = 0) {
	tap_angle = tap_length / (2 * PI * bar_radius) * 360;
	translate([-bar_radius - 5, 0]) {
		rotate([0,0, os])
		rotate_extrude(angle=tap_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) mountProfile(mount_width - 4 - tolerance, bar_height - 4);	
	}
}

module guardBarHole(bar_radius, os = 0) {
	hole_angle = (tap_length + tolerance) / (2 * PI * bar_radius) * 360;	
	translate([-bar_radius - 5, 0]) {
		rotate([0,0,os])
		rotate_extrude(angle=hole_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) mountProfile(mount_width - 4, bar_height - 4 + tolerance);	
	}
}

module barWithTap(bar_radius, bar_angle, tap=true, hole=true) {
	union() {
		difference() {
			guardBar(bar_radius, bar_angle);
			if (hole == true) {
				guardBarHole(bar_radius);
			}
		}
		if (tap == true) {
			guardBarTap(bar_radius, os=bar_angle);
		}
	}
}

module mount() {
	union() {
		translate([0, -5, -nut_mount_height / 2]) {
				linear_extrude(height = nut_mount_height)
					nutMountProfile();
		}

		translate([1, -16]) {
			difference() {
				barWithTap(guard_radius, 11, hole=false);
				#translate([-1, 11]) {
					translate([0,0,10]) cylinder(d = mount_side_cutout_diameter, h = nut_mount_height + tolerance, center = true);
					translate([0,0,-10]) cylinder(d = thumb_nut_cutout_diameter, h = nut_mount_height + 1 + tolerance, center = true);
				}

				// Shape the end of the bar
				translate([-mount_width - 5, 0, -mount_width / 2]) difference() {
					resize([0, mount_width * 2 - 10, 0]) cube(mount_width);
					translate([mount_width / 2 - 1, mount_width + 10, mount_width / 2]) resize([mount_width / 2 + 10, mount_width * 3, 0]) sphere(d=mount_width);
				}
				// More bar shaping
				translate([-mount_width + 12, -29, -mount_width / 2]) rotate(19) difference() {
					resize([0, mount_width * 2 - 10, 0]) cube(mount_width);
					translate([mount_width / 2 + 6, mount_width + 10, mount_width / 2]) resize([mount_width / 2 + 10, mount_width * 3, 0]) sphere(d=mount_width);
				}
			}
		}
	}
}

module guard_lip(tol = 0) {
	cutout_width=59 - tol * 2;
	difference() {
		guardProfile();
		translate([1.6 - tol, 0, 0]) guardProfile();
		translate([35,-cutout_width / 2,0]) square(cutout_width);
	}
}

module guard() {
	lip_tolerance = 0.3;
	lip_angle = (lip_length - lip_tolerance) / (2 * PI * guard_radius) * 360;
	lip_inset_angle = (lip_length) / (2 * PI * guard_radius) * 360;

	union() {
		difference() {
		    rotate_extrude(angle=circle_deg, convexity=10)
		       translate([guard_radius - tyre_width, 0]) guardProfile();

			rotate(0) rotate_extrude(angle=lip_inset_angle, convexity=10) 
				translate([guard_radius - tyre_width - 0.01, 0]) guard_lip();
		}
		
		rotate(circle_deg) rotate_extrude(angle=lip_angle, convexity=10) 
			translate([guard_radius - tyre_width, 0]) guard_lip(lip_tolerance);
	}
}

module tyre() {
    rotate_extrude(angle=360, convexity=10)
        translate([tyre_radius - tyre_width, 0]) circle(d=tyre_width);
}

//barWithTap(guard_radius, circle_deg);

//color("green") tyre();
//nutMountProfile();

translate([-guard_radius, 0,0]) guard();
//mount();

//guardProfile();

// guard_lip();