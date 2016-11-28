
						
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
/*
Tab n Slot module

A simple module to generate tabs and slots to make 2 objects interlock
Use slots(); with a difference to cut grooves
Use tab(); with a union to add tabs to the other object

just about everything I could think of is panametric, just watch that you don't set certain values to numbers that wouldn't work. Most of these are simple math to avoid.

To Do: currently generating 2 or more tabs cannont be compliled to look right but renders fine. Need to fix this to make life easier
Stops are not implemented so have to make own if groove protrude out the other side of the object
Need to add some error code to stop the use of values that will result in slots longer than possible and tabs that are too big for there to be enough room for grooves.
*/
//----------------------------------------------------------------------------


//test_slot_tab_diff();
module test_slot_tab_diff()
{
	$fn=60;
	depth = 5;
	dia = 30 - 2*2.5;
	numtabs=12;
	tabWidth_angle = 12;
	rotation = 48;
	difference()
	{
		slots_metric(groove_dia=dia,
		cutHole=false,
		depth=depth,
		tabHeight=depth/4,
		tabWidth=0,
		tabWidth_angle=tabWidth_angle,		
		rotation=rotation,
		tabNumber=numtabs,	
		tolerance=0.2,
		clockwise=true,
		gap=0.2,
		lock=0.3,
		stop=1,
		tabs_outward=true,
		pitch=2);

		tabs_metric(outer_dia=dia,
		fill_center=true, //fill center hole
		depth=depth,
		tabHeight=depth/4,
		tabWidth=0,
		tabWidth_angle=tabWidth_angle,	
		tabNumber=numtabs,		
		tolerance=0.2,
		gap=0.2,
		lock=0.3,
		stop=1,
		pitch=2,
		tabs_outward=true);
	}
}



// ---------------------------------------------------------------
// Functions
// ---------------------------------------------------------------

// At low $fn the cylinders are not round. For the same reason the created tab is
// not round too and because of unknown tab count. Therefore, to ensure that the tab
// connects to its base (Outer diameter) we add some "good measure" value.
function join_distance(tabs_outward, is_tab) =
			is_tab ?
				(tabs_outward ? -0.2 : 0.2)
				:
				(tabs_outward ? -0.2 : 0.2);

function get_clockwise(clockwise)=
	(clockwise?1:-1);

function get_tabWidth(tab_is_ref, tabWidth_angle, tabWidth, radius, tolerance) =
			tabWidth_angle!=0 ?
				2*sin(tabWidth_angle/2)*radius 
				: get_tabWidth_tol(tab_is_ref,tabWidth,tolerance);
		;
function get_tabWidth_angle(tab_is_ref, tabWidth_angle, tabWidth, radius, tolerance) =
			(tabWidth!=0 ?
			 width_to_angle(get_tabWidth_tol(tab_is_ref,tabWidth,tolerance),radius) 
			: tabWidth_angle);
		;
function get_tabWidth_tol(tab_is_ref, tabWidth, tolerance ) =
		tab_is_ref ? tabWidth : tabWidth - 2*tolerance;
function get_tabHeight_tol(tab_is_ref, tabWidth, tolerance ) =
		tab_is_ref ? tabHeight : tabHeight - 2*tolerance;

function width_to_angle(width, radius) =
			2*asin((width/2)/radius) ;


// ---------------------------------------------------------------
// Slots
// ---------------------------------------------------------------

//test_slots_metric();
module test_slots_metric(ref_dia = 30)
{
	depth = 5;
	numtabs=1;
	gap = 0.2;

	slots_metric(groove_dia=ref_dia,
			cutHole=false,
			depth=depth,
			tabHeight=depth/3,
			tabWidth=0,
			tabWidth_angle=12,		
			rotation=48,
			tabNumber=numtabs,	
			tolerance=0.2,
			clockwise=false,
			gap=gap,
			lock=0.2,
			stop=1,
			tabs_outward=false,
			pitch=2);
}
//test_slots();
module test_slots(ref_dia = 30)
{
	depth = 5;
	dia = ref_dia ;
	numtabs=4;
	tabWidth_angle = 12;
	rotation = 48;

	slots_metric(groove_dia=dia,
		cutHole=false,
		depth=depth,
		tabHeight=depth/4,
		tabWidth=0,
		tabWidth_angle=tabWidth_angle,		
		rotation=rotation,
		tabNumber=numtabs,	
		tolerance=0.2,
		clockwise=true,
		gap=0.2,
		lock=0.3,
		stop=1,
		tabs_outward=true,
		pitch=2);
}







module slots_metric(
			groove_dia=55, //diameter over grooves
			cutHole=true, 	//turn on or off the center hole
			depth=10,  		//how far you want to go in before turning
			tabHeight=3,	//tab height
			tabWidth=0,		//use width of tab or tab_angle
			tabWidth_angle=13,	//use tab_angle or tabWidth
			rotation=25,	//how far to rotate to lock, never set to 
							//more than 360/tabNumber
			tabNumber=2, 	//Number of tabs >= 1.
			tolerance=0.1, //Space hull around path of tab to provide 
							//some play. The total play in one direction
							//is 2*tolerance.
			clockwise=true, //which way you want to rotate
			gap=0.5, 		// gap (play) between tab zylinder and slot cylinder
			lock=0, 		//this adds a little indent and nub at the final 
							//resting point to make it harder to turn back, 
							//adjust to a value that is not too big just 
							//enough to make it click into place
			stop=1, 	//not implemented yet, to make a stop if the slot is
						// past the end of the object to make sure you can't 
						//rotate all the way back to the gap
			tabs_outward=true,
			pitch=1,    // metric slots need a pitch to calculate the groove depth
                      // This is used to get the same depth as a companion thread

){

	grooveDepth = groove_dia/2 - metric_minor_radius(groove_dia, pitch) +gap;
	minor_dia = groove_dia - (tabs_outward?1:0)*2*grooveDepth 
					+ (tabs_outward?0:1)*2*gap; //ensures correct cutout at low $fn
	slots(ref_dia=minor_dia, 
			slot_is_ref=false, //for metric slots the tabs are reference
			cutHole=cutHole, 
			depth = depth,
			grooveDepth=grooveDepth,
			tabHeight=tabHeight,
			tabWidth=tabWidth,
			tabWidth_angle=tabWidth_angle,		
			rotation=rotation,
			tabNumber=tabNumber,	
			tolerance=tolerance,
			clockwise=clockwise,
			gap=gap,
			lock=lock,
			stop=stop,
			tabs_outward = tabs_outward);
}

module slots(
			ref_dia=55, 	//diameter of center hole
			slot_is_ref=true, //is ref data for tabs or slots (gap, tolerance)
			cutHole=true, 	//turn on or off the center hole
			depth=10,  		//how far you want to go in before turning
			grooveDepth=4,	//how far in the tabs grip
			tabHeight=3,	//tab height
			tabWidth=0,		//use width of tab or tab_angle
			tabWidth_angle=0,	//use tab_angle or tabWidth
			rotation=24,	//how far to rotate to lock, never set to 
							//more than 360/tabNumber
			tabNumber=2, 	//Number of tabs >= 1.
			tolerance=0.1, //Space hull around path of tab to provide 
							//some play. The total play in one direction
							//is 2*tolerance.
			clockwise=true, //which way you want to rotate
			gap=0.5, 		// gap (play) between tab zylinder and slot cylinder
			lock=0, 		//this adds a little indent and nub at the final 
							//resting point to make it harder to turn back, 
							//adjust to a value that is not too big just 
							//enough to make it click into place
			stop=1, 	//not implemented yet, to make a stop if the slot is
						// past the end of the object to make sure you can't 
						//rotate all the way back to the gap
			tabs_outward=true

){

	slot_major_radius = 
		tabs_outward ?
			(slot_is_ref ? 
				ref_dia/2+grooveDepth+tolerance 
				: ref_dia/2+gap+grooveDepth+tolerance)
			:(slot_is_ref ? 
				ref_dia/2-grooveDepth-tolerance
				: ref_dia/2-gap-grooveDepth-tolerance)
	;
	slot_minor_radius =
		tabs_outward ?
			(slot_is_ref ? 
				ref_dia/2 
				: ref_dia/2+gap)
			:(slot_is_ref ? 
				ref_dia/2
				: ref_dia/2-gap)
	;

	inner_radius = tabs_outward ? slot_minor_radius : slot_major_radius;
	outer_radius = tabs_outward ? slot_major_radius : slot_minor_radius;
	echo("SLOTS");
	echo("inner_radius",inner_radius);
	echo("outer_radius",outer_radius);
	if(tabWidth!=0 && tabWidth_angle!=0)
	{	echo("Warning !!!");
		echo("Use either tabWidth or tabWidth_angle but not both.");}



	f_tabWidth_angle = get_tabWidth_angle(!slot_is_ref, tabWidth_angle, tabWidth, outer_radius, tolerance);
	f_tabWidth = get_tabWidth(!slot_is_ref, tabWidth_angle, tabWidth, outer_radius, tolerance);


	cut_x=ref_dia+2*grooveDepth+10;
	cut_y=ref_dia/2+grooveDepth+10;
	f_depth = slot_is_ref?depth:depth+tolerance;
	cut_depth = f_depth+0.01;

	rad_toomuch = outer_radius + 0.2; 
	difference()
	{
	union(){
		for(i = [0:tabNumber-1])
		{
			rotate((360/tabNumber)*i)
				translate([0,0,slot_is_ref?0:-tolerance])
					slot(outer_radius = rad_toomuch,
						inner_radius = inner_radius,
						tabHeight = tabHeight,
						f_depth = f_depth,
						cut_depth = cut_depth,
						clockwise = clockwise,
						rotation = rotation,
						f_tabWidth_angle = f_tabWidth_angle,
						tolerance = tolerance,
						lock = lock,
						cut_x = cut_x,
						cut_y = cut_y,
						cut_depth = cut_depth,
						tabs_outward = tabs_outward);
		}//end for

		if (needs_center())
			translate([0,0,slot_is_ref?0:-tolerance])
			cylinder(r=inner_radius + join_distance(tabs_outward), h=f_depth);
	} //end union


		//Subtract inner leftover of slots
		//It is outside of slot() module because with this
		//flanks of cylinder are nicely aligned ($fn)
		if (!needs_center())
			translate([0,0,(slot_is_ref?0:-tolerance)-0.005])
				cylinder(r=inner_radius + join_distance(tabs_outward), h=cut_depth);


		//subtract outer area to beautify protuded indent rod
		// and subtract rad_toomuch (needed to get aligned
		// facettes of cylinder ($fn and rotate of tabs)
		translate([0,0,-tolerance-0.01])
		difference()
		{
			cylinder(r=rad_toomuch+1, h=f_depth+tolerance+0.02);
			cylinder(r=outer_radius, h=f_depth+tolerance+0.02);
		}

	} //end difference

echo("needs_center()",needs_center());
	function needs_center() = tabs_outward && cutHole;

}
	


module slot(outer_radius, inner_radius,
						tabHeight, f_depth, cut_depth,
						clockwise, rotation, f_tabWidth_angle,
						tolerance, lock,
						cut_x, cut_y, cut_depth,
						tabs_outward)
{		
	render()
	{
			union()
			{

				difference()
				{
					cylinder(r=outer_radius, h=f_depth);
					// cuts covered slot flank
					rotate(get_clockwise(clockwise)
								*(rotation+f_tabWidth_angle/2+width_to_angle(tolerance, outer_radius)))
						translate([0,get_clockwise(clockwise)*(cut_y/2),cut_depth/2-0.005])
							cube([cut_x,cut_y,cut_depth],center=true);
					
					// cuts slot flank (whole depth)
					rotate(-get_clockwise(clockwise)
								*(f_tabWidth_angle/2+width_to_angle(tolerance, outer_radius)))
						translate([0,-get_clockwise(clockwise)*(cut_y/2),cut_depth/2-0.005])
							cube([cut_x,cut_y,cut_depth],center=true);
					//cuts top of covered slot				
					difference()
					{
						rotate(get_clockwise(clockwise)*(rotation-f_tabWidth_angle/2))
							translate([0,-(cut_y/2)*get_clockwise(clockwise),
										f_depth/2+tabHeight+tolerance])
								cube([cut_x,cut_y,f_depth],center=true);
					
						// little indent and nub(a rod from center 
						// well over hole radius) 
						if(lock>0)
						{
							translate([0,0,tabHeight+lock/2])
								rotate([0,90,0])
									cylinder(r=lock+tolerance, h=outer_radius+0.001, $fn=12);
						}
					} //end union

					//subtract opposite leftover per slot
					translate([-2*outer_radius,-outer_radius,-0.005])
						cube([2*outer_radius,2*outer_radius,cut_depth]);
				} //end difference	

			} // end union
	}
	
}
// ---------------------------------------------------------------
// Tabs Tabs Tabs
// ---------------------------------------------------------------

//test_tabs();
module test_tabs(ref_dia = 30)
{
	depth = 5;
	tabs(ref_dia=ref_dia,
		fill_center=true, //fill center hole
		tab_is_ref=true, 
		depth=depth,
		grooveDepth=ref_dia/10,
		tabHeight=ref_dia/12,
		tabWidth=ref_dia/8,
		tabWidth_angle=0,	
		tabNumber=4,	
		tolerance=0.1,
		gap=0.5,
		lock=0.2,
		stop=1);
}

//test_tabs_metric(outer_dia=30);
module test_tabs_metric(outer_dia=30)
{
	depth = 5;
	pitch=2;
	tabs_metric(outer_dia=outer_dia,
		fill_center=true, //fill center hole
		depth=depth,
		tabHeight=outer_dia/12,
		tabWidth=outer_dia/16,
		tabWidth_angle=0,	
		tabNumber=4,	
		tolerance=0.2,
		gap=0.5,
		lock=0.3,
		stop=1,
		pitch=pitch,
		tabs_outward=true);
}


module tabs_metric(
			outer_dia=55, 	//diameter over tabs
			fill_center=true, //fill center hole
			depth=10,  		//how far you want to go in before turning
			tabHeight=3,	//tab height
			tabWidth=0,		//use width of tab or tab_angle
			tabWidth_angle=0,	//use tab_angle or tabWidth
			tabNumber=2, 	//Number of tabs >= 1.
			tolerance=0.2, //Space hull around path of tab to provide 
							//some play. The total play in one direction
							//is 2*tolerance.
			gap=0.5, 		// gap (play) between tab zylinder and slot cylinder
			lock=0, 		//this adds a little indent and nub at the final 
							//resting point to make it harder to turn back, 
							//adjust to a value that is not too big just 
							//enough to make it click into place
			stop=1, 	//not implemented yet, to make a stop if the slot is
						// past the end of the object to make sure you can't 
						//rotate all the way back to the gap
			pitch=1,    // metric tabs need a pitch to calculate the groove depth
                      // This is used to get the same depth as a companion thread
			tabs_outward = true
){

	grooveDepth = outer_dia/2 - metric_minor_radius(outer_dia, pitch);
	ref_dia = outer_dia - (tabs_outward?1:0)*2*grooveDepth;
	tabs(ref_dia=ref_dia,
		fill_center=fill_center, //fill center hole
		tab_is_ref=true, //for metric tabs the tabs are reference
		depth=depth,
		grooveDepth=grooveDepth,
		tabHeight=tabHeight,
		tabWidth=tabWidth,
		tabWidth_angle=tabWidth_angle,
		tabNumber=tabNumber,	
		tolerance=tolerance,
		gap=gap,
		lock=lock,
		tabs_outward = tabs_outward);
}


module tabs(
			ref_dia=55, 	// base diameter of rod/hole 
							// where tabs are attached to
			fill_center=true, //fill center hole
			tab_is_ref=true,  //is ref data for tabs or slots (gap, tolerance)
			depth=10,  		//how far you want to go in before turning
			grooveDepth=4,	//how far in the tabs grip
			tabHeight=3,	//tab height
			tabWidth=0,		//use width of tab or tab_angle
			tabWidth_angle=0,	//use tab_angle or tabWidth
			tabNumber=2, 	//Number of tabs >= 1.
			tolerance=0.2, //Space hull around path of tab to provide 
							//some play. The total play in one direction
							//is 2*tolerance.
			gap=0.5, 		// gap (play) between tab zylinder and slot cylinder
			lock=0, 		//this adds a little indent and nub at the final 
							//resting point to make it harder to turn back, 
							//adjust to a value that is not too big just 
							//enough to make it click into place
			stop=1, 	//not implemented yet, to make a stop if the slot is
						// past the end of the object to make sure you can't 
						//rotate all the way back to the gap
			tabs_outward = false
){

	tab_major_radius = 
		tabs_outward ?
			(tab_is_ref ? 
				ref_dia/2+gap+grooveDepth
				: ref_dia/2+grooveDepth)
			:(tab_is_ref ? 
				ref_dia/2-gap-grooveDepth 
				: ref_dia/2-grooveDepth)
	;
	tab_minor_radius =
		tabs_outward ?
			(tab_is_ref ? 
				ref_dia/2
				: ref_dia/2-gap)
			:(tab_is_ref ? 
				ref_dia/2 
				: ref_dia/2+gap)
	;

	inner_radius = tabs_outward ? tab_minor_radius : tab_major_radius;
	outer_radius = tabs_outward ? tab_major_radius : tab_minor_radius;
	echo("TABS");
	echo("inner_radius",inner_radius);
	echo("outer_radius",outer_radius);
	if(tabWidth!=0 && tabWidth_angle!=0){
		echo("Warning !!!");
		echo("Use either tabWidth or tabWidth_angle but not both.");}

	f_tabWidth = get_tabWidth(tab_is_ref, tabWidth_angle, tabWidth, outer_radius, tolerance);
	f_tabWidth_angle = get_tabWidth_angle(tab_is_ref, tabWidth_angle, tabWidth, outer_radius, tolerance);
	f_tabHeight = tab_is_ref ? tabHeight : tabHeight - tolerance;

	if(lock<=tolerance && lock > 0){
		echo("Warning !!!");
		echo("Tolerance is bigger or equal to lock. Locking will not be cut.");}


	rad_toomuch = outer_radius + 0.2; 
	union()
	{
		for(i = [0:tabNumber-1])
		{
			//Single tab
			
			rotate((360/tabNumber)*i)
				translate([0,0,tab_is_ref?0:tolerance]) 
					tab(outer_radius = rad_toomuch,
						inner_radius = inner_radius,
						f_tabHeight = f_tabHeight,
						f_tabWidth_angle = f_tabWidth_angle, 
						lock = lock,
						tabs_outward = tabs_outward);

		} // end tab for loop

		if (tabs_outward && fill_center)
			translate([0,0,tab_is_ref?0:tolerance])
			cylinder(r=inner_radius, h=depth);

	} // end union
}

module tab(outer_radius, inner_radius,
			f_tabHeight,
			f_tabWidth_angle, 
			lock,
			tabs_outward )

{
	render()
	{
		difference()
			{
				union()
				{
					cylinder(r=outer_radius, h=f_tabHeight);
					// little indent and nub(a rod from center 
					// well over hole radius)
					if(lock>0)
					{
						translate([0,0,f_tabHeight])
							rotate([0,90,0])
								cylinder(r=lock, h=outer_radius, $fn=12);
					}
				}//end union

				// cuts right tab flank
				rotate(f_tabWidth_angle/2)
					translate([0,outer_radius,f_tabHeight/2])
						cube([2*(outer_radius+1), 2*outer_radius, f_tabHeight+0.001],center=true);
					
				// cuts left tab flank 
				rotate(-f_tabWidth_angle/2)
					translate([0,-outer_radius,f_tabHeight/2])
						cube([2*(outer_radius+1), 2*outer_radius, f_tabHeight+0.001],center=true);

				// subtract inner leftover per slot
				// make inner radius of tab smaller so it gets longer and
				// can cross the gap between tab and slot cylinder
				translate([0,0,-f_tabHeight])
				cylinder(r=inner_radius+join_distance(tabs_outward), h=f_tabHeight+2*f_tabHeight);

				// subtract outer area to beautify protuded indent rod (lock)
				translate([0,0,-0.01])
					difference()
					{
						cylinder(r=outer_radius+1, h=f_tabHeight+lock+0.02);
						cylinder(r=outer_radius, h=f_tabHeight+lock+0.02);
					}
			
				// subtract for turnability
				// The outer_radius defines the maximum radius (corners of cylinder) of 
				// the slot channel.
				// With low/uneven $fn ($fn=23) or small gaps the slot channel gets
				// eventually too narrow. So much that the the tab is no longer turnable.
				rotate([0,0,360/$fn/2])
				translate([0,0,-0.01])
				difference()
				{
					cylinder(r=outer_radius+1, h=f_tabHeight+lock+0.02);
					cylinder(r=outer_radius, h=f_tabHeight+lock+0.02);
				}
				
			}	// end tab difference
	}
}

