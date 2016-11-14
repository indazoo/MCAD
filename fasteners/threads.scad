// -------------------------------------------------------------------
// Test/demo threads
// -------------------------------------------------------------------

//$fn=30;
//test_threads();
//test_channel_threads();
//test_slot_tabs();

// -------------------------------------------------------------------
// Usage
// -------------------------------------------------------------------
/* 
 *   > This single file lets you create many types of threads.
 *   > No external dependencies other than OpenScad.
 *   > You can define your custom tooth profile of your thread.
 *     Check out test_rope_thread() and "rope_xz_map" in the code below. 
 *     This simple sample should show you how to do it. A map is a 
 *     vector with x/z elements. 
 *
 *   Already implemented:
 *   > Metric threads
 *   > Square threads
 *   > ACME threads
 *   > Buttress threads
 *   > Channel threads
 *   > Rope threads (for rope pulleys)
 *   > NPT, BSP  (tapered for pipes)
 *   > Simple twist and lock connectors
 *   
 *   > All can have a bore in the center
 *   > All can have multiple starts
 *   > All support internal(nut) and external(screw)
 *
 *   > Very fast rendering, no "normalization tree" problems
 *
*/ 
 
// -------------------------------------------------------------------
// Author(s)
// -------------------------------------------------------------------
/*
 * indazoo 
 *
 * Credits:
 * kintel
 * hyperair
 * Dan Kirshner
 * Chow Loong Jin
 * You ?
 */

// -------------------------------------------------------------------
// Possible Contibutions (yes, YOU!)
// -------------------------------------------------------------------
/*
 * - For very short threads (length < pitch) the output is garbage because polygons may be larger than this.
 * - Channel threads ending and starting front faces are not exact.
 * - For simpler code, move the pair minor/major points into a vector/object. This would eliminate many +/-1 potential problems.
 * - small error (too much material) for channel thread differences at segment plan 0.
 * - big taper angles create invalid polygons (no limit checks implemented).
 * - test print BSP and NPT threads and check compatibility with std hardware.
 * - check/buils a 45(?) degree BSP/NPT thread variant which fits on metal std hardware 
     and has no leaks (i believe for garden stuff)
 * - printify does notwork after v1.8   
 * - Internal threads start at y=0 as non internal do.
 *   This is not 100% correct. The middle point between two segment planes
 *   of internal and normal thread should be aligned. Barely noticable. 
 *   No known effect on usability.
 * - Often one wants a shaft attached to the thread. ==> param (len_top/bottom_shaft).

 * OPTIONAL
 * - wood screws like
 *   http://www.thingiverse.com/thing:8952 and OneNote
 * - chamfer/bevel
 * - Lead screw profile extension. We have already ACME and metric profiles.
 *   Not sure if this is needed.
 *   Picture "Leadscrew 5" on thing (http://www.thingiverse.com/thing:8793)
 *   has raised profile which is currently not supported. Is this really needed? 
 *   For worm drives?
 *   Code: 
 *   https://github.com/syvwlch/Thingiverse-Projects/tree/master/Threaded%20Library
 * - Worm drive support would be nice. but then the thread must be able to
 *   follow a curve
 *   http://www.thingiverse.com/thing:8821 
 * - D lot of standard definitions (DIN/ISO) can be implemented (tolerance etc).
 */
 
// -------------------------------------------------------------------
// History
// -------------------------------------------------------------------
/*
 * Version 4.1  2016-11-13  indazoo
 *                          - Improved calculations/output for intersection() free code which had problems
 *                            with the cross points (thread start & end).
 *                            Passed all tests except very short threads length < pitch. Not needed very often.
 * Version 4.0  2016-10-24  indazoo
 *                          - Now ultra fast without intersection. The thread is being created exactly
 *                            with the correct length. The polygons are calculated to the needed height.
 *                            Still needs some work for rope_threads (cross point calculation not correct).
 * Version 3.3  2016-09-26  indazoo
 *                          - fixed wrong calculation of round "rope threads".
 * Version 3.2  2015-06-05  indazoo
 *                          - supports now tooth maps. You can create a map of your
 *                            custom tooth profile and easily create a thread.
 *                            As a sample, I implemented "rope threads" for 
 *                            ropes/fishing line pulleys. Feel free to create your own
 *                            and publish it. Thanks.
 *                          - fixed issue with non minor radius at border points 
 *                            of profile which created illegal polygons. 
 * Version 3.1  2015-05-29  indazoo
 *                          - also channel threads with calculated polygons
 *                          - many fixes and tests. Lib should be ok now. 
 * Version 3.0  2015-05-01  indazoo
 *                          - standard threads use now list comprehension instead of 
 *                            concatenated polygons. This is much faster.  Run time of 
 *                            main test went from 15 minutes to 1.5 minutes.
 *                          - some minor bugs/typos removed
 *                          - sin() and cos() are now accurate with OpenScad 2015.03.
 *                            So, workaround code removed.
 * Version 2.7  2015-02-16  indazoo
 *                          - removed the "holes" reported by netfabb.
 *                          - channel thread supports now deep sunken threads
 *                          - modularized polygon calculation
 *                          - test/demo samples extended
 * Version 2.6  2015-01-14  indazoo
 *                          - tab & slot connections added. Heavily modified code
 *                            of SimCity.
 * Version 2.5  2015-01-14  indazoo
 *                          - multipoint polygons were not "planar" for all cases
 * Version 2.5  2015-01-14  indazoo
 *                          - large clearance increases backlash when upper_flat
 *                            is zero on internal thread.
 *                          - negative upper_flat prohibited.
 *                          - channel thread improved
 * Version 2.4  2014-11-10  indazoo
 *                          - thread was not complete for fractions of 
 *                            pitch/length relationships
 *                          - more comments and output texts
 *                          - channel threads further debugged
 *                          - tests improved
 *                          - thread flats calculation improved
 *                          - "flat_thread" (still beta) renamed to "channel_thread" 
 *                            due to name conflicts with tooth flats of thread .
 *                          - removed external dependencies (MCAD)  
 *                          - internal_play_offset deactivated                         
 * Version 2.3  2014-11-06  indazoo
 *                          - channel_thread has now clearance also on top
 *                          - some comments improved
 *                          - bugs with channel threads removed
 *                          - channel thread created too many polygons
 *                          - flat polygon now independent of angle/location
 *                          - parameter "exact_clearance" added
 * Version 2.3  2014-11-02  indazoo
 *                          - main thread() module supports now tapered threads
 *                          - added tapered water pipe threads.
 * Version 2.2  2014-11-01  indazoo  
 *                          - now with "channel threads" which have only one turn and
 *                            no thread above that turn.
 *                          - supports now a bore hole at the thread's axis.
 *                          - some test code added
 * Version 2.1  2014-10-27  indazoo  
 *                          - improved polygon overlap for "simple = yes"  
 *                          - fully sliced polyhedra without need for internal cylinder
 *                          - improved corner cases where thread flats are zero
 *                          - test code changed
 * Version 2.0  2014-10-27  indazoo            
 *                          dropped linear_extrude() infavor of polyhedra approach from
 *                            http://dkprojects.net/openscad-threads/threads.scad
 *                          ==> thread is accurate and "nice"
 *                          - removed too many turns (those for loops are tricky, eh?)
 *                          - merged modules/functions for less parameters
 *                          - calculation of inner outer diameter for polygon now correct
 *                          - calculation of polyhedron face width now correct
 *                          - corrected circular misalignment of polyhedron relative 
 *                            to other objects ($fa,$fn) (for example inner fill cylinder)
 *                          Reimplented features:
 *                          - metric, ACME, buttress, square, english threads
 *                          - left/right threads
 *                          - user defined $fn influences number of segments
 *                          Added features:
 *                          - ensure clearance. Edges of bolt's polyhedrons may collide
 *                            with middle of nut's polyhedrons
 *                          - print/echo dimensional data about thread
 * 
 * Version 1.8  2014-10-27  indazoo
 *
 *                          Important note for coders not for users :
 *                          This library was forked from hyperair/MCAD. Thought it 
 *                          would be ok to use/extend the code. Then I found some bugs
 *                          and fixed them. Below in the history you see, the comment 
 *                          for version 1.2:
 *                          ==> "Use discrete polyhedra rather than linear_extrude()"
 *                          This has never been implemented or was erased! 
 *                          Why is this important ? 
 *                          Because it is impossible to create a accurate thread with 
 *                          linear_extrude'ing a cross section of a thread (at least up
 *                          until OpenSCAD 2014.QX. It is always an aproximation.
 *
 *                          Case A: Create the cross section with constant angles matching
 *                          that of linear_extrude.
 *                          This gives a nice ouput. But! It cuts or adds too much of/to
 *                          the corners of your thread. You need to have a high $fn to 
 *                          get an APROXIMATION. Very likely your 3D printed nut/bolt 
 *                          will not fit/turn.
 *
 *                          Case B: Create the cross section with angles matching the 
 *                          thread corners (as I implemented it (version 1.4 and above).
 *                          This creates in theory an accurate cross section of the 
 *                          thread's tooth profile but linear_extrude messes it up 
 *                          creating polygons in a way, that the surface is distorted/rough.
 *                          This is,because the polygons/corners of the cross section
 *                          aren't even spaced by the same angle ($fa) which is being used
 *                          by linear_extrude(). At least with high $fn the "roughness" 
 *                          gets small.
 * 
 *                          ==> If you want accurate threads use V1.8 but check if the
 *                              roughess is OK for you.
 *                          ==> All versions < v1.8 are only an aproximation.
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
//             Not necesseraly needed for tapered threads. Use default (zero)
//             for those.
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
//
// exact_clearance
//             Usefuly only for "internal" threads. Default "true" (exact).
//             Using "false" expands outer diameter more than clearance:
//             ==> outer diameter changes with different $fn but bolt will surely turn.
//             Using "true" adds only exact clearance to outer diameter
//             ==> outer diameter is fix for all $fn, but your bolt may be unturnable
//             Reason:
//             The outer walls of the created threads are not circular. They consist
//             of polyhydrons with planar front rectangles. Because the corners of 
//             these polyhedrons are located at major radius (x,y), the middle of these
//             rectangles is a little bit inside of major_radius. So, with low $fn
//             this difference gets larger and may be even larger than the clearance itself
//             but also for big $fn values clearance is being reduced. If one prints a 
//             thread/nut without addressing this they may not turn.


// -------------------------------------------------------------------
// Test/demo threads
// -------------------------------------------------------------------

//$fn=67;
//Test Case 1:
//$fn=26; //or 58
//metric_thread(8, pitch=3, length=5, right_handed=true, internal=false, n_starts=3, bore_diameter=2);
// ==>  if bottom _z() is above zero then there was a polygon too much at bottom.

// Test Case 2:
// $fn=3; 
// metric_thread(8, pitch=3, length=5, right_handed=true, internal=false, n_starts=3, bore_diameter=2);
// ==> holes at bottom and top appear, bore is covered by polygons.

// Test Case 3:
// $fn=32;
// $fn=13; //this creates good visible polygons and with n_starts=2 or 3 many cases of cross points
// square_thread(diameter=8, pitch=1.5, length=1.5+1/pow(2,50), bore_diameter=3, right_handed=false);  

// Test Case 4:
// Flat polygons on top_z() and bottom_z() of thread without volume above or below.
// $fn=32;
// square_thread(diameter=8, pitch=1.5, length=5, right_handed=false, bore_diameter=4); 
// square_thread(diameter=8, pitch=1.5, length=5, right_handed=true, bore_diameter=4);

// Test Case 5:
// Thread without bore but in code modified min x to see correct center build.
// min_center_x = 1200 * netfabb_degenerated_min();

// Test Case 6:
// A channel thread should close its planar face at thread start.
// $fn=32;
// test_channel_simple(dia=8, internal=false);


// Test Case 7:
// The limitation of the thread to top_z() and bottom_z() results in points at z which are rotated away from the original segment angle.
// Due to the fact that a round structure is given by points and the fact, that a straight line between two points is smaller than the wanted radius
// the move of the point at z results in undercuts at bottom and overcuts at top.
// Sample :
// $fn=16;
// test_rope_thread(length=1, n_starts=3);
// $fn=15;
// test_rope_thread(rope_diameter=1.2, length = 1, rope_bury_ratio=0.9, coarseness=7,n_starts=2 );

// Test Case 8 (IN PROGRESS):
// ==> Because of pitch with value 1.01 (not exactly 1) the result shows a hole in netfabb. 
// ==> This was, because the norm vector in the exported stl file does not correspond with the exported vertexes.
//     I opened an issue on github (4.11.2016):   https://github.com/openscad/openscad/issues/1853
// $fn=67;
// metric_thread(8, pitch=1.01, length=10, right_handed=true, internal=false, n_starts=3, bore_diameter=-1);

// Test Case 8:
// At top (maybe at bottom too) the top cover overlaps in air (very small triangle at the profile.
// Also a polygon is missing.
// $fn=16;
// test_rope_thread(length=1, n_starts=3);

// Test Case 9 (TODO):
// Very short thread:
// 1) A face is missing at zero:
//    $fn=16;
//    metric_thread(8, pitch=1, length=1, right_handed=true, internal=false, n_starts=3);
// 2) With very short threads, the algorithm does not work. The faces of the thread are bigger than the height.
//    $fn=16;
//    metric_thread(8, pitch=1, length=1, right_handed=true, internal=false, n_starts=3);

//$fn=7;
//test_threads();
//test_channel_threads();
//test_slot_tabs();
//test_metric_right(internal = false);
//test_metric_right_n_starts();   
//test_metric_right_large_pitch();
//test_metric_right_and_internal();
//test_metric_left();
//test_internal_difference_metric();

//test_turnability();

//test_square_thread();
//acme_thread(8, pitch=1.5, length=5);
//test_hollow_thread();
//test_threads();
//test_buttress();
//test_leftright_buttress(5);
//test_internal_difference_buttress();
//test_internal_difference_buttress_lefthanded();
//test_buttress_no_lower_flat();

//test_rope_thread(rope_diameter=1.2, length = 5, right_handed=true, rope_bury_ratio=0.9, coarseness=7, n_starts=2 );
//metric_thread(8, pitch=1.01, length=10, right_handed=true, internal=false, n_starts=3, bore_diameter=-1);
//square_thread(8, pitch=1.5, length=5, right_handed=false, bore_diameter=5, n_starts=3);	
//translate([0,0,1])
	//cylinder(d=20,h=20);

//test_channel_simple();
//translate([10,20,2])
//cube([4,4,4]);
//test_channel_thread(dia=8);
 //test_channel_simple(dia=8, internal=false);
//test_channel_thread2(); 
//test_channel_thread3();
//test_channel_thread_diff();
//test_NPT();
//test_BSP();

module test_threads ($fa=5, $fs=0.1)
{
    // M8
	metric_thread(8, pitch=1.5, length=5);
	
  translate ([0, 15, 0])
    metric_thread(8, pitch=1.5, length=5, right_handed=false);


  // multiple start:
  translate ([0, -15, 0])
    metric_thread(8, pitch=3, length=5, internal=false, n_starts=3);

	
    translate ([10, 0, 0])
    square_thread(8, pitch=1.5, length=5);
	
    translate ([20, 0, 0])
    acme_thread(8, pitch=1.5, length=5);

    translate ([30, 0, 0])
    buttress_thread(8, pitch=1.5, length=5);



    translate ([40, 0, 0])
    test_channel_simple(dia=8, internal=false);
		color("LemonChiffon")
    translate ([40, 0, -5])
    test_channel_simple(dia=8, internal=true);
		
	
		translate ([40, -15, 0])
		test_channel_thread(dia=8);
	
    translate ([50, 0, 0])
		test_NPT(dia_inches = 1/8);

    translate ([60.5, 0, 0])
		test_BSP(dia_inches = 1/8);
		
		translate ([70, 0, 0])
		test_rope_thread();
		
		translate ([70, -15, 0])
		test_rope_thread(n_starts=3);

}

module test_channel_threads()
{
	// channel thread
	translate ([10, 0, 0])
         test_channel_thread(dia=8);
	
	translate ([-10, 0, 0])
         test_channel_thread2();
}

module test_slot_tabs()
{
	// tabs & slots
	translate ([0, 0, +5])
		test_tabs(ref_dia = 10);
	color("LemonChiffon")
	translate ([0, 0, -5])
		test_slots(ref_dia = 10);
}





module test_metric_right ($fa=5, $fs=0.1, internal=false)
{
	//Case: Std right handed metric thread
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 8, 
		internal=internal, 
		n_starts=1, 
		right_handed=true,
		clearance = 0.22, 
		backlash=0.4,
		printify_top = false
	);
}
module test_metric_right_large_pitch ($fa=5, $fs=0.1)
{
	//Case: Pitch larger than length
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 8, 
		internal=false, 
		n_starts=1, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
}
module test_metric_right_n_starts ($fa=5, $fs=0.1)
{
	//Case: More than one start (3)
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 8, 
		internal=false, 
		n_starts=3, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
}
module test_metric_right_and_internal ($fa=5, $fs=0.1)
{
	//Case: Std right handed metric thread
	dia = 20;
	
	metric_thread( diameter = dia,
		pitch = 4, 
		length = 8, 
		internal=false, 
		n_starts=2, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
	translate([0,0,-40])
	rotate([0,0,360/3/2])
	metric_thread( diameter = dia,
		pitch = 4, 
		length = 8, 
		internal=true, 
		n_starts=2, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
}
module test_metric_left($fa=5, $fs=0.1)
{
	//Case: Std left(!) handed metric thread
	metric_thread(20, 
				pitch=4, 
				internal=false, 
				n_starts=2,
				length=8, 
				right_handed=false);
}

module test_turnability ($fa=5, $fs=0.1)
{
	$fn = 3;
	translate([0,0,4])
	test_metric_right(internal=false);
	rotate([0,0,60])
	test_metric_right(internal=true);
}

module test_hollow_thread ($fa=5, $fs=0.1)
{
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 5, 
		internal=false, 
		n_starts=2, 
		thread_angles = [0,30],
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false,
		bore_diameter = 7
	);
}



module test_square_thread()
{	
    square_thread(8, pitch=2, length=5);
}


module test_internal_difference_metric($fa=20, $fs=0.1)
{
	//Case: Diff of std right handed metric thread
	starts = 3;
	length = 2.3;
	pitch = 2;
	clearance = 0.1;
	backlash = 0.3;
	difference()
	{
		metric_thread(diameter=17.7, pitch=pitch, length=length,
						internal=true, n_starts=starts, 
						clearance = clearance, backlash=backlash,
						bore_diameter = 0);
		translate([0,0,-0.005]) 
		metric_thread(diameter=17.7, pitch=pitch, length=length+0.01, 
						internal=false, n_starts=starts,
						clearance = clearance, backlash=backlash,
						bore_diameter = 0);
	cube_tooMuch = backlash + clearance;
	cube_len = ceil(length/pitch)*starts*(ceil(length))+2*cube_tooMuch;
	translate([10,10-0.01,cube_len/2-pitch*(starts)-cube_tooMuch]) 
		cube([20,20,cube_len], center=true);
	}
}


module test_internal_difference_buttress($fa=20, $fs=0.1)
{
	difference()
	{
		buttress_thread(diameter=17.7, pitch=1.9, length=2.3, 
					internal=true, n_starts=1,
					buttress_angles = [13, 33], 
					clearance = 0.1, backlash=0.4);
		buttress_thread(diameter=17.7, pitch=1.9, length=2.3, 
					internal=false, n_starts=1, 
					buttress_angles = [13, 33]);
		translate([10,10,0]) cube([20,20,20], center=true);
	}
}

module test_internal_difference_buttress_lefthanded($fa=20, $fs=0.1)
{
	difference()
	{
		buttress_thread(diameter=17.7, pitch=1.9, length=2.3, 
					internal=true, n_starts=1,
					buttress_angles = [7, 44], 
					right_handed = false,
					clearance = 0.1, backlash=0.4);
		buttress_thread(diameter=17.7, pitch=1.9, length=2.3, 
					internal=false, n_starts=1, 
					buttress_angles = [7, 44],
					right_handed = false);

		translate([10,10,0]) cube([20,20,20], center=true);
	}
}

module test_buttress($fa=20, $fs=0.1)
{
	buttress_thread(diameter=20, pitch=4, length=4.3, 
					internal=false, n_starts=1,
					buttress_angles = [45, 3], right_handed=true);
	
}

module test_buttress_no_lower_flat($fa=5, $fs=0.1)
{
	buttress_thread(diameter=20, pitch=4, length=8, 
					internal=false, n_starts=1,
					buttress_angles = [60, 60], right_handed=true);
}

module test_leftright_buttress($fa=20, $fs=0.1)
{

	translate([20,0,0])
		buttress_thread(diameter=20, pitch=1.9, length=4.3, 
					internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=true ,
					clearance = 0.1, backlash=0.4);

		buttress_thread(diameter=20, pitch=1.9, length=4.3, 
					internal=true, n_starts=1,
					buttress_angles = [15, 40], right_handed=false);
}

module test_channel_simple(dia = 10, length=4, pitch = 2, internal = false, right_handed = true)
{
	pitch = pitch;
	length = length;
	angles = [30,30]; //second angle needs to be zero for test case.
	outer_flat_length = 0.2;
	clearance = 0;
	backlash = 0;
	starts = 1;
	exact_clearance = false;
	cutout = true;
	cutout_space = 0.1;
	h_cutout = cutout ? cutout_space : 0;

	channel_thread(
		thread_diameter = dia,
		pitch = pitch,
		length = length,
		internal = internal,
		n_starts = starts,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = right_handed,
		clearance = h_cutout,
		backlash = h_cutout,
		bore_diameter = dia/5*2,
		exact_clearance = exact_clearance
		);
}

module test_channel_thread(dia = 10)
{
	angles = [30,30];
	length = 34;
	pitch=2;
	outer_flat_length = 0.2;
	clearance = 0.0;
	backlash = 0.0;
	starts = 1;

	translate([0,0,0])
	channel_thread(
		thread_diameter = dia,
		pitch = pitch,
		length = length,
		internal = false,
		n_starts = starts,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = 2,
		exact_clearance = true
		);


	color("LemonChiffon")
	translate([0,0,-length*3/2-pitch])
	channel_thread(
		thread_diameter = dia,
		pitch = pitch,
		length = length,
		internal = true,
		n_starts = starts,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = 1
		);
		
}

module test_channel_thread2()
{
	//top cuts through upper thread (no shaft)
	angles = [0,30]; 
	length = 2;
	outer_flat_length = 0.2;
	clearance = 0.2;
	backlash = 0.15;
	function getdia(n) = 5 + n * 5;
	for (n=[1 :1 : 1])
	{

	translate([0,0,length+5])
	channel_thread(
		thread_diameter = getdia(n),
		pitch = 1,
		length = length,
		internal = false,
		n_starts = 1,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = getdia(n)-4
		);


	color("LemonChiffon")
		translate([0,0,-5])
	channel_thread(
		thread_diameter = getdia(n),
		pitch = 1,
		length = length,
		internal = true,
		n_starts = 1,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = getdia(n)-4
		);
		
	}
	
}

//test_channel_thread3
module test_channel_thread3()
{
	//this sample created degenerated faces in netfabb
	//because the angles created lower/upper_flat = 0 (or 0.0001)
	wall_width = 2;
	dia = 30 - 2*wall_width;
	pitch = 2;
	length = 4;
	angles = [50,0]; //second angle needs to be zero for test case.
	outer_flat_length = 0.5;
	clearance = 0;
	backlash = 0;
	exact_clearance = false;
	cutout = true;
	cutout_space = 0.2;
	h_cutout = cutout ? cutout_space : 0;

	channel_thread(
		thread_diameter = dia,
		pitch = 2,
		length = length,
		internal = false,
		n_starts = 1,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = h_cutout,
		backlash = h_cutout,
		bore_diameter = 10,
		exact_clearance = exact_clearance
		);
}



module test_channel_thread_diff()
{
	//Case: both flanks with non zero angle
	dia = 8;
	//angles= [30,30];
	angles= [10,50];  //[upper, lower]
	backlash = 0.3;
	clearance = 0.4;
	pitch = 1;
	length = 2;
	starts = 2;
	right_handed = true;
	difference()
	{
	channel_thread(
			thread_diameter = dia,
			pitch = pitch,
			length = length,
			internal = true,
			n_starts = starts,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = right_handed,
			clearance = clearance,
			backlash = backlash, 
			bore_diameter = 0);
		channel_thread(
			thread_diameter = dia,
			pitch = pitch,
			length = length,
			internal = false,
			n_starts = starts,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = right_handed,
			clearance = clearance,
			backlash = backlash,
			bore_diameter = 5);
		//translate([-2.5,-2.5,0]) cube([5,5,5], center=true);
	}
}


module test_NPT(dia_inches = 3/4)
{
	US_national_pipe_thread(
		nominal_pipe_size = dia_inches,
		length = 0.5, //inches
		internal  = false);
}

module test_BSP(dia_inches = 3/4)
{
	BSP_thread(
		nominal_pipe_size = dia_inches,
		length = 0.5, //inches
		internal  = false);
}

module test_rope_thread(diameter=8,
												length=10,
												right_handed=true,
												rope_diameter=1.5,
												rope_bury_ratio=0.9,
												coarseness = 10,
												n_starts = 1
												)
{

	rope_thread(
		thread_diameter = diameter,
		pitch=rope_diameter+0.5,
		length=length,
		internal = false,
		n_starts = n_starts,
		rope_diameter=rope_diameter,
		rope_bury_ratio=rope_bury_ratio,
		coarseness = coarseness,
		right_handed = right_handed,
		clearance = 0,
		backlash = 0,
		printify_top = false,
		printify_bottom = false,
		bore_diameter = 4, //-1 = no bore hole. Use it for pipes 
		taper_angle = 0,
		exact_clearance = false)	;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Thread Definitions
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function metric_minor_radius(major_diameter, pitch) =
				major_diameter / 2 - 5/8 * cos(30) * pitch;
 
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
    simple_profile_thread (
			pitch = pitch,
			length = length,
			upper_angle = 30, 
			lower_angle = 30,
			outer_flat_length = pitch / 8,
			major_radius = diameter / 2,
			minor_radius = metric_minor_radius(diameter,pitch),
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
    simple_profile_thread (
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
			printify_bottom = printify_bottom,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
    simple_profile_thread (
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
			printify_bottom = printify_bottom,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
    simple_profile_thread (
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
			printify_bottom = printify_bottom,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
	// Convert to mm.
	mm_diameter = diameter*25.4;
	mm_pitch = (1.0/threads_per_inch)*25.4;
	mm_length = length*25.4;

	metric_thread(mm_diameter, 
			mm_pitch, 
			mm_length, 
			internal, 
			n_starts, 
			right_handed = right_handed,
			clearance = clearance,
			backlash =  backlash,
			printify_top = printify_top,
			printify_bottom = printify_bottom,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
			);
}


//
//-------------------------------------------------------------------
//-------------------------------------------------------------------
// BSPT (British Standard Pipe Taper)
// Whitworth pipe thread DIN ISO 228 (DIN 259) 
//
// British Engineering Standard Association Reports No. 21 - 1938
//
// http://books.google.ch/books?id=rq69qn9WpQAC&pg=PA108&lpg=PA108&dq=British+Engineering+Standard+Association+Reports+No.+21+-+1938&source=bl&ots=KV2kxT-fFR&sig=3FBCPA3Kzhd62nl1Tz08g1QyyIY&hl=en&sa=X&ei=JehZVPWdA4LfPZyEgIAN&ved=0CBQQ6AEwAA#v=onepage&q=British%20Engineering%20Standard%20Association%20Reports%20No.%2021%20-%201938&f=false
// 
// http://valiagroups.net/dimensions-of-pipe-threads.htm
// http://mdmetric.com/tech/thddat7.htm#pt
// 
// Male BSP is denoted as MBSP or MNPT
// Female BSP is FBSP
//
// Notes:
// a
module BSP_thread(
		nominal_pipe_size = 3/4,
		length = 10,
		internal  = false,
		backlash = 0  //use backlash to correct too thight threads after 3D printing.
)
{
	 //see http://mdmetric.com/tech/thddat19.htm
	function get_n_threads(nominal_pipe_size) = 
		 nominal_pipe_size == 1/16 ? 28
		: nominal_pipe_size == 1/8 ? 28
		: nominal_pipe_size == 1/4 ? 19
		: nominal_pipe_size == 3/8 ? 19
		: nominal_pipe_size == 1/2 ? 14
		: nominal_pipe_size == 5/8 ? 14
		: nominal_pipe_size == 3/4 ? 14
		: nominal_pipe_size == 1 ? 11
		: nominal_pipe_size == 5/4 ? 11
		: nominal_pipe_size == 3/2 ? 11
		: nominal_pipe_size == 2 ? 11
		: nominal_pipe_size == 5/2 ? 11
		: nominal_pipe_size == 3 ? 11
		: nominal_pipe_size == 7/2 ? 11
		: nominal_pipe_size == 4 ? 11
		: nominal_pipe_size == 5 ? 11
		: nominal_pipe_size == 6 ? 11
		: 0
		;
	
	 //see http://mdmetric.com/tech/thddat19.htm
	function get_outside_diameter(nominal_pipe_size) =  
		 nominal_pipe_size == 1/16 ? 0.304
		: nominal_pipe_size == 1/8 ? 0.383	
		: nominal_pipe_size == 1/4 ? 0.518
		: nominal_pipe_size == 3/8 ? 0.656
		: nominal_pipe_size == 1/2 ? 0.825
		: nominal_pipe_size == 5/8 ? 0.902
		: nominal_pipe_size == 3/4 ? 1.041
		: nominal_pipe_size == 1 ? 1.309
		: nominal_pipe_size == 5/4 ? 1.650
		: nominal_pipe_size == 3/2 ? 1.882
		: nominal_pipe_size == 2 ? 2.347
		: nominal_pipe_size == 5/2 ? 2.960
		: nominal_pipe_size == 3 ? 3.460
		: nominal_pipe_size == 7/2 ? 3.950
		: nominal_pipe_size == 4 ? 4.450
		: nominal_pipe_size == 5 ? 5.450	
		: nominal_pipe_size == 6 ? 6.450
		: 0
		;

	// http://en.wikipedia.org/wiki/National_pipe_thread
	// http://www.csgnetwork.com/mapminsecconv.html
	//http://www.hasmi.nl/en/handleidingen/draadsoorten/american-standard-taper-pipe-threads-npt/
	angle=27.5;
	TPI_threads_per_inch = get_n_threads(nominal_pipe_size);
	pitch = 1.0/TPI_threads_per_inch;
	height = 0.960491 * pitch; //height from peak to peak , ideal without flat
	max_height_inner_to_outer_flat = 0.640327 * pitch; 
	
	//Simple rules for all threads, not really correct
	//So far, exact clearance not implemented.
	//This is a rough approximation derived from mdmetric.com data	
	min_clearance_to_outer_peak = (height-max_height_inner_to_outer_flat)/2;
	max_clearance_to_outer_peak = 2 * min_clearance_to_outer_peak; // no idea, honestly
	min_outer_flat = 2 * accurateTan(angle) * min_clearance_to_outer_peak;
	max_outer_flat = 2 * accurateTan(angle) * max_clearance_to_outer_peak;

	//so far, exact clearance not implemented.
	//This is a rough approximation derived from mdmetric.com data	
	clearance = internal ? max_clearance_to_outer_peak - min_clearance_to_outer_peak
							: 0;

	// outside diameter is defined in table
	outside_diameter = get_outside_diameter(nominal_pipe_size);
	mm_diameter = outside_diameter*25.4;

	mm_pitch = (1.0/TPI_threads_per_inch)*25.4;
	mm_length = length*25.4;
	mm_outer_flat = (internal ? max_outer_flat : min_outer_flat) * 25.4;
	mm_max_height_inner_to_outer_flat = max_height_inner_to_outer_flat *25.4;
	mm_bore = nominal_pipe_size * 25.4;

	simple_profile_thread (
			pitch = mm_pitch,
			length = mm_length,
			upper_angle = angle, 
			lower_angle = angle,
			outer_flat_length = mm_outer_flat,
			major_radius = mm_diameter / 2,
			minor_radius = mm_diameter / 2 - mm_max_height_inner_to_outer_flat,
			internal = internal,
			n_starts = 1,
			right_handed = true,
			clearance = clearance,
			backlash =  0,
			printify_top = false,
			printify_bottom = false,
			bore_diameter = mm_bore,
			taper_angle = atan(1/32) //tan−1(1⁄32) = 1.7899° = 1° 47′ 24.474642599928302″.
			);	

}

//-------------------------------------------------------------------
//-------------------------------------------------------------------
// 
// http://machiningproducts.com/html/NPT-Thread-Dimensions.html
// http://www.piping-engineering.com/nominal-pipe-size-nps-nominal-bore-nb-outside-diameter-od.html
// http://mdmetric.com/tech/thddat19.htm
// 
// Male NPT is denoted as either MPT or MNPT
// Female NPT is either FPT or FNPT
// Notes:
//  - As itseems, a ideal model of a thread has no vanish section
//    because there is no die with a chamfer which cuts the thread.
module US_national_pipe_thread(
		nominal_pipe_size = 3/4,
		length = 10,
		internal  = false,
		backlash = 0  //use backlash to correct too thight threads after 3D printing.
)
{
	 //see http://mdmetric.com/tech/thddat19.htm
	function get_n_threads(nominal_pipe_size) = 
		  nominal_pipe_size == 1/16 ? 27
		: nominal_pipe_size == 1/8 ? 27
		: nominal_pipe_size == 1/4 ? 18
		: nominal_pipe_size == 3/8 ? 18
		: nominal_pipe_size == 1/2 ? 14
		: nominal_pipe_size == 3/4 ? 14
		: nominal_pipe_size == 1 ? 11.5
		: nominal_pipe_size == 5/4 ? 11.5
		: nominal_pipe_size == 3/2 ? 11.5
		: nominal_pipe_size == 2 ? 11.5
		: nominal_pipe_size == 5/2 ? 8
		: nominal_pipe_size == 3 ? 8
		: nominal_pipe_size == 7/2 ? 8
		: nominal_pipe_size == 4 ? 8
		: nominal_pipe_size == 5 ? 8
		: nominal_pipe_size == 6 ? 8
		: nominal_pipe_size == 8 ? 8
		: nominal_pipe_size == 10 ? 8
		: nominal_pipe_size == 12 ? 8
		: nominal_pipe_size == 14 ? 8
		: nominal_pipe_size == 16 ? 8
		: nominal_pipe_size == 18 ? 8
		: nominal_pipe_size == 20 ? 8
		: nominal_pipe_size == 24 ? 8
		: 0
		;
	
	 //see http://mdmetric.com/tech/thddat19.htm
	function get_outside_diameter(nominal_pipe_size) =  
		  nominal_pipe_size == 1/16 ? 0.3125
		: nominal_pipe_size == 1/8 ? 0.405
		: nominal_pipe_size == 1/4 ? 0.540
		: nominal_pipe_size == 3/8 ? 0.675
		: nominal_pipe_size == 1/2 ? 0.840
		: nominal_pipe_size == 3/4 ? 1.050
		: nominal_pipe_size == 1 ? 1.315
		: nominal_pipe_size == 5/4 ? 1.660
		: nominal_pipe_size == 3/2 ? 1.900
		: nominal_pipe_size == 2 ? 2.375
		: nominal_pipe_size == 5/2 ? 2.875
		: nominal_pipe_size == 3 ? 3.500
		: nominal_pipe_size == 7/2 ? 4
		: nominal_pipe_size == 4 ? 4.5
		: nominal_pipe_size == 5 ? 5.563
		: nominal_pipe_size == 6 ? 6.625
		: nominal_pipe_size == 8 ? 8.625
		: nominal_pipe_size == 10 ? 10.750
		: nominal_pipe_size == 12 ? 12.750
		: nominal_pipe_size == 14 ? 14
		: nominal_pipe_size == 16 ? 16
		: nominal_pipe_size == 18 ? 18
		: nominal_pipe_size == 20 ? 20
		: nominal_pipe_size == 24 ? 24
		: 0
		;

	// http://en.wikipedia.org/wiki/National_pipe_thread
	// http://www.csgnetwork.com/mapminsecconv.html
	//http://www.hasmi.nl/en/handleidingen/draadsoorten/american-standard-taper-pipe-threads-npt/
	angle = 30;
	TPI_threads_per_inch = get_n_threads(nominal_pipe_size);
	pitch = 1.0/TPI_threads_per_inch;
	height = 0.866025 * pitch; //height from peak to peak , ideal without flat
	max_height_inner_to_outer_flat = 0.8 * pitch; 
	
	//Simple rules for all threads, not really correct
	//So far, exact clearance not implemented.
	//This is a rough approximation derived from mdmetric.com data	
	min_clearance_to_outer_peak = 0.033 * pitch; // value  from website  
	max_clearance_to_outer_peak = 0.088 * pitch; // aproximation, is dependent on thread size
	min_outer_flat = 0.038 * pitch;
	max_outer_flat = 2 * accurateTan(angle) * max_clearance_to_outer_peak;

	//so far, exact clearance not implemented.
	//This is a rough approximation derived from mdmetric.com data	
	clearance = internal ? max_clearance_to_outer_peak - min_clearance_to_outer_peak
							: 0;
	outside_diameter = get_outside_diameter(nominal_pipe_size);

	// Convert to mm.
	mm_diameter = outside_diameter*25.4;
	mm_pitch = (1.0/TPI_threads_per_inch)*25.4;
	mm_length = length*25.4;
	mm_outer_flat = (internal ? max_outer_flat : min_outer_flat) * 25.4;
	mm_max_height_inner_to_outer_flat = max_height_inner_to_outer_flat *25.4;
	mm_bore = nominal_pipe_size * 25.4;

	simple_profile_thread (
			pitch = mm_pitch,
			length = mm_length,
			upper_angle = angle, 
			lower_angle = angle,
			outer_flat_length = mm_outer_flat,
			major_radius = mm_diameter / 2,
			minor_radius = mm_diameter / 2 - mm_max_height_inner_to_outer_flat,
			internal = internal,
			n_starts = 1,
			right_handed = true,
			clearance = clearance,
			backlash =  0,
			printify_top = false,
			printify_bottom = false,
			bore_diameter = mm_bore,
			taper_angle = atan(1/32) //tan−1(1⁄32) = 1.7899° = 1° 47′ 24.474642599928302″.
			);	
}

//-------------------------------------------------------------------
//-------------------------------------------------------------------
// Meccano Worm Thread
//
module meccano_worm_gear_narrow_No32b (
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
)
{
	meccano_worm_thread (
			length = (7/8 * 25.4)-6,  //6mm = about the length of the hub
			diameter = 15/32 * 25.4,  //http://www.meccanospares.com/32b-BR-N.html
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
			);
}

module meccano_worm_gear_std_No32 (
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
)
{
	meccano_worm_thread (
			length = (7/8 * 25.4)-6,  //6mm ca Hub
			diameter = 25.4*0.553,		//technical drawing
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
			);
}
			
			
module meccano_worm_thread (
			length = 10,
			diameter = 25.4*0.553,
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
)
{
	maj_rad = diameter / 2;
	min_rad = diameter / 2 - 25.4*0.064;
	echo("*** Meccano Worm Data ***");
	echo("thread depth :",1/25.4*(maj_rad));
	echo("gear mesh [inch]:",(maj_rad+min_rad)/25.4);
	echo("gear mesh [mm]:",(maj_rad+min_rad), 25.4/2);	
	echo("*** End Meccano Worm Data ***");
	
    simple_profile_thread (
			pitch = 25.4/12,  //12 TPI
			length = length,
			upper_angle = 20, 
			lower_angle = 20,
			outer_flat_length = (25.4*0.037)-2*(tan(20)*(25.4*0.026)),
			major_radius = maj_rad,
			minor_radius = min_rad,
			internal = false,
			n_starts = 1,
			right_handed = right_handed,
			clearance = 0,
			backlash =  0,
			printify_top = printify_top,
			printify_bottom = printify_bottom,
			bore_diameter = 4,
			exact_clearance = exact_clearance
			);
}

//-------------------------------------------------------------------
//-------------------------------------------------------------------
// Channel Thread
//
module channel_thread(
		thread_diameter = 8,
		pitch = 1,
		length = 1,
		internal = false,
		n_starts = 1,
		thread_angles = [0,45],
		outer_flat_length = 0.125,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		bore_diameter = -1,
		exact_clearance = true		
)
{
	if(outer_flat_length >= length)
	{
		echo("*** Warning !!! ***");
		echo("channel_thread(): tip of thread (outer_flat_length) cannot be larger than height!");
	}
	
	simple_profile_thread (
			pitch = pitch,
			length = length,
			upper_angle = thread_angles[0], 
			lower_angle = thread_angles[1],
			outer_flat_length = outer_flat_length,
			major_radius = thread_diameter / 2,
			minor_radius = metric_minor_radius(thread_diameter, pitch),
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash = backlash,
			printify_top = false,
			printify_bottom = false,
			is_channel_thread = true,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
			);

}


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Functions 
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// OpenSCAD version 2014.03 and also 2014.QX (only for tan) created
// incorrect values for "even" angles.
// Update: As of OpenScad 2015.03 sin() and cos() deliver correct values.

function accurateTan(x) = 
(x%15)!=0?tan(x): (x<360?simpleTan(x):simpleTan(x-floor(x/360)*360));
function simpleTan(x) =
x==0 ? 0 :
x==30 ? 1/sqrt(3):
x==45 ? 1 :
x==60 ? sqrt(3):
x==120 ? -sqrt(3):
x==135 ? -1 :
x==150 ? -1/sqrt(3):
x==180 ? 0 :
x==210 ? 1/sqrt(3):
x==225 ? 1 :
x==240 ? sqrt(3):
x==300 ? -sqrt(3):
x==315 ? -1 :
x==330 ? -1/sqrt(3):
x==360 ? 0 : tan(x);
// TEST
/*
echo("tan");
for (angle = [0:1:721]) 
{
   if((tan(angle)-accurateTan(angle)) != 0)
   echo(angle, tan(angle)-accurateTan(angle));
}
*/
	
			
function atan360(x,y) = 
			x > 0 ?
				y > 0 ?
					atan(y/x)
				: y == 0 ?
						0
					: //y < 0
						270 - atan(x/y)
			:
				x == 0 ?
					y > 0 ?
						90
					:
						y == 0 ?
							0
						:
							//y<0
							270
				:
					//x < 0
					y > 0 ?
						90 - atan(x/y)
						:	y == 0 ?
							180
							: //y<0
							180 + atan(y/x)
						;
		
function rotate_xy(angle, vect_3D) = [
		vect_3D.x*cos(angle)-vect_3D.y*sin(angle),
		vect_3D.x*sin(angle)+vect_3D.y*cos(angle),
		vect_3D.z
		];

function scale_xy(point, scale_factor) =
				[point.x * scale_factor,
				 point.y * scale_factor,
				 point.z
				];
	
function z_offset_v3(z_offset, vect_3D) = 
		[vect_3D.x,
		vect_3D.y,
		vect_3D.z + z_offset
		];	

function norm_xy(point)= norm([point.x, point.y,0]);
	

						
function sagitta_to_radius_extension(sagitta_diff, angle) =
							//sagitta_diff*cos(90-angle/2) ;
							sagitta_diff/sin(90-angle/2);
function chord_sagitta(radius, angle) = radius - chord_apothem(radius, angle);
function chord_apothem(radius, angle) = radius * cos(angle/2);		

function bow_to_face_distance_scale(radius, angle, screw_radius, internal) =
					radius_extension(radius, angle, screw_radius, internal) == 0 ?
						1 : get_scale(radius, radius_extension(radius, angle, screw_radius, internal));

function get_scale(length, extension)	=
						(length + extension)/length;
						
function bow_to_face_distance(radius, angle) = 
			radius*(1-cos(angle/2));
			
function radius_extension(radius, angle, screw_radius, internal) = 
			// - the bolt is reference ==> apply change only to internal threads
			!internal ? 0 //bolt will not be expanded
			:
			// - the internal thread must provide room for the external (screw) 
			//   to turn ==> expand radius.
			// - extreme case: With very flat flank angles and low $fn a screw
			//   thread may fall through a nut (internal).
			// - By using the diameter as reference for a screw, only the
			//   corners of the thread (think low $fn) have the correct diameter.
			//   So the screw has too little material between the corners.
			//   TODO (optional): parameter for the user if he wants to recut 
			//   the thread with machining tools
			// - TODO: Study extreme case with high pitch and big taper angle
			//      corners where are they? 
			//old: radius*(1-cos(angle/2))/cos(angle/2) : 0; //30 ==>0.29509
			(
				chord_apothem(radius, angle) >= screw_radius ? 0  //is turnable
				:
				 sagitta_to_radius_extension(
											sagitta_diff = screw_radius-chord_apothem(radius, angle),
											angle =	angle)
					 
			);

		
	
// netfabb recognises/marks a triangle as "degenerated" if it is too small
// Values:
// 0.0015 was necessary for a channel thread to suppress degenerated message 
//        in netfabb.
// 0.001 seems to be the trigger level in netfab. ==> See Settings in Netfab.
// The message in Netfabb about degenerated faces can also be reduced by
// changing the treshold to 0.0001 in Netfabb settings.
function netfabb_degenerated_min() = 0.0011; 
min_openscad_fs = 0.01;
min_center_x = 2 * netfabb_degenerated_min();//DEFAULT 2*netfabb_degenerated_min(), DEBUG: use 1200 * netfabb_degenerated_min()
tol = 1/pow(2,50); //8.88178*10-16

function get_clearance(clearance, internal) = (internal ? clearance : 0);
function get_backlash(backlash, internal) = (internal ? backlash : 0);


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Simple profile thread
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
module simple_profile_thread(
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
	printify_bottom = false,
	is_channel_thread = false,
	bore_diameter = -1, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = true
)
{
	// ------------------------------------------------------------------
  // trapezoid calculation
	// ------------------------------------------------------------------

    // looking at the tooth profile along the upper part of a screw held
    // horizontally, which is a trapezoid longer at the bottom flat
    /*
                upper flat
 upper angle___________________lower angle 
           /|                 |\   
          / |                 | \  right angle
    left /__|                 |__\______________
   angle|   |                 |   |   lower     |
        |   |                 |   |    flat     |
        |left                 |right
         flat                 |flat
				tooth flat
        <------------------------->

	
	// extreme difference of the clearance/backlash combinations

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
   	left_angle = (90 - upper_angle);
   	right_angle = (90 - lower_angle);
	tan_left = accurateTan(upper_angle);
	tan_right = accurateTan(lower_angle);
	
		/*  Old polygon points diagram.   
		(angles x0 and x3 inner are actually 60 deg)
	
	                             B-side(behind)
	                                      _____[10](B)
	                                _[18]/    |
	                         ______/         /|
	                        /_______________/ |
	                    [13]|     [19] [11]|  |
	                        |              | /\ [2](B)
	                        |              |/  \
	                        |           [3]/    \
	                  [3]   |              \     \
	                        |              |\     \ [6](B)
	                        |    A-side    | \    /
	                        |    (front)   |  \  /|
	             z          |              |[7]\/ | [5](B)
	             |          |          [14]|   | /|
	             |   x      |  (behind)[15]|   |/ /
	             |  /       |              |[4]/ |
	             | /        |              |  /  |   
	             |/         |              | / _/|[1] (B)
	    y________|          |           [0]|/_/  |
	   (r)                  |              |     |[9](B)
	                        |    [17](B)   |  __/
	                    [12]|___________[8]|_/ 
	                             [16]

		// Rule for face ordering: look at polyhedron from outside: points must
		// be in clockwise order.
		*/
			
	// ------------------------------------------------------------------
	// Flat calculations
	// ------------------------------------------------------------------
	// The thread is primarly defined by outer diameter, pitch, angles.
	// The parameter outer_flat_length is only secondary.
	// For external threads inner diameter is important too but for
	// internal threads inner diameter is not so important. Depending on
	// the values of backlash and clearance inner diameter may get bigger 
	// than major_radius-tooth_height.
	// Because this module has many parameters the code here must be
	// robust to check for illegal inputs.
	
	function calc_left_flat(h_tooth) = 
				get_left_flat(h_tooth) < 0.0001 ? 0 : get_left_flat(h_tooth);
	function get_left_flat(h_tooth) = h_tooth / accurateTan (left_angle);
	function calc_right_flat(h_tooth) = 
				get_right_flat(h_tooth) < 0.0001 ? 0 : get_right_flat(h_tooth);
	function get_right_flat(h_tooth) = h_tooth / accurateTan (right_angle)	;

	function get_minor_radius() =
				// - A large backlash fills thread depth at minor_radius 
				//   therefore increases minor_radius, decreases tooth_height
				// - Threads with variable angles have no minor radius defined
				//   we need to calculate it
				(calc_upper_flat()
					+ calc_left_flat(param_tooth_height())
					+ calc_right_flat(param_tooth_height())
				) <= pitch ?
					(minor_radius != 0 ? minor_radius : calc_minor_radius())
				: calc_minor_radius()
				;
	function calc_minor_radius() =
				major_radius-
				((pitch-calc_upper_flat()) 
					/ (accurateTan(upper_angle)+accurateTan(lower_angle)))
				;
	function param_tooth_height() = major_radius - minor_radius;
	function calc_tooth_height()=
				calc_left_flat(param_tooth_height())+calc_right_flat(param_tooth_height())
					<= pitch ?
				( // Standard case, full tooth height possible
					param_tooth_height()
				)
				: ( // Angle of flanks don't allow full tooth height.
					// Flats under angles cover at least whole pitch
					// so tooth height is being reduced.
					pitch/(accurateTan(upper_angle)+accurateTan(lower_angle)) 
				);
	function calc_upper_flat() =
				get_upper_flat(backlash) > 0 ? get_upper_flat(backlash) : 0
				;
	function get_upper_flat(f_backlash) =
				outer_flat_length + 
				(internal ?
			  		+left_flank_diff(f_backlash) + right_flank_diff(f_backlash)
					:0)
				;
	function left_flank_diff(f_backlash) =
				tan_left*clearance >= f_backlash/2 ?
					-(tan_left*clearance-f_backlash/2)
					: +(f_backlash/2-tan_left*clearance)
				;
	function right_flank_diff(f_backlash) =
				tan_right*clearance >= f_backlash/2 ?
					 -(tan_right*clearance-f_backlash/2)
					: +(f_backlash/2-tan_right*clearance)
				;
	function calc_backlash(f_backlash) =
				get_upper_flat(f_backlash) >= 0 ? f_backlash 
				: f_backlash + (-1)*get_upper_flat(f_backlash)
				;

	function max_upper_flat(leftflat, rightflat) =
				pitch-leftflat-rightflat > 0 ?
					(pitch-leftflat-rightflat > calc_upper_flat() ?
						calc_upper_flat()
						: pitch-leftflat-rightflat)
					:0
				;

	clearance = get_clearance(clearance, internal);
	backlash = calc_backlash(get_backlash(backlash, internal));

	minor_radius = get_minor_radius();
	tooth_height = calc_tooth_height();
	// calculate first the flank angles because they are 
	// more important than outer_flat_length
	left_flat = calc_left_flat(tooth_height);
	right_flat = calc_right_flat(tooth_height);
	// then, if there is some pitch left assign it to upper_flat
	upper_flat = max_upper_flat(left_flat,right_flat);

	tooth_flat = upper_flat + left_flat + right_flat;
	//finally, if still some pitch left, assign it to lower_flat
	lower_flat = (pitch-tooth_flat >= 0) ? pitch-tooth_flat : 0;

	// ------------------------------------------------------------------
	// Radius / Diameter /length
	// ------------------------------------------------------------------
	//

	//internal channel threads have backlash on bottom too
	len_backlash_compensated = !internal || !is_channel_thread ? 
				length
			: length + backlash/2 
			 ;

	// ------------------------------------------------------------------
	// Warnings / Messages
	// ------------------------------------------------------------------
	
	//to add other objects to a thread it may be useful to know the diameters
	if(tooth_height != param_tooth_height())
	{
		echo("*** Warning !!! ***");
		echo("thread(): Depth of thread has been reduced due to flank angles.");
		echo("depth expected", param_tooth_height());
		echo("depth calculated", tooth_height);
	}
	if((!internal && outer_flat_length != upper_flat
		|| (internal && calc_upper_flat() != upper_flat)))
	{
		echo("*** Warning !!! ***");
		echo("thread(): calculated upper_flat is not as expected!");
		echo("outer_flat_length", outer_flat_length);
		echo("upper_flat", upper_flat);
	}
	if(upper_flat<0)
	{
		echo("*** Warning !!! ***");
		echo("thread(): upper_flat is negative!");
	}
	if(!internal && clearance != 0)
	{
		echo("*** Warning !!! ***");
		echo("thread(): Clearance has no effect on external threads.");
	}
	if(!internal && backlash != 0)
	{
		echo("*** Warning !!! ***");
		echo("thread(): Backlash has no effect on external threads.");
	}

	// ------------------------------------------------------------------
	// Display useful data about thread to add other objects
	// ------------------------------------------------------------------
/*
	echo("**** polyhedron thread ******");
	echo("internal", internal);
	echo("length", len_backlash_compensated);
	echo("pitch", pitch);
	echo("right_handed", right_handed);
	echo("tooth_height param", param_tooth_height());
	echo("tooth_height calc", tooth_height);
	echo("$fa (slice step angle)",$fa);
	echo("$fn (slice step angle)",$fn);
	echo("outer_flat_length", outer_flat_length);
	echo("upper_angle",upper_angle);
	echo("left_angle", left_angle);	
	echo("left_flat", left_flat);
	echo("upper flat param", outer_flat_length);
	echo("max_upper_flat(left_flat,right_flat)",max_upper_flat(left_flat,right_flat));
	echo("upper flat calc", upper_flat);
	echo("left_flank_diff", left_flank_diff(backlash));
	echo("right_flank_diff", right_flank_diff(backlash));
	echo("lower_angle",lower_angle);
	echo("right_angle", right_angle);
	echo("right_flat", right_flat);
	echo("lower_flat", lower_flat);
	echo("tooth_flat", tooth_flat);
	echo("total_flats", tooth_flat + lower_flat, "diff", pitch-(tooth_flat + lower_flat));
	echo("sum flat calc", calc_upper_flat()
					+ calc_left_flat(calc_tooth_height())
					+ calc_right_flat(calc_tooth_height()));
	echo("clearance", clearance);
	echo("backlash", backlash);
	echo("major_radius",major_radius);
	echo("minor_radius",minor_radius);
	echo("taper_angle",taper_angle);	
	echo("poly_rot_slice_offset()",poly_rot_slice_offset());
	echo("internal_play_offset",internal_play_offset());
	echo("******************************");
*/		
	// The segment algorithm starts at the same z for
	// internal and external threads. But the internal thread
	// has a bigger diameter because of clearance/backlash so the
	// internal thread must be shifted higher.	
	function channel_thread_bottom_spacer() =
			(internal ? clearance/accurateTan (left_angle)  : 0)
			;
			
	// z offset includes length added to upper_flat on left angle side
	function channel_thread_z_offset() = 
				-len_backlash_compensated // "len_backlash_compensated" contains backlash already
				+ channel_thread_bottom_spacer()
				;	
				
	// An internal thread must be rotated/moved because the calculation starts	
	// at base corner of right flat which is not exactly over base
	// corner of bolt (clearance and backlash)
	// Combination of small backlash and large clearance gives 
	// positive numbers, large backlash and small clearance negative ones.
	// This is not necessary for channel_threads.
	function internal_play_offset() = 
		internal && !is_channel_thread ?
				( 	tan_right*clearance >= backlash/2 ?
					-tan_right*clearance-backlash/2
					: 
					-(backlash/2-tan_right*clearance)
				)
			: 0;		

	translate([0,0, - channel_thread_bottom_spacer()]
									+ internal_play_offset())		
		make_profile_thread (
				pitch = pitch,
				length = length,
				major_radius = major_radius,
				minor_radius = minor_radius,
				internal = internal,
				n_starts = n_starts,
				right_handed = right_handed,
				clearance = clearance,
				backlash = backlash,
				printify_top = printify_top,
				printify_bottom = printify_bottom,
				is_channel_thread = is_channel_thread,
				bore_diameter = bore_diameter,
				taper_angle = taper_angle,
				exact_clearance = exact_clearance,
				tooth_profile_map	= simple_tooth_xz_map(left_flat, upper_flat, tooth_flat,
																							minor_radius, major_radius ),
				tooth_height = tooth_height
				);
				
	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// Tooth profile map
	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// A tooth can have any profile with multiple edges. 
	// But so far all threads use the standard profile map.
	// limitations: 
	//   - z-value must not be the same for two points.
	//   - no overhangs (low convexitiy)
	//
	// TODO:
	// Manual polygon triangulation for complex tooth profile maps		

	// Basic tooth profile
	// Only the tooth points are defined. Connections to the next/previous
	// tooth profile gives the full tooths profile. This way no in between
	// points (at zero or at pitch) are needed.
	// The profile starts with the left flat. For standard threads, this is
	// not important, but for channel threads it is exactly what we want.
	// Before version 3 the threads started with lower_flat.	

	function simple_tooth_xz_map(left_flat, upper_flat, tooth_flat,
																	minor_rad, major_rad) =
						// Build xz map of tooth profile
						upper_flat >= netfabb_degenerated_min()  ?
							[ [	minor_rad,  // x
									0],         // z offset
								[	major_rad,
									left_flat],
								[	major_rad,
									left_flat + upper_flat],
								[	minor_rad,
									tooth_flat]
							]
						:
							[ [	minor_rad,
									0],
								[	major_rad,
									left_flat],
								[	minor_rad,
									tooth_flat]]		
						;
				
	// ----------------------------------------------------------------------------
	// TODO : polyhedron axial orientation
	// ------------------------------------------------------------------
	//Correction angle so at x=0 is left_flat/angle
	//Not needed so far. Two problems:
	//Internal and external threads have different lower_flats and therefore
	//a different turn angle. ==> no nice thread differences.
	//With parameter "exact_clearance" a problem occurs. 
	function poly_rot_slice_offset() =
			((is_channel_thread ? 0 : 1)
			 *(right_handed?1:-1)
			 *(360/n_starts/pitch* (lower_flat/2)));
}

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Rope profile thread
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------

module rope_thread(
	thread_diameter = 20,
	pitch=2,
	length=8,
	internal = false,
	n_starts = 1,
	rope_diameter=1,
	rope_bury_ratio=0.4,
	coarseness = 10,
	right_handed = true,
	clearance = 0,
	backlash = 0,
	printify_top = false,
	printify_bottom = false,
	bore_diameter = 4, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = false)
{

	rope_profile_thread(
		pitch = pitch,
		length = length,
		rope_diameter = rope_diameter,
		rope_bury_ratio=rope_bury_ratio,
		coarseness = coarseness,
		major_radius = thread_diameter/2,
		internal = internal,
		n_starts = n_starts,
		right_handed = right_handed,
		clearance = clearance,
		backlash = backlash,
		printify_top = printify_top,
		printify_bottom = printify_bottom,
		bore_diameter = bore_diameter, //-1 = no bore hole. Use it for pipes 
		taper_angle = taper_angle,
		exact_clearance = exact_clearance
	);

}

module rope_profile_thread(
	pitch=1,
	length=10,
	rope_diameter=0.5,
	rope_bury_ratio=0.4,
	coarseness = 10,
	major_radius=20,
	internal = false,
	n_starts = 1,
	right_handed = true,
	clearance = 0,
	backlash = 0,
	printify_top = false,
	printify_bottom = false,
	bore_diameter = -1, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = true
)
{
	tooth_height = rope_diameter/2 * rope_bury_ratio;
	minor_radius = major_radius-tooth_height;
	clearance = get_clearance(clearance, internal);
	backlash = get_backlash(backlash, internal);

	xz_map = rope_xz_map(pitch, rope_diameter, rope_bury_ratio, coarseness,
																	minor_radius, major_radius);

	make_profile_thread (
		pitch = pitch,
		length = length,
		major_radius = major_radius,
		minor_radius = minor_radius,
		internal = internal,
		n_starts = n_starts,
		right_handed = right_handed,
		clearance = clearance,
		backlash = backlash,
		printify_top = printify_top,
		printify_bottom = printify_bottom,
		is_channel_thread = false,
		bore_diameter = bore_diameter,
		taper_angle = taper_angle,
		exact_clearance = exact_clearance,
		tooth_profile_map	= xz_map,
		tooth_height = tooth_height
		);

	//-----------------------------------------------------------
	// Tooth profile map
	//-----------------------------------------------------------
	// A tooth can have any profile with multiple edges. 
	// limitations: 
	//   - z-value must not be the same for two points.
	//   - no overhangs (low convexitiy)
	//
	// TODO:
	// Manual polygon triangulation for complex tooth profile maps		

	// Basic tooth profile
	// Only the tooth points are defined. Connections to the next/previous
	// tooth profile gives the full tooths profile. This way no in between
	// points (at zero or at pitch) are needed.
	// The profile starts with the left flat. For standard threads, this is
	// not important, but for channel threads it is exactly what we want.
	// Before version 3 the threads started with lower_flat.	

	function rope_xz_map(pitch, rope_diameter, rope_bury_ratio, coarseness,
																	minor_radius, major_radius) =
			let(rope_radius = rope_diameter/2,
					buried_depth = rope_radius * rope_bury_ratio,
					unburied_depth = rope_radius-buried_depth,
					buried_height =  2*sqrt(pow(rope_radius,2)-pow(unburied_depth,2)), //coarseness must go over the buried part only
					unused_radius = rope_radius - sqrt(pow(rope_radius,2)-pow(unburied_depth,2)),
					left_upper_flat	= (pitch-(rope_diameter-2*unused_radius))/2,
					right_upper_flat = pitch-(rope_diameter-2*unused_radius) -left_upper_flat
					)
			concat(
				[	[major_radius, 0],
					[major_radius, left_upper_flat]]
			,
				[for ( circel_seg = [1:1:coarseness-1]) 
					let(z_offset = circel_seg * (buried_height/coarseness),
							current_rad_on_base = abs(rope_radius - (unused_radius + z_offset)),
							depth = sqrt(pow(rope_radius,2)- abs(pow(current_rad_on_base,2)))
												-unburied_depth
						)
					//[major_radius-depth, left_upper_flat+z_offset]
					[major_radius-depth, left_upper_flat+z_offset]
				]	
			,	
				[	[major_radius, pitch-right_upper_flat]]

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
module make_profile_thread(
	pitch,
	length,
	major_radius,
	minor_radius,
	internal = false,
	n_starts = 1,
	right_handed = true,
	clearance = 0,
	backlash = 0,
	printify_top = false,
	printify_bottom = false,
	is_channel_thread = false,
	bore_diameter = -1, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = true,
	tooth_profile_map,
	tooth_height = 1
)
{

	// ------------------------------------------------------------------
	// Segments and its angle, number of turns
	// ------------------------------------------------------------------
	n_turns = ceil(length/pitch) // floor(): full turn needed for length < pitch
							// below z=0 turn is included for length only for channel threads
							+ (is_channel_thread ? 0 : 1)
							// internal channel threads showed missing dent. Probably
							// because for internal threads  backlash/clearance is missing in height
							+1; 
	
	n_horiz_starts = is_channel_thread ? n_starts : 1;
	n_vert_starts = is_channel_thread ? 1 : n_starts;
	
	n_segments_fn =  $fn > 0 ? 
						$fn :
						max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));

	n_segments = ceil(n_segments_fn/n_horiz_starts) * n_horiz_starts;

	seg_angle = 360/n_segments;
	
	is_hollow = bore_diameter > 0;
	hollow_rad = is_hollow ? bore_diameter/2 : min_center_x; //hollow_rad is used in plane polygons, may not be at center (x=0).


	
	clearance_ext = clearance_extension(major_radius, internal);
	turnability_ext = radius_extension(major_radius+clearance_ext, 
																		seg_angle, major_radius, internal);
	major_rad = major_radius + clearance_ext + turnability_ext;
	minor_rad = major_rad-tooth_height;
	diameter = major_rad*2;
	
	tooth_profile_map = 
		[for(point = tooth_profile_map)
			[point[0]+clearance_ext+turnability_ext,
				point[1] //leave z alone
			]
		];

	// Clearance/Turnability:
	// The outer walls of the created threads are not circular. They consist
	// of polyhydrons with planar front rectangles. Because the corners of 
	// these polyhedrons are located at major radius (x,y), the middle of these
	// rectangles is a little bit inside of major_radius. So, with low $fn
	// this difference gets larger and may be even larger than the clearance itself
	// but also for big $fn values clearance is being reduced. If one prints a 
	// thread/nut without addressing this they may not turn.
			
	function clearance_radius(radius) =
							radius + clearance_extension(radius);
	function clearance_extension(radius) =
							exact_clearance ?
								clearance
							:(radius+clearance)/cos(seg_angle/2)-radius
							;				
	function oversized_len() = (n_turns+1) * n_starts * pitch;
	function rest_of_channel_len(length) = 
							// reference is the non internal thread.
							// So channel_thread_bottom_spacer() is not included
							(	length >= 2*pitch ?
									length-2*pitch
									: 0
							);
						
				
	// ------------------------------------------------------------------
	// Warnings / Messages
	// ------------------------------------------------------------------
	
	//to add other objects to a thread it may be useful to know the diameters
	echo("*** Thread dimensions !!! ***");
	echo("outer diameter :",major_rad*2);
	echo("inner diameter :",minor_rad*2);

	if(is_hollow)
		echo("bore diameter :",hollow_rad*2);

	if(bore_diameter >= 2*minor_radius)
	{
		echo("*** Warning !!! ***");
		echo("thread(): bore diameter larger than minor diameter of thread !");
	}
	//collision test: only possible when clearance defined (internal)
	if(internal 
		&& (clearance_radius(major_radius, true)
			-bow_to_face_distance(clearance_radius(major_radius, true), seg_angle)
			+ 0.00001 //ignore floating point errors
		<  major_radius))
	{
		echo("*** Warning !!! ***");
		echo("thread(): With these parameters (clearance and $fn) a bolt will not turn in internal/nut thread!");
		echo("Consider using higher $fn,larger clearance and/or exact_clearance parameter.");
	}

	//------------------------------------------------------------------
	// Create the thread 
	// ------------------------------------------------------------------
	if(!is_channel_thread)
	{
		// Standard threads with multiple turns
			make_thread_polyhedron(turns = n_turns,
										thread_starts_flat = true,
										open_top = false,
										n_horiz_starts = n_horiz_starts,
										n_vert_starts = n_vert_starts,
										minor_rad = minor_rad,
										major_rad = major_rad,
										major_radius = major_radius,
										is_hollow = is_hollow,
										hollow_rad = hollow_rad,
										tooth_profile_map = tooth_profile_map,	
										is_channel_thread = is_channel_thread,
										internal = internal,
										pitch = pitch,
										n_segments = n_segments,
										seg_angle = seg_angle,
										right_handed = right_handed,
										taper_angle = taper_angle,
										length = length
									); 
	}
	else
	{
		//Channel threads
			translate([0, 0, (length >= 2*pitch ? 0 : 2*pitch-length)
								])
				make_thread_polyhedron(turns = n_turns,
													thread_starts_flat = false,
													open_top = true,
													n_horiz_starts = n_horiz_starts,
													n_vert_starts = n_vert_starts,
													minor_rad = minor_rad,
													major_rad = major_rad,
													major_radius = major_radius,
													is_hollow = is_hollow,
													hollow_rad = hollow_rad,
													tooth_profile_map = tooth_profile_map,
													is_channel_thread = is_channel_thread,
													internal = internal,
													pitch = pitch,
													n_segments = n_segments,
													seg_angle = seg_angle,
													right_handed = right_handed,
													taper_angle = taper_angle,
													length = length	
												);  				
	}
} // end module m_thread()



//-----------------------------------------------------------
//-----------------------------------------------------------
// Thread Polyhedron calculation
//-----------------------------------------------------------
//-----------------------------------------------------------
module make_thread_polyhedron(
					turns = 1, //make_thread_polygon() adds always one turn to this value
					thread_starts_flat = true, //"true" adds extra loop, so at z=0 the
																		 // resulting thread is flat/full
					open_top = false,  	// Default: std threads have no open top so far
															// But internal channel threads have always 
															// an open top to let insert the channel thread 
															// to a certain depth without a thread over the
															// whole depth
					n_horiz_starts = 1, //channel threads start multiple times (rotated)
					n_vert_starts = 1, //std threads can have more than one start (lifted)
					minor_rad = 10,
					major_rad = 12,
					major_radius = 12,
					is_hollow = true,
					hollow_rad = 5,
					tooth_profile_map,
					is_channel_thread = false,
					internal = false,
					pitch = 2,
					n_segments = 30,
					seg_angle = 12,
					right_handed = true,
					taper_angle = 0,
					length = 20	
					)
{

	// ------------------------------------------------------------------
	// Debug Messages
	// ------------------------------------------------------------------
	/*
	echo("n_segments",n_segments);
	echo("seg_angle",seg_angle);
	echo("tooth_profile_map", tooth_profile_map);
	echo("is_hollow", is_hollow);
	*/

	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// 3d vector points base on tooth profile map
	//-----------------------------------------------------------
	//-----------------------------------------------------------

	function get_3Dvec_tooth_points(turn, combined_start, is_last_tooth, tooth_profile_map ) =
			let(y_offset = get_3Dvec_profile_yOffset())  //So far it is zero.
			concat(
				[for (points =	
					
					[
						for(profile_xz_point = tooth_profile_map)	
						let(z_offset = get_3Dvec_profile_zOffset(turn, combined_start) 
														+ profile_xz_point[1])
							[ //The profile point
								[	compensate_tooth_x(turn, combined_start,
																			profile_xz_point[0],
																			profile_xz_point[1]),
									y_offset,
									z_offset
								]
							,
								[ //The minor radius point at same z
									get_3Dvec_profile_xOffset_minor(),
									y_offset,
									z_offset
								]
						]])
						for(point = points) //flatten
							point
					]
					//Add lower flat/rest of pitch as point on top turn
					, !is_last_tooth ? []
						: 
						(let(z_offset = get_3Dvec_profile_zOffset(turn+1, 0) 
														+ tooth_profile_map[0][1])
							[
								[	compensate_tooth_x(turn, combined_start,
																				tooth_profile_map[0][0],
																				tooth_profile_map[0][1]),
									y_offset,
									z_offset
								]
							,
								[ //The minor radius point at same z
									get_3Dvec_profile_xOffset_minor(),
									y_offset,
									z_offset
								]
							]
						)
					);
		

			
	// TODO: use open_top because woodscrews may need only x for shaft
	function compensate_tooth_x(turn, combined_start, tooth_x, z_offset) =
		(!is_channel_thread 
			|| (is_channel_thread && turn == 0) 
			|| (is_channel_thread && turn == 1 && z_offset==0 && internal)
			)?
			// 1 : For standard threads and first turn of channel threads
			//     create normal thread profile.
			//     The first turn of a channel thread must have a profile.
			//     Because the lower_flat has no seperate point we must force
			//     profile for internal channel threads
			tooth_x
		:
		(
			// 2 : Channel threads
			internal?
			(
				// 2A : For internal channel threads create enough space to insert
				//     male channel thread.
				get_3Dvec_profile_xOffset_major()
			)
			:
			(
				// 2B : For external channel threads do not create a thread
				//     above first turn
				get_3Dvec_profile_xOffset_minor()
			)
		)
		;	

	function get_3Dvec_profile_xOffset_minor() = minor_rad;
	function get_3Dvec_profile_xOffset_major() = major_rad;
	function get_3Dvec_profile_yOffset() =	0;
	
	function get_3Dvec_profile_zOffset(turn, combined_start) =	
										//Increase z because of tooth raster.
										//Here segment angle is not relevant.
										//==> base height for one tooth. Flats must be added.
										//1) increase z for every vertical start (tooth)
										pitch * ((turn*n_tooths_per_turn()) + combined_start)
										;
	function get_3Dvec_profile_zOffset_bottom(turn, combined_start) =	
										get_3Dvec_profile_zOffset(turn, combined_start)
										//+ ( (internal && turn == 0 && vertical_start == 0) ?
										//			-clearance
										//			: 0
										//	)
										;	

	// -------------------------------------------------------------
	//Create an array of planar points describing the profile of the tooths.
	function get_3Dvec_tooths_points(seg_plane_index) = 
					[
					for (turn = [ 0 : 1: n_turns_of_seg_plane(seg_plane_index)-1 ]) 
						let (is_last_turn = (turn == n_turns_of_seg_plane(seg_plane_index)-1))
						for (combined_start = [0:1:n_tooths_per_turn()-1])  
						let (is_last_comb_start = (combined_start == n_tooths_per_turn()-1),
								is_last_tooth = is_last_turn && is_last_comb_start)
							for (point = get_3Dvec_tooth_points(turn,
																									combined_start,
																									is_last_tooth,
																									tooth_profile_map) )
									point
					]
				;
	// Profile 

	pre_calc_3Dvec_tooth_points = get_3Dvec_tooth_points(0, 0,false,tooth_profile_map);
	len_tooth_points = len(pre_calc_3Dvec_tooth_points);
/*
// DEBUG
echo("n_vert_starts",n_vert_starts);
echo("n_horiz_starts",n_horiz_starts);
echo("len_tooth_points",len_tooth_points);	
//echo("pre_calc_3Dvec_tooth_points",pre_calc_3Dvec_tooth_points);
//echo("pre_calc_faces_points", pre_calc_faces_points);
echo("len(pre_calc_faces_points)",len(pre_calc_faces_points));
//echo(thread_faces);	
for (seg_plane_index = [0:get_n_segment_planes()-1])	
{
	echo("********************************");
	echo("seg_plane_index",seg_plane_index);
	echo("get_adj_seg_plane_index",seg_plane_index, get_adj_seg_plane_index(seg_plane_index));
	echo("get_adj_seg_plane_index",seg_plane_index -1, get_adj_seg_plane_index(seg_plane_index-1));
	echo("get_adj_seg_plane_index",seg_plane_index + 1,get_adj_seg_plane_index(seg_plane_index+1));
	echo("is_first_plane_of_horiz_start",is_first_plane_of_horiz_start(seg_plane_index));

	echo("n_tooths_of_seg_plane(seg_plane_index)",seg_plane_index,n_tooths_of_seg_plane(seg_plane_index));
	echo("len(get_3Dvec_tooths_polygon(seg_plane_index))",len(get_3Dvec_tooths_polygon(seg_plane_index)));
	echo("len_seg_plane",len_seg_plane(seg_plane_index));
	echo("get_point_index_offset(get_adj_seg_plane_index(seg_plane_index+1,false)", get_point_index_offset(get_adj_seg_plane_index(seg_plane_index+1),false));
	echo("get_starts_segment_zOffset(seg_plane_index)",get_starts_segment_zOffset(seg_plane_index));
	echo("get_horiz_starts_segment_zOffset(seg_plane_index)",get_horiz_starts_segment_zOffset(seg_plane_index));
	echo(" get_segment_zOffset(seg_plane_index)", get_segment_zOffset(seg_plane_index));
	echo("get_3Dvec_profile_zOffset(turn, combined_start)",get_3Dvec_profile_zOffset(0, 0));
	echo("get_3Dvec_profile_zOffset(turn, combined_start)",get_3Dvec_profile_zOffset(0, 1));
	echo("get_3Dvec_profile_zOffset(turn, combined_start)",get_3Dvec_profile_zOffset(0, 2));
	echo("get_3Dvec_profile_zOffset(turn, combined_start)",get_3Dvec_profile_zOffset(1, 0));
	echo("get_3Dvec_tooth_points(0,0,)",get_3Dvec_tooth_points(turn=0,combined_start=0,is_last_turn=false,tooth_profile_map));
	echo("get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index)[1]",get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index)[1]);
	echo("get_segment_zOffset(seg_plane_index) ...",get_segment_zOffset(seg_plane_index) 
														- (is_channel_thread ? pitch*2 : 
																						pitch*(n_vert_starts*n_horiz_starts)));
	echo("len_seg_plane(start_seg_plane_index)",len_seg_plane(seg_plane_index));
	
}	
*/

	function len_seg_plane(seg_plane_index) =
							n_tooths_of_seg_plane(seg_plane_index) * len_tooth_points
							+ 2*n_center_points() //center points on top and end
							+ ( //point pair added on top to complete pitch over lower flat 
									tooth_profile_map[len(tooth_profile_map)-1][1] < pitch ?
										n_points_per_edge() : 0
								)
							;
	function n_tooths_of_seg_plane(seg_plane_index) = 
						n_tooths_per_turn() * n_turns_of_seg_plane(seg_plane_index);
	function n_turns_of_seg_plane(seg_plane_index) =
						is_first_plane_of_horiz_start(seg_plane_index) ? (turns+1) : turns;

	function n_points_per_turn() =  n_tooths_per_turn() * len_tooth_points;
	function n_points_per_start() =  n_vert_starts * len_tooth_points;
	function n_tooths_per_turn()	= n_vert_starts;//*n_horiz_starts;					
	function n_tooths_per_start()	= n_vert_starts;										
	function n_center_points() = 2;				
	function n_points_per_edge() = 2;		
	function is_center_point(point_index, tooths_polygon) = (point_index < n_center_points()) || (point_index > len(tooths_polygon)-n_center_points()-1);
	function top_z() = is_channel_thread ? length-(-1)*bottom_z(): length;
	function bottom_z() = is_channel_thread ? -thread_height_below_zero() :  0;
	function thread_height_below_zero() = is_channel_thread ? 2* pitch*n_tooths_per_start() : pitch*n_tooths_per_turn();
	
	
	// -------------------------------------------------------------
	//Create a closed planar (point.y=0) polygon with tooths profile and center points
	function get_3Dvec_tooths_polygon(seg_plane_index) =
						complete_3Dvec_tooths_polygon(get_3Dvec_tooths_points(seg_plane_index));
	//DEBUG
	/*
	echo("******************", len(get_3Dvec_tooths_points(0)), len(get_3Dvec_tooths_points(1)));
	echo("******************", get_3Dvec_tooths_points(0));
	echo("******************", get_3Dvec_tooths_points(1));
	*/
	
	function complete_3Dvec_tooths_polygon(tooths_profile) = 
				concat(
					//bottom center point
					[[0,0,tooths_profile[0].z]],
					[[hollow_rad,0,tooths_profile[0].z]], //hollow_rad is not zero, see make_profile_thread(), so no conflict with first point.
					//tooth points
					tooths_profile,
					//top center point
					[[hollow_rad,0,tooths_profile[len(tooths_profile)-1].z]],
					[[0,0,tooths_profile[len(tooths_profile)-1].z]]
				);
	

	pre_calc_tooths_polygon = get_3Dvec_tooths_polygon(0);				
	tooths_polygon_point_count = len(pre_calc_tooths_polygon);
	/*
	//DEBUG
	echo("pre_calc_tooths_polygon",pre_calc_tooths_polygon);
	echo("tooths_polygon_point_count",tooths_polygon_point_count);
	*/

	aligned_3Dvec_segments_points = 
									[
										for (seg_plane_index = [0:1:get_n_segment_planes()-1])
											get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index, tol)
									];
	
	pre_calc_seg_plane_point_polygons = get_3Dvec_seg_plane_point_polygons(aligned_3Dvec_segments_points);
	/*
	//DEBUG
	pre_calc_seg_index=0;	
	echo("get_3Dvec_seg_plane_point_polygons_aligned(pre_calc_seg_index)",pre_calc_seg_plane_point_polygons[pre_calc_seg_index], len(pre_calc_seg_plane_point_polygons[pre_calc_seg_index]), len(get_3Dvec_tooths_polygon(pre_calc_seg_index)));
	*/
	
	// -------------------------------------------------------------
	//- Rotate and lift ( z axis) the pre calculated planar tooths polygon
	//  for each segment angle.
	//- taper point
	// Array of planar polygons rotated and lifted in z
	function get_3Dvec_seg_plane_point_polygons(aligned_3Dvec_segments_points) = 
						[
							let(all_toped_seg_points =
									[
											for(seg_index = [0:1:len(aligned_3Dvec_segments_points)-1])
												let(previous_seg_index = get_adj_seg_plane_index(seg_index-1),
														toped_seg_points = orientate_thread_points_at_z(top_z(), true, false, seg_index, aligned_3Dvec_segments_points[seg_index], 
																											previous_seg_index, aligned_3Dvec_segments_points[previous_seg_index])
													)
												//aligned_3Dvec_segments_points[seg_index]
												toped_seg_points
							
									],
									all_bottomed_seg_points_reinverted = 
										[
											for(seg_index = [0:1:len(all_toped_seg_points)-1]) //the order direction does not matter, the z-values are given per segement.
												let(adj_seg_index = get_adj_seg_plane_index(seg_index),
														previous_seg_index = get_adj_seg_plane_index(adj_seg_index+1), //+1 because the inverse thread has more negative z-values with rising segement index (for right -handed threads).
														toped_seg_points_inv =invert_minor_major(
																											invert_order(
																												invert_z(all_toped_seg_points[adj_seg_index])
																											)
																										)
																										,
														previous_toped_seg_points_inv = invert_minor_major(
																											invert_order(
																												invert_z(all_toped_seg_points[previous_seg_index])
																											)
																										),
														bottomed_seg_points = is_channel_thread ? toped_seg_points_inv
																							: orientate_thread_points_at_z(-(bottom_z()+0), true, true, 
																											adj_seg_index, toped_seg_points_inv, 
																											previous_seg_index, previous_toped_seg_points_inv),
														bottomed_seg_points_reinv = invert_z(
																													invert_order(
																														invert_minor_major(bottomed_seg_points)
																													)
																												)
													)
											bottomed_seg_points_reinv
										],
									return_reversed = false,
									start_seg = return_reversed ? len(all_bottomed_seg_points_reinverted)-1 : 0,
									end_seg = return_reversed ? 0 : len(all_bottomed_seg_points_reinverted)-1,
									step_seg = return_reversed ? -1 : 1
							)
								//return segments 
								for(seg_index = [start_seg:step_seg:end_seg])
									aligned_3Dvec_segments_points[seg_index]
								
						];

	cross_point_type_SAME_SEG_AT_Z = 1;
	cross_point_type_SAME_SEG_THROUGH_Z = 2;
	cross_point_type_TWO_SEGS_FIRST_FIRST = 3;
	cross_point_type_TWO_SEGS_FIRST_SECOND = 4;
		
					
								
	function find_z_cross_points(z, aligned_3Dvec_segments) =
		//Test case 1:
		//metric_thread(8, pitch=3, length=5, right_handed=true, internal=false, n_starts=3, bore_diameter=2);
		//Test case 7 
		//test_rope_thread(rope_diameter=1.2, length = 1, right_handed=false, rope_bury_ratio=0.9, coarseness=7,n_starts=2 );
		// Test case:
		//	Any square thread, to test the cases with where multiple points exactly at z create correct output.
		//	For all segement points exactly at z there should be a cp. But later on, during generating facets, the not all polygons
		//  towards center are needed, but towards previous/next cross point.
		let(cross_points = 
		[
		for (current_seg_index = [0:1:len(aligned_3Dvec_segments)-1])
			let(next_seg_index = get_adj_seg_plane_index(current_seg_index+1),
					current_seg_points = aligned_3Dvec_segments[current_seg_index],
					next_seg_points = aligned_3Dvec_segments[next_seg_index],
					total_seg_center_pt_bottom = all_3Dvec_seg_indexes_starts[current_seg_index] + 1,
					total_seg_center_pt_top = all_3Dvec_seg_indexes_starts[current_seg_index] + len(aligned_3Dvec_segments[current_seg_index]) - n_center_points()
				)
				//[
		/*
				for(current_seg_point_i = [n_center_points():n_points_per_edge(): len(current_seg_points)-1
																																			-n_center_points() //jump over center points
																																			-1 //-1 jump over last minor point
																																			-n_points_per_edge()])
		*/
		
				//To get the correct point order (correctly sorted in a way that a correct polygon of the crosspoints is being built),
				//The scan starts on top and goes down the segment points.
				for(current_seg_point_i = [len(current_seg_points)-1
																		-n_center_points() //jump over center points
																		-1 //-1 jump over last minor point 
																		-n_points_per_edge() //jump one point forward to be able to get next second point
																		:-n_points_per_edge(): n_center_points() //Important to go at end
																	])
					let(current_seg_second_point_i = current_seg_point_i+n_points_per_edge(),
							next_seg_point_i = current_seg_point_i + (is_first_plane_of_horiz_start(next_seg_index) ? n_points_per_start() : 0),
							next_seg_second_point_i = next_seg_point_i + n_points_per_edge(),
							next_seg_previous_point_i = next_seg_point_i  - n_points_per_edge(),
							total_current_point_i = all_3Dvec_seg_indexes_starts[current_seg_index]+current_seg_point_i,
							total_current_second_point_i = all_3Dvec_seg_indexes_starts[current_seg_index]+current_seg_second_point_i,
							total_next_point_i = all_3Dvec_seg_indexes_starts[next_seg_index]+next_seg_point_i,
							total_next_second_point_i = all_3Dvec_seg_indexes_starts[next_seg_index]+next_seg_second_point_i
							
					)
					current_seg_index == -1 ? []  //DEBUG: limit to one segment
						:
						concat(
						// Case 1: z cross between two points of the same segment
						current_seg_points[current_seg_point_i].z == z ?
							//point exactly at z
							//Since the zero point with index from faces collection is already used by above faces loop,
							//we must later prefer this index instead of the new one to have only one point at the same position. 
							1==2 ? [] :
							[[[current_seg_index], //segments
								[total_current_point_i, total_current_second_point_i], //point indexes
								current_seg_points[current_seg_point_i], //3D_vec of cross point
								atan360(current_seg_points[current_seg_point_i].x,current_seg_points[current_seg_point_i].y), //angle
								cross_point_type_SAME_SEG_AT_Z, //Indicator
								[total_seg_center_pt_bottom, total_seg_center_pt_top]
							]]
						: []
						,
							1==2 ? [] :
							current_seg_points[current_seg_point_i].z  < z && current_seg_points[current_seg_second_point_i].z  > z 
							? 
							//TTT 0 (1.Durchlauf),  3( 2.Durchlauf)
							// Segement line crosses z.
							// To get a correct order this is the steepest cross above current, so we issue it first.
							let(cpi_cspi_cross = z_cross_of_line(current_seg_points[current_seg_point_i], current_seg_points[current_seg_second_point_i], z))
							[[[current_seg_index], //segments
								[total_current_point_i, total_current_second_point_i], //point indexes
								cpi_cspi_cross, //3D_vec of cross point
								atan360(cpi_cspi_cross.x,cpi_cspi_cross.y), //angle
								cross_point_type_SAME_SEG_THROUGH_Z, //Indicator
								[total_seg_center_pt_bottom, total_seg_center_pt_top]
							]]
							: [] //no cross
						,
						// Case 3: cross between current_seg_point_i and next_seg_second_point_i
						// The result depends on how the two polygons of the four points of a facet will be drawn.
						// So far for left and right handed no distinction is needed.
						1==2 ? [] :
						current_seg_points[current_seg_point_i].z  < z && next_seg_points[next_seg_second_point_i].z > z   //current seg point is below z and next seg point is above z ==> cross!!!!
						// TTT 	1(1.Durchlauf), 4 (2.Durchlauf)
						// To get a correct order, before calculating cross for "current/Current to next/next"
						// the cross for "current/current to next/next_second" will be evaluated because it is steeper and therefore "before" (angle-wise).
						?
							
							let(cpi_nspi_cross = z_cross_of_line(current_seg_points[current_seg_point_i], next_seg_points[next_seg_second_point_i], z))
							[[[current_seg_index,next_seg_index], //segments
								[total_current_point_i, total_next_second_point_i], //point indexes
								cpi_nspi_cross, //3D_vec of cross point
								atan360(cpi_nspi_cross.x,cpi_nspi_cross.y), //angle
								cross_point_type_TWO_SEGS_FIRST_SECOND, //Indicator
								[total_seg_center_pt_bottom, total_seg_center_pt_top]
							]]
							: []	
						,
						// Case 2: cross between current_seg_point_i and next_seg_point_i
						// The result depends on how the two polygons of the four points of a facet will be drawn.
						// So far for left and right handed no distinction is needed.
						1==2 ? [] :
						current_seg_points[current_seg_point_i].z  < z && next_seg_points[next_seg_point_i].z > z  
						//TTT 2 (1.Durchlauf), 5 (2.Durchlauf)
						?
							//current seg point is below z and next seg point is above z ==> cross!!!!
							let(cpi_npi_cross = z_cross_of_line(current_seg_points[current_seg_point_i], next_seg_points[next_seg_point_i], z))
							//[]
							[[[current_seg_index,next_seg_index], //segments
								[total_current_point_i, total_next_point_i], //point indexes
								cpi_npi_cross, //3D_vec of cross point
								atan360(cpi_npi_cross.x,cpi_npi_cross.y), //angle
								cross_point_type_TWO_SEGS_FIRST_FIRST, //Indicator
								[total_seg_center_pt_bottom, total_seg_center_pt_top]
							]]
							: []
							
							
					) //end concat(), per segment
				] //end of all cross points
			//]
		) //end of let(crosspoints)
		
		//cross_points
		
		[
		for(seg = cross_points)
			for(cross_points_def = seg)
				if(len(cross_points_def)>=1)
					cross_points_def
		
				]
		
	;			
				
	all_3Dvec_seg_indexes_starts = 
		calc_3Dvec_seg_indexes_starts(0, 0, [], aligned_3Dvec_segments_points) ;
	//DEBUG							
	/*
	echo("all_3Dvec_seg_indexes_starts ", all_3Dvec_seg_indexes_starts);
	*/
				
	//RESULT with $fn=16, rope thread:
	//ECHO: "calc_3Dvec_seg_indexes_starts ", [0, 114, 228, 342, 456, 570, 684, 798, 912, 1026, 1140, 1254, 1368, 1482, 1596, 1710]
	function calc_3Dvec_seg_indexes_starts(seg_index, seg_index_sum, seg_indexes, segments_points) =
		seg_index >= n_segments ? 
			seg_indexes //break recursion
		:
			let(new_seg_index_sum = (seg_index == 0 ? 0 : seg_index_sum + len(segments_points[seg_index-1])))
			calc_3Dvec_seg_indexes_starts(seg_index+1, new_seg_index_sum, concat(seg_indexes, new_seg_index_sum), segments_points)
	;
			
			
	function sort_cross_points(unsorted_cross_points) =
		1==2 ?
			quicksort(unsorted_cross_points)
		:
			//unsorted		
			unsorted_cross_points
			;
	
	//Data Structure of cross points:
	//point index in final 3d Vec points], 
	//	[[current_seg,next_seg], [first_point_index, second_point_index], [cross_point], angle, cross_point_type_...]
	//]	
	top_first_result_cross_point_index = calc_total_array_elements_nxn(0,aligned_3Dvec_segments_points,0); //since array indexes start at zero, the length is just right
	z_top_cross_points = sort_cross_points(find_z_cross_points(top_z(),aligned_3Dvec_segments_points)); 
	indexed_z_top_cross_points = get_indexed_array(top_first_result_cross_point_index, z_top_cross_points) ;
	bottom_first_result_cross_point_index = top_first_result_cross_point_index + len(z_top_cross_points);
	z_bottom_cross_points = sort_cross_points(find_z_cross_points(bottom_z(),aligned_3Dvec_segments_points));	
	indexed_z_bottom_cross_points = get_indexed_array(bottom_first_result_cross_point_index, z_bottom_cross_points) ;

	//DEBUG
	// Use show_z_plane_cyl = true; and the same height as the thread's length.
	// Use "Show Edges" in OpenScad
	// Limit output to one segment (see code in function) : current_seg_index != 1 ? [] :
	/*
	echo("***************************************");
	echo("indexed_z_top_cross_points",indexed_z_top_cross_points);
	echo("***************************************");
	echo("indexed_z_bottom_cross_points",len(indexed_z_bottom_cross_points));
	for(pt=	indexed_z_bottom_cross_points)
		echo(pt);
	//Show cross points as 2D polygon
	cross_points_2D = [for(cp = z_top_cross_points) [cp[2].x, cp[2].y]];
	cross_points_2D_paths = [[for(i = [0:1:len(z_top_cross_points)-1]) i]];
	translate([10,10,0])
	polygon(cross_points_2D, paths=cross_points_2D_paths);
	*/
	
	function get_indexed_array(start_index, array) =
		[
			for(index = [start_index:1:start_index+len(array)-1])
				[index, array[index-start_index]]
		];
	
	//echo("find_z_seg_plane_cross_point_indexes()",find_z_seg_plane_cross_point_indexes(test_cross_points));
	function find_z_seg_plane_cross_point_indexes(cross_points_2D) =
				[
					for(index = [0:1:len(cross_points_2D)-1])
						if(len(cross_points_2D[index][0]) == 1)
							//cross on same segment
							index
				]
					;
					

						



	function get_round_trip_array_index(index, array) =
						index >= len(array) ? 
							index - len(array)
							: (index >= 0 ?
									index
									: len(array) + 	index
								)	
							;
					
						
	function calc_total_array_elements_nxn(index, array_points_nxn, sum)	=
			index > (len(array_points_nxn)-1) ?
				//break recursion
				sum
			:
				calc_total_array_elements_nxn(index+1, array_points_nxn, sum + len(array_points_nxn[index]))
		;		
						
	function quicksort(arr) =
  (len(arr)==0) ? [] :
      let(  pivot   = arr[floor(len(arr)/2)][3],
            lesser  = [ for (y = arr) if (y[3]  < pivot) y ],
            equal   = [ for (y = arr) if (y[3] == pivot) y ],
            greater = [ for (y = arr) if (y[3]  > pivot) y ]
      )
      concat( quicksort(lesser), equal, quicksort(greater) ); 

						
	function invert_minor_major(array_of_3D_vectors) =
			[
				for(index = [0:1:len(array_of_3D_vectors)-1])
					index < n_center_points() || index > len(array_of_3D_vectors) -1 - n_center_points() ?
						array_of_3D_vectors[index]
					: index % n_points_per_edge() == 0 ?
							array_of_3D_vectors[index+1]
						:
							array_of_3D_vectors[index-1]
			];
				
	function invert_order(array) =
			[
				for(index = [len(array)-1:-1:0])
					array[index]
			];
	function invert_z(array_of_3D_vectors) =
			[
				for(vec = array_of_3D_vectors)
					[vec.x, vec.y, -1*vec.z]
			];

	/*
	//DEBUG
	p_tol_index = 11;
	echo("points tolerance", get_3Dvec_tooths_polygon(p_tol_index));
	echo("po new tolerance", orientate_length_points_for_tolerance(tol, get_3Dvec_tooths_polygon(p_tol_index)));
	echo("po diff", arrayDiff(get_3Dvec_tooths_polygon(p_tol_index),orientate_length_points_for_tolerance(tol, get_3Dvec_tooths_polygon(p_tol_index))));
	*/
				
	function get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index, tol) = 
							let(tooths_polygon = get_3Dvec_tooths_polygon(seg_plane_index)		
									)
									orientate_all_points_for_rotation(seg_plane_index,  
											orientate_profile_tooths_for_taper(
												orientate_all_points_in_z(seg_plane_index,
													orientate_length_points_for_tolerance(tol, 
													tooths_polygon
													) //orientate_all_points_in_z
												) //orientate_all_points_in_z
											)// taper
									)// orientate_all_points_for_rotation
						;
						
	function orientate_length_points_for_tolerance(tol, tooths_polygon) = [
							for( point = tooths_polygon)
								(point.z < top_z()-tol || point.z > top_z()+tol) ? point : [point.x, point.y, top_z()]//length+tol]  
							];
							
	function orientate_all_points_for_rotation(seg_plane_index, tooths_polygon ) = [
								for( point = tooths_polygon)
									rotate_xy(rotation_angle_synced(seg_plane_index), point )
								];
								
	function orientate_all_points_in_z(seg_plane_index,tooths_polygon ) = 
								!is_channel_thread  ?
								[
									for (point_index = [0:1:len(tooths_polygon)-1] ) 
										is_center_point(point_index, tooths_polygon) ? 
											(//because we want a thread ending at zero or length
											point_index <= n_center_points() ?
												[tooths_polygon[point_index].x,  tooths_polygon[point_index].y, bottom_z()] //Bottom center points
											:
												[tooths_polygon[point_index].x,  tooths_polygon[point_index].y, top_z()] //Top center points
											)
										:
											(z_offset_v3(get_segment_zOffset(seg_plane_index) - thread_height_below_zero() //Tooth points
															, tooths_polygon[point_index] )
											)
								]
								:
								[
									for (point_index = [0:1:len(tooths_polygon)-1] ) 
										is_center_point(point_index, tooths_polygon) && (point_index > n_center_points()) ? 
											//Top center points to zero
											[tooths_polygon[point_index].x,  tooths_polygon[point_index].y, top_z()] 
										:
											z_offset_v3(get_segment_zOffset(seg_plane_index) - thread_height_below_zero() 
															, tooths_polygon[point_index] )
										
								]									
								;

	function orientate_profile_tooths_for_taper(tooths_polygon) =
		(!is_channel_thread ?
			// 1 : For standard threads shrink profile to get a tapered thread.
			[ for (point_index = [0:1:len(tooths_polygon)-1] ) 
					(is_center_point(point_index, tooths_polygon) ? 
						tooths_polygon[point_index]  //do not taper center points
						:
						((point_index - n_center_points() % n_points_per_edge()) == 0 ?
							taper(tooths_polygon[point_index])
							: tooths_polygon[point_index] //do not taper secondary helper point of profile
						)
					)
			]
		:
			// Channel thread
			tooths_polygon
		)
		;			

	function arrayDiff(array1,array2) = [
		for (index = [0:1:len(array1)-1] )
			[array1[index].x-array2[index].x,array1[index].y-array2[index].y,array1[index].z-array2[index].z]
		];
		
	function array_replace_at(index, array, replacement) =
					concat(
					//first part
					[
					for(first_index = [0:1: index-1])
						array[first_index]
					]
					,
					//replacement part
					replacement
					,
					//end part
					[
					for(last_index = [index+len(replacement):1: len(array)-1])
						array[last_index]
					]
				);
					
	function matrix_3x3_determinant(matrix) = 
		  	A[0][0]*(A[1][1]*A[2][2]-A[2][1]*A[1][2])
     		-A[0][1]*(A[1][0]*A[2][2]-A[1][2]*A[2][0])
      	+A[0][2]*(A[1][0]*A[2][1]-A[1][1]*A[2][0]);
			
	function matrix_3x3_transposed_inversed(A) =
		//http://stackoverflow.com/a/984286
		let(invdet = 1/matrix_3x3_determinant(A)
				)
		[
			[
				(A[1][1]*A[2][2]-A[2][1]*A[1][2])*invdet //result(0,0)
			 -(A[1][0]*A[2][2]-A[1][2]*A[2][0])*invdet //result(0,1)
				(A[1][0]*A[2][1]-A[2][0]*A[1][1])*invdet //result(0,2)
			],[                                        
			 -(A[0][1]*A[2][2]-A[0][2]*A[2][1])*invdet //result(1,0)
			  (A[0][0]*A[2][2]-A[0][2]*A[2][0])*invdet //result(1,1)
			 -(A[0][0]*A[2][1]-A[2][0]*A[0][1])*invdet //result(1,2)
			 ],[                                       
			  (A[0][1]*A[1][2]-A[0][2]*A[1][1])*invdet //result(2,0)
			 -(A[0][0]*A[1][2]-A[1][0]*A[0][2])*invdet //result(2,1)
			  (A[0][0]*A[1][1]-A[1][0]*A[0][1])*invdet //result(2,2)
			]
		];		
		
	function matrix_3x3_inversed(A) =
		//http://stackoverflow.com/a/18504573
		//https://en.wikipedia.org/wiki/Invertible_matrix
		let(invdet = 1/matrix_3x3_determinant(A)
				)
		[
			[
				(A[1][1]*A[2][2]-A[2][1]*A[1][2])*invdet //minv(0, 0)
			 -(A[0][2]*A[2][1]-A[0][1]*A[2][2])*invdet //minv(0, 1)
				(A[0][1]*A[1][2]-A[0][2]*A[1][1])*invdet //minv(0, 2)
			],[                                        
			 -(A[1][2]*A[2][0]-A[1][0]*A[2][2])*invdet //minv(1, 0)
			  (A[0][0]*A[2][2]-A[0][2]*A[2][0])*invdet //minv(1, 1)
			 -(A[1][0]*A[0][2]-A[0][0]*A[1][2])*invdet //minv(1, 2)
			 ],[                                       
			  (A[1][0]*A[2][1]-A[2][0]*A[1][1])*invdet //minv(2,0)
			 -(A[2][0]*A[0][1]-A[0][0]*A[2][1])*invdet //minv(2,1)
			  (A[0][0]*A[1][1]-A[1][0]*A[0][1])*invdet //minv(2,2)
				]
		];

	function zero_cross_x2(point_below, point_above, cross_z) =
		let(x_distance = abs(point_below.x - point_above.x),
				z_distance = abs(point_above.z-point_below.z),
				x_sign = point_below.x > point_above.x ? 1 : -1
				)	
				x_distance == 0 ? point_below.x : 
					point_above.x + x_sign*(x_distance/z_distance)*(point_above.z-cross_z); //congruence helps
	
	
	function orientate_thread_points_at_z(z, is_for_top, is_inverted, current_seg_plane_index, current_seg_points, 
																				previous_seg_plane_index, previous_seg_points) =
		//For threads with steep slopes (for example with many starts) the "next" point
		//of the second polygon of a face set may be above top_z() (length or z=0) or below zero.
		let(firstpoint_index = is_for_top ? n_center_points() //start at first point
														: //For inverse arrays the points are called in reverse order (88,87,86,85).
														  //So we must end at second point to have a valid P2
															n_center_points() + n_points_per_edge(),
				lastpoint_index = is_for_top ? 
														//end at second last point to have a valid P2
														len(current_seg_points)-n_center_points() // points to second top center point
																		-n_points_per_edge() //points to last point
																		-n_points_per_edge() //points to second last point
													: //For inverse array we can start at last point
														len(current_seg_points)-n_center_points() // points to second top center point
																		-n_points_per_edge() //points to last point
				)//end let
		//Result
		[
		for(point =
			recursive_cross_point_calculation(z, is_for_top, is_for_top ? 1 : -1, is_inverted, 
						is_for_top ? 0 : len(current_seg_points)-1, 
						firstpoint_index, 
						lastpoint_index-0, is_for_top ? len(current_seg_points)-1 : 0,
						current_seg_points, current_seg_plane_index,
						previous_seg_points, previous_seg_plane_index))
			point
		]
		;
			
	function recursive_cross_point_calculation(z, is_for_top, inversion_index_sign, is_inverted, 
										point_index, firstpoint_index, lastpoint_index, maxpoint_index,
										current_seg_points, current_seg_plane_index,
										previous_seg_points, previous_seg_plane_index) =
				// inversion_index_sign:
				//	The algorithm in function orientate_thread_points_of_faceset_for_below_z() expects the z values increase from bottom to top.
				//	Therefore, it expects Current_P1 is always at lower or the same height as Current_P2 and Next_P1 is always at lower
				//	or the same height as Next_P2.
				//	If the thread is inverted (z-axis, is_for_top = false) then points with higher indexes have a lower z value. The indexes of the points
				//	at the bottom of the inverted object are higher than the indexes at top. But the order of the points inside the array is the same. 
				//	Also, for inverted arrays, this recursive function is being called first with high indexes then going to lower to imitate
				//	the behaviour as for non inverted arrays of "crawling up".
				//	So, to let orientate_thread_points_of_faceset_for_below_z work properly we must subtract to get the correct minor/next point.
				
					is_for_top && point_index >= maxpoint_index //top calculation ends at len
					|| !is_for_top && point_index <= maxpoint_index	? //bottom calculation ends at zero
						 current_seg_points //break recursion
					:
					let(z_check_not_needed = point_index < firstpoint_index 
													|| point_index >	lastpoint_index
													|| (is_inverted && 
															//ignore points on top for inverted threads, there are no previous points.
															(is_first_plane_of_horiz_start(current_seg_plane_index) && point_index > len(current_seg_points)
																																																				- n_center_points() //at second last center point 
																																																				- n_points_per_edge() //at last major point
																																																				- n_points_per_start()
																																																				))
													|| false && (is_for_top  ?
																is_inverted ? false :
																//ignore points on bottom for non-inverted threads, there are no previous points.
																(is_first_plane_of_horiz_start(current_seg_plane_index) && point_index < (n_points_per_start() + n_center_points()))
															: //Bottom case:
																//The thread is inverted. Therefore also the z-values are inverted. Lower indexes ar at top.
																// ==> The same code as for "top"
																//For inverse arrays we go through 7,6,5..2,1,0 segement indexes and
																//through 6,5,4,...1,0,7 previous segment indexes.
																//Also, for inverse arrays we go through 99,98,97,...0 point indexes.
																(is_first_plane_of_horiz_start(current_seg_plane_index) && point_index < (n_points_per_start() + n_center_points()))
																//(is_first_plane_of_horiz_start(current_seg_plane_index) && point_index > len(current_seg_points)-1-n_center_points()-n_points_per_start()-10)
															)
						)
						z_check_not_needed ?
							//Ignore center points, top last points and first seg_plane on first turn (these points have no previous).
							//Continue working with unchanged "current_seg_points" one index higher.
							recursive_cross_point_calculation(z, is_for_top, inversion_index_sign, is_inverted, 
												point_index+1*inversion_index_sign, firstpoint_index, lastpoint_index, maxpoint_index,
												current_seg_points, current_seg_plane_index,
												previous_seg_points, previous_seg_plane_index)
						:
							// TODO:
							// For the function's orientate_thread_points_of_faceset_for_below_z() cases to work, the condition exists that previous points are below current.
							// This is the case for right and left handed threads for top. With left handed threads, the segements come in the inverse order.
							// For "top" the function orientate_thread_points_of_faceset_for_below_z() returns its "next" or here the "current" as modified points.
							/*TODO:  For "bottom"	this is not true, the indexes must be exchanged.
							        Retry the negative mirroring. With an Inverse (z) thread we havethe situation, that the segment ordering is in wrong order.
											Maybe we also need to go through the indexes in reverse order and reverse the result segement arrays also as result.
							*/
							let(previous_index = point_index + (is_for_top ? 
																										is_inverted ?
																												//+n_points_per_start()
																											is_first_plane_of_horiz_start(current_seg_plane_index) ?
																												//0 
																											-n_points_per_start()+0
																												//get_point_index_offset_previous(previous_seg_plane_index)
																												: 0
																										 // get_point_index_offset_previous(previous_seg_plane_index) +0
																										 : 
																										 get_point_index_offset_previous(previous_seg_plane_index) +0
																									: //Bottom case:
																										//The thread is inverted. Therefore also the z-values of the points are inverted. Lower indexes ar at top.
																										//==> So, the offset must be subtracted too
																										//For inverse arrays we go through 7,6,5..2,1,0 segement indexes and
																										//through 6,5,4,...1,0,7 previous segment indexes.
																										//Also, for inverse arrays we go through 99,98,97,...0 point indexes.
																										//When previous_seg_plane_index is 7 then the point index may be 99
																										//whose z-values are at bottom of thread. But the "0" segment has more points
																										//because it must reach from bottom to top. So, the z-values of segement "0" at point index 99
																										//are well above(for the inverse array) of the z-values of "previous". So we have to subtract n_starts()*n_points_per_tooth()
																										//to get the points with the correct z values.
																										//
																										get_point_index_offset_previous(previous_seg_plane_index)-0
																									),
									inverted_index = point_index + 
																		(
																		is_inverted ? 
																				is_first_plane_of_horiz_start(current_seg_plane_index) ?  0 : 0 // - n_points_per_start() 
																		:
																			0
																		)	
																		,
									changed_points = is_for_top ?
																			orientate_thread_points_of_faceset_for_below_z(z, is_for_top,
																				previous_seg_points[previous_index], previous_seg_points[previous_index+1*inversion_index_sign], 
																				previous_seg_points[previous_index+n_points_per_edge()*inversion_index_sign], previous_seg_points[previous_index+(n_points_per_edge()+1)*inversion_index_sign],
																				current_seg_points[inverted_index], current_seg_points[inverted_index+1*inversion_index_sign],
																				current_seg_points[inverted_index+n_points_per_edge()*inversion_index_sign], current_seg_points[inverted_index+(n_points_per_edge()+1)*inversion_index_sign]
																			)
																		:
																			orientate_thread_points_of_faceset_for_below_z(z, is_for_top,
																				previous_seg_points[previous_index], previous_seg_points[previous_index+1], 
																				previous_seg_points[previous_index-n_points_per_edge()], previous_seg_points[previous_index-1],
																				current_seg_points[point_index], current_seg_points[point_index+1],
																				current_seg_points[point_index-n_points_per_edge()], current_seg_points[point_index-n_points_per_edge()+1]
																			)
																	,
									//The function orientate_thread_points_of_faceset_for_below_z() returns 
									//[returnvalue, [current_p1, current_P1_minor, current_P2, current_P2_minor]].
									//For inverted arrays we call orientate_thread_points_of_faceset_for_below_z() with indexes 
									//like [80,79,78,77] and also get this order back.
									//But the order of the points in the array is the same for inverted arrays. So the result's 
									//order must be inverted and inserted at index 77.
								  //The next call to recursive_cross_point_calculation() has the point_index set to 78 (minus n_points_per_edge).	
									seg_points = is_for_top ?
																	is_inverted ?
																		is_first_plane_of_horiz_start(current_seg_plane_index) ?
																			array_replace_at(point_index, current_seg_points, changed_points[1])
																		:
																			array_replace_at(point_index, current_seg_points, changed_points[1])
																	: array_replace_at(point_index, current_seg_points, changed_points[1])
															: //For inverse arrays we input into recursive function
																// [P(index), P(index+1), P(index-2), P(index-1) ]
																// and must store back 
																// [P(index-2), P(index-1), P(index), P(index+1) ]
																array_replace_at(point_index-n_points_per_edge(), current_seg_points, [changed_points[1][2],changed_points[1][3],changed_points[1][0],changed_points[1][1]])
								)
									recursive_cross_point_calculation(z, is_for_top, inversion_index_sign, is_inverted, 
														point_index+n_points_per_edge()*inversion_index_sign, firstpoint_index, lastpoint_index, maxpoint_index,
														seg_points, current_seg_plane_index,
														previous_seg_points, previous_seg_plane_index)
				;


	//DEBUG			
	show_all_facets = false;  //must be in code, do not comment
	/*
	show_z_plane_cyl = false;
	if(show_z_plane_cyl) 
		translate([0,0,length])cylinder(d=2*major_rad+1,h=0.01);
	*/
	
	function orientate_thread_points_of_faceset_for_below_z(z, is_for_top,
																														current_seg_p1, current_seg_p1_minor, 
																														current_seg_p2, current_seg_p2_minor,
																														next_seg_p1, next_seg_p1_minor,
																														next_seg_p2, next_seg_p2_minor) =
		//For threads with steep slopes (for example with many starts) the "next" point
		//of the second polygon of a face set may be above top_z() which is for std threads "length", for channel threads zero.
		//Lower polygon = [current_seg_p1, current_seg_p2, next_seg_p1]
		//Higher polygon = [current_seg_p2, next_seg_p1, next_seg_p2]
		//Since for left handed threads the current/next direction of the segments alternates there is no need
		//to check "right_handed" value because the "next" points are higher for both cases.
		//
		//The initial "design" was coded to calculate the points on z="top" of the thread where the thread reaches its length.
		//To get a flat plane at length, some points above length will be moved down to length thus distorting the thread above.
		//
		//When calling for "top", then "current" is "previous" and "next" is the input (current seg) and will "next" will be returned.
		//When calling for "bootom", then "current" is the input (current seg) and will be returned meanwhile "next" is "next".
		//This is because for "top" we have to change/return the "next" points while for "bottom" we must change/return "current".
		//
		let(//unchanged = [current_seg_p1, current_seg_p2, next_seg_p1, next_seg_p2]
				unchanged = [0,[next_seg_p1, next_seg_p1_minor, next_seg_p2, next_seg_p2_minor]],
				not_done = unchanged,
				current_p1_above_z = current_seg_p1.z > z,
				current_p1_at_z = current_seg_p1.z == z,
				current_p1_below_z = current_seg_p1.z < z,
				current_p2_above_z = current_seg_p2.z > z,
				current_p2_at_z = current_seg_p2.z == z,
				current_p2_below_z = current_seg_p2.z < z,
				next_p1_above_z = next_seg_p1.z > z,
				next_p1_at_z = next_seg_p1.z == z,
				next_p1_below_z = next_seg_p1.z < z,
				next_p2_above_z = next_seg_p2.z > z,
				next_p2_at_z = next_seg_p2.z == z,
				next_p2_below_z = next_seg_p2.z < z,
				cross_point1 = z_cross_of_line(current_seg_p1, next_seg_p1, z),
				cross_point2 = z_cross_of_line(current_seg_p2, next_seg_p2, z),
				cross_point_next1_next2 = z_cross_of_line(next_seg_p1, next_seg_p2, z),
				c2=next_seg_p2+[0,0,-0.1],
				changed = [0,[next_seg_p1, next_seg_p1_minor, c2, next_seg_p2_minor]]
				)
		current_p1_above_z ?
			//*************************
			// A
			// If current p1 is above z, then all others are above z too and should not be changed
			// The face polygons will be ignored.
			unchanged 
		: current_p1_at_z ?
			//*************************
			// B
			// Current P1 is exactly at z.
				current_p2_above_z ?
					//*****************************
					// B1
					// Current P1 is at z. 
					// Current P2 is above z.
					// For Top: 
					// ==> The upper polygon is not needed.
					// Next P1 is higher as Current P1 ==> Next P1 is above z
					// ==> The lower polygon is not needed too.
					unchanged
				:
					//*****************************
					// B2
					// Current P1 is at z.
					// Current P2 is at z.
					// ==> because Next points are higher, no polygons are needed.
					unchanged
			:
				//*************************
				// C
				// Current P1 is below z.
					current_p2_above_z 
						//*************************
						// C1 ==C2
						// Current P1 is below z.
						// Current P2 is above z.
						// ==> Since "current" is "previous" for the calling loop, this case will be corrected as soon
						//     the previous plane will be corrected when it is "current/next". Then P2 will be "Next P2"
						//     and lowered to z. So we behave here as if :
						//     Current P1 is below z.
						//     Current P2 is at z (Assuming).
					||
					current_p2_at_z ?
						//*************************
						// C2 = C1
						// Current P1 is below z.
						// Current P2 is at z.
						// ==> Both polygons may be needed.
						next_p1_above_z ?
							//*************************
							// C2_1 = C1_1
							// Current P1 is below z.
							// Current P2 is at z.
							// Next P1 is above z
							// ==> Next P2 is above z too
							// ==> We need only the lower polygon, so we lower Next P1.
							//unchanged
							[2,[cross_point1, calc_minor(cross_point1), next_seg_p2, next_seg_p2_minor]]
						:							
							next_p1_at_z ?
								//*************************
								// C2_2
								// Current P1 is below z.
								// Current P2 is at z.
								// Next P1 is at z
								// ==> Next P2 cannot be below z
								next_p2_above_z ?
									//*************************
									// C2_2_1
									// Current P1 is below z.
									// Current P2 is at z.
									// Next P1 is at z
									// Next P2 is above z
									// ==> We need only the lower polygon. A correction is not needed, because Next P1 is already at z
									unchanged
								:
									//*************************
									// C2_2_2
									// Current P1 is below z.
									// Current P2 is at z.
									// Next P1 is at z
									// Next P2 is at z
									// ==> The lower polygon is needed.
									// ==> The higher polygon is flat at z (all corners). We do not change the values. The decision to draw it or not 
									//     will be decided by facet generator.
									unchanged
							:
								//*************************
								// C2_3
								// Current P1 is below z.
								// Current P2 is at z.
								// Next P1 is below z.
								// ==> Next P2 undefined
								next_p2_above_z ?
									//*************************
									// C2_3_1
									// Current P1 is below z.
									// Current P2 is at z.
									// Next P1 is below z.
									// Next P2 is above z.
									// ==> The lower polygon will be drawn without change.
									// ==> The higher polygon is needed too because next p1 is below not at z. So we need to fill up to z.
									//unchanged
									[1,[next_seg_p1, next_seg_p1_minor, cross_point_next1_next2, calc_minor(cross_point_next1_next2)]]
								: 
									next_p2_at_z ?
										//*************************
										// C2_3_2
										// Current P1 is below z.
										// Current P2 is at z.
										// Next P1 is below z.
										// Next P2 is at z.
										// ==> The lower and higher polygon will be drawn without change.
										unchanged
									:
										//*************************
										// C2_3_3
										// Current P1 is below z.
										// Current P2 is at z.
										// Next P1 is below z.
										// Next P2 is below z.	
										// ==> Both polygons needed. Since no values above z, no change is needed.
										unchanged
					:
						//*************************
						// C3
						// Current P1 is below z.
						// Current P2 is below z.
						// ==> Both polygons may be needed.
						next_p1_above_z ?
							//*************************
							// C3_1
							// Current P1 is below z.
							// Current P2 is below z.
							// Next P1 is above z
							// ==> Next P2 is above z too
							// ==> Both polygons needed, both points must be changed.
							//unchanged
							is_for_top ?
								[2,[cross_point1, calc_minor(cross_point1), cross_point2, calc_minor(cross_point2)]]
								:
								[2,[cross_point1, calc_minor(cross_point1), cross_point2, calc_minor(cross_point2)]]
						:							
							next_p1_at_z ?
								//*************************
								// C3_2
								// Current P1 is below z.
								// Current P2 is below z.
								// Next P1 is at z
								// ==> Next P2 cannot be below z
								next_p2_above_z ?
									//*************************
									// C3_2_1
									// Current P1 is below z.
									// Current P2 is below z.
									// Next P1 is at z
									// Next P2 is above z
									// For Top: 
									// ==> Both polygons needed, only one point must be changed
									//unchanged
									[1,[next_seg_p1, next_seg_p1_minor, cross_point2, calc_minor(cross_point2)]]
								:
									//*************************
									// C3_2_2
									// Current P1 is below z.
									// Current P2 is below z.
									// Next P1 is at z
									// Next P2 is at z
									// ==> Both polygons are needed. Points must not be changed. 
									unchanged
							:
								//*************************
								// C3_3
								// Current P1 is below z.
								// Current P2 is below z.
								// Next P1 is below z.
								// ==> Next P2 undefined
								next_p2_above_z ?
									//*************************
									// C3_3_1
									// Current P1 is below z.
									// Current P2 is below z.
									// Next P1 is below z.
									// Next P2 is above z.
									// ==> First polygon must not be changed because Next P1 is below z.
									// ==> Second polygon is needed, because Current P2 is below z so we have to correct Next P2.
									//unchanged
									//changed
									[1,[next_seg_p1, next_seg_p1_minor, cross_point2, calc_minor(cross_point2)]]
								: 
									next_p2_at_z ?
										//*************************
										// C3_3_2
										// Current P1 is below z.
										// Current P2 is below z.
										// Next P1 is below z.
										// Next P2 is at z.
										// ==> Everything in range. Two polygons, no change
										unchanged
									:
										//*************************
										// C3_3_3
										// Current P1 is below z.
										// Current P2 is below z.
										// Next P1 is below z.
										// Next P2 is below z.
										// ==> Std case for facets below z. Return them unchanged.
										unchanged				
		;

		function z_cross_of_line(p1, p2, z_target) =
			//Generally : Because both points are at or over minor_radius, the z-corrected value is also at or over minor_radius.
			//But, if both points ar at minor radius, then, due to the nature of a round cylinder, the new point may be smaller than minor radius.
			//This is not solvable in an exact manner. Some walls of the thread will always be smaller than minor_rad.
			//Old: Since this function is being used to calculate the start or end of the thread the corners must be at minor_rad. Thus
			//     we expand the points outwards if needed.
			//New: The new concept with the seperate cross point collection/loop instead of moving existing thread faces points
			//     enables smaller radiusses because top and bottom factes will be drawn directly to hollow_rad. The result
			//     is a more accurate outer form of the thread given from the n segments.
			//
			let (//Cross point calculation
						p1_p2 = p2-p1, //Richtungsvektor
						t = (z_target-p1.z)/p1_p2.z, //3 Equations from x_vec = p1_vec + t*p1_p2
						x_t = p1.x + t*p1_p2.x,
						y_t = p1.y + t*p1_p2.y,
						//length correction
						rad = sqrt(pow(x_t,2)+pow(y_t,2)),
						rad_min = get_3Dvec_profile_xOffset_minor(),
						corr_needed = rad < rad_min-tol,
						corr = corr_needed ? 1:1,//New: corr_needed ? 1:1, Old: corr_needed ? rad_min/rad : 1, //correct only smaller distances
						x_t_corr = corr_needed ? x_t * corr : x_t,
						//To minimize rounding errors we use corr only once to get exact minor_radius.
						y_t_sign = y_t >= 0 ? 1 : -1,
						y_t_corr = corr_needed ? y_t * corr : y_t, //sqrt(pow(rad_min,2)-pow(x_t_corr,2)) * y_t_sign,
						new_rad_square = pow(x_t_corr,2) + pow(y_t_corr,2),
						new_rad = sqrt(new_rad_square),
						minor_rad_square = pow(rad_min,2),
						is_minor = (new_rad == rad_min),
						is_in_minor_tol = !is_minor && (new_rad <= rad_min + tol) && (new_rad >= rad_min - tol)
					)
					//[x_t_corr,y_t_corr,z_target]
					is_minor && !is_in_minor_tol ? 
						//Outside of minor tolerance or exactly minor, just return value
						[x_t_corr, y_t_corr, z_target]
					:
						[x_t_corr, y_t_corr, z_target]
					//
					//p2
					//[p2.x,p2.y,p2.z]
					//p1_p2
					;

	function calc_minor(point) =
		let(rad = sqrt(pow(point.x,2)+pow(point.y,2)),
				rad_min = get_3Dvec_profile_xOffset_minor(),
				tolerance = 2*tol,
				is_minor = (rad <= rad_min + tolerance) && (rad >= rad_min - tolerance),
				mul = rad == 0 ? 1 : rad_min/rad	)
			is_minor ?
					point //for later comparisons they should be the same
				:
					[point.x*mul, point.y*mul, point.z];
	
	function calc_xy_radius(point_3D)=
		sqrt(pow(point_3D.x,2)+pow(point_3D.y,2));
	
	// ----------------------------------------------------------------------------
	// TODO : polyhedron axial orientation
	// ------------------------------------------------------------------
	//Correction angle so at x=0 is left_flat/angle
	//Not needed so far. Two problems:
	//Internal and external threads have different lower_flats and therefore
	//a different turn angle. ==> no nice thread differences.
	//With parameter "exact_clearance" a problem occurs. 
	function poly_rot_slice_offset() =
			((is_channel_thread ? 0 : 1)
			 *(right_handed?1:-1)
			 *(360/n_starts/pitch* (lower_flat/2)));


			 
	function rotation_angle(seg_plane_index) = 
							right_handed ? 
								(360/n_segments * seg_plane_index)
								: 360 - (360/n_segments * seg_plane_index) ;
	function rotation_angle_synced(seg_plane_index) = 	
							(rotation_angle(seg_plane_index) >= 359.99 ? 
								0 : rotation_angle(seg_plane_index));				
	function rotation_angle_adj(seg_plane_index) = 	
							(rotation_angle(seg_plane_index) >= 359.99 ?
								360 : rotation_angle(seg_plane_index));
							
	function get_segment_zOffset(seg_plane_index) =
				// Get z increase according to seg plane angle(seg_plane_index)
				// The points in the seg_plane collection have already z positions
				// according to tooth raster height. But they all start at z = 0.
				// They (except the one at horiz_start sync) must be lifted to 
				// overcome pitch.

				//1) increase z according to vertical/horizontal starts (twist)
				(right_handed ?
					get_starts_segment_zOffset(seg_plane_index)
					:  0*pitch+get_starts_segment_zOffset(seg_plane_index)
				)
				//2) decrease (reset to zero) for every horizontal start
				- get_horiz_starts_segment_zOffset(seg_plane_index)
				;

	function get_starts_segment_zOffset(seg_plane_index) =
							pitch/n_segments 
								* seg_plane_index //step up once per segment plane and start
								* n_vert_starts //overcome vertical starts
								* n_horiz_starts //also steeper for horiz starts
								;

	function get_horiz_starts_segment_zOffset(seg_plane_index) =
							pitch/n_segments 
							 * floor(seg_plane_index/horiz_raster())
							 * horiz_raster()
							 * n_vert_starts 
							 * n_horiz_starts
							 *1
							;
	function get_seg_to_horiz_starts_sync_seg(seg_plane_index) =
							sync_raster() *	floor((seg_plane_index) / sync_raster());
	function sync_raster() = n_segments/n_horiz_starts;
	



					
	function horiz_raster() = n_segments/n_horiz_starts;
	
	function taper(point) =
					// replaces current_minor_rad() current_major_rad() functions.
					// - Each point should be tapared
					// - Taper should be a function of length (z) 
					//   resulting in tapered thread tooth tips.
					// - it must be ensured that the diameter at the resulting
					//   thread top is correct because the thread created 
					//   is too long and will be later cut to length.
					taper_angle == 0 ? point //no taper needed
					:	point.z == length ? point //start point, no taper
						:	scale_xy(point, get_scale(major_radius, get_taper_at_z(point)))
					;
					
					
	function get_taper_at_z(point) = accurateTan(taper_angle)*(point.z-length);

		
	// -------------------------------------------------------------
	//Create points for polyhedron ==> flatten pre_calc_seg_plane_polygons 
	/*
	-1.27875e-016
	
	-2.55751e-016
	
	-2.23201e-015
	
	-4.47564e-016
	5.57739e-015
	9.29792e-016
	-3.34725e-015
	-1.97599e-014
	3.96339e-017
	*/
	

	function correct_floating_point_errors(points_3Dvec) =
			[
				for(pt = points_3Dvec)
					correct_3D_floating_point_error(0, pt)
			];
	
	function correct_3D_floating_point_error(target_value, vec_3D) =
	[correct_loating_point_error_zero(target_value, vec_3D.x),
		correct_loating_point_error_zero(target_value, vec_3D.y),
		correct_loating_point_error_zero(target_value, vec_3D.z)
	];			
				
	max_tol = 1/pow(2,40); //checked in exported STL.
	function correct_loating_point_error_zero(target_value, fuzzy_value) = 
		fuzzy_value <=  target_value + max_tol && fuzzy_value >= target_value-max_tol ? target_value : fuzzy_value;
	
				
	points_3Dvec = 
				correct_floating_point_errors(
					concat(
						[
						for(poly_gon	= pre_calc_seg_plane_point_polygons) 
							for (point = poly_gon)
								point
						],
						[
							for(cross_point_index =[0:1:len(indexed_z_top_cross_points)-1 ])
									indexed_z_top_cross_points[cross_point_index][1][2]
						],	
						[
							for(cross_point_index =[0:1:len(indexed_z_bottom_cross_points)-1 ])
									indexed_z_bottom_cross_points[cross_point_index][1][2]
						]
						)
					)
				;	
					
							
	pre_calc_faces_points = generate_all_seg_faces_points();		
							
	/* DEBUG
	// Test minor rads for their value (all should be the same).
	minor_rads = [for(plane_i = [0:1:len(pre_calc_seg_plane_point_polygons)-1])
							[
							let(points = pre_calc_seg_plane_point_polygons[plane_i])
							for(i =[ n_center_points()+1:2:len(points)-n_center_points()-1])
							[sqrt(pow(points[i].x,2)+pow(points[i].y,2))-get_3Dvec_profile_xOffset_minor()]
							]
				];
	echo("minor_rads", minor_rads);
	*/
							
	// Since this method returns the first zero cross point use it with care
	// for threads with square profiles.		
	// Does not return center points or minor points.			
	function find_first_point_index_with_z(points_3Dvec, faces_pts, z) =
		[
			for(point_index = [n_center_points():n_points_per_edge():len(faces_pts)-n_center_points()-1])
					if(points_3Dvec[faces_pts[point_index]].z == z )
						point_index
		];
					
	/*
	//DEBUG	find_first_point_index_with_z	
	testPlaneIndex = 1;		
	found_indexes = find_first_point_index_with_z(points_3Dvec, pre_calc_faces_points[testPlaneIndex],bottom_z());
	major_index = found_indexes[0];
	minor_index = found_indexes[0]+1;
	major_index_3D = pre_calc_faces_points[testPlaneIndex][major_index];
	minor_index_3D = pre_calc_faces_points[testPlaneIndex][minor_index];
						
	echo("find_first_point_index_with_z_zero", found_indexes);
	echo("major_index:", major_index);
	echo("minor_index:", minor_index);
	echo("major_index_3D:", major_index_3D);
	echo("minor_index_3D:", minor_index_3D);
	echo("first_point_index_with_z_zero", points_3Dvec[major_index_3D], points_3Dvec[minor_index_3D]);

	echo("faces", len(pre_calc_faces_points[testPlaneIndex]), pre_calc_faces_points[testPlaneIndex]);
	echo("points", [for(i=pre_calc_faces_points[testPlaneIndex]) points_3Dvec[i]]);
	*/								
			
	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// FACES
	//-----------------------------------------------------------
	//-----------------------------------------------------------

	// Generate an array of point index numbers used later for 
	// creating the faces points.
	// Its structure/length is equal to the previously created 3D points.
	// Returns always the same length for all segments of the same thread except for the first segment which starts at lowest point
	// but also includes the endpoints of the top turn
	// generate_faces_points(0) ==>  [0,1,2,...,13]  (14 points = 10points + 4 extra profile points,  just a sample)
	// generate_faces_points(1) ==>  [14,15,16,...,23] (10 points)
	// generate_faces_points(2) ==>  [24,15,16,...,33] (10 points)

	function generate_all_seg_faces_points() = 
					[ for(seg_plane_index	= [ 0:1:get_n_segment_planes()-1])
								generate_faces_points(seg_plane_index)
					];

	function generate_faces_points(seg_plane_index) = 
					[ for (fp = [seg_faces_point_offset(0,seg_plane_index,0):1
												: seg_faces_point_offset(0,seg_plane_index+1,0)-1]) 
								fp
					];
			
	function seg_faces_point_offset(start_seg_plane_index, 
																				end_seg_plane_index, 
																				current_len) =
						//for loop to count/add all lengths
						start_seg_plane_index >= end_seg_plane_index ? 
								current_len
							: seg_faces_point_offset(start_seg_plane_index+1, 
									end_seg_plane_index, 
									current_len+len_seg_plane(start_seg_plane_index))
					;
	

	function get_n_segment_planes() = 
							//DEBUG: Set to 2 to see only one segment.
							n_segments; 
					

	//-----------------------------------------------------------
	// Prepare the faces used later for polyhydron function which creates the thread.
	thread_faces = 
				concat(
				[
				// Notes:
				// Channel threads use n_starts for number 
				// of horizontal threads (n_horiz_starts).
				// For every n_start exist (n_segments/n_starts) segment planes.
				// tooth_offset: one tooth per horizontal start one per vertical start
				//               offset = n_horiz_starts*n_vert_starts
				// length: std_thread length above z=0
				//         channel thread length = below zero.
				for (seg_plane_index	= [ 0 : 1 : get_n_segment_planes()-1]) 
					let (next_seg_plane_index = get_adj_seg_plane_index(seg_plane_index+1),
							current_faces_pts = pre_calc_faces_points[seg_plane_index],
							next_faces_pts  = pre_calc_faces_points[next_seg_plane_index],
							next_point_offset = get_point_index_offset(next_seg_plane_index, false),
							top_seg_cross_points = get_seg_cross_points(seg_plane_index, indexed_z_top_cross_points),
							bottom_seg_cross_points = get_seg_cross_points(seg_plane_index, indexed_z_bottom_cross_points)	
							)
					for (a = get_seg_faces(seg_plane_index = seg_plane_index,
																next_seg_plane_index = next_seg_plane_index,
																first_faces_pts = pre_calc_faces_points[0], 
																current_faces_pts = current_faces_pts, 
																next_faces_pts = next_faces_pts,
																last_faces_pts = pre_calc_faces_points[len(pre_calc_faces_points)-1],
																next_point_offset = next_point_offset,
																i_bottom_first_seg_second_center_pt = pre_calc_faces_points[0][1]
																)
								) 
							if(len(a)>0) //suppress empty face sets, reported as "degenerated faces"
								a	//extract faces into 1-dim array
					]
				,
				//***********************************************
				// Top Thread Completion Facets
				//***********************************************
				[
				for(pts=
				[
					for(current_cp_index = [0:1:len(indexed_z_top_cross_points)-1])
						let(next_cp_index = get_round_trip_array_index(current_cp_index + 1, indexed_z_top_cross_points),
								next_next_cp_index = get_round_trip_array_index(next_cp_index + 1, indexed_z_bottom_cross_points),
								previous_cp_index = get_round_trip_array_index(next_cp_index -1, indexed_z_bottom_cross_points),
								current_cp = indexed_z_top_cross_points[current_cp_index],
								next_cp = indexed_z_top_cross_points[next_cp_index],
								next_next_cp = indexed_z_bottom_cross_points[next_next_cp_index],
								previous_cp = indexed_z_bottom_cross_points[previous_cp_index],
								current_cp_rad = calc_xy_radius(get_cp_3D(current_cp)),
								next_cp_rad = calc_xy_radius(get_cp_3D(next_cp)),
								next_next_cp_rad = calc_xy_radius(get_cp_3D(next_next_cp)),
								is_for_top_face = true,
								same_seg_current_and_next = (get_cp_current_seg_index(current_cp) == get_cp_current_seg_index(next_cp)),
								same_angle_current_to_next = (get_cp_angle(current_cp) == get_cp_angle(next_cp)),
								same_angle_next_to_nextnext = (get_cp_angle(next_cp) == get_cp_angle(next_next_cp)),
								same_angle_current_to_previous = (get_cp_angle(current_cp) == get_cp_angle(previous_cp)),
								hollow_pt_i_current = get_cp_seg_hollow_rad_pt_i_top(current_cp),
								hollow_pt_i_next = get_cp_seg_hollow_rad_pt_i_top(next_cp),
								angle_current_seg = atan360(points_3Dvec[hollow_pt_i_current].x,points_3Dvec[hollow_pt_i_current].y),
								angle_next_seg = atan360(points_3Dvec[hollow_pt_i_next].x,points_3Dvec[hollow_pt_i_next].y) 
					)
						concat(
						//1. Front completion faces up to z.
						!same_seg_current_and_next ? [] :
							//1. A) Cross points of same segment
							get_cp_first_point_index(current_cp) == get_cp_first_point_index(next_cp) ?
								//Simplest case,where both cross points have the same first point
								//same_angle_current_to_previous ? [] :
								1==2 ? [] :
								[
								uturn(right_handed, is_for_top_face,
									[get_cp_point_index(next_cp),
									get_cp_first_point_index(current_cp),
									get_cp_point_index(current_cp)])
								]
							:
								get_cp_first_point_index(current_cp)- n_points_per_edge() == get_cp_first_point_index(next_cp) ?
									[1==2 ? [] :
										uturn(right_handed, is_for_top_face,
										[get_cp_first_point_index(next_cp),
										get_cp_first_point_index(current_cp),
										get_cp_point_index(current_cp)])
									,1==2 ? [] :
										uturn(right_handed, is_for_top_face,
										[get_cp_point_index(next_cp),
										get_cp_first_point_index(next_cp),
										get_cp_point_index(current_cp)])
									]
								:
								[]
						,
							//1.B) Cross points of two segments
							same_seg_current_and_next ? [] :
								1==2 ? [] :
								same_angle_current_to_next ? [] :
								get_cp_current_seg_index(current_cp) != get_cp_current_seg_index(next_cp) ?
									[uturn(right_handed, is_for_top_face,
										[get_cp_point_index(next_cp),
										get_cp_first_point_index(current_cp),
										get_cp_point_index(current_cp)])
										
									,uturn(right_handed, is_for_top_face,
										[get_cp_first_point_index(current_cp),
										get_cp_point_index(next_cp),
										get_cp_first_point_index(next_cp)
										])
									]
								:
								[]
						) //end concat
					
						
				])//end filter for
				for(pt=pts)
					if(len(pt)>0)
						pt
				]
			,
				//***********************************************
				// Top Thread Cover Facets
				//***********************************************
				1==2 ? [] :
				[
					
					for(seg_plane_index	= [ 0 : 1: get_n_segment_planes()-1]) 
					//for (seg_plane_index	= [ 52 : 1: 52]) //get_n_segment_planes()-1]) 
						let (next_seg_plane_index = get_adj_seg_plane_index(seg_plane_index+1),
								current_faces_pts = pre_calc_faces_points[seg_plane_index],
								next_faces_pts  = pre_calc_faces_points[next_seg_plane_index]
							)
						uturn(!right_handed, false, 
						concat(
						1==2 ? [] :
							[current_faces_pts[len(current_faces_pts)-n_center_points()],
							next_faces_pts[len(next_faces_pts)-n_center_points()],
							]
						,
						1==2 ? [] :
							get_seg_cross_point_indexes(next_seg_plane_index, indexed_z_top_cross_points)[0]
						,
						1==2 ? [] :
							invert_order(get_seg_cross_point_indexes(seg_plane_index, indexed_z_top_cross_points))
						) // end concat
					) // end uturn
				]
			,
				//***********************************************
				// Bottom Thread Completion Facets
				//***********************************************
				/*
					cross_point_type_SAME_SEG_AT_Z = 1;
					cross_point_type_SAME_SEG_THROUGH_Z = 2;
					cross_point_type_TWO_SEGS_FIRST_FIRST = 3;
					cross_point_type_TWO_SEGS_FIRST_SECOND = 4;
				*/
				is_channel_thread ? [] :
				[
				for(pts=
				[
					for(current_cp_index = [0:1:len(indexed_z_bottom_cross_points)-1])
						let(next_cp_index = get_round_trip_array_index(current_cp_index + 1, indexed_z_bottom_cross_points),
								next_next_cp_index = get_round_trip_array_index(next_cp_index + 1, indexed_z_bottom_cross_points),
								current_cp = indexed_z_bottom_cross_points[current_cp_index],
								next_cp = indexed_z_bottom_cross_points[next_cp_index],
								next_next_cp = indexed_z_bottom_cross_points[next_next_cp_index],
								current_cp_rad = calc_xy_radius(get_cp_3D(current_cp)),
								next_cp_rad = calc_xy_radius(get_cp_3D(next_cp)),
								next_next_cp_rad = calc_xy_radius(get_cp_3D(next_next_cp)),
								is_for_top_face = false,
								same_seg_current_and_next = (get_cp_current_seg_index(current_cp) == get_cp_current_seg_index(next_cp)),
								same_angle_current_to_next = (get_cp_angle(current_cp) == get_cp_angle(next_cp)),
								same_angle_next_to_nextnext = (get_cp_angle(next_cp) == get_cp_angle(next_next_cp))
						)
						concat(
						// 1. Bottom fill polygons upt to facets of thread above z
								//!same_seg_current_and_next ? [] :
									//A) Cross points of same segment
									get_cp_second_point_index(current_cp) == get_cp_second_point_index(next_cp) ?
										//A 1) Simplest case,where both cross points have the same second point
										1==2 ? [] :  //10
										[
										uturn(right_handed, is_for_top_face,
											[get_cp_point_index(next_cp),
											get_cp_second_point_index(current_cp),
											get_cp_point_index(current_cp)])
										]
									:
										//TODO
										get_cp_second_point_index(current_cp)- n_points_per_edge() == get_cp_second_point_index(next_cp) 
											//&& (get_cp_angle(next_cp) == get_cp_angle(current_cp))// && current_cp_rad >= next_cp_rad)
										?
											//A 2)
											1==2 ? [] :  //22
											[uturn(right_handed, is_for_top_face,
												[get_cp_second_point_index(next_cp),
												get_cp_second_point_index(current_cp),
												get_cp_point_index(current_cp)])
											,
												uturn(right_handed, is_for_top_face,
												[get_cp_point_index(next_cp),
												get_cp_second_point_index(next_cp),
												get_cp_point_index(current_cp)])
											]
										:
										get_cp_first_point_index(current_cp) == get_cp_first_point_index(next_cp) ?
											//A 3) Both cross points have the same first point
											1==2 ? [] : //12
											[
											uturn(right_handed, is_for_top_face,
												[get_cp_point_index(next_cp),
												get_cp_second_point_index(next_cp),
												get_cp_point_index(current_cp)])
											,
											uturn(right_handed, is_for_top_face,
												[get_cp_second_point_index(next_cp),
												get_cp_second_point_index(current_cp),
												get_cp_point_index(current_cp)])
											]
										:
										//get_cp_point_index(current_cp) == get_cp_first_point_index(current_cp) ?
										1==2 ? [] : //1
										get_cp_type(current_cp) == cross_point_type_SAME_SEG_AT_Z 
											//Cross point equals first point and is at z bottom.
											//Because the cross point is at the same position as the already used facet point (exactly at z),
											//we prefer the facet point (first point)
											//&& same_angle_current_to_next
											?
											[
											uturn(right_handed, is_for_top_face,
												[get_cp_second_point_index(next_cp),
												get_cp_first_point_index(current_cp), //get_cp_second_point_index(current_cp),
												//[44444, points_3Dvec[get_cp_first_point_index(current_cp)],current_cp]
												get_cp_point_index(next_cp)
												])
											]
											:
											[]
								
						,
							same_seg_current_and_next ? [] :
							//B) Cross points of two segments
								[
								1==1 ? [] : //7
									same_angle_next_to_nextnext && next_cp_rad >= next_next_cp_rad ? 
										//Square threads: On bottom, if two cp's are at same angle the polygon from current to next must end at last same angled cp.
										// TODO: if multiple cp's are at same angle.....function needed to detect last cp at this angle
										uturn(right_handed, is_for_top_face,
											[get_cp_second_point_index(next_next_cp),
											get_cp_point_index(current_cp),
											get_cp_point_index(next_next_cp)										
											])
									:
										//get_cp_has_second_point(next_cp) ? 
										uturn(right_handed, is_for_top_face,
											[get_cp_second_point_index(next_cp),
											get_cp_point_index(current_cp),
											get_cp_point_index(next_cp)										
											])
											//:
											//[]
									]		
						) //end concat() , bottom			
						
				])//end filter for
				for(pt=pts)
					if(len(pt)>0)
						pt
				]
				,
					is_channel_thread ? 
					[
					for(pts=
					[
					//***********************************************
					// Bottom Thread Cover Facets for Channel Thread
					//***********************************************
					for (seg_plane_index	= [ 0 : 1 : get_n_segment_planes()-1]) 
						let (next_seg_plane_index = get_adj_seg_plane_index(seg_plane_index+1),
								current_faces_pts = pre_calc_faces_points[seg_plane_index],
								next_faces_pts  = pre_calc_faces_points[next_seg_plane_index],
								//next_point_offset = get_point_index_offset(next_seg_plane_index, false),
								//top_seg_cross_points = get_seg_cross_points(seg_plane_index, indexed_z_top_cross_points),
								//bottom_seg_cross_points = get_seg_cross_points(seg_plane_index, indexed_z_bottom_cross_points),
								i_bottom_center_point = 0,
								i_bottom_2nd_center_point = 1,
								i_bottom_current_first_point = i_bottom_2nd_center_point + 1,
								i_bottom_next_first_point = is_first_plane_of_horiz_start(next_seg_plane_index) ?
																							i_bottom_2nd_center_point + 1 + n_points_per_start()
																							:	i_bottom_2nd_center_point + 1,
								i_bottom_current_second_point = i_bottom_current_first_point+n_points_per_edge(),
								i_bottom_next_second_point = i_bottom_next_first_point+n_points_per_edge(),
								i_bottom_current_minor_point = get_minor_point_prefer_major_index(i_bottom_current_first_point, current_faces_pts),
								i_bottom_next_minor_point = get_minor_point_prefer_major_index(i_bottom_next_first_point, next_faces_pts)
						)
								// Bottom triangles from closing face	to hollow_rad 
						[
								1==2? [] :
								uturn(right_handed, false,
								[current_faces_pts[i_bottom_current_minor_point],
									current_faces_pts[i_bottom_2nd_center_point],
									next_faces_pts[i_bottom_next_minor_point]
								]),
								// ******  Bottom  ******
								// Bottom triangles from hollow_rad to closing face.
								1==2 ? [] :
									uturn(right_handed, false,
									[next_faces_pts[i_bottom_next_minor_point],
										current_faces_pts[i_bottom_2nd_center_point],
										next_faces_pts[i_bottom_2nd_center_point]
									])
							]
						])//end filter for
						for(pt=pts)
							if(len(pt)>0)
								pt
					]
						:
					[
					//***************************************************
					// Bottom Thread Cover Facets for Standard Threads
					//***************************************************
					for (seg_plane_index	= [ 0 : 1: get_n_segment_planes()-1]) 
							let (next_seg_plane_index = get_adj_seg_plane_index(seg_plane_index+1),
									current_faces_pts = pre_calc_faces_points[seg_plane_index],
									next_faces_pts  = pre_calc_faces_points[next_seg_plane_index]
								)
						uturn(!right_handed, false, 
							concat(
								1==2 ? [] :
									get_seg_cross_point_indexes(seg_plane_index, indexed_z_bottom_cross_points)
							,
								1==2? [] :
									get_seg_cross_point_indexes(next_seg_plane_index, indexed_z_bottom_cross_points)[0]
							,
								1==2 ? [] :
									[next_faces_pts[1],
										current_faces_pts[1]]
							) // end concat(), Bottom Thread Cover Facets
						) // end uturn
					]
				); 
	
	function get_cp_current_seg_index(cross_point)=
			cross_point[1][0][0];
	function get_cp_first_point_index(cross_point)=
			cross_point[1][1][0];
	function get_cp_has_second_point(cross_point)=
			len(cross_point[1][1])>1;	
	function get_cp_second_point_index(cross_point)=
			cross_point[1][1][1];					
	function get_cp_point_index(cross_point)=
			cross_point[0];
	function get_cp_3D(cross_point)=
			cross_point[1][2];
	function get_cp_angle(cross_point)=
			cross_point[1][3];
	function get_cp_type(cross_point)=
			cross_point[1][4];
	function get_cp_seg_hollow_rad_pt_i_bottom(cross_point) =
					cross_point[1][5][0];
	function get_cp_seg_hollow_rad_pt_i_top(cross_point) =
					cross_point[1][5][1];

	
	//echo("get_seg_cross_points(seg_index, indexed_z_top_cross_points) ", get_seg_cross_points(0, indexed_z_top_cross_points));
	function get_seg_cross_points(seg_index, indexed_cross_points) =
		[
			for(pt=indexed_cross_points)
				if(pt[1][0][0] == seg_index)
					pt					
		];
	function get_seg_cross_point_indexes(seg_index, indexed_cross_points) =
		[
			for(pt=indexed_cross_points)
				if(pt[1][0][0] == seg_index)
					get_cp_point_index(pt)			
		];
	//[[point index in final 3d Vec points], 
	//	[[current_seg,next_seg], [first_point_index, second_point_index], [cross_point_3D], angle, cross_point_type, [hollow_rad_i_bottom, hollow_rad_i_top]]
	//]
	//indexed_z_top_cross_points
	// indexed_z_bottom_cross_points						
	/*
	//DEBUG
	echo("len thread faces", len(thread_faces));
	*/

	// To draw last segment's polygons we need the first (0)
	// seg plane as "next" seg plane.
	function get_adj_seg_plane_index(seg_plane_index) =
						seg_plane_index >= get_n_segment_planes() ? 
							seg_plane_index - get_n_segment_planes()
							: (seg_plane_index >= 0 ?
									seg_plane_index
									: get_n_segment_planes() + 	seg_plane_index
								)	
							;
					
	function get_point_index_offset(seg_plane_index,
																is_current_seg_plane) =
					(is_current_seg_plane 
						|| (!is_current_seg_plane && !is_first_plane_of_horiz_start(seg_plane_index)))
					? 0 //always zero since points are lifted 
							//according to horiz_start on start point
							// seg planes and on normal seg planes
					:
					// For every horiz start we must overcome the vertical starts
					//(right_handed ? 1 : -1) *
						n_points_per_start()
					;

	function get_point_index_offset_previous(previous_seg_plane_index) =
					(!is_last_plane_of_horiz_start(previous_seg_plane_index)
						)
					? 0 //always zero since points are lifted 
							//according to horiz_start on start point
							// seg planes and on normal seg planes
					:
					// For every horiz start we must overcome the vertical starts
					// Current is first and previous is last ==> step
						-n_points_per_start()
					;				

							
	function is_first_plane_of_horiz_start(seg_plane) = 
					(seg_plane) % (horiz_raster()) == 0 ;

	function is_last_plane_of_horiz_start(seg_plane) = 
					(seg_plane+1) % (horiz_raster()) == 0 ;				
	
	function i_2nd_center_point(faces_pts)	= 
							len(faces_pts)
								-1 //array, first center point
								-1 //second center point
						;
		function i_2nd_center_point_bottom()	= 
							0		// first center point
							+ 1 //second center point
						;					
	
	//-----------------------------------------------------------
	//-----------------------------------------------------------
	
	function get_bottom_ring_faces(seg_plane_index,
															current_faces_pts,
															next_faces_pts) =
			//Create facets if lowest thread point has a diameter larger
			//than minor_rad		
			let( //first tooth point, minor
						adj_next_seg_index = get_adj_seg_plane_index(seg_plane_index+1),
						point2_index = i_2nd_center_point_bottom()
														+1 //first tooth point, minor
						,
						//first tooth point, major
						point1_index = i_2nd_center_point_bottom()
														+n_points_per_edge() //first tooth point, major
										
						,	
						//first tooth point, major					
						point4_index = i_2nd_center_point_bottom()
														+ n_points_per_edge()
														+ ((is_first_plane_of_horiz_start(adj_next_seg_index)) ? 
																		n_points_per_turn() : 0)
						,
						//first tooth point, minor
						point3_index = i_2nd_center_point_bottom()
														+1
														+ ((is_first_plane_of_horiz_start(adj_next_seg_index)) ? 
																		n_points_per_turn() : 0)
				)	
			!(norm_xy(points_3Dvec[current_faces_pts[point2_index]])
			>  norm_xy(points_3Dvec[current_faces_pts[point1_index]]))
			&& true ?
				[]	
			:
				get_ring_faces(current_faces_pts, next_faces_pts,
															false,  //is for bottom face
															point1_index, point2_index, point3_index, point4_index)
			
			
			;	
															
	function get_top_ring_faces(seg_plane_index,
															current_faces_pts,
															next_faces_pts) =
			//Create facets if highest thread point has a diameter larger
			//than minor_rad		
			let( //first tooth point, minor
						point1_index = i_2nd_center_point(current_faces_pts)
										-1 //first tooth point, minor
										- ((is_first_plane_of_horiz_start(seg_plane_index)) ? 
																		n_points_per_turn() : 0),
						//first tooth point, major
						point2_index = i_2nd_center_point(current_faces_pts)
										-n_points_per_edge() //first tooth point, major
										- ((is_first_plane_of_horiz_start(seg_plane_index)) ? 
																		n_points_per_turn() : 0),	
						//first tooth point, major					
						point3_index = i_2nd_center_point(next_faces_pts)-n_points_per_edge(),
						//first tooth point, minor
						point4_index = i_2nd_center_point(next_faces_pts)-1
						
				)	
			!(norm_xy(points_3Dvec[current_faces_pts[point2_index]])
			>  norm_xy(points_3Dvec[current_faces_pts[point1_index]]))
			&& false?
				[]	
			:
				get_ring_faces(current_faces_pts, next_faces_pts,
															true,  //is_for_top_face
															point1_index, point2_index, point3_index, point4_index)
			
			
			;										
	function get_ring_faces(current_faces_pts, next_faces_pts,
													is_for_top_face,
													point1_index, point2_index, point3_index, point4_index) =	
									[	uturn(right_handed, is_for_top_face,			
										[current_faces_pts[point1_index],
										next_faces_pts[point4_index],
										next_faces_pts[point3_index]						
										]),
									uturn(right_handed, is_for_top_face,
										[current_faces_pts[point2_index],
										current_faces_pts[point1_index],
										next_faces_pts[point3_index]						
									])
									];											
									
									
									
	function facet_polygon_is_belowOrEqual(cross_z, faces_pts_polygon) =
		points_3Dvec[faces_pts_polygon[0]].z <= cross_z 
		&& points_3Dvec[faces_pts_polygon[1]].z <= cross_z 
		&& points_3Dvec[faces_pts_polygon[2]].z <= cross_z ;

	function facet_polygon_is_aboveOrEqual(cross_z, faces_pts_polygon) =
		points_3Dvec[faces_pts_polygon[0]].z >= cross_z 
		&& points_3Dvec[faces_pts_polygon[1]].z >= cross_z 
		&& points_3Dvec[faces_pts_polygon[2]].z >= cross_z ;

	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// Get faces of one segment.
	
	function get_seg_faces(seg_plane_index, next_seg_plane_index,
									first_faces_pts, 
									current_faces_pts, 
									next_faces_pts, 
									last_faces_pts,
									next_point_offset,
									i_bottom_first_seg_second_center_pt) = 
		let(i_top_current_center_point = len(current_faces_pts)-1,
				i_top_next_center_point = len(next_faces_pts)-1,
				i_top_current_2nd_center_point = len(current_faces_pts)-1-1,
				i_top_next_2nd_center_point = len(next_faces_pts)-1-1,
				current_first_point_indexes_with_z_top = find_first_point_index_with_z(points_3Dvec, current_faces_pts, top_z()),
				next_first_point_indexes_with_z_top = find_first_point_index_with_z(points_3Dvec, next_faces_pts, top_z()))
		let(i_bottom_center_point = 0,
				i_bottom_2nd_center_point = 1,
				current_first_point_indexes_with_z_bottom = find_first_point_index_with_z(points_3Dvec, current_faces_pts, bottom_z()),
				next_first_point_indexes_with_z_bottom = find_first_point_index_with_z(points_3Dvec, next_faces_pts, bottom_z()))		
		concat(


		// ******  Tooths faces  ******

		[ for (face_set_index = [n_center_points() //start after bottom center points
														: n_points_per_edge() //step size:
																//Each point existed twice in a point
																//pair(major/minor). The most
																//important is at first position.
															: i_2nd_center_point(current_faces_pts)
																-n_points_per_edge() //first point pair
																-n_points_per_edge() //stop on point pair early
																				//because we use later "face_set_index+n_points_per_edge()"
																+0
																
																]) 
			for (face_polygon = 
			(!facets_needed(next_point_offset, 
												face_set_index, 
												current_faces_pts,
												next_faces_pts) ? [] :
				( 
					//A face_set consits of four points. They are not planar. Therefore two polygons are needed.
					//Of the first face set after z=zero only one polygon is needed to get a flat bottom at z=0 and
					//a flat top at z=length. With four points there are two possibilities to create the two polygons. 
					//The polygon variation with all polygon sides going upwards is being chosen to facilitate the cross point calculation.
					let(i_current_first_point = current_faces_pts[face_set_index],
							i_current_second_point = current_faces_pts[face_set_index+n_points_per_edge()],
							i_next_first_point = next_faces_pts[next_point_offset+face_set_index],
							i_next_second_point = 
								
								next_faces_pts[next_point_offset+face_set_index+n_points_per_edge()]
						)
					let(facet_polygons =
							[
								1==2 ? [] :
									uturn(right_handed, true,
											[i_current_first_point,
											 i_current_second_point,
											 i_next_second_point
											])
							,
								1==2 ? []:
									uturn(right_handed, true,
												[i_current_first_point,
												 i_next_second_point,
												 i_next_first_point
												])
							]
					/*
								right_handed ?
									[	//A : First polygon of face set
										1==2 ? [] :
										uturn(right_handed, true,
											[i_current_first_point,
											 i_current_second_point,
											 i_next_first_point
											])
										,
										//B : Second polygon of face set
											((points_3Dvec[i_next_first_point].z == bottom_z()
											&& points_3Dvec[i_next_second_point].z > bottom_z()
											&& points_3Dvec[i_current_second_point].z < bottom_z())
										?
											//Special polygon for steep threads at z = 0
											1==2 ? []:
											uturn(right_handed, true,
												[current_faces_pts[face_set_index+2*n_points_per_edge()],
											 	i_next_second_point,
											 	i_next_first_point
												])
										:
											(points_3Dvec[ i_next_first_point].z == top_z()
												&& points_3Dvec[i_next_second_point].z > top_z()
												&& points_3Dvec[i_current_second_point].z < top_z())
											?
												//Special polygon for steep threads at z = length
												1==1 ? [] :
												uturn(right_handed, true,
											[i_current_second_point,
											 i_next_second_point,
											 i_next_first_point
											])
											:
												//With a square thread exists a face set polygon at z=0, y=0 (thread start).
												//Also the same polygon with all points at z=0 exists if the tooth of the square thread
												//travels through z=0. The first case is not needed (plane without volume) the second polygon
												//is needed to close the tooth volume.
												//Case: square_thread(8, pitch=1.5, length=5);
												(1==1 &&
													(points_3Dvec[i_current_second_point].z == bottom_z() && points_3Dvec[i_next_second_point].z == bottom_z() && points_3Dvec[i_next_first_point].z == bottom_z()  )
													//&& (abs(points_3Dvec[i_next_second_point].x)
														//		< abs(points_3Dvec[i_next_first_point].x))
													) ? [] :
												//normal polygon , in between
												1==2 ? [] :
												uturn(right_handed, true,
													[i_current_second_point,
													 i_next_second_point,
													 i_next_first_point
													])
										)
									]
									:
									[ //A : First polygon of face set
										1==2 ? [] :
										uturn(right_handed, true,
													[i_current_first_point,
													 i_current_second_point,
													 i_next_first_point
													])
										,
										//B : Second polygon of face set
										((points_3Dvec[i_current_second_point].z == bottom_z()
											&& points_3Dvec[i_next_first_point].z == bottom_z())
											&& points_3Dvec[i_next_second_point].z > bottom_z()

										?
											//Special polygon for steep threads at z = 0
											1==2 ? [] :
											uturn(right_handed, true,
												[i_next_first_point,
											 	i_current_second_point,
											 	i_next_second_point
												])
										:
											(points_3Dvec[i_current_first_point].z == top_z()
											&& points_3Dvec[i_current_second_point].z > top_z()
											&& points_3Dvec[i_next_first_point].z < top_z())
											?
												//Special polygon for steep angles at z = length
												1==2 ? [] :
												uturn(right_handed, true,
													[i_current_first_point,
													 i_current_second_point,
													 next_faces_pts[next_point_offset+face_set_index+2*n_points_per_edge()]
													])
											:
												//With a square thread exists a face set polygon at z=0, y=0 (thread start).
												//Also the same polygon with all points at z=0 exists if the tooth of the square thread
												//travels through z=0. The first case is not needed (plane without volume) the second polygon
												//is needed to close the tooth volume.
												//Case: square_thread(8, pitch=1.5, length=5);
												(1==1 &&
													(points_3Dvec[i_current_second_point].z == bottom_z() && points_3Dvec[i_next_second_point].z == bottom_z() && points_3Dvec[i_next_first_point].z == bottom_z()  )
													&& (abs(points_3Dvec[i_next_second_point].x)
																< abs(points_3Dvec[i_next_first_point].x))
													) ? [] :
												//normal polygon , in between
												1==2 ? [] :
												uturn(right_handed, true,
													[i_next_second_point,
													 i_next_first_point,
													 i_current_second_point
													])
										)
										
									]
							*/
							)
					[
						for(facet_polygon = facet_polygons )
							is_channel_thread ?
								1==2 ? [] :
									(show_all_facets 
										|| facet_polygon_is_belowOrEqual(top_z(), facet_polygon)) ? facet_polygon : []
							:
								false 
								|| show_all_facets 
								|| (facet_polygon_is_aboveOrEqual(bottom_z(), facet_polygon)
										&& (facet_polygon_is_belowOrEqual(top_z(), facet_polygon)
												&& //ignore flat facet ont top without volume above
													//Test Case 4 (square thread)
														!(all_points_at_z(facet_polygon, top_z()) 
														&&  (//	(right_handed ?
																	!points_3Dvec[next_faces_pts[i_next_second_point]].z < top_z()		//Volume above facet exists
																//: !points_3Dvec[current_faces_pts[i_next_second_point]].z < top_z()	
																)
														)
												)
										)
								?
									false ? [] :
									facet_polygon 
								: []

					]
				)
			)

			) //end for face set index loop (flatten)
			face_polygon
		]
	
	,
	[ //Define indexes of current_faces_pts/next_faces_pts 

		let(i_top_current_last_point = is_channel_thread ? current_first_point_indexes_with_z_top[len(current_first_point_indexes_with_z_top)-1]//i_top_current_2nd_center_point - 1
					: //current_first_point_indexes_with_z_top[0],
						//Take the last point (if more than one) because for square threads the second last point can also be at z=top_z().
						current_first_point_indexes_with_z_top[len(current_first_point_indexes_with_z_top)-1],
				i_top_next_last_point = is_channel_thread ? next_first_point_indexes_with_z_top[len(next_first_point_indexes_with_z_top)-1]//i_top_next_2nd_center_point - 1
					: //next_first_point_indexes_with_z_top[0]
						next_first_point_indexes_with_z_top[len(next_first_point_indexes_with_z_top)-1]
				)
		let(i_top_current_second_last_point = i_top_current_last_point-n_points_per_edge(),
				i_top_next_second_last_point = i_top_next_last_point-n_points_per_edge()
				)
		let(i_top_current_minor_point = get_minor_point_prefer_major_index(i_top_current_last_point, current_faces_pts)
															/*
															points_3Dvec[current_faces_pts[i_top_current_last_point]].z >  points_3Dvec[current_faces_pts[i_top_current_second_last_point]].z  ?
																//The last two points are not at the same height (z). The minor point for the top is from last point
																prefer_major_index(i_top_current_last_point, current_faces_pts)
																: //The last two points are at the same height (second point with lower z is not supported) as in square threads
																  //then the radius of the points decides
																	get_minor_point_index(i_top_current_last_point, i_top_current_second_last_point, current_faces_pts),
																	*/
																,
				i_top_next_minor_point = get_minor_point_prefer_major_index(i_top_next_last_point, next_faces_pts)
																/*
																points_3Dvec[next_faces_pts[i_top_next_last_point]].z >  points_3Dvec[next_faces_pts[i_top_next_second_last_point]].z  ?
																prefer_major_index(i_top_next_last_point, next_faces_pts)
																//get_minor_point_index(i_top_next_last_point, i_top_next_second_last_point)
																: get_minor_point_index(i_top_next_last_point, i_top_next_second_last_point, next_faces_pts)
																*/
				)
		
	for(poly = [ //without this for loop the code shows irregular behaviour only returning first polygon.
		
		// ******  Top  ******
		// Top large cover triangles of segments to hollow_rad.
			1==1 ? [] :
			i_top_current_2nd_center_point == i_top_current_minor_point ? [] : //Channel threads have a "bore" at minor radius.
			uturn(right_handed, false,
			[current_faces_pts[i_top_current_2nd_center_point],
				current_faces_pts[i_top_current_minor_point],
				next_faces_pts[i_top_next_minor_point]
			]),
		// ******  Top  ******
		// Top small cover triangles between segments to center from hollow_rad to closing face.
			1==1 ? [] :
			i_top_next_minor_point == i_top_next_2nd_center_point ? [] : //Channel threads have a "bore" at minor radius.
			uturn(right_handed, false,
			[current_faces_pts[i_top_current_2nd_center_point],
				next_faces_pts[i_top_next_minor_point],
				next_faces_pts[i_top_next_2nd_center_point]
			]),
		// ******  Top  ******
		// If the lowest point is larger than minor radius, then
		// a gap (distance minor to outer points) appears on top of thread.
			i_top_current_last_point == i_top_current_minor_point ? [] :
			1==1 ? [] :
				//seg_plane_index != 4 ?  [] :
			let(facet = 	
						uturn(right_handed, false,
						[next_faces_pts[i_top_next_minor_point],
						current_faces_pts[i_top_current_minor_point],
						current_faces_pts[i_top_current_last_point]
					]))
			(all_points_at_z(facet, top_z())
				//Test Case 4 (Square Threads, left handed)
				&& 	points_3Dvec[current_faces_pts[i_top_current_second_last_point]].z < top_z()  //Volume below facet exists
				//&&  points_order_is_outwards(current_faces_pts[i_top_current_last_point],current_faces_pts[i_top_current_minor_point]) //Volume below facet exists
			)	? facet : []		
			,
		// ******  Top  ******
		// If the lowest point is larger than minor radius, then
		// a gap (distance minor to outer points) appears on top of thread.
			1==1? [] :
			i_top_next_last_point == i_top_next_minor_point ?  [] :
				//last point is not on minor radius ==> polygon needed.
				//points_3Dvec[next_faces_pts[i_top_next_second_last_point]].z < top_z() ? []
				//:	//There is a volume under this polygon
				1==2 ? [] :
				uturn(right_handed, false,
				[	next_faces_pts[i_top_next_last_point],
				next_faces_pts[i_top_next_minor_point],
				current_faces_pts[i_top_current_last_point]
				]),
		// ******  Top  ******
		// If the lowest point is larger than minor radius, then
		// a gap (distance minor to outer points) appears on top of thread.
			i_top_current_last_point == i_top_current_second_last_point ? [] :
			1==1 ? [] :
				//seg_plane_index != 4 ?  [] :
				let(facet = 	
							uturn(right_handed, false,
							[next_faces_pts[i_top_next_last_point],
							current_faces_pts[i_top_current_last_point],
							current_faces_pts[i_top_current_second_last_point]
							]))
				(all_points_at_z(facet, top_z())
					//Test Case 4 (Square Threads, left handed)
					&&  points_order_is_outwards(current_faces_pts[i_top_current_last_point], current_faces_pts[i_top_current_second_last_point]) //Volume below facet exists
				)	? facet : []						
			,
			
		]) // end of for(poly=[
	poly
	]
	,
	[ // ******  Bottom  ******
		//Define indexes of current_faces_pts/next_faces_pts 

		let(i_bottom_current_first_point = 
					is_channel_thread ? 
						//is_first_plane_of_horiz_start(seg_plane_index) ?
						//		i_bottom_2nd_center_point + 1 + n_points_per_start()
						//	:	
							i_bottom_2nd_center_point + 1
					: current_first_point_indexes_with_z_bottom[0]
				,
				i_bottom_next_first_point = 
					is_channel_thread ?  
						is_first_plane_of_horiz_start(next_seg_plane_index) ?
								i_bottom_2nd_center_point + 1 + n_points_per_start()
							:	i_bottom_2nd_center_point + 1
					: next_first_point_indexes_with_z_bottom[0]
				)
		let(i_bottom_current_second_point = i_bottom_current_first_point+n_points_per_edge(),
				i_bottom_next_second_point = i_bottom_next_first_point+n_points_per_edge()
				)
		let(i_bottom_current_minor_point = get_minor_point_prefer_major_index(i_bottom_current_first_point, current_faces_pts)
																/*
																points_3Dvec[i_bottom_current_first_point].z <  points_3Dvec[i_bottom_current_second_point].z  ?
																//if second point is higher, then the minor point for the bottom is from first point
																prefer_major_index(i_bottom_current_first_point, current_faces_pts)
																: //if they are equal (second point with lower z is not supported) as in square threads
																  //then the radius of the points decides
																	get_minor_point_index(i_bottom_current_first_point, i_bottom_current_second_point, current_faces_pts)
																*/	
																,		
				i_bottom_next_minor_point = get_minor_point_prefer_major_index(i_bottom_next_first_point, next_faces_pts)
															/*
															points_3Dvec[i_bottom_next_first_point].z <  points_3Dvec[i_bottom_next_second_point].z  ?
																prefer_major_index(i_next_first_point, next_faces_pts)
																: get_minor_point_index(i_bottom_next_first_point, i_bottom_next_second_point, next_faces_pts)
															*/
				)
		

		for(poly = [ //without this for loop the code show irregular behaviour only returning first polygon.
			// ******  Bottom  ******
			// Bottom triangles from closing face	to hollow_rad 
			1==1? [] :
			uturn(right_handed, false,
			[current_faces_pts[i_bottom_current_minor_point],
				current_faces_pts[i_bottom_2nd_center_point],
				next_faces_pts[i_bottom_next_minor_point]
			]),
			// ******  Bottom  ******
			// Bottom triangles from hollow_rad to closing face.
			1==1 ? [] :
				uturn(right_handed, false,
				[next_faces_pts[i_bottom_next_minor_point],
					current_faces_pts[i_bottom_2nd_center_point],
					next_faces_pts[i_bottom_2nd_center_point]
				])
			,
			// ******  Bottom  ******
			// If the lowest point is larger than minor radius, then
			// a gap (ring)appears on bottom of thread.
			i_bottom_current_first_point == i_bottom_current_minor_point ? [] :
			1==1 ? [] :
			uturn(right_handed, false,
			[current_faces_pts[i_bottom_current_minor_point],
				next_faces_pts[i_bottom_next_minor_point],
				current_faces_pts[i_bottom_current_first_point]
			]),
			// ******  Bottom  ******
			// If the lowest point is larger than minor radius, then
			// a gap (ring)appears on bottom of thread.
			i_bottom_next_first_point == i_bottom_next_minor_point ?  [] :
			1==1 ? [] :
				let(facet = uturn(right_handed, false,
				[next_faces_pts[i_bottom_next_minor_point],
					next_faces_pts[i_bottom_next_first_point],
				current_faces_pts[i_bottom_current_first_point]
					]))
			//Suppress facet, square thread without volume above,at thread start (z=0)
				(all_points_at_z(facet, bottom_z())
				&& 	points_3Dvec[next_faces_pts[i_bottom_next_second_point]].z > bottom_z()  //Volume above facet exists
				)	? facet : []
			,				
			// ******  Bottom  ******
			// If the lowest point is larger than minor radius, then
			// a gap (ring)appears on bottom of thread.
			//i_bottom_next_first_point == i_bottom_next_second_point ? [] : 
			// Suspicous, creates 4 polygons and one very slim.
			i_bottom_next_first_point == i_bottom_next_second_point ?  [] :
			1==1 ? [] :
				let(facet = uturn(right_handed, false,
							[	next_faces_pts[i_bottom_next_first_point],
								next_faces_pts[i_bottom_next_second_point],
								current_faces_pts[i_bottom_current_first_point]
							]))
				//Suppress facet, square thread without volume above,at thread start (z=0)
				//Test Case 4
				(all_points_at_z(facet, bottom_z())
				&& points_order_is_outwards(next_faces_pts[i_bottom_next_first_point], next_faces_pts[i_bottom_next_second_point])  //Volume above facet exists
				)	? facet : []
				
		]) // end of for(poly=[
		poly
	]
	,
				// ******  Bottom  ******
			//Closing polygons of planar face at thread start.
			//Since std threads are flat at z=0 the planar face is not needed.
			1==2 ? [] :			
			is_channel_thread && is_first_plane_of_horiz_start(seg_plane_index)? 
				//Bottom planar face up to last seg_plane_index
					get_closing_planar_face(seg_plane_index = seg_plane_index,
							start_seg_faces_pts = current_faces_pts,
							face_center_pointIndex = 1,
							highest_tooth_point_index = n_center_points()-1 + n_points_per_start(),
							lowest_tooth_point_index = n_center_points()-1,
							center_point_index = 0,
							last_visible_tooth_point_index = n_center_points()-1 
																							+ n_points_per_start(),
							is_for_top_face = false
																)		
			: [] 
	,
	[
		// ******  Bore  ******
		// Facets for closed bore center at top
		is_hollow ? [] :
			1==2 ? [] :
				uturn(right_handed, false,
				[current_faces_pts[i_top_current_2nd_center_point],
					next_faces_pts[i_top_next_2nd_center_point],
					current_faces_pts[i_top_current_center_point]
				]),	
		// ******  Bore  ******
		// Facets for closed bore center at bottom
		is_hollow ? [] :
			1==2? [] :
				uturn(right_handed, false,
				[next_faces_pts[i_bottom_2nd_center_point],
					current_faces_pts[i_bottom_2nd_center_point],
					current_faces_pts[i_bottom_center_point]
				]),						
		// ******  Bore  ******
		// Facets for closed bore center at bottom, channel thread
		// Test this with nor bore and netfabmin = 1200 * netfabmin
		!is_channel_thread || is_hollow ? [] :
			1==2 ? [] :
				seg_plane_index>n_segments-2 ? [] :
				uturn(right_handed, false,
				[	current_faces_pts[i_bottom_center_point],
					next_faces_pts[i_bottom_center_point],
					next_faces_pts[i_bottom_2nd_center_point]
				]),	
		!is_channel_thread || is_hollow ? [] :
			1==2 ? [] :
				seg_plane_index>n_segments-2 ? [] :
				uturn(right_handed, false,
				[	i_bottom_first_seg_second_center_pt,
					next_faces_pts[i_bottom_center_point],
					current_faces_pts[i_bottom_center_point]
				]),	
		// ******  Bore  ******
		// Facets for bore
		!is_hollow ? [] :
			1==2 ? [] :
				uturn(right_handed, false,
				[current_faces_pts[i_top_current_2nd_center_point],
					next_faces_pts[i_top_next_2nd_center_point],
					current_faces_pts[i_bottom_2nd_center_point]
				]),
		!is_hollow ? [] :
			1==2 ? [] :	
				uturn(right_handed, false,
				[current_faces_pts[i_bottom_2nd_center_point],
					next_faces_pts[i_top_next_2nd_center_point],
					next_faces_pts[i_bottom_2nd_center_point]
				])

	]
		); //end concat and function		
		

		function facets_needed(next_point_offset, 
														face_set_index, 
														current_faces_pts,
														next_faces_pts) =
					next_point_offset + face_set_index+n_points_per_edge() 
					< len(next_faces_pts)-n_center_points()
			;
		
	//-----------------------------------------------------------

	function points_order_is_outwards(i_inner_point, i_outer_point) =
						(abs(points_3Dvec[i_inner_point].x)
						< abs(points_3Dvec[i_outer_point].x));

	function all_points_at_z(facet, z) =
		(points_3Dvec[facet[0]].z == z 
		&& points_3Dvec[facet[1]].z == z
		&& points_3Dvec[facet[2]].z == z  );
		
	function get_minor_point_prefer_major_index(i_seg_point_major, seg_faces) =
			points_3Dvec[seg_faces[i_seg_point_major]] == points_3Dvec[seg_faces[i_seg_point_major+1]] ? i_seg_point_major : i_seg_point_major+1;

	function get_minor_point_index(i_seg_major_point1, i_seg_major_point2, seg_faces) =
							(norm_xy(points_3Dvec[seg_faces[i_seg_major_point1]])
								<= norm_xy(points_3Dvec[seg_faces[i_seg_major_point2]])
							? i_seg_major_point1+1 : i_seg_major_point1+1)
						;		
	function get_minor_face_point_index(seg_faces_pts,
																			thread_face_point_index) =
							thread_face_point_index
							/*
							thread_face_point_index +
							(norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index]])
								> norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index+1]])
							? 1 : 0)*/
						;
				
						
	//Closing planar face polygon at thread start (bottom/top)		
	//DEBUG:		
	//Disable intersecting/differentiating of thread to correct length
	//to see them
	function get_closing_planar_face(seg_plane_index,
																		start_seg_faces_pts,
																		face_center_pointIndex,
																		highest_tooth_point_index,
																		lowest_tooth_point_index,
																		center_point_index,
																		last_visible_tooth_point_index,
																		is_for_top_face
																	) =
							concat(
								// 1 : The closing face polygons along tooth base (minor radius) of first or last turn 
								//     to the center. This does not include the polygons of the tooth itself.
								//     Since std threads have a flat top/bottom they are not needed.
								//     Since channel threads have a flat top, supress it also for this case.
								1==1
									&& (is_channel_thread && !is_for_top_face) ?
								[ 
										for (face = get_closing_face_to_toothbase(
														seg_faces_pts = start_seg_faces_pts,
														face_center_pointIndex = face_center_pointIndex,
														is_for_top_face = is_for_top_face))
											face
								]	: []
								
							,
								// 2 : The closing face polygons for the tooth profile to tooth base (minor radius).
								//     Tests showed, that polygons from center to tooth points
								//     are not ok for OpenScad. It creates its own polygons for
								//     the tooth if it feels so. So tooth face and base to center were seperated.
								//     Also, because polygons from center point (0)
								//     do not work because with large flank angles lines from 
								//     center point to upper flat intersect with lower flat line.	
								//     Since std threads have a flat top/bottom they are not needed.
								//     Since channel threads have a flat top, supress it also for this case.
								
								(1==1 
									&& is_channel_thread && !is_for_top_face) ?						
								[ for (tooth_index = [0:1:n_tooths_per_start()-1])
										for (face = get_closing_tooth_face(
																	seg_faces_pts = start_seg_faces_pts,
																	is_for_top_face = is_for_top_face,
																	tooth_index = tooth_index,
																	highest_tooth_point_index = 
																		(is_for_top_face ?
																				len(start_seg_faces_pts)
																				- n_center_points()
																				- n_points_per_edge() //first point pair
																				-(tooth_index)*len_tooth_points
																				:
																				0 // center point
																				+ n_center_points() //first point pair
																				+ (tooth_index+1)*len_tooth_points
																				//- n_points_per_edge() //lower flat, no polygon
																		),
																							
																	lowest_tooth_point_index = 
																		(is_for_top_face ?
																				len(start_seg_faces_pts) 
																				- n_center_points()
																				- n_points_per_edge() //first point pair
																				-(tooth_index+1)*len_tooth_points
																				//+ 2 //lower flat, no polygon
																			:
																				0 // center point
																				+ n_center_points() //first point pair
																				+ (tooth_index)*len_tooth_points
																		))
													)
										face
								]		//n_tooths_per_start()	
								: []		
							);
										

										
	function get_closing_face_to_toothbase(seg_faces_pts,
																	face_center_pointIndex,
																	is_for_top_face) =
			[ for (tooth_index = [0:1:n_tooths_per_start()-1])
					let( highest = (is_for_top_face ?
													face_center_pointIndex
																	-1 // minor point of point pair
																	-(tooth_index)*len_tooth_points
												: face_center_pointIndex
															+ 1  // thread point of point pair
															+ 1  //minor point of point pair
															+ (tooth_index+1)*len_tooth_points
													)
								,centerp = is_for_top_face ? 
															len( seg_faces_pts)- n_center_points()
															: face_center_pointIndex
							)
					for (poly_index = [0:n_points_per_edge()
													:len_tooth_points-n_points_per_edge()]	)	
						uturn(right_handed, is_for_top_face,
							[seg_faces_pts[get_minor_face_point_index(seg_faces_pts,
																											highest-poly_index)],
							seg_faces_pts[centerp],
							seg_faces_pts[get_minor_face_point_index(seg_faces_pts,
															highest-poly_index-n_points_per_edge())]
						])
			]					
		; //end function	
	
	
		function is_minor_face_point(seg_faces_pts, thread_face_point_index) =
							norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index]])
								<= norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index+1]])
						;		
					
		//Each tooth element may have two polygons.
		//For a given tooth profile some tooth_elements may not need both polygons.
		//Returns a vector :  [lower polygon needed(bool), higher polygon needed(bool)]
		function needed_tooth_element_polygons(seg_faces_pts, thread_face_point_index) =
						let(next_index = thread_face_point_index + n_points_per_edge(),
								lower_is_minor = is_minor_face_point(seg_faces_pts,
																					thread_face_point_index),
								higher_is_minor = is_minor_face_point(seg_faces_pts, next_index),
								z_equal = (points_3Dvec[seg_faces_pts[thread_face_point_index]].z
														== points_3Dvec[seg_faces_pts[next_index]].z)
							)
						lower_is_minor ?
							(higher_is_minor ?
								//lower minor, higher minor
								//Empty tooth element
								[false,false]
							:
								(//lower minor, higher not minor
								z_equal ?
									//No polygon needed. 
									[false,false]
								:
									//lower polygon of tooth element on lower part of tooth needed
									[true,false]
								)	
							)
						: 
							(higher_is_minor ?
								(//lower not minor, higher minor
								z_equal ?
									//No polygon needed. 
									[false,false]
								:
									//Upper polygon of tooth element on lower part of tooth needed
									[false,true]
								)	
							:
								(//lower not minor, higher not minor
								z_equal ?
									//No polygon needed. 
									[false,false]
								:
									//Full tooth element
									//If both are larger than minor two polygons are needed		
									[true,true]
								)	
								
								

							)
						;
					
	
		// Creates two polygons for each tooth_element of one tooth.
		// A tooth has multiple tooth_elements.
		// A tooth profile has multiple teeth.
		function get_closing_tooth_face(seg_faces_pts,
																	is_for_top_face,
																	tooth_index,
																	highest_tooth_point_index,
																	lowest_tooth_point_index,
																	) =

			[for (facets =		
				[	for (tooth_element= [0:n_points_per_edge()
																:highest_tooth_point_index-lowest_tooth_point_index
																	-n_points_per_edge()])
					let(index = lowest_tooth_point_index + tooth_element,
							needed_polygons = needed_tooth_element_polygons(seg_faces_pts, index)
							)
						[
							//DEBUG : 
							//[999999, lowest_tooth_point_index,highest_tooth_point_index],
							// 1 : Higher polygon of tooth element
							(needed_polygons[1] ?	
								uturn(right_handed, is_for_top_face,
											[seg_faces_pts[index+0],
											seg_faces_pts[index+n_points_per_edge()+1],
											seg_faces_pts[index+1]]):[])
							,
							// 2 : Lower polygon of tooth element
							(needed_polygons[0] ?	
								uturn(right_handed, is_for_top_face,
											[seg_faces_pts[index+0],
											 seg_faces_pts[index+n_points_per_edge()],
											seg_faces_pts[index+n_points_per_edge()+1]]):[])
						]
				]) //for facets
				for (facet=facets) //flatten
					if(len(facet)==3)
						facet
			]
					
			; //end function	
	
	function uturn(right_handed, is_for_top_face, vec) =
				((right_handed && !is_for_top_face 
						|| (!right_handed && is_for_top_face)) 
					? 
						(len(vec)==3 ? 
							[vec.y,vec.x,vec.z]	
							: [for(i = [len(vec)-1:-1:0])
								vec[i]
							]
						)		
					 
					:vec
				);
	function uturn_right_handed(right_handed,  vec3D) =
				(right_handed ?
					 [vec3D.y,vec3D.x,vec3D.z]	
					:vec3D
				);							
						
	function get_first_faces_pts() = pre_calc_faces_points[0];
	function get_secondlast_faces_pts() = pre_calc_faces_points[n_segments-1];
	function get_last_faces_pts() = pre_calc_faces_points[n_segments];	
	
								
	//-----------------------------------------------------------		
	// ------------------------------------------------------------
	// Check faces integrity
	// ------------------------------------------------------------
	//-----------------------------------------------------------

	
	thread_faces_sorted_points = sort_points_in_faces(faces=thread_faces);
	self_intersecting_faces = get_polygons_duplicate_vertexes(faces = thread_faces_sorted_points);
	test_duplicate_faces = [];//[[2,1,1],[1,2,1]];
	test_faces = sort_points_in_faces(faces=concat(test_duplicate_faces,thread_faces_sorted_points));
	thread_faces_sorted_faces = sort_faces( test_faces);
	duplicate_faces = get_faces_duplicates(faces=thread_faces_sorted_faces);

	function get_faces_duplicates(faces = []) =
		[
			for(found_face =
			[
				for(index = [0:1:len(faces)-1])
					faces[index] == faces[index+1] ? faces[index] : []
			])
			if(len(	found_face)> 0)
				found_face
		];	

	function get_polygons_duplicate_vertexes(faces = []) =
		[
			for(found_face =
			[
				for(face = faces)
				
					//quicksort_faces(face)
					check_vertex_duplicate(face=face,index=0,face_length=len(face)) ?
						face : []
			
			])
			if(len(	found_face)> 0)
				found_face
		];
			
	function check_vertex_duplicate(face=[], current_index=0, face_length=0) =
			current_index >= face_length-1 ?
				false //end of array, no duplicates found
			:	
				face[current_index] == face[current_index+1] ?
					true//[current_index] //end recursion, duplicate found
				: 
					check_vertex_duplicate(face=face, index=current_index+1) 
		;
		

	function sort_faces(faces=[]) =
			quicksort_faces(faces)
	;
		
	function sort_points_in_faces(faces=[]) =
	[
		for(face = faces)
			quicksort_face(face)
	];

	function quicksort_face(arr) =
  (len(arr)==0) ? [] :
      let(  pivot   = arr[floor(len(arr)/2)],
            lesser  = [ for (y = arr) if (y  < pivot) y ],
            equal   = [ for (y = arr) if (y == pivot) y ],
            greater = [ for (y = arr) if (y  > pivot) y ]
      )
      concat( quicksort_face(lesser), equal, quicksort_face(greater) ); 
					
	function quicksort_faces(arr) =
  (len(arr)==0) ? [] :
      let(  pivot   = arr[floor(len(arr)/2)][0],
            lesser  = [ for (y = arr) if (y[0]  < pivot) y ],
            equal   = [ for (y = arr) if (y[0] == pivot) y ],
            greater = [ for (y = arr) if (y[0]  > pivot) y ]
      )
      concat( quicksort_faces(lesser), equal, quicksort_faces(greater) );


	//-----------------------------------------------------------		
	// ------------------------------------------------------------
	// Create Thread/polygon
	// ------------------------------------------------------------
	//-----------------------------------------------------------
	
	 
	//DEBUG
	/*
	echo("***********************************************");
	echo("points_3Dvec len ");
	echo(points_3Dvec, len(points_3Dvec));
	echo("***********************************************");
	echo("thread_faces len ");	
	echo(thread_faces, len(thread_faces));	
	*/
						
	if(len(duplicate_faces) > 0)
	{
		echo("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		echo("Duplicate faces", duplicate_faces);
	}
	if(len(self_intersecting_faces) > 0)
	{
		echo("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		echo("Self intersecting faces", self_intersecting_faces);
	}
	
	polyhedron(	points = points_3Dvec,
									faces = thread_faces);

	
}//end module make_thread_polyhedron()



						
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

