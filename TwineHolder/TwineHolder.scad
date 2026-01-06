baseWidth = 75;
baseThickness = 3;
pinLength = 55;
pinDiameter = 7;

use <threads.scad>

module strut()
{
    rotate([-90,0,0])    
        linear_extrude(height = baseThickness)
            polygon(points=[
                [0,0],
                [0, baseWidth * 2/3],
                [baseWidth,0],
            ]);
}

// base plate with screw hole
ScrewHole(pinDiameter, baseThickness, position = [baseWidth/2, baseWidth/2  , 0])
    cube([baseWidth, baseWidth, baseThickness], center = false);

// wall facing plate, to be tape-glued to wall
rotate([0,90,0])
    cube([baseWidth*2/3, baseWidth, baseThickness], center = false);

// add support struts
translate([0, baseWidth/3-baseThickness, 0])
    strut();
translate([0, baseWidth*2/3, 0])
    strut();

// the pin to hold the twine spool
translate([0, -baseWidth/2, baseThickness])
    RodStart(pinDiameter, pinLength, thread_diam = pinDiameter, thread_len = baseThickness);

// plate on top of the pin to stop the spool falling off
translate([0, -baseWidth/2, 0])
    cylinder(h = baseThickness, r = baseWidth/3, center = false);