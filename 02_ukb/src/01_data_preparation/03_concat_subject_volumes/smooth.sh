#!/usr/bin/env bash
# Purpose: Run surf2surf to smooth the data
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --job-name=smooth
#SBATCH --account=p23
#SBATCH --mem-per-cpu=8GB
#SBATCH --output logs/slurm-%j.txt

# Source freesurfer
export FREESURFER_HOME=/cluster/projects/p23/tools/mri/freesurfer/freesurfer.7.1.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh

hemi=$1
measure=$2
target=$3
fwhm=$4
input_dir=$5

mri_surf2surf \
    --hemi ${hemi} \
    --s ${target} \
    --sval $input_dir/${hemi}.${measure}.${target}.sm00.mgh \
    --tval $input_dir/${hemi}.${measure}.${target}.sm${fwhm}.mgh \
    --fwhm ${fwhm} \
    --cortex \
    --noreshape
