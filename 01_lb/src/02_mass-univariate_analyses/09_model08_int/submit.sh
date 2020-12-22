#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=24:00:00
#SBATCH --job-name=lme_education
#SBATCH --account=p274
#SBATCH --mem-per-cpu=8G
#SBATCH --output logs/slurm-%j.txt
# NOTE: SUBJECTS_DIR must be set to a location where 'fsaverage' is before running this script
#
# Source freesurfer
module purge

module load R/3.5.0

# Get config data
source ../../../config

measure=$1

script_dir=$PWD

mv logs/slurm-${SLURM_JOBID}.txt logs/slurm.analysis.lme_education-${SLURM_JOBID}.log

tmp_file=tmp_submit_$measure.m

export output_dir=$OUTPUT_DIR/02_mass-univariate_analyses/09_model08_int

# Create R model
Rscript create_model.R

if [ ! -e ${tmp_file} ]; then
    echo $measure $factor $description
    echo "cd ${script_dir};" > $tmp_file
    echo "addpath('$output_dir');" >> $tmp_file
    echo "addpath('$QDEC_DATA_DIR');" >> $tmp_file
    echo "addpath('$CONCAT_DATA_DIR');" >> $tmp_file
    echo "addpath('$COMMON_DATA_FUNCTIONS/matlab_functions');" >> $tmp_file
    echo "run_LME('$measure', 15, 16,'$output_dir');" >> $tmp_file

    module load matlab/R2017a

    matlab -nodisplay -nodesktop -nosplash < $tmp_file

    rm $tmp_file

    # clusterwise correction for multiple Comparisons
    cd $COMMON_FUNCTIONS
    bash multiple_comparison_correction.sh $measure $output_dir
else
    echo "Analysis already running for $measure $factor, exiting.."
    exit 1
fi
