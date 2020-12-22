#!/usr/bin/env python3
# Purpose: Make qdec tables from the edited .csv files

import os.path as op
import pandas as pd
import glob
import numpy as np
import os

EDITED_CSV_DIRECTORY = os.environ['EDITED_TABULAR_DATA_DIR']

OUTPUT_DIR = os.environ['QDEC_DATA_DIR'] 

MPIB_data = {
    'name' : "MPIB",
    'tabular_data' : op.join(
        EDITED_CSV_DIRECTORY,
        "MPIB_education_2020-09-10.csv"),
    'fs_directory' : os.environ['MPIB_SUBJECT_DIR']
}

UB_data = {
    'name' : "UB",
    'tabular_data' : op.join(
        EDITED_CSV_DIRECTORY,
        "UB_education_2020-09-10.csv"
        ),
    'fs_directory' : os.environ['UB_SUBJECT_DIR']
}

UIO_data = {
    'name' : "UIO",
    'tabular_data' : op.join(
        EDITED_CSV_DIRECTORY,
        "UIO_education_2020-09-10.csv"),
    'fs_directory' : os.environ['UIO_SUBJECT_DIR']
}

UMU_data = {
    'name' : "UMU",
    'tabular_data' : op.join(
        EDITED_CSV_DIRECTORY,
        "UMU_education_2020-09-10.csv"
    ),
    'fs_directory' : os.environ['UMU_SUBJECT_DIR']
}

UCAM_data = {
    'name' : "UCAM",
    'tabular_data' : op.join(
        EDITED_CSV_DIRECTORY,
        "UCAM_education_2020-09-15.csv"
    ),
    'fs_directory' : os.environ['UCAM_SUBJECT_DIR']
}

def extract_fs_long_dir(fs_directory,Subject_id,Session_id):
    """Extract fs long dir using fs_directory, subject_id and session_id"""
    search = glob.glob(op.join(fs_directory,"*"+str(Subject_id)+"*"+str(Session_id)+"*.long.*"))
    try:
        fs_long_dir = op.basename(search[0])

        # Check if long processing has exited with error
        if op.exists(op.join(fs_directory,fs_long_dir,"scripts","recon-all.error")):
            fs_long_dir = np.NaN
    except:
        fs_long_dir = np.NaN

    return fs_long_dir

# Table for converting CamCAN education categories to years
CamCan2eduyrs = {
    1: 16,
    2: 13,
    3: 11,
    4: 11,
    5: 13,
    6: 16,
    0: 7,
    8: np.NaN
}

def convert_edu_categories_to_years(categories,age_finished_education):
    """ 
    Converts education categories to years based ob the dictionary
    'CamCan2eduyrs'.

    inputs:
        categories: list of categories separated with semicolon
        age_finished_education: age finished full-time education.
    outputs:
        edu: Education in years
    """

    # Take the lowest value out of the categories given
    categories_array = np.array(categories.split(";"),dtype=float)
    category = int(min(categories_array))

    edu_years_category = CamCan2eduyrs[category]
    if age_finished_education < 40:
        edu_years_age = age_finished_education - 5
    else:
        edu_years_age = np.nan
    
    #print(edu_years_category,edu_years_age)

    if edu_years_category > edu_years_age:
        return edu_years_category
    else:
        return edu_years_age

def convert_to_float(x):
    try:
        return float(x)
    except:
        return np.nan

# Create qdec tables
for data in [UCAM_data, MPIB_data, UIO_data, UMU_data, UB_data]:

    tabular_data = data['tabular_data']
    fs_directory = data['fs_directory']

    print(fs_directory)
    df = pd.read_csv(tabular_data)
    print(df.head(10))

    # Find fs id and base id
    if data['name'] == "UMU":
        df['Session_id'] = df['Round_id'].apply(lambda x: x-4 if x>4 else x)
    elif data['name'] == "UIO":
        df['Session_id'] = df['Round_id'].apply(lambda x: x[4:])
    elif data['name'] == "UCAM":
        df['Session_id'] = df['Round_id'].apply(lambda x: int(x))
    else:
        df['Session_id'] = df['Round_id'].apply(lambda x: int(''.join(filter(str.isdigit, x))))

    # Sort dataset so that we do not get negative years
    if data['name'] == "UIO":
        df = df.sort_values(['Subject_id','mri_age'])

    df['fs_long_dir'] = df[['Subject_id','Session_id']].apply(
        lambda x: extract_fs_long_dir(fs_directory,x.Subject_id,x.Session_id),axis=1)

    # Drop datasets which do not have freesurfer data
    df = df.dropna(subset=['fs_long_dir'])

    df['fsid'] = df['fs_long_dir'].apply(lambda x: str(x).split(".long.")[0])
    df['fsid_base'] = df['fs_long_dir'].apply(lambda x: str(x).split(".long.")[1])
    
    df['int'] = df[['Subject_id','mri_age']].apply(
        lambda x: x.mri_age - df['mri_age'][df['Subject_id']==x.Subject_id].iloc[0], axis=1).map('{:,.2f}'.format)
    
    df['bl_age'] = df['Subject_id'].apply(lambda x: df['mri_age'][df['Subject_id']==x].iloc[0])

    # For UB, they have coded female as 1, and male as 0.
    df['sex'] = df['sex'].apply(lambda x: 1 if str(x).lower() == "female" or x == 1 else 0)

    if data['name'] == "UCAM":
        df['scanner'] = df['fsid_base'].apply(lambda x: "ucamTrioTrim")
    else:
        df['scanner'] = df['fsid_base'].apply(lambda x: str(x).split("_")[2])
        
    # Take away potential participants that are still under education.
    df = df[df['bl_age']>29]

    if data['name'] == "UIO":
        df['edu'] = df[['years_education','Subject_id']].apply(
            lambda x: \
                df['years_education'][df['Subject_id'] == x.Subject_id].mean() \
                if df['years_education'][df['Subject_id']==x.Subject_id].mean() <= 20 \
                else 20, axis=1).map('{:,.2f}'.format)

    elif data['name'] == "UB":
        df['edu'] = df['Subject_id'].apply(
            # Should only have 1 value per subject, if more, take the mean.
            # Remove the -9999 values
            lambda x: df['years_education'][df['Subject_id']==x].mean() \
            if df['years_education'][df['Subject_id']==x].iloc[-1] != -9999 \
            else df['years_education'][df['Subject_id']==x].iloc[0]
        ).map('{:,.2f}'.format)
        
    elif data['name'] == "UCAM":
        df['edu'] = df[['category_education','age_completed_education']]\
            .apply(
                lambda x: convert_edu_categories_to_years(
                    x.category_education,
                    x.age_completed_education
                ),
                axis=1
            )
    
    else:
        df['edu'] = df['years_education']

    # At least one year between first and last scan
    df['diff_years_last_first_scan'] = df['Subject_id'].apply(
        lambda x: \
            float(df['int'][df['Subject_id']==x].iloc[-1]) - \
            float(df['int'][df['Subject_id']==x].iloc[0])
    )

    df_final = df[['fsid','fsid_base','int','bl_age','edu','sex','scanner']][\
        df['diff_years_last_first_scan']>=1].dropna()

    df_final['edu'] = df_final['edu'].apply(
        lambda x: convert_to_float(x)
    )

    df_final = df_final[df_final['edu']>0].drop_duplicates()

    df_final.sort_values(by=['fsid','int']).to_csv(
        op.join(
            OUTPUT_DIR,
            data['name']+".qdec.table.dat"
        ),
        index=False,
        sep=" "
    )
