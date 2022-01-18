# ----------------------------------
# extract_zonal.R
# extracts footprint and light data by country
# IIASA 01/12/2021
# ----------------------------------

library(raster)
library(gdalUtils)

# manage filesize
rasterOptions(maxmemory = 1e+08, chunksize = 1e+06)
rasterOptions(tmpdir="../R")

# extract country names
natearth <- shapefile('./countries/ne_50m_admin_0_sovereignty.shp')
index <- natearth$SOVEREIGNT != "Antarctica" & natearth$SOVEREIGNT != "Greenland"
natearth <- natearth[index,]
natearth$zone <- 1:length(natearth)
c.names <- natearth[,c("zone","SOVEREIGNT")]

# load VIIRS, WSF, country raster, area
wsf <- raster("./wsf/wsfnew_all.tif")
unlit <- raster("./viirs/unlit/VIIRSunlit.vrt")
cntry <- raster("./countries/cntry_r.tif")
#a <- raster("./dhs/area.tif")

# load GHS

gdalwarp("./GHS-SMOD/GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif","./GHS-SMOD/SMOD.tif",t_srs='+proj=longlat +datum=WGS84 +no_defs',tr=c(0.004166667, 0.004166667), te=c(-180, -90,180, 90), verbose = TRUE, overwrite = TRUE, r="near", progress='text',options = c("BIGTIFF=YES", "COMPRESSION=LZW"))

p <- raster("./GHS-SMOD/SMOD.tif")

urb <- reclassify(p, c(-Inf, 10, NA, 10, 13, NA, 20, Inf, 1), progress = 'text')
rur <- reclassify(p, c(-Inf, 10, NA, 10, 13, 1, 20, Inf, NA), progress = 'text')

# build stack
s <- stack(wsf,unlit, rur, urb)
names(s) <- c("wsf","unlit","rur","urb")
s$area <- area(s)

# assign actual area
s$wsf <- s$wsf / 100 * s$area
s$unlitwsf <- s$wsf * s$unlit
s$wsf_urb <- s$wsf * s$urb
s$unlitwsf_urb <- s$wsf_urb * s$unlit
s$wsf_rur <- s$wsf * s$rur
s$unlitwsf_rur <- s$wsf_rur * s$unlit

# drop uneccessary layers from stack!!!

# zonal stats
z <- zonal(s,cntry,'sum',na.rm=TRUE,progress='text')

# create data frame and merge country names
z.df <- round(as.data.frame(z))
z.df$unlitwsfpc <- round(z.df$unlitwsf / z.df$wsf * 100)
z.df$unlitwsfpc_urb <- round(z.df$unlitwsf_urb / z.df$wsf_urb * 100)
z.df$unlitwsfpc_rur <- round(z.df$unlitwsf_rur / z.df$wsf_rur * 100)
z.df <- merge(z.df,c.names,by="zone")
#z.df <- z.df[,c(7,2,5,6)]
z.df <- z.df[,c(15,2,7,12,13,14,8,9,10,11)]
names(z.df) <- c("Country","Total_WSF","Unlit_WSF","Unlit_WSFpc","Unlit_urban_pc","Unlit_rural_pc","wsfurb","unlitwsfurb","wsfrur","unlitwsfrur")
z.df <- z.df[order(z.df$Country),]
z.df <- na.omit(z.df)

# export data
write.csv(z.df,file = "globalunlitwsf.csv")
