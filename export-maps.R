# ----------------------------------
# figureX_pov_maps.R
# poverty maps
# IIASA 24/04/2020
# ----------------------------------

library(raster)
library(gdalUtils)
library(ggplot2)
library(ggpubr)
library(jcolors)
library(scales)
library(ggrepel)

rm(list=ls())
memory.limit(size=56000)

c <- 1

dat <- read.csv("./dhs/figure2data_rev_all.csv")
dat <- dat[dat$CountryName != "All countries",]
dat$CountryName <- as.factor(dat$CountryName)
#dat <- dat[dat$CountryName != "India",]
levels(dat$CountryName)[levels(dat$CountryName)=="Tanzania"] <- "United Republic of Tanzania"
levels(dat$CountryName)[levels(dat$CountryName)=="Timor-Leste"] <- "East Timor"
levels(dat$CountryName)[levels(dat$CountryName)=="Congo Democratic Republic"] <- "Democratic Republic of the Congo"
#levels(dat$CountryName)[levels(dat$CountryName)=="Cote d'Ivoire"] <- "Côte d'Ivoire"
#levels(dat$CountryName)[levels(dat$CountryName)=="Dominican Republic"] <- "Dominican Rep."

#levels(dat$CountryName)[levels(dat$CountryName)=="Cote d'Ivoire"] <- "CDI"

#dat <- dat[dat$urban_rural == "Urban",]

#dat <- dat[dat$has_electricity == 1,]

dat$factor <- factor(dat$factor_ef1,levels=c('Poorer','Average','Richer'),ordered=T)

# load country
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
natearth[natearth$SOVEREIGNT =="Ivory Coast"] <- "Cote d'Ivoire"

# load capital cities
caps <- shapefile("./cities/ne_10m_populated_places_simple.shp")
caps <- caps[caps$adm0cap == 1,]

################################################################
for(i in unique(dat$CountryName)){
#for (i in c("Bangladesh","Cambodia","Nigeria","Uganda")){
#for (i in c("Honduras","India","Indonesia")){

#i = "United Republic of Tanzania "

# load raster data
unlit <- raster("./viirs/unlit/VIIRSunlit.vrt")
wsf <- raster("./wsf/wsfnew_all.tif")

#newdat <- dat[dat$CountryName == unique(dat$CountryName)[i],]
newdat <- dat[dat$CountryName == i,]
summary(newdat)

index <- natearth$SOVEREIGNT == i
#index <- natearth$SOVEREIGNT == unique(dat$CountryName)[i]
cntry <- natearth[index,]

caps[caps$adm0name == "Congo (Kinshasa)"] <- "Democratic Republic of the Congo"
caps[caps$adm0name == "Ivory Coast"] <- "Cote d'Ivoire"
caps[caps$adm0name == "Tanzania"] <- "United Republic of Tanzania"

index <- caps$adm0name == i
cap <- caps[index,]
shapefile(cntry, './countries/cntry.shp', overwrite = TRUE)
#gdalwarp("./wsf/wsfavg.vrt", "./countries/cntry.tif", cutline = "./countries/cntry.shp", crop_to_cutline = T, overwrite = TRUE)
gdalwarp("./wsf/wsfnew_all.tif", "./countries/cntry.tif", cutline = "./countries/cntry.shp", crop_to_cutline = T, overwrite = TRUE, tr=c(0.004166667, 0.004166667))
gdalwarp("./viirs/unlit/VIIRSunlit.vrt", "./countries/unlit.tif", cutline = "./countries/cntry.shp", crop_to_cutline = T, overwrite = TRUE, tr=c(0.004166667, 0.004166667))


r <- raster("./countries/cntry.tif")
r <- mask(r,cntry)
r <- r/100
r[is.na(r)] <- 0
#r[r < 0.1] <- NA
#r[r == 0] <- NA
#unlit <- crop(unlit,cntry)
unlit <- raster("./countries/unlit.tif")
unlit <- mask(unlit,cntry)
#extent(unlit) <- extent(r)
#res(unlit) <- res(r)

unlit[is.na(unlit)] <- 0
lit <- unlit
lit[lit==1]<- 99
lit[lit==0]<- 1
lit[lit==99] <- 0
#lit <- crop(unlit,cntry)
#lit[lit==1] <- 0
#lit[is.na(lit)] <- 1
#lit[lit==0] <- NA
a <- area(r)
allwsf <- r * a
litwsf <- r * lit * a
unlitwsf <- r * unlit * a
#allwsf <- aggregate(allwsf, fact = 2, fun=sum, na.rm=T)
#unlitwsf <- aggregate(unlitwsf, fact = 2, fun=sum, na.rm=T)

#alllight <- litwsf + unlitwsf
s <- stack(allwsf,unlitwsf)
#unlitpc <- unlitwsf / allwsf * 100
#plot(s, col = heat.colors(10))
s <- aggregate(s,5, fun=sum)
unlitpc <- s$layer.2 / s$layer.1 * 100

# write out unlit
#writeRaster(unlitpc,paste0("./maps/",i,"_ll.tif"), overwrite = TRUE)

# project data
newproj <- "+proj=robin"
unlitwsfn <- projectRaster(unlitpc, crs=newproj)
litwsf <- projectRaster(litwsf, crs=newproj)
cntry <- spTransform(cntry, CRS(newproj))
cntry.plot <- cntry
cntry <- fortify(cntry)
cap <- spTransform(cap, CRS(newproj))
cap.df <- as.data.frame(cap)

lit.df = as.data.frame(litwsf,xy=TRUE)
lit.df$layer <- lit.df$layer/100

# write out raster
writeRaster(unlitwsfn,paste0("./maps/",i,".tif"), overwrite = TRUE)

unlitwsf.df <- as.data.frame(unlitwsfn,xy=TRUE,na.rm=TRUE)
rownames(unlitwsf.df) <- NULL
if (colnames(unlitwsf.df) == "2"){
  colnames(unlitwsf.df) <- c("layer","x","y")
}

#2. Using naive Bayes on the fully observed data
dat.all <- newdat[(!is.na(newdat$pcunlit))&(!is.na(newdat$factor)),] 
dat.all$pcdark.disc <- cut(dat.all$pcunlit,c(-.01,seq(1,99,1),100.1)) 
pr.c <- table(dat.all$factor) 
tt <- table(dat.all$factor,dat.all$pcdark.disc) 
pr.x.given.c <- (tt+.1)/apply(tt+.1,1,sum) 
#pr.x.and.c <- (tt+.1)/sum(tt+.1) 
#(pr.c.given.x <- t(pr.x.and.c)/apply(pr.x.and.c,2,sum))
bc <- t(pr.x.given.c)

#3. Using the results of naive Bayes to predict/estimate the rest
best.class <- colnames(bc)[apply(bc,1,which.max)] 

unlitwsf.df$best.class <- factor(best.class[cut(unlitwsf.df$layer,c(-.01,seq(1,99,1),100.1))],
                         levels=c('Poorer','Average','Richer'))

best.class.prob <- bc[rbind(1:(dim(bc)[1]))]  #, as.numeric(factor)

unlitwsf.df$best.class.prob <- best.class.prob[cut(unlitwsf.df$layer,c(-.01,seq(1,99,1),100.1))]
print(head(unlitwsf.df))

write.csv(unlitwsf.df,paste0("./figs/",i,".csv"))

poor <- unlitwsf.df[unlitwsf.df$best.class == "Poorer",]
avg<- unlitwsf.df[unlitwsf.df$best.class == "Average",]
rich<- unlitwsf.df[unlitwsf.df$best.class == "Richer",]

all <- rbind(poor,avg,rich)
all$best.class.map <- as.numeric(all$best.class)
all <- all[,c(1,2,6)]

wealth.class <- rasterFromXYZ(all, crs = newproj)
# write out raster
writeRaster(wealth.class,paste0("./maps/",i,"_wc.tif"), overwrite = TRUE)







#m <- ggplot()+ 
#  geom_raster(data=r.df,aes(x,y, fill = cntry), interpolate = TRUE, show.legend = TRUE, na.rm = TRUE) +
#  #scale_fill_manual(values = c("#00AFBB", "yellow", "#FC4E07" ))+
#  scale_fill_viridis_c(option = "D", name = "WSF (%)", direction = -1) +
#  theme_void()+
#  theme(aspect.ratio = 1) +
#  theme(panel.background = element_blank())
#m

#best.class.prob <- pr.c.given.x[rbind(1:(dim(pr.c.given.x)[1]))]  #, as.numeric(factor)
#(best.class.prob)

#unlitwsf.df$best.class.prob <- best.class.prob[cut(unlitwsf.df$layer,c(-.01,seq(1,100,1),100.1))]
#print(head(unlitwsf.df))




#assign(paste0("x",c),x)
c <- c+1

}

# save plots


#g <- ggarrange(p,nrow=1,ncol=1,common.legend = TRUE,legend="bottom")
#ggsave(paste0("./mapping/figure_pov_maps",unique(dat$CountryName)[i],".png"),  width=8, height=8, dpi=300)

#g <- ggarrange(x1,x2,x3,x4,nrow=2,ncol=2,labels="auto",common.legend = TRUE,legend="bottom")
#ggsave(paste0("./figs/prob_maps.png"),  width=8, height=8, dpi=300)
#ggsave(paste0("./mapping/prob_maps",unique(dat$CountryName)[i],".png"),  width=8, height=8, dpi=300)

#}