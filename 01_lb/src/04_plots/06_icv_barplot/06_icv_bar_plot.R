library(ggplot2) # for plotting
library(latex2exp) # for LaTeX in plots
library(plotrix)
#+++++++++++++++++++++++++
# Function to calculate the mean and the standard deviation
  # for each group
#+++++++++++++++++++++++++
# data : a data frame
# varname : the name of a column containing the variable
  #to be summariezed
# groupnames : vector of column names to be used as
  # grouping variables
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE),
      se = std.error(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
 return(data_sum)
}

# load data
input_table = paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"above_below_median_hippocampus_icv.txt",sep="/")

dat <- read.table(input_table,header=TRUE)
dat <- dat[ which(dat$int==0),]

dat$value = dat$icv
dat$education_group = as.ordered(dat$above_median)
dat$sex = as.ordered(dat$sex)

head(dat)

dat2 <- data_summary(dat, varname="icv", 
                    groupnames=c("education_group"))

head(dat2)

ggplot(dat) + 
  geom_bar(aes(education_group, icv, fill=education_group),
           position = "dodge", stat = "summary", fun = "mean") +
  scale_fill_discrete(name = "Education group", labels = c("<= median","> median")) +
  theme_classic()

ggplot(dat2, aes(x=education_group, y=icv, fill=education_group)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=icv+qnorm(0.025)*se, ymax=icv+qnorm(0.975)*se), width=.2,
                 position=position_dodge(.9)) +
  scale_fill_discrete(name = "Education group", labels = c("<= median","> median")) +
  theme_classic() +
  ggtitle("LB: ICV") +
  ylab(TeX("Volume $(mm^3)$")) +
  theme(text = element_text(size=15))

ggsave(filename = "06_LB_icv_bar_plot.png", width = 12, height = 8, units = "cm")
ggsave(filename = "06_LB_icv_bar_plot.svg", width = 12, height = 8, units = "cm")
