#!/bin/tclsh

# tcl script
# Purpose: Display results for education and brain athrophy

set overlay_min 0.0
set overlay_mid 0.02

# Get list of "results" directory
set list_of_analysis [glob -directory "power" -- "*${hemi}*.mgz"]

set i 0
foreach analysis [lsort $list_of_analysis] {
puts "$i: Display: $analysis"
set val $analysis
sclv_read_from_dotw 0
set gaLinkedVars(fthresh) ${overlay_min}
set gaLinkedVars(fmid) ${overlay_mid}
set gaLinkedVars(fslope) 25
SendLinkedVarGroup overlay

# Set scalebar
set gaLinkedVars(scalebarflag) 1
set gaLinkedVars(colscalebarflag) 1
SendLinkedVarGroup view

set basename [file tail $analysis]

# Save lateral view
make_lateral_view
redraw

save_tiff figures/power/maps/${basename}_lateral.tif

# Make medial view
make_lateral_view
rotate_brain_y 180
redraw

save_tiff figures/power/maps/${basename}_medial.tif

incr i
}

exit
