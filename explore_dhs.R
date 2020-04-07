# -----------------------------------
# explore_dhs.R
# explore/reformat DHS data
# IIASA, 28/03/2020
# -----------------------------------

library(raster)
library(ggplot2)
library(rdhs)
library(plyr)

# load
dhs <- read.csv("./dhs/dhs_harm_mw.csv")
dhs8 <- dhs[dhs$survey_year > 2010 & dhs$n_anchors == 8, ]
# dhs8 <- dhs8[dhs8$urban == "FALSE",]
names(dhs8)[7] <- "factor"

ag.lis <- aggregate(factor ~ country, data=dhs8, FUN=function(x) length(unique(x)))
names(ag.lis) <- c("country","classes")
dhs8 <- merge(ag.lis,dhs8,by="country")
dhs8 <- dhs8[dhs8$classes == 5,]

# load DHS country ids
ids <- dhs_countries(returnFields=c("CountryName", "DHS_CountryCode"))
ids <- rename(ids,c("DHS_CountryCode" = "country"))

# mode function
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# apply function
dat <- aggregate(factor ~ latitude + longitude + country, data=dhs8, Mode)

# reduce 5 wealth factors
dat$factor[dat$factor == "Poorest" | dat$factor == "Poorer"] <- "Poorer"
dat$factor[dat$factor == "Richest" | dat$factor == "Richer"] <- "Richer"
dat$factor <- factor(dat$factor,levels=c('Poorer','Average','Richer'),ordered=T)

# merge dhs and country ids
final <- merge(ids,dat,by="country")

# plot data
ggplot(final, aes(factor)) +
  geom_bar(fill = "#0073C2FF") +
  facet_wrap(~CountryName, scales = "free")

# write csv
write.csv(final,"./dhs/dhs_harm_clean.csv")
