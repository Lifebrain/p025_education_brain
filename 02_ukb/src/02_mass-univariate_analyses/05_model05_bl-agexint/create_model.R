#!/bin/usr/env R
## ---------------------------
##
## Notes: Creates the model:
##   brain = int + bl_age + int*bl_age + sex
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"sorted.qdec.table.dat",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)

# Scale the variables
df$bl_age_z = scale(df$bl_age)
df$int_z = scale(df$int)

X <- model.matrix(~ int_z + 
                    bl_age_z + 
                    int_z*bl_age_z +
                    sex, df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)