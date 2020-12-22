set.seed(123)
library(mgcv) # package with gamm() function
library(ggplot2) # for plotting
library(latex2exp) # for LaTeX in plots

# load data
input_table = paste(Sys.getenv("QDEC_DATA_DIR"),"sorted.qdec.table.dat",sep="/")
aseg_table = paste(Sys.getenv("ASEG_DATA_DIR"),"aseg.long.table",sep="/")

dat <- read.table(input_table,header=TRUE)
dat_aseg <- read.table(aseg_table,header=TRUE)

dat$value = (dat_aseg$Left.Hippocampus + dat_aseg$Right.Hippocampus)/2
dat$icv = dat_aseg$EstimatedTotalIntraCranialVol

dat$education_group = as.ordered(dat$edu_coded)
dat$sex = as.ordered(dat$sex)
dat$age = dat$bl_age + dat$int

# Get id
dat$id = gsub("_base","",dat$fsid_base)

head(dat)
# Plot data before fitting GAMM
ggplot(dat, aes(x = age, y = value, group = id,color=education_group)) + 
  geom_line() + # segments between points with the same id
  geom_point() +
  ggtitle("0: non-university degree; 1: university degree")

# Fit GAMM
# We could have included scanner as an additional variable,
# by writing "value ~ s(age) + scanner", but this will make
# the plots harder to understand, since we then get one curve
# for each scanner. Use instead a model with only age, and no 
# other variable like sex, scanner, etc, since the purpose here
# is visualization only.
mod <- gamm(value ~ education_group + s(age) + s(age,by=education_group), data = dat, random = list(id =~ 1))
summary(mod$gam) 
# Plot the estimated function. Very nonlinear.
# This uses R's built-in plotting tool.
plot(mod$gam)
# We might use ggplot2 to get more customizable plots
# create a grid of values over which to plot
grid <- expand.grid(
  age = seq(from = 45, to = 80, by = 1),
  education_group = factor(0:1)
)

# Compute the fit
fit <- predict(mod$gam, newdata = grid, se.fit = TRUE)

# Put the fit into the grid
grid$estimate <- fit$fit
grid$lower_ci <- grid$estimate + qnorm(.025) * fit$se.fit
grid$upper_ci <- grid$estimate + qnorm(.975) * fit$se.fit

# Plot fit with 95 % confidence bands
ggplot(grid, aes(x = age, y = estimate, group=education_group,color=education_group, ymin=lower_ci, ymax=upper_ci)) +
  geom_line() +
  ggtitle("UKB: Mean hippocampus volume") +
  geom_ribbon(alpha=0.1,color=NA) +
  theme_classic() +
  xlab("Age (years)") +
  ylab(TeX("Volume $(mm^3)$")) +
  scale_color_discrete(name = "Education group",label=c("non-university degree","university degree"))

# Save plot
ggsave(filename = "02_UKB_hippocampus.png", width = 12, height = 8, units = "cm")

# But we might want to add data to the plots as well
# We also save the plot to the variable p
p <- ggplot(grid, aes(x = age)) +
  geom_line(aes(y = estimate,group=education_group,color=education_group)) +
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci,group=education_group), alpha = .2) +
  geom_point(data = dat, aes(y = value), size = .2, alpha = .2) +
  geom_line(data = dat, aes(y = value, group = id,color=education_group), alpha = .2) +
  theme_classic() +
  ggtitle("UKB: Mean hippocampus volume") +
  xlab("Age (years)") +
  ylab(TeX("Volume $(mm^3)$")) + 
  scale_color_discrete(name = "Education group",label=c("non-university degree","university degree"))
# Print the plot
p

# Save plot
ggsave(filename = "02_UKB_hippocampus_all.png", width = 12, height = 8, units = "cm")

mod2 <- gamm(value ~ education_group + s(age) + s(age,by=education_group) + sex + icv, data = dat, random = list(id =~ 1))
summary(mod2$gam) 
# Plot the estimated function. Very nonlinear.
# This uses R's built-in plotting tool.
#plot(mod2$gam,select=1)
#plot(mod2$gam,select=2)

grid <- expand.grid(
  age = seq(from = 45, to = 80, by = .1),
  education_group = factor(0:1),
  sex = factor(1),
  icv = mean(dat$icv)
)

fit <- predict(mod2$gam,newdata = grid,se.fit=TRUE)

grid$estimate <- fit$fit
grid$lower_ci <- grid$estimate + qnorm(.025) * fit$se.fit
grid$upper_ci <- grid$estimate + qnorm(.975) * fit$se.fit

# Plot fit with 95 % confidence bands
ggplot(grid, aes(x = age, y = estimate, group=education_group,color=education_group, ymin=lower_ci, ymax=upper_ci)) +
  geom_line() +
  geom_ribbon(alpha=0.1,color=NA) +
  theme_classic() +
  xlab("Age (years)") +
  ylab(TeX("Mean volume $(mm^3)$")) + 
  scale_color_discrete(name="Education group",labels=c("non-university","university/college")) +
  ggtitle("UKB: Hippocampus") +
  theme(text = element_text(size=15))

  # Save plot
ggsave(filename = "02_hippocampus_volume_covariates_included.png", width = 12, height = 8, units = "cm")
ggsave(filename = "02_hippocampus_volume_covariates_included.svg", width = 12, height = 8, units = "cm")