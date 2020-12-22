#!/bin/usr/env R
## ---------------------------
##
## Notes: Creating following model:
##   brain = int + bl_age + int*bl_age + sex + scanner + icv
##
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"ALL.sorted.qdec.table.dat",sep="/")
aseg_table = paste(Sys.getenv("ASEG_DATA_DIR"),"ALL.aseg.long.table",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)
df_aseg <- read.table(aseg_table,header=TRUE)

# Scale the variables
df$bl_age_z = scale(df$bl_age)
df$int_z = scale(df$int)
df$icv_z = scale(df_aseg$EstimatedTotalIntraCranialVol)

X <- model.matrix(~ int_z + 
                    bl_age_z + 
                    int_z*bl_age_z +
                    scanner +
                    sex +
                    icv_z, df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)