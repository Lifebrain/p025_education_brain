#!/bin/usr/env R
## ---------------------------
##
## Script name: create_model.R
##
## Purpose of script: Create model for analysis
##
## Author: Fredrik Magnussen
##
## Date Created: 2020-09-17
##
## Email: fredrik.magnussen@psykologi.uio.no
##
## ---------------------------
##
## Notes: Creating following model:
##   brain = edu + int + edu*int + sex + scanner + bl_age + bl_age^2,
##   where scanner is a proxy for the study.
##
## ---------------------------

input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"MEGA.sorted.qdec.table.dat",sep="/")
output_table = paste(Sys.getenv("output_dir"),"model.dat",sep="/")

df <- read.table(input_table,header=TRUE)

# Scale the variables
df$edu = df$edu_coded
df$bl_age = scale(df$baseline_age)
df$int = scale(df$years)
df$sex = df$sex

X <- model.matrix(~ edu + 
                    int + 
                    edu * int + 
                    sex + 
                    scanner +
                    bl_age + 
                    I(bl_age^2), df)

# Check if rank is equal to number of columns
stopifnot(qr(X)$rank==ncol(X))

write.table(X,output_table,row.names=FALSE)