# ----------------------------------
# SI figure_globe - urban.R
# map %unlit by country and barplot
# IIASA 24/06/2021
# ----------------------------------

# create map of country percent unlit
library(raster)
library(plyr)
library(RColorBrewer)
library(ggplot2)
library(magrittr)
library(ggpubr)
library(ggmap)

# load unlit csv
unlit <- read.csv("globalunlitwsf.csv")
unlit <- rename(unlit, replace = c("Country" = "id"))
unlit <- na.omit(unlit)
unlit[unlit == 0] <- 0.1 # then ensures that polygon is shaded

# load countries, bbox
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$ADMIN != "Antarctica" & natearth$ADMIN != "Greenland"
natearth <- natearth[index,]
natearth$country <- natearth$ADMIN
bbox <- shapefile("./graticules/ne_110m_wgs84_bounding_box.shp") 
grat <- shapefile("./graticules/ne_110m_graticules_30.shp")

# add outline of all polygons to map
blank <- shapefile('./countries/ne_50m_admin_0_countries.shp')

# project map
newproj <- "+proj=robin"
natearthp <- spTransform(natearth, CRS(newproj))
blankp <- spTransform(blank, CRS(newproj)) %>% fortify()
bbox_robin <- spTransform(bbox, CRS(newproj)) %>% fortify()
grat_robin <- spTransform(grat, CRS(newproj)) %>% fortify()

# join data
r2 <- fortify(natearthp,region="country")
r2_join = plyr::join(x = r2,y = unlit, by="id")
r2_join$brks <- cut(r2_join$Unlit_urban_pc, 
                   breaks=c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100), 
                   labels=c("0 - 10", "10 - 20", "20 - 30", 
                            "30 - 40", "40 - 50", "50 - 60", "60 - 70",
                            "70 - 80", "80 - 90", "90 - 100"))
r2_join <- r2_join[complete.cases(r2_join), ]

# plot map
p1 <- ggplot()+ 
  geom_polygon(data=blankp, aes(x=long, y=lat,group = group),fill = "transparent", color="grey50", size = 0.21) +
  geom_polygon(data=bbox_robin, aes(x=long, y=lat), colour="grey50", fill="transparent", size = 0.21) +
  geom_polygon(data=r2_join, aes(x=long, y=lat,group=group,fill=Unlit_urban_pc), colour="grey50", size = 0.21) +
  scale_fill_viridis_c(limits=c(0,100),breaks=c(0,25,50,75,100), direction = -1,option = "inferno") +
  geom_path(data=grat_robin, aes(long,lat,group=group),linetype="dashed", color="grey50", size = 0.21) +
  theme_void()+
  theme(text = element_text(size=10))+
  theme(legend.position="bottom")+
  labs(fill = "Unlit\nsettlements (%)")

# create barplot
df <- as.data.frame(unlit)
ne <- as.data.frame(natearth)
ne <- ne[c(9,36, 60)]
new <- merge(df,ne,by.x="id",by.y="ADMIN")
new <- new[order(-new$Unlit_urban_pc),]
new$pop <- as.numeric(new$POP_EST)
final <- subset(new, pop > 50000000 & CONTINENT == "Africa" | pop > 50000000 & CONTINENT == "Asia")

final$id <- as.factor(final$id)

levels(final$id)[match("Democratic Republic of the Congo",levels(final$id))] <- "DRC"
levels(final$id)[match("United Republic of Tanzania",levels(final$id))] <- "Tanzania"
levels(final$id)[match("United States of America",levels(final$id))] <- "USA"

p2<-ggplot(data=final, aes(x=reorder(id,Unlit_urban_pc), y=Unlit_urban_pc,fill=Unlit_urban_pc)) +
  geom_bar(stat="identity")+
  coord_flip()+
  theme_pubr()+
  theme(text = element_text(size=10))+
  labs(y="Unlit settlements (%)",x="")+
  scale_y_continuous(limits=c(0,75),breaks = c(0,25,50,75))+
  scale_fill_viridis_c(direction = -1,option = "inferno",guide = "none", limits=c(0,100))

# save plot
g <- ggarrange(p1,p2,ncol=2,labels = c("a","b"),widths = c(2,1))
ggsave(paste("./figs/figure1_globe_urban.png",sep=""), width=10, height=4, dpi=300)
