$fn=100;
tyre_width=45;
tyre_radius=260;
tyre_diameter=tyre_radius * 2;

clearance=30;
guard_radius=tyre_radius + clearance / 2;
guard_diameter=guard_radius * 2;
guard_width=tyre_width + 30;
guard_thickness=3;

circle_deg=180;


tolerance = 0.6;

module mountProfile() {
	translate([(guard_width / 2) - 2, 0, 0]) resize([10 - tolerance, 22.5 - tolerance]) circle();
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
			translate([-guard_width, -guard_width / 2, 0]) square(guard_width);
			translate([(guard_width / 2) - 2, 0, 0]) resize([10, 22.5]) circle();
		}

		difference() {
			translate([(guard_width / 2) - 2, 0, 0]) resize([12.5, 25]) circle();
			translate([(guard_width / 2) - 2, 0, 0]) resize([10, 22.5]) circle();
		}

		difference() {
			translate([-straight, -guard_width / 2, 0]) 
				square([straight, guard_width]);
			translate([-straight, -(guard_width - guard_thickness) / 2, 0])
				square([straight, guard_width - guard_thickness]);
		}
	}
}

module mount() {
	rotate_extrude(angle=circle_deg, convexity=10) 
		translate([guard_radius - tyre_width, 0]) mountProfile();
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

guard();
mount();
//guardProfile();