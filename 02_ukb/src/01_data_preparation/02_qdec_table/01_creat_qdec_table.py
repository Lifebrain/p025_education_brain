#!/usr/bin/env python3
# Purpose: Create qdec table

import pandas as pd
import numpy as np
import glob
import os.path as op
import os

data_csv = op.join(os.environ['TABULAR_DATA_DIR'],'data.csv')

output_file = op.join(os.environ['QDEC_DATA_DIR'],'qdec.table.dat')

fs_dir = "/cluster/projects/p23/data/open_datasets/ukb_long/bids/derivatives/freesurfer.7.1.0/recon"

df = pd.read_csv(data_csv)

def extract_fs_long_dir(id,timepoint):
    """ Extract fs long dir based on id and timepoint """

    search = glob.glob(op.join(fs_dir,"*"+str(id)+"*"+str(timepoint+1)+"*"+".long.*"))

    try:
        return op.basename(search[0])
    except:
        return np.nan


df['fs_long_dir'] = df[['eid','mr_timepoint']].apply(lambda x: extract_fs_long_dir(x.eid,x.mr_timepoint), axis=1)
df = df.dropna()

df['fsid'] = df['fs_long_dir'].apply(lambda x: x.split(".long.")[0])
df['fsid_base'] = df['fs_long_dir'].apply(lambda x: x.split(".long.")[1])
df['edu_coded'] = df['education'].apply(lambda x: 1 if x==1 else 0)
df['sex'] = df['sex'].apply(lambda x: int(x))

df[['fsid','fsid_base','int','bl_age','sex','edu_coded']].to_csv(output_file, sep=" ", index=False)