/*
 * Dan Kirshner - dan_kirshner@yahoo.com
 * Chow Loong Jin - hyperair@debian.org
 *
 * You are welcome to make free use of this software.  Retention of my
 * authorship credit would be appreciated.
 *
 * Version 1.7   2014-10-19   indazoo
 *                            - added printify for inset threads so no
 *                              90 degree overhang ocurs.
 *                            - too smal polygons cannot be rendered by openscad
 * Version 1.6   2014-10-17   indazoo
 *                            - now fully supports backlash and clearance
 *                            - internal(nut) and bolt synchronized to allow
 *                              difference of two threads without cut throughs.
 *                            - debug code added showing thread in 2D space
 * Version 1.5   2014-10-13   indazoo
 *                            intermediate release
 * Version 1.4   2014-10-11   indazoo:  
 *                            - trapezoidal_thread(), speed up/memory bloat: 
                                pre calculate angles outside function
 *                            - trapezoidal_thread(), speed up/memory bloat: 
                                the for loops inside trapezoidal_thread() were
 *                              called too often
 *                            - trapezoidal_thread():
 *                              removed undocumented "good measure" value from
 *                              polygon calculation which created irregular 
 *                            - added right/left handed option for all thread types
 *                            - limited height of test threads (faster test)
 *                            - using accurate sin(),cos(),tan() because in OpenScad 2014.01
 *                              these functions deliver non-zero values for special angles.
 *                              This resulted in "simple=no" compilation when combining
 *                              a thread with another object because the flat ends of the
 *                              generated threads were not really flat.
 *                              https://github.com/openscad/openscad/issues/977
 * Version 1.3.  2013-12-01   Correct loop over turns -- don't have early cut-off
 * Version 1.2.  2012-09-09   Use discrete polyhedra rather than linear_extrude()
 * Version 1.1.  2012-09-07   Corrected to right-hand threads!

 * TODO:
 *  - artifacts from linear_extrude on low $fn
 */

//$fn=60; //needs high $fn or low $fa for nice output

// -------------------------------------------------------------------
// Parameters
//
// -------------------------------------------------------------------
// internal 
//            true = clearances for internal thread (e.g., a nut).
//            false = clearances for external thread (e.g., a bolt).
//            (Internal threads may be "cut out" from a solid using
//            difference()).
//
// n_starts  
//            Number of thread starts (e.g., DNA, a "double helix," has
//            n_starts=2).  See wikipedia Screw_thread.
//
// backlash 
//            Distance by which an ideal bolt can be moved in an ideal 
//            nut(internal) in direction of its axis.
//            "backlash" does not influence a bolt (internal = false)
// 
// clearance  
//             Distance between the flat portions of the nut(internal) and bolt.
//             With backlash==0 the nut(internal) and bolt will not have any
//             play no matter what "clearance" used, because the flanks will 
//             fit exactly. For 3D prints "clearance" is probably needed if
//             one does not uses a bigger "diameter" for the nut.
//             "clearance" does not influence a bolt (internal = false)
//  
// printify_top
// printify_bottom
//             Creates a slope on top/bottom from inner to outer diamter 
//             providing a defined end.
//             Maybe you want to add a thread to a rod. If the rod
//             diameter is the same or larger than the thread's minor 
//             diameter, a 90 degree overhang is being created which is
//             difficult to print for certain 3D printers(assuming 
//             printing the thread vertically). 




// -------------------------------------------------------------------
// Test threads
// -------------------------------------------------------------------

//test_thread();
//test_threads();
//test_min_openscad_fs();
//test_leftright_buttress();
//test_internal_difference();
//test_internal_difference_buttress();
//test_internal_difference_buttress_lefthanded();
//test_internal_difference_metric_cut();

module test_thread ($fa=5, $fs=0.1)
{
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 3, 
		internal=false, 
		n_starts=1, 
		right_handed=true,
		printify_top = false
	);
}

module test_threads ($fa=5, $fs=0.1)
{
    // M8
    metric_thread(8, 1.5, 5);
    translate ([-10, 0, 0])
        metric_thread(8, 1.5, 5, right_handed=false);

    translate ([10, 0, 0])
    square_thread(8, 1.5, 5);

    translate ([20, 0, 0])
    acme_thread(8, 1.5, 5);

    translate ([30, 0, 0])
    buttress_thread(8, 1.5, 5);

    translate ([40, 0, 0])
    english_thread(1/4, 20, 1/4);

    // Rohloff hub thread:
    translate ([65, 0, 0])
    metric_thread(34, 1, 5, internal=true, n_starts=6);
}

module test_min_openscad_fs ($fs=0.1)
{
	// This thread creates polygon angles which are very small
	// so the limit of OpenScad is reached without the use 
	// of "min_openscad_fs" (see code below).
	$fn=16;
	metric_thread(34, 1, 1, internal=false, n_starts=1);
}

module test_internal_difference_metric($fa=5, $fs=0.1)
{
	difference()
	{
	metric_thread(34, 2, 10, internal=true, n_starts=1, clearance = 0.1, backlash=0.4);
	metric_thread(34, 2, 10, internal=false, n_starts=1, clearance = 0.1, backlash=0.4);
	}
}

module test_internal_difference_metric_cut($fa=5, $fs=0.1)
{
	difference()
	{
	metric_thread(34, 2, 10, internal=true, n_starts=3, clearance = 0.1, backlash=0.4);
	metric_thread(34, 2, 10, internal=false, n_starts=3, clearance = 0.1, backlash=0.4);
	translate([10,10,0]) cube([20,20,20], center=true);
	}
}


module test_internal_difference_buttress($fa=5, $fs=0.1)
{
	difference()
	{
	buttress_thread(20, 1.9, 11.1, internal=true, n_starts=1,
					buttress_angles = [7, 44], 
					clearance = 0.1, backlash=0.4);
	buttress_thread(20, 1.9, 11.1, internal=false, n_starts=1, 
					buttress_angles = [7, 44],
					clearance = 0.1, backlash=0.4);
	}
}

module test_internal_difference_buttress_lefthanded($fa=5, $fs=0.1)
{
	difference()
	{
	buttress_thread(20, 1.9, 11.1, internal=true, n_starts=1,
					buttress_angles = [7, 44], 
					right_handed = false,
					clearance = 0.1, backlash=0.4);
	buttress_thread(20, 1.9, 11.1, internal=false, n_starts=1, 
					buttress_angles = [7, 44],
					right_handed = false,
					clearance = 0.1, backlash=0.4);
	}
}

module test_leftright_buttress($fa=5, $fs=0.1)
{
	buttress_thread(20, 1.9, 5.1, internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=true ,
					clearance = 0.1, backlash=0.4);
	translate([20,0,0])
		buttress_thread(20, 1.9, 5.1, internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=false ,
					clearance = 0.1, backlash=0.4);
}


// ----------------------------------------------------------------------------
//
// Debug: it is useful to show the profile in 2D
// Set "debug = true" and plot an internal and a bolt thread.
// This displays both profiles and how they fit.
//
// ----------------------------------------------------------------------------
debug = false;
//test_profile();

module test_profile()
{	
	metric_thread(34, 2, 10, internal=true, n_starts=1, clearance = 0.1, backlash=0.4);
	metric_thread(34, 2, 10, internal=false, n_starts=1, clearance = 0.1, backlash=0.4);
}

// ----------------------------------------------------------------------------
use <../general/utilities.scad>
use <../general/math.scad>

// ----------------------------------------------------------------------------
            
module metric_thread (
		diameter = 8,
		pitch = 1,
		length = 1,
		internal = false,
		n_starts = 1,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
    trapezoidal_thread (
			pitch = pitch,
			length = length,
			upper_angle = 30, 
			lower_angle = 30,
			outer_flat_length = pitch / 8,
			major_radius = diameter / 2,
			minor_radius = diameter / 2 - 5/8 * cos(30) * pitch,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom
			);
}

module square_thread (
		diameter = 8,
		pitch = 1,
		length = 1,
		internal = false,
		n_starts = 1,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
    trapezoidal_thread (
			pitch = pitch,
			length = length,
			upper_angle = 0, 
			lower_angle = 0,
			outer_flat_length = pitch / 2,
			major_radius = diameter / 2,
			minor_radius = diameter / 2 - pitch / 2,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom
			);
}

module acme_thread (
		diameter = 8,
		pitch = 1,
		length = 1,
		internal = false,
		n_starts = 1,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
    trapezoidal_thread (
			pitch = pitch,
			length = length,
			upper_angle = 29/2, 
			lower_angle = 29/2,
			outer_flat_length = 0.3707 * pitch,
			major_radius = diameter / 2,
			minor_radius = diameter / 2 - pitch / 2,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom
			);
}

module buttress_thread (
		diameter = 8,
		pitch = 1,
		length = 1,
		internal = false,
		n_starts = 1,
		buttress_angles = [3, 33],
		pitch_flat_ratio = 6,       // ratio of pitch to flat length
		pitch_depth_ratio = 3/2,     // ratio of pitch to thread depth
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
    trapezoidal_thread (
			pitch = pitch,
			length = length,
			upper_angle = buttress_angles[0], 
			lower_angle = buttress_angles[1],
			outer_flat_length = pitch / pitch_flat_ratio,
			major_radius = diameter / 2,
			minor_radius = diameter / 2 - pitch / pitch_depth_ratio,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom
			);
}


// ----------------------------------------------------------------------------
// Input units in inches.
// Note: units of measure in drawing are mm!
module english_thread(
		diameter=0.25, 
		threads_per_inch=20, 
		length=1,
		internal=false, 
		n_starts=1,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
	// Convert to mm.
	mm_diameter = diameter*25.4;
	mm_pitch = (1.0/threads_per_inch)*25.4;
	mm_length = length*25.4;

	echo(str("mm_diameter: ", mm_diameter));
	echo(str("mm_pitch: ", mm_pitch));
	echo(str("mm_length: ", mm_length));
	metric_thread(mm_diameter, 
			mm_pitch, 
			mm_length, 
			internal, 
			n_starts, 
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom
			);
}

/**
 * trapezoidal_thread():
 * generates a screw with a trapezoidal thread profile
 *
 * pitch = distance between the same part of adjacent teeth
 * length = length of the screw to generate
 * upper_angle = angle between the normal and the upper slant of a tooth
 * lower_angle = ditto, but for the lower slant
 * outer_flat_length = length of the flat part of the tooth along the outside
 * major_radius = radius of the screw until the outer flat
 * minor_radius = radius of the screw until the inner flat
 * internal = if true, generates a thread suitable for difference() to make nuts
 * n_starts = number of threads winding the screw
 */
module trapezoidal_thread (
	pitch,
	length,
	upper_angle,
	lower_angle,
	outer_flat_length,
	major_radius,
	minor_radius,
	internal = false,
	n_starts = 1,
	right_handed = true,
	clearance = 0,
	backlash = 0,
	printify_top = false,
	printify_bottom = false
)
{
    // trapezoid calculation:
    /*
                upper flat
            ___________________
           /|                 |\
          / |                 | \
    left /__|_________________|__\ right
   angle|   |   lower flat    |   |angle
        |   |                 |   |
        |left                 |right
         flat                 |flat
    */
    // looking at the tooth profile along the upper part of a screw held
    // horizontally, which is a trapezoid longer at the bottom flat
	tooth_height = major_radius - minor_radius;

	major_radius = internal ? (major_radius+clearance) : major_radius;
	minor_radius = internal ? (minor_radius+clearance) : minor_radius;

   	left_angle = right_handed ? (90 - upper_angle) : 90 - lower_angle;
   	right_angle = right_handed ? (90 - lower_angle) : 90 - upper_angle;


	// extreme difference of the clearance/backlash combinations
	/*

      large clearance        small clearance
      small backlash         large backlash

      ==> upper flat         ==> upper flat
          gets smaller           gets wider
      ==> start point of     ==> start point of
          left angle moves       left angle moves
          to the right           to the left
                 _____         
                /
               /         
              / ______    
    _________/ /                 __________________ 
              /                 /           _______
             /             ____/           /   
    ________/              _______________/    

	*/
	tan_left = accurateTan(90-left_angle);
	tan_right = accurateTan(90-right_angle);

	upper_flat = outer_flat_length + 
		(internal ?
			( 	tan_left*clearance >= backlash/2 ?
					- tan_left*clearance-backlash/2
					- tan_right*clearance-backlash/2
					: 
					+ backlash/2-tan_left*clearance
					+ backlash/2-tan_right*clearance
			)
		:0);
	if(upper_flat<=0)
	{
		echo("*** Warning !!! ***");
		echo("trapezoidal_thread(): upper_flat is smaller than zero!");
	}

	left_flat = tooth_height / accurateTan (left_angle);
	right_flat = tooth_height / accurateTan (right_angle);
	lower_flat = upper_flat + left_flat + right_flat;
	vert_l_backlash = (left_angle != 0 ?
					 	(backlash/2)/ accurateTan(90-left_angle)
						: 0);
	vert_r_backlash = (right_angle != 0 ?
					 	(backlash/2)/ accurateTan(90-right_angle)
						: 0);

    // facet calculation
    facets = $fn > 0 ? 
				$fn :
    			max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));
    facet_angle = 360 / facets;
    $fa = length2twist (length) / round (length2twist (length) / facet_angle);
	min_openscad_fs = 0.01;

	angle = 0;
	angle_corner_case = 0;

    // convert length along the tooth profile to angle of twist of the screw
    function length2twist (length) = length / pitch * (360 / n_starts);
    function twist2length (angle) = angle / (360 / n_starts) * pitch;

	//Calculations of angles moved out of get_radius() and therefore 
   //not called in linear_extrude loops (faster).
    angle_left_flat = length2twist (left_flat);
	angle_upper_flat = length2twist (upper_flat);
    angle_left_upper_flat = length2twist (left_flat + upper_flat);
    angle_lower_flat = length2twist (lower_flat);
	if(angle_lower_flat>=360)
	{
		echo("*** Warning !!! ***");
		echo("trapezoidal_thread(): no inner flat!");
	}
	
/*	echo("**** trapezoidal_thread ******");
	echo("internal", internal);
	echo("right_handed", right_handed);
	echo("tooth_height", tooth_height);
	echo("facets",facets);
	echo("facet_angle",facet_angle);
	echo("$fa (slice step angle)",$fa);
	echo("$fn (slice step angle)",$fn);

	echo("outer_flat_length", outer_flat_length);
	echo("left_angle", left_angle);	
	echo("left_flat", left_flat);
	echo("upper_flat", upper_flat);
	echo("right_angle", right_angle);
	echo("right_flat", right_flat);
	echo("clearance", clearance);
	echo("backlash",backlash);
	echo("major_radius",major_radius);
	echo("minor_radius",minor_radius);
	echo("angle_left_flat",angle_left_flat);	
	echo("angle_upper_flat",angle_upper_flat);
	echo("angle_left_upper_flat",angle_left_upper_flat);	
	echo("angle_lower_flat",angle_lower_flat);
	echo("internalThread_rot_offset",internal_thread_rot_offset());
	echo("******************************");*/

	function get_l_vBacklash() = internal ? vert_l_backlash : 0;
	function get_r_vBacklash() = internal ? vert_r_backlash : 0;

    // polar coordinate function representing tooth profile
    function get_radius (plane_angle) =
    minor_radius +
    (
        // left slant
        (plane_angle < angle_left_flat) ?
        accurateTan (left_angle) * twist2length (plane_angle) :

        // upper flat portion
        (plane_angle < angle_left_upper_flat) ?
        tooth_height:

        // right slant
        (plane_angle < angle_lower_flat) ?
        accurateTan (right_angle) * (lower_flat - twist2length (plane_angle)):

        // past the end of the tooth
        0
    );

    // obtain vertex for angle on cross-section 
    function get_vertex (angle) =
    		conv2D_polar2cartesian ([get_radius (angle), angle]);
	function vertex_length (point) =
			sqrt(pow(point[0],2)+pow(point[1],2));

	// An internal thread must be rotated because the calculation starts	
	// at base corner of left flat which is not exactly over base
	// corner of bolt (clearance and backlash)
	// Combination of small backlash and large clearance gives 
	// positive numbers, large backlash and small clearance negative ones.
	function internal_thread_rot_offset() = 
		internal ?
			length2twist(
				( 	tan_left*clearance >= backlash/2 ?
					tan_left*clearance-backlash/2
					: 
					-(backlash/2-tan_left*clearance)
				))
			: 0;

	function next_angle(i, angle) =
		(i<(facets-1))? angle+$fa : 360;
	function previous_angle(i, angle) =
		(i<(facets-1))? angle-$fa : 0;

	module thread()
	{
	if(!debug)
	{
    linear_extrude (
        height = length,
        twist = (right_handed ? -1 : 1) * (length2twist (length)),
        slices = length2twist (length) / $fa
    )
    union () {

        // This two for loops create a plane cutted vertically 
        // through  the screw axis of the thread. 
        // Must also create correct polygons for uneven $fn values.

       for (start = [0:n_starts-1])
       rotate ([0, 0, start / n_starts * 360 + internal_thread_rot_offset()])
		for (i = [0:facets-1])
		{
			assign(angle = i*$fa)
			{
				// Draw the profile of the tooth along the perimeter of
				// circle(minor_radius).
				// Often, facet_angle and flat angles (angle_left_flat, 
				// angle_left_upper_flat, angle_lower_flat) are not in sync.
				// With angle_corner_case we can insert another polygon in the
				// thread corners.
				// min_openscad_fs:
				// "angle" may be slightly smaller/greater than one of the
				// three corner angles. Then a too small polygon could be 
				// created and OpenScad would complain.
				assign(angle_corner_case = 
						((angle < angle_left_flat-min_openscad_fs) ? 
							angle_left_flat
						: ((angle < angle_left_upper_flat-min_openscad_fs) ? 
							angle_left_upper_flat
						: ((angle < angle_lower_flat-min_openscad_fs) ? 
							angle_lower_flat 
						: 360)))
						)
				{
					if(next_angle(i,angle) <= angle_corner_case + min_openscad_fs)
					{
						get_polygon(angle, next_angle(i,angle));
					}
					else 
					{
						get_polygon(angle, angle_corner_case);
						get_polygon(angle_corner_case, next_angle(i,angle));
					}
				}
			}
		}
	} 
	}
	else
	{
		for (i = [0:facets-1]) //was: for (angle = [0:$fa:360-$fa])
		{
			assign(angle = i*$fa) 
			{
				// Draw the profile of the tooth along the perimeter of
				// circle(minor_radius).
				// All 2D polygons must be calculated by same case in get_radius().
				// TODO: what if step > left_angle?  (square thread)
				assign(angle_corner_case = 
						((angle < angle_left_flat) ? angle_left_flat
						: ((angle < angle_left_upper_flat) ? angle_left_upper_flat
						: ((angle < angle_lower_flat) ? angle_lower_flat : 360)))
						)
				{
					echo("corner_case_angle",angle_corner_case);
					if(next_angle(i,angle) <= angle_corner_case)
					{
						get_debug_polygon(angle, next_angle(i,angle));
					}
					else 
					{
						get_debug_polygon(angle, angle_corner_case);
						get_debug_polygon(angle_corner_case, next_angle(i,angle));
					
					}
				} //end of assign border
			} //end of assign angle
		} //end of for loop
	} //end debug
	} //end thread module


	// --------------
	// Printify 
	// Draw 3D filler polygons to printify the output 
	// Fills rights slant, lower flat, left slant  
	// TODO
	// - from/to angles to switch for right/left threads?  ==> yes !!!
	// 
	// --------------
	module printify(printify_top=false, printify_bottom=false)
	{
		
		printify_h_top = accurateTan(internal && right_handed ? 
										90-right_angle : 90-left_angle )
					*(major_radius-minor_radius);
		printify_h_bottom = accurateTan(internal && right_handed ?
											 90-left_angle :90-right_angle)
					*(major_radius-minor_radius);
		if(internal)
		{
			if(printify_top)
			{
				translate([0,0,length-printify_h_top])
					difference()
					{
						cylinder(printify_h_top,major_radius,major_radius);
						cylinder(printify_h_top,major_radius,minor_radius);
					}
			}
			if(printify_bottom)
			{
				translate([0,0,0])
					difference()
					{
						cylinder(printify_h_bottom,major_radius,major_radius);
						cylinder(printify_h_bottom,minor_radius, major_radius);
					}
			}
		}
		else
		{
			if(printify_top)
			{
				translate([0,0,length-printify_h_top])
					cylinder(printify_h_top,minor_radius,major_radius);
			}
			if(printify_bottom)
			{
				translate([0,0,0])
					cylinder(printify_h_bottom,major_radius,minor_radius);
			}
		}
	}
	

	module get_polygon(angle_from, angle_to)
	{
		/* echo("from angle ", angle_from, vertex_length (get_vertex (angle_from)));
		echo("to angle ", angle_to, vertex_length (get_vertex (angle_to)));
		echo([	[0, 0],
           	get_vertex (angle_from),
           	get_vertex (angle_to)
            ]); */

		polygon (points=[
                    	[0, 0],
                    	get_vertex (angle_from),
                    	get_vertex (angle_to)
                			]);
	}

	module get_debug_polygon(angle_from, angle_to)
	{
		echo("from angle ", angle_from, vertex_length (get_vertex (angle_from)));
		echo("to angle ", angle_to, vertex_length (get_vertex (angle_to)));
		echo([	[getx_debug(angle_from) , get_radius(angle_from)],
            	[getx_debug(angle_to),get_radius(angle_to)],
				[getx_debug(angle_to),gety_debug()],
				[getx_debug(angle_from),gety_debug()]
             ]);
		polygon (points=[[getx_debug(angle_from) , get_radius(angle_from)],
            				[getx_debug(angle_to),get_radius(angle_to)],
							[getx_debug(angle_to),gety_debug()],
							[getx_debug(angle_from),gety_debug()]
             				]);
	}

	function getx_debug(angle) = internal?
							(angle+internal_thread_rot_offset())/10
							:(angle/10);
	function gety_debug() = internal ? 
						major_radius + minor_radius - clearance  
						: 0; 

	// ------------------------------------------------------
	// plot thread
	// -------------------------------------------------------
	if(internal)
	{
		// Thread for nut
		difference()
		{
			thread();
			difference() //subtract artifacts from bolt created by linear_extrude()
			{
				cylinder(length, major_radius+1, major_radius + 1);
				cylinder(length, major_radius, major_radius);
			}
			printify(printify_top = printify_top,printify_bottom = printify_bottom);
		}
	}
	else
	{
		// Thread for bolt
		difference()
		{
			thread();
			difference() //subtract artifacts from bolt created by linear_extrude()
			{
				cylinder(length, major_radius+1, major_radius + 1);
				cylinder(length, major_radius, major_radius);
			}
		}
		printify(printify_top,printify_bottom);*/
	}

}

