#!/bin/bash
###########
source ../../../config

export SUBJECTS_DIR=$FS_DATA_DIR

if [ ! -d $CONCAT_DATA_DIR ]; then
    mkdir -p $CONCAT_DATA_DIR
fi

if [[ ! -f $QDEC_DATA_DIR/sorted.qdec.table.dat ]]; then
    echo "ERROR: sorted.qdec.table.dat file does not exist in the current working directory."
    exit 255
fi

##########################################################
get_options() {
    #################################
    # properly handle input arguments
    #################################
    if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then 
        echo "ERROR: wrong number of input arguments."
        echo "USAGE: "
        echo "\$1 : <measure> (thickness, area, curv, vol,...)"
        echo "\$2 : <FWHM>"
        echo "\$3 : [target subject] (default is fsaverage)"
        exit 255
    elif [[ $# -eq 2 ]]; then
        measure=$1
        fwhm=$2
        target=fsaverage # default
    else
        measure=$1
        fwhm=$2
        target=$3
    fi
}
###########################################################
main() {
    get_options "$@"
    echo $BASH_ENV
    # Report major script control variables to the user
    echo "------------------------------"
    echo "Control variables: "
    echo "Measure:        ${measure}"
    echo "FWHM:           ${fwhm}"
    echo "Target subject: ${target}"
    echo "------------------------------"
    
    # Gather measure data into a single .mgh file for each hemisphere separetely
    if [[ -f $CONCAT_DATA_DIR/lh.${measure}.${target}.sm${fwhm}.mgh ]] && [[ -f $CONCAT_DATA_DIR/rh.${measure}.${target}.sm${fwhm}.mgh ]]; then
        echo "Data for the control variables above is already prepared for further processing."
        exit 0
    fi
    for hemi in "lh" "rh"
    do
        if [[ ! -f $CONCAT_DATA_DIR/${hemi}.${measure}.${target}.sm00.mgh ]]; then
            echo " > Preparing surface-based data of ${measure} onto ${target} for ${hemi}... "; sleep 3
            
            output_dir=$CONCAT_DATA_DIR/tmp.${hemi}.${measure}.${target}
            if [ ! -e $output_dir ]; then
                mkdir -p $output_dir
            fi

            i=1
            job_ids=""
            for long_dir in $(awk '{if(NR>1)print $1".long."$2}' $QDEC_DATA_DIR/sorted.qdec.table.dat)
            do
                # Add leading zeros to number
                qdec_nr=$(printf "%05d" $i)

                jobs_submitted=$(squeue -u $USER | wc -l)
                while [ $jobs_submitted -gt 3000 ]
                do
                    jobs_submitted=$(squeue -u $USER -n surf2surf | wc -l)
                    echo "Too many jobs submitted, over $jobs_submitted, sleeping..."
                    sleep 30s
                done

                if [ ! -e $output_dir/$qdec_nr.$long_dir.mgh ]; then
                    job_id=$(sbatch --parsable surf2surf.sh $SUBJECTS_DIR/$long_dir $qdec_nr ${hemi} $measure $target $output_dir)
                    echo "Submitted batch job $job_id"
                    if [ "X${job_ids}" == "X" ]; then
                        job_ids="$job_id"
                    else
                        job_ids="$job_ids,$job_id"
                    fi
                fi
                i=$((i+1))
            done

            if [ "X$job_ids" != "X" ]; then
                dependency="--dependency=afterok:$job_ids"
            fi
            #echo $dependency 
            echo " > Concatenating ${measure} maps for hemisphere ${hemi} (dependency)"; sleep 3
            concat_job_id=$(sbatch --parsable $dependency concat.sh ${hemi} ${measure} ${target} ${output_dir} ${CONCAT_DATA_DIR})
            echo "Submitted batch job $concat_job_id"

            # Smooth the cortical ${measurement} maps with ${fwhm}
            if [[ ! -f $CONCAT_DATA_DIR/${hemi}.${measure}.${target}.sm${fwhm}.mgh ]]; then
                echo " > Smoothing ${measure} maps with FWHM=${fwhm} for hemisphere ${hemi}"; sleep 3
                sbatch --dependency=afterok:$concat_job_id smooth.sh ${hemi} ${measure} ${target} ${fwhm} $CONCAT_DATA_DIR
            fi
 
        else
            echo " > ${hemi}.${measure}.${target}.sm00.mgh already prepared."
            if [[ ! -f $CONCAT_DATA_DIR/${hemi}.${measure}.${target}.sm${fwhm}.mgh ]]; then
                echo " > Smoothing ${measure} maps with FWHM=${fwhm} for hemisphere ${hemi}"
                sbatch smooth.sh ${hemi} ${measure} ${target} ${fwhm} $CONCAT_DATA_DIR
            fi
        fi
    done
}
##########################################
# Invoke the main function to start things
##########################################
main "$@"
