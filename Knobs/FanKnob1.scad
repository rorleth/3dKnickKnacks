baseThickness = 9;
baseDiameter = 42;
knobHeight = 8;
knobFlatThickness = 5.5;
knobDiameter = 6.2;
knobSlotWidth = 1;
knobSlotDepth = 5.5;
handleHeight = 8;
handleWidth = 5;

$fn = 50;
module knobFlattener()
{
    cube([knobDiameter, knobDiameter, knobHeight], center = false);
}

module twistKnob()
{
    difference()
    {
        cylinder(knobHeight, d=knobDiameter, center = false);
        union()
        {
            translate([-knobDiameter/2, knobFlatThickness/2, 0])
                knobFlattener();
            translate([-knobDiameter/2, -knobFlatThickness/2-knobDiameter, 0])
                knobFlattener();
            translate([-knobDiameter/2, -knobSlotWidth/2, 0])
                cube([knobDiameter, knobSlotWidth, knobSlotDepth], center=false);
        }
   }
}

module handleEdge()
{
    rotate_extrude(angle =90, convexity = 10)
        square([handleHeight,handleWidth], center=false);
}


module handle()
{
    translate([baseDiameter/2- handleHeight/2, handleWidth/2, 0])
        rotate([90,0,0])
            handleEdge();
    translate([-(baseDiameter/2- handleHeight/2), -handleWidth/2, 0])
        rotate([90,0,180])
            handleEdge();
    translate([-(baseDiameter-handleHeight)/2, -handleWidth/2, 0])
        cube([baseDiameter - handleHeight, handleWidth, knobHeight], center = false);
}

difference()
{
    cylinder(baseThickness, d=baseDiameter, center = false);
    twistKnob();
}
translate([0,0,baseThickness])
    handle();
