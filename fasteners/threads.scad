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

//$fn=25;
//test_threads();
//test_channel_threads();
//test_slot_tabs();

//test_metric_right();
//test_metric_left();
//test_square_thread();
//test_hollow_thread();
//test_threads();
//test_internal_difference_metric();
//test_buttress();
//test_leftright_buttress(5);
//test_internal_difference_buttress();
//test_internal_difference_buttress_lefthanded();
//test_channel_thread(8);
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
    english_thread(1/4, pitch=20, length=1/4);

}

module test_channel_threads()
{
	// channel thread
	translate ([10, 0, 0])
         test_channel_thread(8);
	
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





module test_metric_right ($fa=5, $fs=0.1)
{
	//Case: Pitch larger than length
	metric_thread( diameter = 20,
		pitch = 4, 
		length = 3, 
		internal=false, 
		n_starts=3, 
		right_handed=true,
		clearance = 0.1, 
		backlash=0.4,
		printify_top = false
	);
}
module test_metric_left()
{
	metric_thread(8, 
				pitch=1.5, 
				internal=false, 
				length=3, 
				right_handed=false);
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
	buttress_thread(diameter=20, pitch=4, length=4.3, 
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

module test_channel_thread(dia = 10)
{
	angles = [0,50];
	length = 15;
	backlash = 0.13;
	outer_flat_length = 0.5;
	clearance = 0.17;
	backlash = 0.1;
	starts = 1;

	translate([0,0,len+5])
	channel_thread(
		thread_diameter = dia,
		pitch = 2,
		turn_angle = 360,
		length = length,
		internal = false,
		n_starts = starts,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = dia-4
		);

	color("LemonChiffon")
	translate([0,0,-5])
	channel_thread(
		thread_diameter = dia,
		pitch = 2,
		turn_angle = 360,
		length = length,
		internal = true,
		n_starts = starts,
		thread_angles = angles,
		outer_flat_length = outer_flat_length,
		right_handed = true,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = dia-4
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
	for (n=[1 : 3])
	{
	translate([0,0,len+5])
	channel_thread(
		thread_diameter = getdia(n),
		pitch = 1,
		turn_angle = 360,
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
		turn_angle = 360,
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
	angles = [50,50]; //second angle needs to be zero for test case.
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
		turn_angle = 360,
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
	dia = 8;
	//angles= [30,30];
	angles= [10,50];  //[upper, lower]
	backlash = 0.3;
	clearance = 0.3;
	difference()
	{
		channel_thread(
			thread_diameter = dia,
			pitch = 1,
			turn_angle = 360,
			length = 2,
			internal = true,
			n_starts = 1,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = true,
			clearance = clearance,
			backlash = backlash, 
			bore_diameter = 5);
		channel_thread(
			thread_diameter = dia,
			pitch = 1,
			turn_angle = 360,
			length = 2,
			internal = false,
			n_starts = 1,
			thread_angles = angles,
			outer_flat_length = 0.2,
			right_handed = true,
			clearance = clearance,
			backlash = backlash,
			bore_diameter = 5);
		translate([-2.5,-2.5,0]) cube([5,5,5], center=true);
	}
}


module test_NPT()
{
	US_national_pipe_thread(
		nominal_pipe_size = 3/4,
		length = 0.5, //inches
		internal  = false);
}

module test_BSP()
{
	BSP_thread(
		nominal_pipe_size = 3/4,
		length = 0.5, //inches
		internal  = false);
}

// ----------------------------------------------------------------------------
// Definitions
// ----------------------------------------------------------------------------

	// netfabb recognises/marks a triangle as "degenerated" if it is too small
	// This value has been evaluated by try and error by exporting a STL to netfabb.
	// Values:
	// 0.0015 was necessary for a channel thread to suppress degenerated message 
	//        in netfabb.
	// 0.001 seems to be the trigger level in netfab. ==> See Settings in Netfab.
	// THe message in Netfabb about degenerated faces can be reduced by
	// changing the treshold to 0.0001.
	function nefabb_degenerated_min() = 0.0011; 
	// OpenScad unfortunately works with CSG. So coincident faces (exact match) 
	// do not work. Objects must always overlap.
	csg_min = nefabb_degenerated_min();///2;

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
    thread (
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
			minor_radius = metric_minor_radius(thread_diameter, pitch),
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
// As of OpenScad 2015.03 sin() and cos() deliver correct values

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
	m_thread (
			pitch = pitch,
			length = length,
			upper_angle = upper_angle,
			lower_angle = lower_angle,
			outer_flat_length = outer_flat_length,
			major_radius = major_radius,
			minor_radius = minor_radius,
			internal = internal,
			n_starts = n_starts,
			right_handed = right_handed,
			clearance = (internal ? clearance : 0),
			backlash = (internal ? backlash : 0),
			printify_top = printify_top,
			printify_bottom = printify_bottom,
			multiple_turns_over_height = multiple_turns_over_height,
			turn_angle = turn_angle,
			bore_diameter = bore_diameter,
			taper_angle = taper_angle,
			exact_clearance = exact_clearance
			);
}

module m_thread(
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

	// ------------------------------------------------------------------
	// Segments and its angle, number of turns
	// ------------------------------------------------------------------
	n_turns = floor(length/pitch); // Number of turns needed.
	n_segments_tmp =  $fn > 0 ? 
						$fn :
						max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));
	seg_angle = multiple_turns_over_height ?
					360/n_segments_tmp  //std threads
					: turn_angle/(round(turn_angle/(360/n_segments_tmp))) ; //channel threads
	n_segments = multiple_turns_over_height ?
					n_segments_tmp  //std threads
					: turn_angle/seg_angle; //channel threads
	
	taper_per_segment = accurateTan(taper_angle)*length   //total taper
						/ (length/pitch) / n_segments;
	
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
	function get_backlash() =
				get_upper_flat(backlash) >= 0 ? backlash 
				: backlash + (-1)*get_upper_flat(backlash)
				;
	function max_upper_flat(leftflat, rightflat) =
				pitch-leftflat-rightflat > 0 ?
					(pitch-leftflat-rightflat > calc_upper_flat() ?
						calc_upper_flat()
						: pitch-leftflat-rightflat)
					:0
				;

	backlash = get_backlash();
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
	len_backlash_compensated = !internal || multiple_turns_over_height ? length
			: length + backlash/2 
			 ;

	// Clearance:
	// The outer walls of the created threads are not circular. They consist
	// of polyhydrons with planar front rectangles. Because the corners of 
	// these polyhedrons are located at major radius (x,y), the middle of these
	// rectangles is a little bit inside of major_radius. So, with low $fn
	// this difference gets larger and may be even larger than the clearance itself
	// but also for big $fn values clearance is being reduced. If one prints a 
	// thread/nut without addressing this they may not turn.
	function bow_to_face_distance(radius, angle) = 
				radius*(1-cos(angle/2));
	function clearance_radius(radius, internal_thread) =
				(internal_thread ? 
					( exact_clearance ?
						radius+clearance
						:(radius+clearance)/cos(seg_angle/2)
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
	echo("length", len_backlash_compensated);
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
	echo("major_rad",major_rad);
	echo("minor_radius",minor_radius);
	echo("minor_rad",minor_rad);
	echo("is_hollow", is_hollow);
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

	// ------------------------------------------------------------------
	// Create the thread 
	// ------------------------------------------------------------------
	if(multiple_turns_over_height)
	{
		// normal threads with multiple turns
		if(true)
		{
					
			intersection() 
			{
				make_thread();
				// Cut to length.
				translate([0, 0, (len_backlash_compensated-0.1)/2]) //0.001 : "simple=no" for square threads
					cube([diameter*1.1, diameter*1.1, len_backlash_compensated-0.1], center=true);
			}
		}
		else
		{
			make_thread();
		}
			
	}
	else
	{
		
		//Channel threads
		intersection() 
		{
			make_channel_thread();
			// nefabb_degenerated_min() is needed because in netfabb a "hole" and
			// degenerated faces would be detected
			translate([0, 0, -(len_backlash_compensated/2)+nefabb_degenerated_min()])
				cube([diameter*1.1, diameter*1.1, len_backlash_compensated+2*nefabb_degenerated_min()], center=true);
		}
		/* DEBUG
		#translate([0, diameter*1.1/2+0.05, -len_backlash_compensated/2]) 
				cube([diameter*1.1, diameter*1.1, len_backlash_compensated], center=true);
		#translate([diameter*1.1/2+0.05,0 , -len_backlash_compensated/2]) 
				cube([diameter*1.1, diameter*1.1, len_backlash_compensated], center=true);
		#translate([-backlash/4, -diameter*1.1/2+2 , -len_backlash_compensated+backlash/4])
				cube([backlash/2, backlash/2, backlash/2], center=true);
		*/
	}

	// ------------------------------------------------------------
	// ------------------------------------------------------------------
	// Thread modules
	// ------------------------------------------------------------------
	module make_thread()
	{
		// Start one below z = 0.  Gives an extra turn at each end.
		for (i_thread_turn=[-1*n_starts : n_turns]) 
		{
			for (i_turn_seg=[0 : n_segments-1])//n_segments-1]) 
			{
				thread_polyhedron(seg_angle, 
										i_turn_seg, 
										i_thread_turn*n_segments + i_turn_seg,
										i_thread_turn,
										poly_rotation_total(i_turn_seg),
										false,
										false);
			}
		}
	}//end module make_thread()
	// ------------------------------------------------------------
	// ------------------------------------------------------------
	// ------------------------------------------------------------------
	// Channel Thread modules
	// ------------------------------------------------------------------
	module make_channel_thread()
	{
		open_top = true;	// so far, internal channel threads have always an open top
							// to let insert the channel thread to a certain depth without
							// a thread over the whole depth

		i_thread_turn = 0; // starts at zero for channel_thread_z_offset()

		translate([0, 0, channel_thread_z_offset()]) 
		{
			for (i_start=[0:n_starts-1]) 
			{
				for (i_turn_seg=[0 : n_segments/n_starts-1]) 
				{
					thread_polyhedron(seg_angle=seg_angle, 
												i_turn_seg=i_turn_seg, 
												i_thread_seg = i_turn_seg,
												i_thread_turn=i_thread_turn, 
												poly_rotation_total=poly_rotation_total(i_turn_seg)
																	+i_start*360/n_starts,
												open_top=false, //the first turn has a closed top
												is_bottom_turn=true);
				}
				// an internal (cutout) channel thread needs a thread above
				// to create enough space to insert the male thread.
				if(internal)
				{
					for (i_turn_seg=[0 : n_segments/n_starts-1]) 
					{
						thread_polyhedron(seg_angle=seg_angle, 
													i_turn_seg=i_turn_seg, 
													i_thread_seg=1*n_segments + i_turn_seg  ,
													i_thread_turn=i_thread_turn+1,
													poly_rotation_total=poly_rotation_total(i_turn_seg)
																		+i_start*360/n_starts,
													open_top=open_top,
													is_bottom_turn=false);
					}
				}
			}//end starts for loop
		}
	}//end module make_channel_thread()


	// ------------------------------------------------------------
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
		//A side of slice, multi point polygons did not worked
		[19,11,3], [19,3,14],[3,7,14],[14,7,4], 
		[19,14,16],[16,14,0],[0,14,4],[16,0,8],
		// B side of slice, multi point polygons did not worked
		[18,2,10], [18,15,2],[6,2,15],[15,5,6], 
		[18,17,15],[17,1,15],[1,5,15],[17,9,1],	
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
		[0,1,9,8],
		//hollow inner
		[17,19,16],[17,18,19]
		]
		:
		[
		//A side of slice, multi point polygons did not worked
		[19,11,3], [19,3,14],[3,7,14],[14,7,4], 
		[19,14,16],[16,14,0],[0,14,4],[16,0,8],
		[12,13,19,16],// accepts it as "planar"
		// B side of slice, multi point polygons did not worked
		[18,2,10], [18,15,2],[6,2,15],[15,5,6], 
		[18,17,15],[17,1,15],[1,5,15],[17,9,1],	
		[13,12,17,18], // accepts it as "planar"
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

/* 
	// More complex polyhedron to get a smoother slope on
	// bottom of channel thread (still Beta)

		is_hollow ?
		[]
		:
		[
		
		//center
		//slice center, this side
		[13,19,16],[13,16,12],
		//slice center ,back side
		[18,21,20],[18,20,17],
		//slice center close
		[20,21,13],[13,12,20],
		//slice center bottom
		[17,20,12],	[16,17,12],
		//slice center top
		[19,21,18],[19,13,21],


		];
*/



	// ------------------------------------------------------------
	// ------------------------------------------------------------
	// functions for polyhedron point calculations
	// To prevent errors if top slice barely touches bottom of next segment
	// afterone full turn.
	function z_thread_top_simple_yes() = 0.000;

	function current_major_rad(i_thread_seg, taper_per_segment) = 
				major_rad-i_thread_seg*taper_per_segment;
	function current_minor_rad(i_thread_seg, taper_per_segment) = 
				minor_rad-i_thread_seg*taper_per_segment;

	function x_incr_outer(seg_angle, i_thread_seg, taper_per_segment) = 
				2*(sin(seg_angle/2)
					*current_major_rad(i_thread_seg, taper_per_segment));
	function x_incr_inner(seg_angle, i_thread_seg, taper_per_segment) = 
				2*(sin(seg_angle/2)
					*current_minor_rad(i_thread_seg, taper_per_segment));
	function x_incr_bottom(seg_angle, i_thread_seg, taper_per_segment) = 
					x_incr_inner(seg_angle, i_thread_seg, taper_per_segment);
	function x_incr_top(open_top, seg_angle, i_thread_seg, taper_per_segment) = 
					open_top ? 
						x_incr_outer(seg_angle, i_thread_seg, taper_per_segment) 
						: x_incr_inner(seg_angle, i_thread_seg, taper_per_segment);
	function x_incr_hollow(seg_angle) = 
				2*(sin(seg_angle/2)
					*hollow_rad);

	// radius correction to place polyhedron correctly
	// hint: polyhedron front ist straight, thread circle not
	function major_rad_p(seg_angle, i_thread_seg, taper_per_segment) =
			current_major_rad(i_thread_seg, taper_per_segment)
			 - bow_to_face_distance(current_major_rad(i_thread_seg, taper_per_segment), seg_angle);
	function minor_rad_p(seg_angle, i_thread_seg, taper_per_segment) =
			current_minor_rad(i_thread_seg, taper_per_segment)
			 - bow_to_face_distance(current_minor_rad(i_thread_seg, taper_per_segment), seg_angle);
	//bottom/top rads: allow flat thread to be inserted 
	function bottom_minor_rad_p(seg_angle, i_thread_seg, taper_per_segment) = 
					minor_rad_p(seg_angle, i_thread_seg, taper_per_segment);
	function top_minor_rad_p(open_top, seg_angle, i_thread_seg, taper_per_segment) =
					 open_top ? 
							major_rad_p(seg_angle, i_thread_seg, taper_per_segment) 
							: minor_rad_p(seg_angle, i_thread_seg, taper_per_segment);
	function hollow_rad_p(seg_angle) =
			hollow_rad - bow_to_face_distance(hollow_rad, seg_angle);

	function z_incr(seg_angle) = n_starts * pitch * seg_angle/360;
	function z_incr_this_side(seg_angle) = z_incr(seg_angle) * (right_handed ? 0 : 1);
	function z_incr_back_side(seg_angle) = z_incr(seg_angle) * (right_handed ? 1 : 0);

	function z_thread_lower() = 
					multiple_turns_over_height ?
						(lower_flat > nefabb_degenerated_min() ? 
								lower_flat : nefabb_degenerated_min())
						: nefabb_degenerated_min() // a channel thread starts with left flank at bottom
						;
	function z_tip_lower() = z_thread_lower() + left_flat;
	function z_tip_inner_middle() = z_tip_lower() + upper_flat/2;
	function z_tip_upper() = (z_tip_lower() + upper_flat <= pitch-nefabb_degenerated_min()) ?
							z_tip_lower() + upper_flat
							: pitch-nefabb_degenerated_min(); 
	function z_thread_upper(open_top) = open_top ?
								z_len_or_pitch()
								:((z_tip_upper() + right_flat <= pitch) ?
									z_tip_upper() + right_flat
									: pitch);
	function z_len_or_pitch(open_top) =
					multiple_turns_over_height ? pitch  //normal thread work only with pitch	
						: (open_top && internal ? len_backlash_compensated : pitch) ;  //channel threads need full height
	function z_len_offest(i_thread_turn) = //channel threads need the above thread much higher
					multiple_turns_over_height ? 0
						:( ((!internal && i_thread_turn == 1)
							|| (internal && i_thread_turn == 2) )? len_backlash_compensated : 0);
				;
 	function z_offset(seg_angle, i_turn_seg, i_thread_turn, 3D_vect) = [
			3D_vect.x,
			3D_vect.y,
			3D_vect.z + i_turn_seg*n_starts*pitch*(seg_angle/360) //offset per segment
						+ internal_play_offset()
						+ i_thread_turn*pitch 	
						+ z_len_offest(i_thread_turn)  // for channel threads the next/above must 
														 // higher than "len_backlash_compensated" and will be cut by intersection 
			];
	function bottom_z_space(is_bottom_turn) = is_bottom_turn ? channel_thread_bottom_spacer() : 0;
	function z_thread_bottom(is_bottom_turn) = -bottom_z_space(is_bottom_turn);

	function rotate_xy(poly_rotation_total, 3D_vect) = [
			3D_vect.x*cos(poly_rotation_total)-3D_vect.y*sin(poly_rotation_total),
			3D_vect.x*sin(poly_rotation_total)+3D_vect.y*cos(poly_rotation_total),
			3D_vect.z
			];



	function slice_offset(slice_csged,
									seg_angle, 
									i_turn_seg, 
									i_thread_seg,
									i_thread_turn,
									poly_rotation_total) = 
			[
			//tooth
			// [0]
			z_offset(seg_angle = seg_angle, i_turn_seg = i_turn_seg,i_thread_turn= i_thread_turn,
			3D_vect = rotate_xy(poly_rotation_total,
			slice_csged[0] )),
			// [1]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[1] )),
			// [2]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[2] )),
			// [3]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[3] )),
			// [4]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[4] )),
			// [5]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[5] )),
			// [6]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[6] )),
			// [7]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[7] )),

			//slice
			// [8]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[8] )),
			// [9]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[9] )),
			// [10]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[10] )),
			// [11]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[11] )),
			// [12]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[12] )),
			// [13]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[13] )),
			// [14]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[14] )),
			// [15]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[15] )),

			// inner shaft points
			// [16]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[16] )),
			// [17]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[17] )),
			// [18]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[18] )),
			// [19]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[19] )),
			// [20]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[20] )),
			// [21]
			z_offset(seg_angle, i_turn_seg, i_thread_turn,
			rotate_xy(poly_rotation_total,
			slice_csged[21] ))
			];

	function overlap(amount) = internal ? amount : 0;
	// OpenScad works with CSG. So coincident faces (exact match) 
	// do not work. Objects must always overlap.
	function slice_csg_ed(slice, overlap) =
		[
			[slice[0].x-overlap(overlap),slice[0].y,slice[0].z],
			[slice[1].x+overlap(overlap),slice[1].y,slice[1].z],
			[slice[2].x+overlap(overlap),slice[2].y,slice[2].z],
			[slice[3].x-overlap(overlap),slice[3].y,slice[3].z],
			[slice[4].x-overlap(overlap),slice[4].y,slice[4].z],
			[slice[5].x+overlap(overlap),slice[5].y,slice[5].z],
			[slice[6].x+overlap(overlap),slice[6].y,slice[6].z],
			[slice[7].x-overlap(overlap),slice[7].y,slice[7].z],
			[slice[8].x-overlap(overlap),slice[8].y,slice[8].z-overlap(overlap)],
			[slice[9].x+overlap(overlap),slice[9].y,slice[9].z-overlap(overlap)],
			[slice[10].x+overlap(overlap),slice[10].y,slice[10].z+overlap(overlap)],
			[slice[11].x-overlap(overlap),slice[11].y,slice[11].z+overlap(overlap)],
			[slice[12].x-overlap(overlap),slice[12].y+overlap(csg_min),slice[12].z-overlap(overlap)],
			[slice[13].x-overlap(overlap),slice[13].y+overlap(csg_min),slice[13].z+overlap(overlap)],
			[slice[14].x-overlap(overlap),slice[14].y,slice[14].z],
			[slice[15].x+overlap(overlap),slice[15].y,slice[15].z],
			[slice[16].x-overlap(overlap),slice[16].y,slice[16].z-overlap(overlap)],
			[slice[17].x+overlap(overlap),slice[17].y,slice[17].z-overlap(overlap)],
			[slice[18].x+overlap(overlap),slice[18].y,slice[18].z+overlap(overlap)],
			[slice[19].x-overlap(overlap),slice[19].y,slice[19].z+overlap(overlap)],
			[slice[20].x+overlap(overlap),slice[20].y+overlap(overlap),slice[20].z-overlap(overlap)],
			[slice[21].x+overlap(overlap),slice[21].y+overlap(overlap),slice[21].z+overlap(overlap)]
		];

	// ------------------------------------------------------------
	module thread_polyhedron(seg_angle, 
								i_turn_seg, 
								i_thread_seg,
								i_thread_turn, 
								poly_rotation_total,
								open_top,
								is_bottom_turn)
	{
		if(false)
		{
			if((i_turn_seg==0 || false)
				&&
				(i_thread_turn==1 || false))
			{
				echo(" *** polyhedron ***");
				echo("lower_flat",lower_flat);
				echo("upper_flat",upper_flat);

				echo("z_thread_lower",z_thread_lower());
				echo("z_tip_lower",z_tip_lower());	
				echo("z_tip_inner_middle",z_tip_inner_middle());
				echo("z_tip_upper",z_tip_upper());
				echo("z_thread_upper",z_thread_upper(open_top));
				echo("z_len_or_pitch()",z_len_or_pitch());
				echo("z_incr_this_side",z_incr_this_side(seg_angle));
				echo("z_incr_back_side",z_incr_back_side(seg_angle));

				echo("x_incr_hollow",x_incr_hollow(seg_angle));
				echo("hollow_rad",hollow_rad);
				echo("hollow_rad_p",hollow_rad_p(seg_angle));

				echo("seg_angle",seg_angle);
				echo("poly_rotation_total",poly_rotation_total);
			}
			if((i_turn_seg==0 || false)
				&&
				(i_thread_turn==1 || false))
			{
				echo("slice_raw", slice);
				echo("slice_wanted", slice_wanted);
				echo("slice_next", slice_next);
				echo("slice_above", slice_above);
				echo("slice_next_above", slice_next_above);
				echo("slice_combined", slice_combined(slice_wanted,	
														slice_above, 
														slice_next, 
														slice_next_above));
				echo(slice_faces());

			}
		}

		slice = slice_csg_ed(slice_points_raw(seg_angle, 
									i_turn_seg, 
									i_thread_seg,
									i_thread_turn,
									poly_rotation_total,
									open_top,
									is_bottom_turn)
								,csg_min);

		slice_wanted = slice_offset(slice,
										seg_angle, 
										i_turn_seg, 
										i_thread_seg,
										i_thread_turn,
										poly_rotation_total);



		slice_above = slice_offset(slice_csged=slice,
										seg_angle=seg_angle, 
										i_turn_seg=i_turn_seg, 
										i_thread_seg=i_thread_seg+n_segments,
										i_thread_turn=(i_thread_turn+1),
										poly_rotation_total=poly_rotation_total);
		slice_next = slice_offset(slice,
										seg_angle, 
										i_turn_seg+1, 
										i_thread_seg+1,
										i_thread_turn,
										poly_rotation_total+seg_angle*(right_handed?1:-1));
		slice_next_above = slice_offset(slice,
										seg_angle, 
										i_turn_seg+1, 
										i_thread_seg+1+n_segments,
										i_thread_turn+1,
										poly_rotation_total+seg_angle*(right_handed?1:-1));
		// For accurate polygons without holes and degenerated faces
		// as netfabb reported it, it is necessary to use the calculated
		// points of precalculated slices.
		// For example, the top most points of a slice must match with
		// the slice above it (one turn ahead). So we use the bottom points
		// of the slice above ours and use them as our top points.
		if(internal)
		{
			//Because OpenScad uses CSG a subtract (internal) must be made 
			//with overlapping polygons or slim planes will be left over
			//where coincident faces exist.
			polyhedron(	points = slice_wanted,
						faces = slice_faces());
		}
		else
		{
			//We can use a coincident faces (exact polygons) for additive actions
			polyhedron(	points = slice_combined(slice_wanted,	
												slice_above, 
												slice_next, 
												slice_next_above),
						faces = slice_faces());
		}

		function slice_combined(slice_wanted,	slice_above, slice_next, slice_next_above) =
					right_handed ?
			 			[
						slice_wanted[0], // [0]
						slice_next[0], // [1]
						slice_next[3], // [2]
						slice_wanted[3], // [3]
						slice_wanted[4], // [4]
						slice_next[4], // [5]
						slice_next[7], // [6]
						slice_wanted[7], // [7]
						slice_wanted[8], // [8]
						slice_next[8], // [9]
						slice_next_above[8], // [10]
						slice_above[8], // [11]
						slice_wanted[12], // [12]
						slice_above[12], // [13]
						slice_wanted[14], // [14]
						slice_next[14], // [15]
						slice_wanted[16], // [16]
						slice_next[16], // [17]
						slice_next_above[16], // [18]
						slice_above[16], // [19]
						slice_next[12], // [20]  ????
						slice_next_above[12], // [21]
						]
					:
					[
						slice_next[1], // [0]
						slice_wanted[1], // [1]
						slice_wanted[2], // [2]
						slice_next[2], // [3]
						slice_next[5], // [4]
						slice_wanted[5], // [5]
						slice_wanted[6], // [6]
						slice_next[6], // [7]
						slice_next[9], // [8]
						slice_wanted[9], // [9]
						slice_above[9], // [10]
						slice_next_above[9], // [11]
						slice_next[20], // [12]
						slice_next_above[20], // [13]
						slice_next[15], // [14]
						slice_wanted[15], // [15]
						slice_next[17], // [16]
						slice_wanted[17], // [17]
						slice_above[17], // [18]
						slice_next_above[17], // [19]
						slice_wanted[20], // [20]
						slice_above[20], // [21]
						]
					;
	} // end module thread_polyhedron()

	// ------------------------------------------------------------
	function slice_points_raw(seg_angle, 
							i_turn_seg, 
							i_thread_seg,
							i_thread_turn,
							poly_rotation_total,
							open_top,
							is_bottom_turn) = 
			[
			//tooth
			// [0]
			[-x_incr_bottom(seg_angle, i_thread_seg, taper_per_segment)/2, 
				-bottom_minor_rad_p(seg_angle, i_thread_seg, taper_per_segment), 
				z_thread_lower() + z_incr_this_side(seg_angle)],
			// [1]
			[x_incr_bottom(seg_angle, i_thread_seg, taper_per_segment)/2, 
				-bottom_minor_rad_p(seg_angle, i_thread_seg, taper_per_segment), 
				z_thread_lower() + z_incr_back_side(seg_angle)],
			// [2]
			[x_incr_top(open_top, seg_angle, i_thread_seg, taper_per_segment)/2, 
				-top_minor_rad_p(open_top, seg_angle, i_thread_seg, taper_per_segment), 
				z_thread_upper(open_top)  + z_incr_back_side(seg_angle)],
			// [3]
			[-x_incr_top(open_top, seg_angle, i_thread_seg, taper_per_segment)/2,
				-top_minor_rad_p(open_top, seg_angle, i_thread_seg, taper_per_segment),
				z_thread_upper(open_top) + z_incr_this_side(seg_angle)],
			// [4]
			[-x_incr_outer(seg_angle, i_thread_seg, taper_per_segment)/2,
				-major_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_lower() + z_incr_this_side(seg_angle)],
			// [5]
			[x_incr_outer(seg_angle, i_thread_seg, taper_per_segment)/2,
				-major_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_lower() + z_incr_back_side(seg_angle)],
			// [6]
			[x_incr_outer(seg_angle, i_thread_seg, taper_per_segment)/2,
				-major_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_upper() + z_incr_back_side(seg_angle)],
			// [7]
			[-x_incr_outer(seg_angle, i_thread_seg, taper_per_segment)/2,
				-major_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_upper() + z_incr_this_side(seg_angle)],
			//slice
			// [8]
			[-x_incr_bottom(seg_angle, i_thread_seg, taper_per_segment)/2,
				-bottom_minor_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_thread_bottom(is_bottom_turn) + z_incr_this_side(seg_angle)],
			// [9]
			[x_incr_bottom(seg_angle, i_thread_seg, taper_per_segment)/2,
				-bottom_minor_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_thread_bottom(is_bottom_turn) + z_incr_back_side(seg_angle)],
			// [10]
			[x_incr_top(open_top, seg_angle, i_thread_seg, taper_per_segment)/2,
				-top_minor_rad_p(open_top, seg_angle, i_thread_seg, taper_per_segment),
				z_len_or_pitch(open_top) + z_incr_back_side(seg_angle)],
			// [11]
			[-x_incr_top(open_top, seg_angle, i_thread_seg, taper_per_segment)/2,
				-top_minor_rad_p(open_top, seg_angle, i_thread_seg, taper_per_segment),
				z_len_or_pitch(open_top) + z_incr_this_side(seg_angle)],
			// [12]
			[0,
				0,
				z_thread_bottom(is_bottom_turn) + z_incr_this_side(seg_angle)],
			// [13]
			[0,
				0,
				z_len_or_pitch(open_top) + z_incr_this_side(seg_angle)],
			// [14]
			[-x_incr_inner(seg_angle, i_thread_seg, taper_per_segment)/2,
				-minor_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_inner_middle() + z_incr_this_side(seg_angle)],
			// [15]
			[x_incr_inner(seg_angle, i_thread_seg, taper_per_segment)/2,
				-minor_rad_p(seg_angle, i_thread_seg, taper_per_segment),
				z_tip_inner_middle() + z_incr_back_side(seg_angle)],
			// inner shaft points
			// bottom
			// [16]
			[-x_incr_hollow(seg_angle)/2, 
				-hollow_rad_p(seg_angle), 
				z_thread_bottom(is_bottom_turn) + z_incr_this_side(seg_angle)],
			// [17]
			[x_incr_hollow(seg_angle)/2,
				-hollow_rad_p(seg_angle),
				z_thread_bottom(is_bottom_turn) + z_incr_back_side(seg_angle)],
			// top
			// [18]
			[x_incr_hollow(seg_angle)/2,
				-hollow_rad_p(seg_angle),
				z_len_or_pitch(open_top) + z_incr_back_side(seg_angle)],
			// [19]
			[-x_incr_hollow(seg_angle)/2,
				-hollow_rad_p(seg_angle),
				z_len_or_pitch(open_top) + z_incr_this_side(seg_angle)],
			// [20]
			[0,
				0,
				z_thread_bottom(is_bottom_turn) + z_incr_back_side(seg_angle)],
			// [21]
			[0,
				0,
				z_len_or_pitch(open_top) + z_incr_back_side(seg_angle)]
		];

} // end module thread()


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

