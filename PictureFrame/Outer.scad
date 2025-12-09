// Picture Frame Generator
// Parameters for art dimensions
art_width_inches = 10;
art_height_inches = 5;

// Frame parameters
frame_front_width = 20;     // Width of frame border
glass_overlap = 3;          // How much the border overlaps the glass
frame_front_thickness = 3;  // distance from front of frame to the glass
glass_thickness = 3;   // Thickness of glass pane
picture_thickness =1;  // Thickness of the picture
foam_spacer_thickness = 1; // Thickness of foam spacer
backing_thickness = 2;    // Thickness of backing board
backing_bevel_depth = 3;  // Depth of the bevel on the backing board
// assumption is that backing board is flush with back of frame and has a 45degree cut to hold onto frame
frame_side_thickness = 10;  // Thickness of the sides of the frame in x/y direction
make_backing_insert = false; // Whether to make a backing insert

module stopthecustomizer() {
   // This module is intentionally left empty to stop customizer issues
}
mm_per_inch = 10; // for testing purposes, set to 10 instead of 25.4

art_width = art_width_inches * mm_per_inch;
art_height = art_height_inches * mm_per_inch;   
framebody_z_dimension = glass_thickness + picture_thickness + foam_spacer_thickness + backing_thickness;

module frameFront(length) {
    cube([length, frame_front_width, frame_front_thickness], center = false);
}

module backplate()
{
//    translate([0,0,-(glass_thickness + picture_thickness)])
//        cube([art_width + 2*frame_front_width, art_height + 2*frame_front_width, frame_side_thickness], center = false);
}

module frameSide(length) {
    union()
    {
        cube([length, frame_side_thickness, framebody_z_dimension], center = false);
        #translate([-glass_overlap, -glass_overlap, framebody_z_dimension])
            frameFront(length + 2*glass_overlap);
    }
}

module frameAssembly()
{
    union()
    {
        // Top frame side
        translate([0, art_height + frame_side_thickness, 0])
            frameSide(art_width + 2*frame_side_thickness);
        // Bottom frame side
        translate([art_width + 2*frame_side_thickness, frame_side_thickness, 0])
            rotate([0,0,180])
                frameSide(art_width + 2*frame_side_thickness);
        // Left frame side
        translate([frame_side_thickness, 0, 0])
            rotate([0,0,90])
                frameSide(art_height + 2*frame_side_thickness);
        // Right frame side
        translate([art_width + frame_side_thickness, art_height + 2*frame_side_thickness, 0])
            rotate([0,0,-90])
                frameSide(art_height + 2*frame_side_thickness);
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