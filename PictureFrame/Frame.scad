// Picture Frame Generator
// Parameters for art dimensions

art_width_inches = 7.1;
art_height_inches = 5.1;

// Frame parameters
frame_side_thickness = 10;  // Thickness of the sides of the frame in x/y direction
frame_front_width = 20;     // Width of frame border
internal_glass_overlap = 3; // How much the border overlaps the glass
frame_front_thickness = 3;  // distance from front of frame to the glass
frame_deco_thickness = 1;  // Thickness of the front decorative part of the frame
glass_thickness = 3;   // Thickness of glass pane
picture_thickness =1;  // Thickness of the picture
foam_spacer_thickness = 1; // Thickness of foam spacer
backing_thickness = 2;    // Thickness of backing board

hanger_option = "hole"; // [hole, tab, none]
hanger_cutout_diameter = 5; // Diameter of the hanger cutout on the backing board
hanger_overlap = 2; // Overlap of hanger backside to diameter of hanger cutout
hanger_thickness = 2; // Thickness of the hanger structure
hanger_depth = 4; // Depth of the hanger cutout
landscape_mode = true; // Whether to make the frame in landscape mode
make_backing_insert = false; // Whether to make a backing insert


module stopthecustomizer() {
   // This module is intentionally left empty to stop customizer issues
}
mm_per_inch = 25.4;
$fn=50;
// assumption is that backing board is flush with back of frame and has a 45degree cut to hold onto frame
backing_groove_depth = 1;  // Depth of the groove that the backing board slides into
backplate_play = 0.1; // Extra space for the backing plate to fit easily
hanger_length = 10; // Length of the hanger structure

art_width = art_width_inches * mm_per_inch;
art_height = art_height_inches * mm_per_inch;   
framebody_z_dimension = glass_thickness + picture_thickness + foam_spacer_thickness + backing_thickness;

// produces one side of the frame with 45 degree bevels at each end
module frameBevel(length, width, height) {
    translate([-(length+2*width)/2,-width/2,0])
        linear_extrude(height = height)
            polygon([
                [0, 0],
                [length + 2*width, 0],
                [length + width, width],
                [width, width]
            ]);
}

module tabSide()
{
    !difference()
    {
        cube([hanger_length, hanger_cutout_diameter/2 + hanger_thickness, hanger_depth], center = false);
        cube([hanger_length, hanger_cutout_diameter/2, hanger_depth-hanger_overlap], center=false);
    }
}
module tabHanger(length, width)
{
    // make a structure to hang the frame from, using two l-shaped plate with an inner
    // space of hanger_cutout_diameter and depth hanger_depth, topped by a half-cylinder
    // at the top
    translate([hanger_length/2,0,(hanger_depth+hanger_thickness)/2])
    union()
    {
        difference()
        {
            // outer cube
            cube([hanger_length, hanger_cutout_diameter + 2* hanger_thickness, hanger_depth+hanger_thickness], center = true);
            // cut away the cube under the overlap
            translate([0,0,-hanger_depth/2])
                cube([hanger_length, hanger_cutout_diameter, hanger_depth], center=true);
            // cut away the cub that opens the hanger
            translate([0,0,0 ])
                cube([hanger_length, hanger_cutout_diameter- hanger_overlap, hanger_depth+hanger_thickness], center=true);
        }
        // top end with half-cylinder
        translate([-(hanger_length)/2,0,0])
            difference()
            {
                cylinder(h=hanger_depth+hanger_thickness, r=hanger_cutout_diameter/2 + hanger_thickness, center=true);
                translate([0,0,-hanger_thickness/2])
                    cylinder(h=hanger_depth,r=hanger_cutout_diameter/2, center=true);
                cylinder(h=hanger_depth+hanger_thickness, r=hanger_cutout_diameter/2 - hanger_overlap/2, center=true);
                translate([(hanger_cutout_diameter/2 + 2*hanger_thickness)/2,0,0])
                    cube([hanger_cutout_diameter/2 + 2*hanger_thickness, hanger_cutout_diameter + 2* hanger_thickness,hanger_depth+hanger_thickness], center=true);
            }
    }
}

module backplateBevel(length, width, negative)
{
    effective_width = negative ? width + 2*backplate_play : width - 2*backplate_play;
    difference()
    {
        union()
        {
            linear_extrude(height = negative ? length + backplate_play : length)
                polygon([
                    [0, 0],
                    [-backing_groove_depth, backing_thickness],
                    [effective_width + backing_groove_depth, backing_thickness],
                    [effective_width, 0]
                ]);
            if (hanger_option == "tab" && !negative)
            {
                translate([effective_width/2, 0, 0.8 * length - hanger_cutout_diameter])
                    rotate([0,90,-90])
                        tabHanger(10, backing_thickness);
            }
        }
        if (hanger_option == "hole" && !negative)
        {
            translate([effective_width/2, backing_thickness/2, 0.8 * length - hanger_cutout_diameter])
                rotate([90,0,0])
                    cylinder(h=backing_thickness, r=hanger_cutout_diameter/2, center=true);
        }
    }
}

module backplate(negative)
{
    if (landscape_mode) {
        translate([-art_width/2, art_height , 0])
            rotate([90,0,0])
                backplateBevel(art_height+frame_side_thickness, art_width, negative);
    } else {
       translate([-art_width/2,0, 0])
            rotate([90,0,90])
                backplateBevel(art_width+frame_side_thickness, art_height, negative);
    }
}

module frameSide(internal_length) {
    union()
    {
        frameBevel(internal_length, frame_side_thickness, framebody_z_dimension);

        translate([0, -frame_front_width/2 + frame_side_thickness/2 + internal_glass_overlap, framebody_z_dimension])
            difference()
            {
                frameBevel(internal_length-2*internal_glass_overlap, frame_front_width, frame_front_thickness); 
                #linear_extrude(height = frame_front_thickness, center=true)
                    //resize([length,width, 0], auto=true)
                        import(file = "wood.svg");
            }
    }
}

module frameAssembly()
{
    // make the frame from two cubes, then overlay the front that holds the glass
    // advantage: can overlay an svg on top of the front piece as this doesn't involve rotation
    translate([0, art_height/2, framebody_z_dimension/2])
        union()
        {
            difference()
            {
                cube([art_width + 2*frame_side_thickness, art_height + 2*frame_side_thickness, framebody_z_dimension], center=true);
                cube([art_width , art_height, framebody_z_dimension], center=true);
            }
            translate([0, 0, framebody_z_dimension/2])
                difference()
                {
                    cube([art_width + 2*frame_front_width, art_height + 2*frame_front_width, frame_front_thickness], center=true);
                    cube([art_width - 2* internal_glass_overlap, art_height - 2* internal_glass_overlap, frame_front_thickness], center=true);
                }
            translate([0, 0, framebody_z_dimension/2 + frame_front_thickness/2])
                intersection()
                {
                    difference()
                    {
                        cube([art_width + 2*frame_front_width, art_height + 2*frame_front_width, frame_deco_thickness], center=true);
                        cube([art_width - 2* internal_glass_overlap, art_height - 2* internal_glass_overlap, frame_deco_thickness], center=true);
                    }
                    translate([-art_width/2 - frame_front_width, -art_height/2 - frame_front_width, 0])
                        linear_extrude(height = frame_deco_thickness, center=true)
                            resize([art_width + 2*frame_front_width, art_height + 2*frame_front_width, 0], auto=true)
                                import(file = "wood.svg");                
                }
        }

    /* this asssembles the frame from four pieces of side
    union()
    {
        // Top frame side
        translate([0, art_height + frame_side_thickness/2, 0])
            rotate([0,0,180])
                frameSide(art_width);
        // Bottom frame side
        translate([0, -frame_side_thickness/2, 0])
                frameSide(art_width);
        // Left frame side
        translate([-art_width/2-frame_side_thickness/2, art_height/2, 0])
            rotate([0,0,-90])
                frameSide(art_height);
        // Right frame side
        translate([art_width/2 + frame_side_thickness/2, art_height/2, 0])
            rotate([0,0,90])
                frameSide(art_height);
    }*/
}

if (!make_backing_insert)
{
    difference()
    {
        frameAssembly();    
        backplate(true);
    }
} else {
    backplate(false);
}