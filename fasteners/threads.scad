include <helix.scad>



// TODO: BA (British Association Threads)
// 		https://en.wikipedia.org/wiki/British_Association_screw_threads
// 		https://mdmetric.com/tech/tict2011.htm#diag8


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
		exact_clearance = true,
		taper_angle = 0,
		debug = false
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
			exact_clearance = exact_clearance,
			taper_angle = taper_angle,
			debug = debug
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
		exact_clearance = true,
		taper_angle = 0
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
			exact_clearance = exact_clearance,
			taper_angle = taper_angle
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
		exact_clearance = true,
		taper_angle = 0
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
			exact_clearance = exact_clearance,
			taper_angle = taper_angle
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
		exact_clearance = true,
		taper_angle = 0
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
			exact_clearance = exact_clearance,
			taper_angle = taper_angle
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
		exact_clearance = true,
		taper_angle = 0
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
			exact_clearance = exact_clearance,
			taper_angle = taper_angle
			);
}

//															Gauge													Tol +-		Diametral	
//	G / R		Thread Thread	Gauge			Minor			basic 	Tol +-					Fitting		Wrenching	Pos	Plane	Tolerance	Tapping drill
//	size	density	pitch	diameter		diameter		length	T1/2	length	length	allowance	allowance	T2/2 		+-			R 95%	G 80%
//																							*1			*2			*5			*6
//	(in)	(in−1)	(mm)	(in)	(mm)	(in)	(mm)	[turns]	(turns)	(in)	(mm)	(turns)		(turns)		(turns)		(mm)		(mm)	(mm)
BSP_data = [
	[1/16,	28,		0.907,	0.3041,	7.723,	0.2583,	6.561,	4+3/8,	1,		5/32,	4.0,	2+3/4,		1+1/2,		1+1/4,		0.071,		6.6,	6.8],	//*3, *4
	[1/8,	28,		0.907,	0.3830,	9.728,	0.3372,	8.566,	4+3/8,	1,		5/32,	4.0,	2+3/4,		1+1/2,		1+1/4,		0.071,		8.6,	8.8],	//*3, *4
	[1/4,	19,		1.337,	0.5180,	13.157,	0.4506,	11.445,	4+1/2,	1,		0.2367,	6.0,	2+3/4,		1+1/2,		1+1/4,		0.104,		11.5,	11.8],	//*3, *4
	[3/8,	19,		1.337,	0.6560,	16.662,	0.5886,	14.950,	4+3/4,	1,		1/4,	6.4,	2+3/4,		1+1/2,		1+1/4,		0.104,		15.0,	15.3],	//*3, *4
	[1/2,	14,		1.814,	0.8250,	20.955,	0.7335,	18.631,	4+1/2,	1,		0.3214,	8.2,	2+3/4,		1+1/2,		1+1/4,		0.142,		18.7,	19.1],	//*3, *4
	[5/8,	14,		1.814,	0.9020,	22.911,	0.8105,	20.587,	4+1/2,	1,		0.3214,	8.2,	2+3/4,		1+1/2,		1+1/4,		0.142,		20.7,	21.1],	//*4
	[3/4,	14,		1.814,	1.0410,	26.441,	0.9495,	24.117,	5+1/4,	1,		3/8,	9.5,	2+3/4,		1+1/2,		1+1/4,		0.142,		24.2,	24.6],	//*3, *4
	[7/8,	14,		1.814,	1.1890,	30.201,	1.0975,	27.877,	5+1/4,	1,		3/8,	9.5,	2+3/4,		1+1/2,		1+1/4,		0.142,		28.0,	28.3],	//*4
	[1,		11,		2.309,	1.3090,	33.249,	1.1926,	30.291,	4+1/2,	1,		0.4091,	10.4,	2+3/4,		1+1/2,		1+1/4,		0.180,		30.4,	30.9],	//*3, *4
	[1+1/8,	11,		2.309,	1.4920,	37.897,	1.3756,	34.939,	4+1/2,	1,		0.4091,	10.4,	2+3/4,		1+1/2,		1+1/4,		0.180,		35.1,	35.5],	//*4
	[1+1/4,	11,		2.309,	1.6500,	41.910,	1.5335,	38.952,	5+1/2,	1,		1/2,	12.7,	2+3/4,		1+1/2,		1+1/4,		0.180,		39.1,	39.5],	//*3, *4
	[1+3/8,	11,		2.309,	1.7450,	44.323,	1.6285,	41.365,	5+1/2,	1,		1/2,	12.7,	2+3/4,		1+1/2,		1+1/4,		0.180,		41.5,	42.0],	//*4
	[1+1/2,	11,		2.309,	1.8820,	47.803,	1.7656,	44.845,	5+1/2,	1,		1/2,	12.7,	2+3/4,		1+1/2,		1+1/4,		0.180,		45.0,	45.4],	//*3, *4
	[1+5/8,	11,		2.309,	2.0820,	52.883,	1.9656,	49.926,	6+7/8,	1,		5/8,	15.9,	3+1/4,		2,			1+1/4,		0.180,		50.1,	50.5],	//*4
	[1+3/4,	11,		2.309,	2.1160,	53.746,	1.9995,	50.788,	6+7/8,	1,		5/8,	15.9,	3+1/4,		2,			1+1/4,		0.180,		50.9,	51.4],	//*4
	[1+7/8,	11,		2.309,	2.2440,	56.998,	2.1276,	54.041,	6+7/8,	1,		5/8,	15.9,	3+1/4,		2,			1+1/4,		0.180,		54.2,	54.6],	//*4
	[2,		11,		2.309,	2.3470,	59.614,	2.2306,	56.656,	6+7/8,	1,		5/8,	15.9,	3+1/4,		2,			1+1/4,		0.180,		56.8,	57.2],	//*3, *4
	[2+1/4,	11,		2.309,	2.5870,	65.710,	2.4706,	62.752,	7+9/16,	1+1/2,	11/16,	17.5,	4,			2+1/2,		1+1/2,		0.216,		62.9,	63.3],	//*4
	[2+1/2,	11,		2.309,	2.9600,	75.184,	2.8435,	72.226,	7+9/16,	1+1/2,	11/16,	17.5,	4,			2+1/2,		1+1/2,		0.216,		72.4,	72.8],	//*3, *4
	[2+3/4,	11,		2.309,	3.2100,	81.534,	3.0935,	78.576,	8+5/16,	1+1/2,	13/16,	20.6,	4,			2+1/2,		1+1/2,		0.216,		78.7,	79.2],	//*4
	[3,		11,		2.309,	3.4600,	87.884,	3.3435,	84.926,	8+5/16,	1+1/2,	13/16,	20.6,	4,			2+1/2,		1+1/2,		0.216,		85.1,	85.5],	//*3, *4
	[3+1/4,	11,		2.309,	3.7000,	93.980,	3.5835,	91.022,	9+5/8,	1+1/2,	7/8,	22.2,	4,			2+1/2,		1+1/2,		0.216,		91.2,	91.6],	//*4
	[3+1/2,	11,		2.309,	3.9500,	100.330,3.8335,	97.372,	9+5/8,	1+1/2,	7/8,	22.2,	4,			2+1/2,		1+1/2,		0.216,		97.5,	98.0],	//*4
	[3+3/4,	11,		2.309,	4.2000,	106.680,4.0835,	103.722,9+5/8,	1+1/2,	7/8,	22.2,	4,			2+1/2,		1+1/2,		0.216,		103.9,	104.3],	//*4
	[4,		11,		2.309,	4.4500,	113.030,4.3335,	110.072,11,		1+1/2,	1,		25.4,	4+1/2,		3,			1+1/2,		0.216,		110.2,	110.7],	//*3, *4
	[4+1/2,	11,		2.309,	4.9500,	125.730,4.8335,	122.772,11,		1+1/2,	1,		25.4,	4+1/2,		3,			1+1/2,		0.216,		122.9,	123.4],	//*4
	[5,		11,		2.309,	5.4500,	138.430,5.3335,	135.472,12+3/8,	1+1/2,	1+1/8,	28.6,	5,			3+1/2,		1+1/2,		0.216,		135.6,	136.1],	//*3, *4
	[5+1/2,	11,		2.309,	5.9500,	151.130,5.8335,	148.172,12+3/8,	1+1/2,	1+1/8,	28.6,	5,			3+1/2,		1+1/2,		0.216,		148.3,	148.8],	//*4
	[6,		11,		2.309,	6.4500,	163.830,6.3335,	160.872,12+3/8,	1+1/2,	1+1/8,	28.6,	6,			3+1/2,		1+1/2,		0.216,		161.0,	161.5],	//*3, *4
	[7,		10,		2.540,	7.4500,	189.230,7.3220,	185.979,13+3/4,	1+1/2,	1+3/8,	34.9,	5+3/4,		4,			1+1/2,		0.25,		186.1,	186.6], //*4
	[8,		10,		2.540,	8.4500,	214.630,8.3220,	211.379,15,		1+1/2,	1+1/2,	38.1,	6+1/4,		4+1/4,		1+1/2,		0.25,		211.5,	212.0],	//*4
	[9,		10,		2.540,	9.4500,	240.030,9.3220,	236.779,15,		1+1/2,	1+1/2,	38.1,	6+1/4,		4+1/4,		1+1/2,		0.25,		236.9,	237.4],	//*4
	[10,	10,		2.540,	10.4500,265.430,10.3220,262.179,16+1/4,	1+1/2,	1+5/8,	41.3,	6+3/4,		4+5/8,		1+1/2,		0.25,		262.3,	262.8],	//*4
	[11,	8,		3.175,	11.4500,290.830,11.2900,286.766,13,		1+1/2,	1+5/8,	41.3,	5+1/2,		3+3/4,		1+1/2,		0.266,		287.0,	287.6],	//*4
	[12,	8,		3.175,	12.4500,316.230,12.2900,312.166,13,		1+1/2,	1+5/8,	41.3,	5+1/2,		3+3/4,		1+1/2,		0.266,		312.4,	313.0],	//*4
	[13,	8,		3.175,	13.6800,347.472,13.5200,343.408,13,		1+1/2,	1+5/8,	41.3,	5+1/2,		3+3/4,		1+1/2,		0.267,		343.6,	344.2],	//*4
	[14,	8,		3.175,	14.6800,372.872,14.5200,368.808,14,		1+1/2,	1+3/4,	44.5,	5+7/8,		4,			1+1/2,		0.266,		369.0,	369.6],	//*4
	[15,	8,		3.175,	15.6800,398.272,15.5200,394.208,14,		1+1/2,	1+3/4,	44.5,	5+7/8,		4,			1+1/2,		0.266,		394.4,	395.0],	//*4
	[16,	8,		3.175,	16.6800,423.672,16.5200,419.608,15,		1+1/2,	1+7/8,	47.6,	6+1/4,		4+1/4,		1+1/2,		0.266,		419.8,	420.4],	//*4
	[17,	8,		3.175,	17.6800,449.072,17.5200,445.008,16,		1+1/2,	2,		50.8,	6+5/8,		4+1/2,		1+1/2,		0.266,		445.2,	445.8],	//*4
	[18,	8,		3.175,	18.6800,474.472,18.5200,470.408,16,		1+1/2,	2,		50.8,	6+5/8,		4+1/2,		1+1/2,		0.266,		470.6,	471.2]	//*4
	];

// *1 : Fitting allowance is only defined for BS 21-1985 thread sizes.
//      For other sizes it is estimated/derived from existing (smaller) thread sizes by looking at ratio "Gauge_length/Fitting-allowance"
//		for(i=[0:len(BSP_data)-1])
//		{
//      echo("fff",BSP_data[i][0],BSP_data[i][7]/BSP_data[i][11],BSP_data[i][7]/BSP_data[i][12], BSP_data[i][7]/2.4,BSP_data[i][7]/3.5);
//		}
// *2 : Wrenching allowance is only defined for BS 21-1985 thread sizes.
//		For other sizes it is estimated/derived from existing (smaller) thread sizes by looking at ratio "Gauge_length/Wrenching-allowance"
// *3 : Sizes defined in BS 21-1985 : Pipe threads for tubes and fittings where pressure-tight joints are made on the threads
// *4 : Sizes defined in https://en.wikipedia.org/wiki/British_Standard_Pipe.
//      Values for "Fitting allowance","Wrenching allowance" and "Tolerance of position of gauge plane" are estimated/derived because
//      they are not existing on wikipedia.
// *5 : "Tolerance on position of gauge plane realtive to face of internally threaded parts, T2/2"
//      Value of this tolerance is only defined for BS 21-1985 thread sizes. Other values are interpolated/estimated.
// *6 : "Diametral tolerance on parallel internal threads" is only defined for BS 21-1985 thread sizes.
//		For other sizes it is estimated/derived from existing (smaller) thread sizes by looking at ration TPI/Diametral_tolerance.
//		echo("fff",BSP_data[i][0], BSP_data[i][0]/BSP_data[i][14]);
//echo("-------------------");
//test_index = 6; //3/4"
//test_data = BSP_data[test_index];
//echo("Size = ", test_data[0]);
//echo("TPI = ", test_data[1]);
//echo("Gauge length = ", test_data[7], "[turns]", test_data[7]/test_data[1]*25.4, "[mm]", test_data[10], "[mm]");
//echo("Gauge tolerance = ", test_data[8], "[turns]");
//echo("Gauge length MIN = ", (test_data[7]-test_data[8])/test_data[1]*25.4, "[mm]");
//echo("Gauge length MAX = ", (test_data[7]+test_data[8])/test_data[1]*25.4, "[mm]");
//echo("Fitting allowance = ", test_data[11]/test_data[1]*25.4, "[mm]");
//echo("Wrenching allowance = ", test_data[12]/test_data[1]*25.4, "[mm]");
//echo("-------------------");





//Derived from BSP_data (see below) to accomodate all nominal and custom diameters.
function BSP_get_threads_per_inch(nominal_pipe_size) = 
		 nominal_pipe_size < 1/4 ? 28
		: nominal_pipe_size < 1/2 ? 19
		: nominal_pipe_size < 1 ? 14
		: nominal_pipe_size < 7 ? 11
		: nominal_pipe_size < 11 ? 10
		: 8
		;

function BSP_get_gauge_diameter_inch(nominal_pipe_size) = 
			let(index = BSP_get_size_index(nominal_pipe_size))
			index >= 0 ? BSP_data[index][3] : 0.005;
					
function BSP_get_taper_angle() = 
			//Taper angle of BSP is defined as 1/16 to the diameter.
			//So, the taper angle for one side is half of that. 
			//atan(1/32), //tan−1(1/32) = 1.7899° = 1° 47′ 24.474642599928302″.
			atan(1/32);

function BSP_get_length_for_external_inches(nominal_pipe_size) =
	// - Length: BS 21-1985 states on page 5 :
	//   "The useful thread of the internally threaded part is to be not less than 80% of the length given in column 14 of Table 2"
	//   BSP_data: Column 7 is "gauge length". Column 11 is fitting allowance.
	BSP_get_gauge_length_inches(nominal_pipe_size)+BSP_get_fitting_allowance_inches(nominal_pipe_size);

function BSP_get_length_for_internal_inches(nominal_pipe_size) =
	// - Length: BS 21-1985 states on page 1 in figure 1:
	//   "Useful thread (not less than gauge length plus fitting allowance)"
	//   Column 14 is "minimum gauge length" which is gauge length - tolerance . So it can(!) but not must be smaller than minimum gauge length.
	BSP_get_gauge_length_inches(nominal_pipe_size);

function BSP_get_fitting_allowance_inches(nominal_pipe_size) =
			let(index = BSP_get_size_index(nominal_pipe_size))
			index >= 0 ? 1/BSP_get_TPI(nominal_pipe_size)*BSP_data[index][11] : 0.005;
			
function BSP_get_gauge_length_inches(nominal_pipe_size) =
			let(index = BSP_get_size_index(nominal_pipe_size))
			index >= 0 ? 1/BSP_get_TPI(nominal_pipe_size)*BSP_data[index][7] : 0.005;
	
function BSP_get_TPI(nominal_pipe_size) =
			let(index = BSP_get_size_index(nominal_pipe_size))
			BSP_data[index][1];
function BSP_get_size_index(nominal_pipe_size) =
			let(indexes = 
				[for(index=[0:len(BSP_data)-1])
					nominal_pipe_size == BSP_data[index][0] ? index : -1
				],
				filtered = [
					for(index=indexes)
					if(index>=0)
						index]
				)
			len(filtered) > 0 ? filtered[0] : -1
			;
					

// British Standard Pipe Taper (BSPT) Threads Size Chart Thickness[mm]
// Source :  https://www.pyromation.com/Downloads/Data/BSPT_Thread_Chart.pdf

//	Thread	Threads		pitch	Major diameter	Gauge			Pipe data
//	Size	per inch	[mm]	[mm]	[inch]	length			DN	OD		OD		Tickness
//												[mm]			[mm]	[inch]	[mm]
BSPT_data = [
[1/16,	28,			0.907,		7.723,	0.304,	4,				undef,undef,undef,undef		],
[1/8,	28,			0.907,		9.728,	0.383,	4,				6,	10.2,	0.4,	2		],
[1/4,	19,			1.337,		13.157,	0.518,	6,				8,	13.5,	0.53,	2.3		],
[3/8,	19,			1.337,		16.662,	0.656,	6.4,			10,	17.2,	0.68,	2.3		],
[1/2,	14,			1.814,		20.995,	0.825,	8.2,			15,	21.3,	0.84,	2.6		],
[5/8,	14,			1.814,		22.911,	0.902,	undef,			16,	undef,	undef,	undef	],
[3/4,	14,			1.814,		26.441, 1.041,	9.5,			20,	26.9,	1.06,	2.6		],
[1	,	11,			2.309,		33.249,	1.309,	10.4,			25,	33.7,	1.33,	3.2		],
[1.25,	11,			2.309,		41.91,	1.65,	12.7,			32,	42.4,	1.67,	3.2		],
[1.5,	11,			2.309,		47.803,	1.882,	12.7,			40,	48.3,	1.9,	3.2		],
[2,		11,			2.309,		59.614,	2.347,	15.9,			50,	60.3,	2.37,	3.6		],
[2.5,	11,			2.309,		75.184,	2.96,	17.5,			65,	76.1,	3,		3.6		],
[3,		11,			2.309,		87.884,	3.46,	20.6,			80,	88.9,	3.5,	4		],
[4,		11,			2.309,		113.03,	4.45,	25.5,			100,114.3,	4.5,	4.5		],
[5,		11,			2.309,		138.43,	5.45,	28.6,			125,139.7,	5.5,	5		],
[6,		11,			2.309,		163.83,	6.45,	28.6,			150,165.1,	6.5,	5		]
];
BSPT_thread_size = BSPT_data[7][0];
BSPT_TPI = BSPT_data[7][1];
BSPT_Maj_dia = BSPT_data[7][3];
BSPT_Pipe_dia = BSPT_data[7][7];
echo("BSPT : thread_size",BSPT_thread_size);
echo("BSPT : TPI" , BSPT_TPI);
echo("BSPT : Maj_dia" , BSPT_Maj_dia);
echo("BSPT : Pipe dia", BSPT_Pipe_dia);

					
//
//-------------------------------------------------------------------
//-------------------------------------------------------------------
// BSPT (British Standard Pipe Taper)
// - Whitworth pipe thread DIN ISO 228 (DIN 259) 
// - https://en.wikipedia.org/wiki/British_Standard_Pipe
// - British Engineering Standard Association Reports No. 21 - 1938
// - http://books.google.ch/books?id=rq69qn9WpQAC&pg=PA108&lpg=PA108&dq=British+Engineering+Standard+Association+Reports+No.+21+-+1938&source=bl&ots=KV2kxT-fFR&sig=3FBCPA3Kzhd62nl1Tz08g1QyyIY&hl=en&sa=X&ei=JehZVPWdA4LfPZyEgIAN&ved=0CBQQ6AEwAA#v=onepage&q=British%20Engineering%20Standard%20Association%20Reports%20No.%2021%20-%201938&f=false
// 
// http://valiagroups.net/dimensions-of-pipe-threads.htm
// http://mdmetric.com/tech/thddat7.htm#pt
// 
// Male BSPT is denoted as MBSPT 
// Female BSPT is FBSPT
//
//  BSPT: British Standard Pipe Taper -also known as R threads 
//  BSPP: British Standard Pipe Parallel -also known as G threads 
// --------------------------------------------------------
// BSP - British Standard Pipe Thread (Parallel)
// --------------------------------------------------------

// --------------------------------------------------------
// Male British Standard Pipe Thread
module MBSP_thread(
		nominal_pipe_size = 3/4,  //use inch fractions not decimals !!!!!!
		length = 10, // [inches]
		backlash = 0,  //use backlash to correct too thight threads after 3D printing.
		bore = 0,
		coarseness = 8, //number of segments for root/crest radius circle ( >= 8).
		debug = false
		)
{
	if(debug)
		echo("MBSP_thread");	
	Whitworth_thread(
		threads_per_inch = BSP_get_threads_per_inch(nominal_pipe_size), // Threads per inch is defined in a table according to the standard.
		major_diameter = BSP_get_gauge_diameter_inch(nominal_pipe_size),
		length = length, // [inches]
		internal  = false,
		backlash = backlash,  
		taper_angle = 0,
		bore = bore,  //[inches]
		coarseness = coarseness,
		debug = false
		);
}
// --------------------------------------------------------
// Female British Standard Pipe Thread
module FBSP_thread(
		nominal_pipe_size = 3/4,  //use inch fractions not decimals !!!!!!
		length = 10, // [inches]
		backlash = 0,  //use backlash to correct too thight threads after 3D printing.
		bore = 0,
		coarseness = 8, //number of segments for root/crest radius circle ( >= 8).
		debug = false
		)
{
	if(debug)
		echo("FBSP_thread");

	Whitworth_thread(
		threads_per_inch = BSP_get_threads_per_inch(nominal_pipe_size), // Threads per inch is defined in a table according to the standard.
		major_diameter = BSP_get_gauge_diameter_inch(nominal_pipe_size),
		length = length, // [inches]
		internal  = true,
		backlash = backlash, 
		taper_angle = 0,
		bore = bore,  //[inches]
		coarseness = coarseness, 
		debug = false
		);
	
}

// --------------------------------------------------------
// Male British Standard Pipe Tapered
module MBSPT_thread(
		nominal_pipe_size = 3/4,  //use inch fractions not decimals !!!!!!
		backlash = 0,  //use backlash to correct too thight threads after 3D printing.
		coarseness = 8, //number of segments for root/crest radius circle ( >= 8).
		debug = false
		)
{
	if(debug)
		echo("MBSPT_thread");
	
		// outside diameter is defined in table 
	// The male thread of a BSPT joint is longer than the female thread.
	// The helix() function starts the taper at z=length.
	// The diameter of the thread for a given thread size is defined in a table
	// but at z=gauge_length. For a male thread the length is gauge_length+fitting_allowance.
	// So, the diameter at z = gauge_length+fitting_allowance must be larger than at gauge_length.
	taper_angle = BSP_get_taper_angle();
	gauge_diameter_inch = BSP_get_gauge_diameter_inch(nominal_pipe_size);
	major_diameter_inch = gauge_diameter_inch + 2 * (BSP_get_fitting_allowance_inches(nominal_pipe_size)*tan(taper_angle));
	
	Whitworth_thread(
		threads_per_inch = BSP_get_threads_per_inch(nominal_pipe_size), // Threads per inch is defined in a table according to the standard.
		major_diameter = major_diameter_inch,
		length = BSP_get_length_for_external_inches(nominal_pipe_size), // [inches]
		internal  = false,
		backlash = backlash,  
		taper_angle = taper_angle,
		bore = nominal_pipe_size,  //[inches]
		coarseness = coarseness, 
		debug = debug
		);
}
// --------------------------------------------------------
// Female British Standard Pipe Tapered
module FBSPT_thread(
		nominal_pipe_size = 3/4,  //use inch fractions not decimals !!!!!!
		backlash = 0,  //use backlash to correct too thight threads after 3D printing.
		coarseness = 8, //number of segments for root/crest radius circle ( >= 8).
		debug = false
		)
{
	if(debug)
		echo("FBSPT_thread");
	// - Length: BS 21-1985 states on page 5 :
	//   "The useful thread of the internally threaded part is to be not less than 80% of the length given in column 14 of Table 2"
	//   Column 14 is "minimum gauge length"
	
	// Outside diameter is defined in table 
	// The female thread of a BSPT joint is, without tolerances, the same as gauge_length
	gauge_diameter_inch = BSP_get_gauge_diameter_inch(nominal_pipe_size);
	
	Whitworth_thread(
		threads_per_inch = BSP_get_threads_per_inch(nominal_pipe_size), // Threads per inch is defined in a table according to the standard.
		major_diameter = gauge_diameter_inch,
		length = BSP_get_length_for_internal_inches(nominal_pipe_size), // [inches]
		internal  = true,
		backlash = backlash,  //use backlash to correct too thight threads after 3D printing.
		taper_angle = BSP_get_taper_angle(),
		bore = nominal_pipe_size,  //[inches]
		coarseness = coarseness, 
		debug = debug
		);
}



module Whitworth_thread(
		threads_per_inch, // Threads per inch 
		major_diameter = 1, //[inch]
		length = 10, // [inch]
		internal  = false,
		backlash = 0,  //use backlash to correct too thight threads after 3D printing.
		taper_angle = 0,
		bore = 0,
		coarseness = 8, //number of segments for root/crest radius circle ( >= 8).
		debug = false
		)
{
	// Wikipedia:
	
	// The thread form follows the British Standard Whitworth standard:
	// - Symmetrical V-thread in which the angle between the flanks is 55° (measured in an axial plane)
	// - One-sixth of this sharp V is truncated at the top and the bottom
	// - The threads are rounded equally at crests and roots by circular arcs ending tangentially with the flanks where r ≈ 0.1373P
	// - The theoretical depth of the thread is therefore 0.6403 times the nominal pitch h ≈ 0.6403P

	if(debug)
		echo("Whitworth_thread");

	mm_length = length*25.4;
	mm_major_diameter = major_diameter*25.4;
	profile_data = whitworth_profile_data(threads_per_inch, internal, coarseness);
		/*
		profile_angle,					// 0
		mm_pitch,						// 1
		peak_to_peak_height,			// 2
		tooth_height,					// 3
		clearance,						// 4
		radius,							// 5
		max_height_inner_to_outer_flat	// 6
		coarseness						// 7
		*/
	//scale([1.0,2.0]) circle(r=5.0); 
	mm_profile_minimum_diameter = mm_major_diameter-profile_data[3]*2;
	mm_bore = bore * 25.4;

	tooth_profile_map = whitworth_xz_map(profile_data = profile_data, 
								coarseness_circle = coarseness, 
								deliver_valid_polygon= false);

	if(debug)
	{
	echo("	mm_major_diameter", mm_major_diameter);
	echo("	mm_minor_diameter", mm_profile_minimum_diameter);
	echo("	bore",bore);
	echo("	coarseness",coarseness);
	echo("	backlash", backlash);
	echo("	tooth height", profile_data[3]);
	echo("	profile_data",profile_data);
	echo("	tooth_profile_map",tooth_profile_map);
	}
	
	profile_thread(
		tooth_profile_map = tooth_profile_map,
		profile_data = profile_data,
		length = mm_length,
		major_radius = mm_major_diameter / 2,
		minor_radius = mm_profile_minimum_diameter / 2,
		internal = internal,
		n_starts = 1,
		right_handed = true,
		clearance = 0,
		backlash = backlash, 
		printify_top = false,
		printify_bottom = false,
		is_channel_thread = false,
		bore_diameter = mm_bore,
		taper_angle = taper_angle,
		exact_clearance = true,
		debug=debug
		);

} //END Whitworth


//-------------------------------------------------------------------
//-------------------------------------------------------------------
// 
// http://machiningproducts.com/html/NPT-Thread-Dimensions.html
// http://www.piping-engineering.com/nominal-pipe-size-nps-nominal-bore-nb-outside-diameter-od.html
// http://mdmetric.com/tech/thddat19.htm
// http://www.hasmi.nl/en/handleidingen/draadsoorten/american-standard-taper-pipe-threads-npt/
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
			taper_angle = atan(1/32) //tan−1(1/32) = 1.7899° = 1° 47′ 24.474642599928302″.
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
			exact_clearance = exact_clearance,
			taper_angle = 0
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
			exact_clearance = exact_clearance,
			taper_angle = 0
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
	exact_clearance = true,
	taper_angle = 0,
	debug = false
	)
{
	if(debug)
	{
		echo("**********************************");
		echo("simple_profile_thread(");
		echo("pitch",pitch);
		echo("length",length);
		echo("upper_angle",upper_angle);
		echo("lower_angle",lower_angle);
		echo("outer_flat_length",outer_flat_length);
		echo("major_radius",major_radius);
		echo("minor_radius",minor_radius);
		echo("internal",internal);
		echo("n_starts",n_starts);
		echo("right_handed",right_handed);
		echo("clearance",clearance);
		echo("backlash",backlash);
		echo("printify_top",printify_top);
		echo("printify_bottom",printify_bottom);
		echo("is_channel_thread",is_channel_thread);
		echo("bore_diameter",bore_diameter);
		echo("exact_clearance",exact_clearance);
		echo("taper_angle",taper_angle);
		echo("**********************************");
	}

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
		echo("outer_flat_length-upper_flat", outer_flat_length-upper_flat);	
		echo("calc_upper_flat()-upper_flat", calc_upper_flat()-upper_flat);
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
	if(debug)
	{
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
	}
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
				tooth_height = tooth_height,
				debug = debug
				);
				

				
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
	exact_clearance = true,
	taper_angle = 0,
	debug = false)
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
		exact_clearance = exact_clearance,
		taper_angle = taper_angle,
		debug = debug
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
	backlash = 0.1,
	printify_top = false,
	printify_bottom = false,
	bore_diameter = -1, //-1 = no bore hole. Use it for pipes 
	taper_angle = 0,
	exact_clearance = true,
	taper_angle = 0,
	debug = false
)
{
	if(debug)
	{
		echo("module rope_profile_thread()");
	}
	tooth_height = rope_diameter/2 * rope_bury_ratio;
	minor_radius = major_radius-tooth_height;
	clearance = get_clearance(clearance, internal);
	backlash = get_backlash(backlash, internal);

	
	profile_data = rope_profile_data(pitch, tooth_height, coarseness);

	xz_map = rope_xz_map(profile_data, 
					rope_diameter, 
					rope_bury_ratio, 
					deliver_valid_polygon = false);
	
	if(debug)
	{
		echo("	internal", internal);
		echo("	backlash",  backlash);
	}

	profile_thread(
		tooth_profile_map = xz_map,
		profile_data = profile_data,
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
		debug=debug
		);

}


//-----------------------------------------------------------------
//-----------------------------------------------------------------
//
// PROFILE THREAD
//
//-----------------------------------------------------------------
//-----------------------------------------------------------------
// All thread modules call this to :
// - apply backlash to the profile
// - finally call helix()
module profile_thread(
		tooth_profile_map = [],
		profile_data = [],
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
		debug = false
		)
{
	//Profile_Data
	//	profile_angle,					// 0
	//	mm_pitch,						// 1
	//	peak_to_peak_height,			// 2
	//	tooth_height,					// 3
	//	clearance,						// 4
	//	radius,							// 5
	//	max_height_inner_to_outer_flat	// 6
	//  coarsness						// 7
	
	if(debug)
		echo("module profile_thread");
	
	pitch = profile_data[1];
	
	//The radius extension is for internal threads. Because the Whitworth profile is round at root and crest
	//but the circles in Openscad are segemented the segmented profile for an internal thread is always 
	//too small to allow a bolt with full round profile. The severity of this depends on the used coarseness.
	//The radius cannot be changed without changing the profile angle so the diameter must be increased.
	rad_seg_angle = v_profil_rad_seg_angle(profile_angle = profile_data[0], 
										coarseness_circle = profile_data[7]);
	radius_ext = radius_extension(profile_data[5], rad_seg_angle, profile_data[5],	internal);
	tooth_profile_map_ext = xz_map_add_z(xzmap=tooth_profile_map, z=radius_ext);

	//Backlash
	//Backlash changes the profile shape. The crests get wider, the roots narrower.
	// 1. Some backlash has already been introduced by radius extension.
	radius_ext_backlash = tan(profile_data[0])*radius_ext; 
	// 2. Backlash indirectly added by helix() to allow the bolt turn in internal thread.
	major_radius_ext = radius_extension(2*major_radius, 360/$fn, 2*major_radius, internal);
	major_radius_backlash = tan(profile_data[0])*major_radius_ext; 
	// Apply still needed backlash
	existing_backlash = radius_ext_backlash+major_radius_backlash;
	needed_backlash = backlash >  existing_backlash ? backlash-existing_backlash : 0; 
	
	// 3. When applying the rest of the backlash, then the "move" of the curve in one direction
	//    may "eat up" points at a lower level.
	// 4. The "move" of the profile in one direction may introduce new points where the two profiles cut.
	// 5. The same happens when "moving" the profile in the other direction
	// 6. The same happens when comparing the results of these +- backlash/2 "moves"
	

				
	echo("tooth_profile_map_ext XY",tooth_profile_map_ext);
	echo("needed_backlash", needed_backlash);
	echo("internal",internal);
	echo("pitch",pitch);
	
	xy_map = xz_map_to_xy_map(tooth_profile_map_ext);
	array_testpts_fixed = array_remove_empty(xy_map);
	tripled_pts = triple_pts(array_testpts_fixed, pitch);
	array_testp_zeroed = lines_insert_pt_at_zero(lines=tripled_pts,pitch=3*pitch);
	array_testp_pitched = lines_add_pt_at_pitch(lines=array_testp_zeroed, pitch=3*pitch);
	lines = convert_pt_map_to_clines(profile_pt_map=array_testp_pitched);
	backlashed_lines = add_backlash(profile_cline_map=lines, backlash = backlash, is_outline = internal);
	backlashed_indexed_lines = clines_adjust_index(clines=backlashed_lines);
	lines_crossing = remove_disjoints(
					line_crossings(clines = backlashed_indexed_lines,
									do_report_line_touches = false)
				);
	existing_lines_with_crossed = 
		existing_with_crossed(existing_lines=backlashed_indexed_lines,
								crossed_lines=lines_crossing);
	echo("existing_lines_with_crossed",existing_lines_with_crossed);
	lines_min_max_limited = 
		clines_adjust_index_simple(
			clines_limit_to_min_max_x(clines=existing_lines_with_crossed, 
									min_x=pitch, max_x=2*pitch)
									);
echo("lines_min_max_limited",len(lines_min_max_limited),"min_x=", pitch,"max_x=" ,2*pitch);
for(t=lines_min_max_limited) 
{
	echo("	", t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	//draw_cline(cline=t, col = "Blue");
	//draw_cline(cline=t[3], col = "blue");		
}

	extreme = clines_find_extreme_y(
			clines=lines_min_max_limited, 
			is_outline=internal);
	t_sequence_max = clines_move_x(	// Move range from pitch...2*pitch to 0...pitch
					clines=clines_find_sequence(
							clines=lines_min_max_limited, 
							start_index = extreme[0], 
							is_outline=internal),
					move_x = -pitch);
	



tooth_profile_map_backlash = 
/*		xz_map_add_backlash2(
				xzmap=tooth_profile_map_ext, 
				backlash=needed_backlash, 
				internal=internal,
				pitch=pitch);
*/
		xy_map_to_xz_map(
			convert_clines_to_pt_map(clines=t_sequence_max));
			
	echo("tooth_profile_map_backlash XY",tooth_profile_map_backlash)		;
			


	//The helix function needs the full radius of the thread.
	//tooth_profile_map_full = xz_map_add_z(xzmap=tooth_profile_map_corrected, z=minor_radius);
	// Ok tooth_profile_map_full = xz_map_add_z(xzmap=tooth_profile_map_backlash, z=minor_radius);
	tooth_profile_map_full = 
		xz_map_add_z(tooth_profile_map_backlash, //tooth_profile_map_backlash, tooth_profile_map_ext
					z=minor_radius);
	
	if(debug)
	{
		echo("	major_radius", major_radius);
		echo("	minor_radius", minor_radius);
		echo("	bore_diameter",bore_diameter);
		echo("	backlash",backlash);
		echo("	radius_ext_backlash",radius_ext_backlash);
		echo("	major_radius_backlash",major_radius_backlash);
		echo("	needed_backlash +- ",needed_backlash/2);
		echo("	profile_data",profile_data);
		echo("tooth_profile_map",tooth_profile_map);
		echo("tooth_profile_map_ext",tooth_profile_map_ext);
		echo("tooth_profile_map_backlash",tooth_profile_map_backlash);
		//echo("tooth_profile_map_corrected",tooth_profile_map_corrected);
		echo("tooth_profile_map_full",tooth_profile_map_full);
	}
	helix(
		pitch = profile_data[1],
		length = length,
		major_radius = major_radius,
		minor_radius = minor_radius,
		internal = internal,
		n_starts = n_starts,
		right_handed = right_handed,
		clearance = clearance,
		backlash = 0, //Backlash is already added to the profile 
		printify_top = printify_top,
		printify_bottom = printify_bottom,
		is_channel_thread = is_channel_thread,
		bore_diameter = bore_diameter,
		taper_angle = taper_angle,
		exact_clearance = exact_clearance,
		tooth_profile_map = tooth_profile_map_full,
		tooth_height = profile_data[3]
		);
}


function pts_2D_backlash_y_map(map = [], backlash = 0,pitch = 1) =
	len(map) == 0 || backlash == 0 ? map
	:
	let(lines = [ for(pt=map)
					[pt,
					 [pt.x, pt.y-backlash/2], true,
					 [pt.x, pt.y+backlash/2], true
					]
				],
		pts = [for( line =
				[for(pt=map)
					[pt,
					 [pt.x, pt.y-backlash/2],
					 [pt.x, pt.y+backlash/2]
					]
				])
				for(pt=line)
					pt
			],
		pts_bklsh = [for(pt=map)
					[[pt.x, pt.y-backlash/2],
					 pt,
					 [pt.x, pt.y+backlash/2]
					]
				],
		//
		//check each pt against the lines
		valids = [ for(pt_check=pts)
					let(checks = [
						for(line=lines)
							let(l_pt1=line[1],
								l_pt2=line[3]
								)
							//Return false in case the point it below x of line
							l_pt1.y <= pt_check.y && l_pt2.y >= pt_check.y ?
							//pt_check is in the range of backlashed pt_check
								pt_check.x >= l_pt1.x 
							://ptcheck is outside range of backlashed pt
							true //pt not suppressed
						],
						is_visible = 
							len(array_remove_empty(
								[for(ptv=checks)
										ptv ? [ptv] : []
								]
									) //END array_remove_empty
									)>0
						)// END let
					
					checks//is_visible ? pt_check : []
				]
			
		)
	pts_bklsh;

/*
function pts_2D_backlash_y_map(
			map = [], 
			result_map=[], 
			current_index = 0, 
			backlash = 0, 
			is_first_run = true, 
			pitch = 1) =
	len(map) == 0 || current_index < 0 || backlash == 0 ? map
	: current_index > len(map)-1 ? result_map //end of recursion
	//If we call this the first time we need to ensure there is point at y = max (pitch)
	: is_first_run ?
		pts_2D_backlash_y_map(
			map = map[len(map)-1].y == pitch ? map : concat(map, [[map[0].x,pitch ]] ), 
			result_map=[], 
			current_index = 0, 
			backlash = backlash, 
			is_first_run = false, 
			pitch = pitch)
		
	:
	// pt and pt_next represent a line we check against
	// This line is parallel to the x-axis.
	let(pt = map[current_index],
		pt_next = [pt.x, pt.y+backlash/2],
		pt_prev = [pt.x, pt.y-backlash/2],
		lines = [for(]
		new_pts = for(pt_check = map)
			pt_prev.y < pt_check.y &&  pt_next.y > pt_check.y ?
			//pt_check is in the range of backlashed pt
		
			:
			//ptcheck is outside range of backlashed pt
			[]
		)
		for(pt_check = map)
			pt_prev.y < pt_check.y &&  pt_next.y > pt_check.y ?
			//pt_check is in the range of backlashed pt
		
			:
			//ptcheck is outside range of backlashed pt
			result_map
			pts_2D_backlash_y_map(
				map = map, 
				result_map=result_map, 
				current_index = current_index+1, 
				backlash = backlash, 
				is_first_run = false, 
				pitch = pitch)
	;
	*/
	
	


function xz_map_add_backlash2(
		xzmap=[], // tooth_profile_map_ext
		backlash=0, 
		internal= false,
		pitch = 1) =
	len(xzmap) <= 0 
	|| backlash <= 0 ?
		xzmap
	:
	let(
	// To verify the input:
	// - remove empty xy pts
	// - do not sort the array, overhangs will be erased 
	xy_map = xz_map_to_xy_map(xzmap),
	array_testpts_fixed = array_remove_empty(xy_map),
	tripled_pts = triple_pts(array_testpts_fixed, pitch),
	array_testp_zeroed = lines_insert_pt_at_zero(lines=tripled_pts,pitch=3*pitch),
	array_testp_pitched = lines_add_pt_at_pitch(lines=array_testp_zeroed, pitch=3*pitch),
	lines = convert_pt_map_to_clines(profile_pt_map=array_testp_pitched),
	backlashed_lines = add_backlash(profile_cline_map=lines, backlash = backlash, is_outline = internal),
	backlashed_indexed_lines = clines_adjust_index(clines=backlashed_lines),
	lines_crossing = remove_disjoints(
					line_crossings(clines = backlashed_indexed_lines,
									do_report_line_touches = false)
				),
	existing_lines_with_crossed = 
		existing_with_crossed(existing_lines=backlashed_indexed_lines,
								crossed_lines=lines_crossing),
	lines_min_max_limited = 
		clines_adjust_index_simple(
			clines_limit_to_min_max_x(clines=existing_lines_with_crossed, 
									min_x=pitch, max_x=2*pitch)
									),
	extreme = clines_find_extreme_y(
			clines=lines_min_max_limited, 
			is_outline=internal),
	t_sequence_max = clines_move_x(	// Move range from pitch...2*pitch to 0...pitch
					clines=clines_find_sequence(
							clines=lines_min_max_limited, 
							start_index = extreme[0], 
							is_outline=internal),
					move_x = -pitch)
	
	)//end let
		xy_map_to_xz_map(
			convert_clines_to_pt_map(clines=t_sequence_max)
		)
	;
	
// ----------------------------------------------------------------
// ----------------------------------------------------------------
// TODO: - A profile may be incorrect if it has crossing lines
// ----------------------------------------------------------------
// ----------------------------------------------------------------
//array_testp = [[0.1,1],[0.2,1.9],[0.25,2],[0.35,0],[0.8,1.8],[0.9,1.8],[0.95,0.12],[0.98,0]];
//array_testp = [[0.1,1],[0.2,1.8],[0.25,2],[0.85,2],[0.88,1.8],[0.9,1.6],[0.95,0.12],[0.98,0]];
//test_pitch = 1;

whitworth_xz_map_test = [[0.00208757, 0], [0.0102326, 0.0443059], [0.0336025, 0.0828183], [0.0691414, 0.110501], [0.515902, 0.34307], [0.551441, 0.370753], [0.574811, 0.409265], [0.582956, 0.453571], [0.574811, 0.497877], [0.551441, 0.53639], [0.515902, 0.564073], [0.0691414, 0.796642], [0.0336025, 0.824325], [0.0102326, 0.862837]];
whitworth_pitch =  0.907143;


array_testp = xz_map_to_xy_map(whitworth_xz_map_test);
test_pitch  = whitworth_pitch;
backlash_input = 0.9;//0.2217392;
backlash = backlash_input < test_pitch ? backlash_input : test_pitch;
is_outline = true;
do_report_line_touches = false;
POINT_TOLERANCE = netfabb_degenerated_min()/2;
echo("test_pitch",test_pitch);
echo("backlash",backlash);
echo("array_testp unsorted",array_testp);
echo("is_outline",is_outline);

// -------------------------------------------
// To be sure of the input:
// - remove empty xy pts
// - sort the array
array_testpts_fixed = array_remove_empty(array_testp);
echo("array_testpts fixed",array_testpts_fixed);

/*
OK
ECHO: "	", [[1, 0.978261], [1.08913, 0.8], 1.08913, 1, 0.978261, 0.8, -1, 0, 9]
ECHO: "	", [[1.08913, 0.8], [1.28913, 0.7], 1.28913, 1.08913, 0.8, 0.7, -1, 1, 10]
ECHO: "	", [[1.28913, 0.7], [1.43913, 0.1], 1.43913, 1.28913, 0.7, 0.1, -1, 2, 11]
ECHO: "	", [[1.43913, 0.1], [1.48913, 0], 1.48913, 1.43913, 0.1, 0, -1, 3, 12]
ECHO: "	", [[1.48913, 0], [1.91087, 0], 1.91087, 1.48913, 0, 0, 0, 4, 13]
ECHO: "	", [[1.91087, 0], [1.99087, 0.12], 1.99087, 1.91087, 0.12, 0, 1, 5, 14]
ECHO: "	", [[1.99087, 0.12], [2, 0.978261], 2, 1.99087, 0.978261, 0.12, 1, 6, 15]
ECHO: "	", [[1.78913, 2], [1.98913, 1], 1.98913, 1.78913, 2, 1, -1, 7, 16]
ECHO: "	", [[2, 0.978261], [2, 0.978261], 2, 2, 0.978261, 0.978261, -1, 8, 17]


Notok
ECHO: "lines_min_max_limited", 9
ECHO: "	", [[1, 0.978258], [1, 0.978261], 1, 1, 0.978261, 0.978258, 1, 0, 7]
ECHO: "	", [[1, 0.978261], [1.08913, 0.8], 1.08913, 1, 0.978261, 0.8, -1, 1, 9]
ECHO: "	", [[1.08913, 0.8], [1.28913, 0.7], 1.28913, 1.08913, 0.8, 0.7, -1, 2, 10]
ECHO: "	", [[1.28913, 0.7], [1.43913, 0.1], 1.43913, 1.28913, 0.7, 0.1, -1, 3, 11]
ECHO: "	", [[1.43913, 0.1], [1.48913, 0], 1.48913, 1.43913, 0.1, 0, -1, 4, 12]
ECHO: "	", [[1.48913, 0], [1.91087, 0], 1.91087, 1.48913, 0, 0, 0, 5, 13]
ECHO: "	", [[1.91087, 0], [1.99087, 0.12], 1.99087, 1.91087, 0.12, 0, 1, 6, 14]
ECHO: "	", [[1.99087, 0.12], [2, 0.978258], 2, 1.99087, 0.978258, 0.12, 1, 7, 15]
ECHO: "	", [[1.78913, 2], [1.98913, 1], 1.98913, 1.78913, 2, 1, -1, 8, 16]
*/

// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// By adding backlash to the profile there will be missing lines at the beginning of x and
// at the end of x (pitch). So, by tripling the lines the lines in the middle will contain
// a complete backlashed profile.

function triple_pts(pts =[], pitch=1) =
	concat(
			//First segment
			pts,
			// Middle segment
			pts_move_x(pts, pitch),
			// Third segment
			pts_move_x(pts, 2*pitch)
	)
	;
tripled_pts = triple_pts(array_testpts_fixed, test_pitch);
echo("tripled points", len(tripled_pts));
for(t=tripled_pts)	echo("	", t);


// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// Check if there is a point at x=0

function lines_insert_pt_at_zero(lines=[], pitch=1.44) =
	let(first = lines[0],
		last = lines[len(lines)-1]
	)
	first.x == 0 ?
		lines
	: 
		last.x == pitch ?
			concat([0,last.y],
				lines)
		:
			concat([xy_map_calc_x_crosspoint(
					[last.x-pitch, last.y], 
					first, 
					cross_x=0)],
				lines)
		;
 
array_testp_zeroed = 
	lines_insert_pt_at_zero(lines=tripled_pts,pitch=3*test_pitch );

echo("array_testp_zeroed",array_testp_zeroed);
// -------------------------------------------
// Check if there is a point at z=pitch

function lines_add_pt_at_pitch(lines=[], pitch = 1) =
	let(last = lines[len(lines)-1],
		first = lines[0]
		)
	last.x == pitch ? 
		lines
	: 
		first.x == 0 ?
			concat(lines,
					[[pitch,first.y]])
		:
		//Muste use here the last point moved to negative pitch value
		//to allow xz_map_calc_crosspoint deliver the correct value.
		let(cross_pt=xy_map_calc_x_crosspoint(
					[last.x-pitch, last.y],
					first, 
					cross_x=pitch)
			)
			concat(lines,
					[[pitch,cross_pt.y]]
				)
		;

array_testp_pitched = lines_add_pt_at_pitch(lines=array_testp_zeroed, pitch=3*test_pitch);
echo("array_testp_pitched",array_testp_pitched);


// -------------------------------------------
// Create an array of the points with its backlash values
pts_bklsh = [for(i=[0:len(array_testp_pitched)-1])
				let(pt=array_testp_pitched[i])
				[[pt.x-backlash/2, pt.y],	// 0 : negative backlashed point
				 pt,						// 1 : original point
				 [pt.x+backlash/2, pt.y],	// 2 : positive backlashed point
				 i							// 3 : index of point in profile map
				]
			];
echo("pts_bklsh", len(pts_bklsh));
for(t=pts_bklsh)
	echo("	", t);


// Definitions must be placed before first function call which uses these.
line_def_slope_same_spot = 3;
line_def_slope_horizontal = 0;
line_def_slope_vertical_raising = 2;
line_def_slope_vertical_falling = 4;
line_def_slope_raising = 1;
line_def_slope_falling = -1;

line_def_cross_disjoint = 0; //(no intersect)
line_def_cross_intersect = 1; //intersect  in unique point I0
line_def_cross_overlap = 2; //overlap  in segment from I0 to I1


// -------------------------------------------
// Build lines based on backlashed points.
//
// Each line will be moved by backlash/2 to the left and to the right.
// This is an area, a parallelogramm (whatever in english).
// So, for each backlashed line there are four lines which distinct
// the shape of the final profile.
// A* : But each point plays its part in two parallelograms. So, the horizontal
// component should only be created once for each point (two parallelograms).
lines = convert_pt_map_to_clines(profile_pt_map=array_testp_pitched);

/*
[for(i=[0:len(pts_bklsh)-2])
			let(xz = pts_bklsh[i],
				xz_next = pts_bklsh[i+1],
				i_p = i*4
			)
			//[xz,xz_next]
			for(line =
				array_remove_empty(
				[ //Parallelogramm
				  cline_build(pt1=xz[0], pt2=xz[2], line_index = i_p, source_line_index=i),
				  cline_build(pt1=xz[2], pt2=xz_next[2], line_index = i_p+1, source_line_index=i),
				  cline_build(pt1=xz[0], pt2=xz_next[0], line_index = i_p+2, source_line_index=i),
				  i+1 == len(pts_bklsh)-1 ? //only last one, see A*
				  cline_build(pt1=xz_next[0], pt2=xz_next[2], line_index = i_p+3, source_line_index=i)
				  :[]
				])
			   )
			line
		];
*/


echo("lines", len(lines));
for(t=lines)
{
	echo("	", t);
	//draw_cline(t, col="green");
}

	



// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// add_backlash()
// This function adds backlash to a profile defined by a series of lines.
// Input:
//		profile_cline_map = collection of complex lines [[line1],[line2], ....]
//      is_outline = true if the profile describes the outline of the profile.
//		             false, if the profile describes the inline (internal threads) of the profile.
// Returns: A collection of lines backlashed but uncut so far. So resulting lines may cut each other
//          and the profile is no longer uniform.
// Notes:
//        The points of the line indicate a direction (vector). For is_outline==true,
//        the solid is on the right hand of this vector and vice versa.
//        If we add backlash, then the solid part gets wider. Therefore,
//        it is defined for each slope in which direction the line must move to get
//        the desired backlash. 
//        An exception to this are horizontal lines, which expand dependend on the slope of the
//        previous and next line.
function add_backlash(profile_cline_map=[], backlash = 0, is_outline = false) = 
	array_remove_empty(
	[ for(i=[0:len(profile_cline_map)-1])
		let(cline = profile_cline_map[i],
			line_pt_1 = cline[0],
			line_pt_2 = cline[1],
			slope = cline[6],
			line_num = cline[7],
			line_source_line_num = cline[8],
			i_next=array_get_next_circular_index(profile_cline_map, i),
			next = profile_cline_map[i_next],
			next_slope = next[6],
			i_prev=array_get_prev_circular_index(profile_cline_map, i),
			prev = profile_cline_map[i_prev],
			prev_slope = prev[6],
			backlash_half =  backlash/2,
			this_slope_raising = (slope == line_def_slope_raising 
								|| slope == line_def_slope_vertical_raising),
			this_slope_falling = (slope == line_def_slope_falling 
								|| slope == line_def_slope_vertical_falling),
			prev_slope_raising = (prev_slope == line_def_slope_raising 
								|| prev_slope == line_def_slope_vertical_raising),
			prev_slope_falling = (prev_slope == line_def_slope_falling 
								|| prev_slope == line_def_slope_vertical_falling),
			next_slope_raising = (next_slope == line_def_slope_raising 
								|| next_slope == line_def_slope_vertical_raising ),
			next_slope_falling = (next_slope == line_def_slope_falling 
								|| next_slope == line_def_slope_vertical_falling )
		)
		for(moved_lines =
		[ 	//1: Move of main line
			this_slope_raising ?
				[
				cline_move_x(cline=cline, move_x = (is_outline ? -backlash_half : backlash_half))
				]
			:
			this_slope_falling ?
				[
				cline_move_x(cline=cline, move_x = (is_outline ? backlash_half : -backlash_half))
				]
			:
			(slope == line_def_slope_horizontal) ? 
				[
				//The horiz line may get shorter or longer
				let(prev_bckl = (prev_slope == line_def_slope_horizontal) ? 0
								:
								(is_outline && prev_slope_falling
								|| !is_outline && prev_slope_raising) ? 
									-backlash_half 
									: backlash_half,
					next_bckl = (next_slope == line_def_slope_horizontal) ? 0
								:
								(is_outline && next_slope_raising
								|| !is_outline && next_slope_falling) ? 
								-backlash_half : backlash_half,
					ln_pt_distance = abs(line_pt_1.x-line_pt_2.x),
					//there was the case that the calculation of the needed length
					//resulted in very small values 5.55112e-017
					length = ln_pt_distance + prev_bckl + next_bckl,
					is_needed = !(pt_val_equal_tolerant(value1=length, value2=0)
								 || length <0)
					
				)
				is_needed ?
					cline_build(pt1=pt_move_x(point=line_pt_1, move_x=-prev_bckl), 
							pt2=pt_move_x(point=line_pt_2, move_x=next_bckl),
							line_index = line_num, source_line_index=line_num)
							/*
							[ln_pt_distance + prev_bckl + next_bckl, ln_pt_distance,prev_bckl,next_bckl, line_pt_1, pt_move_x(point=line_pt_1, move_x=prev_bckl),
							line_pt_2, pt_move_x(point=line_pt_2, move_x=next_bckl)])
							*/
				:
				[]
				]
			:
			//(slope == line_def_slope_same_spot) ? 
				[[]] //suppress spots, with a correct profile, the prev and next lines end/start in that spot
		,
			//2: Add line if necessary, for example a peak in the profile 
			//   will create a flat top with a width of the backlash
			this_slope_raising
			&& next_slope_falling 
			&& is_outline ?
				[ // Create Horizontal line
				cline_build(pt1=pt_move_x(point=line_pt_2, move_x=-backlash_half), 
								pt2=pt_move_x(point=line_pt_2, move_x=backlash_half),
								line_index = line_num, source_line_index=line_num)
				]
				
			:
			this_slope_falling 			
			&& next_slope_raising
			&& !is_outline ?
				[ // Create Horizontal line
				cline_build(pt1=pt_move_x(point=line_pt_2, move_x=-backlash_half), 
								pt2=pt_move_x(point=line_pt_2, move_x=+backlash_half),
								line_index = line_num, source_line_index=line_num)
				]
/*			:	
			slope == line_def_slope_horizontal ?
				[
				prev_slope_raising ?
					is_outline ?
						cline_build(pt1=pt_move_x(point=line_pt_1, move_x=-backlash_half), 
								pt2=line_pt_1,
								line_index = line_num, source_line_index=line_num)
					:
						[]
				:
				prev_slope_falling ?
					!is_outline ?
						cline_build(pt1=pt_move_x(point=line_pt_1, move_x=-backlash_half), 
								pt2=line_pt_1,
								line_index = line_num, source_line_index=line_num)
					:
						[]
				:
				[]

				,
				next_slope_raising ?
					!is_outline ?
						cline_build(pt1=line_pt_2, 
								pt2=pt_move_x(point=line_pt_2, move_x=backlash_half),
								line_index = line_num, source_line_index=line_num)
					:
						[]
				:
				next_slope_falling?
					is_outline ?
						cline_build(pt1=line_pt_2, 
								pt2=pt_move_x(point=line_pt_2, move_x=backlash_half),
								line_index = line_num, source_line_index=line_num)
					:
						[]
				:
				[]
				,
				]
		*/
			: //next slope is a point
				[[]]
		])//end for flattening
		for(moved_line = moved_lines)
			moved_line
		/*[moved_line, slope, next_slope, 
			slope == line_def_slope_falling||
			slope == line_def_slope_vertical_falling,
			next_slope == line_def_slope_raising|| 
			next_slope == line_def_slope_vertical_raising,
			is_outline ]
		*/
	])
	
	;


backlashed_lines = add_backlash(profile_cline_map=lines, backlash = backlash, is_outline = is_outline);
echo("backlashed lines", len(backlashed_lines));
for(t=backlashed_lines)	echo("	", t);
//fine_xy_point(point = backlashed_lines[11][0], width = 0.2, col = "red");


// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// By adding backlash, some lines may be added to the collection.
// So the indexes must be updated.

backlashed_indexed_lines = clines_adjust_index(clines=backlashed_lines);
echo("backlashed_indexed_lines", len(backlashed_indexed_lines) ) ;
for(t=backlashed_indexed_lines)
{
	echo("	", t);			
	draw_cline(t, col="green");
}






// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// Create cross points between lines of two points
// for plus and minus backlash and add them as regular
// points to be later filtered

// ----------------------------------------------------------------
// line_crossings(clines = [],do_report_line_touches=false)
// ----------------------------------------------------------------
//- Because of the preparation process before there
//  is a point at pitch=0 and one at pitch=pitch
//  at the same x. So no need to calculate crosspoints 
//  for this.
//- The first loop must only go from first to second last line
//  and the second loop must only go from second to last line.
function line_crossings(clines = [], do_report_line_touches=false) =
	array_remove_empty(
	[ for(i_1=[0:len(clines)-2])
		let(line_1 = clines[i_1],
			line_1_pt_1 = line_1[0],
			line_1_pt_2 = line_1[1],
			max_x_line_1 = line_1[2],
			min_x_line_1 = line_1[3],
			max_z_line_1 = line_1[4],
			min_z_line_1 = line_1[5],
			slope_1 = line_1[6],
			line_1_num = line_1[7],
			line_1_source_line_num = line_1[8]
		)
		//Here, xz_1 and xz_next_1 represent the first line
		for(i_2=[i_1+1:len(clines)-1]) //only lines after line_1
		let(line_2 = clines[i_2],
			line_2_pt_1 = line_2[0],
			line_2_pt_2 = line_2[1],
			max_x_line_2 = line_2[2],
			min_x_line_2 = line_2[3],
			max_z_line_2 = line_2[4],
			min_z_line_2 = line_2[5],
			slope_2 = line_2[6],
			line_2_num = line_2[7],
			line_2_source_line_num = line_2[8]
		)
		//Condition 1.1: same lines do not cross
		line_1_num != line_2_num  
		//Condition 1.2: lines of same source do not cross
		&& line_1_num != line_2_source_line_num	 
		
		//&& i_1+1 != i_2 
			//|| (i_1+1 == i_2 && (slope_1 != 0 && slope_2 != 0 && slope_1!=slope_2)
			//	)
		?
			//a cross of the lines is possible
			//[line_1, line_2]
			//[i_1+1, i_2]
			//[[line_1_packet_num,line_1_num,slope_1], [line_2_packet_num, line_2_num,slope_2]]
			line_2D_cross(line_1, line_2, do_report_line_touches=do_report_line_touches)
			
		:
			[line_def_cross_disjoint,[]]
	]);


lines_crossing = remove_disjoints(
					line_crossings(clines = backlashed_indexed_lines,
												do_report_line_touches = do_report_line_touches)
				)
				;
echo("lines_crossing", len(lines_crossing));
for(t=lines_crossing) 
{
	echo("	", t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	//draw_cline(cline=t[2], col = "blue");
	//draw_cline(cline=t[3], col = "blue");
}
/*
test_line_1 = lines[7];
draw_cline(cline=test_line_1, col = "blue");
test_line_2 = backlashed_indexed_lines[10];
draw_cline(cline=test_line_2, col = "blue");
test_cross_348 =  line_2D_cross(test_line_1, test_line_2, do_report_line_touches=do_report_line_touches);
echo("test_cross",test_cross_348 );
fine_xy_point(point = test_cross_348[1], width = 0.2, col = "red");
//line_2D_cross(line_1, line_2, do_report_line_touches=do_report_line_touches)
*/

// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// Combine the crossed lines with the rest 
// and exclude the obsolete cut lines

function existing_with_crossed(existing_lines=[], crossed_lines=[]) =
//TODO what happens if a line is being cut multiple times?
// Eine Linie kann mehrere andere schneiden.
// - Die lineiDs sind neu zu vergeben ==> äausser Schlaufe mit Funktion die die ID neu setzt
//   Es stimmen halt dann id's nicht mehr. Die neuen Id's müssen schon hier vergeben sein.
	let(cross_lines = [
			for(cross_product =
				[for(cr=crossed_lines)
					[cr[2],cr[3]]
				])
				for(cross_line=cross_product)
					cross_line
			]
		)
	len(crossed_lines) == 0 ? 
		existing_lines
	:
	len(existing_lines) == 0 ? 
		cross_lines
	:
	array_remove_empty(
	[
	for(lns =
		[for(xst_cline = existing_lines)
			let(xst_cross = 
				array_remove_empty(
				[for(crossed = crossed_lines)
					
					xst_cline[7] == undef ?
						[]
					:
					xst_cline[7]==crossed[2][7] ? //compare source line id
						crossed[2]
					:
					xst_cline[7]==crossed[3][7] ? //compare source line id
						crossed[3]
					:
						[]
					
				])) //end let()
				
			len(xst_cross)==0 ? 
				//no cross found for this line 
				[xst_cline]
			:
				//Cross point found, include only resulting lines, 
				//not the lines which created the cross point.
				array_remove_empty(
				[for(crs = xst_cross)
					len(crs)>0 ? crs : []
				])
		]
		)
		for(cline=lns)
			cline
	])
	;

existing_lines_with_crossed = 
	existing_with_crossed(existing_lines=backlashed_indexed_lines,
						  crossed_lines=lines_crossing);
echo("existing_lines_with_crossed", len(existing_lines_with_crossed));

for(t=existing_lines_with_crossed) 
{
	echo("	", t);
	//draw_cline(cline=t, col = "yellow");
	//draw_cline(cline=t[3], col = "blue");
}



// ------------------------------------------------------------------------
// All lines included in the result have at least one pt inside 1*pitch...2*pitch

// --------------------------------------------------------------------------
// extract_middle_pitch()
// Limit lines to min/max x
function clines_limit_to_min_max_x(clines=[], min_x=0, max_x=1) =
			array_remove_empty(
			[
			for(cline=clines)
				//lines in the range
				//The last point at pitch is not needed for the profile because it is
				//represented by the one at x=zero
				(cline[0].x >= min_x && cline[0].x < max_x)   
				&& 
				(cline[1].x >= min_x && cline[1].x < max_x) ?
					cline //needed in the result, no change
				:
				(cline[0].x < min_x && cline[1].x <= min_x)
				|| 
				(cline[1].x < min_x && cline[0].x <= min_x)
				|| 
				//The following two conditions would exclude a line ending in exact pitch
				//But so far the last line up to pitch is not returned (see condition below)
				//(cline[0].x >= max_x && cline[1].x > max_x) 
				//|| 
				//(cline[1].x >= max_x && cline[0].x > max_x) 
				//||
				//The last point at pitch is not needed for the profile because it is
				//represented by the one at x=zero
				(cline[0].x >= max_x || cline[1].x >= max_x) 
				?
					[] //unneded
				: 
				let(pt1= xy_map_calc_x_crosspoint(
							cline[0], 
							cline[1], 
							cross_x=min_x),
					pt2= xy_map_calc_x_crosspoint(
							 cline[0], 
							 cline[1], 
							 cross_x=max_x)
					)
				(cline[0].x < min_x && cline[1].x > max_x) ?
					//full cross over middle pitch => two cross points
						cline_build(pt1=pt1, pt2=pt2, line_index = cline[7], source_line_index=cline[7])
				: cline[0].x < min_x ?
					cline_build(pt1=pt1, pt2=cline[1], line_index = cline[7], source_line_index=cline[7])
				: 
				cline_build(pt1=cline[0], pt2=pt2, line_index = cline[7], source_line_index=cline[7])
			]
			)
		;

lines_min_max_limited = 
	clines_adjust_index_simple(
		clines_limit_to_min_max_x(clines=existing_lines_with_crossed, 
									min_x=test_pitch, max_x=2*test_pitch)
	)
	;
echo("lines_min_max_limited",len(lines_min_max_limited),"min_x=", test_pitch,"max_x=" ,2*test_pitch);

for(t=lines_min_max_limited) 
{
	echo("	", [t,t[1][0] == 2*test_pitch, t[1][0] - 2*test_pitch]);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	draw_cline(cline=t, col = "Blue");
	//draw_cline(cline=t[3], col = "blue");		
	//echo(t[7], , t[1][0] - 2*test_pitch);
}


// -------------------------------------------
// -------------------------------------------
// -------------------------------------------
// Remove the unused lines from backlash
// Each line in the list can be a fragment which needs to be deleted or a part of the final profile.
// A unnneded fragment can appear right at the beginning/end of the list.
// Unneeded fragements may appear as a sequence of lines (thread) in the list.
// So, the challenge is to find the valid profile thread.
// A jump in between two lines indicate a "break" of the thread.
// One could find a line with max(y) of all lines (is_outline = true) and then go from there.
// !!! Check each line if it ends/breaks ==> delete (Except last one)
// Possible problem: a series of lines  (which) are going to be deleted may
// merge into the wanted thread/lines.
// Backlash does not change the maximum heigth/depth (y) of the profile.
// With is_outline=true, lines with max_y will always exist because with raising backlash
// peaks get wider. In contrast with is_outline=false, where peaks get narrower but
// minimus get wider. So if we find a line with extreme value, it will be in the 
// resulting profile.




// -----------------------------------------------------------------------------------------
// clines_find_extreme_y(...)
// Finds the maximum (is_outline==true) or the minimum (is_outline==false) of
// all clines and the index of this line. 
// Return extreme_y[ 4, //index of line in "clines" with the maximum
//                  0.44 // extreme of all first points
//                  1.22 // extreme of all second points 
//                  ]
function clines_find_extreme_y(clines=[], is_outline=true, current_index=-1, 
								extreme_y=[-1,1,1]
								) =
	//Initialization
	let(inf = 1e200 * 1e200,
		init_extreme_y = [-1, is_outline ? -inf : inf, is_outline ? -inf : inf],
		previous_extreme_y = current_index < 0 ? init_extreme_y : extreme_y)
	//Break criteria
	len(clines) <= 0 ?
		init_extreme_y //nothing to do
	: 
	current_index > len(clines)-2 ? 
		previous_extreme_y //recursion finished
	:
	(len(clines[current_index+1][0]) <= 0
	|| len(clines[current_index+1][1]) <= 0) ?
		//Skip incomplete lines
		clines_find_extreme_y(
			clines=clines, 
			internal = internal,
			current_index= current_index+1, 
			extreme_y= previous_extreme_y
		)
	:
	let(extreme_y_pt1 = previous_extreme_y[1],
		extreme_y_pt2 = previous_extreme_y[2],
		next_index = current_index+1,
		next_y_pt1 = clines[next_index][0].y,
		next_y_pt2 = clines[next_index][1].y,
		new_extreme_pt1 = 
			pt_find_extreme_y(
				pt_y = next_y_pt1, 
				current_extreme_y = extreme_y_pt1,
				is_outline=is_outline)
			,
		new_extreme_pt2 = 
			pt_find_extreme_y(
				pt_y = next_y_pt2, 
				current_extreme_y = extreme_y_pt2,
				is_outline=is_outline)
			,
		found_index = (
			next_y_pt1 > max(extreme_y_pt1,extreme_y_pt2) 
			|| next_y_pt2 > max(extreme_y_pt1,extreme_y_pt2) ?
				//new line is somewhat higher
				is_outline ? next_index : extreme_y[0]
			:
			next_y_pt1 < min(extreme_y_pt1, extreme_y_pt2) 
			|| next_y_pt2 < min(extreme_y_pt1, extreme_y_pt2) ?
				//new line is somewhat lower
				is_outline ? extreme_y[0] : next_index
			:			
			(next_y_pt1 == extreme_y_pt1 && next_y_pt2 == extreme_y_pt2)
			|| (next_y_pt1 == extreme_y_pt2 && next_y_pt2 == extreme_y_pt1) ?
				//equal case (both directions), take the one we have already
				extreme_y[0]
			:
			(next_y_pt1 == max(extreme_y_pt1, extreme_y_pt2) 
			|| next_y_pt2 == max(extreme_y_pt1, extreme_y_pt2)) ?
				//one of the new points is at current maximum
				(next_y_pt1 < min(extreme_y_pt1, extreme_y_pt2) 
				|| next_y_pt2 < min(extreme_y_pt1, extreme_y_pt2)) ?
					//new line is below old line
					is_outline ? extreme_y[0] : next_index
				:
					is_outline ? next_index : extreme_y[0]
			:
			(next_y_pt1 == min(extreme_y_pt1, extreme_y_pt2) 
			|| next_y_pt2 == min(extreme_y_pt1, extreme_y_pt2)) ?
				//one of the new points is at current minimum
				(next_y_pt1 > max(extreme_y_pt1, extreme_y_pt2)
				|| next_y_pt2 > max(extreme_y_pt1, extreme_y_pt2)) ?
					//new line is above old line
					is_outline ? next_index : extreme_y[0]
				:
					is_outline ? extreme_y[0] : next_index
			:
				//new line is in min/max range of current but below
				is_outline ? extreme_y[0] : next_index 
			)
	)
	clines_find_extreme_y(
		clines=clines, 
		is_outline = is_outline,
		current_index= next_index, 
		extreme_y= [found_index, clines[found_index][0].y, clines[found_index][1].y]
	)
	;
		
function pt_find_extreme_y(pt_y=0, current_extreme_y=1, is_outline=false) = 
	pt_y == undef ?
		current_extreme_y
	:
		is_outline ?
			max(pt_y,
				current_extreme_y)
		:
			min(pt_y,
				current_extreme_y)
	;

// ------------------------------------------------------------------------------------------
// Each line has an endpoint at which another line should be connected/following
// 
function clines_find_connected(clines=[], cline_index = 0, seek_direction = -1,
			cur_index=0, num_worked_lines = 0, connected_lines=[]) =
	len(clines) == 0 ?
		connected_lines
	: num_worked_lines >= len(clines)-1 ? //End/Safety check
		connected_lines
	: seek_direction == 0 ? //forward/backward finished
		connected_lines
	:	
	let(cline = clines[cline_index],
		candidate_index = (num_worked_lines == 0 ? cline_index+seek_direction : cur_index),
		candidate_line=clines[candidate_index],
		candidate_pt = seek_direction > 0 ? 
						candidate_line[0] : candidate_line[1],
		pt = seek_direction > 0 ? cline[1] : cline[0],
		is_connected= pt_equal_tolerant(pt, candidate_pt) 
	)
	//[candidate_index, candidate_pt1]
	
		clines_find_connected(
			clines=clines, 
			cline_index = cline_index,
			seek_direction = seek_direction,
			cur_index=seek_direction > 0 ?
				array_get_next_circular_index(clines, candidate_index) 
				: array_get_prev_circular_index(clines, candidate_index), 
			num_worked_lines = num_worked_lines+1, 
			connected_lines= (is_connected ? 
								seek_direction > 0 ?
									concat(connected_lines, [candidate_line]) 
									: concat([candidate_line], connected_lines ) 
								: connected_lines//[connected_lines,cline_index,candidate_index,candidate_pt,pt] //concat(connected_lines, candidate_line)
							 )//connected_lines)
			)
			
	;
	
// Suppress lines with "lower" value if a line has more than one sequencing line.
function find_extreme_of_connected(connected_lines = [], is_outline=true, seek_direction = 1,
					current_index=-1, current_max_connected=[]) =
	len(connected_lines) == 0 ?
		current_max_connected
	: current_index >= len(connected_lines) ? //End/Safety check
		current_max_connected
	: seek_direction == 0 ?
		current_max_connected
	:	
	let(current_max_connected = 
			len(current_max_connected) == 0 ?
				connected_lines[0]  //to begin, take the first one
			:
				let(pt_current = seek_direction > 0 ?
						current_max_connected[1] : current_max_connected[0],
					pt_next = seek_direction > 0 ?
						connected_lines[current_index][1] : connected_lines[current_index][0]
				)
			is_outline ?
				pt_current.y > pt_next.y ? 
					current_max_connected : connected_lines[current_index]
			:
				pt_current.y < pt_next.y ? 
					current_max_connected : connected_lines[current_index]
		)
	find_extreme_of_connected(
		connected_lines = connected_lines, 
		is_outline=is_outline, 
		seek_direction = seek_direction,
		current_index= (current_index == -1 ? 0 : current_index+1),
		current_max_connected=current_max_connected) 
					
		;	
		
		
extreme = clines_find_extreme_y(
			clines=lines_min_max_limited, 
			is_outline=is_outline);
echo("extreme",len(extreme),extreme);
test_index = extreme[0];
test_direction = 1;
test_lines = lines_min_max_limited;


connected = clines_find_connected(
							clines=test_lines, 
							cline_index = test_index,
							seek_direction=test_direction);		
echo("connected", len(connected), test_index, test_lines[test_index]);
for(t=connected) 
{
	echo("	", t);
}	

extreme_of_connected = find_extreme_of_connected(
								connected_lines = connected, 
								is_outline=is_outline, 
								seek_direction = test_direction);
echo("extreme_of_connected", len(extreme_of_connected));
echo("	", extreme_of_connected);



test_reverse=clines_find_sequence(
							clines=test_lines, 
							is_outline=is_outline,
							start_index = test_index, 
							current_index=test_index, 
							num_worked_lines = 0, 
							clines_sequence=[],
							forward_seek_is_done = true,
							backward_seek_is_done = false
							);
echo("test_reverse", len(test_reverse), test_index);
for(t=test_reverse) 
{
	echo("	", t);
}	

// ---------------------------------------------------------------------------------
// The final sequence of lines gives the profile.
//  - There may be a loop in the lines. So we have to take the longer thread in the end
// - There may be lines overlapping each other (or even totally equal)
function clines_find_sequence(clines=[], is_outline=true, start_index = 0, 
	current_index=0, num_worked_lines = 0, clines_sequence=[],
	forward_seek_is_done = false, backward_seek_is_done = false) =
	len(clines) == 0 ?
		clines_sequence
	: num_worked_lines >= 2*len(clines) ? //End/Safety check (fwd/bwd => 2*)
		clines_sequence
	:
	forward_seek_is_done && backward_seek_is_done ?
		clines_sequence
	:
	num_worked_lines == 0 ?
		//start with forward seek
		clines_find_sequence(
			clines=clines_mark_used(clines, start_index, used=true), 
			is_outline=is_outline,
			start_index = start_index, 
			current_index= start_index, 
			num_worked_lines = 1, 
			clines_sequence= clines[start_index],
			forward_seek_is_done = false,
			backward_seek_is_done = false
		)
	:
	num_worked_lines == len(clines) ?
		//Switch to backward seek
		clines_find_sequence(
			clines=clines, 
			is_outline=is_outline,
			start_index = start_index, 
			current_index= start_index, //reset to start
			num_worked_lines = num_worked_lines+1, 
			clines_sequence = clines_sequence, //start line is already included
			forward_seek_is_done = true,
			backward_seek_is_done = false
		)
	
	let(seek_direction = !forward_seek_is_done ? 1
						: !backward_seek_is_done ? -1
						: 0,
		cur_cline = clines[current_index],
		cur_pt1 = cur_cline[0],
		cur_pt2 = cur_cline[1],
		connected_lines = clines_find_connected(
							clines=clines, 
							cline_index = current_index,
							seek_direction = seek_direction),
		next_unused_cline = clines_find_next_used(
								clines=clines, 
								start_index=current_index, 
								is_used=false, 
								seek_direction=seek_direction
								)
							
	)
	len(connected_lines) <= 0 ?
		//No connected found => continue seek at next unused line
		next_unused_cline[0] ?
			//there is a further unused line
			clines_find_sequence(
				clines=clines, 
				is_outline=is_outline,
				start_index = start_index, 
				current_index=next_unused_cline[1], 
				num_worked_lines = num_worked_lines + 1, 
				clines_sequence= seq_lines,
				forward_seek_is_done = forward_seek_is_done,//true,
				backward_seek_is_done = num_worked_lines == 2*len(clines)
			)
		:
		//There are no other unused lines.
		//Seek direction does not matter, because all are consumed.
		clines_sequence

	//	&& (forward_seek_is_done && backward_seek_is_done )?
		//no connected lines found, thread ends
	//	seq_lines
		//[clines_sequence, 2,cline_index,seek_direction,forward_seek_is_done,backward_seek_is_done]
	:
		let(next_connected = find_extreme_of_connected(
								connected_lines = connected_lines, 
								is_outline=is_outline, 
								seek_direction = seek_direction)
		)
		
		
		//TODO:
		//Below we jump to the next connected "next_connected[7]". By doing this some lines my be left out.
		//So, it is necessary to go through each line for every sequence step because, after
		//applying backlash and cutting, the order (for x-value) of the correctly indexed lines is 
		//no longer guaranteed.A connected line my even be before/after the current line (index wise) 
		//for forwardseek and backwardseek. 
		//- The function clines_find_connected() goes over all clines and returns a collection of
		//  all connected lines. This is ok and solves the "unordered" problem.
		//  But the line may be at index 0 or at len(clines)-1 then and the the algorithm stops. 
		//  These limits should be eliminated. It should be that the algorithm seeks 
		//  as long it finds something and then seeks the other way around from the start point.
		//  num_processed is the limit
		//- We may mark a processed line
		//
		//- find_extreme_of_connected() should return the "longest" line if two lines overlap (any angle/slope)
		//- lines_min_max_limited() returns lines which are very near (-5e-007) but not equal to pitch.
		//  "lines_min_max_limited", 15, "min_x=", 0.907143, "max_x=", 1.81429
		//  ", [[[1.81071, 0.582956], [1.81429, 0.582299], 1.81429, 1.81071, 0.582956, 0.582299, -1, 8, 23], false, -5e-007]
		//  implement the tolerant comparisons in lines_min_max_limited (at least for Max value)

		
		//lines_min_max_limited  -5e-007]
		
		clines_find_sequence(
				clines=clines, 
				is_outline=is_outline,
				start_index = start_index, 
				current_index=next_connected[7], //continue at the connected.
				num_worked_lines = num_worked_lines + 1, 
				clines_sequence=
					seek_direction > 0 ?
						concat(seq_lines, [next_connected])
					:	concat([next_connected], seq_lines)
					,
				forward_seek_is_done = forward_seek_is_done,
				backward_seek_is_done = num_worked_lines == 2*len(clines)
			)

	;


					

//[[[[[[[[[[[[[[[[[[[[[[[[[[[[
//[[[[[[[[[[[[[[[[[[[[[[[[[[[

t_found_sequence = clines_find_sequence(
							clines=lines_min_max_limited, 
							start_index = extreme[0], 
							is_outline=is_outline);
echo("t_found_sequence", len(t_found_sequence));
for(t=t_found_sequence) 
{
	echo("	",t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	draw_cline(cline=t, col = "Red");
	//draw_cline(cline=t[3], col = "blue");
}

t_moved_sequence = clines_move_x(	// Move range from pitch...2*pitch to 0...pitch
					clines=t_found_sequence,
					move_x = -test_pitch); 
echo("t_moved_sequence", len(t_moved_sequence));
for(t=t_moved_sequence) 
{
	echo("	",t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	draw_cline(cline=t, col = "Red");
	//draw_cline(cline=t[3], col = "blue");
}

/*		
function all_sequences() =
		[
		for(i=[0:len(existing_lines_with_crossed)-1])
			let(t_sequences = clines_find_sequence(
							clines=existing_lines_with_crossed, 
							start_index = i, 
							is_outline=is_outline)
			)
		t_sequences
		]
		;
		
t_sequences = all_sequences();
		
echo("t_sequences", len(t_sequences), test_index);
for(line_seqs=t_sequences) 
{
	echo("	", "line_seqs", len(line_seqs));
	for(sequence=line_seqs) 
	{
		echo("	", "sequence", len(sequence));
		for(t=sequence) 
		{
			echo("		", t);
			//fine_xy_point(point = t[1], width = 0.2, col = "red");
			//draw_cline(cline=t, col = "Red");
			//draw_cline(cline=t[3], col = "blue");
		}
	}
}
for(t=t_sequences[6][0]) 
		{
			echo("	ff	", t);
			//fine_xy_point(point = t[1], width = 0.2, col = "red");
			draw_cline(cline=t, col = "Red");
			//draw_cline(cline=t[3], col = "blue");
		}
*/
/*
for(sequence=line_seqs) 
	echo("	", "t_sequence", len(sequence);
	for(t=sequence) 
		echo("		", t);
		//fine_xy_point(point = t[1], width = 0.2, col = "red");
		draw_cline(cline=t, col = "Red");
		//draw_cline(cline=t[3], col = "blue");
*/




// -----------------------------------------------------------------------------------------
// delete unwanted : Not working for complex shapes/overhangs

//TODO: ECHO: "	", [[0.6, 0], [0.6, 0], 0.6, 0.6, 0, 0, 0, 5, 5] ???
function lines_cleanup(clines = [], is_outline=true) =
	array_remove_empty(
	[ for(i_1=[0:len(clines)-1])
		let(line_1 = clines[i_1],
			line_1_pt_1 = line_1[0],
			line_1_pt_2 = line_1[1],
			max_x_line_1 = line_1[2],
			min_x_line_1 = line_1[3],
			max_z_line_1 = line_1[4],
			min_z_line_1 = line_1[5],
			slope_1 = line_1[6],
			line_1_num = line_1[7],
			line_1_source_line_num = line_1[8]
		)
		//Here, xz_1 and xz_next_1 represent the first line
		for(i_2=[0:len(clines)-1]) //only lines after line_1
		let(line_2 = clines[i_2],
			line_2_pt_1 = line_2[0],
			line_2_pt_2 = line_2[1],
			max_x_line_2 = line_2[2],
			min_x_line_2 = line_2[3],
			max_z_line_2 = line_2[4],
			min_z_line_2 = line_2[5],
			slope_2 = line_2[6],
			line_2_num = line_2[7],
			line_2_source_line_num = line_2[8]
		)
		
		//TODO : is_outline
		//Condition 1: lines do not eliminate themselves
		i_1 != i_2  
		&&
		//Condition 2 : Suppress if something is below
		((line_1_pt_1.y >= line_2_pt_1.y && line_1_pt_2.y >= line_2_pt_2.y)
		&& (line_1_pt_1.x <= line_2_pt_1.x && line_1_pt_2.x >= line_2_pt_2.x)
		)	?
		line_2
		:
		[]
	]);
	
	
lines_to_delete = lines_cleanup(clines = lines_min_max_limited, is_outline=is_outline);
echo("lines_to_delete", len(lines_to_delete));
for(t=lines_to_delete) 
{
	echo("	", t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	//draw_cline(cline=t, col = "DarkGreen");
	//draw_cline(cline=t[3], col = "blue");
}


function remove_lines(clines = [], to_delete_clines=[]) =
	[ for(line_1=clines)
		let(line_1_num = line_1[7],
			to_delete = 
				array_remove_empty(
				[
				for(line_2=to_delete_clines) //only lines after line_1
					let(line_2_num = line_2[7])
					line_1_num == line_2_num ?
						line_2 : []
				])
		)
		if(len(to_delete)==0)
			line_1
	];

lines_needed = remove_lines(clines = t_sequence_max, to_delete_clines=lines_to_delete);
echo("lines_needed", len(lines_needed));
for(t=lines_needed) 
{
	echo("	", t);
	//fine_xy_point(point = t[1], width = 0.2, col = "red");
	//draw_cline(cline=t, col = "DarkGreen");
	//draw_cline(cline=t[3], col = "blue");
}



// -------------------------------------------
//
// - From itself, the lines do not cross. It is because of backlash.
// - A line gives two "shadows" of itself at +- backlash/2
// - With two lines and each line has two "shadows" there are four cut possibilities.
// - The "shadows" with the same backlash direction of the two lines will never cut.
//   So, only two possibilities.
// - Which "shadows" cut depends on the slopes.
//   For "V" shapes line1+backlash cuts line2-backlash. 
//   ==> Result is [[line1_pt1,cross_pt], [cross_pt, line2_pt2]]
//   For "peak" shapes, the profile gets wider. For a cut,
//   really large backlash values are needed. But it is possible.
//   ==> Result ????
lines_crossed = [];//lines_crossing

//TODO: problem with negative z-values ??

//line_2D_is_cross(line1, line2)

//echo("lines_crossed", len(lines_crossed));
//for(t=lines_crossed) echo("	", t);


test_point_00 = [0,0];
test_point_11 = [1,1];
test_point_21 = [2,1];
test_point_12 = [1,2];
test_point_01 = [0,1];
test_point_10 = [1,0];
test_line_00 = cline_build(test_point_00,test_point_00,1,33);
test_line_11 = cline_build(test_point_11,test_point_11,2,33);
test_line_12 = cline_build(test_point_00,test_point_12,3,33);
test_line_21 = cline_build(test_point_00,test_point_21,4,33);
test_line_10_01 = cline_build(test_point_10,test_point_01,5,33);
test_line_00_11 = cline_build(test_point_00,test_point_11,6,33);

test_lines_cross = [[test_line_00,test_line_00],
					[test_line_00,test_line_11],
					[test_line_00,test_line_10_01],
					[test_line_11,test_line_10_01],
					[test_line_00_11,test_line_10_01],
					[cline_build([0.12,0.98],[2,1],7,88),cline_build([1.5,0.9],[1.5,1.1],7,89)],
					[cline_build([0.1,0.6],[0.1,0.8],7,90),cline_build([0.1,0.7],[0.1,0.9],7,91)]
				   ];
/*
echo("test_lines_cross2");
for(test_candidates = test_lines_cross)	
{	
	echo("	", test_candidates);
	echo("	==>", line_2D_cross(test_candidates[0],test_candidates[1], do_report_line_touches=false));
}
*/
//cross_lines_result = remove_disjoints(get_crossings(line_touples=test_lines_cross));
//	for(cross_lines = cross_lines_result)
//		echo("	", cross_lines);


function remove_disjoints(cross_lines_result) =
			array_remove_empty(
			[
			for(cross_candidate = cross_lines_result)
				len(cross_candidate) > 0 && cross_candidate[0]!= line_def_cross_disjoint ?
					cross_candidate : []
			]
			)
			;

function get_crossings(line_touples=[]) =
			[for(line_candidates = line_touples)
				line_2D_cross(line_candidates[0],line_candidates[1], do_report_line_touches=do_report_line_touches)
			];

// -------------------------------------------
// Return: [	0=disjoint (no intersect)
//         		1=intersect  in unique point I0
//         		2=overlap  in segment from I0 to I1
//			,
//          intersection point,
//          new_cline_1,
//          new_cline_2			
//          ]
function line_2D_cross(cline_1, cline_2, do_report_line_touches=false) =
	let(line_1_pt_1 = cline_1[0],
		line_1_pt_2 = cline_1[1],
		max_x_line_1 = cline_1[2],
		min_x_line_1 = cline_1[3],
		max_z_line_1 = cline_1[4],
		min_z_line_1 = cline_1[5],
		slope_1 = cline_1[6],
		line_1_num = cline_1[7],
		line_1_packet_num = cline_1[8],
		line_2_pt_1 = cline_2[0],
		line_2_pt_2 = cline_2[1],
		max_x_line_2 = cline_2[2],
		min_x_line_2 = cline_2[3],
		max_z_line_2 = cline_2[4],
		min_z_line_2 = cline_2[5],
		slope_2 = cline_2[6],
		line_2_num = cline_2[7],
		line_2_packet_num = cline_2[8],
		result_disjoint = [true, line_def_cross_disjoint,[], cline_1, cline_2],
		line_1_is_a_point = (slope_1 == line_def_slope_same_spot),
		line_2_is_a_point = (slope_2 == line_def_slope_same_spot),
		line_1_line_2_same_spot = line_1_is_a_point && line_2_is_a_point && pt_equal(line_1_pt_1, line_2_pt_1),
		pt1_line1_is_collin_line2 = is_collinear_tolerant(line=[line_2_pt_1, line_2_pt_2], point_check=line_1_pt_1),
		pt2_line1_is_collin_line2 = is_collinear_tolerant(line=[line_2_pt_1, line_2_pt_2], point_check=line_1_pt_2),
		pt1_line2_is_collin_line1 = is_collinear_tolerant(line=[line_1_pt_1, line_1_pt_2], point_check=line_2_pt_1),
		pt2_line2_is_collin_line1 = is_collinear_tolerant(line=[line_1_pt_1, line_1_pt_2], point_check=line_2_pt_2),
		pt1_line_1_is_on_line_2 = pt1_line1_is_collin_line2 
									&& pt_on_collinear_line(pt=line_1_pt_1, line=[line_2_pt_1,line_2_pt_2]),
		pt2_line_1_is_on_line_2 = pt2_line1_is_collin_line2 
									&& pt_on_collinear_line(pt=line_1_pt_2, line=[line_2_pt_1,line_2_pt_2]),
		pt1_line_2_is_on_line_1 = pt1_line2_is_collin_line1 
									&& pt_on_collinear_line(pt=line_2_pt_1, line=[line_1_pt_1,line_1_pt_2]),
		pt2_line_2_is_on_line_1 = pt2_line2_is_collin_line1 
									&& pt_on_collinear_line(pt=line_2_pt_2, line=[line_1_pt_1,line_1_pt_2]),
		pt1_line_1_touch_line_2 = pt1_line1_is_collin_line2 && pt1_line_1_is_on_line_2 ?
									line_2D_cross_touch_collinear_pt(line=cline_2, point=line_1_pt_1, do_report_line_touches = do_report_line_touches)
									:result_disjoint,
		pt2_line_1_touch_line_2 = pt2_line1_is_collin_line2 && pt1_line_1_is_on_line_2 ?
									line_2D_cross_touch_collinear_pt(line=cline_2, point=line_1_pt_2, do_report_line_touches = do_report_line_touches)
									:result_disjoint,
		pt1_line_2_touch_line_1 = pt1_line2_is_collin_line1 && pt1_line_2_is_on_line_1 ?
									line_2D_cross_touch_collinear_pt(line=cline_1, point=line_2_pt_1, do_report_line_touches = do_report_line_touches)
									:result_disjoint,
		pt2_line_2_touch_line_1 = pt2_line2_is_collin_line1 && pt2_line_2_is_on_line_1 ?
									line_2D_cross_touch_collinear_pt(line=cline_1, point=line_2_pt_2, do_report_line_touches = do_report_line_touches)
									:result_disjoint,
		cross_result = (
			line_1_is_a_point && line_2_is_a_point ?
				//CASE 1: line 1 and line 2 are points
				line_1_line_2_same_spot ?
					do_report_line_touches ? 
						[true, line_def_cross_intersect, line_1_pt_1, cline_1, cline_2] //Result: two points at the same place
					:	result_disjoint //Result: two lines which are points should not be reported as cross
				: 	result_disjoint //Result: two distinct points
			: 
			line_1_is_a_point ?
				//CASE 2: line 1 is a point, line 2 is a line
				pt1_line1_is_collin_line2 ?
					//line_1 (a point) is collinear to line_2
					pt1_line_1_is_on_line_2 ?
						//line_2 is being cut by line_1(a point) in line_1_pt_1
						// ==> pt1_line_1_touch_line_2
						result_disjoint
						//TODO
						//Parse touch: create Result with other line
						
						
						
						
					: result_disjoint //Result: line 1 (point) is collinear to line_2 but is not in line_2's range.
				:result_disjoint //Result: line 1 is a point and is not collinear to line2 ==> no cross
			: 
			line_2_is_a_point ?
				//CASE 3: line 2 is a point, line 1 is a line
				pt1_line2_is_collin_line1 ?
					//line_2 (a point) is collinear to line_1
					pt1_line_2_is_on_line_1 ?
						//line_1 is being cut by line_2(a point) in line_2_pt_1
						//TODO
						pt1_line_2_touch_line_1
					: result_disjoint //Result: line 2 (point) is collinear to line_1 but is not in line_1's range.
				:result_disjoint //Result: line 2 is a point and is not collinear to line_1 ==> no cross
				
			: //line 1 is a line
			//CASE 4: Both lines have two distinct points ==> two lines

				// Condition 4.1: If x of the lines does not overlap. A cross is not possible
				(!(max_x_line_2 < min_x_line_1 || min_x_line_2 > max_x_line_1 ))
				//Condition 4.2: If z does not overlap, across is not possible
				&& (!(max_z_line_1 < min_z_line_2 || max_z_line_2 < min_z_line_1 ))
					?
					//CASE 5:
					// A cross is possible since line_2 is somehow in range of line_1.
					// If any collinear is true, then calculating the cross point is not necessary (speed)
					pt1_line2_is_collin_line1 || pt2_line2_is_collin_line1 ?
						//CASE 5.1:
						// Some collinearity
						pt1_line2_is_collin_line1 && pt2_line2_is_collin_line1 ?
							//CASE 5.1.1:
							//The two lines are collinear ==> overlap
							//TODO do_report_line_touches
							//Because of condition 3.2 at least one pt must be on the other line 
							//[line_def_cross_overlap,[]]   // Result:
							let(overlap =
								line_2D_overlap(line_1=cline_1, line_2=cline_2, do_report_line_touches=do_report_line_touches) )
							[false, 
								overlap[0], //status
								overlap[1], //cross point
								overlap[2], //line1
								overlap[3], //line2
								overlap
							]
						: 
						pt1_line2_is_collin_line1 ?
							//CASE 5.1.2:
							//line_2_pt_1 is collinear with line 1, line_2 may be touching line_1 in line_2_pt_1
							//since pt1_line_2_touch_line_1 is being created with function
							// line_2D_cross_touch_collinear_pt() do_report_line_touches is already evluated
							pt1_line_2_touch_line_1[1] == line_def_cross_disjoint ?
								result_disjoint  //Result: collinear but no cross
							:
							pt1_line_2_touch_line_1[2] ?
								//line_2 touches line_1 on pt1_line_1==line_2_pt_1
								[true,line_def_cross_intersect,[line_1_pt_1],[cline_1,cline_2]]
							:
							pt1_line_2_touch_line_1[3] ?
								//line_2 touches line_1 on pt2_line_1==line_2_pt_1
								[true,line_def_cross_intersect,[line_1_pt_2],[cline_1,cline_2]]
							:
								//line_2 touches line_1 anywhere on the lenght of line_1 in pt1_line2
								//directions of lines are clear
								[true,line_def_cross_intersect,[line_2_pt_1],[cline_1,cline_2]]
								
						:
							//CASE 5.1.3:
							//line_2_pt_2 is collinear with line 1, line_2 may be touching line_1 in line_2_pt_2
							pt1_line_2_touch_line_1[1] == line_def_cross_disjoint ?
								result_disjoint  //Result: collinear but no cross
							:
							pt1_line_2_touch_line_1[2] ?
								//line_2 touches line_1 on pt1_line_1==line_2_pt_1
								[true, line_def_cross_intersect,[line_1_pt_1],[cline_1,cline_2]]
							:
							pt1_line_2_touch_line_1[3] ?
								//line_2 touches line_1 on pt2_line_1==line_2_pt_1
								[true, line_def_cross_intersect,[line_1_pt_2],[cline_1,cline_2]]
							:
								//line_2 touches line_1 anywhere on the lenght of line_1 in pt1_line2
								//directions of lines are clear
								[true, line_def_cross_intersect,[line_2_pt_1],[cline_1,cline_2]]
					:
					pt1_line1_is_collin_line2 || pt2_line1_is_collin_line2 ?
						//CASE 5.2:
						result_disjoint
					:	
					//CASE 5.3
						// No collinearity between the line points.
						// This also means the line endpoints do not touch (do_report_line_touches not needed)
						let(calc_cross = line_2D_is_cross(cline_1, cline_2))
						[false, calc_cross[0], calc_cross[1], calc_cross] // Result: calculate cross
					
					// Possible: 1. calc cross
					// 2. if no cross, end routine
					// 3 check points against calc_cross if is collinear "do_report_line_touches"
					// 4. return calc cross if not touching 
					
					//Well, 
					
					
				: result_disjoint //Result: No cross possible, the lines are not near each other
		) // end cross_pt variable
	) // end let
	cross_result[0] ?
		[cross_result[1], // cross status
		 cross_result[2], // cross point
		 cross_result[3], // cline1
		 cross_result[4]  // cline2
		]
	:
		[cross_result[1], // cross status
		 cross_result[2], // cross point
		 cline_build(line_1_pt_1,cross_result[2],line_1_num, line_1_num),
		 cline_build(cross_result[2],line_2_pt_2,line_2_num, line_2_num)
		 /*,
		 !(max_x_line_2 < min_x_line_1 || min_x_line_2 > max_x_line_1 ),
		 (!(max_z_line_1 < min_z_line_2 || max_z_line_2 < min_z_line_1 )),
		 pt1_line2_is_collin_line1 || pt2_line2_is_collin_line1,
		 pt1_line2_is_collin_line1 && pt2_line2_is_collin_line1,
		 cline_1,cline_2,
		 line_2D_overlap(line_1=cline_1, line_2=cline_2, do_report_line_touches=do_report_line_touches),
		 5555
		 */
		 /*
		 cross_result[2], // line
		 cross_result[3],
		 cross_result[4],
		 cross_result[5],
		 cross_result[6],
		 cross_result[7],
		 "3333", pt1_line2_is_collin_line1, line_1_pt_1, line_1_pt_2, line_2_pt_1,
		 "5555", is_left_raw(line_1_pt_1, line_1_pt_2, line_2_pt_1)
		 */
		]
	// TODO : return cut lines
	;

/*
 [[], 
 [[[0.4, 2], [1.4, 2], 1.4, 0.4, 2, 2, 0, 7, 6], 
  [[1.4, 2], [2.4, 2], 2.4, 1.4, 2, 2, 0, 15, 14]], 
  
  [[0.4, 2], [[[0.4, 2], [1.4, 2], 1.4, 0.4, 2, 2, 0, 7, 6], [[1.4, 2], [2.4, 2], 2.4, 1.4, 2, 2, 0, 15, 14]], 
  undef, undef, undef, undef, 0, 7, 7], [[[[0.4, 2], [1.4, 2], 1.4, 0.4, 2, 2, 0, 7, 6], 
  [[1.4, 2], [2.4, 2], 2.4, 1.4, 2, 2, 0, 15, 14]], [2.4, 2], undef, undef, undef, undef, 0, 15, 15], 
  
  true, true, true, true, 
  [[0.4, 2], [1.4, 2], 1.4, 0.4, 2, 2, 0, 7, 6], 
  [[1.4, 2], [2.4, 2], 2.4, 1.4, 2, 2, 0, 15, 14], 
  
  [0, [], [[[0.4, 2], [1.4, 2], 1.4, 0.4, 2, 2, 0, 7, 6], [[1.4, 2], [2.4, 2], 2.4, 1.4, 2, 2, 0, 15, 14]]]]
 
*/

// line_2D_overlap()
// The function assumes line_1 and line_2 are collinear
function line_2D_overlap(line_1=[[],[]], line_2=[[],[]], do_report_line_touches=false) =
	let(
	//Correction 1:
	//If the lines are vertical, then x is the same for all line points.
	//If ine_1 is vertical, then line_2 is vertical too (assumption of this function).
	//But the algorithm expects changing(raising) x values to find the overlap.
	//So we flip the coordinates for vertical lines.
	is_vertical = (line_1[0].x == line_1[1].x), 
	line_1_pt_1 = pt_2D_invert_xy(line_1[0], is_vertical), //flip x with y, so x can be used
	line_1_pt_2 = pt_2D_invert_xy(line_1[1], is_vertical), //flip x with y, so x can be used
	line_2_pt_1 = pt_2D_invert_xy(line_2[0], is_vertical),
	line_2_pt_2 = pt_2D_invert_xy(line_2[1], is_vertical),
	//Correction 2:
	//The points of a line can be: [[4,66], [1,66]]. Point 2 has lower x.
	//To reduce use cases we switch the points inside a line to have
	//the lower x point as point 1.
	line_1_do_flip_points = line_1_pt_1.x > line_1_pt_2.x,
	pt_1_1 = line_1_do_flip_points ? line_1_pt_2 : line_1_pt_1,
	pt_1_2 = line_1_do_flip_points ? line_1_pt_1 : line_1_pt_2,
	line_2_do_flip_points = line_2_pt_1.x > line_2_pt_2.x,
	pt_2_1 = line_2_do_flip_points ? line_2_pt_2 : line_2_pt_1,
	pt_2_2 = line_2_do_flip_points ? line_2_pt_1 : line_2_pt_2,
	//Correction 3:
	//Two lines overlap. The one with the lower x should be "line 1".
	line_1_is_left = pt_1_1.x <= pt_2_1.x,
	A = line_1_is_left ? pt_1_1 : pt_2_1,
	B = line_1_is_left ? pt_1_2 : pt_2_2,
	P = line_1_is_left ? pt_2_1 : pt_1_1,
	Q = line_1_is_left ? pt_2_2 : pt_1_2 
	)
	//1. : No overlap
	//    A-------B
	//                P------Q
	//Return: no overlap
	P.x > B.x ?
		[line_def_cross_disjoint,[], [line_1,line_2]]
	:
	//2. : line_2 touches line_1 
	//    A-------B
	//            P------Q
	//Return: [A,B],[P,Q] ==> B==P = intersection
	P.x == B.x ?
		do_report_line_touches ?
			[line_def_cross_intersect,
			 pt_2D_invert_xy(pt=B, do_invert=is_vertical),
			 [line_1,line_2]]
		:[line_def_cross_disjoint,
		  [],
		  [line_1,line_2]]
	:
	//3. : pt21 in range of line_1
	//    A-------B
	//         P------
	A.x < P.x && P.x < B.x ?
		//3.1 : line_1_is being partially overlapped by line_2
		//    A-------B
		//         P------Q
		//Return [A,P],[P,Q] ==> P=intersection
		Q.x > B.x ?
			[line_def_cross_intersect,
			 pt_2D_invert_xy(pt=P, do_invert=is_vertical),
			 [line_2D_recompose([A,P], line_1_do_flip_points, is_vertical),
			  line_2D_recompose([P,Q], line_2_do_flip_points, is_vertical)
			 ]
			]
		:
		//3.1. : line_1 fully overlaps line_2
		//     A----------B
		//         P------Q
		//Return [A,P],[P,Q] ==> P=intersection
		Q.x == B.x ?
			[line_def_cross_intersect,
			 pt_2D_invert_xy(pt=P, do_invert=is_vertical),
			 [line_2D_recompose([A,P], line_1_do_flip_points, is_vertical),
			  line_2D_recompose([P,Q], line_2_do_flip_points, is_vertical)
			 ]
			]
		:
		//3.2. : line_1 fully overlaps line_2
		//    A----------B
		//      P------Q
		//Return [A,P],[P,B]  ==> P=intersection
		//Q.x < B.x ?
		[line_def_cross_intersect,
		 pt_2D_invert_xy(pt=P, do_invert=is_vertical),
			 [line_2D_recompose([A,P], line_1_do_flip_points, is_vertical),
			  line_2D_recompose([P,B], line_2_do_flip_points, is_vertical)
			 ]
		]
	:
	//4. : Both lines start at the same point
	//    A-------B
	//    P----------
	A.x == P.x ?
		//4.1 : line_1_is being fully overlapped by line_2
		//    A-------B
		//    P----------Q
		//Return [A,B],[B,Q] ==> B=intersection
		Q.x > B.x ?
			[line_def_cross_intersect,
			 pt_2D_invert_xy(pt=B, do_invert=is_vertical),
			 [line_2D_recompose([A,B], line_1_do_flip_points, is_vertical),
			  line_2D_recompose([B,Q], line_2_do_flip_points, is_vertical)
			 ]
			]
		:
		//4.1. : line_1 overlaps line_2 exactly
		//     A----------B
		//     P----------Q
		//Return [A,Middle],[Middle,Q] ==> P=intersection
		Q.x == B.x ?
			let(pt_middle = [P.x+(Q.x-P.x)/2,P.y])
			[line_def_cross_intersect,
			 pt_2D_invert_xy(pt=pt_middle, do_invert=is_vertical),
			 [line_2D_recompose([A,pt_middle], line_1_do_flip_points, is_vertical),
			  line_2D_recompose([pt_middle,Q], line_2_do_flip_points, is_vertical)
			 ]
			]
		:
		//4.2. : line_1 fully overlaps line_2
		//    A----------B
		//    P------Q
		//Return [P,Q],[Q,B]  ==> Q=intersection
		//Q.x < B.x 
		[line_def_cross_intersect,
		 pt_2D_invert_xy(pt=Q, do_invert=is_vertical),
			 [line_2D_recompose([P,Q], line_2_do_flip_points, is_vertical),
			  line_2D_recompose([Q,B], line_1_do_flip_points, is_vertical)
			 ]
		]
	 
	//5. A.x > P.x
	//This case should not happen, because the lines/pts have been sorted
	: [line_def_cross_disjoint,
		  [],
		  [line_1, line_2]
	  ]	
;



function line_2D_recompose(line=[0,0], do_flip_points=false, is_vertical = false)=
			let(flipped = do_flip_points ? [line[1],line[0]] : line)
			[
				pt_2D_invert_xy(flipped[0], do_invert=is_vertical),
				pt_2D_invert_xy(flipped[1], do_invert=is_vertical)
			];
	

function pt_2D_invert_xy(pt=[0,0], do_invert=true) = 
			do_invert ? [pt.y, pt.x] : pt;

// line_2D_cross_touch_collinear_pt()
// ==> point must be collinear with line !!!
function line_2D_cross_touch_collinear_pt(line=[[],[]], point=[], do_report_line_touches = true) =
			!pt_on_collinear_line(pt=point, line=line) ?
				[true, line_def_cross_disjoint, []] //Result: Point is collinear to line but is not in line's range.
			:
			let(point_on_pt1 = pt_equal(line[0], point),
				point_on_pt2 = pt_equal(line[1], point)
				)
			do_report_line_touches ?
				[true, line_def_cross_intersect, point_on_pt1, point_on_pt2] //Result: point is anywhere on line
			:
				(point_on_pt1 || point_on_pt2) ?
					[true, line_def_cross_disjoint, []] //Result: point is exactly on an endpoint of line but should not be reported
				: [true, line_def_cross_intersect, point_on_pt1, point_on_pt2] //Result: point is anywhere on "inside" of line, not on endpoints
			;
	

	
// check_lines:
// This is based off an explanation and expanded math presented by Paul Bourke:
// http://paulbourke.net/geometry/pointlineplane/example2.c
// It takes two lines as inputs and returns 1 if they intersect, 0 if they do
// not.  hitp returns the point where the two lines intersected.  
//
function line_2D_is_cross(line_1, line_2) =
	// Introduction:
	// This code is based on the solution of these two input equations:
	//  Pa = P1 + ua (P2-P1)
	//  Pb = P3 + ub (P4-P3)
	//
	// Where line one is composed of points P1 and P2 and line two is composed
	//  of points P3 and P4.
	//
	// ua/b is the fractional value you can multiple the x and y legs of the
	//  triangle formed by each line to find a point on the line.
	//
	// The two equations can be expanded to their x/y components:
	//  Pa.x = p1.x + ua(p2.x - p1.x) 
	//  Pa.y = p1.y + ua(p2.y - p1.y) 
	//
	//  Pb.x = p3.x + ub(p4.x - p3.x)
	//  Pb.y = p3.y + ub(p4.y - p3.y)
	//
	// When Pa.x == Pb.x and Pa.y == Pb.y the lines intersect so you can come 
	//  up with two equations (one for x and one for y):
	//
	// p1.x + ua(p2.x - p1.x) = p3.x + ub(p4.x - p3.x)
	// p1.y + ua(p2.y - p1.y) = p3.y + ub(p4.y - p3.y)
	//
	// ua and ub can then be individually solved for.  This results in the
	// equations used in the following code.
	//	

	let(line_1_pt_1 = line_1[0],
		line_1_pt_2 = line_1[1],
		line_2_pt_1 = line_2[0],
		line_2_pt_2 = line_2[1],
		line_1_num = line_1[7],
		line_1_packet_num = line_1[8],
		line_2_num = line_2[7],
		line_2_packet_num = line_2[8],
		line_ids = [line_1_num,line_1_packet_num,line_2_num,line_2_packet_num],
		//Denominator for ua and ub are the same so store this calculation
		d   = (line_2_pt_2.y - line_2_pt_1.y)*(line_1_pt_2.x-line_1_pt_1.x) -
			  (line_2_pt_2.x - line_2_pt_1.x)*(line_1_pt_2.y-line_1_pt_1.y),
					
		// n_a and n_b are calculated as seperate values for readability 
		n_a = (line_2_pt_2.x - line_2_pt_1.x)*(line_1_pt_1.y-line_2_pt_1.y) - 
			  (line_2_pt_2.y - line_2_pt_1.y)*(line_1_pt_1.x-line_2_pt_1.x),
					
		n_b = (line_1_pt_2.x - line_1_pt_1.x)*(line_1_pt_1.y - line_2_pt_1.y) -
			  (line_1_pt_2.y - line_1_pt_1.y)*(line_1_pt_1.x - line_2_pt_1.x),

		// Make sure there is not a division by zero - this also indicates that
		// the lines are parallel.  
		// 
		// If n_a and n_b were both equal to zero the lines would be on top of each 
		// other (coincidental).  This check is not done because it is not 
		// necessary for this implementation (the parallel check accounts for this).
		// 
		// Calculate the intermediate fractional point that the lines potentially
		// intersect.
		//
		ua = n_a / (d != 0 ? d : 0.0000001),
		ub = n_b / (d != 0 ? d : 0.0000001)
	)
    d == 0 ?
        [line_def_cross_disjoint, [], line_ids]
	:
		// The fractional point will be between 0 and 1 inclusive if the lines
		// intersect.  If the fractional calculation is larger than 1 or smaller
		// than 0 the lines would need to be longer to intersect.
		//
		(ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) ?
			[line_def_cross_intersect, 
				[pt_val_exact_zero(
					line_1_pt_1.x + (ua * (line_1_pt_2.x - line_1_pt_1.x))),
				 pt_val_exact_zero(
					line_1_pt_1.y + (ua * (line_1_pt_2.y - line_1_pt_1.y)))
				],
				,
				line_ids
				/*
				 "	",line_1,  "	",line_2, "	", "n_a",n_a, "ua=",ua,"ub=",ub,
				"n_b=", n_b, n_b_tol,
				(line_1_pt_2.x - line_1_pt_1.x),
				(line_1_pt_1.y - line_2_pt_1.y),
				(line_1_pt_2.y - line_1_pt_1.y),
				(line_1_pt_1.x - line_2_pt_1.x),
				(line_1_pt_2.x - line_1_pt_1.x)+(line_1_pt_1.x - line_2_pt_1.x),
				"d=",d
				*/
			]
		:	
			[line_def_cross_disjoint, [], line_ids, ua,ub,d]
	;
	

// line_get_slope() :
// Get the slope of a line.
// The order of the points matters.
//    Input:  two points of a line.
//    Return:  1 => raising slope
//            -1 => falling slope
//            0  => horizontal (same x-value)
//            2  => vertical  (same z value)
//            3  => both points on same spot
function line_get_slope(pt1, pt2) =
	pt1.y == pt2.y ?
		pt1.x == pt2.x ? line_def_slope_same_spot 
		: line_def_slope_horizontal 
	: pt1.x == pt2.x ? 
		pt1.x < pt2.x ? line_def_slope_vertical_raising :  line_def_slope_vertical_falling
	: pt1.y < pt2.y ? line_def_slope_raising 
	: pt1.y > pt2.y ? line_def_slope_falling
	: 0; //never happens



SMALL_NUM = 0.00000001; // anything that avoids division overflow



// line_perp_product() :
// Scalar product of two vectors v and w also
// The "perp dot product" v^_|_·w for  v and w vectors in the plane 
// is a modification of the two-dimensional "dot product" in which v 
// is replaced by the perpendicular vector rotated 90 degrees to the left 
// defined by Hill (1994). It satisfies the identities:
// v^_|_·w	=	|v||w|sin(theta)        (1)
// (v^_|_·w)^2+(v·w)^2	= |v|^2|w|^2	(2)
// where theta is the angle from vector v to vector w.
// Also named "2D exterior product" or "outer product".
// http://mathworld.wolfram.com/PerpDotProduct.html
// http://geomalgorithms.com/vector_products.html
// Input: vector v (2D) and perpendicular vector w (2D)
// Return:  0 if the two vectors are collinear
//         >0 w is left of v (0<theta<180)
//         <0 w is right of v (0>theta>-180)
// See: http://geomalgorithms.com/vector_products.html
function line_2D_perp_product(perpendicular_of_v, w) =
	(perpendicular_of_v.x * w.y - perpendicular_of_v.y * w.x); 
	
	
	
// -------------------------------------------------------------------------
// pt_equal()
// Input: two points
// Return: true if both points are at the same spot.
function pt_equal(pt1, pt2) =
	pt_val_equal_tolerant(pt1.x, pt2.x)
	&& pt_val_equal_tolerant(pt1.y, pt2.y)
	;
	
// -------------------------------------------------------------------------
function pt_equal_tolerant(pt1, pt2) =
	pt_val_equal_tolerant(pt1.x, pt2.x)
	&& pt_val_equal_tolerant(pt1.y, pt2.y)
	;
	
// -------------------------------------------------------------------------
// pt_val_equal_tolerant(...)
// When calculating point and crossings, then small errors may occur.
// So, OpenScad displays "0" in debug print, but it really is 6.55*10^-15
// For such instances the points should be equal.
function pt_val_equal_tolerant(value1=0, value2=0) =
	value1-POINT_TOLERANCE <= value2 && value2 <= value1+POINT_TOLERANCE;

// -------------------------------------------------------------------------
// This function tests "value" for little values and returns
// exactly zero for lets say 2.1684e-017
function pt_val_exact_zero(value) =
	pt_val_equal_tolerant(value1=value, value2=0) ?
		0 : value;
		
// -------------------------------------------------------------------------
// pt_val_in_range(...)
// Compares a value with two other values for boundary.
// Return: "true" if "value" is in range (tolerant)
function pt_val_in_range_tolerant(range=[0,0], value=0) =
	//min/max because the order of the line points is unknown
	let(max_range = max(range[0],range[1]),
		min_range = min(range[0],range[1])
	)
	// The "tolerant" function calls expand the valid values
	// of the "<=" and ">=" operators by POINT_TOLERANCE
	(min_range <= value && value <= max_range)
	|| pt_val_equal_tolerant(value, min_range)
	|| pt_val_equal_tolerant(value, max_range)
	;
	
// pt_on_collinear_line() :
// Determine if a point is on a line (between points).
// It is a pre condition that the point is collinear to the line.
//    Return: true = pt is on/inside line
//            false = pt is  not on/inside line


echo("pt_val_equal_tolerant", pt_val_equal_tolerant(2, 1+POINT_TOLERANCE));
echo("pt_on_collinear_line", pt_on_collinear_line([1,1],[[0,1],[2,1]]));

function pt_on_collinear_line(pt=[], line=[[],[]]) =
    !pt_val_equal_tolerant(line[0].x, line[1].x) ? 
		// segment is not  vertical
		pt_val_in_range_tolerant(range=[line[0].x,line[1].x], value=pt.x)
    :    // line is vertical, so test y coordinate
		pt_val_in_range_tolerant(range=[line[0].y,line[1].y], value=pt.y)
	;
	


function pt_dot_product(u=[], v=[]) =
			(u.x * v.x + u.y * v.y + u.z * v.z);


//TODO : With two calls to is_left() with both lines it might be possble to check for cross.
	

/*
testere = pts_2D_backlash_y_map(
			map = array_testp, 
			backlash = backlash, 
			pitch = pitch_test);
echo("pts_2D_backlash_y_map(");
for(t=testere)
	echo("	", t);
*/




	

function concat_by_max_x(profile1, profile2, pitch) =
			len(profile1) == 0 ?
				len(profile2) == 0 ?
					[] : profile2
				: len(profile2) == 0 ?
					profile1
			: //both profiles contain data
			// For every point pair in profile 1, n values may be ignored and vice versa for profile2
			let( checked_pts =
					[ for(i_1=[1:len(profile1)-1])
						let(xz_1 = profile1[i_1],
							x_1 = xz_1[0],
							z_1 = xz_1[1],
							next_i = array_get_next_circular_index(profile1, i_1),
							xz_next = profile1[next_i],
							x_next = xz_next[0],
							z_next = xz_next[1],
							z_next_virtual = i_1+1 < len(profile1) ? z_next : z_next+pitch 
						)
						for(i_2=[1:len(profile2)-1])
							let(xz_2 = profile2[i_2],
							x_2 = xz_2[0],
							z_2 = xz_2[1]
							)
							
							z_1 == z_2 ? 
								// A : both have same z ==> take max
								pts_2D_max(xz_1,xz_2)
							:
								// B : z of main profile points differ
								z_2 > z_1 && z_2 < z_next_virtual ?
									// xz_2 is in between xz_1 and xz_next
									//Check "is_right" because bigger x's are on the right hand side in x-z 
									is_left_raw(xz_1, xz_next, xz_2)<=0 ?
										//xz_2 is collinear or above pluspoints
										xz_2
										: []
								:
									// xz_2 is under xz_1 or over xz_next 
									[]
								
					]
				) //end let
				//Filter double values
				[for(i = [0:len(checked_pts)-1])
					pts_2D_pt_is_in_array_before(checked_pts, checked_pts[i], i) ? [1] : checked_pts[i]  //ignore if already before ==> once
				];
					


array_f = [[],[],[3,4],[4,5],[],[],[],[],[4,5],[]];
echo("array_f",array_f);
de_emptied = array_remove_empty(array_f);
echo("array_remove_empty(array_f)",de_emptied);
echo("pts_2D_pt_is_in_array_before(map, [3,4], index)",pts_2D_pt_is_in_array_before(array=de_emptied, point=[4,5], max_index=2));
	
	
	
function pts_2D_pt_is_in_array_before(array=[], point, max_index) =
	max_index > len(array)-1 || max_index== 0 ? false 
	:	
	let(found = [for(i = [0:1:max_index-1])
					let(xz=array[i])
					len(xz) <= 0 ? [] //Exclude empty ones
					: (xz[0] == point[0] && xz[1] == point[1]) ? point
						: []
				]
		)
	//found;
	len(array_remove_empty(array=found)) > 0;
	
function pts_2D_max(pt1,pt2, index) = 
			len(pt1) > 0 ?
				len(pt2) > 0 ?
					pt1[index] >= pt2[index] ? pt1 : pt2
				: pt1
			: len(pt2) > 0 ?
				pt2 : [];
//-----------------------------------------------------------------
//-----------------------------------------------------------------
//
// TOOTH PROFILE MAPS
//
//-----------------------------------------------------------------
//-----------------------------------------------------------------
// A tooth can have any profile with multiple edges. 
// limitations: 
//   - z-value must not be the same for two points.
//   - no overhangs (low convexitiy)
// The profile starts with the lowest point of radius (smallest diameter)	



//-----------------------------------------------------------
// Simple tooth profile map
//-----------------------------------------------------------
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
	
//-----------------------------------------------------------
// Whitworth thread tooth profile map
//-----------------------------------------------------------
//
// - BSW - British Standard Whitworth Thread
// - BSF - British Standard Fine Thread
// - BSP - British Standard Pipe Thread (Parallel)
// - BSPT - British Standard Pipe Thread (Tapered)
//
// BSW= British Standard Whitworth Thread after it’s introduction in 1841, was rapidly adopted throughout England and the continent.
// BSF= British Standard Fine Thread is a second series which was established in 1908 to meet the needs of additional engineering activity.

// Basic Whitworth Thread Forms have the following proportions:
// Thread Angle:55º
// Shortening at crest and roots:1/6 H = 0.16008 P
// Flank Angle:27 1/2º
// Depth of Thread h:0.64033 P
// Triangle Height H:0.96049 P
// Radius at crest and root r:0.13733 P
// Pitch:P

function whitworth_profile_data(threads_per_inch, internal, coarseness) =
	let(profile_angle = 55,
		angle = profile_angle/2,
		mm_pitch = 25.4/threads_per_inch,
		// Peak to peak thread height is defined in most documents as 0.960491 * pitch_inch
		// which i found is the geometrical equivalent of  (pitch_inch/2)/tan(angle)
		peak_to_peak_height = (mm_pitch/2)/tan(angle),
		// The peak to peak height is truncated by the standard by 
		// one sixth of the peak to peak value on top and on the bottom. 
		// Most documents have "0.640327*pitch_inch" for this but it is really 
		// peak_to_peak_height-2*peak_to_peak_height/6
		tooth_height = peak_to_peak_height-2*peak_to_peak_height/6,	
		// Radius
		// The most found value for the radius is 0.137329*pitch_inch. 
		// With claim 2 of intercept theorem and a little trigonometry the formula is
		// r = (tr^2*sin(angle)) / (tr-tr*sin(angle)) where tr is the cut away 
		// one sixth of the triangle.
		clearance = (peak_to_peak_height-tooth_height)/2,
		radius = clearance*clearance*sin(angle)/(clearance-clearance*sin(angle)),
		//So far, exact clearance with tolerances not implemented.
		max_height_inner_to_outer_flat = tooth_height,
		min_clearance_to_outer_peak = clearance,
		max_clearance_to_outer_peak = 2 * min_clearance_to_outer_peak, // no idea, honestly
		min_outer_flat = 2 * accurateTan(angle) * min_clearance_to_outer_peak,
		max_outer_flat = 2 * accurateTan(angle) * max_clearance_to_outer_peak		
	)
	[
		profile_angle,					// 0
		mm_pitch,						// 1
		peak_to_peak_height,			// 2
		tooth_height,					// 3
		clearance,						// 4
		radius,							// 5
		max_height_inner_to_outer_flat,	// 6
		coarseness						// 7
	];
	
								
function whitworth_xz_map(profile_data, 
							coarseness_circle, 
							deliver_valid_polygon) =
	v_profil_radius_xz_map(pitch = profile_data[1], 
							tooth_height = profile_data[3],
							radius = profile_data[5], 
							profile_angle=profile_data[0],
							coarseness_circle = coarseness_circle, 
							deliver_valid_polygon = deliver_valid_polygon);
								
	
//-----------------------------------------------------------
// V-shaped threads with radius at peaks tooth profile map
//-----------------------------------------------------------
//
// - Whitworth threads
// - Metric ISO threads
//


function v_profil_num_rad_segs(coarseness_circle) =
	//Segments: with 4 segements on arc we need to create
	//2 exact points and three in between.
	let(num_segs = coarseness_circle >= 8 ? coarseness_circle : 8) 
	ceil(num_segs/4)-2;
	
function v_profil_rad_angle(profile_angle) = 90-profile_angle/2;

function v_profil_rad_seg_angle(profile_angle,coarseness_circle) =
	let(rad_angle = v_profil_rad_angle(profile_angle),
		num_rad_segs = v_profil_num_rad_segs(coarseness_circle))
	rad_angle/(num_rad_segs+1);

function v_profil_radius_xz_map(pitch, 
								tooth_height, 
								radius, 
								profile_angle,
								coarseness_circle, 
								deliver_valid_polygon) =
		let(rad_angle = v_profil_rad_angle(profile_angle),
			num_rad_segs = v_profil_num_rad_segs(coarseness_circle),
			rad_seg_angle = v_profil_rad_seg_angle(profile_angle, coarseness_circle),
			center_rad_lower_z = radius,
			center_rad_higher_z = tooth_height-radius
			)
		concat(
		 //Lower right radius : lowest point of 
			[[center_rad_lower_z-radius,0]]  //exact zero, no angle calculations
		,//Lower right radius: radius until slope
			[for ( i = [1:1:num_rad_segs]) 
				let(i_angle = i*rad_seg_angle)
				[center_rad_lower_z-radius*cos(i_angle),
				radius*sin(i_angle)]
			]
		,//Lower right radius: Exact point at rad_angle (no angle calculations)	
			[[center_rad_lower_z-radius*cos(rad_angle),
			radius*sin(rad_angle)]]  

		,//Top left radius: Exact point at rad_angle (no angle calculations)
			[[center_rad_higher_z+radius*cos(rad_angle),
			pitch/2-radius*sin(rad_angle)]]
		,//Top left radius
			[for ( i = [1:1:num_rad_segs])
				let(i_angle = rad_angle-i*rad_seg_angle)
				[center_rad_higher_z+radius*cos(i_angle),
				pitch/2-radius*sin(i_angle)]
			]
		
		,//Exact highest point
			[[center_rad_higher_z+radius, 
			pitch/2]]
		,//Top right radius:
			[for ( i = [1:1:num_rad_segs]) 
				let(i_angle = i*rad_seg_angle)
				[center_rad_higher_z+radius*cos(i_angle),
				pitch/2+radius*sin(i_angle)]
			]
		,//Top right radius: Exact point at rad_angle (no angle calculations)
			[[center_rad_higher_z+radius*cos(rad_angle),
			pitch/2+radius*sin(rad_angle)]]
			
		,//Lower left radius: Exact point at rad_angle (no angle calculations)	
			[[center_rad_lower_z-radius*cos(rad_angle)+0.0,
			pitch-radius*sin(rad_angle)]]
		,//Lower left radius: 	
			[for ( i = [1:1:num_rad_segs])
				let(i_angle = rad_angle-i*rad_seg_angle)
				[center_rad_lower_z-radius*cos(i_angle),
				pitch-radius*sin(i_angle)]
			]
		//Exact lowest point of lower radius not needed.
		//It is at thread start
		
		//Debug				
		 ,deliver_valid_polygon ? [[-1,pitch],[-1,0]] : []
		)//end concat
		;


//-----------------------------------------------------------
// Rope thread tooth profile map
//-----------------------------------------------------------

// Basic tooth profile
// Only the tooth points are defined. Connections to the next/previous
// tooth profile gives the full tooths profile. This way no in between
// points (at zero or at pitch) are needed.
// The profile starts with the left flat. For standard threads, this is
// not important, but for channel threads it is exactly what we want.
// Before version 3 the threads started with lower_flat.	

function rope_xz_map(
			profile_data, 
			rope_diameter, 
			rope_bury_ratio, 
			deliver_valid_polygon) =
		let(pitch = profile_data[1],
			coarseness = profile_data[7],
			tooth_height = profile_data[3],
			rope_radius = rope_diameter/2,
			buried_depth = rope_radius * rope_bury_ratio,
			unburied_depth = rope_radius-buried_depth,
			buried_height =  2*sqrt(pow(rope_radius,2)-pow(unburied_depth,2)), //coarseness must go over the buried part only
			unused_radius = rope_radius - sqrt(pow(rope_radius,2)-pow(unburied_depth,2)),
			left_upper_flat	= (pitch-(rope_diameter-2*unused_radius))/2,
			right_upper_flat = pitch-(rope_diameter-2*unused_radius) -left_upper_flat
			)
		concat(
			[	[tooth_height, 0],
				[tooth_height, left_upper_flat]]
		,
			[for ( circel_seg = [1:1:coarseness-1]) 
				let(z_offset = circel_seg * (buried_height/coarseness),
						current_rad_on_base = abs(rope_radius - (unused_radius + z_offset)),
						depth = sqrt(pow(rope_radius,2)- abs(pow(current_rad_on_base,2)))
											-unburied_depth
					)
				[tooth_height-depth, left_upper_flat+z_offset]
			]	
		,	
			[	[tooth_height, pitch-right_upper_flat]]
		
		//Debug				
		 ,deliver_valid_polygon ? 
			[[-rope_diameter,pitch],[-rope_diameter,0]] : []
		);
			

function rope_profile_data(pitch, tooth_height, coarseness) =
	[	0, 				// 0, profile_angle : rope profiles have no profile angle
		pitch, 			// 1, mm_pitch
		0,				// 2, peak_to_peak_height : rope profiles have no peak_to_peak_height
		tooth_height, 	// 3, tooth_height
		0,				// 4, clearance : clearance is 0 for rope profiles
		0,				// 5, radius : no v-shaped profile radius
		0,				// 6, max_height_inner_to_outer_flat 
		coarseness		// 7, coarseness
	];
	
// -----------------------------------------------------------
// Helper Functions
// -----------------------------------------------------------

function xz_map_add_z(xzmap, z) =
	[for(xz = xzmap)
		[z+xz[0], xz[1]]
	];

function xz_map_to_xy_map(xzmap) =
	[for(xz = xzmap)
		[xz[1], xz[0]]
	];
function xy_map_to_xz_map(xymap) =
	[for(xy = xymap)
		[xy[1], xy[0]]
	];
function get_clearance(clearance, internal) = (internal ? clearance : 0);

//Backlash only for internal threads and positive values.
function get_backlash(backlash, internal) = (internal ? (backlash>0 ? backlash : 0): 0); 

function xz_map_find_index_of_z(xzmap=[],z ) =
			let(find = [for(i=[0:len(xzmap)-1])
							if(xzmap[i][1]==z)
								i
						])
			len(find)>0 ? find[0] : -1;
function xz_map_find_index_larger_z(xzmap=[],z ) =
			let(find = [for(i=[0:len(xzmap)-1])
							if(xzmap[i][1]>z)
								i
						])
			len(find)>0 ? find[0] : -1;
function xz_map_find_index_smaller_z(xzmap=[],z ) =
			let(find = [for(i=[0:len(xzmap)-1])
							if(xzmap[i][1]<z)
								i
						])
			len(find)>0 ? find[len(find)-1] : -1;

function xz_map_max_x_xy(xy1, xy2) = xy1[0] >= xy2[0] ? xy1 : xy2;
							
//function xz_point_above(xz_plus, xz_larger, xz_smaller) =
//			let(x = xz_plus[0],
//				z = xz_plus[1],
//				x_larger = xz_larger[0],
//				x_smaller = xz_smaller[0]
//				)	
//			x >= x_larger ?
//				x >= x_smaller ?
//					true
//				: // TODO two cases, which side of line
//			:
//				// x <  x_larger
//				x >= x_smaller ?
//					// TODO two cases, which side of line
//				: //x <  x_larger && x <  x_smaller
//					false
//			;
				
a=0;

//is_left( ) :
//Formula returns zero if point c is on line a-b
//Sample: If the line is horizontal, then this returns true 
//if the point is above the line.
function is_left(line_point_a=[], line_point_b=[], point_check=[])=
	is_left_raw(line_point_a, line_point_b, point_check) > 0;



// --------------------------------------------------------------------
// is_left_raw_tolerant()
// A point is not collinear with the exact formulas even if the deviation
// from the line is something like 2.1684e-016. This low value is in the
// range of the calculation errors and this accuracy may not be needed.
// 
// Debug: echo("is_left_tolerant: " ,is_left_tolerant([[0,0],[2,2]],  
// 				[1+POINT_TOLERANCE+2.1684e-016,1-POINT_TOLERANCE]));
function is_left_raw_tolerant(line=[], point_check=[])=
	let(ilr = is_left_raw(line[0], line[1], point_check)
	   )
	false && ilr >= POINT_TOLERANCE ? //TODO switch back <>
		ilr +22
	:
	//For tolerant calculations a point is equal if it is inside +- POINT_TOLERANCE.
	//So, if checks with tolerance aware functions, so far, the tolerance has been
	//simply applied to the horizontal and vertical values but not the real distance
	//which would need angle/trigonometric calculations. So, a point has a square around
	//itself in distance POINT_TOLERANCE. Depending on the slope and to be consistent
	//with the point checks which check for the full square, the tolerance line must 
	//be calculated by applying the tolerance in x and y direction.
	let(pt1=line[0],
		pt2=line[1],
		apply_top_left_bottom_right =
			((pt1.x <= pt2.x && pt1.y <= pt2.y) //raising to the right
			||(pt1.x >= pt2.x && pt1.y >= pt2.y)), //falling to the left
		pt1_tol_left = [pt1.x-POINT_TOLERANCE, pt1.y +(apply_top_left_bottom_right ? POINT_TOLERANCE:-POINT_TOLERANCE)],
		pt2_tol_left = [pt2.x-POINT_TOLERANCE, pt2.y +(apply_top_left_bottom_right ? POINT_TOLERANCE:-POINT_TOLERANCE)],
		pt1_tol_right = [pt1.x+POINT_TOLERANCE, pt1.y +(apply_top_left_bottom_right ? -POINT_TOLERANCE:POINT_TOLERANCE)],
		pt2_tol_right = [pt2.x+POINT_TOLERANCE, pt2.y +(apply_top_left_bottom_right ? -POINT_TOLERANCE:POINT_TOLERANCE)],
		left_tol_left = is_left_raw(pt1_tol_left, pt2_tol_left, point_check),
		left_tol_right = is_left_raw(pt1_tol_right, pt2_tol_right, point_check)
	   )
	left_tol_left>0 ? // ">0" excludes "==0" 
		ilr //left of left ==> really left
			//[44,left_tol_left]
	: 
	!(left_tol_right>=0) ? // because of negation ">=0", includes "==0" 
		ilr //right of right ==> really right
			//[55,left_tol_left, left_tol_right] 
	:	
	 0 	//tolerant colinear case
		//[11, left_tol_left, left_tol_right]//0 
	;
	
		
function is_collinear_tolerant(line=[], point_check=[]) =
	//returns true if point c is on line a-b
	(line[0][0] == line[1][0] && line[1][0]==point_check[0]) // Horizontal
	|| (line[0][1] == line[1][1] && line[1][1]==point_check[1] ) //vertical
	|| is_left_raw_tolerant([line[0], line[1]], point_check) == 0;
	;
	
function is_collinear(line=[], point_check=[])=
	//returns true if point c is on line a-b
	(line[0][0] == line[1][0] && line[1][0]==point_check[0]) // Horizontal
	|| (line[0][1] == line[1][1] && line[1][1]==point_check[1] ) //vertical
	|| is_left_raw(line[0], line[1], point_check) == 0;
	

function is_left_raw(line_point_a=[], line_point_b=[], point_check=[])=
	//formula returns zero if point c is on line a-b
	//If the line is horizontal, then this returns >0 if the point is above the line.
	 ((line_point_b.x - line_point_a.x)*(point_check.y - line_point_a.y) 
		- (line_point_b.y - line_point_a.y)*(point_check.x - line_point_a.x));
													
							
function xz_map_add_backlash(xzmap=[], backlash=0, internal = false) =
	!internal || backlash == 0 ? xzmap
	:
	let(bl = get_backlash(backlash, internal)/2, //only half of backlash on both sides
		plus_bl_map = 
			[for(index=[0:len(xzmap)-1])
				let(xz = xzmap[index],
					x_i = xz[0],
					z_i = xz[1]
					)
				[x_i, z_i + bl]
			],
		minus_bl_map = 
			[for(index=[0:len(xzmap)-1])
				let(xz = xzmap[index],
					x_i = xz[0],
					z_i = xz[1]
					)
				[x_i, z_i - bl]
			],
		max_map_plus = 
			[for(plus_i=[0:len(plus_bl_map)-1])
				let(xz_plus = plus_bl_map[plus_i],
					//x_plus = xz_plus[0],
					z_plus = xz_plus[1],
					xz_minus_exact_i = xz_map_find_index_of_z(xzmap=minus_bl_map,z=z_plus),
					xz_minus_larger_i = xz_map_find_index_larger_z(xzmap=minus_bl_map,z=z_plus),
					xz_minus_larger = minus_bl_map[xz_minus_larger_i],
					//x_minus_larger = minus_bl_map[xz_minus_larger_i][0],
					xz_minus_smaller_i = xz_map_find_index_smaller_z(xzmap=minus_bl_map,z=z_plus),
					xz_minus_smaller = minus_bl_map[xz_minus_smaller_i]
					//x_minus_smaller = minus_bl_map[xz_minus_smaller_i][0]
					)
				xz_minus_exact_i >= 0 ?
					//xz_minus has a point exactly on the same z ==> take max x value
					xz_map_max_x_xy(xz_plus, minus_bl_map[xz_minus_exact_i])
				//Check "is_right" because bigger x's are on the right hand side in x-z 
				: is_left_raw(xz_minus_smaller, xz_minus_larger, xz_plus)<=0 ?  
					//xz_plus is collinear or above minuspoints
					xz_plus
					: []
			],
		max_map_minus = 
			[for(minus_i=[0:len(minus_bl_map)-1])
				let(xz_minus = minus_bl_map[minus_i],
					//x_minus = xz_minus[0],
					z_minus = xz_minus[1],
					xz_plus_exact_i = xz_map_find_index_of_z(xzmap=plus_bl_map,z=z_minus),
					xz_plus_larger_i = xz_map_find_index_larger_z(xzmap=plus_bl_map,z=z_minus),
					xz_plus_larger = plus_bl_map[xz_plus_larger_i],
					//x_plus_larger = plus_bl_map[xz_plus_larger_i][0],
					xz_plus_smaller_i = xz_map_find_index_smaller_z(xzmap=plus_bl_map,z=z_minus),
					xz_plus_smaller = plus_bl_map[xz_plus_smaller_i]
					//x_plus_smaller = plus_bl_map[xz_plus_smaller_i][0]
					)
				xz_plus_exact_i >= 0 ?
					//xz_minus has a point exactly on the same z ==> ignore, already included in max_map_plus
					[]
				//Check "is_right" because bigger x's are on the right hand side in x-z 
				: is_left_raw(xz_plus_smaller, xz_plus_larger, xz_minus)<=0 ?
					//xz_minus is collinear or above pluspoints
					xz_minus
					: []
			],
			max_map_all = [for(xy=concat(max_map_plus,max_map_minus))
							if(len(xy)>0)
								xy
						]
							

					
/*
			,
		backlashed_xzmap = [for(level2 =
						[for(index=[0:len(xzmap)-1])
							let(xz_current = xzmap[index],
								i = index,
								i_arr = array_get_prev_circular_index(array=xzmap, index=i),
								xz_next = xzmap[array_get_next_circular_index(array=xzmap, index=index)],
								xz_prev = xzmap[array_get_prev_circular_index(array=xzmap, index=index)],
								x_current = xz_current[0],
								x_prev = xz_prev[0],
								x_next = xz_next[0],
								z_current = xz_current[1],
								z_previous = xz_prev[1]
								)
							//It is safe to assume, z gets bigger with increasing index
							//so we have only x to test
							x_current < x_next ?
								//raising slope from current to next
								x_current >= x_prev ?
									//raising slope from current to next
									//raising or no slope from previous to current
									//Still, with large backlash values, points might be overriden
									//z_previous+bl < z_current-bl ?
										[[x_current, z_current-bl]]
									//:
									//	[]
								:
									//raising slope from current to next
									//falling or no slope from previous to current
									//==> lowest point
									//A concave profile will be compressed
									//z_previous in orig data is always <= z_current.
									//But in the iteration before, z_previous has been increased (falling slope)
									z_previous+bl < z_current-bl ?
										[[x_current, z_current-bl]]
									:
										[]
							: x_current > x_next ?
								//falling slope from current to next
								x_current <= x_prev ?
									//falling slope from current to next
									//falling or no slope from previous to current
									[[x_current, z_current+bl]]
								:
									//falling slope from current to next
									//raising slope from previous to current
									// ==> highest point
									[
									[x_current, z_current-bl], 
									xz_current, 
									[x_current, z_current+bl]
									]
							: //no slope from current to next
							x_current == x_prev ?
								//no slope from current to next
								//no slope from previous to current
								[xz_current]
								: x_current < x_prev ?
									//no slope from current to next
									//falling slope from previous to current
									[[x_current, z_current+bl]]
									:
									//no slope from current to next
									//raising slope from previous to current
									//[[x_current+100,i,i_arr,len(xzmap),x_prev,index, array_get_prev_circular_index(array=xzmap, index=index), len(xzmap)]]// 
									[[x_current, z_current-bl]]
						]
						 ) //level2 
						for(level1 = level2)
							if(len(level1)>0)
								level1
					]
				*/
		) //end let

	//quicksort_arr(max_map_all, 1)
	//max_map_plus
	//max_map_minus
	//minus_bl_map
	/*
	TODO: Plus: map has after adding backlash no zero point. Insert it derived from point_0+bl and point_pitch+bl
	Minus: map has after adding backlash no zero point.
	remove negative points and points at > pitch
	*/
	quicksort_arr(max_map_all, 1)

	;



function xz_map_find_visavis_pts(map, start_index, point) =
			[
			for(i=[0:len(map)-2])
				let(prev_i = array_get_prev_circular_index(array=map, index=start_index-i)) 
				
				//TODO. Seems pretty complex to do.
				1
			]
			;

function xz_map_correct_backlash(backlashed_xzmap=[], backlash=0, internal = false, pitch=1) =
		!internal || backlash == 0 ? backlashed_xzmap
		:
		let(
		corrected_xzmap = [for(index=[0:len(backlashed_xzmap)-1])
						let(xz_current = backlashed_xzmap[index],
							xz_next = backlashed_xzmap[array_get_next_circular_index(array=backlashed_xzmap, index=index)],
							xz_prev = backlashed_xzmap[array_get_prev_circular_index(array=backlashed_xzmap, index=index)],
							x_current = xz_current[0],
							x_prev = xz_prev[0],
							x_next = xz_next[0],
							z_current = xz_current[1],
							z_next = xz_next [1],
							z_previous = xz_prev[1]
							)
					//After adding backlash, z is not surely increasing with incresing index.
					//If a point was being backlashed and the previous not, then values in z may be smaller
					z_current < 0 ?
						//current z is negative
						z_next <= 0 ?
							//Current z and next z are negative
							// current z no longer needed
							[] 
						:
							//current z is negative
							//next z is positive
							xz_map_calc_crosspoint(xz_current, xz_next, cross_x=0)
					: 	
						//Current z is positive
						z_current < pitch ?
							//Current z is positive
							//Current z < pitch
							z_current < z_previous ?
								//a point moved over the previous
								[]
								: 
								xz_current
							:
							//Current z is positive
							//Current z >= pitch
							[]
					]
		) //end let
		[for(corr = corrected_xzmap)
		if(len(corr)>0)
			corr
		]

	;		

function xy_map_calc_x_crosspoint(current, next, cross_x) =
			cross_x > max(current.x, next.x) 
			|| cross_x < min(current.x, next.x) ?
				[]
			:
			current.x == next.x ?
				//vertical case
				let(vert_diff = pt_abs_diff(current.y, next.y))
				current.y <= next.y ?
					[current.x, current.y+vert_diff/2]
				:	[current.x, current.y-vert_diff/2]
			:
			cross_x == current.x ?
				current
			:
			cross_x == next.x ?
				next
			:
			//cross_x is in range
			current.y == next.y ? 
				[cross_x, current.y] //horizontal, easy
			:

			let(x_current = abs(current.x),
				y_next = next.y,
				x_next = next.x,
				diff_x = pt_abs_diff(current.x, next.x),
				diff_y = pt_abs_diff(current.y, next.y),
				q = pt_abs_diff(current.x, cross_x),
				cross_f = diff_y*q/diff_x
				)  
			[cross_x, current.y+(current.y<next.y?1:-1)*cross_f ]
		;
			
function pt_abs_diff(value1, value2) =
			value1 >= 0 && value2 >= 0 ?
				abs(value1-value2)
			: value1 >= 0 ?
				value1 - value2 //value2 negative
			:	value2 - value1 //value 1 negative
		;
			
function array_get_next_circular_index(array, index) =
		index <= len(array)-2 ? index+1 : 0
		;
function array_get_prev_circular_index(array, index) =
		index <= len(array)-1 && index>0 ? index-1 : ((index)%len(array))+len(array)-1
		;
function array_remove_empty(array=[]) = 
			[for(a = array)
					if(len(a)>0)
						a
			];
					
		
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// Function for lines and complex lines (clines)
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// -------------------------------------------

function cline_build(pt1, pt2, line_index, source_line_index) =
	[pt1, pt2, 
	 max(pt1.x,pt2.x), // 2 : max x of line
	 min(pt1.x,pt2.x), // 3 : min x of line
	 max(pt1.y,pt2.y), // 4 : max y of line
	 min(pt1.y,pt2.y), // 5 : min y of line
	 line_get_slope(pt1, pt2), // 6 : slope of line
	 line_index,			// 7 : line index
	 source_line_index	// 8 : source line number
	];


function convert_pt_map_to_clines(profile_pt_map=[]) =
		[	for(i=[0:len(profile_pt_map)-2])
			let(xy = profile_pt_map[i],
				xy_next = profile_pt_map[i+1]
			)
				//[xz,xz_next]
				cline_build(pt1=xy, pt2=xy_next, line_index = i, source_line_index=undef)
		];

function convert_clines_to_pt_map(clines=[]) =
		[
		for(found =
		[	for(i=[0:len(clines)-1])
			i < len(clines)-1 ?
				[clines[i][0]]
			:
				[clines[i][0],clines[i][1]]
		])
		for(pt = found)
			pt
		]
		;
		
function cline_adjust_index(cline=[], line_index=0, source_line_index=0) =
			cline_build(pt1=cline[0], pt2=cline[1],
			   line_index = line_index, source_line_index=source_line_index
			  );

function clines_adjust_index(clines=[]) = 
	[
		for(i=[0:len(clines)-1])
			let(cline=clines[i],
				src_ln_i = cline[8] == undef ? 
					undef 
				: find_source_line_i(clines= clines, source_line_index = cline[8])
			   )
		cline_adjust_index(cline=cline, line_index=i, source_line_index=src_ln_i)
	];


function clines_adjust_index_simple(clines=[]) = 
	[
		for(i=[0:len(clines)-1])
			cline_adjust_index(cline=clines[i], line_index=i, source_line_index=clines[i][7])
	];
		
function find_source_line_i(clines=[], source_line_index=0) =
		let(arr_found = 
			array_remove_empty(
			[
				for(ln_i = [0:len(clines)-1])
					let(line = clines[ln_i])
					line[7] == source_line_index  && line[8]==undef ?
						[ln_i] : []
			])
			)
		len(arr_found) > 0 ? arr_found[0][0] : undef
		;

function cline_mark_used(cline=[], used = false) =
		[
		cline[0],
		cline[1],
		cline[2],
		cline[3],
		cline[4],
		cline[5],
		cline[6],
		cline[7],
		cline[8],
		used
		];
function cline_used(cline=[], is_used=false) =
	len(cline)<10 ?
		is_used ==  false : true : false
	: cline[9]==is_used;
	
function clines_mark_used(clines=[], index=-1, is_used=false) =
	[
		for(i=len(clines)-1)
			i==index ?
				cline_mark_used(clines[i], is_used)
			: clines[i]
	];
		
function clines_find_next_used(
			clines=[], 
			start_index=-1, 
			is_used=false, 
			seek_direction=1,
			recursive_current_index = -2,
			recursive_num_lines_checked = 0
			) =
	recursive_num_lines_checked == len(clines) ?
		[false, -1, []]
	:
	seek_direction == 0 ?
		[false, -1, []]
	:
	recursive_current_index < 0 ?
		clines_find_next_used(
			clines=clines, 
			start_index=start_index, 
			is_used=is_used, 
			seek_direction=seek_direction,
			recursive_current_index = start_index,
			recursive_num_lines_checked = 0)
	:
	let(next_index = seek_direction == 1 ?
				array_get_next_circular_index(clines, recursive_current_index)
			: 	array_get_prev_circular_index(clines, recursive_current_index),
		next_line = clines[next_index]
	)
	cline_used(next_line, is_used) ?
		[true, next_index, next_line]
	:
		clines_find_next_used(
			clines=clines, 
			index=next_index, 
			is_used=is_used, 
			seek_direction=seek_direction,
			recursive_current_index = current_index,
			recursive_num_lines_checked = recursive_num_lines_checked+1)

	;
	

// -----------------------------------------
// clines : move line
	
function clines_move_x(clines=[], move_x = 0)=
		[
			for(cline = clines)
				cline_move_x(cline=cline, move_x=move_x)
		];
			
function cline_move_x(cline=[], move_x=0) =
	cline_build(pt1=pt_move_x(point=cline[0], move_x=move_x), 
			   pt2=pt_move_x(point=cline[1], move_x=move_x),
			   line_index = cline[7], source_line_index=cline[8]
			  )
	;

function pts_move_x(pts=[], move_x=0) =
			[
				for(pt=pts)
					[pt.x+move_x, pt.y]
			];
			
			
function pt_move_x(point=[], move_x=0) = [point.x+move_x,point.y];	
					

//-----------------------------------------
// clines : draw line				

module draw_cline(cline=[[],[],1,1,1,1], col = "yellow")
{
	fine_xy_line(cline[0], cline[1], col=col);
}
				
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
					
module fine_xy_circle(r=2, fn=360)
{
    fine_circle(r=r, fn=fn);
}
module fine_xy_circle_ideal(r=2)
{
    fine_circle(r=r, fn=3600);
}

module fine_yz_circle(r=2, fn=360)
{
    rotate([0,90,0])
    fine_circle(r=r, fn=fn);
}
module fine_yz_circle_ideal(r=2)
{
    rotate([0,90,0])
    fine_circle(r=r, fn=3600);
}

module fine_circle(r=2, fn=360)
{
    difference()
     {
    circle(r=r+0.0001,$fn=fn);
    circle(r=r-0.0001,$fn=fn);
     }
}

//translate([10/2,0,0])
//fine_x_xy_line(l=10);
module fine_x_xy_line(l=10, width=1, col= "yellow") 
{
	color(col, 0.6)
    cube([l,width,0.0002],center = true);
}
module fine_y_xy_line(l=10, width=1, col= "yellow")
{
	color(col, 0.6)
    cube([0.0002,l,width],center = true);
}



module fine_y_yz_line(l=10, width=1, col= "yellow")
{
	color(col, 0.6)
    cube([width,l,0.0002],center = true);
}
module fine_z_yz_line(l=10, width=1, col= "yellow")
{
	color(col, 0.6)
    cube([width,0.0002,l],center = true);
}

module fine_yz_yz_line(corner1, corner2)
{
	pt1 = corner1[0];
	pt2 = corner2[0];
	echo("pt1",pt1);
	echo("pt2",pt2);
	dt_z = pt2.z-pt1.z;
	dt_y = pt2.y-pt1.y;
	echo("dt_z",dt_z);
	echo("dt_y",dt_y);
	angle = (dt_y==0 ? 0 : atan(dt_z/dt_y));
	echo("angle",angle);
	l = sqrt(dt_z*dt_z+dt_y*dt_y);
	rotation = dt_z >= 0 ?
				dt_y >= 0 ? angle : angle + 90
			:
				dt_y >= 0 ?  angle  : angle + 180;
	translate(pt1)
    rotate([rotation,0,0])
	translate([0,l/2,0])
    fine_y_yz_line(l=l);
}

/*
fine_xy_line([0, 0], [0, 0]);
fine_xy_line([0, 0], [1, 0]);
fine_xy_line([0, 0], [1, 1]);
fine_xy_line([0, 0], [0, 1]);
fine_xy_line([0, 0], [-1, 1]);
fine_xy_line([0, 0], [-1, 0]);
fine_xy_line([0, 0], [-1, -1]);
fine_xy_line([0, 0], [0, -1]);
fine_xy_line([0, 0], [1, -1]);
*/
module fine_xy_line(pt1=[1,0], pt2=[1,1], col = "red")
{
	//echo("pt1",pt1);
	//echo("pt2",pt2);
	dt_x = pt2.x-pt1.x;
	dt_y = pt2.y-pt1.y;
	//echo("dt_x",dt_x);
	//echo("dt_y",dt_y);
	angle = (dt_y==0 ? 0 : atan(dt_y/dt_x));
	//echo("angle",angle);
	rotation = dt_x >= 0 ? angle : angle+180;
	//echo("rotation",rotation);
	l = sqrt(dt_x*dt_x+dt_y*dt_y);
	//echo("l",l);
	translate(pt1)
    rotate([0,0,rotation])
	translate([l/2,0,0])
    fine_x_xy_line(l=l, width = 0.1, col = col);
}

module fine_x_xy_line(l=10, width=1, col= "yellow" )
{
	color(col, 0.6)
    cube([l,0.0002,width],center = true);
}


module fine_yz_polygon(corners)
{
	for(i = [0:1:len(corners)-2])
		fine_yz_yz_line(corners[i], corners[i+1]);
}

module fine_distance(complex_distance)
{

	l = c_corner_get_distance(complex_distance[1]);
	echo("complex_distance[1][0]", complex_distance[1][0], l);
	echo("complex_distance[3][0]", complex_distance[3][0]);
	echo("complex_distance[4][0]", complex_distance[4][0]);
	fine_yz_yz_line(complex_distance[3], complex_distance[4]);
	translate(complex_distance[1][0]+[0,l/2,0])
	fine_y_yz_line(l=abs(l));
}

//fine_xy_cube(size=[10,20]);
module fine_xy_cube(size=[10,20])
{
    translate([size[0]/2,0,0])
    fine_x_xyline(l=size[0]);
    translate([0,size[1]/2,0])
    fine_y_xyline(l=size[1]);
    translate([size[0]/2,size[1],0])
    fine_x_xyline(l=size[0]);
    translate([size[0],size[1]/2,0])
    fine_y_xyline(l=size[1]);
}

module fine_yz_cube(size=[10,20])
{
    translate([0,0,size[0]/2])
    fine_z_yz_line(l=size[0]);
    translate([0,size[1]/2,0])
    fine_y_yz_line(l=size[1]);
    translate([0,size[1],size[0]/2])
    fine_z_yz_line(l=size[0]);
    translate([0,size[1]/2,size[0]])
    fine_y_yz_line(l=size[1]);
}

fine_point_length = 0.3;


module fine_xy_point(point = [10,10], width = 1, col = "red")
{
    translate([point[0],point[1],0])
    fine_x_xy_line(l=fine_point_length, width=width, col = col);
    translate([point[0],point[1],0])
    rotate([0,0,90])
    fine_x_xy_line(l=fine_point_length, width=width, col = col);
}
module fine_yz_point(point = [10,10], width = 1, col = "red")
{
    color( "red", 0.8 )
    translate([0,point[1],point[2]])
    fine_y_yz_line(l=fine_point_length, width=width, col = col);
    color( "red", 0.8 )
    translate([0,point[1],point[2]])
    fine_z_yz_line(l=fine_point_length, width=width, col = col);
}

