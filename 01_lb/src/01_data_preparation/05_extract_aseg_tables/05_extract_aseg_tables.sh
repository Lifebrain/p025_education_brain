#!/usr/bin/env bash
# Purpose: Extract the aseg tables from freesurfer derived data
source ../../../config

# Extract aseg stats
# Create aseg stats for the given qdec.table.dat
sorted_qdec_table=${QDEC_DATA_DIR}/ALL.sorted.qdec.table.dat
aseg_long_table=${ASEG_DATA_DIR}/ALL.aseg.long.table

if [ ! -e $ASEG_DATA_DIR ]; then
    mkdir -p $ASEG_DATA_DIR
fi

# The fs qdec table needs a "fsid-base" column.
sed 's/fsid_base/fsid-base/g' $sorted_qdec_table > ${ASEG_DATA_DIR}/ALL.sorted.qdec.table.dat.tmp
echo "> 1a. Extracts stats from MRI data."

# Create link to all fs data
mkdir $ASEG_DATA_DIR/tmp
for FS_DIR in "$UIO_SUBJECT_DIR" "$MPIB_SUBJECT_DIR" "$UMU_SUBJECT_DIR" "$UB_SUBJECT_DIR" "$UCAM_SUBJECT_DIR"
do
    ln -s $FS_DIR/*.long.* $ASEG_DATA_DIR/tmp/.
done

export SUBJECTS_DIR=$ASEG_DATA_DIR/tmp/

asegstats2table \
    --qdec-long ${ASEG_DATA_DIR}/ALL.sorted.qdec.table.dat.tmp -t $aseg_long_table

rm ${ASEG_DATA_DIR}/ALL.sorted.qdec.table.dat.tmp
rm ${ASEG_DATA_DIR}/tmp/*
rmdir ${ASEG_DATA_DIR}/tmp
