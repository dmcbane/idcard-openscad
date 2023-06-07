// https://github.com/Irev-Dev/Round-Anything
use <Round-Anything/polyround.scad>

$fn = 64;

cardMarginPer = 0.49;
cardMarginH = 0.09;
cardWidth = 87 + cardMarginPer;
cardLength = 55.5 + cardMarginPer;
cardHeight  = 3*0.76 + cardMarginH;

wallThickness = 1.89;

cardHolderW = wallThickness + cardWidth;
cardHolderL = wallThickness + cardLength;
cardHolderH = wallThickness + cardHeight;

myText = "YOUR COMPANY";
fontName = "Lato:style=Regular";
textSize = 4.05;
textDepth = 0.50;
textPosition = 1.50;

holderL = 18;

module rcard( w, l, h, fillet )
{
    extrudeWithRadius(h,fillet,fillet,30)
    square([w, l]);
}

module card ( w, l, h )
{
    cube ( [w, l, h] );
}

module rcylinder(r, h, fillet, center)
{
    extrudeWithRadius(h,fillet,fillet,30)
    circle(r);
}

module d1CardStrap ()
{
	difference ()
	{
		translate ( [cardHolderW, 0, cardHolderH] )
		{
			rcard ( holderL, cardHolderL, wallThickness, 0.5 );
			translate ( [textPosition,cardHolderL/2,wallThickness] )
				rotate ([0,0,-90])
                    linear_extrude(textDepth) 
                    text(myText, size=textSize, font=fontName, halign="center");
			translate ( [textPosition,cardHolderL/2,0] )
				rotate ([0,180,-90])
                    linear_extrude(textDepth) 
                    text(myText, size=textSize, font=fontName, halign="center");
		}
		//	cutting angles of strap
		translate ( [cardHolderW+holderL, -(holderL/2), cardHolderH] )
		{
			rotate ([0,0,180])
			{
				cylinder ( r=holderL+wallThickness, h=10, center=true );
			}
		}
		translate ( [cardHolderW+holderL, cardHolderL+(holderL/2), cardHolderH] )
		{
			rotate ([0,0,180])
			{
				cylinder ( r=holderL+wallThickness, h=10, center=true );
			}
		}
	
		// Strap hole
		translate ( [(cardHolderW+(holderL/2)-0.5), cardHolderL/2-5, cardHolderH-1] )
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

module topStops ()
{
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

module d1CardHolder ()
{
	union() {
	difference ()
	{
            rcard (cardHolderW, cardHolderL, 2*cardHolderH+wallThickness, 0.5 );
            
			translate ( [10, 8, cardHolderH-wallThickness] )
				card ( cardHolderW - 40, 2*wallThickness, 4*wallThickness );
				
			translate ( [10, cardHolderL - 2*wallThickness - 8, cardHolderH-wallThickness] )
				card ( cardHolderW - 40, 2*wallThickness, 4*wallThickness );

			 translate ([wallThickness,wallThickness,wallThickness+cardHolderH])
				card (w=cardHolderW-2*wallThickness, l=cardHolderL-2*wallThickness, h=cardHolderH+wallThickness);

			 translate ([wallThickness,wallThickness,0])
				card (w=cardHolderW-2*wallThickness, l=cardHolderL-2*wallThickness, h=cardHolderH);
        
		translate ([0, (cardHolderL)/2, 0])
		 	cylinder (  h=5*cardHolderH, r = 8, center=true);

	}

    wallDist = 15;
    count = 4;
    stop = cardHolderL - 2*0.5 - 2*wallDist;
    increment = stop/(count - 1);

    for(i = [0: count-1]) let(y = wallDist + (i * increment)) {
        translate ( [12, y, cardHolderH+wallThickness] )
            card ( cardHolderW - 44, 0.5, 0.3 );

        translate ( [12, y, cardHolderH-0.3] )
            card ( cardHolderW - 44, 0.5, 0.3 );
    }

	// Top overhang
	topStops();
	d1CardStrap();
	}
}

d1CardHolder();
// example card...
translate ([wallThickness, wallThickness, wallThickness])
{
	*#card ( 86, 54, 0.8 );
}
