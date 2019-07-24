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


//
//-------------------------------------------------------------------
//-------------------------------------------------------------------
// BSPT (British Standard Pipe Taper)
// - Whitworth pipe thread DIN ISO 228 (DIN 259) 
// - https://en.wikipedia.org/wiki/British_Standard_Pipe
// - British Engineering Standard Association Reports No. 21 - 1938
//
// http://books.google.ch/books?id=rq69qn9WpQAC&pg=PA108&lpg=PA108&dq=British+Engineering+Standard+Association+Reports+No.+21+-+1938&source=bl&ots=KV2kxT-fFR&sig=3FBCPA3Kzhd62nl1Tz08g1QyyIY&hl=en&sa=X&ei=JehZVPWdA4LfPZyEgIAN&ved=0CBQQ6AEwAA#v=onepage&q=British%20Engineering%20Standard%20Association%20Reports%20No.%2021%20-%201938&f=false
// 
// http://valiagroups.net/dimensions-of-pipe-threads.htm
// http://mdmetric.com/tech/thddat7.htm#pt
// 
// Male BSPT is denoted as MBSPT 
// Female BSPT is FBSPT
//
// Notes:
// a
module BSPT_thread(
        nominal_pipe_size = 3/4,  //use inch fractions not decimals !!!!!!
        length = 10, // [inches]
        internal  = false,
        backlash = 0,  //use backlash to correct too thight threads after 3D printing.
        debug = false
        )
{
    // Wikipedia:
    
    // The thread form follows the British Standard Whitworth standard:
    // - Symmetrical V-thread in which the angle between the flanks is 55° (measured in an axial plane)
    // - One-sixth of this sharp V is truncated at the top and the bottom
    // - The threads are rounded equally at crests and roots by circular arcs ending tangentially with the flanks where r ≈ 0.1373P
    // - The theoretical depth of the thread is therefore 0.6403 times the nominal pitch h ≈ 0.6403P
    
    // Other findings/definitions
    // - Peak to peak thread height is defined in most documents as 0.960491 * pitch_inch
    //   which i found is the geometrical equivalent of  (pitch_inch/2)/tan(angle)
    if(debug)
        echo("BSP_thread");
    profile_angle= 55;
    angle=profile_angle/2; //Half, to work on simpler triangle
    // Threads per inch is defined in a table according to the standard.
    threads_per_inch = get_threads_per_inch(nominal_pipe_size);
    mm_pitch = 25.4/threads_per_inch;
    // Peak to peak thread height is defined in most documents as 0.960491 * pitch_inch
    // which i found is the geometrical equivalent of  (pitch_inch/2)/tan(angle)
    peak_to_peak_height = (mm_pitch/2)/tan(angle);
    // The peak to peak height is truncated by the standard by on sixth of the peak to peak value on top and on the bottom. 
    // Most documents have "0.640327*pitch_inch" for this but it is really 
    // peak_to_peak_height-2*peak_to_peak_height/6
    h_5_6t = peak_to_peak_height-2*peak_to_peak_height/6;
    // Radius
    // The most found value for the radius is 0.137329*pitch_inch. 
    // With claim 2 of intercept theorem and a little trigonometry the formula is
    // r = (tr^2*sin(angle)) / (tr-tr*sin(angle)) where tr is the cut away one sixth of the triangle.
    clearance = (peak_to_peak_height-h_5_6t)/2;
    rad = clearance*clearance*sin(angle)/(clearance-clearance*sin(angle));
        
    //Simple rules for all threads, not really correct
    //So far, exact clearance not implemented.
    //This is a rough approximation derived from mdmetric.com data  
    max_height_inner_to_outer_flat = h_5_6t;
    min_clearance_to_outer_peak = clearance;
    max_clearance_to_outer_peak = 2 * min_clearance_to_outer_peak; // no idea, honestly
    min_outer_flat = 2 * accurateTan(angle) * min_clearance_to_outer_peak;
    max_outer_flat = 2 * accurateTan(angle) * max_clearance_to_outer_peak;

    //so far, exact clearance not implemented.
    //This is a rough approximation derived from mdmetric.com data  
    //clearance = internal ? max_clearance_to_outer_peak - min_clearance_to_outer_peak
    //                      : 0;
//TODO: Outside Diameter wie in OneNote. 1/16*diameter?? h= welche Höhe????

    // outside diameter is defined in table
    outside_diameter = get_BSP_outside_diameter(nominal_pipe_size);
    mm_diameter = outside_diameter*25.4;
    mm_profile_minimum_diameter = mm_diameter-peak_to_peak_height;

    mm_length = length*25.4;
    mm_outer_flat = (internal ? max_outer_flat : min_outer_flat);
    mm_max_height_inner_to_outer_flat = max_height_inner_to_outer_flat;
    mm_bore = nominal_pipe_size * 25.4;

    echo(internal,h_5_6t);
    echo("mm_diameter",mm_diameter);
    echo("mm_pitch",mm_pitch);
    echo("mm_outer_flat",mm_outer_flat);
    echo("mm_max_height_inner_to_outer_flat",mm_max_height_inner_to_outer_flat);
    echo("mm_bore",mm_bore);
    corsi=16;
    xz_map = v_profil_radius_xz_map(
                pitch=mm_pitch,
                profile_minimum_diameter = mm_profile_minimum_diameter/2,
                radius_height = mm_max_height_inner_to_outer_flat,
                peak_to_peak_height = peak_to_peak_height,
                coarseness_circle = corsi, 
                clearance = clearance,
                radius = rad, 
                profile_angle=profile_angle,
                deliver_valid_polygon = false
                );
    xz_map_debug = v_profil_radius_xz_map(
                pitch=mm_pitch,
                profile_minimum_diameter = mm_profile_minimum_diameter/2,
                radius_height = mm_max_height_inner_to_outer_flat,
                peak_to_peak_height = peak_to_peak_height,
                coarseness_circle = corsi, 
                clearance = clearance,
                radius = rad, 
                profile_angle=profile_angle,
                deliver_valid_polygon = true
                );

echo("xz_map_debug ", xz_map_debug);
echo("xz_map ", xz_map);
/*
translate([10,10,0])
    polygon(xz_map_debug);
*/
 
xz_map2 = rope_xz_map(mm_pitch,
        0.3, // rope_diameter, 
        0.5, //rope_bury_ratio, 
        6, //coarseness,
    mm_diameter / 2 - mm_max_height_inner_to_outer_flat, mm_diameter / 2,
        deliver_valid_polygon = true);
/*
echo("xz_map2 round", xz_map2);
    translate([11,10,0])
    polygon(xz_map2);

*/
    helix(
        pitch = mm_pitch,
        length = mm_length,
        major_radius = mm_diameter / 2,
        minor_radius = mm_diameter / 2 - mm_max_height_inner_to_outer_flat,
        internal = internal,
        n_starts = 1,
        right_handed = true,
        clearance = clearance,
        backlash = 0,
        printify_top = false,
        printify_bottom = false,
        is_channel_thread = false,
        bore_diameter = -1,
        taper_angle = 0,
        exact_clearance = true,
        tooth_profile_map  = xz_map,
        tooth_height = h_5_6t
        );
        
        
/*      
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
            bore_diameter = -1, //mm_bore,
            taper_angle = 0,//atan(1/32), //tan−1(1/32) = 1.7899° = 1° 47′ 24.474642599928302″.
            debug=debug
            );      

*/
//-----------------------------------------------------------
    // V-shaped threads with radius at peaks tooth profile map
    //-----------------------------------------------------------
    // A tooth can have any profile with multiple edges. 
    // limitations: 
    //   - z-value must not be the same for two points.
    //   - no overhangs (low convexitiy)

    // Basic tooth profile
    // Only the tooth points are defined. Connections to the next/previous
    // tooth profile gives the full tooths profile. This way no in between
    // points (at zero or at pitch) are needed.
    // The profile starts with the lowest point of radius (smallest diameter) 
    //

//TODO:


    function v_profil_radius_xz_map(pitch, 
                                    profile_minimum_diameter,
                                    radius_height, 
                                    peak_to_peak_height,
                                    coarseness_circle, 
                                    clearance, radius, profile_angle,
                                    deliver_valid_polygon) =
            let(rad_angle = 90-profile_angle/2,
                num_segs = coarseness_circle > 8 ? coarseness_circle : 8 ,
                //Segments: with 4 segements on arc we need to create
                //2 exact points and three in between.
                num_rad_segs = ceil(num_segs/4)-2,
                rad_seg_angle = rad_angle/(num_rad_segs+1),
                center_rad_lower_z = clearance+radius,
                center_rad_higher_z = peak_to_peak_height-clearance-radius
                )
            [for(xz = 
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
            )//end for
            [profile_minimum_diameter+xz[0], xz[1]]
            ]
            ;
                

    // http://www.csgnetwork.com/mapminsecconv.html
/*
    angle=55/2;
    pitch_mm = get_threads_per_inch(nominal_pipe_size);
    TPI_threads_per_inch = get_threads_per_inch(nominal_pipe_size);
    pitch_per_inch = 1.0/TPI_threads_per_inch;
    basic_radius_inch = 0.137329*pitch_per_inch;
    basic_radius_mm = 25.4*basic_radius_inch;
    for(f = [1/8:1/8:3])
        let(
        nominal = f+0.00001,//OK 
        threads_per_inch = get_threads_per_inch(f),//OK 
        pitch_inch = 1.0/threads_per_inch,//OK 
        pitch_mm = 25.4/threads_per_inch,//OK 
        thread_height_ideal_inch_defined = 0.960491 * pitch_inch, //OK , Definition !!!
        thread_height_ideal_inch = (pitch_inch/2)/tan(angle), //OK , Formula !!!
        thread_height_ideal_mm = 25.4*thread_height_ideal_inch, //OK 
    
        //height to radius peak
        height_to_rad_inch = 0.640327*pitch_inch, //OK , Definition !!!
        height_to_rad_mm = 25.4*height_to_rad_inch, //OK
        h_inch_5_6t = thread_height_ideal_inch-2*thread_height_ideal_inch/6, //OK, Formula !!!
    
        //Radius
        basic_radius_inch = 0.137329*pitch_inch, //OK , Definition !!!
        basic_radius_mm = 25.4*basic_radius_inch, //OK


        h_inch_half = thread_height_ideal_inch/2,
        tr = h_inch_half-h_inch_5_6t/2, 
        rad_inch = tr*tr*sin(angle)/
                    (tr-tr*sin(angle)),
        max_height_half_inch=h_inch_half-tr,
        max_height_defined = 0.640327 * pitch_inch /2,
    
        s_inch_half = sqrt((pitch_inch/4)*(pitch_inch/4)
                    +(thread_height_ideal_inch/2)*(thread_height_ideal_inch/2))    
        
            )
    {
        echo("nominal", nominal, "threads_per_inch", threads_per_inch, "pitch_mm",pitch_mm); 
        echo("thread_height_ideal_inch",thread_height_ideal_inch,"thread_height_ideal_inch_defined", thread_height_ideal_inch_defined, "must be equal");
        echo("height_to_rad_inch",height_to_rad_inch, "h_inch_5_6t", h_inch_5_6t, "must be equal");
        echo("s_inch_half", s_inch_half,"h_inch_half",h_inch_half );
        echo("tr", tr);
        echo("rad_inch", rad_inch, "basic_radius_inch",basic_radius_inch, "must be equal", e_rad/25.4 );
        echo("max_height_half_inch", max_height_half_inch,"max_height_defined",max_height_defined, "must be equal");
    }
    
    height = 0.960491 * pitch_per_inch; //height from peak to peak , ideal without flat/radius
    max_height_inner_to_outer_flat = 0.640327 * pitch_per_inch; 
    
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
    
    echo("mm_diameter",mm_diameter);
    echo("mm_pitch",mm_pitch);
    echo("mm_outer_flat",mm_outer_flat);
    echo("mm_max_height_inner_to_outer_flat",mm_max_height_inner_to_outer_flat);
    echo("mm_bore",mm_bore);

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
            bore_diameter = -1, //mm_bore,
            taper_angle = 0,//atan(1/32), //tan−1(1//32) = 1.7899° = 1° 47′ 24.474642599928302″.
            debug=debug
            );  

        */
    
    //see: https://en.wikipedia.org/wiki/British_Standard_Pipe
    function get_threads_per_inch(nominal_pipe_size) = 
         nominal_pipe_size < 1/4 ? 28
        : nominal_pipe_size < 1/2 ? 19
        : nominal_pipe_size < 1 ? 14
        : nominal_pipe_size < 7 ? 11
        : nominal_pipe_size < 11 ? 10
        : 8
        ;
    
     //see https://en.wikipedia.org/wiki/British_Standard_Pipe
    function get_BSP_outside_diameter(nominal_pipe_size) =  
         nominal_pipe_size == 1/16 ? 7.723 //0.3041
        : nominal_pipe_size == 1/8 ? 9.728 //0.3830 
        : nominal_pipe_size == 1/4 ? 13.157 //0.518
        : nominal_pipe_size == 3/8 ? 16.662 //0.656
        : nominal_pipe_size == 1/2 ? 20.955 //0.825
        : nominal_pipe_size == 5/8 ? 22.911 //0.902
        : nominal_pipe_size == 3/4 ? 26.441 //0.9495
        : nominal_pipe_size == 7/8 ? 30.201 //1.0975
        : nominal_pipe_size == 1 ? 33.249 //1.309
        : nominal_pipe_size == 1+1/8 ? 37.897 //1.4920
        : nominal_pipe_size == 1+1/4 ? 41.910 //1.6500
        : nominal_pipe_size == 1+3/8 ? 44.323 //1.7450
        : nominal_pipe_size == 1+1/2 ? 47.803 //1.8820
        : nominal_pipe_size == 1+5/8 ? 52.883 //2.0820
        : nominal_pipe_size == 1+3/4 ? 53.746 //2.1160
        : nominal_pipe_size == 1+7/8 ? 56.998 //2.2440
        
        : nominal_pipe_size == 2 ? 59.614 //2.3470
        : nominal_pipe_size == 2+1/4 ? 65.710 //2.5870
        : nominal_pipe_size == 2+1/2 ? 75.184 //2.9600
        : nominal_pipe_size == 2+3/4 ? 81.534 //3.2100

        : nominal_pipe_size == 3 ? 87.884 //3.4600
        : nominal_pipe_size == 3+1/4 ? 93.980 //3.5835
        : nominal_pipe_size == 3+1/2 ? 100.330 //3.8335
        : nominal_pipe_size == 3+3/4 ? 106.680 //4.0835

        : nominal_pipe_size == 4 ? 113.030 //4.450
        : nominal_pipe_size == 4+1/2 ? 125.730 //4.9500
        : nominal_pipe_size == 5 ? 138.430 //5.4500 
        : nominal_pipe_size == 5+1/2 ? 151.130 //5.9500
        : nominal_pipe_size == 6 ? 163.830 //6.4500
        : nominal_pipe_size == 7 ? 189.230 //7.4500
        : nominal_pipe_size == 8 ? 214.630 //8.4500
        : nominal_pipe_size == 9 ? 240.030 //9.4500
        : nominal_pipe_size == 10 ? 265.430 //10.4500
        : nominal_pipe_size == 11 ? 290.830 //11.4500    
        : nominal_pipe_size == 12 ? 316.230 //12.4500
        : nominal_pipe_size == 13 ? 347.472 //13.6800
        : nominal_pipe_size == 14 ? 372.872 //14.6800
        : nominal_pipe_size == 15 ? 398.272 //15.6800
        : nominal_pipe_size == 16 ? 423.672 //16.6800
        : nominal_pipe_size == 17 ? 449.072 //17.6800
        : nominal_pipe_size == 18 ? 474.472 //18.6800
        : 0
        ;
for(i=[0:len(BSP_data)-1])
{
    echo("BSP",BSP_data[i][0], "diff", (BSP_data[i][3]-BSP_data[i][5])/2 );
}
//see https://en.wikipedia.org/wiki/British_Standard_Pipe  
// G / R     Thread   Thread   Major            Minor            Gauge    Tapping drill
// size      density  pitch    diameter     diameter     length   R 95%    G 80%
//(in)       (in−1)   (mm)(in)(mm)(in)(mm)(in)(mm)(mm)(mm)
BSP_data = [
[1/16, 28, 0.907, 0.3041, 7.723, 0.2583, 6.561, 5/32, 4.0, 6.6, 6.8],
[1/8, 28, 0.907, 0.3830, 9.728, 0.3372, 8.566, 5/32, 4.0, 8.6, 8.8]
,​[1/4, 19, 1.337, 0.5180, 13.157, 0.4506, 11.445, 0.2367, 6.0, 11.5, 11.8]
,[3/8, 19, 1.337, 0.6560, 16.662, 0.5886, 14.950, 1/4, 6.4, 15.0, 15.3]
//
];
/*
,
​[3/8, 19, 1.337, 0.6560, 16.662, 0.5886, 14.950, 1/4, 6.4, 15.0, 15.3]
,
​[1/2, 14, 1.814, 0.8250, 20.955, 0.7335, 18.631, 0.3214, 8.2, 18.7, 19.1],
​[5/8, 14, 1.814, 0.9020, 22.911, 0.8105, 20.587, 0.3214, 8.2, 20.7, 21.1],
​[3/4, 14, 1.814, 1.0410, 26.441, 0.9495, 24.117, 3/8, 9.5, 24.2, 24.6],
​[7/8, 14, 1.814, 1.1890, 30.201, 1.0975, 27.877, 3/8, 9.5, 28.0, 28.3],
[1, 11, 2.309, 1.3090, 33.249, 1.1926, 30.291, 0.4091, 10.4, 30.4, 30.9]
,
​[1+1/8, 11, 2.309, 1.4920, 37.897, 1.3756, 34.939, 0.4091, 10.4, 35.1, 35.5],
​[1+1/4, 11, 2.309, 1.6500, 41.910, 1.5335, 38.952, 1/2, 12.7, 39.1, 39.5],
​[1+3/8, 11, 2.309, 1.7450, 44.323, 1.6285, 41.365, 1/2, 12.7, 41.5, 42.0],
​[1+1/2, 11, 2.309, 1.8820, 47.803, 1.7656, 44.845, 1/2, 12.7, 45.0, 45.4],
​[1+5/8, 11, 2.309, 2.0820, 52.883, 1.9656, 49.926, 5/8, 15.9, 50.1, 50.5],
​[1+3/4, 11, 2.309, 2.1160, 53.746, 1.9995, 50.788, 5/8, 15.9, 50.9, 51.4],
​[1+7/8, 11, 2.309, 2.2440, 56.998, 2.1276, 54.041, 5/8, 15.9, 54.2, 54.6],
[2, 11, 2.309, 2.3470, 59.614, 2.2306, 56.656, 5/8, 15.9, 56.8, 57.2]
,
​[2+1/4, 11, 2.309, 2.5870, 65.710, 2.4706, 62.752, 11/16, 17.5, 62.9, 63.3],
​[2+1/2, 11, 2.309, 2.9600, 75.184, 2.8435, 72.226, 11/16, 17.5, 72.4, 72.8],
​[2+3/4, 11, 2.309, 3.2100, 81.534, 3.0935, 78.576, 13/16, 20.6, 78.7, 79.2],
[3, 11, 2.309, 3.4600, 87.884, 3.3435, 84.926, 13/16, 20.6, 85.1, 85.5],
​[3+1/4, 11, 2.309, 3.7000, 93.980, 3.5835, 91.022, 7/8, 22.2, 91.2, 91.6],
​[3+1/2, 11, 2.309, 3.9500, 100.330, 3.8335, 97.372, 7/8, 22.2, 97.5, 98.0],
​[3+3/4, 11, 2.309, 4.2000, 106.680, 4.0835, 103.722, 7/8, 22.2, 103.9, 104.3],
[4, 11, 2.309, 4.4500, 113.030, 4.3335, 110.072, 1, 25.4, 110.2, 110.7],
​[4+1/2, 11, 2.309, 4.9500, 125.730, 4.8335, 122.772, 1, 25.4, 122.9, 123.4],
[5, 11, 2.309, 5.4500, 138.430, 5.3335, 135.472, 1 1/8, 28.6, 135.6, 136.1],
​[5+1/2, 11, 2.309, 5.9500, 151.130, 5.8335, 148.172, 1 1/8, 28.6, 148.3, 148.8],
[6, 11, 2.309, 6.4500, 163.830, 6.3335, 160.872, 1 1/8, 28.6, 161.0, 161.5],
[7, 10, 2.540, 7.4500, 189.230, 7.3220, 185.979, 1 3/8, 34.9, 186.1, 186.6],
[8, 10, 2.540, 8.4500, 214.630, 8.3220, 211.379, 1 1/2, 38.1, 211.5, 212.0],
[9, 10, 2.540, 9.4500, 240.030, 9.3220, 236.779, 1 1/2, 38.1, 236.9, 237.4],
[10, 10, 2.540, 10.4500, 265.430, 10.3220, 262.179, 1 5/8, 41.3, 262.3, 262.8],
[11, 8, 3.175, 11.4500, 290.830, 11.2900, 286.766, 1 5/8, 41.3, 287.0, 287.6],
[12, 8, 3.175, 12.4500, 316.230, 12.2900, 312.166, 1 5/8, 41.3, 312.4, 313.0],
[13, 8, 3.175, 13.6800, 347.472, 13.5200, 343.408, 1 5/8, 41.3, 343.6, 344.2],
[14, 8, 3.175, 14.6800, 372.872, 14.5200, 368.808, 1 3/4, 44.5, 369.0, 369.6],
[15, 8, 3.175, 15.6800, 398.272, 15.5200, 394.208, 1 3/4, 44.5, 394.4, 395.0],
[16, 8, 3.175, 16.6800, 423.672, 16.5200, 419.608, 1 7/8, 47.6, 419.8, 420.4],
[17, 8, 3.175, 17.6800, 449.072, 17.5200, 445.008, 2, 50.8, 445.2, 445.8],
[18, 8, 3.175, 18.6800, 474.472, 18.5200, 470.408, 2, 50.8, 470.6, 471.2]
*/
//];

} //END BSP

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
            diameter = 25.4*0.553,      //technical drawing
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
    function get_right_flat(h_tooth) = h_tooth / accurateTan (right_angle)    ;

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
                (   tan_right*clearance >= backlash/2 ?
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
                tooth_profile_map  = simple_tooth_xz_map(left_flat, upper_flat, tooth_flat,
                                                                                            minor_radius, major_radius ),
                tooth_height = tooth_height,
                debug = debug
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
                            [ [ minor_rad,  // x
                                    0],         // z offset
                                [   major_rad,
                                    left_flat],
                                [   major_rad,
                                    left_flat + upper_flat],
                                [   minor_rad,
                                    tooth_flat]
                            ]
                        :
                            [ [ minor_rad,
                                    0],
                                [   major_rad,
                                    left_flat],
                                [   minor_rad,
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
    exact_clearance = false,
    taper_angle = 0)
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
        taper_angle = taper_angle
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
    exact_clearance = true,
    taper_angle = 0
)
{
    tooth_height = rope_diameter/2 * rope_bury_ratio;
    minor_radius = major_radius-tooth_height;
    clearance = get_clearance(clearance, internal);
    backlash = get_backlash(backlash, internal);

    xz_map = rope_xz_map(pitch, 
                    rope_diameter, 
                    rope_bury_ratio, 
                    coarseness,
                    minor_radius, 
                    major_radius,
                    deliver_valid_polygon = false);

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
        tooth_profile_map  = xz_map,
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

    function rope_xz_map(
                pitch, 
                rope_diameter, 
                rope_bury_ratio, 
                coarseness,
                minor_radius, 
                major_radius,
                deliver_valid_polygon) =
            let(rope_radius = rope_diameter/2,
                    buried_depth = rope_radius * rope_bury_ratio,
                    unburied_depth = rope_radius-buried_depth,
                    buried_height =  2*sqrt(pow(rope_radius,2)-pow(unburied_depth,2)), //coarseness must go over the buried part only
                    unused_radius = rope_radius - sqrt(pow(rope_radius,2)-pow(unburied_depth,2)),
                    left_upper_flat    = (pitch-(rope_diameter-2*unused_radius))/2,
                    right_upper_flat = pitch-(rope_diameter-2*unused_radius) -left_upper_flat
                    )
            concat(
                [   [major_radius, 0],
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
                [   [major_radius, pitch-right_upper_flat]]
            
            //Debug              
             ,deliver_valid_polygon ? 
                [[minor_radius-rope_diameter,pitch],[minor_radius-rope_diameter,0]] : []
            );

// -----------------------------------------------------------
// Helper Functions
// -----------------------------------------------------------

function get_clearance(clearance, internal) = (internal ? clearance : 0);
function get_backlash(backlash, internal) = (internal ? backlash : 0);

            