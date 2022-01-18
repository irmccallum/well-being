# ----------------------------------
# figure4c.R
# SHDI income vs wealth class for Nigeria
# IIASA 22/11/2021
# ----------------------------------

library(raster)
library(ggplot2)
library(ggpubr)


rm(list=ls())

# load income index
inc <- read.csv("../SHDI/GDL-Income-index-data.csv")
names(inc)[names(inc) == "GDLCODE"] <- "GDLcode"

# load SHDI polygons
sp <- shapefile("../SHDI/GDL Shapefiles V4.shp")

sp <- sp[!is.na(sp$country),]


sp <- sp[sp$country == "Nigeria",  ]

# load incombe data, along with lights and unlit %

allwsf <- raster("../dhs/wsfall.tif")
unlitwsf <- raster ("../dhs/wsfunlit.tif")
unlit <- raster("../viirs/unlit/VIIRSunlit.vrt")

s <- stack(allwsf,unlitwsf, unlit)

s <- crop(s, sp)
lit <- s$VIIRSunlit
lit[lit==1]<- 0
lit[is.na(lit)]<- 1
s$lit <- lit


s$area <- area(s)
s$unlit <- s$VIIRSunlit * s$area

s <- aggregate(s,5, fun=sum)

pcu <- s$wsfunlit / s$wsfall * 100

e <- extract(pcu,sp, fun = mean, df=TRUE, na.rm=TRUE)
l <- extract(s$lit,sp, fun=sum, df=TRUE,na.rm=TRUE)
l <- l[,2]
spp <- as.data.frame(sp)
final <- cbind(e,spp,l)

total <- merge(final,inc,by="GDLcode")

m <- lm(X2015~layer+l, data=total) # +unlit
summary(m)

p <- ggplot(total, aes(X2015, layer, group = country) ) +
  geom_point(alpha=0.6)+
  theme_bw()+
  xlab("Income Index")+
  ylab("Unlit Settlements %")+
  geom_smooth(method = lm) +
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~")), color = "black", geom = "label",label.y.npc="bottom", label.x.npc = "left")+
  theme(text = element_text(size=9))
p

# save plots
g <- ggarrange(p,nrow=1,ncol=1,labels=c("c"))
g
ggsave(paste0("../figs/income.png"),  width=2, height=2, dpi=300)
