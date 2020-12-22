#!/usr/bin/env python
# coding: utf-8

# Written by: Inge Amlien
# Edited by Fredrik Magnussen

import pandas as pd
from pathlib import Path
import json
import os

def getdata(df):
    '''Function to get data from update df (40K imaging participants). 
    Also added episodic memory score field, pairs matching'''

    getcols = df['colid'].to_list()
    getcols.append('eid')
    
    chunks = pd.read_csv(
        ukbdata,
        chunksize=100000,
        low_memory=False,
        usecols=getcols
    )

    dfn = pd.DataFrame()
    dfn = pd.concat(chunk for chunk in chunks)
    
    renamelist = df[['colid', 'colname_ed']].to_dict(orient='split')['data']
    dfn.rename(columns=dict(renamelist), inplace=True)
    return dfn


ukbdata = '/tsd/p23/data/durable/external_datasets/UKBiobank/data/40810/ukb40810.csv'
datapath = os.environ['TABULAR_DATA_DIR']

print(datapath)
if not os.path.exists(datapath):
    os.makedirs(datapath)

colnames_df = pd.read_csv('colnames.csv')
colnames_df[['id', 'tp', 'nnn']] = colnames_df['colid'].str.split('_', expand=True)
colnames_df['colid'] = colnames_df['id'] + '-' + colnames_df['tp'] + '.' + colnames_df['nnn']
colnames_df.drop('nnn', axis=1, inplace=True)

# Edit colname
colnames_df['colname_ed'] = colnames_df[['colid','colname']].apply(lambda x: x.colname.lower().replace(" ","_")+"_"+x.colid,axis=1)

# cast to int
colnames_df[['id', 'tp']] = colnames_df[['id', 'tp']].astype(int)

# T2 used_ id = 26500
# demog: sex, birthmonth, birthyear, mridate, Education scores (England, Wales, Scotland)
demog_df_cols = colnames_df[colnames_df['colid'].isin(
    ['31-0.0', 
     '34-0.0', 
     '52-0.0', 
     '53-2.0', 
     '53-3.0',
     '6138-0.0',
     '25822-3.0'
    ])]

#demog_df['colid'].to_list()

df_demog = getdata(demog_df_cols)
print(df_demog.columns)
print("Rows:",len(df_demog))

df_demog.dropna(inplace=True)
print("After dropping rows:",len(df_demog))
df_demog.head()

# Fix dateformats
df_demog['birthyear'] = df_demog['year_of_birth_34-0.0'].astype(int)
df_demog['birthmonth'] = df_demog['month_of_birth_52-0.0'].astype(int)
df_demog['birthdayofmonth'] = 1
df_demog['birthdate'] = df_demog[['birthyear', 'birthmonth', 'birthdayofmonth']].astype(str).apply(lambda x: '-'.join(x), axis=1)

# Calc age at examination (2_0 for subjects with MR, 0_0 for subjects without)
df_demog['mrsubject_2-0'] = df_demog['date_of_attending_assessment_centre_53-2.0'].notna()
df_demog['examdate_2-0'] = df_demog['date_of_attending_assessment_centre_53-2.0']

df_demog['mrsubject_3-0'] = df_demog['date_of_attending_assessment_centre_53-3.0'].notna()
df_demog['examdate_3-0'] = df_demog['date_of_attending_assessment_centre_53-3.0']

df_demog['examdate_2-0'] = pd.to_datetime(df_demog['examdate_2-0']).dt.date
df_demog['birthdate'] = pd.to_datetime(df_demog['birthdate']).dt.date
df_demog['age-2.0'] =  (df_demog['examdate_2-0'] - df_demog['birthdate'])
df_demog['age-2.0'] = round(df_demog['age-2.0'].dt.days / 364, 2)

df_demog['examdate_3-0'] = pd.to_datetime(df_demog['examdate_3-0']).dt.date
df_demog['birthdate'] = pd.to_datetime(df_demog['birthdate']).dt.date
df_demog['age-3.0'] =  (df_demog['examdate_3-0'] - df_demog['birthdate'])
df_demog['age-3.0'] = round(df_demog['age-3.0'].dt.days / 364, 2)

df_demog.rename(columns={'sex_31-0.0': 'sex'}, inplace=True)

print(df_demog.columns)
df_demog.head()

# Create timepoint data in rows
data_dict = df_demog.to_dict()
rows_list = []
for _, row in df_demog[['eid','sex','age-2.0','age-3.0','qualifications_6138-0.0']].iterrows():
    eid = str(int(row['eid']))
    sex = row['sex']
    baseline_age = round(row['age-2.0'],2)
    
    years_0 = 0
    years_1 = round(row['age-3.0'] - baseline_age,2)
    
    # education, pick the best answer
    edu = int(row['qualifications_6138-0.0'])
    
    row_0 = {
        'eid' : eid,
        'mr_timepoint' : 1,
        'int' : years_0,
        'bl_age' : baseline_age,
        'sex' : sex,
        'education' : edu
        
    }
    row_1 = {
        'eid' : eid,
        'mr_timepoint' : 2,
        'int' : years_1,
        'bl_age' : baseline_age,
        'sex' : sex,
        'education' : edu
    }
    # Drop ids if they did not respond on education 
    if edu > 0:
        rows_list.append(row_0)
        rows_list.append(row_1)


df = pd.DataFrame(rows_list)
print(df)

# Save data
df.to_csv(Path(datapath, 'data.csv'), index=False)

print(str(len(df)) + ' lines written to ' + datapath + '/')

# Description of data
print("n =",len(df[df['mr_timepoint']==1]),"("+str(len(df[(df['mr_timepoint']==1) & (df['sex']==0) ] ))+" females)")

bl_age_mean = df[df['mr_timepoint']==1]['bl_age'].mean()
bl_age_std = df[df['mr_timepoint']==1]['bl_age'].std()
int_year_mean = df[df['mr_timepoint']==2]['int'].mean()
int_year_std = df[df['mr_timepoint']==2]['int'].std()

print("Mean age (at first timepoint) = %3.1f (std = %2.1f)" % (bl_age_mean,bl_age_std))
print("Mean interval between 1st and 2nd interval = %3.1f (std = %2.1f)" % (int_year_mean,int_year_std))
