#!/usr/bin/env bash
# Purpose: Change the headers of the .csv files, so they are uniform

source ../../../config

mkdir -p $EDITED_TABULAR_DATA_DIR

# MPIB
# Use behav age
MPIB_csv=$RAW_TABULAR_DATA_DIR/MPIB_Base2_subjects.csv
awk -F"," 'BEGIN{OFS=","}{print $1,$2,$3,$8,$5,$10,$7}' $MPIB_csv | \
    sed 's/edu/years_education/g; s/age.beha/mri_age/g' > $EDITED_TABULAR_DATA_DIR/$(basename ${MPIB_csv/Base2_subjects.csv/education})_$(date +%F).csv

# UB
UB_output_file=$EDITED_TABULAR_DATA_DIR/UB_education_$(date +%F).csv

# UB CR
UB_CR_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_CR.csv
UB_CR_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_CR.csv

# Merge sex into demo data
awk -F"," 'BEGIN{OFS=","}NR==FNR{a[$3]=$8;next}$3 in a{print $1,$2,$3,$4,a[$3],$6,$10}' $UB_CR_subject $UB_CR_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' > $UB_output_file

# UB GABA
UB_GABA_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_GABA.csv
UB_GABA_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_GABA.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$8,$12}' $UB_GABA_subject $UB_GABA_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' >> $UB_output_file

# UB iTBS
UB_iTBS_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_iTBS.csv
UB_iTBS_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_iTBS.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$7,$10}' $UB_iTBS_subject $UB_iTBS_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' >> $UB_output_file

# UB iTBS
UB_iTBS_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_iTBS.csv
UB_iTBS_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_iTBS.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$7,$10}' $UB_iTBS_subject $UB_iTBS_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' >> $UB_output_file

# UB MSA
UB_MSA_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_MSA.csv
UB_MSA_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_MSA.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$8,$12}' $UB_MSA_subject $UB_MSA_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' >> $UB_output_file

# UB PD
UB_PD_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_PD.csv
UB_PD_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_PD.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$8,$13}' $UB_PD_subject $UB_PD_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_MRI/mri_age/g; s/Sex/sex/g' >> $UB_output_file

# UB WAHA
# Use calculated_age_cogn instead of mri_age, due to missing values for MRI age..
UB_WAHA_demo_csv=$RAW_TABULAR_DATA_DIR/UB_datatable_DEMO_WAHA.csv
UB_WAHA_subject=$RAW_TABULAR_DATA_DIR/UB_subject_table_WAHA.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{if(NR>1){a[$3]=$8};next}$3 in a{print $1,$2,$3,$4,a[$3],$6,$14}' $UB_WAHA_subject $UB_WAHA_demo_csv | \
    sed 's/Round_ id/Round_id/g; s/calculated_age_cogn/mri_age/g; s/Sex/sex/g' >> $UB_output_file


# UMU
UMU_output_file=$EDITED_TABULAR_DATA_DIR/UMU_education_$(date +%F).csv

UMU_tabular_file=$RAW_TABULAR_DATA_DIR/UMU_V6_Eduation_1_2019-01-25.csv
UMU_subject_file=$RAW_TABULAR_DATA_DIR/UMU_V6_ID_Subject_2018-12-07.csv

awk -F"," 'BEGIN{OFS=","}NR==FNR{a[$3]=$9;next}$3 in a{print $1,$2,$3,$5,a[$3],$7,$14}' $UMU_subject_file $UMU_tabular_file | \
    sed 's/SubjectRound_ id/Round_id/g; s/Age/mri_age/g; s/educ_T/years_education/g; s/Sex/sex/g' > $UMU_output_file

# UIO
UIO_output_file=$EDITED_TABULAR_DATA_DIR/UIO_education_$(date +%F).csv

UIO_tabular_file=$RAW_TABULAR_DATA_DIR/UIO_noas_query_2020-06-09_16.37_79e3887.csv

echo "Site_id,Study_id,Subject_id,Round_id,sex,mri_age,years_education" > $UIO_output_file
awk -F";" 'BEGIN{OFS=","}{if(NR>1)print "UiO",$5,$1,substr($7,14),$3,$4,$9}' $UIO_tabular_file  | sed 's/\"//g' >> $UIO_output_file

# UCAM
UCAM_output_file=$EDITED_TABULAR_DATA_DIR/UCAM_education_$(date +%F).csv
UCAM_tabular_data=$RAW_TABULAR_DATA_DIR/UCAM_data_change_delim_edu.csv

awk -F"," 'BEGIN{OFS=","}{if(NR==1){print "Site_id","Study_id","Subject_id","Round_id","sex","mri_age","category_education","age_completed_education"} else{ print "UCAM","Cam-Can",$1,"1",$5,$3,$10,$11"\nUCAM","Cam-Can",$1,"2",$5,$4,$10,$11;}}' $UCAM_tabular_data > $UCAM_output_file