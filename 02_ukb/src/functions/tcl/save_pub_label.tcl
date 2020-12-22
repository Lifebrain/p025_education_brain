#!/bin/tclsh

# tcl script
# Purpose: Display labels

foreach measure {volume} {

    set overlay_min 1.3
    set overlay_mid 4.0

    # Get list of "results" directory
    set list_of_analysis [glob -directory "labels" -- "*${hemi}*${measure}*.label"]

    set i 0
    foreach analysis [lsort $list_of_analysis] {

       # Read curvature file
        read_curv_to_val /cluster/projects/p23/tools/mri/freesurfer/freesurfer.6.0.1/subjects/fsaverage/surf/${hemi}.curv
        read_binary_curv

        # display curvature file
        set gaLinkedVars(curvflag) 1
        SendLinkedVarGroup view

        # Put to binary value
        set gaLinkedVars(forcegraycurvatureflag) 1
        SendLinkedVarGroup curvature

        # Change brightness
        set gaLinkedVars(offset) 0.60
        SendLinkedVarGroup scene

        redraw

        puts "$i: Display: $analysis"
        labl_load $analysis
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

        save_tiff figures/publication/label/${basename}_lateral.tif

        # Make medial view
        make_lateral_view
        rotate_brain_y 180
        redraw

        save_tiff figures/publication/label/${basename}_medial.tif

        labl_remove_all

        incr i
    }
}
exit
