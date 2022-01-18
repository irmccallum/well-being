#' SI_figure_stats_confidence.R
#' title: 'Bivariate Regressions: Lit/Unlit'
#' author: "Elena Moltchanova"
#' date: "17 September 2019"
#' modified: IIASA
#' date: "24 March 2021"
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
colnames(dat)[15] <- "continent"

dat$continent <- as.factor(dat$continent)

#' # Bivariate Modeling

# logit transform for probs, log transform for GDP
dat$logitWSFpc <- log(dat$Unlit_WSFpc/100/(1-dat$Unlit_WSFpc/100)); dat$logitWSFpc[dat$Unlit_WSFpc==0] <- log(0.01/.99)

# logit transform for se, urban
dat$logitse <- log(dat$se/100/(1-dat$se/100)); dat$logitse[dat$se==0] <- log(0.01/.99); dat$logitse[dat$se==100] <- log(0.99/.01)
dat$logitu <- log(dat$urban/100/(1-dat$urban/100)); dat$urban[dat$urban==0] <- log(0.01/.99); dat$logitu[dat$urban==100] <- log(0.99/.01)

## ------------------------------------------------------------------------
# fitting the models with interactions between continent 
m.GDP.int <- lm(logitWSFpc ~ I(log10(gdp))*continent, data=dat)
m.electric.int <- lm(logitWSFpc ~ I(log10(ec))*continent, data=dat)
m.school.int <- lm(logitWSFpc ~ logitse*continent, data=dat)
m.urban.int <- lm(logitWSFpc ~ I(logitu)*continent, data=dat)

# checking the diagnostics
par(mfrow=c(2,2)); plot(m.GDP.int)
par(mfrow=c(1,1))

## ------------------------------------------------------------------------
anova(m.GDP.int)
summary(m.GDP.int)

#' Use the model output to obtain the confidence intervals.
## ------------------------------------------------------------------------

contr <- t(array(
          c(0,1,0,0,0,0,0,0,0,0,0,0,
            0,1,0,0,0,0,0,1,0,0,0,0,
            0,1,0,0,0,0,0,0,1,0,0,0,
            0,1,0,0,0,0,0,0,0,1,0,0,
            0,1,0,0,0,0,0,0,0,0,1,0,
            0,1,0,0,0,0,0,0,0,0,0,1),dim=c(12,6)))

rownames(contr) <- levels(dat$continent)

gdp <- cbind(rownames(contr),estimable(m.GDP.int,contr))
e <- cbind(rownames(contr),estimable(m.electric.int,contr))
se <- cbind(rownames(contr),estimable(m.school.int,contr))
u <- cbind(rownames(contr),estimable(m.urban.int,contr))

# join all into one list
est <- rbind(gdp,e,se,u)

all.list <- NULL

for (i in 1:24){
ci.lo <- est$Estimate[i] - 1.96 * est$`Std. Error`[i]
ci.hi <- est$Estimate[i] + 1.96 * est$`Std. Error`[i]
ln.est <- est$Estimate[i] / log(10)
ln.lo <- ci.lo / log(10)
ln.hi <- ci.hi / log(10)
pc.est <- round((exp(ln.est * log(1.1))-1)*100,2)
pc.lo <- round((exp(ln.lo * log(1.1))-1)*100,2)
pc.hi <- round((exp(ln.hi * log(1.1))-1)*100,2)
p <- format(round(est$`Pr(>|t|)`[i],4), scientific = FALSE)
if(p == 0) p <- "<0.0001"

c <- as.vector(est$`rownames(contr)`[i])

lohi <- paste0("(",pc.lo,"; ",pc.hi,")")
stats.list <- cbind(c,pc.est,lohi,p)
all.list <- rbind(all.list,stats.list)
}

all.list

# write out csv
write.csv(all.list, "fig2stats.csv")
