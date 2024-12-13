// cd into the User Library Path
// git clone https://github.com/BelfrySCAD/BOSL2.git
include <BOSL2/std.scad>

// steps in curves
$fn = 256;
// card width mm
cardWidth = 87.61;
// card width mm
cardLength = 56.11;
// card thckness mm
cardHeight  = 2.25;
// perimeter tolerance mm
cardPerimeterTolerance = 0.51;
// thickness tolerance mm
cardThicknessTolerance = 0.11;
// chamfer mm
chamferDepth = 0.5;
// wall thickness mm
wallThickness = 1.75;

// Select Strap Text
strapText = "";
//strapText = "NIWC LANT 54200";
//strapText = "NIWC LANT 54210";
//strapText = "NIWC LANT 54220";
//strapText = "NIWC LANT 54230";
//strapText = "NIWC LANT 54250";
//strapText = "NIWC LANT 54260";
//strapText = "NIWC LANT 54270";
//strapText = "NIWC LANT 59150";
//strapText = "NIWC LANT 89500";
//strapText = "U.S. ARMY";
//strapText = "DOI  USGS";
// Select Strap Text Font
fontName = "DejaVu Sans:style=Condensed";
// text height mm
textHeight = 4.7;
// text depth mm
textDepth = 0.5;
// text vertical position mm
textVerticalPosition = 1.5;
// skid depth mm
skidDepth = 0.5;
// skid width mm
skidWidth = 1.0;
// strap height mm
strapHeight = 18;
// Render only one side of the card holder
oneHalf = true;
// Generate supports for 3D printing horizontally
generateSupports = true;
// Support diameter mm
supportDiameter=1;
// Support to model distance
supportOffset=0;


// card size calculations
cardHolderW = wallThickness + cardWidth + cardPerimeterTolerance;
cardHolderL = wallThickness + cardLength + cardPerimeterTolerance;
cardHolderH = wallThickness + cardHeight + cardThicknessTolerance;

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


// chw = cardHolderW - card holder width
// chl = cardHolderL - card holder length
// chh = cardHolderH - card holder height
// wt = wallThickness - wall thickness
// sh = strapHeight - strap height
// tvp = textVerticalPosition - text vertical position on strap
// st = strapText - the text to be displayed on the strap
// td = textDepth - the distance the text is extruded from the face of the strap
// th = textHeight - the size/height of the text
// fn = fontName - the name of the type face used to render the text
module cardStrap (chw, chl, chh, wt, sh, tvp, st, td, th, fn)
{
	difference ()
	{
		// text
        translate ( [chw, 0, chh] )
		{
            translate ( [-chamferDepth, 0, 0])
                card ( sh+chamferDepth, chl, wt );

			translate ( [tvp,chl/2,wt] )
				rotate ([0,0,-90])
			        linear_extrude(td) 
			        text(st, size=th, font=fn, halign="center");
			translate ( [tvp,chl/2,0] )
				rotate ([0,180,-90])
					linear_extrude(td) 
					text(st, size=th, font=fn, halign="center");
		}
		//	cutting corners of strap
        translate( [ chw, sh, 0 ] )
        {
            rotate( [ 0, 0, 270 ] )
            {
                cornerCutter( r1=sh, r2=sh*2, ht=10 );
            }
        }
        translate([chw, chl-sh, 0])
            cornerCutter(r1=sh, r2=sh*2, ht=10);
            	
		// Strap hole
		translate ( [(chw+(sh/2)-0.5), chl/2-5, chh-1] )
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
        translate( position )
            rcylinder ( r=supportDiameter/2, h=cardHolderH-wallThickness-supportOffset, chamfer=supportDiameter*5/12-supportOffset );
    };
}

module cardEdgeGrips ()
{
    // bottom left
	translate ( [ 20, 0, 2*cardHolderH ] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderW-40-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderW - 40)/ 5 + 1]) {
            edgeSupport([(i*5), 2*wallThickness-chamferDepth-supportDiameter/8, -cardHolderH/2-wallThickness/8+2*supportOffset]);
        }
	}
    
	// bottom right
    translate ( [ 20, cardHolderL-(2*wallThickness), 2*cardHolderH] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderW-40-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}

        for(i = [0: (cardHolderW - 40)/ 5 + 1]) {
            edgeSupport([(i*5), 0+chamferDepth+supportDiameter/8, -cardHolderH/2-wallThickness/8+2*supportOffset]);
        }
	}
	
	// top left
    translate ( [ 20, 0, 0] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
			translate ( [cardHolderW-40-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderW - 40)/ 5 + 1]) {
            edgeSupport([(i*5), 2*wallThickness-chamferDepth-supportDiameter/8, cardHolderH/2-wallThickness/8-2*supportOffset]);
        }
	}
    // top right
	translate ( [ 20, cardHolderL-(2*wallThickness), 0] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, chamfer=chamferDepth );
			// Round the ends
			translate ( [(wallThickness-chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth);
			translate ( [cardHolderW-40-(wallThickness - chamferDepth)/2, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, chamfer=chamferDepth );
		}
        
        for(i = [0: (cardHolderW - 40)/ 5 + 1]) {
        edgeSupport([(i*5), 0+chamferDepth+supportDiameter/8, cardHolderH/2-wallThickness/8-2*supportOffset]);
        }
	}

}

module cardSkid (x, y, z)
{
    translate ( [x, y, z] )
		    // card ( cardHolderW - 44, skidWidth, skidDepth );
        rotate ( [0, 90, 0] )
            rcylinder ( r=skidWidth/2, h=cardHolderW - 44, chamfer=chamferDepth );
}

module cardHolder ()
{
	union() {
	difference ()
	{
		rcard (cardHolderW, cardHolderL, 2*cardHolderH+wallThickness, chamferDepth );
			
        // left side slot
		translate ( [10, 8, cardHolderH-wallThickness] )
			card ( cardHolderW - 40, 2*wallThickness, 4*wallThickness );

        // right side slot
		translate ( [10, cardHolderL - 2*wallThickness - 8, cardHolderH-wallThickness] )
			card ( cardHolderW - 40, 2*wallThickness, 4*wallThickness );

        // bottom side cut out for card space
		translate ([wallThickness,wallThickness,wallThickness+cardHolderH])
			card (w=cardHolderW-2*wallThickness, l=cardHolderL-2*wallThickness, h=cardHolderH+wallThickness);

        // top side cut out for card space
		translate ([wallThickness,wallThickness,-wallThickness])
		card (w=cardHolderW-2*wallThickness, l=cardHolderL-2*wallThickness, h=cardHolderH+wallThickness);
		
        // grip arch at the bottom
		translate ([0, (cardHolderL)/2, 0])
			cylinder (  h=5*cardHolderH, r = 8, center=true);

	}

	wallDist = 15;
	count = 4;
	stop = cardHolderL - skidWidth - 2*wallDist;
	increment = stop/(count - 1);

	for(i = [0: count-1]) let(y = wallDist + (i * increment)) {
		// bottom side skids
        cardSkid(12, y, cardHolderH+wallThickness);
        // top side skids
        cardSkid(12, y, cardHolderH-(skidDepth / 2) + cardThicknessTolerance*2);
	}

	// Top overhang
	cardEdgeGrips();
	// strap
	cardStrap(
	    chw=cardHolderW, 
	    chl=cardHolderL,
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
    difference() {
        cardHolder();
        translate ([-wallThickness, -wallThickness, (cardHolderH)+(wallThickness/2)])
            card(cardHolderW*2, cardHolderL*2, cardHolderH*2);
    }
else
    cardHolder();