#!/bin/usr/env R
## ---------------------------
##
## Notes: Creating following model:
##   brain = edu + int + sex  + bl_age + bl_age^2 + icv,
##
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"sorted.qdec.table.dat",sep="/")
aseg_table = paste(Sys.getenv("ASEG_DATA_DIR"),"aseg.long.table",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)
df_aseg <- read.table(aseg_table,header=TRUE)

# Scale the variables
df$edu = df$edu_coded
df$bl_age_z = scale(df$bl_age)
df$int_z = scale(df$int)
df$icv_z = scale(df_aseg$EstimatedTotalIntraCranialVol)

X <- model.matrix(~ edu + 
                    int_z + 
                    sex + 
                    bl_age_z + 
                    I(bl_age_z^2) +
                    icv_z, df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)