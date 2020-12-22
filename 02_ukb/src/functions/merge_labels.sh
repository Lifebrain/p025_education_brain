#!/usr/bin/env bash
# Purpose: Merge negative labels together

if [ $# -ne 3 ]; then
    echo "Usage: $0 <measure> <threshold> <output_directory>" 
    exit 0
else
    measure=$1
    threshold=$2
    output_directory=$3
fi

source ../../config

# Find labels corresponding to negative clusters
for hemi in "lh" "rh"
do
    # Extract negative clusterts
    label_numbers=$(awk '{ if ($2<0 && $1 != "#") print $1}' \
        ${output_directory}/p_maps/glmdir.sm15.${hemi}.${measure}/slope/cache.${threshold}.abs.sig.cluster.summary)
    
    #echo $label_numbers
    labels_to_merge=
    i=0
    for label_number in ${label_numbers}
    do
        label_file=$(ls ${output_directory}/labels/*${hemi}*${threshold}*${label_number}*.label)
        if [ -e ${label_file} ]; then
            labels_to_merge+="-i ${label_file} "
            i=$((i+1))
        fi
    done

    output_file=${output_directory}/labels/sig.${hemi}.${threshold}.abs.sig.${measure}.label.negative-clusters-merged.label

    if [ $i -gt 1 ]; then
        # merge labels
        #echo mri_mergelabels ${labels_to_merge} -o ${output_file}
        mri_mergelabels ${labels_to_merge} -o ${output_file}
    else
        cp ${label_file} ${output_file}
    fi
done