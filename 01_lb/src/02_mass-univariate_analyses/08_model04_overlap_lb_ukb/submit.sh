#!/bin/bash

module load matlab/R2017a

source ../../../config

ukb_data="/tsd/p23sharedp274/data/durable/p025-education_brain/output/02_mass-univariate_analyses/03_model03_edu/p_maps"
lb_data="${OUTPUT_DIR}/02_mass-univariate_analyses/04_model04_edu/p_maps"

export output_dir="${OUTPUT_DIR}/02_mass-univariate_analyses/08_model04_overlap_lb_ukb"

# Link data to output directory
mkdir -p $output_dir/p_maps-source
mkdir -p $output_dir/p_maps
mkdir -p $output_dir/labels

for ukb_file in $(ls ${ukb_data}/*_C.mgh)
do 
    base=$(basename ${ukb_file})
    # Change filename so that do_comparison.m works
    ln -sf ${ukb_file} ${output_dir}/p_maps-source/ukb.${base/volume_edu_main/th00.abs.sig.masked.volume_C}
done 

for lb_file in $(ls ${lb_data}/*_C.mgh)
do 
    base=$(basename ${lb_file})
    # Change filename so that do_comparison.m works
    ln -sf ${lb_file} ${output_dir}/p_maps-source/lb.${base/volume_edu_main/th00.abs.sig.masked.volume_C}
done 

matlab -nodisplay -nodesktop -nosplash < do_comparison.m

# Extract stats
cd ${COMMON_FUNCTIONS} && \
bash extract_stats_from_label.sh \
    volume \
    lh \
    combined_binarized.sig.lh.th13.abs.sig.masked.volume_C.mgh.label \
    ${output_dir}