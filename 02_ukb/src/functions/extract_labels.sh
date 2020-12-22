#!/usr/bin/env bash
# Purpose: Extract labels from the p-maps clusters which survives the 
# multiple comparison correction.

if [ $# -ne 2 ]; then
    echo "Usage: $0 <measure> <output_directory>" 
    exit 0
else
    measure=$1
    output_directory=$2
fi

source ../../config

if [ ! -d $output_directory/labels ]; then
    mkdir $output_directory/labels
fi

for hemi in "lh" "rh"
do
    for threshold in "th13" "th20" "th30" "th40"
    do
        annot_file=${output_directory}/p_maps/glmdir.sm15.${hemi}.${measure}/slope/cache.${threshold}.abs.sig.ocn.annot
        if [ -e ${annot_file} ]; then
            label_base="sig.${hemi}.${threshold}.abs.sig.${measure}.label"
            mri_annotation2label \
                --subject fsaverage \
                --hemi ${hemi} \
                --labelbase ${label_base} \
                --annotation ${annot_file}
            mv ${FREESURFER_HOME}/subjects/fsaverage/label/${label_base}*.label ${output_directory}/labels/.
        fi  
    done
done