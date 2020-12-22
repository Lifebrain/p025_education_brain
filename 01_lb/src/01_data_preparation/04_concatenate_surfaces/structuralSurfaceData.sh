#!/bin/bash
###########

##########################################################
get_options() {
    #################################
    # properly handle input arguments
    #################################
    if [[ $# -lt 3 ]] || [[ $# -gt 4 ]]; then 
        echo "ERROR: wrong number of input arguments."
        echo "USAGE: "
        echo "\$1 : <measure> (thickness, area, curv, vol,...)"
        echo "\$2 : <FWHM>"
        echo "\$3 : <dataset> (UMU, UIO, MPIB, UB)"
        echo "\$4 : [target subject] (default is fsaverage)"
        exit 255
    elif [[ $# -eq 3 ]]; then
        measure=$1
        fwhm=$2
        dataset=$3
        target=fsaverage # default
    else
        measure=$1
        fwhm=$2
        dataset=$3
        target=$4
    fi
}
###########################################################
main() {
    get_options "$@"
    qdec_table=$QDEC_DATA_DIR/$dataset.sorted.qdec.table.dat
    if [[ ! -f $qdec_table ]]; then
        echo "ERROR: sorted.qdec.table.dat file does not exist in the current working directory."
        exit 255
    fi
    echo $BASH_ENV
    # Report major script control variables to the user
    echo "------------------------------"
    echo "Dataset:        ${dataset}"
    echo "Control variables: "
    echo "Measure:        ${measure}"
    echo "FWHM:           ${fwhm}"
    echo "Target subject: ${target}"
    echo "------------------------------"

    # Check if fsaverage is in subject_dir
    if [ ! -e $SUBJECTS_DIR/fsaverage ]; then
        ln -s $FREESURFER_HOME/subjects/fsaverage $SUBJECTS_DIR/.
    fi 
    # Gather measure data into a single .mgh file for each hemisphere separetely
    if [[ -f $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm${fwhm}.mgh ]] && [[ -f $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm${fwhm}.mgh ]]; then
        echo "Data for the control variables above is already prepared for further processing."
        exit 0
    elif [[ ! -f $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm0.mgh ]]; then
        echo " > Preparing surface-based data of ${measure} onto ${target} for lh... "; sleep 3
        mris_preproc --qdec-long $qdec_table --target ${target} --hemi lh --meas ${measure} --out $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm0.mgh
    fi
    if [[ ! -f $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm0.mgh ]]; then
        echo " > Preparing surface-based data of ${measure} onto ${target} for rh... "; sleep 3
        mris_preproc --qdec-long $qdec_table --target ${target} --hemi rh --meas ${measure} --out $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm0.mgh
    fi
    if [[ -e $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm0.mgh ]] && [[ -e $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm0.mgh ]]; then
        echo "?h.${measure}.${target}.sm0.mgh data is already prepared."
    fi
    # Smooth the cortical ${measurement} maps with ${fwhm}
    if [[ $? -eq 0 ]] && [[ ! -f $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm${fwhm}.mgh ]]; then
        echo -n " > Smoothing ${measure} maps with FWHM=${fwhm} for both hemispheres..."; sleep 3
        mri_surf2surf --hemi lh --s ${target} --sval $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm0.mgh --tval $CONCAT_DATA_DIR/$dataset.lh.${measure}.${target}.sm${fwhm}.mgh --fwhm ${fwhm} --cortex --noreshape
    fi
    
    if [[ $? -eq 0 ]] && [[ ! -f $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm${fwhm}.mgh ]]; then
        mri_surf2surf --hemi rh --s ${target} --sval $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm0.mgh --tval $CONCAT_DATA_DIR/$dataset.rh.${measure}.${target}.sm${fwhm}.mgh --fwhm ${fwhm} --cortex --noreshape
    else
        echo "Something wrong went with the mris_preproc command. Check it."
    fi
}
##########################################
# Invoke the main function to start things
##########################################
main "$@"
