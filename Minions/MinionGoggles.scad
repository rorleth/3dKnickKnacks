// Simple parameterized Minion-style goggles (pair)
$fn = 120;

// Parameters
lens_dia = 56;           // diameter of lens opening
frame_band = 6;          // thickness of metal frame ring
frame_depth = 8;         // depth (thickness) of the frame
bridge_gap = 70;         // center-to-center distance between lenses
// Rubber band parameters (user requested 5 mm wide, 1 mm thick)
band_width = 5;          // width of rubber band (mm)
band_thickness = 1;      // thickness of rubber band (mm)
eyelet_clearance = 2;    // extra length to ensure slot passes cleanly through frame (mm)

// How far inset from the outer face the slot should be (small positive number)
eyelet_inset = 1.5;

// Frame (solid ring with an open inner hole for the eye)
module frame(r_lens=lens_dia/2) {
    r_outer = r_lens + frame_band;
    difference() {
        // outer ring
        cylinder(h=frame_depth, r=r_outer, center=false);
        // inner cutout for lens (this makes the goggles see-through)
        translate([0,0,-1]) cylinder(h=frame_depth+2, r=r_lens, center=false);
        // shallow bezel around inner edge (cosmetic)
        translate([0,0,frame_depth-1]) cylinder(h=2, r=r_lens + 1, center=false);
    }
}

// Small decorative bridge between the two frames
module bridge() {
    // bridge that connects into the inner rims of both frames so it is not floating
    // place two short cylinders at the inner edges of each frame and hull them
    left_x = -bridge_gap/2 + (lens_dia/2 + frame_band) - 1; // a little inside the outer edge
    right_x = bridge_gap/2 - (lens_dia/2 + frame_band) + 1;
    translate([0,0,frame_depth/2])
        hull() {
            translate([left_x, 0, 0]) cylinder(h=2, r=3);
            translate([right_x, 0, 0]) cylinder(h=2, r=3);
        }
}

// Single goggle: frame with eyelet hole (no solid lens and no strap)
// x is the X translation for the frame center (used to place left/right frames)
module single_goggle(x=0) {
    // Subtract an eyelet (through-hole) from the frame so a rubber band can be threaded.
    // Place the eyelet on the outer side of each frame (away from the center line)
    side_sign = (x >= 0) ? 1 : -1;
    // put the slot slightly inset from the absolute outer radius so it sits inside the frame
    eyelet_x = side_sign * (lens_dia/2 + frame_band - eyelet_inset);

    difference() {
        color([0.7,0.7,0.7]) frame();
        // rectangular slot sized for the band: width (X) x depth (Y) x thickness (Z)
        // center the slot at mid-height of the frame
        translate([eyelet_x, 0, frame_depth/2])
            // center=true so the cube cuts symmetrically
            cube([band_width, frame_depth + eyelet_clearance, band_thickness], center=true);
    }
}

// Pair assembly: two frames and the small bridge
module goggles_pair() {
    // place left and right frames (hollow centers allow seeing through)
    translate([-(lens_dia + bridge_gap)/2,0,0]) single_goggle(-bridge_gap/2);
    translate([(lens_dia + bridge_gap)/2,0,0]) single_goggle(bridge_gap/2);

    // connected bridge
    color([0.7,0.7,0.7]) bridge();
}

// Final assembly
goggles_pair();