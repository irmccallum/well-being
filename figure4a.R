# ----------------------------------
# figure4a.R
# Wealth index comparison for Nigieria
# IIASA 22/11/2021
# ----------------------------------

library(pdftools)
library(raster)
library(ggplot2)
library(ggpubr)

rm(list=ls())

s <- shapefile("./nigeria/gadm36_NGA_2.shp")

yeh.r <- raster("nigeria_2012_2014_msnl_vals.tif")

iiasa.df <- read.csv("../figs/nigeria.csv")
poor <- iiasa.df[iiasa.df$best.class == "Poorer",]; poor$class <- 1
avg <- iiasa.df[iiasa.df$best.class == "Average",]; avg$class <- 2
rich <- iiasa.df[iiasa.df$best.class == "Richer",]; rich$class <- 3
iiasa.df <- rbind(poor,avg,rich)

sp <- iiasa.df[,c(2:3,7)]

# add geo-coords
newproj <- "+proj=robin" # longlat

coordinates(sp) <- ~x+y
crs(sp) <- "+proj=robin"
newproj <- crs(yeh.r, asText = TRUE) #"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 " # longlat
sp <- spTransform(sp, CRS(newproj))

s <- spTransform(s, CRS(newproj))


yeh.v <- extract(yeh.r,s, df = TRUE, fun=mean)
iiasa <- over(s,sp, fn=median)
iiasa$class.r <- ceiling(iiasa$class)

test <- extract(yeh.r,sp,df=TRUE)
sp <- as.data.frame(sp)
test <- cbind(test,sp)


all <- cbind(iiasa,yeh.v)
all$class.f <- as.factor(all$class.r)
levels(all$class.f) <- c("Poorer","Average", "Richer")

p <- ggplot(all, aes(x=class.f, y=nigeria_2012_2014_msnl_vals)) + 
  xlab("") + ylab("Wealth Index")+
  theme_bw()+
  geom_boxplot(notch=TRUE,outlier.shape = NA) +
  theme(text = element_text(size=9))
  #geom_jitter(position=position_jitter(0.2))
p
 

# save plots
g <- ggarrange(p,nrow=1,ncol=1,labels=c("a"))
g
ggsave(paste0("../figs/yeh.png"),  width=2, height=2, dpi=300)

