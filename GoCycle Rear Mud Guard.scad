$fn=100;
tyre_width=45;
tyre_radius=260;
tyre_diameter=tyre_radius * 2;

clearance=30;
guard_radius=tyre_radius + clearance / 2;
guard_diameter=guard_radius * 2;
guard_width=tyre_width + 30;
guard_thickness=3;

circle_deg=45;

mount_width = 22.5;

thumb_nut_diameter = 15.9;
nut_mount_height = 10;
nut_mount_diameter = 40;

tolerance = 0.6;

module nutMountProfile() {
	thumb_nut_radius = (thumb_nut_diameter + tolerance) / 2;
	nut_mount_radius = nut_mount_diameter / 2;
	difference() {
		union() {
			translate([-17, 14.5]) difference() {
				square(15);
				translate([15,15]) circle(10);
			}
			circle(d=nut_mount_diameter);
		}		
		circle(d=thumb_nut_diameter + tolerance);
	}
}

module mountProfile() {
	translate([(guard_width / 2) - 2, 0, 0]) resize([10 - tolerance, mount_width - tolerance]) circle();
}

module guardProfile() {
	straight = 10;
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
			translate([(guard_width / 2) - 2, 0, 0]) resize([10, 22.5]) circle();
		}

		// Reinforcement for shaft
		difference() {
			translate([(guard_width / 2) - 2, 0, 0]) resize([12.5, 25]) circle();
			translate([(guard_width / 2) - 2, 0, 0]) resize([10, 22.5]) circle();
		}
	}
}

module mount() {
	translate([0, 0, -nut_mount_height / 2]) {
			linear_extrude(height = nut_mount_height)
				nutMountProfile();
	}

	translate([2, -10]) {
		difference() {
			translate([-guard_radius - 5, 0]) {
				rotate_extrude(angle=circle_deg, convexity=10)
					translate([guard_radius - tyre_width, 0]) mountProfile();
			}
			translate([-mount_width - 5, 0, -mount_width / 2]) difference() {
				resize([0, mount_width * 2, 0]) cube(mount_width);
				translate([mount_width / 2, mount_width * 2, mount_width / 2]) resize([0, mount_width * 4, 0]) sphere(d=mount_width);
			}			
		}
	}
}

module guard() {
    rotate_extrude(angle=circle_deg, convexity=10)
       translate([guard_radius - tyre_width, 0]) guardProfile();
}

module tyre() {
    rotate_extrude(angle=360, convexity=10)
        translate([tyre_radius - tyre_width, 0]) circle(d=tyre_width);
}

//color("green") tyre();

//nutMountProfile();

//guard();
mount();
//guardProfile();
//