#!/usr/bin/env bash
# Purpose: Extract individual aseg files to merge them better

source ../../../config

MEGA_QDEC_DIR="../../../data/07_ukb_lb_merged/01_qdec_tables"
MEGA_ASEG_DIR="../../../data/07_ukb_lb_merged/03_aseg_tables"

# Extract aseg stats
# Create aseg stats for the given qdec.table.dat
for sorted_qdec_table in $(ls $MEGA_QDEC_DIR --ignore=MEGA* | grep sorted)
do
    dataset=$(echo $sorted_qdec_table | awk -F"." '{print $1}')
    if [ $dataset == "ukb_long" ]; then
        continue;
    fi
    echo $dataset

    aseg_long_table=${MEGA_ASEG_DIR}/$dataset.aseg.long.table
    sorted_qdec_table=$MEGA_QDEC_DIR/${sorted_qdec_table}

    if [ -e ${sorted_qdec_table} ] && [ ! -e ${aseg_long_table} ] ; then
        sed 's/fsid_base/fsid-base/g' $sorted_qdec_table > ${MEGA_ASEG_DIR}/tmp
        echo "> 1a. Extracts stats from MRI data."
        if [ $dataset == "UIO" ]; then
            data_dir="UiO"
        elif [ $dataset == "UMU" ]; then
            data_dir="UmU"
        else
            data_dir=$dataset
        fi
        export SUBJECTS_DIR=$SITE_DATA_DIR/$data_dir/derivatives/freesurfer.7.1.0_recon
        asegstats2table \
            --qdec-long ${MEGA_ASEG_DIR}/tmp -t $aseg_long_table
        
        rm ${MEGA_ASEG_DIR}/tmp
    fi
done