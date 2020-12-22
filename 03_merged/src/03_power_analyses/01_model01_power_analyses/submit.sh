#!/bin/bash

#SBATCH --cpus-per-task=3
#SBATCH --time=24:00:00
#SBATCH --job-name=power_education
#SBATCH --account=p274_lcbc
#SBATCH --mem-per-cpu=8G

module purge

# Get config data
source ../../../config

module load matlab/R2017a

matlab -nodisplay -nodesktop -nosplash < confidence_interval.m

