// Copyright 2025 H. Dale McBane
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the “Software”), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// cd into the User Library Path
// git clone https://github.com/BelfrySCAD/BOSL2.git
include <BOSL2/std.scad>

// steps in curves
$fn = 256;
// card length mm
cardLength = 85.0;
// card width mm
cardWidth = 54.0;
// card thckness mm
cardHeight  = 2.25;
// perimeter tolerance mm
cardPerimeterTolerance = 0.75;
// thickness tolerance mm
cardThicknessTolerance = 0.11;
// chamfer mm
chamferDepth = 0.5;
// wall thickness mm
wallThickness = 2.5;
// Select Strap Text
strapText = "";
// Select Strap Text Font
fontName = "Highway Gothic:style=Regular";
// text height mm
textHeight = 4.7;
// text depth mm
textDepth = 0.5;
// text vertical position mm
textVerticalPosition = 1.5;
// skid depth mm
skidDepth = 0.5;
// skid width mm
skidWidth = 1.1;
// skid length mm
skidLength = 44.1;
// skid offset vertically
skidVerticalOffset = -11.5;
// strap height mm
strapHeight = 18.1;
// Render only one side of the card holder
oneHalf = true;
// Generate supports for 3D printing horizontally
generateSupports = true;
// Support diameter mm
supportDiameter=1.1;
// Distance between support and model
supportOffset=0.0;
// Distance between supports
supportDistance=9.5;
// How much wall to remove in making the grip
edgeGripLength=50;
// Size of the card grip arch
cardGripArch=9;


// card size calculations
cardHolderL = wallThickness + cardLength + cardPerimeterTolerance;
cardHolderW = wallThickness * 2 + cardWidth + cardPerimeterTolerance;
cardHolderH = wallThickness + cardHeight + cardThicknessTolerance;
// skid size calculation
skidL = cardHolderL - skidLength;

// card with chamfer
module rcard( w, l, h, chamfer )
{
    cuboid(size=[w, l, h], anchor=DOWN+FRONT+LEFT, chamfer=chamfer);
}

// card no radius
module card ( w, l, h )
{
	cube ( [w, l, h] );
}

// cylinder with chamfer
module rcylinder(r, h, chamfer, center)
{
    cyl(r=r, l=h, anchor=DOWN, chamfer=chamfer);
}


module cornerCutter (r1, r2, ht) {
    difference() {
        cube([r2, r2, ht]);
        translate([0,0,-1])linear_extrude(ht+2, [0,0,1])circle(r1);
    }
}


// chl = cardHolderL - card holder length
// chw = cardHolderW - card holder width
// chh = cardHolderH - card holder height
// wt = wallThickness - wall thickness
// sh = strapHeight - strap height
// tvp = textVerticalPosition - text vertical position on strap
// st = strapText - the text to be displayed on the strap
// td = textDepth - the distance the text is extruded from the face of the strap
// th = textHeight - the size/height of the text
// fn = fontName - the name of the type face used to render the text
module cardStrap (chl, chw, chh, wt, sh, tvp, st, td, th, fn)
{
	difference ()
	{
		// text
        translate ( [chl, 0, chh] )
		{
            translate ( [-chamferDepth, 0, 0])
                card ( sh+chamferDepth, chw, wt );

			translate ( [tvp,chw/2,wt] )
				rotate ([0,0,-90])
			        linear_extrude(td) 
			        text(st, size=th, font=fn, halign="center");
			translate ( [tvp,chw/2,0] )
				rotate ([0,180,-90])
					linear_extrude(td) 
					text(st, size=th, font=fn, halign="center");
		}
		//	cutting corners of strap
        translate( [ chl, sh, 0 ] )
        {
            rotate( [ 0, 0, 270 ] )
            {
                cornerCutter( r1=sh, r2=sh*2, ht=10 );
            }
        }
        translate([chl, chw-sh, 0])
            cornerCutter(r1=sh, r2=sh*2, ht=10);
            	
		// Strap hole
		translate ( [(chl+(sh/2)-0.5), chw/2-5, chh-1] )
		{
			card (5, 10, 10);
			translate ([2.5,0,-1])
				cylinder ( r=2.5, h=10 );
			translate ([2.5,10,-1])
				cylinder ( r=2.5, h=10 );
			translate ([2.5,5,-5])
				cylinder ( r=3.5, h=10 );
		}
	}	
}

module edgeSupport (position)
{
    if (generateSupports)
    {
        translate( position ) {
            translate([0,0,supportDiameter*3/8])
                rcylinder ( r=supportDiameter/2, h=cardHolderH-wallThickness-supportOffset, chamfer=supportDiameter*5/12-supportOffset );
            rcylinder ( r=supportDiameter/4, h=cardHolderH-wallThickness/2-supportOffset);
        }
    };
}

module cardEdgeGrips ()
{
    // bottom left
	translate ( [ edgeGripLength/2, 0, 2*cardHolderH ] )
	{
		union ()
		{
			rcard ( w=cardHolderL - edgeGripLength, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderL-edgeGripLength-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderL - edgeGripLength)/ supportDistance]) {
            edgeSupport([(i*supportDistance), 2*wallThickness-chamferDepth-supportDiameter/8, -cardHolderH/2-wallThickness/8+2*supportOffset]);
        }
	}
    
	// bottom right
    translate ( [ edgeGripLength/2, cardHolderW-(2*wallThickness), 2*cardHolderH] )
	{
		union ()
		{
			rcard ( w=cardHolderL - edgeGripLength, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderL-edgeGripLength-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}

        for(i = [0: (cardHolderL - edgeGripLength)/ supportDistance]) {
            edgeSupport([(i*supportDistance), 0+chamferDepth+supportDiameter/8, -cardHolderH/2-wallThickness/8+2*supportOffset]);
        }
	}
	
	// top left
    translate ( [ edgeGripLength/2, 0, 0] )
	{
		union ()
		{
			rcard ( w=cardHolderL - edgeGripLength, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderL-edgeGripLength-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderL - edgeGripLength)/ supportDistance]) {
            edgeSupport([(i*supportDistance), 2*wallThickness-chamferDepth-supportDiameter/8, cardHolderH/2-wallThickness/8-2*supportOffset]);
        }
	}
    // top right
	translate ( [ edgeGripLength/2, cardHolderW-(2*wallThickness), 0] )
	{
		union ()
		{
			rcard ( w=cardHolderL - edgeGripLength, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness-chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth);
			translate ( [cardHolderL-edgeGripLength-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderL - edgeGripLength)/ supportDistance]) {
        edgeSupport([(i*supportDistance), 0+chamferDepth+supportDiameter/8, cardHolderH/2-wallThickness/8-2*supportOffset]);
        }
	}

}

module cardSkid (x, y, z)
{
    translate ( [x, y, z] )
		    // card ( skidL, skidWidth, skidDepth );
        rotate ( [0, 90, 0] )
            rcylinder ( r=skidWidth/2, h=skidL, chamfer=chamferDepth );
}

module cardHolder ()
{
	union() {
	difference ()
	{
		rcard (cardHolderL, cardHolderW, 2*cardHolderH+wallThickness, chamferDepth );
			
        // left side slot
		translate ( [10, 8, cardHolderH-wallThickness] )
			card ( cardHolderL - edgeGripLength, 2*wallThickness, 4*wallThickness );

        // right side slot
		translate ( [10, cardHolderW - 2*wallThickness - 8, cardHolderH-wallThickness] )
			card ( cardHolderL - edgeGripLength, 2*wallThickness, 4*wallThickness );

        // bottom side cut out for card space
		translate ([wallThickness,wallThickness,wallThickness+cardHolderH])
			card (w=cardHolderL-2*wallThickness, l=cardHolderW-2*wallThickness, h=cardHolderH+wallThickness);

        // top side cut out for card space
		translate ([wallThickness,wallThickness,-wallThickness])
		card (w=cardHolderL-2*wallThickness, l=cardHolderW-2*wallThickness, h=cardHolderH+wallThickness);
		
        // grip arch at the bottom
		translate ([wallThickness/2, cardHolderW/2, 0])
			cylinder (  h=6*cardHolderH, r = cardGripArch, center=true);

	}

    
	skidDist = 15;
	count = 4;
	stop = cardHolderW - skidWidth - 2*skidDist;
	increment = stop/(count - 1);

	for(i = [0: count-1]) let(y = skidDist + skidWidth/2 + (i * increment)) {
		// bottom side skids
        cardSkid(cardHolderL/2 - skidL/2 + skidVerticalOffset, y, cardHolderH+wallThickness);
        // top side skids
        cardSkid(cardHolderL/2 - skidL/2 + skidVerticalOffset, y, cardHolderH-(skidDepth / 2) + cardThicknessTolerance*2);
	}

	// Top overhang
	cardEdgeGrips();
	// strap
	cardStrap(
	    chl=cardHolderL, 
	    chw=cardHolderW,
	    chh=cardHolderH,
	    wt=wallThickness,
	    sh=strapHeight,
	    tvp=textVerticalPosition,
	    st=strapText,
	    td=textDepth,
	    th=textHeight,
	    fn=fontName
	);
	}
}

if (oneHalf)
    rotate([180, 0, 0])
        difference() {
            cardHolder();
            translate ([-wallThickness, -wallThickness, (cardHolderH)+(wallThickness/2)])
                card(cardHolderL*2, cardHolderW*2, cardHolderH*2);
    }
else
    cardHolder();
