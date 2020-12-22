#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=24:00:00
#SBATCH --job-name=lme_education
#SBATCH --account=p23
#SBATCH --mem-per-cpu=8G
#SBATCH --output logs/slurm-%j.txt

module purge

module load R/3.5.0
module load matlab/R2017a

# Get config data
source ../../../config

measure=$1

script_dir=$PWD

tmp_file=tmp_submit_$measure.m

export output_dir=$OUTPUT_DIR/02_mass-univariate_analyses/05_model05_bl-agexint

if [ ! -e $output_dir ]; then
    mkdir -p $output_dir
    mkdir $output_dir/covariance_maps
    mkdir $output_dir/p_maps
    mkdir $output_dir/logs
fi

mv logs/slurm-${SLURM_JOBID}.txt $output_dir/logs/slurm.analysis.lme_education-${SLURM_JOBID}.log


# Create R model
Rscript create_model.R

if [ ! -e ${tmp_file} ]; then
    echo $measure $factor $description
    echo "cd ${script_dir};" > $tmp_file
    echo "run('$HOME/matlab/startup.m')" >> $tmp_file
    echo "addpath('$output_dir');" >> $tmp_file
    echo "addpath('$QDEC_DATA_DIR');" >> $tmp_file
    echo "addpath('$CONCAT_DATA_DIR');" >> $tmp_file
    echo "addpath('$COMMON_FUNCTIONS/matlab_functions');" >> $tmp_file
    echo "run_LME('$measure', 15, 16,'$output_dir');" >> $tmp_file

    # Change home directory to not mix parallell job information 
    # when multiple pools starts at the same time.
    export HOME=$output_dir

    matlab -nodisplay -nodesktop -nosplash < $tmp_file

    rm $tmp_file

    # clusterwise correction for multiple Comparisons
    cd $COMMON_FUNCTIONS
    bash multiple_comparison_correction.sh $measure $output_dir
else
    echo "Analysis already running for $measure $factor, exiting.."
    exit 1
fi
