library(mgcv) # package with gamm() function
library(ggplot2) # for plotting
library(latex2exp) # for LaTeX in plots

# load data
input_table = paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"above_below_median_hippocampus_icv.txt",sep="/")
dat <- read.table(input_table,header=TRUE)

label_lh_stats = paste(Sys.getenv("OUTPUT_DIR"),"02_mass-univariate_analyses/06_model06_bl-agexint/stats/sig.lh.th30.abs.sig.volume.label.negative-clusters-merged.label.stats",sep="/")
label_rh_stats = paste(Sys.getenv("OUTPUT_DIR"),"02_mass-univariate_analyses/06_model06_bl-agexint/stats/sig.rh.th30.abs.sig.volume.label.negative-clusters-merged.label.stats",sep="/")

lh_volume <- read.table(label_lh_stats,header=FALSE)
rh_volume <- read.table(label_rh_stats,header=FALSE)

dat$value = (lh_volume$V1 + rh_volume$V1)/2
dat$education_group = as.ordered(dat$above_median)
dat$sex = as.ordered(dat$sex)

head(dat)
# Plot data before fitting GAMM
ggplot(dat, aes(x = age, y = value, group = id,color=scanner)) + 
  geom_line() + # segments between points with the same id
  geom_point() +
  ggtitle("0 : <=below_median; 1: >above_median ")

# Save plot
ggsave(filename = "03_pre_test.png", width = 12, height = 8, units = "cm")

# Fit GAMM
mod <- gamm(value ~ education_group + s(age) + s(age,by=education_group), data = dat, random = list(id =~ 1))
summary(mod$gam) 
# Plot the estimated function. Very nonlinear.
# This uses R's built-in plotting tool.
plot(mod$gam)
# We might use ggplot2 to get more customizable plots
# create a grid of values over which to plot
grid <- expand.grid(
  age = seq(from = 20, to = 90, by = 1),
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
  geom_ribbon(alpha=0.1,color=NA) +
  theme_classic() +
  scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
  xlab("Age (years)") +
  ylab(TeX("Cortical volume"))

# But we might want to add data to the plots as well
# We also save the plot to the variable p
p <- ggplot(grid, aes(x = age)) +
  geom_line(aes(y = estimate,group=education_group,color=education_group)) +
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci,group=education_group), alpha = .2) +
  geom_point(data = dat, aes(y = value), size = .2, alpha = .2) +
  geom_line(data = dat, aes(y = value, group = id), alpha = .2) +
  theme_classic() +
  scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
  xlab("Age (years)") +
  ylab(TeX("Cortical volume"))
# Print the plot
p

# Save plot
ggsave(filename = "03_LB_cortical_volume_most_change_all.png", width = 12, height = 8, units = "cm")


# Test if it is significance between the two groups
# Fit GAMM
mod2 <- gamm(value ~ education_group + s(age) + s(age,by=education_group) + scanner + sex + icv, data = dat, random = list(id =~ 1))
summary(mod2$gam) 
# Plot the estimated function. Very nonlinear.
# This uses R's built-in plotting tool.
plot(mod2$gam,select=1)
plot(mod2$gam,select=2)

grid <- expand.grid(
  age = seq(from = 30, to = 90, by = .1),
  education_group = factor(0:1),
  scanner = "ousAvanto",
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
  scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
  xlab("Age (years)") +
  ggtitle("LB: Athrophy-prone regions") +
  ylab(TeX("Mean cortical volume $(mm^3)$")) +
  theme(text = element_text(size=15))

# Save plot
ggsave(filename = "03_LB_cortical_volume_covariates_included.png", width = 12, height = 8, units = "cm")
ggsave(filename = "03_LB_cortical_volume_covariates_included.svg", width = 12, height = 8, units = "cm")