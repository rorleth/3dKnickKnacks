mmPerInch=25.4;

skirt = 3.5;
beamWidth = 3.5;
length = 8;
topThickness = 0.125;
skirtThickness = 0.125;
dripEdgeLength = 0.25;
dripEdgeAngle = 30;
module skirtSide()
{
    cube([skirtThickness, length+skirtThickness, skirt+topThickness], center=false);    
    rotate([0,dripEdgeAngle,0])
        translate([skirtThickness*sin(dripEdgeAngle),0,0])
            cube([dripEdgeLength, length+skirtThickness, skirtThickness], center=false);    
}

scale([mmPerInch, mmPerInch,mmPerInch])
{
    // top
    translate([-skirtThickness,0,skirt])
        cube([beamWidth + 2*skirtThickness, length+skirtThickness, topThickness], center = false);
        
    // long sides    
    translate([0,length+skirtThickness,0])
        rotate([0,0,180])
            skirtSide();
    translate([beamWidth,0,0])
        skirtSide();
    
    // front
    translate([-skirtThickness,-skirtThickness,0])
        cube([beamWidth+2*skirtThickness, skirtThickness, skirt+topThickness], center=false);
    
    translate([-dripEdgeLength*cos(dripEdgeAngle)-skirtThickness,-skirtThickness*sin(dripEdgeAngle),0])
        rotate([dripEdgeAngle, 0,0])
            translate([0,-(dripEdgeLength-skirtThickness*sin(dripEdgeAngle)),-skirtThickness*sin(dripEdgeAngle)])
                cube([beamWidth+2*skirtThickness+2*(dripEdgeLength*cos(dripEdgeAngle)), dripEdgeLength, skirtThickness], center=false);    
    
}