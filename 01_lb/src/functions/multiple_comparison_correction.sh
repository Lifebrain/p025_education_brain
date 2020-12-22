#!/bin/sh
# Purpose: Make dummy analysis for multiple comparison correction 

if [ $# -ne 2 ]; then
    echo "Usage: $0 <measure> <path/to/data>"
    exit 0
else
    measure=$1
    data_to_correct=$2
fi

source ../../config

if [ ! -d $COMMON_DATA/dummy_glm_analysis ]; then
    mkdir -p $COMMON_DATA/dummy_glm_analysis
fi

# (1.1) Build the .fsgd table:
dummy_fsgd_file=$COMMON_DATA/dummy_glm_analysis/dbs.fsgd
dummy_mtx_file=$COMMON_DATA/dummy_glm_analysis/slope.mtx

glmdir_base=$COMMON_DATA/dummy_glm_analysis/glmdir.sm15

echo "GroupDescriptorFile 1" > $dummy_fsgd_file
echo "Class Class1" >> $dummy_fsgd_file
echo "Variable Zage" >> $dummy_fsgd_file
awk '{if(NR>1)print "INPUT",$1,"Class1",$4}' $QDEC_DATA_DIR/ALL.sorted.qdec.table.dat >> $dummy_fsgd_file

echo "0 1" > $dummy_mtx_file

fwhm_sm15_lh=$CONCAT_DATA_DIR/ALL.lh.${measure}.fsaverage.sm15.mgh
fwhm_sm15_rh=$CONCAT_DATA_DIR/ALL.rh.${measure}.fsaverage.sm15.mgh

nr_submitted=0

if [ ! -e ${glmdir_base}.lh.${measure} ]; then
    mri_glmfit \
    --y ${fwhm_sm15_lh} --surface fsaverage lh \
    --glmdir ${glmdir_base}.lh.${measure} --fsgd ${dummy_fsgd_file} --C ${dummy_mtx_file}

    nr_submitted=$((nr_submitted+1))
fi

if [ ! -e ${glmdir_base}.rh.${measure} ]; then
    mri_glmfit \
    --y ${fwhm_sm15_rh} --surface fsaverage rh \
    --glmdir ${glmdir_base}.rh.${measure} --fsgd ${dummy_fsgd_file} --C ${dummy_mtx_file}
    nr_submitted=$((nr_submitted+1))
fi

# (1.3) Put together folders with results
for hemi in "lh" "rh"
do
    sig_path=$(ls $data_to_correct/p_maps/*${hemi}.${measure}*C.mgh)
    sig=$(basename $sig_path C.mgh)
    dir_base=$(basename $glmdir_base)
    dir_name=${dir_base}.$hemi.${measure}
    echo $dir_name
    if [ -d $data_to_correct/p_maps/$dir_name ]; then
        rm -rf $data_to_correct/p_maps/$dir_name
    fi
    cp -r ${glmdir_base}.$hemi.${measure} $data_to_correct/p_maps/$dir_name
    cp $sig_path $data_to_correct/p_maps/$dir_name/slope/sig.mgh
done

# Only care about negative p-values when correcting 
# 06_model06_bl-agexint.
analysis=$(basename $data_to_correct)
if [ $analysis == "06_model06_bl-agexint" ]; then
    sign="neg"
else
    sign="abs"
fi

# (1.4) Run the cluster-wise analysis
for glmdir in $(ls -d $data_to_correct/p_maps/glmdir*${measure}*)
do
    for p_val in "1.3" "2.0" "3.0" "4.0"
    do
        mri_glmfit-sim \
        --glmdir ${glmdir} \
        --cache ${p_val} ${sign} \
        --cwp  0.05 \
        --2spaces

        # Create link into the p_maps directory
        hemi=$(echo $(basename $glmdir) | awk -F"." '{print $3}')
        measure=$(echo $(basename $glmdir) | awk -F"." '{print $4}')
        ln -sf ${glmdir}/slope/cache.th${p_val/./}.${sign}.sig.masked.mgh \
             $data_to_correct/p_maps/sig.${hemi}.th${p_val/./}.${sign}.sig.masked.${measure}_C.mgh
    done
done