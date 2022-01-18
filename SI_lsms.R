# ----------------------------------
# SI_lsms.R
# plot lsms consumption vs. %unlit
# IIASA 22/11/2021
# ----------------------------------

library(raster)
library(plyr)
library(ggplot2)
#library(ggpmisc)
library(stringr)
library(ggpubr)

rm(list=ls())

c <- 1

tanzania <- read.csv("Tanzania 2013 LSMS (Household).csv")
tanzania$count <- 1
malawi <- read.csv("Malawi 2013 LSMS (Household).csv")
malawi$count <- 1
nigeria <- read.csv("Nigeria 2013 LSMS (Household).csv")
nigeria$count <- 1
uganda <- read.csv("Uganda 2012 LSMS (Household).csv")
uganda$count <- 1

nigeria$rururb <- str_to_title(nigeria$rururb)
tanzania$rururb <- str_to_title(tanzania$rururb)
malawi$rururb <- str_to_title(malawi$rururb)
uganda$rururb <- str_to_title(uganda$rururb)

uganda <- na.omit(uganda)
nigeria <- na.omit(nigeria)
tanzania <- na.omit(tanzania)
malawi <- na.omit(malawi)

uganda$country <- "Uganda"
tanzania$country <- "Tanzania"
nigeria$country <- "Nigeria"
malawi$country <- "Malawi"

dflist <- list(nigeria, uganda, tanzania, malawi )

for (i in dflist) {

# Clustering for LSMS survey data

  Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }

lsms <- ddply(i, .(lat, lon), summarise, cons = mean(cons), country = paste(unique(country)),
      rururb = Mode(rururb), count = sum(count))

# this removes clusters with only 1 household - highly uncertain
lsms <- lsms[lsms$count > 1,]
coordinates(lsms) <- ~lon+lat

# load wsf and viirs tifs, stack and crop
wsfall <- raster("../dhs/wsfall_all.tif")
wsfunlit <- raster("../dhs/wsfunlit_all.tif")
s <- stack(wsfall,wsfunlit)
s <- crop(s,lsms)
#s <- raster("Nigeria_ll.tif")
#names(s) <- "pcunlit"

# extract raster data from cluster buffers (2km-urban and 5km-rural)
lsms <- lsms[!is.na(lsms$rururb), ]
lsmsurb <- lsms[lsms$rururb == "Urban",]
wsfurb <- raster::extract(s,lsmsurb,buffer=10000,fun=sum,df=T)
lsmsrur <- lsms[lsms$rururb == "Rural",]
wsfrur <- raster::extract(s,lsmsrur,buffer=10000,fun=sum,df=T)

newurb <- cbind(wsfurb,as.data.frame(lsmsurb))
newrur <- cbind(wsfrur,as.data.frame(lsmsrur))
new <- rbind(newurb,newrur)

new$pcunlit <- new$wsfunlit / new$wsfall * 100

breaks <- c(1,1.9,5,10,20) # Choose consumption tick labels

pooled <- rbind(uganda, tanzania, nigeria, malawi)
pooled <- pooled[pooled$cons < 20 & pooled$cons > 1, ]

margin <- range(pooled$cons, na.rm = T)

p <- ggplot(new, aes(cons, pcunlit, color = rururb)) + #color = rururb
  geom_point(alpha=0.25, size = 2)+ # alpha(0.25)
  geom_smooth(method = loess) +
  geom_vline(xintercept = 1.9, color = 'black', size = 1) +
  ggtitle(unique(new$country))+
  ylim(0, 100) +
  scale_x_continuous(trans='log', breaks = breaks, limits = margin, minor_breaks = NULL) +

  theme(legend.position="none") +
  theme(legend.title = element_blank()) +
  xlab("Daily Consumption (2011 USD)") + ylab("Unlit settlements (%)") +
  theme_classic()

p

assign(paste0("p",c),p)
c <- c+1

}

# save plots
g <- ggarrange(p1,p2,p3,p4,nrow=2,ncol=2,labels=c("a","b","c","d"), common.legend = TRUE, legend = "bottom")
g
ggsave(paste0("../figs/lsms.png"),  width=6, height=6, dpi=300)
