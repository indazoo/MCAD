$fn=64;
include <threads.scad>;

/*
translate([9.728/2,0,0])
cube([10,10,10]);
*/
debug = true;

// ----------------------------------------------------
//test_rope_threads(debug=true);
module test_rope_threads(debug=false)
{
	//Rope threads
	size_mm = 8;
	length = 10;
	translate ([0, 0, 0])
	
	//translate ([0, -15, 0])
	//test_rope_thread(diameter=size_mm,
	//				n_starts=3,
	//				debug=debug);
	
	translate ([0, 0, 0.25])
	difference()
	{
		cube([size_mm+4,size_mm+4,length+4], center=true);
		test_rope_thread(diameter=size_mm,
						length=length,
						internal = true,
						backlash = 0.5,
						debug=debug);
		translate([0,-20,0])
		cube([40,40,60], center=true);
		translate([0,0,-30+0.01])
		cube([40,40,60], center=true);
		translate([0,0,+30+length-0.01])
		cube([40,40,60], center=true);
		
	}
	
	translate([0,0,1*0])
	test_rope_thread(diameter=size_mm,
					length = length,
					internal = false,
					backlash = 0,
					debug=debug);
	
}

module test_rope_thread(diameter=8,
						length=10,
						internal = false,
						n_starts = 1,
						rope_diameter=1.5,
						rope_bury_ratio=0.9,
						coarseness = 32,
						right_handed=true,
						clearance = 0,
						backlash = 0,
						bore_diameter = 0,
						taper_angle = 0,
						debug = false
			)
{

	rope_thread(
		thread_diameter = diameter,
		pitch=rope_diameter+0.5,
		length=length,
		internal = internal,
		n_starts = n_starts,
		rope_diameter=rope_diameter,
		rope_bury_ratio=rope_bury_ratio,
		coarseness = coarseness,
		right_handed = right_handed,
		clearance = 0,
		backlash = backlash,
		printify_top = false,
		printify_bottom = false,
		bore_diameter = bore_diameter, //-1 = no bore hole. Use it for pipes 
		taper_angle = 0,
		exact_clearance = true,
		taper_angle = taper_angle,
		debug=debug);
}

// ----------------------------------------------------

size = 1/8;
test_BSP_backlash(nominal_pipe_size = size, debug=true);
test_coarseness = 8;
//The thread profile should get wider at the crest and narrower at the roots.
module test_BSP_backlash(nominal_pipe_size = 3/4, debug=false)
{
	size_mm = BSP_get_gauge_diameter_inch(nominal_pipe_size)*25.4+4;
	internal_l = 25.4*BSP_get_length_for_internal_inches(nominal_pipe_size);
	difference()
	{
		cube([size_mm,size_mm,internal_l+4], center=true);
		FBSPT_thread(
			nominal_pipe_size = nominal_pipe_size,
			backlash =0.9,
			coarseness=test_coarseness,
			debug=debug);
		translate([0,-20,0])
		cube([40,40,60], center=true);
		translate([0,0,-30+0.01])
		cube([40,40,60], center=true);
		translate([0,0,+30+internal_l-0.01])
		cube([40,40,60], center=true);
		
	}
	/*
	translate([0,0,-25.4/BSP_get_TPI(nominal_pipe_size)*0])
	MBSPT_thread(
		nominal_pipe_size = nominal_pipe_size,
		backlash = 0.1,
		coarseness=test_coarseness,
		debug=debug);
	*/
}


//The facets of internal thread should be snugly around the external thread.
module test_BSP_radius_extension(nominal_pipe_size = 3/4, debug=false)
{
	$fn=64;
	size_mm = BSP_get_gauge_diameter_inch(nominal_pipe_size)*25.4+4;
	internal_l = 25.4*BSP_get_length_for_internal_inches(nominal_pipe_size);
	difference()
	{
		cube([size_mm,size_mm,internal_l+4], center=true);
		FBSPT_thread(
			nominal_pipe_size = nominal_pipe_size,
			backlash = 0,
			coarseness=32,
			debug=debug);
		translate([0,-20,0])
		cube([40,40,60], center=true);
		translate([0,0,-30+0.01])
		cube([40,40,60], center=true);
		translate([0,0,+30+internal_l-0.01])
		cube([40,40,60], center=true);
		
	}
	translate([0,0,-25.4/BSP_get_TPI(nominal_pipe_size)*0])
	MBSPT_thread(
		nominal_pipe_size = nominal_pipe_size,
		backlash = 0,
		coarseness=64,
		debug=debug);
}
/*
translate([0,10,0])
metric_thread(8, pitch=1.5, length=5, right_handed=true, debug=true);
*/