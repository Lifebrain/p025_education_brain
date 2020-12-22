#!/usr/bin/env bash
# Purpose: Run mri_surf2surf for one subject
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --job-name=surf2surf
#SBATCH --account=p23
#SBATCH --mem-per-cpu=8GB
#SBATCH --output logs/slurm-%j.txt

# Source freesurfer
export FREESURFER_HOME=/cluster/projects/p23/tools/mri/freesurfer/freesurfer.7.1.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh

long_dir_path=$1
long_dir=$(basename $long_dir_path)
qdec_nr=$2
hemi=$3
measure=$4
target=$5
output_dir=$6

mri_surf2surf \
    --srcsubject ${long_dir} \
    --srchemi ${hemi} \
    --srcsurfreg sphere.reg \
    --trgsubject fsaverage \
    --trghemi ${hemi} \
    --trgsurfreg sphere.reg \
    --tval ${output_dir}/${qdec_nr}.${long_dir}.mgh \
    --sval $long_dir_path/surf/${hemi}.${measure} \
    --sfmt curv \
    --noreshape \
    --cortex