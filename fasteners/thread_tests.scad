include <threads.scad>

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
 //$fn=13; //this creates good visible polygons and with n_starts=2 or 3 many cases of cross points
 //square_thread(diameter=8, pitch=1.5, length=1.5+1/pow(2,50), bore_diameter=3, right_handed=false);  

// Test Case 4:
// Flat polygons on top_z() and bottom_z() of thread without volume above or below.
// $fn=32;
// square_thread(diameter=8, pitch=1.5, length=5, right_handed=false, bore_diameter=4);
// translate([10,10,0])square_thread(diameter=8, pitch=1.5, length=5, right_handed=true, bore_diameter=4);

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
// ==> This thread has facets points at z=-4.4995e-16 (near zero). This created multiple identical crosspoints.
//     It was solved by introducing a "cross point tolerance" and adjusting the z-values of the points.
// $fn=67;
// $fn=12;
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

$fn=13;
test_threads();
//test_channel_simple(dia=8, internal=true);
//test_channel_thread(dia=8);
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
//metric_thread(10, pitch=3, length=5, internal=false, n_starts=4);
 //   metric_thread(8, pitch=1.5, length=5, right_handed=false);
//metric_thread(8, pitch=1.01, length=10, right_handed=true, internal=false, n_starts=3, bore_diameter=-1);
//translate([-10,0,0])
//metric_thread(8, pitch=1.01, length=10, right_handed=false, internal=false, n_starts=3, bore_diameter=-1);
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
//translate([20,30,0])cube([10,10,10]);
//test_BSP(dia_inches = 1/8);
//    square_thread(8, pitch=1.5, length=5);
module test_threads ($fa=5, $fs=0.1)
{
	// M8
	metric_thread(8, pitch=1.5, length=5, right_handed=true);

  translate ([0, 15, 0])
  metric_thread(8, pitch=1.5, length=5, right_handed=false);



  // multiple start:
  translate ([0, -15, 0])
    metric_thread(10, pitch=3, length=5, internal=false, n_starts=4);

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

		echo("BSP_thread start");
    translate ([60.5, 0, 0])
		test_BSP(dia_inches = 1/8);
		echo("BSP_thread end");
	
		translate ([70, 0, 0])
		test_rope_thread();
		
		translate ([70, -15, 0])
		test_rope_thread(n_starts=3);

		translate([85,0,0])
			test_meccano_worms();
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
	length = 14;
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
		right_handed = false,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = 0,
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
		right_handed = false,
		clearance = clearance,
		backlash = backlash,
		bore_diameter = 0
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

module test_meccano_worms()
{
	rotate([90,0,0])
	meccano_worm_gear_narrow_No32b (
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
	);

	translate([0,-30,0])
	rotate([90,0,0])
		meccano_worm_gear_std_No32 (
			right_handed = true,
			printify_top = false,
			printify_bottom = false,
			exact_clearance = true
	);		
}