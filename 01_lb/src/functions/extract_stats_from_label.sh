#!/bin/bash
# Purpose: extract volume stats based on label, merges this stats with the qdec table

if [ $# -ne 4 ]; then
    echo "Usage: $0 <measure> <hemi> <label> <output_directory>" 
    exit 0
else
    measure=$1
    hemi=$2
    label_file=$3
    output_directory=$4
fi

source ../../config

if [ ! -d $output_directory/stats ]; then
    mkdir -p $output_directory/stats
fi

output_stats_file=$output_directory/stats/${label_file}.stats

mri_segstats \
    --slabel fsaverage ${hemi} $output_directory/labels/${label_file} \
    --avgwf $output_stats_file \
    --excludeid 0 \
    --i $CONCAT_DATA_DIR/ALL.${hemi}.volume.fsaverage.sm15.mgh
