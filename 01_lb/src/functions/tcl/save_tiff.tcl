#!/bin/tclsh

# tcl script
# Purpose: Display results for education and brain athrophy

set wd [file tail [pwd]]

foreach measure {volume thickness area} {

    if { $wd == "08_model04_overlap_lb_ukb" } {
        set overlay_min 0.9999
        set overlay_mid 1.0
    } else {
        set overlay_min 1.3
        set overlay_mid 4.0
    }
    
    # Get list of "results" directory
    set list_of_analysis [glob -directory "p_maps" -- "*${hemi}*${measure}*C.mgh"]

    set i 0
    foreach analysis [lsort $list_of_analysis] {
        puts "$i: Display: $analysis"
        set val $analysis
        sclv_read_from_dotw 0
        set gaLinkedVars(fthresh) ${overlay_min}
        set gaLinkedVars(fmid) ${overlay_mid}
        SendLinkedVarGroup overlay
        
        # Set scalebar
        set gaLinkedVars(scalebarflag) 1
        set gaLinkedVars(colscalebarflag) 1
        SendLinkedVarGroup view

        set basename [file tail $analysis]

        # Save lateral view
        make_lateral_view
        redraw

        save_tiff figures/normal/p_maps/${basename}_lateral.tif

        # Make medial view
        make_lateral_view
        rotate_brain_y 180
        redraw

        save_tiff figures/normal/p_maps/${basename}_medial.tif

        incr i
    }
}
exit
