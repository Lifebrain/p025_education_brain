#!/usr/bin/env bash
# Purpose: Run mri_concat for all subjects
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --job-name=concat
#SBATCH --account=p23
#SBATCH --mem-per-cpu=8GB
#SBATCH --output logs/slurm-%j.txt

# Source freesurfer
export FREESURFER_HOME=/cluster/projects/p23/tools/mri/freesurfer/freesurfer.7.1.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh

hemi=$1
measure=$2
target=$3
input_dir=$4
output_dir=$5

mri_concat $input_dir/*.mgh --o $output_dir/${hemi}.${measure}.${target}.sm00.mgh

if [ $? == 0 ]; then
    echo "Data cleaning"
    rm -rf $input_dir
fi