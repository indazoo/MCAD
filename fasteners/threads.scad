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
 * 
 * - small error (too much material) for channel thread differences at segment plan 0.
 * - big taper angles create invalid polygons (no limit checks implemented).
 * - test print BSP and NPT threads and check compatibility with std hardware.
 * - check/buils a 45(?) degree BSP/NPT thread variant which fits on metal std hardware 
     and has no leaks (i believe for garden stuff)
 * - printify does notwork after v1.8   
 * - Manual polygon triangulation for complex tooth profile maps
 * - Internal threads start at y=0 as non internal do.
 *   This is not 100% correct. The middle point between two segment planes
 *   of internal and normal thread should be aligned. Barely noticable. 
 *   No known effect on usability.
 * - Often one wants a shaft attached to the thread. ==> param (len_top/bottom_shaft).

 * OPTIONAL
 * - Cut thread to length without intersection but with polygon calculation.
 *   This would give another speed boost.
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
// Test Case 1:
// $fn=26; //or 58
// metric_thread(8, pitch=3, length=5, right_handed=true, internal=false, n_starts=3, bore_diameter=2);
// ==>  if bottom _z() is above zero then there was a polygon too much at bottom.

// Test Case 2 (TODO) :
// $fn=3; 
// metric_thread(8, pitch=3, length=5, right_handed=true, internal=false, n_starts=3, bore_diameter=2);
// ==> holes at bottom and top appear, bore is covered by polygons.

// Test Case 3(TODO)
// $fn=32;
// square_thread(diameter=8, pitch=1.5, length=1.5-pow(2,50), bore_diameter=3, right_handed=false);  
// ==> gave collection errors : "WARNING: Bad range parameter in for statement: too many elements (2863311528)"

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


// Test Case 7 (TODO) :
// The limitation of the thread to top_z() and bottom_z() results in points at z which are rotated away from the original segment angle.
// Due to the fact that a round structure is given by points and the fact, that a straight line between two points is smaller than the wanted radius
// the move of the point at z results in undercuts at bottom and overcuts at top.
// Sample :
// $fn=16;
// test_rope_thread(length=1, n_starts=3);

// Test Case 8 (TODO)
// At top (maybe at bottom too) the top cover overlaps in air (very small triangle at the profile.
// Also a polygon is missing.
// $fn=16;
// test_rope_thread(length=1, n_starts=3);

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

//test_rope_thread(rope_diameter=1.2, rope_bury_ratio=0.9, coarseness=10,n_starts=2 );
//test_channel_simple();
//test_channel_thread(dia=8);
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
	angles = [20,10];
	length = 8;
	pitch=2;
	backlash = 0.13;
	outer_flat_length = 0.5;
	clearance = 0.17;
	backlash = 0.1;
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
		bore_diameter = 0
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
		bore_diameter = 0
		);
}

module test_channel_thread2()
{
	//top cuts through upper thread (no shaft)
	angles = [0,30]; 
	length = 1;
	outer_flat_length = 0.2;
	clearance = 0.2;
	backlash = 0.15;
	function getdia(n) = 5 + n * 5;
	for (n=[1 : 1])
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
		right_handed = true,
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
									tooth_flat]]
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
				[for ( circel_seg = [1:coarseness-1]) 
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
		difference() 
		{
			//
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

			//Cut to length
			if(true) //DEBUG : set to false to see full thread before cutting
			{
				translate([0, 0, 
										oversized_len()/2 + //correct center = true
											rest_of_channel_len(length)])
					cube([diameter*4, diameter*4, oversized_len()], center=true);
			}
		}
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
	
	echo("n_segments",n_segments);
	echo("seg_angle",seg_angle);
	echo("tooth_profile_map", tooth_profile_map);
	echo("is_hollow", is_hollow);
	
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
					for (turn = [ 0 : n_turns_of_seg_plane(seg_plane_index)-1 ]) 
						let (is_last_turn = (turn == n_turns_of_seg_plane(seg_plane_index)-1))
						for (combined_start = [0 : n_tooths_per_turn()-1])  
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

	function n_points_per_turn() =  n_tooths_per_turn() *len_tooth_points;
	function n_points_per_start() =  n_vert_starts *len_tooth_points;
	function n_tooths_per_turn()	= n_vert_starts;//*n_horiz_starts;					
	function n_tooths_per_start()	= n_vert_starts;										
	function n_center_points() = 2;				
	function n_points_per_edge() = 2;		
	function is_center_point(point_index, tooths_polygon) = (point_index < n_center_points()) || (point_index > len(tooths_polygon)-n_center_points()-1);
	function top_z() = is_channel_thread ? length-(-1)*bottom_z() : length;
	function bottom_z() = is_channel_thread ? -thread_height_below_zero() :  0;
	function thread_height_below_zero() = is_channel_thread ? 2* pitch*n_tooths_per_start() : pitch*n_tooths_per_turn();
	
	
	// -------------------------------------------------------------
	//Create a closed planar (point.y=0) polygon with tooths profile and center points
	function get_3Dvec_tooths_polygon(seg_plane_index) =
						complete_3Dvec_tooths_polygon(get_3Dvec_tooths_points(seg_plane_index));

	function complete_3Dvec_tooths_polygon(tooths_profile) = 
				concat(
					//bottom center point
					[[0,0,tooths_profile[0].z]],
					[[hollow_rad,0,tooths_profile[0].z]],
					//tooth points
					tooths_profile,
					//top center point
					[[hollow_rad,0,tooths_profile[len(tooths_profile)-1].z]],
					[[0,0,tooths_profile[len(tooths_profile)-1].z]]
				);
	
	
	pre_calc_tooths_polygon = get_3Dvec_tooths_polygon(0);				
	tooths_polygon_point_count = len(pre_calc_tooths_polygon);
	//echo("pre_calc_tooths_polygon",pre_calc_tooths_polygon);
	//echo("tooths_polygon_point_count",tooths_polygon_point_count);

	// -------------------------------------------------------------
	//- Rotate and lift ( z axis) the pre calculated planar tooths polygon
	//  for each segment angle.
	//- taper point
	// Array of planar polygons rotated and lifted in z
	function get_3Dvec_seg_plane_point_polygons() = [
							for (seg_plane_index = [0:get_n_segment_planes()-1])
								get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index)
						];
	pre_calc_seg_plane_point_polygons = get_3Dvec_seg_plane_point_polygons();

	function get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index) = [
							for (point = get_3Dvec_tooths_polygon(seg_plane_index))  
								taper(
									z_offset_v3(get_segment_zOffset(seg_plane_index) 
													- (is_channel_thread ? 2* pitch*n_tooths_per_start() : 
																					pitch*n_tooths_per_turn()),
										rotate_xy(rotation_angle_synced(seg_plane_index), point)
										
									) // z_offset
								)// taper
						];
	


			 
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
	points_3Dvec = [
						for (poly_gon	= pre_calc_seg_plane_point_polygons) 
							for (point = poly_gon)
								point
						];	
							

	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// FACES
	//-----------------------------------------------------------
	//-----------------------------------------------------------

	// Generate an array of point index numbers used later for 
	// creating the faces points.
	// Its structure/length is equal to the previously created 3D points.
	// Returns always the same length for all segments of the same thread.
	// generate_faces_points(0) ==>  [0,1,2,...,13]
	// generate_faces_points(1) ==>  [14,15,16,...,27]
	pre_calc_faces_points = generate_all_seg_faces_points();
							
	function generate_all_seg_faces_points() = 
					[ for (seg_plane_index	= [ 0 : get_n_segment_planes()-1])
								generate_faces_points(seg_plane_index)
					];

	function generate_faces_points(seg_plane_index) = 
					[ for (fp = [seg_faces_point_offset(0,seg_plane_index,0)
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
	thread_faces = [
				// Notes:
				// Channel threads use n_starts for number 
				// of horizontal threads (n_horiz_starts).
				// For every n_start exist (n_segments/n_starts) segment planes.
				// tooth_offset: one tooth per horizontal start one per vertical start
				//               offset = n_horiz_starts*n_vert_starts
				// length: std_thread length above z=0
				//         channel thread length = below zero.
				for (seg_plane_index	= [ 0 : get_n_segment_planes()-1]) 
					let (current_faces_pts = pre_calc_faces_points[seg_plane_index],
							next_faces_pts  = pre_calc_faces_points[
																	get_adj_seg_plane_index(seg_plane_index+1)],
							next_point_offset = get_point_index_offset(
												get_adj_seg_plane_index(seg_plane_index+1),false) 
							)
					for (a = get_seg_faces(seg_plane_index,
																pre_calc_faces_points[0], 
																current_faces_pts, 
																next_faces_pts,
																pre_calc_faces_points[len(pre_calc_faces_points)-1],
																next_point_offset
																)
								) 
							a //extract faces into 1-dim array
					]; 

	
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
						n_vert_starts * len_tooth_points
					;

					

							
	function is_first_plane_of_horiz_start(seg_plane) = 
					(seg_plane) % (horiz_raster()) == 0 ;

	function is_last_plane_of_horiz_start(seg_plane) = 
					(seg_plane+1) % (horiz_raster()+1) == 0 ;				
	
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
			&& false?
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
	//-----------------------------------------------------------
	//-----------------------------------------------------------
	// Get faces of one segment.
	function get_seg_faces(seg_plane_index, 
									first_faces_pts, 
									current_faces_pts, 
									next_faces_pts, 
									last_faces_pts,
									next_point_offset) = 
		concat(

		// ******  Top  ******
		// Top large cover triangles of segments to center
		[uturn(right_handed, true,
			[next_faces_pts[i_2nd_center_point(next_faces_pts)],
				next_faces_pts[get_minor_face_point_index(
														seg_faces_pts = next_faces_pts,
														thread_face_point_index =	
													i_2nd_center_point(next_faces_pts)
													-1 //minor point of point pair
													)],
				current_faces_pts[get_minor_face_point_index(
														seg_faces_pts = current_faces_pts,
														thread_face_point_index =	
													i_2nd_center_point(current_faces_pts)
													-1 //minor point of point pair
													- ((is_first_plane_of_horiz_start(seg_plane_index)) ? 
																n_points_per_turn() : 0
																))]
			])]
		,
		// ******  Top  ******
		// Top small cover triangles between segments to center
		[uturn(right_handed, true,
			[current_faces_pts[i_2nd_center_point(current_faces_pts)],
				next_faces_pts[i_2nd_center_point(next_faces_pts)
											//-n_points_per_edge() //first tooth point
											],
				current_faces_pts[get_minor_face_point_index(
														seg_faces_pts = current_faces_pts,
														thread_face_point_index =	
																i_2nd_center_point(current_faces_pts)
																-1 //minor point of point pair
																- ((is_first_plane_of_horiz_start(seg_plane_index)) ? 
																			n_points_per_turn() : 0
																			))]
				]
				)
			]
		// ******  Top  ******
		// If the top most point is larger than minor radius, then
		// a gap appears on top of thread.
		// Sample cases: - internal channel threads 
		//               - rope threads
		,
			get_top_ring_faces(seg_plane_index,
													current_faces_pts,
													next_faces_pts
													)
		
		//Closing triangles to next segment
		,( (!is_first_plane_of_horiz_start(seg_plane_index))? []
			:
				//Top triangle down to first segment
				get_closing_planar_face(seg_plane_index = seg_plane_index,
							start_seg_faces_pts = current_faces_pts,
							face_center_pointIndex = i_2nd_center_point(current_faces_pts),
							highest_tooth_point_index = i_2nd_center_point(current_faces_pts)
																						-n_points_per_edge(), //first tooth point
							lowest_tooth_point_index = i_2nd_center_point(current_faces_pts)
																						-n_points_per_edge() //first tooth point
																						-n_points_per_turn(),
							center_point_index = len(current_faces_pts)
																					-1, ///array, first center point
							last_visible_tooth_point_index = i_2nd_center_point(current_faces_pts)
																					-n_points_per_edge()
																					-n_points_per_turn()
																					,
							is_for_top_face = true
																)				
			
		) // end condition top closing polygon
		


		// ******  Closing faces for channel thread ******	
		//internal channel thread needs closing face at begin of second turn
		// ==> Not needed so far. The automaticall existing "slope" is OK.
		//,
		
		,
		// ******  Tooths faces  ******
		[ for (face_set_index = [n_center_points() //start after bottom center points
														: n_points_per_edge() //step size:
																//Each point existed twice in a point
																//pair(major/minor). The most
																//important is at first position.
															: i_2nd_center_point(current_faces_pts)
																-n_points_per_edge() //first point pair
																-n_points_per_edge() //stop on point pair early
																				//because we use later "face_set_index+2"
																+0
																
																]) 
			if (facets_needed(next_point_offset, 
												face_set_index, 
												current_faces_pts,
												next_faces_pts))
			for (face_set = 
							[uturn(right_handed, true,
								[current_faces_pts[face_set_index],
								 next_faces_pts[next_point_offset+face_set_index+n_points_per_edge()],
								 next_faces_pts[next_point_offset+face_set_index]]),
							 uturn(right_handed, true,
								[current_faces_pts[face_set_index+n_points_per_edge()],
								 next_faces_pts[next_point_offset+face_set_index+n_points_per_edge()],
								 current_faces_pts[face_set_index]])
							]
						)
				face_set
		]

	,

		// ******  Bottom  ******
		// Bottom triangles to center and closing face	
		// Bottom triangle to center	
	
	[uturn(right_handed, false,
			[current_faces_pts[2+1],
				current_faces_pts[1],
				next_faces_pts[next_point_offset+n_points_per_edge()
													+1 //Take minor 
												]])]
		,
			[uturn(right_handed, false,
				[current_faces_pts[1],
					next_faces_pts[1],
					next_faces_pts[next_point_offset+n_points_per_edge() 
													+1 //Take minor 
												]])]
		,
		//Closing triangle to next segment
		(!is_first_plane_of_horiz_start(seg_plane_index) ? [] :
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
		) // end condition bottom closing polygon
		,
			get_bottom_ring_faces(seg_plane_index,
															current_faces_pts,
															next_faces_pts)
		); //end concat and function		
		

		function facets_needed(next_point_offset, 
														face_set_index, 
														current_faces_pts,
														next_faces_pts) =
					next_point_offset + face_set_index+n_points_per_edge() 
					< len(next_faces_pts)-n_center_points()
			;
		
	//-----------------------------------------------------------
			
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
								// 1 : The face polygons along tooth bases of first turn 
								//     to the center
				
								[ 
										for (face = get_closing_face_to_toothbase(
														seg_faces_pts = start_seg_faces_pts,
														face_center_pointIndex = face_center_pointIndex,
														is_for_top_face = is_for_top_face))
											face
								]	
						,
								// 2 : every tooth has its polygon.
								//     Tests showed, that polygons from center to tooth peak
								//     are not ok for OpenScad. It creates its own polygons for
								//     the tooth if it feels so. Because polygons from center point (0)
								//     do not work because with large flank angles lines from 
								//     center point to upper flat intersect with lower flat line.	
						
								[ for (tooth_index = [0:n_tooths_per_start()-1])
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
								
							,
								// 3 : The polygons to center points of all segments
								//     or hollow shaft
								//     It was necessary to include all center points so
								//     netfabb does not reports a "hole" in center
								//     Also it was necessary to split the planar multipoint
								//     polygon into simple one (3 corners) to prevent "non
								//     planar" messages
								
								( is_hollow ?
									(is_for_top_face ? [] : //inner walls only once if hollow
									[for (vert_facets =
										[for (segIndex = [seg_plane_index:
																			seg_plane_index + (n_segments/n_horiz_starts)-1])
											let(adj_seg_index = get_adj_seg_plane_index(segIndex+1),
													adj_plane_len = //points to second center point
														len(pre_calc_faces_points[adj_seg_index])-1-1) 
											[uturn(right_handed, true,
												[pre_calc_faces_points[adj_seg_index][adj_plane_len],
												pre_calc_faces_points[segIndex][
															len(pre_calc_faces_points[segIndex])-1-1],
												pre_calc_faces_points[adj_seg_index][1]
												])
											,
											uturn(right_handed, true,
												[pre_calc_faces_points[segIndex][
															len(pre_calc_faces_points[segIndex])-1-1],
												pre_calc_faces_points[segIndex][1],
												pre_calc_faces_points[adj_seg_index][1]
												])
											]
										])
										for (facet=vert_facets) //flatten
											if (len(facet) == 3) 
											facet
									]
										) // end is_for_top_face
								:
									 //Not hollow, draw center facets
									( is_for_top_face ?
										// is_for_top_face
										[for (segIndex = [seg_plane_index:
																			seg_plane_index + (n_segments/n_horiz_starts)-1])
											let(adj_seg_index = get_adj_seg_plane_index(segIndex+1),
													adj_plane_len = //points to second center point
														len(pre_calc_faces_points[adj_seg_index])-1-1) 
											uturn(right_handed, is_for_top_face,
												[pre_calc_faces_points[adj_seg_index][adj_plane_len],
												pre_calc_faces_points[segIndex][
															len(pre_calc_faces_points[segIndex])-1-1],
												start_seg_faces_pts[center_point_index]
												])
										]
										:
										// is_for_bottom_face
										[for (segIndex = [seg_plane_index :
																		seg_plane_index + (n_segments/n_horiz_starts)-1])
										let(adj_seg_index = get_adj_seg_plane_index(segIndex+1)
												) 
										uturn(right_handed, is_for_top_face,
											[pre_calc_faces_points[adj_seg_index][face_center_pointIndex],
											pre_calc_faces_points[segIndex][face_center_pointIndex],
											start_seg_faces_pts[center_point_index]
											])
										]
									) // end center facets (not hollow) 
								) // end is_hollow
								
							);
										

										
	function get_closing_face_to_toothbase(seg_faces_pts,
																	face_center_pointIndex,
																	is_for_top_face) =
			[ for (tooth_index = [0:n_tooths_per_start()-1])
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
	
	function uturn(right_handed, is_for_top_face, vec3D) =
				((right_handed && !is_for_top_face 
						|| (!right_handed && is_for_top_face)) ?
					 [vec3D.y,vec3D.x,vec3D.z]	
					:vec3D
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
	// Create Thread/polygon
	// ------------------------------------------------------------
	//-----------------------------------------------------------
	
	/* 
	//DEBUG
	echo("points_3Dvec len ", len(points_3Dvec));
	echo("thread_faces len ", len(thread_faces));	
	echo(points_3Dvec);
	echo(thread_faces);	
	*/

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

