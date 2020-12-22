#!/bin/tcl
# tlc script
# Purpose: Automatic creation of .tif files for Anders

set output_prefix_figures ""
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

        # load overlay
        set val $analysis
        sclv_read_from_dotw 0

        # Set min max of overlay
        set gaLinkedVars(fthresh) ${overlay_min}
        set gaLinkedVars(fmid) ${overlay_mid}

        SendLinkedVarGroup overlay

        set basename [file tail $analysis]

        # Set scalebar
        set gaLinkedVars(scalebarflag) 1
        set gaLinkedVars(colscalebarflag) 1
        SendLinkedVarGroup view

        # Save lateral view
        make_lateral_view
        redraw

        save_tiff figures/publication/p_maps/${basename}_lateral.tif

        # Make inferior view
        make_lateral_view
        rotate_brain_x 90
        redraw
        save_tiff figures/publication/p_maps/${basename}_inferior.tif

        # Make medial view
        make_lateral_view
        rotate_brain_y 180
        redraw
        save_tiff figures/publication/p_maps/${basename}_medial.tif

        # Make superior view
        make_lateral_view
        rotate_brain_x -90
        redraw
        save_tiff figures/publication/p_maps/${basename}_superior.tif

        # Make anterior view
        make_lateral_view
        rotate_brain_y 90
        redraw
        save_tiff figures/publication/p_maps/${basename}_anterior.tif

        # Make posterior view
        make_lateral_view
        rotate_brain_y -90
        redraw
        save_tiff figures/publication/p_maps/${basename}_posterior.tif
    }
}
exit