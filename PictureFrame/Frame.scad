// Picture Frame Generator - Copyright 2026 by Robert Orleth
use <caption.scad>;
use <roundedcube.scad>;

/* [Frame] */
art_width_inches = 7.1;
art_height_inches = 5.1;
frame_side_thickness = 10;  // Thickness of the sides of the frame in x/y direction
frame_front_width = 13;     // Width of frame border
internal_glass_overlap = 3; // How much the border overlaps the glass
frame_front_thickness = 3;  // distance from front of frame to the glass
frame_deco_thickness = 1;  // Thickness of the front decorative part of the frame
glass_thickness = 3;   // Thickness of glass pane
picture_thickness =1;  // Thickness of the picture
foam_spacer_thickness = 1; // Thickness of foam spacer
backing_thickness = 2;    // Thickness of backing board
landscape_mode = true; // Whether to make the frame in landscape mode

/* [Decoration] */
front_decoration= "svg"; // [svg, png, mould, none ]
overlay_filename = "wood.svg";
caption = "2025";
caption_location = "bottom"; // [top, bottom, none]
caption_font = "Impact";
caption_font_size = 16;
caption_elevation = 2; // How high the caption is elevated over the baseplate
caption_border_thickness = 1; // Thickness of border around caption

/* [Hanger] */
make_backing_insert = false; // Whether to make a backing insert
hanger_option = "hole"; // [hole, tab, stand, none]
hanger_nailhead_diameter = 5; // Diameter of the hanger cutout on the backing board
hanger_nailbody_diameter = 2; // Diameter of the nail body that goes into the hanger cutout
hanger_nailhead_thickness = 2; // Depth of the hanger cutout
hanger_thickness = 2; // Thickness of the hanger structure


module stopthecustomizer() {
   // This module is intentionally left empty to stop customizer issues
}

mm_per_inch = 25.4;
$fn=50;
backing_groove_depth = 1;  // Depth of the groove that the backing board slides into
backplate_play = 0.1; // Extra space for the backing plate to fit easily
hanger_length = 5; // Length of the hanger structure
hanger_overlap = (hanger_nailhead_diameter - hanger_nailbody_diameter) /2; // Overlap of hanger backside to diameter of hanger cutout

art_width = art_width_inches * mm_per_inch;
art_height = art_height_inches * mm_per_inch;   
framebody_z_dimension = glass_thickness + picture_thickness + foam_spacer_thickness + backing_thickness;

mounting_point_percentage = 0.8; // percentage along the top edge to place the mounting point
frame_angle_degrees = 70; // to calculate the stand



// make a structure to hang the frame from, using two l-shaped plate with an inner
// space of hanger_nailhead_diameter and depth hanger_nailhead_thickness, topped by a half-cylinder
// at the top
module tabHanger(length, width)
{
    translate([hanger_length/2,0,(hanger_nailhead_thickness+hanger_thickness)/2])
    union()
    {
        difference()
        {
            // outer cube
            cube([hanger_length, hanger_nailhead_diameter + 2* hanger_thickness, hanger_nailhead_thickness+hanger_thickness], center = true);
            // cut away the cube under the overlap
            translate([0,0,-hanger_nailhead_thickness/2])
                cube([hanger_length, hanger_nailhead_diameter, hanger_nailhead_thickness], center=true);
            // cut away the cub that opens the hanger
            translate([0,0,0 ])
                cube([hanger_length, hanger_nailhead_diameter- hanger_overlap, hanger_nailhead_thickness+hanger_thickness], center=true);
        }
        // top end with half-cylinder
        translate([-(hanger_length)/2,0,0])
            difference()
            {
                cylinder(h=hanger_nailhead_thickness+hanger_thickness, r=hanger_nailhead_diameter/2 + hanger_thickness, center=true);
                translate([0,0,-hanger_thickness/2])
                    cylinder(h=hanger_nailhead_thickness,r=hanger_nailhead_diameter/2, center=true);
                cylinder(h=hanger_nailhead_thickness+hanger_thickness, r=hanger_nailhead_diameter/2 - hanger_overlap/2, center=true);
                translate([(hanger_nailhead_diameter/2 + 2*hanger_thickness)/2,0,0])
                    cube([hanger_nailhead_diameter/2 + 2*hanger_thickness, hanger_nailhead_diameter + 2* hanger_thickness,hanger_nailhead_thickness+hanger_thickness], center=true);
            }
    }
}

// make a stand that props the frame up at the given angle
module frameStand(stand_length)
{
    // how far out does the foot of the stand reach
    length_foot = stand_length * cos(frame_angle_degrees);
    
    // make a triangular prism for the stand
    rotate([90,90,-90])
        linear_extrude(height = hanger_thickness)
            polygon([
                [stand_length * sin(frame_angle_degrees),0],
                [0,0],
                [length_foot* cos(frame_angle_degrees),length_foot* sin(frame_angle_degrees)]
            ]);
}

module backplateAssembly(length, width, negative)
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
                translate([effective_width/2, 0, mounting_point_percentage * length - hanger_nailhead_diameter])
                    rotate([0,90,-90])
                        tabHanger(10, backing_thickness);
            }
            if (hanger_option == "stand" && !negative)
            {
                translate([effective_width/2 + hanger_thickness/2, 0, length])                
                        frameStand(mounting_point_percentage * length);
            }
        }
        if (hanger_option == "hole" && !negative)
        {
            union()
            {
                // cut the nail head hole
                translate([effective_width/2, backing_thickness/2, mounting_point_percentage * length - hanger_nailhead_diameter])
                    rotate([90,0,0])
                        cylinder(h=backing_thickness, r=hanger_nailhead_diameter/2, center=true);
                translate([effective_width/2, backing_thickness/2, mounting_point_percentage * length - hanger_nailhead_diameter/2])
                    rotate([90,0,0])
                        cube([hanger_nailbody_diameter, hanger_nailhead_diameter/2 + hanger_nailbody_diameter/2, backing_thickness], center=true);
                translate([effective_width/2, backing_thickness/2, mounting_point_percentage * length - hanger_nailbody_diameter/2])
                    rotate([90,0,0])
                        cylinder(h=backing_thickness, r=hanger_nailbody_diameter/2, center=true);
            }
        }
    }
}

// produces the backplate, negative = true makes the cutout for the frame which needs to a little bigger
module backplate(negative)
{
    if (landscape_mode) {
       translate([-art_width/2,0, 0])
            rotate([90,0,90])
                backplateAssembly(art_width+frame_side_thickness, art_height, negative);
    } else {
        translate([-art_width/2, art_height , 0])
            rotate([90,0,0])
                backplateAssembly(art_height+frame_side_thickness, art_width, negative);
    }
}

// produces one piece of the frame, a cube ith 45 degree bevels at each end
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
// produces one side of the frame, consisting of the frame body and the front plate that's holding in the glass
module frameSide(internal_length) {
    union()
    {
        frameBevel(internal_length, frame_side_thickness, framebody_z_dimension);

        translate([0, -frame_front_width/2 + frame_side_thickness/2 + internal_glass_overlap, framebody_z_dimension])
            frameBevel(internal_length-2*internal_glass_overlap, frame_front_width, frame_front_thickness); 
        // todo : add moulding
    }
}

// assembles the frame from four sides and adds decoration. Specifically does NOT add a caption plate
// as that needs cutting into the decoration.
module frameWithDecoration()
{
    if (front_decoration == "svg" || front_decoration == "png")
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
                        if (front_decoration == "svg" && overlay_filename != "")
                        {
                            translate([-art_width/2 - frame_front_width, -art_height/2 - frame_front_width, 0])
                                linear_extrude(height = frame_deco_thickness, center=true)
                                    resize([art_width + 2*frame_front_width, art_height + 2*frame_front_width, 0], auto=true)
                                        import(file = overlay_filename);                
                        } 
                        else if (front_decoration == "png" && overlay_filename != "")
                        {
                            // not yet implemented
                        }
                    }
            }
    } 
    else if (front_decoration == "mould") 
    {
        // this asssembles the frame from four pieces of side each of which come with their aligned decorative front
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
}
function captionTranslateVector(location) = 
    location == "top" ? 
        [0, art_height + frame_front_width/2, framebody_z_dimension + frame_front_thickness/2]:
        [0, -frame_front_width/2, framebody_z_dimension + frame_front_thickness/2];

module addCaption()
{  
    if (caption_location != "none")
    {
        tv = captionTranslateVector(caption_location);

        translate(tv)
            caption_plate(caption,  caption_font, caption_font_size,caption_elevation, caption_border_thickness);

        difference()
        {
            children();
            translate(tv)
                linear_extrude(height = 100)// remove material where the caption goes
                    text_area(caption, caption_font, caption_font_size);
        }
    }
    else
    {
        children();
    }
}


if (!make_backing_insert)
{
    difference()
    {
        addCaption()
            frameWithDecoration();    
        backplate(true); // cutout for the backplate
    }
} else {
    backplate(false);
}