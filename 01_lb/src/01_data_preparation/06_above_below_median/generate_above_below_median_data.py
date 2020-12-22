#!/usr/bin/env python
# coding: utf-8

import os
import numpy as np
import pandas as pd

data = os.path.join(os.environ['QDEC_DATA_DIR'],'ALL.sorted.qdec.table.dat')
aseg_data = os.path.join(os.environ['ASEG_DATA_DIR'],'ALL.aseg.long.table')

output_data = os.path.join(os.environ['ABOVE_BELOW_MEDIAN_DIR'],'above_below_median_hippocampus_icv.txt')
output_median = os.path.join(os.environ['ABOVE_BELOW_MEDIAN_DIR'],'age_group_median.txt')

df = pd.read_csv(data,sep=" ")
df_aseg = pd.read_csv(aseg_data,sep="\t")

df['hippocampus_mean'] = (df_aseg['Left-Hippocampus'] + df_aseg['Right-Hippocampus'])/2

df['age'] = df['bl_age'] + df['int']
df['id'] = df['fsid_base'].apply(lambda x: x.split("_")[0]).replace("sub-","")

print(df.head())
print(df_aseg.head())

df['icv'] = df_aseg['EstimatedTotalIntraCranialVol']

# Calculate above and below median
age_int = 10
range_start = 25
range_end = 120

median = df[df['int']==0].groupby(pd.cut(df[df['int']==0]['age'],np.arange(range_start,range_end,age_int)))['edu'].median().reset_index()
median = median.rename(columns={"edu": "median_education"})

interval_array = pd.arrays.IntervalArray(median['age'])

# Create data for median_plot
number_range = np.arange(range_start+age_int/2,range_end-age_int/2,age_int)[:]
median['age_group'] = number_range
df['age_group'] = df['age'].apply(lambda x: number_range[interval_array.contains(x)][0])

df['below_median'] = df[['age','edu']].apply(lambda x: 1 if median[interval_array.contains(x.age)]['median_education'].iloc[0] >= x.edu else 0,axis=1)
df['above_median'] = df[['age','edu']].apply(lambda x: 1 if median[interval_array.contains(x.age)]['median_education'].iloc[0] < x.edu else 0,axis=1)

df[['id','bl_age','int','age','edu','sex','hippocampus_mean','above_median','scanner','icv','age_group']].to_csv(output_data,sep=" ",index=False)
median.to_csv(output_median,sep=" ",index=False)