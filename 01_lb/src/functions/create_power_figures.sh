#!/usr/bin/env bash

source ../../config

# Output directory to create figures in
output_dir=$1

# For tksurfer to work, we need freesurfer 6.0
export FREESURFER_HOME=/cluster/projects/p274/tools/mri/freesurfer/freesurfer.6.0.1
source $FREESURFER_HOME/SetUpFreeSurfer.sh

#set -eET
base_name=$(basename $output_dir)
cd $output_dir

if [ 1 == 1 ]; then
    mkdir -p figures/power/maps

    tksurfer fsaverage lh inflated -tcl $COMMON_DATA_FUNCTIONS/tcl/save_power_tiff.tcl
    tksurfer fsaverage rh inflated -tcl $COMMON_DATA_FUNCTIONS/tcl/save_power_tiff.tcl

    # Make background transparent on the normal and publication figures, and swap white with black on label
    for figure in $(ls figures/power/maps/*.tif)
    do
        convert $figure -fuzz 1% -transparent "#000000" ${figure/.tif/_transparent.png}
        convert ${figure/.tif/_transparent.png} -fuzz 1% -fill black -opaque white ${figure/.tif/_transparent.png}
        convert ${figure/.tif/_transparent.png} -fuzz 1% -transparent "#000000" ${figure/.tif/_transparent.png}
    done


    # Extract the colorbar
    convert $figure \
        -fuzz 1% \
        -transparent "#000000" \
        -crop 100x210+500+390\
        -fill black \
        -opaque white \
        -pointsize 14 \
        -font helvetica \
        -stroke black \
        -strokewidth 0.2 \
        figures/power/bar.png
fi

for analysis in "edu" "eduxint" "int"
do
    for type in "Bhat" "conf-min" "conf-max"
    do
        figure_list="
            figures/power/maps/rh_${type}_${analysis}.mgz*lateral*.png \
            figures/power/maps/lh_${type}_${analysis}.mgz*lateral*.png \
            figures/power/maps/rh_${type}_${analysis}.mgz*medial*.png \
            figures/power/maps/lh_${type}_${analysis}.mgz*medial*.png"
        figures_to_concat=""
        i=0
        for figure in $figure_list;
        do
            if [ -e $figure ]; then
                figures_to_concat="$figures_to_concat $figure"
                i=$((i+1))
            fi
        done
        echo $figures_to_concat
        if [ $i -gt 1 ]; then
            output_figure=figures/power/${type}_${analysis}.png
            montage -mode concatenate -background transparent -crop 500x350+50+125 \
                $figures_to_concat \
                $output_figure    
            
            montage -mode concatenate -background transparent \
                $output_figure figures/power/bar.png \
                $output_figure
        fi
    done

    # Concatenate all figures into one
    montage -mode concatenate \
        figures/power/Bhat_${analysis}.png \
        figures/power/conf-min_${analysis}.png \
        figures/power/conf-max_${analysis}.png \
        figures/power/power_maps_overview_${analysis}.png
    montage -mode concatenate \
        figures/power/histogram/hist_Bhat_${analysis}.png \
        figures/power/histogram/hist_ci_min_${analysis}.png \
        figures/power/histogram/hist_ci_max_${analysis}.png \
        figures/power/power_histogram_overview_${analysis}.png
done