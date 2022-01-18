# -----------------------------------
# figure2_dhs.R
# produce global dhs wealth and % unlit figure
# IIASA, 25/11/2021
# -----------------------------------

library(raster)
library(ggplot2)
library(ggpol)
library(rgeos)

rm(list=ls())

# load data
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$CONTINENT != "Antarctica"
natearth <- natearth[index,]
natearth <- natearth[c(18,36,60)]
names(natearth) <- c("CountryName","Population","Continent")
natearth$Population <- as.numeric(natearth$Population)
natearth$CountryName[natearth$CountryName == "Dem. Rep. Congo"] <- "Congo Democratic Republic"
natearth$CountryName[natearth$CountryName == "Côte d'Ivoire"] <- "Cote d'Ivoire"
natearth$CountryName[natearth$CountryName == "Dominican Rep."] <- "Dominican Republic"
natearth$CountryName[natearth$CountryName == "eSwatini"] <- "Eswatini"

dhs <- read.csv("./dhs/dhs_harm_clean.csv")
test1 <- as.data.frame(sort(unique(dhs$CountryName)))

# merge dhs and country data
dhs <- merge(dhs,natearth,by="CountryName")
test2 <- as.data.frame(sort(unique(dhs$CountryName)))

# remove small countries and low data
#dhs <- dhs[dhs$Population > 1000000,] # removes small countries
dhs <- dhs[dhs$CountryName != "Jordan",] # remove, too little data
dhs <- dhs[dhs$CountryName != "Egypt",] # remove, too little data
#dhs <- dhs[dhs$CountryName != "Chad",] # remove, too little data
#dhs <- dhs[dhs$CountryName != "Ethiopia",] # remove, too little data
dhs <- dhs[dhs$CountryName != "Niger",] # remove, too little data
dhs <- dhs[dhs$CountryName != "South Africa",] # remove, too little data
#dhs <- dhs[dhs$CountryName != "Eswatini",] # remove, too little data
#dhs <- dhs[dhs$CountryName != "Namibia",] # remove, too little data
#dhs <- dhs[dhs$CountryName != "Morocco",] # remove, too little data

# number of villages
print("Number of Villages"); length(dhs$CountryName)

# number of countries
print("Number of Countries"); unique(dhs$CountryName)

# add geo-coords
coordinates(dhs) <- ~longitude+latitude

# plot dhs data for SI
ne <- fortify(natearth,region="CountryName")
dhs.df <- as.data.frame(dhs)
d <- fortify(dhs.df,region="Continent")

p1 <- ggplot()+ 
  geom_path(data=ne, aes(long,lat, group=group), col="dark grey")+
  geom_point(data=d, aes(longitude,latitude),pch=21, cex=0.4, col = "blue")+
  #geom_point(color='darkblue')+
  xlab("Longitude")+
  ylab("Latitude")+
  theme_bw()+
#  theme(aspect.ratio = 1) 
coord_equal(ratio = 1)
p1

# save figure
ggsave(paste("./figs/dhs.png",sep=""),p1,width=7.5, height=4, dpi=300)

#############################
dhs <- dhs[dhs$Continent == "Africa",]# | dhs$Continent == "South America",] # a specific continent
#############################

# load wsf and viirs tifs, stack and crop
wsfall <- raster("./dhs/wsfall.tif")
wsfunlit <- raster("./dhs/wsfunlit.tif")
s <- stack(wsfall,wsfunlit)
s <- crop(s,dhs)

# extract raster data from cluster buffers (2km-urban and 5km-rural)
dhs <- dhs[!is.na(dhs$urban_rural), ]
dhsurb <- dhs[dhs$urban_rural == "Urban",]
wsfurb <- raster::extract(s,dhsurb,buffer=2500,fun=sum,df=T)
dhsrur <- dhs[dhs$urban_rural == "Rural",]
wsfrur <- raster::extract(s,dhsrur,buffer=5500,fun=sum,df=T)

newurb <- cbind(wsfurb,as.data.frame(dhsurb))
newrur <- cbind(wsfrur,as.data.frame(dhsrur))
new <- rbind(newurb,newrur)

#new <- cbind(wsf.df,as.data.frame(dhs))
new$pcunlit <- new$wsfunlit / new$wsfall * 100

# order levels
new$factor_ef1 <- as.factor(new$factor_ef1)
new$factor <-factor(new$factor_ef1,levels = levels(new$factor_ef1)[c(2,1,3)])

new <- new[!is.na(new$Continent),] # drop NAs

# plot figure
bp2 <- ggplot(new, aes(x=factor, y=pcunlit, fill=factor))+ ## alpha = urban_rural - not great
  geom_boxplot(notch = FALSE)+#(aes(colour = urban_rural))+ notch=TRUE outlier.shape=NA - This works well
  #geom_jitter(aes(colour = urban_rural))+
  ggtitle("")+
  labs(y = "Unlit settlements (%)", x = "DHS wealth index") +
  facet_wrap(~CountryName )+ #, ncol = 5 + urban_rural - not great
  theme_bw() +
  theme( strip.background = element_rect(fill = "white"))+
  ylim(0,100)+
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_fill_brewer(palette="Blues") + theme(legend.position="none")
bp2

# create item to determine value for all countries
all <- new
all$CountryName <- "All countries"
new <- rbind(new,all)

# write out validation file
#write.csv(new,paste0("./dhs/figure4data_rev",unique(dhs$Continent),".csv"))
write.csv(new,paste0("./dhs/figure2data_rev_all.csv"))

# save figure
ggsave(paste("./figs/figure2_dhs_",unique(dhs$Continent)[1],"_bplot.png",sep=""),bp2,width=7.5, height=10, dpi=300)

