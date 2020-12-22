#!/usr/bin/env bash
# Purpose: Extract aseg table from longitudinal processed fs 7.1.0
source ../../../config

export SUBJECTS_DIR=$FS_DATA_DIR

if [ ! -e $ASEG_DATA_DIR ]; then
    mkdir -p $ASEG_DATA_DIR
fi

sed 's/fsid_base/fsid-base/g' $QDEC_DATA_DIR/sorted.qdec.table.dat > ${ASEG_DATA_DIR}/sorted.qdec.table.dat.modified
echo "> 1a. Extracts stats from MRI data."
asegstats2table \
    --qdec-long ${ASEG_DATA_DIR}/sorted.qdec.table.dat.modified \
    -t $ASEG_DATA_DIR/aseg.long.table 

rm ${ASEG_DATA_DIR}/sorted.qdec.table.dat.modified