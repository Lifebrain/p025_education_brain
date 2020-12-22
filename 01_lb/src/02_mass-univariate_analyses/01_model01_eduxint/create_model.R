#!/bin/usr/env R
## ---------------------------
##
## Notes: Creates the following model:
##   brain = edu + int + edu*int + sex + scanner + bl_age + bl_age^2,
##   where scanner is a proxy for the study.
##
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"ALL.sorted.qdec.table.dat",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)

# Scale the variables
df$edu_z = scale(df$edu)
df$bl_age_z = scale(df$bl_age)
df$int_z = scale(df$int)

X <- model.matrix(~ edu_z + 
                    int_z + 
                    edu_z * int_z + 
                    sex + 
                    scanner +
                    bl_age_z + 
                    I(bl_age_z^2), df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)