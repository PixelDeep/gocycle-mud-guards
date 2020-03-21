$fn=300;
tyre_width=45;
tyre_radius=265;
tyre_diameter=tyre_radius * 2;

clearance=30;
guard_radius=tyre_radius + clearance;
guard_diameter=guard_radius * 2;
guard_width=tyre_width + 30;
guard_thickness=3;
lip_length=4;

shell_thickness = 5;

circle_deg=44;

shock_mount_diameter = 30.6;
shock_mount_height = 20;
shock_mount_angle = 45;
shock_absorber_diameter = 22;

mount_width = 30;
bar_height = 15;

tap_length = 25;
thumb_nut_diameter = 15.9;
thumb_nut_cutout_diameter = 26.5;
nut_mount_height = 10;
nut_mount_diameter = 40;

tolerance = 0.4;

module fillet(diameter = 15) {
	difference() {
		square(diameter);
		translate([diameter, diameter]) circle(d = diameter);
	}
}

module barProfile(width, new_height) {
	height = new_height ? new_height : bar_height;
	translate([(guard_width / 2) - 2, 0, 0]) resize([height - tolerance, width - tolerance]) circle();
}

module guardProfile() {
	inner_width = guard_width - guard_thickness;
	t = 0.1; // Loosen up tolerance
	union() {
		difference() {	
			resize([guard_width + 5, guard_width]) circle(d=guard_width);
			translate([16, 0, 0]) resize([inner_width / 2, inner_width - 12]) circle(d=guard_width - guard_thickness);
			difference() {
				circle(d=guard_width - guard_thickness);				
				translate([inner_width - 20, 0, 0]) square(inner_width, center=true);
			}
			translate([-guard_width + 20, -guard_width / 2, 0]) square(guard_width);
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height -t, mount_width -t]) circle();
		}
		
		// Reinforcement for shaft
		difference() {
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height + 5, mount_width + 5]) circle();
			translate([(guard_width / 2) - 2, 0, 0]) resize([bar_height + t, mount_width + t]) circle();
			translate([0, -mount_width / 2 - 2, 0]) square(mount_width + 4);
			
		}

	}
}

module guardBar(bar_radius, bar_angle) {
	translate([-bar_radius - 5, 0]) {
		rotate_extrude(angle=bar_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) barProfile(mount_width);	
	}
}

module guardBarTap(bar_radius, os = 0) {
	tap_angle = tap_length / (2 * PI * bar_radius) * 360;
	translate([-bar_radius - 5, 0]) {
		rotate([0,0, os])
		rotate_extrude(angle=tap_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) barProfile(mount_width - 4 - tolerance, bar_height - 4 - tolerance);
	}
}

module guardBarHole(bar_radius, os = 0) {
	hole_angle = (tap_length + tolerance) / (2 * PI * bar_radius) * 360;	
	translate([-bar_radius - 5, 0]) {
		rotate([0,0,os])
		rotate_extrude(angle=hole_angle, convexity=10)
			translate([bar_radius - tyre_width, 0]) barProfile(mount_width - 4, bar_height - 4);	
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

module shock_mount_damasque_profile() {
	inner_x = nut_mount_diameter - shock_mount_diameter;
	polygon([
		[inner_x, 0],
		[inner_x, shock_mount_height],
		[inner_x + shell_thickness / 2, shock_mount_height],
		[inner_x + shell_thickness, 0]
	]);
}

module mount() {
	difference() {	
		union() {
			translate([0, -5, -nut_mount_height / 2])
				cylinder(d=nut_mount_diameter, h = nut_mount_height);

			translate([0, -5, nut_mount_height / 2])
				cylinder(d1=nut_mount_diameter, d2 = shock_mount_diameter + shell_thickness, h = shock_mount_height);

			// Mount for bar support
			bar_angle = 6;
			translate([9, 0]) {
				difference() {
					rotate(-1) intersection() {
						barWithTap(guard_radius, bar_angle, hole=false);
						translate([-mount_width / 2, mount_width + 14, 0]) {
							resize([mount_width / 2 + 10, mount_width * 3, 0])
							sphere(d=mount_width + 2);
						}
					}
				}
			}
		}

		// Cutout for thumb nut
		translate([0, -5, -9]) {
			cylinder(d = thumb_nut_cutout_diameter, h = nut_mount_height, center = true);
		}

		// Holes for thumb nut and shock mount
		translate([0, -5, -nut_mount_height / 2 - tolerance]) {
			cylinder(d=thumb_nut_diameter + tolerance, h = nut_mount_height + tolerance * 2);
		}
		translate([0, -5, shock_mount_height - 5]) cylinder(d = shock_mount_diameter + tolerance * 2, h = shock_mount_height + tolerance, center = true);

		// Cut out for shock mount
		rotate(shock_mount_angle) translate([10, -3, nut_mount_height / 2 + shock_mount_height / 2])
			cube([shock_mount_height, shock_absorber_diameter + tolerance, shock_mount_height + tolerance], center= true);
		
	}
}

module guard_lip(tol = 0) {
	cutout_width=59 - tol * 2;
	difference() {
		guardProfile();
		scale([1.0, 1.01]) translate([1.6 - tol, 0, 0]) guardProfile();
		translate([35,-cutout_width / 2,0]) square(cutout_width);
	}
}

module guard(guard_deg = circle_deg) {
	lip_tolerance = 0.3;
	lip_angle = (lip_length - lip_tolerance) / (2 * PI * guard_radius) * 360;
	lip_inset_angle = (lip_length) / (2 * PI * guard_radius) * 360;

	union() {
		difference() {
		    rotate_extrude(angle=guard_deg, convexity=10)
		       translate([guard_radius - tyre_width, 0]) guardProfile();

			rotate_extrude(angle=lip_inset_angle, convexity=10) 
				translate([guard_radius - tyre_width - 0.01, 0]) guard_lip();
		}
		
		rotate(guard_deg) rotate_extrude(angle=lip_angle, convexity=10) 
			translate([guard_radius - tyre_width, 0]) guard_lip(lip_tolerance);
	}
}

module tyre() {
    rotate_extrude(angle=360, convexity=10)
        translate([tyre_radius - tyre_width, 0]) circle(d=tyre_width);
}

// translate([5, 0, 0]) barWithTap(guard_radius, circle_deg);

// color("green") tyre();
// nutMountProfile();

rotate([90,0,0]) translate([-guard_radius, 0,0]) guard(guard_deg = 15);
// mount();

// shock_mount_damasque_profile();

//guardProfile();

//guard_lip();

//translate([-guard_radius, 0,0]) rotate_extrude(angle=10, convexity=10) translate([guard_radius - tyre_width, 0]) guardProfile();
