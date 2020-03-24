# ----------------------------------
# extract_zonal 
# extracts footprint and light data by country
# IIASA 24/03/2020
# ----------------------------------

library(raster)
library(gdalUtils)

# manage filesize
rasterOptions(maxmemory = 1e+08, chunksize = 1e+06)
rasterOptions(tmpdir="../R")

# extract country names
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$ADMIN != "Antarctica" & natearth$ADMIN != "Greenland"
natearth <- natearth[index,]
natearth$zone <- 1:length(natearth)
c.names <- natearth[,c("zone","ADMIN")]

# load VIIRS, GUF, country raster
wsf <- raster("./wsf/wsfavg.vrt")
unlit <- raster("./viirs/unlit/VIIRSunlit.vrt")
cntry <- raster("./countries/cntry_r.tif")

# build stack
s <- stack(wsf,unlit)
names(s) <- c("wsf","unlit")
s$area <- area(s,na.rm=FALSE)

# assign actual area
s$wsf <- s$wsf /255 * s$area
s$unlitwsf <- s$wsf * s$unlit

# zonal stats
z <- zonal(s,cntry,'sum',na.rm=TRUE,progress='text')

# create data frame and merge country names
z.df <- round(as.data.frame(z))
z.df$unlitwsfpc <- round(z.df$unlitwsf / z.df$wsf * 100)
z.df <- merge(z.df,c.names,by="zone")
z.df <- z.df[,c(7,2,5,6)]
names(z.df) <- c("Country","Total_WSF","Unlit_WSF","Unlit_WSFpc")
z.df <- z.df[order(z.df$Country),]

# export data
write.csv(z.df,file = "globalunlitwsf.csv")
