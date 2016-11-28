include <helix.scad>

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
	angle=47.5;
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
		helix(
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

	helix(
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
}


	//-----------------------------------------------------------
	// Rope thread tooth profile map
	//-----------------------------------------------------------
	// A tooth can have any profile with multiple edges. 
	// limitations: 
	//   - z-value must not be the same for two points.
	//   - no overhangs (low convexitiy)

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

// -----------------------------------------------------------
// Helper Functions
// -----------------------------------------------------------

function get_clearance(clearance, internal) = (internal ? clearance : 0);
function get_backlash(backlash, internal) = (internal ? backlash : 0);

			