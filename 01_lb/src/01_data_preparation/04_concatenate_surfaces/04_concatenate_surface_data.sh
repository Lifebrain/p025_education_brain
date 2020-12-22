#!/usr/bin/env bash
# Purpose: Extract and concatenate surface volumes.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <measure>"
    exit 0
else
    measure=$1
fi

source ../../../config

mkdir -p $CONCAT_DATA_DIR

# UB
export SUBJECTS_DIR=$UB_SUBJECT_DIR
bash structuralSurfaceData.sh $measure 15 UB &
process_1=$!

# UmU
export SUBJECTS_DIR=$UMU_SUBJECT_DIR
bash structuralSurfaceData.sh $measure 15 UMU &
process_2=$1

wait $process_1 $process_2

# MPIB
export SUBJECTS_DIR=$MPIB_SUBJECT_DIR
bash structuralSurfaceData.sh $measure 15 MPIB &
process_1=$!

# UIO
export SUBJECTS_DIR=$UIO_SUBJECT_DIR
bash structuralSurfaceData.sh $measure 15 UIO &
process_2=$!

wait $process_1 $process_2

# UCAM
export SUBJECTS_DIR=$UCAM_SUBJECT_DIR
bash structuralSurfaceData.sh $measure 15 UCAM

# Concatenate all
for hemi in "rh" "lh"
do
    if [ ! -e $CONCAT_DATA_DIR/ALL.${hemi}.${measure}.fsaverage.sm15.mgh ]; then
        mri_concat $CONCAT_DATA_DIR/*.${hemi}.${measure}.fsaverage.sm15.mgh \
            --o $CONCAT_DATA_DIR/ALL.${hemi}.${measure}.fsaverage.sm15.mgh
    fi
done