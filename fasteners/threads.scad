/*
 * Dan Kirshner - dan_kirshner@yahoo.com
 * Chow Loong Jin - hyperair@debian.org
 * indazoo - callNSAforemail@brotherswearemaybe.internet
 *
 * You are welcome to make free use of this software.  Retention of our
 * authorship credit would be appreciated.
 *
 * TODO:
 *  - OpenScad issues warning the warning:
 *    "Normalized tree is growing past 200000 elements. Aborting normalization."
 *    for medium to high $fn values ==> compile view is not correct. ==> use low 
 *    $fn during development of your part and increase "turn off rendering at" 
 *    in Menu=>Edit=>Preferences substantially (at least on Windows OS). 
 *  - Use OpenScad 2014.QX features as soon
 *    it is officially released (feature: list-comprehensions).
 *
 * Version 2.0  2014-10.27  indazoo            
 *                          merged polyhedra approach from
 *                            http://dkprojects.net/openscad-threads/threads.scad
 *                          - removed too many turns (those for loops are tricky, eh?)
 *                          - merged modules/functions for less parameters
 *                          - calculation of inner outer diameter for polygon now correct
 *                          - calculation of polyhedron face width now correct
 *                          - corrected circular misalignment of polyhedron relative 
 *                            to other objects ($fa,$fn) (for example inner fill cylinder)
 *                          Reimplented features:
 *                          - metric, ACME, buttress, square, english threads
 *                          - left/right threads
 *                          - user defined $fn influences number of segements
 *                          Added features:
 *                          - ensure clearance. Edges of bolt's polyhedrons may collide
 *                            with middle of nut's polyhedrons
 *                          - print/echo dimensional data about thread
 * 
 * Version 1.8  2014-10-27  indazoo
 *
 * Important  !!!!
 * Use that library (all versions <= 1.8) on your own risk!
 * Yes there are risks.
 * This library was forked from hyperair/MCAD. Thought it would be ok to use/extend 
 * the code. Then I found some bugs and fixed them. Unfortunately I discovered a real BUG.
 * Below in the history you see, the comment for version 1.2:
 * ==> "Use discrete polyhedra rather than linear_extrude()"
 * This has never been implemented or was erased! Why is this important ? 
 * Because it is impossible to create a accurate thread with linear_extrude'ing
 * a cross section of a thread. It is always an aproximation.
 * Case A: Create the cross section with constant angles matching that of linear_extrude.
 *         This gives a nice ouput. But! It cuts or adds too much of/to the corners 
 *         of your thread. You need to have a high $fn to get an APROXIMATION. Very
 *         likely your 3D printed nut/bolt will not fit.
 * Case B: Create the cross section with angles matching the thread corners (as I 
 *         implemented it (version 1.4 and above). This creates an accurate cross section
 *         of the thread's tooth profile but linear_extrude messes it up creating 
 *         polygons in a way, that the surface is distorted/rough.
 *         This is,because the polygons/corners of the cross section 
 *         aren't even spaced by the same angle ($fa) which is being used by 
 *         linear_extrude(). Atleast with high $fn the "roughness" gets small.
 * 
 *  ==> If you want accurate threads use V1.8 but check if the roughess is OK for you.
 *      See "radius bug" below in the TODO list
 *  ==> All versions < v1.8 are only an aproximation.
 *  ==> This code (version 1.3 and below) is a good sample of "never believe 
 *      source code you find in the internet".
 *
 * Back to the missing polyhedra implementation:
 * It seems the version 1.2 with poylhedra flies around:
 * http://dkprojects.net/openscad-threads/threads.scad
 * 
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
 */


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

//$fn=32;
//test_thread();
//test_threads();
//test_min_openscad_fs();
//test_internal_difference_metric();
//test_buttress();
//test_leftright_buttress(5);
//test_internal_difference_buttress();
//test_internal_difference_buttress_lefthanded();


module test_thread ($fa=5, $fs=0.1)
{
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 3, 
		internal=false, 
		n_starts=1, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
}

module test_threads ($fa=5, $fs=0.1)
{
    // M8
    metric_thread(8, 1.5, length=5);
    translate ([-10, 0, 0])
        metric_thread(8, 1.5, length=5, right_handed=false);

    translate ([10, 0, 0])
    square_thread(8, 1.5, length=5);

    translate ([20, 0, 0])
    acme_thread(8, 1.5, length=5);

    translate ([30, 0, 0])
    buttress_thread(8, 1.5, length=5);

    translate ([40, 0, 0])
    english_thread(1/4, 20, length=1/4);

    // Rohloff hub thread:
    translate ([65, 0, 0])
    metric_thread(34, 1, length=5, internal=true, n_starts=6);
}


module test_internal_difference_metric($fa=20, $fs=0.1)
{
	difference()
	{
		metric_thread(diameter=34, pitch=2, length=10, 
						internal=true, n_starts=1, 
						clearance = 0.1, backlash=0.4);
		metric_thread(diameter=34, pitch=2, length=10, 
						internal=false, n_starts=1, 
						clearance = 0.1, backlash=0.4);
	}
}

module test_internal_difference_metric($fa=20, $fs=0.1)
{
	difference()
	{
		metric_thread(diameter=17.7, pitch=2, length=10,
						internal=true, n_starts=3, 
						clearance = 0.1, backlash=0.4);
		rotate([0,0,$fa/2])
		metric_thread(diameter=17.7, pitch=2, length=10, 
						internal=false, n_starts=3, 
						clearance = 0.1, backlash=0.4);
		translate([10,10,0]) cube([20,20,20], center=true);
	}
}


module test_internal_difference_buttress($fa=20, $fs=0.1)
{
	difference()
	{
		buttress_thread(diameter=17.7, pitch=1.9, length=11.1, 
					internal=true, n_starts=1,
					buttress_angles = [13, 33], 
					clearance = 0.1, backlash=0.4);
		buttress_thread(diameter=17.7, pitch=1.9, length=11.1, 
					internal=false, n_starts=1, 
					buttress_angles = [13, 33],
					clearance = 0.1, backlash=0.4);
		translate([10,10,0]) cube([20,20,20], center=true);
	}
}

module test_internal_difference_buttress_lefthanded($fa=20, $fs=0.1)
{
	difference()
	{
		buttress_thread(diameter=17.7, pitch=1.9, length=11.1, 
					internal=true, n_starts=1,
					buttress_angles = [7, 44], 
					right_handed = false,
					clearance = 0.1, backlash=0.4);
		buttress_thread(diameter=17.7, pitch=1.9, length=11.1, 
					internal=false, n_starts=1, 
					buttress_angles = [7, 44],
					right_handed = false,
					clearance = 0.1, backlash=0.4);

	}
}

module test_buttress($fa=20, $fs=0.1)
{
	buttress_thread(diameter=8, pitch=4, length=4, 
					internal=false, n_starts=1,
					buttress_angles = [45, 3], right_handed=true ,
					clearance = 0, backlash=0);
	
}
module test_leftright_buttress($fa=20, $fs=0.1)
{

	translate([20,0,0])
		buttress_thread(diameter=20, pitch=1.9, length=5.1, 
					internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=true ,
					clearance = 0.1, backlash=0.4);

		buttress_thread(diameter=20, pitch=1.9, length=5.1, 
					internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=false ,
					clearance = 0.1, backlash=0.4);
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
    thread_polyhedron (
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
    thread_polyhedron (
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
    thread_polyhedron (
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
		pitch_flat_ratio = 6,       // ratio of pitch to outer flat length
		pitch_depth_ratio = 3/2,     // ratio of pitch to thread depth
		right_handed = true,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false
)
{
    thread_polyhedron (
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



// ---------------------------------------------------------------------
// ---------------------------------------------------------------------

// ---------------------------------------------------------------------
// internal - true = clearances for internal thread (e.g., a nut).
//            false = clearances for external thread (e.g., a bolt).
//            (Internal threads should be "cut out" from a solid using
//            difference()).
// n_starts - Number of thread starts (e.g., DNA, a "double helix," has
//            n_starts=2).  See wikipedia Screw_thread.
module thread_polyhedron(
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

	// Number of turns needed.
	n_turns = floor(length/pitch);
	n_segments = $fn > 0 ? 
					$fn :
					max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));
	seg_angle = 360/n_segments;
	fraction_circle = 1.0/n_segments;
	min_openscad_fs = 0.01;

	// Clearance:
	// The outer walls of the created threads are not circular. They consist
	// of polyhydrons with planar front rectangles. Because the corners of 
	// these polyhedrons are located at major radius (x,y), the middle of these
	// rectangles is a little bit inside of major_radius. So, with low $fn
	// this difference gets larger and may be even larger than the clearance itself
	// but also for big $fn values this fact reduces clearance. If one prints a 
	// thread/nut without addressing this they may not turn.
	function bow_to_face_distance(radius) = 
				radius*(1-accurateCos(seg_angle/2));

	major_rad = (internal ? 
					(major_radius+clearance)/accurateCos(seg_angle/2)
					: major_radius);
	minor_rad = (internal ? 
					(minor_radius+clearance)/accurateCos(seg_angle/2)
					: minor_radius);

	// Display useful data about thread to add other objects
	echo("*** Thread dimensions !!! ***");
	echo("outer diameter :",major_rad*2);
	echo("inner diameter :",minor_rad*2);

	diameter = major_rad*2;
	tooth_height = major_rad - minor_rad;

    // trapezoid calculation:
    // looking at the tooth profile along the upper part of a screw held
    // horizontally, which is a trapezoid longer at the bottom flat
    /*
                upper flat
            ___________________
           /|                 |\   right
          / |                 | \  angle
    left /__|                 |__\______________
   angle|   |                 |   |   lower     |
        |   |                 |   |    flat     |
        |left                 |right
         flat                 |flat
				tooth flat
        <------------------------->
    */

   	left_angle = (90 - upper_angle); //right_handed ? (90 - upper_angle) : 90 - lower_angle;
   	right_angle = (90 - lower_angle); //right_handed ? (90 - lower_angle) : 90 - upper_angle;

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
		echo("thread_polyhedron(): upper_flat is smaller than zero!");
	}

	left_flat = tooth_height / accurateTan (left_angle);
	right_flat = tooth_height / accurateTan (right_angle);
	tooth_flat = upper_flat + left_flat + right_flat;
	lower_flat = pitch-tooth_flat;



/*	echo("**** polyhedron thread ******");
	echo("internal", internal);
	echo("right_handed", right_handed);
	echo("tooth_height", tooth_height);
	echo("fraction_circle",fraction_circle);
	echo("n_segments",n_segments);
	echo("$fa (slice step angle)",$fa);
	echo("$fn (slice step angle)",$fn);

	echo("outer_flat_length", outer_flat_length);
	echo("left_angle", left_angle);	
	echo("left_flat", left_flat);
	echo("upper_flat", upper_flat);
	echo("right_angle", right_angle);
	echo("right_flat", right_flat);
	echo("lower_flat", lower_flat);
	echo("tooth_flat", tooth_flat);
	echo("clearance", clearance);
	echo("backlash",backlash);
	echo("major_radius",major_radius);
	echo("major_rad",major_rad);
	echo("minor_radius",minor_radius);
	echo("minor_rad",minor_rad);
	echo("diameter",diameter);
	echo("internal_play_offset",internal_play_offset());
	echo("******************************"); */

	union() {
		intersection() {
			// Start one below z = 0.  Gives an extra turn at each end.
			for (i=[-1*n_starts : n_turns]) {
				translate([0, 0, i*pitch]) {
					thread_turn();
				}
			}

			// Cut to length.
			translate([0, 0, length/2]) {
				cube([diameter*1.1, diameter*1.1, length], center=true);
			}
		} //end intersection

		// Solid center, including Dmin truncation.
		cylinder(r=minor_rad, h=length, $fn=n_segments);
		
	} // end union

	// ----------------------------------------------------------------------------
	module thread_turn()
	{
		for (i=[0 : n_segments-1]) 
		{
			rotate([0, 0, poly_rotation_total(i)]) 
			{
				translate([0, 0, i*n_starts*pitch*fraction_circle
									+ internal_play_offset()]) {
									//]) {
				thread_polyhedron();
         		}
      		}
		}
	} // end module metric_thread_turn()

	// polyhedron axial orientation
	function poly_rotation(i) =
		(right_handed?1:-1)*(i*seg_angle);
	// cylinder() starts at x=0,y=radius. But so far, the created polygon
	// starts at x=-1/2 facette,y=-radius. So, the cylinder's facettes are
	// not aligned with the thread ones, creating holes in the thread behind
	// the lower flat of the thread. 
	function poly_rot_offset() = 
		90 + ((right_handed?1:-1)*(seg_angle/2));
	function poly_rotation_total(i)	=
			poly_rotation(i) + poly_rot_offset();

	// An internal thread must be rotated/moved because the calculation starts	
	// at base corner of left flat which is not exactly over base
	// corner of bolt (clearance and backlash)
	// Combination of small backlash and large clearance gives 
	// positive numbers, large backlash and small clearance negative ones.
	function internal_play_offset() = 
		internal ?
				( 	tan_right*clearance >= backlash/2 ?
					-tan_right*clearance-backlash/2
					: 
					-(backlash/2-tan_right*clearance)
				)
			: 0;
	// ------------------------------------------------------------
	module thread_polyhedron()
	{
		x_incr_outer = 2*(accurateSin(seg_angle/2)*major_rad)+0.001; //overlapping needed 
		x_incr_inner = 2*(accurateSin(seg_angle/2)*minor_rad)+0.001; //for simple=yes
		z_incr = n_starts * pitch * fraction_circle;
		z_incr_this_side = z_incr * (right_handed ? 0 : 1);
		z_incr_back_side = z_incr * (right_handed ? 1 : 0);
		// radius correction to place polyhedron correctly
		// hint: polyhedron front ist straight, thread circle not
		minor_rad_p = minor_rad - bow_to_face_distance(minor_rad)
                            -0.01; //let polyhedra overlap with inner fill cylinder 
		major_rad_p = major_rad - bow_to_face_distance(major_rad);

	/*    
	(angles x0 and x3 inner are actually 60 deg)

                          /\  (x2_inner, z2_inner) [2]
                         /  \
   (x3_inner, z3_inner) /    \
                  [3]   \     \
                        |\     \ (x2_outer, z2_outer) [6]
                        | \    /
                        |  \  /|
             z          |[7]\/ / (x1_outer, z1_outer) [5]
             |          |   | /
             |   x      |   |/
             |  /       |   / (x0_outer, z0_outer) [4]
             | /        |  /     (behind: (x1_inner, z1_inner) [1]
             |/         | /
    y________|          |/
   (r)                  / (x0_inner, z0_inner) [0]

   */

		// Rule for face ordering: look at polyhedron from outside: points must
		// be in clockwise order.

		polyhedron(

			points = [
               	 [-x_incr_inner/2, -minor_rad_p, z_incr_this_side],    // [0]
               	 [x_incr_inner/2, -minor_rad_p, z_incr_back_side],     // [1]
               	 [x_incr_inner/2, -minor_rad_p,  right_flat + upper_flat + left_flat + z_incr_back_side],  // [2]
                	[-x_incr_inner/2, -minor_rad_p, right_flat + upper_flat + left_flat + z_incr_this_side],        // [3]

               	 [-x_incr_outer/2, -major_rad_p, right_flat + z_incr_this_side], // [4]
               	 [x_incr_outer/2, -major_rad_p, right_flat + z_incr_back_side],  // [5]
               	 [x_incr_outer/2, -major_rad_p, right_flat + upper_flat + z_incr_back_side], // [6]
               	 [-x_incr_outer/2, -major_rad_p, right_flat + upper_flat + z_incr_this_side]  // [7]
               	],

			faces = [
                	[0, 3, 7, 4],  // This-side trapezoid

                	[1, 5, 6, 2],  // Back-side trapezoid

                	[0, 1, 2, 3],  // Inner rectangle

                	[4, 7, 6, 5],  // Outer rectangle

                	// These are not planar, so do with separate triangles.
                	[7, 2, 6],     // Upper rectangle, bottom
               	 [7, 3, 2],     // Upper rectangle, top

                	[0, 5, 1],     // Lower rectangle, bottom
                	[0, 4, 5]      // Lower rectangle, top
 	              ]
		);

	
	} // end module thread_polyhedron()
}

