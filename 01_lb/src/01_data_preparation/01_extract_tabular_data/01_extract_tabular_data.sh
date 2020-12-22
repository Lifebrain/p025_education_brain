#!/usr/bin/env bash
# Purpose: Extract raw tabular data from the different sites

source ../../../config

mkdir -p $RAW_TABULAR_DATA_DIR

# UB data
cp $SITE_DATA_DIR/UB/tabular/current/UB_datatable_DEMO.xlsx $RAW_TABULAR_DATA_DIR/.
cp $SITE_DATA_DIR/UB/tabular/current/UB_subject_table.xlsx $RAW_TABULAR_DATA_DIR/.

# MPIB
cp $SITE_DATA_DIR/MPIB/tabular/MPIB_Base2_subjects.xlsx $RAW_TABULAR_DATA_DIR/.

# UmU
cp "$SITE_DATA_DIR/UmU/tabular/datatables-2019-02-07/LB_data_tables_setup_V6_Education_1_2019-01-25 - KLAR.xlsx" \
$RAW_TABULAR_DATA_DIR/UMU_V6_Eduation_1_2019-01-25.xlsx

cp "$SITE_DATA_DIR/UmU/tabular/datatables-2019-02-07/LB_data_tables_setup_V6_ID_Subject_2018-12-07 - KLAR_v3.xlsx" \
    $RAW_TABULAR_DATA_DIR/UMU_V6_ID_Subject_2018-12-07.xlsx

cp "$SITE_DATA_DIR//UmU/tabular/datatables-2019-02-07/LB_data_tables_setup_V6_Education_2_2019-02-07 - KLAR.xlsx" \
$RAW_TABULAR_DATA_DIR/UMU_V6_Eduation_2_2019-02-07.xlsx

# Uio data extracted from NOAS
cp /tsd/p23sharedp274/data/durable/noas_query_2020-06-09_16.37_79e3887.csv $RAW_TABULAR_DATA_DIR/UIO_noas_query_2020-06-09_16.37_79e3887.csv

# UCAM data was exported by Ethan and copied over to 01_tabular_data at 14.09.20
# The edu field was separated with commas, I edited this to semicolon, and saved to file:
# UCAM_change_delim_edu.csv

# Data was converted to .csv files by hand. 
# Then, all files where write protected with the commands:
chmod 440 $RAW_TABULAR_DATA_DIR/*.xlsx
chmod 440 $RAW_TABULAR_DATA_DIR/*.csv