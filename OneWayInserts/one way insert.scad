foot_radius = 8;
foot_height = 20;
hook_inner_diameter = 4;
hook_outer_diameter = 5;
hook_height = 2;
hooked_plate_thickness = 1;
hook_gap = 0.5;
gap_depth_in_foot = 8;
$fn = 50;
cut_plate_height = gap_depth_in_foot + hook_height + hooked_plate_thickness;
cut_plate_width = foot_radius*2;
difference()
{
    union()
    {
        cylinder(h= foot_height-foot_radius, r=foot_radius, center = false);
        translate([0,0,foot_height-foot_radius])
            sphere(r= foot_radius);

        rotate([180, 0, 0])
            cylinder(h = hooked_plate_thickness, r=hook_inner_diameter/2, center=false);

        translate([0,0,-hooked_plate_thickness])
            rotate([180, 0, 0])
                cylinder(hook_height, hook_outer_diameter/2, 0, center = false);
    }
    union()
    {
        translate([-foot_radius,-hook_gap/2,gap_depth_in_foot])
            rotate([270, 0, 0])
            cube([cut_plate_width, cut_plate_height, hook_gap], center=false);

        translate([hook_gap/2,-foot_radius,gap_depth_in_foot])
            rotate([270, 0, 90])
            cube([cut_plate_width, cut_plate_height, hook_gap], center=false);
    }
}
