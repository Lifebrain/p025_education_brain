#!/usr/bin/env bash
# Purpose: (1) Create qdec tables for each site, (2) sort them, (3) merge them.

source ../../../config
mkdir -p $QDEC_DATA_DIR

# Create qdec tables
python 03_create_qdec_tables.py

# Sort them
for site in "UIO" "MPIB" "UB" "UMU" "UCAM"
do
    bash sortQdecTable.sh $site
done

# Merge datasets
awk '{if(FNR>1 || NR==1) print $0}' $QDEC_DATA_DIR/*.sorted.qdec.table.dat > $QDEC_DATA_DIR/ALL.sorted.qdec.table.dat

matlab -nodisplay -nosplash -nodesktop -r "try, run('merge_ni_files.m'), catch, exit(1), end, exit(0);" > /dev/null
