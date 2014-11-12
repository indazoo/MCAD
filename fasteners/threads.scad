/*
 * Dan Kirshner - dan_kirshner@yahoo.com
 * Chow Loong Jin - hyperair@debian.org
 * indazoo 
 *
 * You are welcome to make free use of this software.  Retention of our
 * authorship credit would be appreciated.
 *
 *
 * TODO:
 *  - printify does notwork after v1.8
 *  - OpenScad issues warning the warning:
 *    "Normalized tree is growing past 200000 elements. Aborting normalization."
 *    for medium to high $fn values ==> compile view is not correct. ==> use low 
 *    $fn during development of your part and increase "turn off rendering at" 
 *    in Menu=>Edit=>Preferences substantially (at least on Windows OS). 
 *  - Use OpenScad 2014.QX features as soon
 *    it is officially released (feature: list-comprehensions).
 *  - a lot of standard definitions can be implemented (tolerance etc).
 *  - big taper angles create invalid polygons (no limit checks implemented).
 *  - test print BSP and NPT threads and check compatibility with std hardware.
 *  - a 45 degree BSP/NPT variant which fits on metal std hardware and has no leaks.
 *  - reduce number of polygons for a tooth (speed). 
 *  - The current design creates polyhedra with the possibility of an inner flat
 *    (at minor_rad) on bottom and on top. This is useful if each tooth segment is 
 *    being individually calculated for its position in the thread which needs a
 *    variable inner flat on top and on bottom. With dynamically created polyhedra
 *    only the necessary polyhedra must be created. The current design creates too
 *    many of them and cuts the unneeded on top and bottom. So, with less polyhedra 
 *    speed can be improved. But the last and first polyhedra may 
 *    be tricky to create because they end with height = 0 on one side.
 *    Perhaps, this speed trick should be implemented AFTER moving to list-comprehensions.
 *
 * Version 2.4  2011-11-10  indazoo
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
 *                          - user defined $fn influences number of segements
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

//$fn=12;
//test_thread();
//test_square_thread();
//test_hollow_thread();
//test_threads();
//test_internal_difference_metric();
//test_buttress();
//test_leftright_buttress(5);
//test_internal_difference_buttress();
//test_internal_difference_buttress_lefthanded();
//test_channel_thread();
//test_channel_thread_diff();
//test_NPT();
//test_BSP();

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

module test_threads ($fa=5, $fs=0.1)
{
    // M8
    metric_thread(8, pitch=1.5, length=5);
    translate ([0, -15, 0])
        metric_thread(8, pitch=1.5, length=5, right_handed=false);

    translate ([10, 0, 0])
    square_thread(8, pitch=1.5, length=5);

    translate ([20, 0, 0])
    acme_thread(8, pitch=1.5, length=5);

    translate ([30, 0, 0])
    buttress_thread(8, pitch=1.5, length=5);

    translate ([40, 0, 0])
    english_thread(1/4, pitch=20, length=1/4);

    // multiple start:
    translate ([50, 0, 0])
    metric_thread(8, pitch=1, length=5, internal=true, n_starts=3);

	translate ([-10, 0, 0])
         test_channel_thread();

}

module test_square_thread()
{	
    square_thread(8, pitch=2, length=5);
}

module test_internal_difference_metric($fa=20, $fs=0.1)
{
	difference()
	{
		metric_thread(diameter=34, pitch=2, length=4.3, 
						internal=true, n_starts=1, 
						clearance = 0.1, backlash=0.4);
		metric_thread(diameter=34, pitch=2, length=4.3, 
						internal=false, n_starts=1);
	}
}

module test_internal_difference_metric($fa=20, $fs=0.1)
{
	difference()
	{
		metric_thread(diameter=17.7, pitch=2, length=2.3,
						internal=true, n_starts=3, 
						clearance = 0.1, backlash=0.4);
		rotate([0,0,$fa/2])
		metric_thread(diameter=17.7, pitch=2, length=2.3, 
						internal=false, n_starts=3);
		translate([10,10,0]) cube([20,20,20], center=true);
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
	buttress_thread(diameter=8, pitch=4, length=4.3, 
					internal=false, n_starts=1,
					buttress_angles = [45, 3], right_handed=true);
	
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

module test_channel_thread()
{
	channel_thread(
		thread_diameter = 8,
		pitch = 1,
		turn_angle = 360,
		length = 1,
		internal = false,
		n_starts = 1,
		thread_angles = [20,45],
		outer_flat_length = 0.2,
		right_handed = true,
		clearance = 0,
		backlash = 0,
		bore_diameter = 5
		);

	translate([0,-10,0])
	channel_thread(
		thread_diameter = 8,
		pitch = 0.5,
		turn_angle = 360,
		length = 1,
		internal = false,
		n_starts = 1,
		thread_angles = [0,45],
		outer_flat_length = 0.2,
		right_handed = false,
		clearance = 0,
		backlash = 0,
		bore_diameter = 5);
	
}

module test_channel_thread_diff()
{
	angles= [10,30];
	difference()
	{
		channel_thread(
			thread_diameter = 8,
			pitch = 0.5,
			turn_angle = 360,
			length = 1,
			internal = true,
			n_starts = 1,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = false,
			clearance = 0.1,
			backlash = 0.1,
			bore_diameter = 5);
		channel_thread(
			thread_diameter = 8,
			pitch = 0.5,
			turn_angle = 360,
			length = 1,
			internal = false,
			n_starts = 1,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = false,
			bore_diameter = 5);
		translate([-2.5,-2.5,0]) cube([5,5,5], center=true);
	}
}

module test_NPT()
{
	US_national_pipe_thread(
		nominal_pipe_size = 3/4,
		length = 0.5,
		internal  = false);
}

module test_BSP()
{
	BSP_thread(
		nominal_pipe_size = 3/4,
		length = 0.5,
		internal  = false);
}

// ----------------------------------------------------------------------------
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
		printify_bottom = false,
		bore_diameter = -1,
		exact_clearance = true
)
{
    thread (
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
    thread (
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
    thread (
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
    thread (
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

	thread (
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

	thread (
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


// ----------------------------------------------------------------------------
//
module channel_thread(
		thread_diameter = 8,
		pitch = 1,
		turn_angle = 360,
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
	if(turn_angle > 360)
	{
		echo("*** Warning !!! ***");
		echo("channel_thread(): a channel thread cannot be larger than 360 degree!");
	}
	if(turn_angle*n_starts > 360)
	{
		echo("*** Warning !!! ***");
		echo("channel_thread(): a channel thread cannot have turn_angle*n_starts larger than 360 degree!");
	}
	if(outer_flat_length >= length)
	{
		echo("*** Warning !!! ***");
		echo("channel_thread(): tip of thread (outer_flat_length) cannot be larger than height!");
	}
	
	thread (
			pitch = pitch,
			length = length,
			upper_angle = thread_angles[0], 
			lower_angle = thread_angles[1],
			outer_flat_length = outer_flat_length,
			major_radius = thread_diameter / 2,
			minor_radius = thread_diameter / 2 - 5/8 * cos(thread_angles[1]) * pitch,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = clearance,
			backlash = backlash,
			printify_top = false,
			printify_bottom = false,
			multiple_turns_over_height = false,
			turn_angle = turn_angle,
			bore_diameter = bore_diameter,
			exact_clearance = exact_clearance
			);
}

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// OpenSCAD version 2014.03 and also 2014.QX (only for tan) created
// incorrect values for "even" angles.
function accurateCos(x) = 
(x%30)!=0?cos(x): (x<360?simpleCos(x):simpleCos(x-floor(x/360)*360));
function simpleCos(x) =
x==0 ? 1 :
x==60 ? 0.5 :
x==90 ? 0 :
x==120 ? -0.5 :
x==180 ? -1 :
x==240 ? -0.5 :
x==270 ? 0 :
x==300 ? 0.5 :
x==360 ? 1 : cos(x);
// TEST
/*
echo("cos");
for (angle = [0:1:361]) 
{
	if((cos(angle)-accurateCos(angle)) != 0)	
		echo(angle," ", cos(angle)-accurateCos(angle));
}
*/
function accurateSin(x) = 
(x%15)!=0?sin(x): (x<360?simpleSin(x):simpleSin(x-floor(x/360)*360));
function simpleSin(x) =
x==0 ? 0 :
x==30 ? 0.5 :
x==90 ? 1 :
x==150 ? 0.5 :
x==180 ? 0 :
x==210 ? -0.5 :
x==270 ? -1 :
x==330 ? -0.5 :
x==360 ? 0 : sin(x);
//TEST
/*
echo("sin");
for (angle = [0:1:361]) 
{
	if((sin(angle)-accurateSin(angle)) != 0)	
		echo(angle," ", sin(angle)-accurateSin(angle));
}
*/

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


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// internal - true = clearances for internal thread (e.g., a nut).
//            false = clearances for external thread (e.g., a bolt).
//            (Internal threads should be "cut out" from a solid using
//            difference()).
// n_starts - Number of thread starts (e.g., DNA, a "double helix," has
//            n_starts=2).  See wikipedia Screw_thread.
module thread(
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
	multiple_turns_over_height = true,
	turn_angle = 360, //used for channel_threads
	bore_diameter = -1, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = true
)
{

	//internal channel threads have on top a backlash too
	len = internal && !multiple_turns_over_height ? length+backlash/2 : length;
	
	// ------------------------------------------------------------------
	// Segments and its angle, number of turns
	// ------------------------------------------------------------------
	n_turns = floor(len/pitch); // Number of turns needed.
	n_segments_tmp =  $fn > 0 ? 
						$fn :
						max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));
	seg_angle = multiple_turns_over_height ?
					360/n_segments_tmp  //std threads
					: turn_angle/(round(turn_angle/(360/n_segments_tmp))) ; //channel threads
	n_segments = multiple_turns_over_height ?
					n_segments_tmp  //std threads
					: turn_angle/seg_angle; //channel threads
	
	taper_per_segment = accurateTan(taper_angle)*len   //total taper
						/ (len/pitch) / n_segments;
	
	min_openscad_fs = 0.01;



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
	
	function calc_left_flat(h_tooth) = h_tooth / accurateTan (left_angle);
	function calc_right_flat(h_tooth) = h_tooth / accurateTan (right_angle);
	function param_tooth_height() = major_radius - minor_radius;
	function calc_tooth_height()=
				calc_left_flat(param_tooth_height())+calc_right_flat(param_tooth_height())
					< pitch ?
				( // Standard case, full tooth height possible
					param_tooth_height()
				)
				: ( // Angle of flanks don't allow full tooth height.
					// Flats under angles cover at least whole pitch
					// so tooth height is being reduced.
					pitch/(accurateTan(upper_angle)+accurateTan(lower_angle)) 
				);

	function calc_upper_flat() =
		outer_flat_length + 
		(internal ?
			  (tan_left*clearance >= backlash/2 ?
					- (tan_left*clearance-backlash/2)
					: 
					+ (backlash/2-tan_left*clearance)
			  )
			+ (tan_right*clearance >= backlash/2 ?
					- (tan_right*clearance-backlash/2)
					: 
					+ (backlash/2-tan_right*clearance)
			  )
		:0);
	function max_upper_flat(leftflat, rightflat) =
				pitch-leftflat-rightflat > 0 ?
					(pitch-leftflat-rightflat > calc_upper_flat() ?
						calc_upper_flat()
						: pitch-leftflat-rightflat)
					:0;

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
	// Radius / Diameter
	// ------------------------------------------------------------------
	//
	// Clearance:
	// The outer walls of the created threads are not circular. They consist
	// of polyhydrons with planar front rectangles. Because the corners of 
	// these polyhedrons are located at major radius (x,y), the middle of these
	// rectangles is a little bit inside of major_radius. So, with low $fn
	// this difference gets larger and may be even larger than the clearance itself
	// but also for big $fn values clearance is being reduced. If one prints a 
	// thread/nut without addressing this they may not turn.
	function bow_to_face_distance(radius, angle) = 
				radius*(1-accurateCos(angle/2));
	function clearance_radius(radius, internal_thread) =
				(internal_thread ? 
					( exact_clearance ?
						radius+clearance
						:(radius+clearance)/accurateCos(seg_angle/2)
					)
					: radius);

	major_rad = clearance_radius(major_radius, internal);
	minor_rad = major_rad-tooth_height;

	diameter = major_rad*2;
	is_hollow = bore_diameter > 0;
	hollow_rad = is_hollow ? bore_diameter/2 : minor_rad/2;


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
/*	echo("**** polyhedron thread ******");
	echo("internal", internal);
	echo("length", len);
	echo("pitch", pitch);
	echo("right_handed", right_handed);
	echo("tooth_height param", param_tooth_height());
	echo("tooth_height calc", tooth_height);
	echo("n_segments",n_segments);
	echo("turn_angle",turn_angle);
	echo("seg_angle*n_segments",turn_angle);
	echo("seg_angle",seg_angle);
	echo("$fa (slice step angle)",$fa);
	echo("$fn (slice step angle)",$fn);
	echo("outer_flat_length", outer_flat_length);
	echo("left_angle", left_angle);	
	echo("left_flat", left_flat);
	echo("upper flat param", outer_flat_length);
	echo("upper flat calc", upper_flat);
	echo("right_angle", right_angle);
	echo("right_flat", right_flat);
	echo("lower_flat", lower_flat);
	echo("tooth_flat", tooth_flat);
	echo("total_flats", tooth_flat + lower_flat, "diff", pitch-(tooth_flat + lower_flat));
	echo("clearance", clearance);
	echo("backlash", backlash);
	echo("major_radius",major_radius);
	echo("major_rad",major_rad);
	echo("minor_radius",minor_radius);
	echo("minor_rad",minor_rad);
	echo("taper_angle",taper_angle);	
	echo("taper_per_segment",taper_per_segment);
	echo("poly_rot_slice_offset()",poly_rot_slice_offset());
	echo("internal_play_offset",internal_play_offset());
	echo("******************************");*/
	// ----------------------------------------------------------------------------
	// polyhedron axial orientation
	// ------------------------------------------------------------------
	function poly_rotation(i) =
		(right_handed?1:-1)*(i*seg_angle);
	// The facettes of OpenSCAD's cylinder() command start at x=0,y=radius.
	// But so far, the created polygon starts at x=-1/2 facette,y=-radius.
	// So, the cylinder's facettes are not aligned with the thread ones,
	// creating holes in the thread behind the lower flat of the thread.
	// channel threads: Because segment angle for channel threads is not equal
	// to $fn, for channel threads this corrects only the start.
	function poly_rot_offset() = 
		90 + ((right_handed?1:-1)*(seg_angle/2));
	//Correction angle so at x=0 is left_flat/angle
	//Not needed so far. Two problems:
	//Internal and external threads have different lower_flats and therefore
	//a different turn angle. ==> no nice thread differences.
	//With parameter "exact_clearance" a problem occurs. 
	function poly_rot_slice_offset() =
			((multiple_turns_over_height ? 1 : 0)
			 *(right_handed?1:-1)
			 *(360/n_starts/pitch* (lower_flat/2)));
	//total poly rotation
	function poly_rotation_total(i)	=
			poly_rotation(i) + poly_rot_offset() ;//+ poly_rot_slice_offset();

	// An internal thread must be rotated/moved because the calculation starts	
	// at base corner of left flat which is not exactly over base
	// corner of bolt (clearance and backlash)
	// Combination of small backlash and large clearance gives 
	// positive numbers, large backlash and small clearance negative ones.
	// This is not necessary for channel_threads.
	function internal_play_offset() = 
		internal && multiple_turns_over_height ?
				0/*
				( 	tan_right*clearance >= backlash/2 ?
					-tan_right*clearance-backlash/2
					: 
					-(backlash/2-tan_right*clearance)
				)*/
			: 0;
	
	// z offset includes length added to upper_flat on left angle side
	function channel_thread_z_offset() = 
				((pitch >= len)? -pitch : 0)
				+ (internal ?
			  		(tan_left*clearance >= backlash/2 ?
						- (tan_left*clearance-backlash/2)
						: (backlash/2-tan_left*clearance))
					:0);

	// ----------------------------------------------------------------------------
	// Create the thread 
	// ------------------------------------------------------------------
	intersection() 
	{
		union()
		{
			if(multiple_turns_over_height)
			{
				// Start one below z = 0.  Gives an extra turn at each end.
				for (i=[-1*n_starts : n_turns]) {
					translate([0, 0, i*pitch]) 
						thread_turn(n_segments, i+n_starts+1);
				}
			}
			else
			{
				for (i=[0:n_starts-1]) 
				{
					rotate([0,0,i*360/n_starts])
					{
						translate([0, 0, channel_thread_z_offset()]) 
						{
							channel_thread_turn(n_segments);
							// an internal (cutout) channel thread needs a thread above
							// to create enough space to insert the male thread.
							if(internal)
							{
								translate([0, 0, pitch+lower_flat/2]) 
									thread_turn(n_segments,1);
							}
						}
					}
				}
			}
		}

		// Cut to length.
		translate([0, 0, len/2]) 
			cube([diameter*1.1, diameter*1.1, len], center=true);
	}

	// ----------------------------------------------------------------------------
	module thread_turn(n_segments, current_turn)
	{
		for (i=[0 : n_segments-1]) 
		{
			rotate([0, 0, poly_rotation_total(i)]) 
			{
				translate([0, 0, i*n_starts*pitch*(seg_angle/360)
									+ internal_play_offset()
							]) 
				{
					if(taper_per_segment == 0)
						thread_polyhedron(seg_angle);
					else
						thread_polyhedron_tapered(seg_angle, current_turn*n_segments + i);
				}
			}
		}
	} // end module metric_thread_turn()

	// ----------------------------------------------------------------------------
	module channel_thread_turn(n_segments)
	{
		current_seg_z_offset = 0;
		for (i=[0 : n_segments-1]) 
		{
			rotate([0, 0, poly_rotation_total(i)]) 
			{
				assign(current_seg_z_offset = i*pitch*(seg_angle/360)) 
				{
					translate([0, 0, current_seg_z_offset ]) 
						channel_thread_polyhedron(seg_angle, current_seg_z_offset, i);
         		}
      		}
		}
	} // end module metric_thread_turn()


		// ------------------------------------------------------------
		function slice_faces() =
	
		/*    
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
		is_hollow ?
		[
		//A side of slice
		[16,19,11,3,0,8], // accepts it as "planar"
		[3,7,4,0],
		// B side of slice
		[18,17,9,1,2,10], // accepts it as "planar"
		[1,5,6,2],		
		// top of slice	
		[19,18,10],[19,10,11],	
		// bottom of slice
		[16,8,9],[16,9,17],
		//top inner of thread
		[2,3,11,10],
		//top flank of thread
		[7,3,2], [2,6,7],
		// tip/outer of thread	 	
		[4,7,6,5],
		//bottom flank of thread	
		[0,4,5], [5,1,0], 					
		//bottom inner of thread
		//[8,0,1], [1,9,8],
		[0,1,9,8],
		//hollow inner
		[17,19,16],[17,18,19]
		]
		:
		[
		//A side of slice
		[12,13,19,16],// accepts it as "planar"
		[16,19,11,3,0,8], // accepts it as "planar"
		[3,7,4,0],
		// B side of slice
		[13,12,17,18], // accepts it as "planar"
		[17,9,1,2,10,18], // accepts it as "planar"
		[1,5,6,2],		
		// top of slice	
		[13,18,19],[19,18,10],[19,10,11],	
		// bottom of slice
		[12,16,17],[16,8,9],[16,9,17],
		//top inner of thread
		[2,3,11,10],
		//top flank of thread
		[7,3,2], [2,6,7],
		// tip/outer of thread	 	
		[4,7,6,5],
		//bottom flank of thread	
		[0,4,5], [5,1,0], 					
		//bottom inner of thread
		//[8,0,1], [1,9,8],
		[0,1,9,8],	
		];

	// ------------------------------------------------------------
	module thread_polyhedron_tapered(seg_angle, current_segment)
	{
		current_major_rad = major_rad-current_segment*taper_per_segment;
		current_minor_rad = minor_rad-current_segment*taper_per_segment;

		x_incr_outer = 2*(accurateSin(seg_angle/2)*current_major_rad)+0.001; //overlapping needed 
		x_incr_inner = 2*(accurateSin(seg_angle/2)*current_minor_rad)+0.001; //for simple=yes
		x_incr_hollow = 2*(accurateSin(seg_angle/2)*hollow_rad)+0.001; //for simple=yes

		z_incr = n_starts * pitch * seg_angle/360;
		z_incr_this_side = z_incr * (right_handed ? 0 : 1);
		z_incr_back_side = z_incr * (right_handed ? 1 : 0);
		z_thread_lower = lower_flat >= 0.002 ? lower_flat/2 : 0.001;
		z_tip_lower = z_thread_lower + right_flat;
		z_tip_inner_middle = z_tip_lower + upper_flat/2;
		z_tip_upper = (z_tip_lower + upper_flat <= pitch-0.002) ?
							z_tip_lower + upper_flat
							: pitch-0.002; 
		z_thread_upper = (z_tip_upper + left_flat <= pitch-0.001) ?
							z_tip_upper + left_flat
							: pitch-0.001; 				
		//to prevent errors if top slice barely touches bottom of next segement
		//afterone full turn.
		z_thread_top_simple_yes = 0.001;
		// radius correction to place polyhedron correctly
		// hint: polyhedron front ist straight, thread circle not
		major_rad_p = current_major_rad - bow_to_face_distance(current_major_rad, seg_angle);
		minor_rad_p = current_minor_rad - bow_to_face_distance(current_minor_rad, seg_angle);
		hollow_rad_p = hollow_rad - bow_to_face_distance(hollow_rad, seg_angle);

		/*echo(" *** polyhedron ***");
		echo("lower_flat",lower_flat);
		echo("upper_flat",lower_flat);
		echo("lower_flat",lower_flat);

		echo("z_thread_lower",z_thread_lower);
		echo("z_tip_lower",z_tip_lower);
		echo("z_tip_inner_middle",z_tip_inner_middle);
		echo("z_tip_upper",z_tip_upper);
		echo("z_thread_upper",z_thread_upper);

		echo("x_incr_hollow",x_incr_hollow);
		echo("hollow_rad",hollow_rad);
		echo("hollow_rad_p",hollow_rad_p);
		
		echo(slice_points());
		echo(slice_faces());*/

		polyhedron(	points = slice_points(),faces = slice_faces());
		
		// ------------------------------------------------------------
		function slice_points() = 
			[
			//tooth
			[-x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_this_side],    // [0]
			[x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_back_side],     // [1]
			[x_incr_inner/2, -minor_rad_p, z_thread_upper  + z_incr_back_side],  // [2]
			[-x_incr_inner/2, -minor_rad_p, z_thread_upper + z_incr_this_side],        // [3]
			[-x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_this_side], // [4]
			[x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_back_side],  // [5]
			[x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_back_side], // [6]
			[-x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_this_side],// [7]

			//slice
			[-x_incr_inner/2,-minor_rad_p,0 + z_incr_this_side], // [8]
			[x_incr_inner/2,-minor_rad_p,0 + z_incr_back_side], // [9]
			[x_incr_inner/2,-minor_rad_p, pitch + z_incr_back_side + z_thread_top_simple_yes], // [10]
			[-x_incr_inner/2,-minor_rad_p, pitch + z_incr_this_side + z_thread_top_simple_yes], // [11]
			[0,0,0], // [12]
			[0,0,pitch + z_thread_top_simple_yes], // [13]
			[-x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_this_side], // [14]
			[+x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_back_side], // [15]
			// inner shaft points
			// bottom
			[-x_incr_hollow/2,-hollow_rad_p,0 + z_incr_this_side], // [16]
			[x_incr_hollow/2,-hollow_rad_p,0 + z_incr_back_side], // [17]
			// top
			[x_incr_hollow/2,-hollow_rad_p, pitch + z_incr_back_side + z_thread_top_simple_yes], // [18]
			[-x_incr_hollow/2,-hollow_rad_p, pitch + z_incr_this_side + z_thread_top_simple_yes], // [19]
		];


	} // end module thread_polyhedron_tapered()

	// ------------------------------------------------------------
	module thread_polyhedron(seg_angle)
	{
		x_incr_outer = 2*(accurateSin(seg_angle/2)*major_rad)+0.001; //overlapping needed 
		x_incr_inner = 2*(accurateSin(seg_angle/2)*minor_rad)+0.001; //for simple=yes
		x_incr_hollow = 2*(accurateSin(seg_angle/2)*hollow_rad)+0.001; //for simple=yes

		z_incr = n_starts * pitch * seg_angle/360;
		z_incr_this_side = z_incr * (right_handed ? 0 : 1);
		z_incr_back_side = z_incr * (right_handed ? 1 : 0);
		z_thread_lower = lower_flat >= 0.002 ? lower_flat/2 : 0.001;
		z_tip_lower = z_thread_lower + right_flat;
		z_tip_inner_middle = z_tip_lower + upper_flat/2;
		z_tip_upper = (z_tip_lower + upper_flat <= pitch-0.002) ?
							z_tip_lower + upper_flat
							: pitch-0.002; 
		z_thread_upper = (z_tip_upper + left_flat <= pitch-0.001) ?
							z_tip_upper + left_flat
							: pitch-0.001; 				
		//to prevent errors if top slice barely touches bottom of next segement
		//afterone full turn.
		z_thread_top_simple_yes = 0.001;
		// radius correction to place polyhedron correctly
		// hint: polyhedron front ist straight, thread circle not
		major_rad_p = major_rad - bow_to_face_distance(major_rad, seg_angle);
		minor_rad_p = minor_rad - bow_to_face_distance(minor_rad, seg_angle);
		hollow_rad_p = hollow_rad - bow_to_face_distance(hollow_rad, seg_angle);

		/*echo(" *** polyhedron ***");
		echo("lower_flat",lower_flat);
		echo("upper_flat",lower_flat);
		echo("lower_flat",lower_flat);

		echo("z_thread_lower",z_thread_lower);
		echo("z_tip_lower",z_tip_lower);
		echo("z_tip_inner_middle",z_tip_inner_middle);
		echo("z_tip_upper",z_tip_upper);
		echo("z_thread_upper",z_thread_upper);

		echo("x_incr_hollow",x_incr_hollow);
		echo("hollow_rad",hollow_rad);
		echo("hollow_rad_p",hollow_rad_p);
		
		echo(slice_points());
		echo(slice_faces());*/

		polyhedron(	points = slice_points(),faces = slice_faces());
		
		// ------------------------------------------------------------
		function slice_points() = 
			[
			//tooth
			[-x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_this_side],    // [0]
			[x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_back_side],     // [1]
			[x_incr_inner/2, -minor_rad_p, z_thread_upper  + z_incr_back_side],  // [2]
			[-x_incr_inner/2, -minor_rad_p, z_thread_upper + z_incr_this_side],        // [3]
			[-x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_this_side], // [4]
			[x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_back_side],  // [5]
			[x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_back_side], // [6]
			[-x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_this_side],// [7]

			//slice
			[-x_incr_inner/2,-minor_rad_p,0 + z_incr_this_side], // [8]
			[x_incr_inner/2,-minor_rad_p,0 + z_incr_back_side], // [9]
			[x_incr_inner/2,-minor_rad_p, pitch + z_incr_back_side + z_thread_top_simple_yes], // [10]
			[-x_incr_inner/2,-minor_rad_p, pitch + z_incr_this_side + z_thread_top_simple_yes], // [11]
			[0,0,0], // [12]
			[0,0,pitch + z_thread_top_simple_yes], // [13]
			[-x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_this_side], // [14]
			[+x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_back_side], // [15]
			// inner shaft points
			// bottom
			[-x_incr_hollow/2,-hollow_rad_p,0 + z_incr_this_side], // [16]
			[x_incr_hollow/2,-hollow_rad_p,0 + z_incr_back_side], // [17]
			// top
			[x_incr_hollow/2,-hollow_rad_p, pitch + z_incr_back_side + z_thread_top_simple_yes], // [18]
			[-x_incr_hollow/2,-hollow_rad_p, pitch + z_incr_this_side + z_thread_top_simple_yes], // [19]
		];


	} // end module thread_polyhedron()

	// ------------------------------------------------------------
	module channel_thread_polyhedron(seg_angle)
	{
		x_incr_outer = 2*(accurateSin(seg_angle/2)*major_rad)+0.001; //overlapping needed 
		x_incr_inner = 2*(accurateSin(seg_angle/2)*minor_rad)+0.001; //for simple=yes
		x_incr_hollow = 2*(accurateSin(seg_angle/2)*hollow_rad)+0.001; //for simple=yes

		function top_z() = internal ? pitch + len : pitch;
		z_incr =  pitch * seg_angle/360;

		z_incr_this_side = z_incr * (right_handed ? 0 : 1);
		z_incr_back_side = z_incr * (right_handed ? 1 : 0);
		// a channel thread has all lower_flat really low... :-)
		z_thread_lower = lower_flat >= 0.002 ? lower_flat-0.001 : 0.001;
		z_tip_lower = z_thread_lower + right_flat;
		z_tip_inner_middle = z_tip_lower + upper_flat/2;
		z_tip_upper = (z_tip_lower + upper_flat <= pitch-0.002) ?
							z_tip_lower + upper_flat
							: pitch-0.002; 
		z_thread_upper = (z_tip_upper + left_flat <= pitch-0.001) ?
							z_tip_upper + left_flat
							: pitch-0.001; 				
		//to prevent errors if top slice barely touches bottom of next segement
		//afterone full turn.
		z_thread_top_simple_yes = 0.001;

		// radius correction to place polyhedron correctly
		// hint: polyhedron front ist straight, thread circle not
		major_rad_p = major_rad - bow_to_face_distance(major_rad, seg_angle);
		minor_rad_p = minor_rad - bow_to_face_distance(minor_rad, seg_angle);	
		hollow_rad_p = hollow_rad - bow_to_face_distance(hollow_rad, seg_angle);
	
		/*echo(" *** polyhedron ***");
		echo("seg_angle",seg_angle);
		echo("lower_flat",lower_flat);
		echo("upper_flat",upper_flat);
		echo("internal_play_offset()",internal_play_offset());
		echo("z_thread_upper",z_thread_upper);
		echo("z_incr_this_side",z_incr_this_side);
		echo("z_incr_back_side",z_incr_back_side);
		echo("z_thread_lower",z_thread_lower);
		echo("z_tip_lower",z_tip_lower);
		echo("z_tip_inner_middle",z_tip_inner_middle);
		echo("z_tip_upper",z_tip_upper);
		echo("z_thread_upper",z_thread_upper);
		echo("x_incr_hollow",x_incr_hollow);
		echo("hollow_rad",hollow_rad);
		echo("hollow_rad_p",hollow_rad_p);
		echo(flat_slice_points());
		echo(slice_faces());*/
		polyhedron(	points = flat_slice_points(),faces = slice_faces());
		
		// ------------------------------------------------------------
		function flat_slice_points() = 
			[
			//tooth
			[-x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_this_side],    // [0]
			[x_incr_inner/2, -minor_rad_p, z_thread_lower + z_incr_back_side],     // [1]
			[x_incr_inner/2, -minor_rad_p, z_thread_upper  + z_incr_back_side],  // [2]
			[-x_incr_inner/2, -minor_rad_p, z_thread_upper + z_incr_this_side],        // [3]
			[-x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_this_side], // [4]
			[x_incr_outer/2, -major_rad_p, z_tip_lower + z_incr_back_side],  // [5]
			[x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_back_side], // [6]
			[-x_incr_outer/2, -major_rad_p, z_tip_upper + z_incr_this_side],// [7]

			//slice
			[-x_incr_inner/2,-minor_rad_p,-len], // [8]
			[x_incr_inner/2,-minor_rad_p,-len], // [9]
			[x_incr_inner/2,-minor_rad_p, top_z() + z_incr_back_side + z_thread_top_simple_yes], // [10]
			[-x_incr_inner/2,-minor_rad_p, top_z() + z_incr_this_side + z_thread_top_simple_yes], // [11]
			[0,0,-len], // [12]
			[0,0,top_z() + z_thread_top_simple_yes], // [13]
			[-x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_this_side], // [14]
			[+x_incr_inner/2,-minor_rad_p, z_tip_inner_middle + z_incr_back_side], // [15]

			// inner shaft points
			// bottom
			[-x_incr_hollow/2,-hollow_rad_p,-len], // [16]
			[x_incr_hollow/2,-hollow_rad_p,-len], // [17]
			// top
			[x_incr_hollow/2,-hollow_rad_p, top_z() + z_incr_back_side + z_thread_top_simple_yes], // [18]
			[-x_incr_hollow/2,-hollow_rad_p, top_z() + z_incr_this_side + z_thread_top_simple_yes], // [19]
		];

	} // end module channel_thread_polyhedron(seg_angle)
} // end module thread()
