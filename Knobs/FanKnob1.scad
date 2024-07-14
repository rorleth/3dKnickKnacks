baseThickness = 9;
baseDiameter = 42;
knobHeight = 8;
knobFlatThickness = 6;
knobDiameter = 7;
knobSlotWidth = 0.8;
knobSlotDepth = 5.5;
handleHeight = 15;
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
            translate([-knobDiameter/2, -knobSlotWidth/2, knobHeight - knobSlotDepth])
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
    translate([baseDiameter/2- handleHeight, handleWidth/2, 0])
        rotate([90,0,0])
            handleEdge();
    translate([-(baseDiameter/2- handleHeight), -handleWidth/2, 0])
        rotate([90,0,180])
            handleEdge();
    translate([-baseDiameter/2 +handleHeight, -handleWidth/2, 0])
        cube([baseDiameter - 2*handleHeight, handleWidth, handleHeight], center = false);
}

difference()
{
    cylinder(baseThickness, d=baseDiameter, center = false);
    twistKnob();
}
translate([0,0,baseThickness])
    handle();

//twistKnob();