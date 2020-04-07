# ----------------------------------
# figure3_maps.R
# unlit settlement country maps
# IIASA 24/03/2020
# ----------------------------------

library(raster)
library(plyr)
library(RColorBrewer)
library(ggplot2)
library(magrittr)
library(ggpubr)
library(ggmap)
library(ggsn)
library(ggnewscale)
library(ggrepel)
library(gdalUtils)

# load countries, bbox
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$ADMIN != "Antarctica" & natearth$ADMIN != "Greenland"
natearth <- natearth[index,]
natearth$country <- natearth$ADMIN

# load capital cities
caps <- shapefile("./cities/ne_10m_populated_places_simple.shp")
caps <- caps[caps$adm0cap == 1,]

# load data
wsf <- raster("./wsf/wsfavg.vrt")
unlit <- raster("./viirs/unlit/VIIRSunlit.vrt")

c <- 2

# plot maps
for (i in c("Bangladesh","Cambodia","Nigeria","Syria")){
  index <- natearth$ADMIN == i
  cntry <- natearth[index,]
  index <- caps$adm0name == i
  cap <- caps[index,]
  shapefile(cntry, './countries/cntry.shp', overwrite = TRUE)
  gdalwarp("./wsf/wsfavg.vrt", "./countries/cntry.tif", cutline = "./countries/cntry.shp", crop_to_cutline = T, overwrite = TRUE)
  r <- raster("./countries/cntry.tif")
  r <- mask(r,cntry)
  r <- r/255 * 100 # to remove decimals
  r[r == 0] <- NA
  lit <- crop(unlit,cntry)
  lit[lit==1] <- 0
  lit[is.na(lit)] <- 1
  lit[lit==0] <- NA
  litwsf <- r * lit
  unlitwsf <- r * unlit
 
  s <- stack(litwsf,unlitwsf)

  # project data
  newproj <- "+proj=robin"
  unlitwsf <- projectRaster(unlitwsf, crs=newproj)
  litwsf <- projectRaster(litwsf, crs=newproj)
  cntry <- spTransform(cntry, CRS(newproj))
  cap <- spTransform(cap, CRS(newproj))
  cap.df <- as.data.frame(cap)

  temp <- fortify(cntry)

  wsf.df = as.data.frame(unlitwsf,xy=TRUE)
  lit.df = as.data.frame(litwsf,xy=TRUE)
  lit.df$layer <- lit.df$layer/100
  
  s.df = as.data.frame(s,xy=TRUE)
  
  p <- ggplot()+ 
    
    annotate(geom="raster", x=lit.df$x, y=lit.df$y, alpha=.5,
             fill = scales::colour_ramp(c("black","black"))(lit.df$layer))+
    geom_point(data = lit.df, aes(x=x,y=y,size="layer", shape = NA), colour = "grey50")+
    guides(size=guide_legend("Lit\nsettlements",label = FALSE, override.aes=list(shape=15, size = 8)))+
    geom_raster(data=wsf.df,aes(x,y,fill=layer)) +
    scale_fill_viridis_c(option="magma",direction=-1,na.value = "transparent",name="Unlit\nsettlements (%)",
                         limits = c(0,100), breaks = c(0, 25, 50, 75, 100))+
    ggtitle(i) +
    xlab("") +
    ylab("") +
    geom_polygon(data=temp, aes(x=long, y=lat,group=group),fill="transparent",color="black") +
    geom_text_repel(data = cap.df, aes(x=coords.x1,y=coords.x2,label = name),size=2.5) +
    theme_bw() +
    theme(legend.position="bottom") +
    theme(aspect.ratio = 1) +
    theme(axis.text = element_text(size = 7.5)) +
    scale_x_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::comma) 
  
    assign(paste0("p",c),p)
    c <- c+1

}

p

# save plot
g <- ggarrange(p2,p3,p4,p5,nrow=2,ncol=2,labels="auto",common.legend = TRUE,legend="bottom")
ggsave(paste("figure3_maps.png",sep=""),  width=7.5, height=7.5, dpi=300)
