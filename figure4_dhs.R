# -----------------------------------
# figure4_dhs.R
# produce global dhs wealth and % unlit figure
# IIASA, 01/04/2020
# -----------------------------------

library(raster)
library(ggplot2)
library(ggpol)
library(rgeos)

# load data
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$CONTINENT != "Antarctica"
natearth <- natearth[index,]
natearth <- natearth[c(18,36,60)]
names(natearth) <- c("CountryName","Population","Continent")
natearth$Population <- as.numeric(natearth$Population)
dhs <- read.csv("./dhs/dhs_harm_clean.csv")

# merge dhs and country data
dhs <- merge(dhs,natearth,by="CountryName")

# filter continent, pop > 1 mil and Jordan
dhs <- dhs[dhs$Continent == "North America",] # a specific continent
#dhs <- dhs[dhs$Continent != "Africa",] # non-africa only
dhs <- dhs[dhs$Population > 1000000,] # removes small countries
dhs <- dhs[dhs$CountryName != "Jordan",] # remove, too little data

# add geo-coords
coordinates(dhs) <- ~longitude+latitude

# plot dhs data for SI
ne <- fortify(natearth,region="Continent")
dhs.df <- as.data.frame(dhs)
d <- fortify(dhs.df,region="Continent")

p1 <- ggplot()+ 
  geom_polygon(data=ne, aes(long,lat, group=group))+
  geom_point(data=d, aes(longitude,latitude),col="red",pch=1, cex=0.4)
p1

# save figure
ggsave(paste("dhs.png",sep=""),p1,width=10, height=7.5, dpi=300)

# load wsf and viirs tifs, stack and crop
wsfall <- raster("./dhs/wsfall.tif")
wsfunlit <- raster("./dhs/wsfunlit.tif")
s <- stack(wsfall,wsfunlit)
s <- crop(s,dhs)

# extract raster data from cluster buffers (10km)
wsf.df <- raster::extract(s,dhs,buffer=10000,fun=sum,df=T)
new <- cbind(wsf.df,as.data.frame(dhs))
new$pcunlit <- new$wsfunlit/new$wsfall * 100

# order levels
new$factor<-factor(new$factor,levels = levels(new$factor)[c(2,1,3)])

# plot figure
bp2 <- ggplot(new, aes(x=factor, y=pcunlit, fill=factor))+
  geom_boxplot()+
  ggtitle("")+
  labs(y = "Unlit settlements (%)", x = "DHS wealth index") +
  facet_wrap(~CountryName, ncol = 4)+
  theme_bw() +
  theme( strip.background = element_rect(fill = "white"))+
  ylim(0,100)+
  theme_minimal() +
    scale_fill_brewer(palette="Blues") + theme(legend.position="none")
bp2

# create item to determine value for all countries
all <- new
all$CountryName <- "All countries"
new <- rbind(new,all)

# write out validation file
write.csv(new,"./dhs/figure4data_rev.csv")

# save figure
ggsave(paste("figure4_dhs.png",sep=""),bp2,width=7.5, height=7.5, dpi=300)
