

 
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
 * - For channel threads, ending and starting front faces are not exactly flat.
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
 * Version 4.4  2017-04-16  indazoo
 *                          - better debug output code
 *                          - removed error creating "debug feature"
 * Version 4.3  2016-11-27  indazoo
 *                          - separate files for test,threads and helix
 * Version 4.2	2016-11-27  indazoo
 *                          - Because of CGAL errors for high resolutions the top and bottom are now
 *                            fully triangulated. No more polygons with more than 3 points.
 *                          - Added some integrity tests for the faces (must be manually activated)
 *                          - So far passed all tests, also on high resolution.
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


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Tolerances / Acurracy 
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
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

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// internal - true = clearances for internal thread (e.g., a nut).
//            false = clearances for external thread (e.g., a bolt).
//            (Internal threads should be "cut out" from a solid using
//            difference()).
// n_starts - Number of thread starts (e.g., DNA, a "double helix," has
//            n_starts=2).  See wikipedia Screw_thread.
module helix(
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
	// Create the helix 
	// ------------------------------------------------------------------
	make_helix_polyhedron(turns = n_turns,
										thread_starts_flat = !is_channel_thread,
										open_top = is_channel_thread,
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
	
	//---------------------------------------------------------
	// Helper functions
	// --------------------------------------------------------
	
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
							
	function sagitta_to_radius_extension(sagitta_diff, angle) =
								//sagitta_diff*cos(90-angle/2) ;
								sagitta_diff/sin(90-angle/2);
	function chord_sagitta(radius, angle) = radius - chord_apothem(radius, angle);
	function chord_apothem(radius, angle) = radius * cos(angle/2);		

	function bow_to_face_distance_scale(radius, angle, screw_radius, internal) =
						radius_extension(radius, angle, screw_radius, internal) == 0 ?
							1 : get_scale(radius, radius_extension(radius, angle, screw_radius, internal));

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
	
} // end module helix()



//-----------------------------------------------------------
//-----------------------------------------------------------
// Helix Polyhedron calculation
//-----------------------------------------------------------
//-----------------------------------------------------------
module make_helix_polyhedron(
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
					[[hollow_rad,0,tooths_profile[0].z]], //hollow_rad is not zero, see helix(), so no conflict with first point.
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

	//The cross points are being calculated as where a line between two points crosses a given z value.
	//Because one or both of these points can be very near of the z-value the cross point algorithm calculates
	//multiple cross points with the same coordinates for the cross point. This results in illegal polygons 
	//on bottom/top of the thread because a polygon with the same points is not liked by CGAL.
	cross_point_tolerance = length/10000;			
	
	aligned_3Dvec_segments_points = 
									[
										for (seg_plane_index = [0:1:get_n_segment_planes()-1])
											get_3Dvec_seg_plane_point_polygons_aligned(seg_plane_index, cross_point_tolerance)
									];
	
	/*
	//DEBUG
	pre_calc_seg_index=0;	
	echo("aligned_3Dvec_segments_points(pre_calc_seg_index)",aligned_3Dvec_segments_points[pre_calc_seg_index], len(aligned_3Dvec_segments_points[pre_calc_seg_index]), len(get_3Dvec_tooths_polygon(pre_calc_seg_index)));
	*/
	
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
							// Segment line crosses z.
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
			quicksort_cross_point(unsorted_cross_points)
		:
			//unsorted		
			unsorted_cross_points
			;
	
	//Data Structure of cross points:
	//[point index in final 3d Vec points, 
	//	[[current_seg,next_seg], [first_point_index, second_point_index], [cross_point], angle, cross_point_type_...]
	//]	
	// Sample:
	// z_top_cross_point         :  [     [[0], [26, 28], [1.47977, 0, 1.1], 0, 2, [1, 52]]
	// indexed_z_top_cross_point : [[468, [[0], [26, 28], [1.47977, 0, 1.1], 0, 2, [1, 52]]]

	top_first_result_cross_point_index = calc_total_array_elements_nxn(0,aligned_3Dvec_segments_points,0); //since array indexes start at zero, the length is just right
	z_top_cross_points = sort_cross_points(find_z_cross_points(top_z(),aligned_3Dvec_segments_points)); 
	indexed_z_top_cross_points = get_indexed_array(top_first_result_cross_point_index, z_top_cross_points) ;
	bottom_first_result_cross_point_index = top_first_result_cross_point_index + len(z_top_cross_points);
	z_bottom_cross_points = sort_cross_points(find_z_cross_points(bottom_z(),aligned_3Dvec_segments_points));	
	//echo("z_bottom_cross_points");//,z_bottom_cross_points);
	//for(pt = z_bottom_cross_points)
	//	echo(pt);
	indexed_z_bottom_cross_points = get_indexed_array(bottom_first_result_cross_point_index, z_bottom_cross_points) ;

	//DEBUG
	// Use show_z_plane_cyl = true; and the same height as the thread's length.
	// Use "Show Edges" in OpenScad
	// Limit output to one segment (see code in function) : current_seg_index != 1 ? [] :
	/*
	echo("***************************************");
	echo("top_first_result_cross_point_index",top_first_result_cross_point_index);
	echo("bottom_first_result_cross_point_index",bottom_first_result_cross_point_index);
	echo("z_top_cross_points",len(z_top_cross_points),z_top_cross_points);
	echo("indexed_z_top_cross_points",len(indexed_z_top_cross_points),indexed_z_top_cross_points);	
	echo("***************************************");
	echo("indexed_z_bottom_cross_points",len(indexed_z_bottom_cross_points));
	for(pt=	indexed_z_bottom_cross_points)
		echo(pt);
	//Show cross points as 2D polygon
	cross_points_2D = [for(cp = z_top_cross_points) [cp[2].x, cp[2].y]];
	cross_points_2D_paths = [[for(i = [0:1:len(z_top_cross_points)-1]) i]];
	translate([0,0,length+0.55])
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
						
	function calc_total_array_elements_nxn(index, array_points_nxn, sum)	=
			index > (len(array_points_nxn)-1) ?
				//break recursion
				sum
			:
				calc_total_array_elements_nxn(index+1, array_points_nxn, sum + len(array_points_nxn[index]))
		;		

						
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
									orientate_length_points_for_tolerance(tol,
										orientate_all_points_for_rotation(seg_plane_index,  
											orientate_profile_tooths_for_taper(
												orientate_all_points_in_z(seg_plane_index,
													tooths_polygon
													) //orientate_all_points_in_z
												) //taper
											)// orientate_all_points_for_rotation
									)// orientate_length_points_for_tolerance
						;
	
		
	function orientate_length_points_for_tolerance(tol, tooths_polygon) = [
							let(cross_point_tolerance = length/10000)
							for( point = tooths_polygon)
								point.z < bottom_z()-cross_point_tolerance ? point
									: point.z < bottom_z()+cross_point_tolerance ? [point.x, point.y, bottom_z()]
										: point.z < top_z()-cross_point_tolerance ? point
											: point.z < top_z()+cross_point_tolerance ? [point.x, point.y, top_z()]
												: point
							//	(point.z < top_z()-tol || point.z > top_z()+tol) ? point : [point.x, point.y, top_z()]//length+tol]  
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
									
	function z_offset_v3(z_offset, vect_3D) = 
		[vect_3D.x,
		vect_3D.y,
		vect_3D.z + z_offset
		];	

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

	show_all_facets = false;  //must be in code, do not comment
	//DEBUG			
	/*
	show_z_plane_cyl = false;
	if(show_z_plane_cyl) 
		translate([0,0,length])cylinder(d=2*major_rad+1,h=0.01);
	*/
	

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

		
	function rotate_xy(angle, vect_3D) = [
		vect_3D.x*cos(angle)-vect_3D.y*sin(angle),
		vect_3D.x*sin(angle)+vect_3D.y*cos(angle),
		vect_3D.z
		];
		
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

	function correct_floating_point_errors(points_3Dvec) =
			[
				for(pt = points_3Dvec)
					pt//correct_3D_floating_point_error(0, pt)
			];
	
	function correct_3D_floating_point_error(target_value, vec_3D) =
	[cut_accurracy(correct_floating_point_error_value(target_value, vec_3D.x)),
		cut_accurracy(correct_floating_point_error_value(target_value, vec_3D.y)),
		cut_accurracy(correct_floating_point_error_value(target_value, vec_3D.z))
	];			
				
	function cut_accurracy(value) = 
				round(value * 100)/100;
				
	max_tol = 1/pow(2,40); //checked in exported STL.
	function correct_floating_point_error_value(target_value, fuzzy_value) = 
		fuzzy_value <=  target_value + max_tol && fuzzy_value >= target_value-max_tol ? target_value : fuzzy_value;
	
				
	points_3Dvec = 
				correct_floating_point_errors(
					concat(
						[
						for(poly_gon	= aligned_3Dvec_segments_points) 
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
	minor_rads = [for(plane_i = [0:1:len(aligned_3Dvec_segments_points)-1])
							[
							let(points = aligned_3Dvec_segments_points[plane_i])
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
				// Top Thread Front Completion Facets 
				//***********************************************
				[
				for(pts=
				[
					for(current_cp_index = [0:1:len(indexed_z_top_cross_points)-1])
						let(next_cp_index = array_get_circular_index(indexed_z_top_cross_points, current_cp_index + 1),
								next_next_cp_index = array_get_circular_index(indexed_z_bottom_cross_points, next_cp_index + 1),
								previous_cp_index = array_get_circular_index(indexed_z_bottom_cross_points, next_cp_index -1),
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
				//****************************************************************************
				// Top Thread Cover Facets
				// The cross points are an irregular shaped line of points
				// describing the shape of the thread at z.
				// All cross points of a segment result in one ore more triangles but
				// these triangles do not "close" the top because the center points 
				// are not included.
				//****************************************************************************
				1==2 ? [] :
				[
					let(tria_faces_top = get_tria_faces(indexed_z_top_cross_points, true))
					for(seg_plane_index	= [ 0 : 1: get_n_segment_planes()-1]) 
						let (facets = triangulate_polygon(tria_faces_top[seg_plane_index], true))
						for(facet = facets)
							facet
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
						let(next_cp_index = array_get_circular_index(indexed_z_bottom_cross_points, current_cp_index + 1),
								next_next_cp_index = array_get_circular_index(indexed_z_bottom_cross_points, next_cp_index + 1),
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
					1==2 ? [] :
					[
					//***************************************************
					// Bottom Thread Cover Facets for Standard Threads
					//***************************************************
					let(tria_faces = get_tria_faces(indexed_z_bottom_cross_points, false))
					for (seg_plane_index	= [ 0 : 1: get_n_segment_planes()-1]) 
						let (facets = triangulate_polygon(tria_faces[seg_plane_index], false))
						for(facet = facets)
							invert_order(facet) //needed because we look from "below".
					]
				); 
	
						
	show_thread_faces_result = false;
						
	
	//  **********************************************************************
	//  Triangulation Helper Functions	
	//  **********************************************************************
					
	function get_tria_faces(indexed_cross_points, is_for_top) =
						[
						for (seg_plane_index	= [ 0 : 1: get_n_segment_planes()-1]) 
							let (next_seg_plane_index = get_adj_seg_plane_index(seg_plane_index+1),
									current_faces_pts = pre_calc_faces_points[seg_plane_index],
									next_faces_pts  = pre_calc_faces_points[next_seg_plane_index],
									current_seg_crpts = get_seg_cross_point_indexes(seg_plane_index, indexed_cross_points),
									next_seg_crpts = get_seg_cross_point_indexes(next_seg_plane_index, indexed_cross_points),
									hollowrad_pts = is_for_top ?
									                  [next_faces_pts[len(next_faces_pts)-n_center_points()],current_faces_pts[len(current_faces_pts)-n_center_points()]]
									                : [next_faces_pts[1],current_faces_pts[1]],
									//Square Threads (and others):
									//If the radius jumps from outer radius to minor radius, then a steep angle
									//results and all points (see below) are in one line to hollow rad point.
									//To create a correct polygon which can be connected to the next segment polygon 
									//we need to add an additional point of the next segment polygon, because the next 
									//segment polygon cannot create a polygon with three points in a line.
									valid_current_crpts = facet_pts_on_line(current_seg_crpts[0], current_seg_crpts[1], 
									                                         is_for_top ? current_faces_pts[len(current_faces_pts)-n_center_points()] : current_faces_pts[1])
									                      && face_pts_outwards(current_seg_crpts[0], current_seg_crpts[1]) ?
									                      	array_remove_at(0,current_seg_crpts) : current_seg_crpts,
									valid_next_crpts = facet_pts_on_line(next_seg_crpts[0],next_seg_crpts[1],hollowrad_pts[0]) 
									                   && face_pts_outwards(next_seg_crpts[0], next_seg_crpts[1]) ?
									                   		next_seg_crpts[1] : [],
									tria_pts = concat(valid_current_crpts, next_seg_crpts[0], valid_next_crpts, hollowrad_pts),

									tria_pts_ordered = right_handed ? tria_pts : invert_order(tria_pts) //clockwise pts for triangulation
								)
							tria_pts_ordered
					]
						;
	// DEBUG
	/*
	echo("*********************************");
	faces_to_tria = get_tria_faces(indexed_z_top_cross_points, true);
	first_tri_seg_index = -1;
	y_poly_offset=right_handed ? -10 : -15;
	//poly_pts1 = get_2d_of_faces(faces_to_tria[len(faces_to_tria)-1]);	
	//poly1_face_pts = faces_to_tria[len(faces_to_tria)-1];
	poly1_face_pts = faces_to_tria[get_adj_seg_plane_index(first_tri_seg_index)];
	poly_pts1 = get_2d_of_faces(poly1_face_pts);
	//poly_pts1_test_case_1 =   [[-1.45641, -0.358973], [-1.45641, 0.358973], [-3.88377, 0.957263], [-3.88377, 0.829628], [-3.88377, 1.56541e-014], [-3.51966, -0.0897434], [-3.15556, 1.26565e-014], [-3.15556, -0.674072], [-3.15556, -0.777776]];
	//poly_pts1 =  [[1.32818, 0.97085], [1.5, 0], [4, 0], [3.60291, 1.61104], [3.54182, 1.85889]];
	echo("poly_pts1",poly_pts1);	
	translate([-15,y_poly_offset,0]) polygon(poly_pts1);
	triangulated_faces1 = triangulate_polygon(poly1_face_pts, true);
	for(tria = triangulated_faces1)
		translate([-10,y_poly_offset,0]) polygon(get_2d_of_faces(tria));
	//Method 2:
	tria_facets = [];
	tria_struct = [poly1_face_pts, tria_facets, [], []];
	tria_struct_result = triangulate_polygon_iterations(
															tria_struct = tria_struct, 
															iteration_index = 0,              //iteration_index
															max_iterations = array_len_savely(tria_struct[0])-1,  //max_iterations
															is_for_top = true
															);	
	echo("triangulation of ", poly1_face_pts);
	echo("  Rest points", tria_struct_result[0] );
	echo("  triangles", tria_struct_result[1]);
	for(logEntry = tria_struct_result[2])
		echo("  log: ", logEntry);
		echo("iteration_index",tria_struct_result[3]);
	
	poly2_face_pts = faces_to_tria[get_adj_seg_plane_index(first_tri_seg_index+1)];
	poly_pts2 = get_2d_of_faces(poly2_face_pts);
	//poly_pts2 = get_2d_of_faces(faces_to_tria[0]);		
	//poly_pts2 =  [[4,-0.1],[4,0], [3.45, 0], [3.18342, 0.633481], [3.17898, 0.675713], [1.29115, 0.274443], [1.32, 0]];
	//poly_pts2 = [[4, 0], [3.25, 0.2], [3.18342, 0.633481], [3.17898, 0.675713], [2.99527, 1.24112], [1.29115, 0.274443], [1.32, 0]];
	echo("poly_pts2",poly_pts2);
	translate([-15,y_poly_offset,0]) polygon(poly_pts2);
	triangulated_faces2 = triangulate_polygon(poly2_face_pts, true);
	echo("triangulated faces 2", triangulated_faces2);
	for(tria = triangulated_faces2)
		translate([-10,y_poly_offset,0]) polygon(get_2d_of_faces(tria));

	*/

	function get_2d_of_faces(faces) =
						[
							for(face = faces)
								[points_3Dvec[face].x,points_3Dvec[face].y]
						];
						
	function triangulate_polygon(face_points, is_for_top)=
		// Design Notes:
		// - The cross points can be very irregular, in a manner that many or one small spike appears. Then
		//   the spike point may not be directly reachable from the hollow rad points. 
		// - If a line from one cross point to the next point points outwards. A triangle [previous, current,next] is not correct.
		// - The recursive algo simplifies the cross point triangles until only two cross points are unused.
		// - If the last two crosspoints point outwards then this needs special considerations...
		let(
				tria_struct = //[face_points, []],
										triangulate_polygon_iterations(
															[face_points,[],[],[]], 
															0,              //iteration_index
															array_len_savely(face_points)-1,  //max_iterations
															is_for_top
															), 
				all_facets = 1==2 ? [face_points] //Old planar polygon
												:concat([tria_struct[0]], tria_struct[1]==undef ? [] :tria_struct[1])
				)
		[
			for(facet = all_facets)
						invert_order(facet)
		]
	;
	

			
	function facet_pts_on_line(facet_pt1, facet_pt2, facet_pt3) =
		pts_on_line(points_3Dvec[facet_pt1], points_3Dvec[facet_pt2], points_3Dvec[facet_pt3]);
		
	function pts_on_line(pt1,pt2,pt3) =
		let(line_vector = [pt2.x-pt1.x,pt2.y-pt1.y,pt2.z-pt1.z],
				k= (line_vector.x!=0 ? ((pt3.x-pt1.x)/line_vector.x)
						: line_vector.y!=0 ? ((pt3.y-pt1.y)/line_vector.y)
							: line_vector.z!=0 ? ((pt3.z-pt1.z)/line_vector.z)
								: 0)
					,
				extended_pt = pt1+[k*line_vector.x,k*line_vector.y,k*line_vector.z],
				diff_near_zero = extended_pt-pt3,
				diff = correct_3D_floating_point_error(0,diff_near_zero)
		)
		diff.x==0 && diff.y==0 && diff.z==0
		;

	//DEBUG
	/*	
	lt_1_xy = [3,3,0];
	lt_2_xy = [3,5,0];
	lt_3_xy = [5,7,0];
	lt_4_xy = [4,9,0];
	echo("1 ", is_left(lt_3_xy, lt_2_xy, lt_1_xy, true));
	echo("2 ", is_left(lt_2_xy, lt_3_xy, lt_4_xy, true));
	*/
	function is_left(pt1, pt2, pt3, is_for_top) = // true if c is left of a--->b 
  	is_for_top ? (pt2.x - pt1.x)*(pt3.y - pt1.y) - (pt2.y - pt1.y)*(pt3.x - pt1.x) > 0 
		           : (pt2.x - pt1.x)*(pt3.y - pt1.y) - (pt2.y - pt1.y)*(pt3.x - pt1.x) < 0 
	;

	function triangulate_polygon_iterations(tria_struct, 
																					iteration_index, 
																					max_iterations,
																					is_for_top)=
		let(current_triangulation = triangulate_polygon_to_two_points(tria_struct, 
																							0, array_len_savely(tria_struct[0])-1, 
																							0, iteration_index,
																							is_for_top)
				)
		iteration_index >= max_iterations   //break recursion after maximum of iterations
			|| len(current_triangulation[0])<=3 ? //nothing to triangulate
				[current_triangulation[0],
					current_triangulation[1],
					current_triangulation[2], 
					concat(current_triangulation[3], iteration_index)]
		:
			triangulate_polygon_iterations(current_triangulation, 
																			iteration_index+1, 
																			max_iterations,
																			is_for_top)
	;

	function is_valid(tria_struct, pt1_i, pt1_xy, pt2_i, pt2_xy, pt3_i, pt3_xy, points, len_points, is_for_top) = // false, if not ear or any other point of S inside ear 
  	is_left(pt1_xy, pt2_xy, pt3_xy, true)? // ear? 
      let (	rest_pt_index = array_get_circular_index_len(len_points, pt3_i+1),
						start_i = rest_pt_index,
						end_i = rest_pt_index + len_points -3 -1, 
					res = [for(i=[start_i:end_i]) // test all other points 
      	            if(is_left(pt1_xy, pt2_xy, get_xy(i, points, len_points), true) && 
                       is_left(pt2_xy, pt3_xy, get_xy(i, points, len_points), true) && 
                       is_left(pt3_xy, pt1_xy, get_xy(i, points, len_points), true)) 
										1]
					) 
      res==[]  //is ear and no other point inside triangle
		: false //is not ear
	;
										
	function get_xy(index, points, len_points) =
		points_3Dvec[points[array_get_circular_index_len(len_points, index)]];
			
	function triangulate_polygon_to_two_points(tria_struct, 
																							pt_counter, max_pt_count, //to have a "hard" recursion break value. "pt_index" will be modified.
																							pt_index, iteration_index,
																							is_for_top) =
		let(points = tria_struct[0],
				found_facets = tria_struct[1] != undef ? tria_struct[1] : [],
				len_points = array_len_savely(points),
				first_pt_i = pt_index,
				second_pt_i = array_get_circular_index_len(len_points, pt_index+1),
				third_pt_i = array_get_circular_index_len(len_points, pt_index+2),
				new_pt_counter = pt_counter+1,
				face_first_pt = points[first_pt_i],
				face_second_pt = points[second_pt_i],
				face_third_pt = points[third_pt_i],
				pt1 = points_3Dvec[face_first_pt],
				pt2 = points_3Dvec[face_second_pt],
				pt3 = points_3Dvec[face_third_pt],
				pts_are_on_a_line = pts_on_line(pt1,pt2,pt3),
				first_line_outwards = face_pts_outwards(face_first_pt, face_second_pt),
				second_line_outwards = face_pts_outwards(face_second_pt, face_third_pt)
				)
		pt_counter > max_pt_count-1 ? //stop this iteration, all points checked
			[tria_struct[0], tria_struct[1], concat(tria_struct[2], [[111111, len_points, pt_counter, pt_index, iteration_index]]),tria_struct[3]]
		:
			len_points <= 3 ?  //triangulation finished completely successfull
				[tria_struct[0], tria_struct[1], concat(tria_struct[2], [[111211, len_points, pt_counter, pt_index, iteration_index]]),tria_struct[3]]
		:
			//Continue triangulation
			pts_are_on_a_line ? //If the pts are in one line, continue with next triangle
				triangulate_polygon_to_two_points(
					[tria_struct[0], tria_struct[1], concat(tria_struct[2], [[111311, len_points, pt_counter, pt_index, iteration_index]]),tria_struct[3]],
								pt_counter+1, max_pt_count,
								pt_index+1, 
								iteration_index,
								is_for_top)
			: //is_left(pt1, pt2, pt3, true)
				is_valid(tria_struct, first_pt_i, pt1, second_pt_i, pt2, third_pt_i, pt3, points, len_points, true) ?
					triangulate_polygon_to_two_points(
									[array_remove_at(second_pt_i, points), 
										concat(found_facets, [[face_first_pt,face_second_pt,face_third_pt]]),
										concat(tria_struct[2], [[222222, [[face_first_pt,face_second_pt,face_third_pt]],[[first_pt_i,face_second_pt, face_third_pt]], len_points, pt_counter, pt_index, iteration_index]]),
										,tria_struct[3]],
									pt_counter+1, max_pt_count-1,
									pt_index,//since the consumed point is the second point (index +1), the index does not increase because the third point becomes the second point in the next check
									iteration_index,
									is_for_top)
					:					
					triangulate_polygon_to_two_points(
						[tria_struct[0], tria_struct[1], concat(tria_struct[2], [[111411, len_points, pt_counter, pt_index, iteration_index]]),tria_struct[3]],
								pt_counter+1, max_pt_count,
								pt_index+1, 
								iteration_index,
								is_for_top)
			
			;
		
	function face_pts_outwards(face_pt_1, face_pt_2) =
					outwards(points_3Dvec[face_pt_1], points_3Dvec[face_pt_2]);
					
	function outwards(point1, point2)=
		has_bigger_xy(point1, point2);
		
	function has_bigger_xy(point1, point2) =
		(pow(point1.x,2)+pow(point1.y,2)) > (pow(point2.x,2)+pow(point2.y,2));
		
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
							) //end let
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
	
	function is_minor_face_point(seg_faces_pts, thread_face_point_index) =
							norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index]])
								<= norm_xy(points_3Dvec[seg_faces_pts[thread_face_point_index+1]])
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
	
	//  **********************************************************************
	//  Array Helper Functions	
	//  **********************************************************************

	function array_len_savely(value) =
			value == undef ? 0 : len(value)==undef ? 0 : len(value);
			
	function array_get_circular_index(array, index) =
		index <= len(array)-1 ? index : ((index)%len(array))
		;
							
	function array_get_circular_index_len(array_length, index) =
		index <= array_length-1 ? index : ((index)%array_length)
		;
		
	function array_remove_at(index, array) =
			index < 0 || index > len(array)-1 ? array 
			:
					concat(
					//first part
					[
					for(first_index = [0:1: index-1])
						array[first_index]
					],
					//end part
					[
					for(last_index = [index+1:1: len(array)-1])
						array[last_index]
					]
				);
					
	function array_replace_at(index, array, replacement) =
			index < 0 || index > len(array)-1 ? array 
			:
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
	
	function arrayDiff(array1,array2) = [
		for (index = [0:1:len(array1)-1] )
			[array1[index].x-array2[index].x,array1[index].y-array2[index].y,array1[index].z-array2[index].z]
		];
								
	//-----------------------------------------------------------		
	// ------------------------------------------------------------
	// Check faces integrity
	// ------------------------------------------------------------
	//-----------------------------------------------------------

	non_planar_faces = [];
	duplicate_faces = [];
	self_intersecting_faces = [];
	thread_faces_sorted_points = [];
	/*
	thread_faces_sorted_points = sort_points_in_faces(faces=thread_faces);
	//for(f = thread_faces_sorted_points)
	//	echo(points_3Dvec[f[0]],points_3Dvec[f[1]],points_3Dvec[f[2]]);
	self_intersecting_faces = get_polygons_duplicate_vertexes(thread_faces_sorted_points);
	test_duplicate_faces = [];//[[2,1,1],[1,2,1]];
	test_faces = sort_points_in_faces(faces=concat(test_duplicate_faces,thread_faces_sorted_points));
	thread_faces_sorted_faces = sort_faces( test_faces);
	
	duplicate_faces = [];//get_faces_duplicates(faces=thread_faces_sorted_faces);
	non_planar_faces = get_faces_non_planar_z(thread_faces, points_3Dvec);
	
	point_dupli = get_point_duplicates(points = quicksort_arr(points_3Dvec, 2));
	echo("point duplicates", point_dupli);
	*/
	//echo(points_3Dvec[f[0]],points_3Dvec[f[1]],points_3Dvec[f[2]]);
	//DEBUG
	/*
	non_planar_test_pts = [[1,2,3],[2,3,3.1],[3,4,3],[4,5,3]];
	non_planar_test_faces = [[0,1,2,3]];
	echo("non-planar faces", get_faces_non_planar_z(non_planar_test_faces, non_planar_test_pts));
	*/
	function get_faces_non_planar_z(faces = [], points = []) =
		[
			for(found_face =
			[
				for(face = faces)
					let(face_len = (face == undef ? 0 : (len(face)==undef ? 0 : len(face)))) //a "undef" face created the "recursion detected" error
					face_len<=3 ? []  //always planar, 
					: check_face_planar_z(face, len(face), 0, points) ? [] //is planar
						: face
			])
			if(len(	found_face)> 0)
				found_face
		]
		;	
	
	function check_face_planar_z(face = [], length_face=0, face_index=0, points=[]) =
		face_index >= length_face-1 ? true //break recursion
			: points[face[face_index]].z == points[face[face_index+1]].z ?
					//all ok, got next point
					check_face_planar_z(face, length_face, face_index+1, points)
					:
					//not the same z
					false
			;
			
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
					check_vertex_duplicate(face=face,index=0,face_length=len(face)) ?
						face : []
			
			])
			if(len(	found_face)> 0)
				found_face
		];
			
	function get_point_duplicates(points = []) =
		[
			for(found_point =
			[
				for(index = [0:1:len(points)-1])
					points[index].x == points[index+1].x
						&& points[index].y == points[index+1].y
						&& points[index].z == points[index+1].z
					? [index, points[index]] : []
			])
			if(len(	found_point)> 0)
				found_point
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
			quicksort_arr(faces, 0)
	;
		
	function sort_points_in_faces(faces=[]) =
	[
		for(face = faces)
			quicksort_face(face)
	];

						
	function quicksort_cross_point(arr) =
  (len(arr)==0) ? [] :
			//Sort by angle (3)
      let(  pivot   = arr[floor(len(arr)/2)][3],
            lesser  = [ for (y = arr) if (y[3]  < pivot) y ],
            equal   = [ for (y = arr) if (y[3] == pivot) y ],
            greater = [ for (y = arr) if (y[3]  > pivot) y ]
      )
      concat( quicksort_cross_point(lesser), equal, quicksort_cross_point(greater) ); 
						
	function quicksort_face(arr) =
  (len(arr)==0) ? [] :
      let(  pivot   = arr[floor(len(arr)/2)],
            lesser  = [ for (y = arr) if (y  < pivot) y ],
            equal   = [ for (y = arr) if (y == pivot) y ],
            greater = [ for (y = arr) if (y  > pivot) y ]
      )
      concat( quicksort_face(lesser), equal, quicksort_face(greater) ); 
					
	function quicksort_arr(arr, index_of_sort_value) =
  (len(arr)==0) ? [] :
      let(  pivot   = arr[floor(len(arr)/2)][index_of_sort_value],
            lesser  = [ for (y = arr) if (y[index_of_sort_value]  < pivot) y ],
            equal   = [ for (y = arr) if (y[index_of_sort_value] == pivot) y ],
            greater = [ for (y = arr) if (y[index_of_sort_value]  > pivot) y ]
      )
      concat( quicksort_arr(lesser, index_of_sort_value), equal, quicksort_arr(greater, index_of_sort_value) );


	//-----------------------------------------------------------		
	// ------------------------------------------------------------
	// Create Thread/polygon
	// ------------------------------------------------------------
	//-----------------------------------------------------------
	
	 
	//DEBUG
	/*
	echo("***********************************************");
	echo("points_3Dvec len ", len(points_3Dvec));
	echo("points_3Dvec=", points_3Dvec);
	echo("***********************************************");
	echo("thread_faces len ",len(thread_faces));	
	echo("thread_faces=", thread_faces);
	*/
	if(show_thread_faces_result)
		echo(thread_faces, len(thread_faces));	
	if(len(non_planar_faces) > 0)
	{
		echo("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		echo("Non-planar_faces", non_planar_faces);
	}			
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

	
}//end module make_helix_polyhedron()


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Math Functions 
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

	function get_scale(length, extension)	=
							(length + extension)/length;

	function scale_xy(point, scale_factor) =
				[point.x * scale_factor,
				 point.y * scale_factor,
				 point.z
				];
				
	function norm_xy(point)= norm([point.x, point.y,0]);							
	


