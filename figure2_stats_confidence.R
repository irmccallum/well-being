#' ---
#' title: 'Bivariate Regressions: Lit/Unlit'
#' author: "Elena Moltchanova"
#' date: "17 September 2019"
#' modified: IIASA
#' date: "24 March 2020"
#' output:
#'   estimated fixed effect parameters 
#' ---
#' 
#' # Loading the data
#' 
## ------------------------------------------------------------------------
rm(list=ls())

library(gmodels)

dat <- read.csv("alldata.csv")
colnames(dat)[2] <- "country"
colnames(dat)[9] <- "continent"

#' # Bivariate Modeling

# logit transform for probs, log transform for GDP
dat$logitWSFpc <- log(dat$Unlit_WSFpc/100/(1-dat$Unlit_WSFpc/100)); dat$logitWSFpc[dat$Unlit_WSFpc==0] <- log(0.01/.99)

# logit transform for r, urban
dat$logitr <- log(dat$r/100/(1-dat$r/100)); dat$logitr[dat$r==0] <- log(0.01/.99); dat$logitr[dat$r==100] <- log(0.99/.01)
dat$logitu <- log(dat$urban/100/(1-dat$urban/100)); dat$urban[dat$urban==0] <- log(0.01/.99); dat$logitu[dat$urban==100] <- log(0.99/.01)

#' 
## ------------------------------------------------------------------------
# fitting the models with interactions between continent 
m.GDP.int <- lm(logitWSFpc ~ I(log10(gdp))*continent, data=dat)
m.electric.int <- lm(logitWSFpc ~ I(log10(ec))*continent, data=dat)
m.roads.int <- lm(logitWSFpc ~ logitr*continent, data=dat)
m.urban.int <- lm(logitWSFpc ~ I(logitu)*continent, data=dat)

# checking the diagnostics
par(mfrow=c(2,2)); plot(m.GDP.int)
par(mfrow=c(1,1))


## ------------------------------------------------------------------------
anova(m.GDP.int)
summary(m.GDP.int)

#' 
#' Use the model output to obtain the confidence intervals. 
#' 
## ------------------------------------------------------------------------

contr <- t(array(
          c(0,1,0,0,0,0,0,0,0,0,0,0,
            0,1,0,0,0,0,0,1,0,0,0,0,
            0,1,0,0,0,0,0,0,1,0,0,0,
            0,1,0,0,0,0,0,0,0,1,0,0,
            0,1,0,0,0,0,0,0,0,0,1,0,
            0,1,0,0,0,0,0,0,0,0,0,1),dim=c(12,6)))

rownames(contr) <- levels(dat$continent)

estimable(m.GDP.int,contr)
estimable(m.electric.int,contr)
estimable(m.roads.int,contr)
estimable(m.urban.int,contr)
