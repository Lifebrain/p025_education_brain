#!/bin/bash

module purge

module load R/3.6.3-foss-2020a

source /cluster/projects/p274/tools/other/env/r_aliases

Rscript Bayesian_null_testing.R
Rscript render.R