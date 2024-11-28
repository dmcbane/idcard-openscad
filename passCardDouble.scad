// https://github.com/Irev-Dev/Round-Anything
// use <Round-Anything/polyround.scad>
//https://github.com/BelfrySCAD/BOSL2.git
include <BOSL2/std.scad>

$fn = 256;
cardWidth = 87.61;
cardLength = 56.11;
cardHeight  = 2.25;
cardPerimeterTolerance = 0.51;
cardThicknessTolerance = 0.11;

wallThickness = 1.75;

cardHolderW = wallThickness + cardWidth + cardPerimeterTolerance;
cardHolderL = wallThickness + cardLength + cardPerimeterTolerance;
cardHolderH = wallThickness + cardHeight + cardThicknessTolerance;

strapText = "NIWC LANT 54200";
fontName = "DejaVu Sans:style=Condensed";
textHeight = 4.7;
textDepth = 0.33;
textVerticalPosition = 1.5;

skidDepth = 0.5;
skidWidth = 1.0;

strapHeight = 18;

oneHalf=false;

RoundedCube(size = [10, 10, 10], center = false,radius = 0.5,fn=10);


module RoundedCube(size = [1, 1, 1], center = false,radius = 0.5,fn=10){

obj_translate = (center == true) ?
[0, 0, 0] : [
(size[0] / 2),
(size[1] / 2),
(size[2] / 2)
];
    
    //echo (obj_translate);
translate(v = obj_translate) {
        hull(){
            cube([size[0]-radius-radius,size[1]-radius-radius,size[2]],center=true);
            cube([size[0]-radius-radius,size[1],size[2]-radius-radius],center=true);
            cube([size[0],size[1]-radius-radius,size[2]-radius-radius],center=true);
           
            translate ([size[0]/2-radius,size[1]/2-radius,size[2]/2-radius])
            sphere(r = radius,$fn = fn);
            translate ([-size[0]/2+radius,size[1]/2-radius,size[2]/2-radius])
            sphere(r = radius,$fn = fn);
            translate ([-size[0]/2+radius,-size[1]/2+radius,size[2]/2-radius])
            sphere(r = radius,$fn = fn);
            translate ([size[0]/2-radius,-size[1]/2+radius,size[2]/2-radius])
            sphere(r = radius,$fn = fn);
           
            translate ([size[0]/2-radius,size[1]/2-radius,-size[2]/2+radius])
            sphere(r = radius,$fn = fn);
            translate ([-size[0]/2+radius,size[1]/2-radius,-size[2]/2+radius])
            sphere(r = radius,$fn = fn);
            translate ([-size[0]/2+radius,-size[1]/2+radius,-size[2]/2+radius])
            sphere(r = radius,$fn = fn);
            translate ([size[0]/2-radius,-size[1]/2+radius,-size[2]/2+radius])
            sphere(r = radius,$fn = fn);
        }
    }
}

// card with fillet
module rcard( w, l, h, fillet )
{
    RoundedCube(size=[w, l, h], center=false, radius=fillet, fn=$fn);
	// // extrudeWithRadius(h,fillet,fillet,$fn)
    // linear_extrude(h)
	// square([w, l]);
}

// card no radius
module card ( w, l, h )
{
	cube ( [w, l, h] );
}

// cylinder with fillet
module rcylinder(r, h, fillet, center)
{
	//extrudeWithRadius(h,fillet,fillet,$fn)
    linear_extrude(h)
	circle(r);
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
            rcard ( sh, chl, wt, 0.5 );
            //translate([-wt, 0, 0])
            //    card ( sh/2, chl, wt);

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

module cardEdgeGrips ()
{
    // bottom left
	translate ( [ 20, 0, 2*cardHolderH ] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, fillet=0.5 );
			// Round the ends
			translate ( [0, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
			translate ( [cardHolderW - 40, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
		}
	}
    
	// bottom right
    translate ( [ 20, cardHolderL-(2*wallThickness), 2*cardHolderH] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, fillet=0.5 );
			// Round the ends
			translate ( [0, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
			translate ( [cardHolderW-40, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
		}
	}
	
	// top left
    translate ( [ 20, 0, 0] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, fillet=0.5 );
			// Round the ends
			translate ( [0, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
			translate ( [cardHolderW - 40, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
		}
	}
    // top right
	translate ( [ 20, cardHolderL-(2*wallThickness), 0] )
	{
		union ()
		{
			rcard ( w=cardHolderW - 40, l=2*wallThickness,  h=wallThickness, fillet=0.5 );
			// Round the ends
			translate ( [0, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5);
			translate ( [cardHolderW-40, wallThickness, 0] )
				rcylinder ( r=wallThickness, h=wallThickness, fillet=0.5 );
		}
	}

}

module cardSkid (x, y, z)
{
    translate ( [x, y, z] )
		    // card ( cardHolderW - 44, skidWidth, skidDepth );
        rotate ( [0, 90, 0] )
            rcylinder ( r=skidWidth/2, h=cardHolderW - 44, fillet=0.5 );
}

module cardHolder ()
{
	union() {
	difference ()
	{
		rcard (cardHolderW, cardHolderL, 2*cardHolderH+wallThickness, 0.5 );
			
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
        translate ([-wallThickness, -wallThickness, (cardHolderH)+(wallThickness/4*3)])
            card(cardHolderW*2, cardHolderL*2, cardHolderH*2);
    }
else
    cardHolder();