


// used a couple of times to write the caption, hence pulling into own module
module write_caption(output, font, fontSize) {
    text(
        text = output, 
        size = fontSize, 
        font = font, 
        valign = "center", 
        halign = "center",
        $fn = 50
    );    
}

// figure out the bounding rectangle of the text, which depends on font, font size and margin
// taken approach/idea/code from https://mastering-openscad.eu/buch/example_06/ 
// - basically project the text on to x axis to get width (and take hull to not get a 
// collection of rectangles) then project on to y axis to get height
module text_area(output, font, fontSize, margin) {
    // margin between font and outer edge of plate
    textMargin = margin;

    // normalize nameplate to that size in order to get a fixed height regardless of characters used in font
    bottomPlateHeight = fontSize * 1.5 + 2 * textMargin; 
    estimated_length = len(output) * fontSize * 2;
    
    // set the resulting height to a constant, else it's going to depend
    // on whether really tall characters are being used or not (Italic capital G for instance)
    resize([0,bottomPlateHeight,0], auto =[false, true, false])
    offset( delta = textMargin )
    projection()
    intersection() {
        rotate([-90 , 0, 0])
            translate([0,0,-(3 * fontSize) / 2])
                linear_extrude( height = 3 * fontSize )
                    hull()
                        projection()
                            rotate( [90, 0, 0] )
                                linear_extrude(height = 1)
                                    write_caption(output, font, fontSize);


        rotate( [0, -90, 0] )
            translate( [0, 0, -estimated_length/2] )
                linear_extrude( height = estimated_length )
                    hull()
                        projection()    
                            rotate( [0, 90, 0] )
                                linear_extrude( height = 1 )
                                    write_caption(output, font, fontSize);
    }
}

module caption_plate(caption, font, fontSize,  captionElevation, borderThickness, margin) 
{
    // plate to write the name on
    //linear_extrude( height = 1 )
        //text_area(caption);

    if (borderThickness > 0)
    {
        difference()
        {
            linear_extrude( height = captionElevation )
                offset (delta = borderThickness)
                    text_area(caption, font, fontSize, margin);
            linear_extrude( height = captionElevation )
                text_area(caption, font, fontSize, margin);
        }
    }

    // write the caption
    linear_extrude(height = captionElevation)
        write_caption(output = caption, font = font, fontSize =fontSize);
    
}