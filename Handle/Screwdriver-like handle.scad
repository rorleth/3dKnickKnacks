
handle_height = 60;
handle_diameter = 40;
handle_top = handle_height*0.25;
tool_diameter = 13.12;
tool_height = 7.2;
handle_cutout_diameter = 6.5;
toroid_adj = -9; //have to sometimes adjust height of toroid 

post_width=19.3;
post_thickness=3.45;

difference()
{
    union()
    {
        //main handle
        cylinder(h = handle_height, d = handle_diameter, $fn = 18);

        //ball on top of handle
        translate([0,0,handle_height + 0.25])
            sphere(d = handle_diameter - 0.25, $fn = 100);

        //BOTTOM CONES
        union()
        {    
            translate([0,0,-21])
                cylinder(h = 2, d = handle_diameter - 2, $fn = 18);
            
            translate([0,0,-23])
                cylinder(h = 2, d1 = handle_diameter - 4, d2 = handle_diameter - 2, $fn = 18);

            translate([0,0,-19])
                cylinder(h = 3, d1 = handle_diameter - 2, d2 = handle_diameter - 7, $fn = 18);
        }    

        //MID-BOTTOM CONES FOR TOROID
        translate([0,0,-10])
            cylinder(h = 10, d1 = handle_diameter - 11, d2 = handle_diameter, $fn = 18); //$fn = 64

        translate([0,0,-19])
            cylinder(h = 28, d1 = handle_diameter - 2.7, d2 = handle_diameter - 11, $fn = 64); //$fn = 64

    }   

    //internal cutouts for main handle texture
    for ( i = [0 : 5] )
    {
        rotate( i * 60, [0, 0, 1])
        {
            translate([(0.5 * handle_diameter) + 1, 0, -8])
                cylinder(h = handle_height + 20, d = handle_cutout_diameter, $fn = 16);
        }
    }


    translate([0,0,-30])    
        //internal cutouts for bottom handle texture
        for ( i = [0 : 5] )
        {
            rotate( i * 60, [0, 0, 1])
            {
                translate([(handle_diameter * 0.5), 0, 5])
                    cylinder(h = 12, d = handle_cutout_diameter - 2, $fn = 64);
            }
        }

    //toroid to cut out of bottom of handle
    translate([0, 0, toroid_adj]){
        rotate_extrude(convexity = 10, $fn = 64)
            translate([handle_diameter - 5, 0, 0])
                circle(r = (0.5 * handle_diameter) - 0.5 , $fn = 128);
    }

    translate([0,0,handle_height-41])
        cube([post_width, post_thickness, handle_height+25], center = true);

    /*
    //TOOL HOLDING PART!
    translate([0,0,-25])
        cylinder(h = 12, d = 10.1, $fn = 6);

    //SCREWDRIVER HOLDING PART
    union()
    {
        translate([0,0,-25])
            cylinder(d = 3.7, h = 15.5, $fn = 64);

        translate([0,0,-18])
            cylinder(d1 = tool_diameter + 0.03, d2 = tool_diameter - 7, h = 5.5, $fn = 64);

        translate([0,0,-25])
        cylinder(d = tool_diameter, h = tool_height, $fn = 64);
    }
    */
}