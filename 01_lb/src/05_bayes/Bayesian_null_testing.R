library(lme4)
library(lmerTest)
library(ggplot2)
library(brms)

data_table <- paste(Sys.getenv("ABOVE_BELOW_MEDIAN_DIR"),"above_below_median_hippocampus_icv.txt",sep="/")
df <- read.csv(data_table,sep=" ")

df$edu_group = df$above_median # 0 og 1
df$y = df$hippocampus_mean

head(df)

typeof(df$edu)
typeof(df$bl_age)
typeof(df$id)
typeof(df$y)
typeof(df$int)

ggplot()+geom_point(aes(x=age,y=y,group=id),df)+geom_line(aes(x=age,y=y,group=id),df)
summary(lme.mod<-lmer(y~bl_age*int+edu*int+(1|id),data=df))

########## Set same (default) priors for all regression coefs ##########
brm.mod1 <- brm(
    formula = y~bl_age*int+edu*int+(1|id),
    data=df, 
    family = gaussian(),
    prior = c(
        set_prior("normal(0,500)", class = "b"),
        set_prior("cauchy(0,2)", class = "sd")
    ),
    warmup = 1000, 
    iter = 2000, 
    chains = 4,
    control = list(adapt_delta = 0.975),
    sample_prior = "yes"
)
summary(brm.mod1)
saveRDS(brm.mod1,"brm.mod1.rds")
plot(brm.mod1)
hypothesis(brm.mod1, "bl_age<0")
hypothesis(brm.mod1, "edu>0")
hypothesis(brm.mod1, "int:edu=0")

######### Set specific prior on interaction term following the Bergren et al paper ################
# Chosen prior puts more prior mass at zero, i.e. even small shifts away from zero in the posterior
# will decrease evidence for the null more dramatically
brm.mod2 <- brm(
    formula = y~bl_age*int+edu*int+(1|id),
    data=df, 
    family = gaussian(),
    prior = c(
        set_prior("normal(0,500)", class = "b"),
        set_prior("normal(0,0.5)", class = "b", coef="int:edu"),
        set_prior("cauchy(0,2)", class = "sd")
    ),
    warmup = 1000, 
    iter = 2000, 
    chains = 4,
    control = list(adapt_delta = 0.975),
    sample_prior = "yes"
)

summary(brm.mod2)
saveRDS(brm.mod2,"brm.mod2.rds")
plot(brm.mod2)
hypothesis(brm.mod2, "bl_age<0")
hypothesis(brm.mod2, "edu>0")
hypothesis(brm.mod2, "int:edu=0")

brm.mod3 <- brm(
    formula = y~bl_age*int+edu*int+(1|id),
    data=df, 
    family = gaussian(),
    prior = c(
        set_prior("normal(0,500)", class = "b"),
        set_prior("normal(0,1)", class = "b", coef="int:edu"),
        set_prior("cauchy(0,2)", class = "sd")
    ),
    warmup = 1000, 
    iter = 2000, 
    chains = 4,
    control = list(adapt_delta = 0.975),
    sample_prior = "yes"
)

summary(brm.mod3)
saveRDS(brm.mod3,"brm.mod3.rds")
plot(brm.mod3)
hypothesis(brm.mod3, "bl_age<0")
hypothesis(brm.mod3, "edu>0")
hypothesis(brm.mod3, "int:edu=0")