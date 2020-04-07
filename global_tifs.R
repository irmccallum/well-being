# -----------------------------------
# global_tifs.R
# create wsf & unlit tifs for figure 4
# IIASA, 01/04/2020
# -----------------------------------

library(raster)

# load VIIRS, WSF
wsf <- raster("./wsf/wsfall/wsfall.tif")
unlit <- raster("./viirs/unlit/viirsall/VIIRSunlit.tif")

# build stack
s <- stack(wsf,unlit)
names(s) <- c("wsf","unlit")
s$area <- area(s,na.rm=FALSE)

# assign actual area - takes some minutes
s$wsf <- s$wsf /255 * s$area
s$unlitwsf <- s$wsf * s$unlit

# write out all and unlit wsf
writeRaster(s$wsf,"./dhs/wsfall.tif", overwrite = T, progress = "text")
writeRaster(s$unlitwsf,"./dhs/wsfunlit.tif", overwrite = T, progress = "text")
