#!/usr/bin/env R
# Purpose plot median range plot with ggplot

library(ggplot2) # for plotting
library(latex2exp) # for LaTeX in plots

## Read data
input_table = paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"above_below_median_hippocampus_icv.txt",sep="/")
dat <- read.table(input_table,header=TRUE,sep=" ")

input_table_median = paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"age_group_median.txt",sep="/")
dat_median <- read.table(input_table_median,header=TRUE,sep=" ")

dat$education_group = as.ordered(dat$above_median)

dat_median <- dat_median[ which(dat_median$age_group<100), ]

ggplot() +
geom_jitter(data=dat,aes(x = age_group, y = edu, color = education_group),width=1.3) +
theme_classic() +
xlab("Age group (years)") +
scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
ylab(TeX("Education (years)")) +
theme(text = element_text(size=15)) +
geom_line(data=dat_median,aes(x=age_group,y=median_education),linetype="dashed")

# Save plot
ggsave(filename = "05_median_plot.png", width = 12, height = 8, units = "cm")
ggsave(filename = "05_median_plot.svg", width = 12, height = 8, units = "cm")
