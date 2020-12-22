#!/bin/usr/env R
## ---------------------------
## ---------------------------
##
## Notes: Creating following model:
##   brain = intervall + sex + scanner + baseline_alder + baseline_alder^2,
##   where scanner is a proxy for the study.
##
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"ALL.sorted.qdec.table.dat",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)

# Scale the variables
df$bl_age = scale(df$base_age)
df$int = scale(df$years)
df$sex = df$sex_coded

X <- model.matrix(~ int + 
                    scanner +
                    sex + 
                    bl_age + 
                    I(bl_age^2), df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)