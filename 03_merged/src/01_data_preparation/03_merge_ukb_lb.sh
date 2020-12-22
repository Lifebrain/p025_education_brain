#!/usr/bin/env bash
# Purpose: Merge UKB data with LB data to do mega-mega analysis

# 1. Merge sorted.qdec.dat files
# 2. Merge ni.mat files
# 3. Merge concatenated volume files
# 4. Merge aseg files

source ../../../config

QDEC_DIR="../../../data/07_ukb_lb_merged/01_qdec_tables"
ASEG_DIR="../../../data/07_ukb_lb_merged/03_aseg_tables"

module load matlab/R2017a

# 1. Merge sorted.qdec.dat files
echo "> 1. Merge sorted.qdec.dat files"
rm $QDEC_DIR/MEGA.sorted.qdec.table.dat
awk '{if(FNR>1 || NR==1) print $0}' $QDEC_DIR/*.sorted.qdec.table.dat > $QDEC_DIR/MEGA.sorted.qdec.table.dat

# 2. Merge ni.mat files
echo "> 2. Merge ni.mat files"
rm $QDEC_DIR/MEGA.ni.mat
ls $QDEC_DIR/*.ni.mat > ni.mat_order_to_load.txt
matlab -nodisplay -nosplash -nodesktop -r "try, run('merge_ni_files.m'), catch, exit(1), end, exit(0);" > ni_merge_log.txt

# 3. Merge concatenated files
echo "> 3. Merge concatenated files"
concat_dir="../../../data/07_ukb_lb_merged/02_concatenated_surface_data"

# Concatenate all
measure="volume"
for hemi in "rh" "lh"
do
    if [ ! -e $concat_dir/MEGA.${hemi}.${measure}.fsaverage.sm15.mgh ]; then
        echo mri_concat $concat_dir/*.${hemi}.${measure}.fsaverage.sm15.mgh \
            --o $concat_dir/MEGA.${hemi}.${measure}.fsaverage.sm15.mgh > merge_mgh_cmd.txt
        mri_concat $concat_dir/*.${hemi}.${measure}.fsaverage.sm15.mgh \
            --o $concat_dir/MEGA.${hemi}.${measure}.fsaverage.sm15.mgh
    fi
done

# 4. Merge aseg data
echo "> 4. Merge aseg data"
rm $ASEG_DIR/MEGA.aseg.long.table
awk '{if(FNR>1 || NR==1) print $0}' $ASEG_DIR/*.aseg.long.table > $ASEG_DIR/MEGA.aseg.long.table