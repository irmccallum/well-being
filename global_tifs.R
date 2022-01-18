# -----------------------------------
# global_tifs.R
# create wsf & unlit tifs for figure 2
# IIASA, 01/04/2020
# -----------------------------------

library(raster)

# manage filesize
rasterOptions(maxmemory = 1e+08, chunksize = 1e+06)
rasterOptions(tmpdir="../R")

# load VIIRS, WSF
wsf <- raster("./wsf/wsfnew_all.tif") # adjusted to ingest full wsf product
#wsf <- setMinMax(wsf)
unlit <- raster("./viirs/unlit/viirsall/VIIRSunlit.tif")
area <- raster("./dhs/area.tif")

# build stack
s <- stack(wsf,unlit,area)
names(s) <- c("wsf","unlit","area")
#$area <- area(s,na.rm=FALSE)

# assign actual area - takes some minutes
s$wsfarea <- s$wsf / 100 * s$area
s$unlitwsf <- s$wsfarea * s$unlit

# write out all and unlit wsf
writeRaster(s$wsfarea,"./dhs/wsfall_all.tif", overwrite = T, progress = "text")
writeRaster(s$unlitwsf,"./dhs/wsfunlit_all.tif", overwrite = T, progress = "text")
