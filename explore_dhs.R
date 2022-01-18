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
#dhs8 <- dhs[dhs$survey_year > 1990 & dhs$n_anchors > 4, ]
#dhs8 <- dhs[dhs$country != "JO" & dhs$country != "EG", ]

#dhs8 <- dhs[dhs$urban_rural == "Rural",]
dhs8 <- dhs
names(dhs8)[15] <- "factor_all"
names(dhs8)[16] <- "factor_ef1"
names(dhs8)[17] <- "factor_ef2"

# print number of surveys from full dataset
print("Number of Surveys");(length(dhs8$country))

# load DHS country ids (from library rdhs)
ids <- read.csv("./dhs/dhs_cc.csv")
#ids <- dhs_countries(returnFields=c("CountryName", "DHS_CountryCode"))
ids <- rename(ids,c("DHS_CountryCode" = "country"))

# mode function
#Mode <- function(x) {
#  ux <- unique(x)
#  ux[which.max(tabulate(match(x, ux)))]
#}

# apply function
#dat <- aggregate(factor ~ latitude + longitude + country + urban_rural, data=dhs8, Mode)
dat <- dhs8

# reduce 5 wealth factors
dat$factor_all[dat$factor_all == "Poorest" | dat$factor_all == "Poorer"] <- "Poorer"
dat$factor_all[dat$factor_all == "Richest" | dat$factor_all == "Richer"] <- "Richer"
dat$factor_all <- factor(dat$factor_all,levels=c("Poorer","Average","Richer"),ordered=T)

dat$factor_ef1[dat$factor_ef1 == "Poorest" | dat$factor_ef1 == "Poorer"] <- "Poorer"
dat$factor_ef1[dat$factor_ef1 == "Richest" | dat$factor_ef1 == "Richer"] <- "Richer"
dat$factor_ef1 <- factor(dat$factor_ef1,levels=c("Poorer","Average","Richer"),ordered=T)

dat$factor_ef2[dat$factor_ef2 == "Poorest" | dat$factor_ef2 == "Poorer"] <- "Poorer"
dat$factor_ef2[dat$factor_ef2 == "Richest" | dat$factor_ef2 == "Richer"] <- "Richer"
dat$factor_ef2 <- factor(dat$factor_ef2,levels=c("Poorer","Average","Richer"),ordered=T)

# drop any countries that do not have DHS measurements in all three wealth classes
ag.lis <- aggregate(factor_all ~ country, data=dat, FUN=function(x) length(unique(x)))
names(ag.lis) <- c("country","classes")
dat <- merge(ag.lis,dat,by="country")
dat <- dat[dat$classes == 3,]

# total HH surveys in reduced dataset
surveys <- dhs8[dhs8$country %in% dat$country, ]
length(surveys$country)

# merge dhs and country ids
final <- merge(ids,dat,by="country")

# plot data
ggplot(final, aes(factor_all)) +
  geom_bar(fill = "#0073C2FF") +
  facet_wrap(~CountryName, scales = "free")

# write csv
write.csv(final,"./dhs/dhs_harm_clean.csv")
