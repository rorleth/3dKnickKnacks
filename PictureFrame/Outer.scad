// Picture Frame Generator
// Parameters for art dimensions
art_width_inches = 10;
art_height_inches = 5;

// Frame parameters
frame_side_thickness = 10;  // Thickness of the sides of the frame in x/y direction
frame_front_width = 20;     // Width of frame border
internal_glass_overlap = 3; // How much the border overlaps the glass
frame_front_thickness = 3;  // distance from front of frame to the glass
glass_thickness = 3;   // Thickness of glass pane
picture_thickness =1;  // Thickness of the picture
foam_spacer_thickness = 1; // Thickness of foam spacer
backing_thickness = 2;    // Thickness of backing board
// assumption is that backing board is flush with back of frame and has a 45degree cut to hold onto frame
backing_groove_depth = 3;  // Depth of the groove that the backing board slides into
hanger_cutout_diameter = 5; // Diameter of the hanger cutout on the backing board
landscape_mode = true; // Whether to make the frame in landscape mode
make_backing_insert = false; // Whether to make a backing insert

module stopthecustomizer() {
   // This module is intentionally left empty to stop customizer issues
}
mm_per_inch = 25.4; // for testing purposes, set to 10 instead of 25.4

art_width = art_width_inches * mm_per_inch;
art_height = art_height_inches * mm_per_inch;   
framebody_z_dimension = glass_thickness + picture_thickness + foam_spacer_thickness + backing_thickness;

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

module backplateBevel(length, width)
{
    difference()
    {
        linear_extrude(height = length)
            polygon([
                [0, 0],
                [-backing_groove_depth, backing_thickness],
                [width + backing_groove_depth, backing_thickness],
                [width, 0]
            ]);
        translate([width/2, backing_thickness/2, 0.8 * length])
            rotate([90,0,0])
                cylinder(h=backing_thickness, r=hanger_cutout_diameter/2, center=true);
    }
}

module backplate()
{
    if (landscape_mode) {
        translate([-art_width/2, art_height , 0])
            rotate([90,0,0])
                backplateBevel(art_height+frame_side_thickness, art_width);
    } else {
       translate([-art_width/2,0, 0])
            rotate([90,0,90])
                backplateBevel(art_width+frame_side_thickness, art_height);
    }
}

module frameSide(internal_length) {
    union()
    {
        frameBevel(internal_length, frame_side_thickness, framebody_z_dimension);

        translate([0, -frame_front_width/2 + frame_side_thickness/2 + internal_glass_overlap, framebody_z_dimension])
            frameBevel(internal_length-2*internal_glass_overlap, frame_front_width, frame_front_thickness); 
    }
}

module frameAssembly()
{
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
    }
}

if (!make_backing_insert)
{
    difference()
    {
        frameAssembly();    
        backplate();
    }
} else {
    backplate();
}