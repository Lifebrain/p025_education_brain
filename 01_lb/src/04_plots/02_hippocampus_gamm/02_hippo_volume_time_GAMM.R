library(mgcv) # package with gamm() function
library(ggplot2) # for plotting
library(latex2exp) # for LaTeX in plots

# load data
input_table = paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"above_below_median_hippocampus_icv.txt",sep="/")
dat <- read.table(input_table,header=TRUE)

dat$value = dat$hippocampus_mean
dat$education_group = as.ordered(dat$above_median)
dat$sex = as.ordered(dat$sex)

head(dat)
# Plot data before fitting GAMM
ggplot(dat, aes(x = age, y = value, group = id,color=scanner)) + 
  geom_line() + # segments between points with the same id
  geom_point() +
  ggtitle("0 : <=below_median; 1: >above_median")

# Fit GAMM
mod <- gamm(value ~ education_group + s(age) + s(age,by=education_group), data = dat, random = list(id =~ 1))
summary(mod$gam) 
# Plot the estimated function. Very nonlinear.
# This uses R's built-in plotting tool.
plot(mod$gam)
# We might use ggplot2 to get more customizable plots
# create a grid of values over which to plot
grid <- expand.grid(
  age = seq(from = 30, to = 90, by = 1),
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
  ggtitle("LB: Mean hippocampus volume") +
  geom_ribbon(alpha=0.1,color=NA) +
  theme_classic() +
  xlab("Age (years)") +
  ylab(TeX("Volume $(mm^3)$")) +
  scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +

# Save plot
ggsave(filename = "02_LB_hippocampus.png", width = 12, height = 8, units = "cm")

# But we might want to add data to the plots as well
# We also save the plot to the variable p
p <- ggplot(grid, aes(x = age)) +
  geom_line(aes(y = estimate,group=education_group,color=education_group)) +
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci,group=education_group), alpha = .2) +
  geom_point(data = dat, aes(y = value), size = .2, alpha = .2) +
  geom_line(data = dat, aes(y = value, group = id,color=education_group), alpha = .2) +
  theme_classic() +
  ggtitle("LB: Mean hippocampus volume") +
  xlab("Age (years)") +
  scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
  ylab(TeX("Volume $(mm^3)$"))
# Print the plot
p
# Save plot
ggsave(filename = "02_LB_hippocampus_all.png", width = 12, height = 8, units = "cm")

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
ggplot(
  grid, 
  aes(
    x = age, 
    y = estimate, 
    group=education_group,
    color=education_group, 
    ymin=lower_ci, 
    ymax=upper_ci
  )
) +
geom_line() +
geom_ribbon(alpha=0.1,color=NA) +
theme_classic() +
ggtitle("LB: Hippocampus") +
xlab("Age (years)") +
scale_color_discrete(name = "Education group", labels = c("<= median","> median")) +
ylab(TeX("Mean volume $(mm^3)$")) +
theme(text = element_text(size=15))

# Save plot
ggsave(filename = "02_LB_hippocampus_covariates_included.png", width = 12, height = 8, units = "cm")
ggsave(filename = "02_LB_hippocampus_covariates_included.svg", width = 12, height = 8, units = "cm")