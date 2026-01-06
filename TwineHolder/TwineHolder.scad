baseWidth = 75;
baseThickness = 3;
pinLength = 55;
pinDiameter = 7;


use <threads.scad>

ScrewHole(pinDiameter, baseThickness, position = [baseWidth/2, baseWidth/2  , 0])
    cube([baseWidth, baseWidth, baseThickness], center = false);

rotate([0,90,0])
    cube([baseWidth*2/3, baseWidth, baseThickness], center = false);

translate([0, -baseWidth/2, baseThickness])
    RodStart(pinDiameter, pinLength, thread_len = baseThickness);

translate([0, -baseWidth/2, 0])
    cylinder(h = baseThickness, r = baseWidth/3, center = false);