#!/usr/bin/env bash
# Purpose: Sort the qdec tables, and extract the ni.mats

source ../../../config

module load matlab/R2017a

QDEC_DIR="../../../data/07_ukb_lb_merged/01_qdec_tables"

for qdec_table in $QDEC_DIR/{??,???,????}.qdec.table.dat
do
    if [ -e qdec.table.dat ]; then
        rm qdec.table.dat
    fi
    base=$(basename $qdec_table)
    dataset=$(echo $base | awk -F"." '{print $1}')

    ln -s $qdec_table qdec.table.dat
    echo -n "> Sorting longitudinal QDEC table: $qdec_table "
    matlab -nodisplay -nosplash -nodesktop -r "try, run('sort.m'), catch, exit(1), end, exit(0);" > /dev/null

    if [[ $? != 0 ]]; then
        echo "ERROR: something went wrong in the sort.m script."
    else
        mv sorted.qdec.table.dat $QDEC_DIR/$dataset.sorted.qdec.table.dat
        mv ni.mat $QDEC_DIR/$dataset.ni.mat
        rm qdec.table.dat
        echo "DONE."
        echo "> sorted.qdec.table.dat and ni.mat files have been created"
    fi
done

# Remove columns that the UKB sorted.qdec.dat does not have.
# Rename columns to match UKB
for sorted_qdec_table in $QDEC_DIR/*.sorted.qdec.table.dat
do
    awk '{print $1,$2,$3,$4,$6,$7,$8}' $sorted_qdec_table | sed 's/base_age/baseline_age/g; s/sex_coded/sex/g' > tmp
    mv tmp $sorted_qdec_table
done

# Add a scanner column in UKB data
awk '{if(NR>1){print $0,"ukbSkyra"}else{print $0,"scanner"}}' \
    ../../../data/06_ukb_long_data/01_qdec_table/sorted.qdec.table.dat > $QDEC_DIR/ukb_long.sorted.qdec.table.dat

cp ../../../data/06_ukb_long_data/01_qdec_table/ni.mat $QDEC_DIR/ukb_long.ni.mat