# ----------------------------------
# wsf_import.R
# creates vrt and tif of unlit pixels
# IIASA 22/11/2021
# ----------------------------------

library(gdalUtils)
library(rgdal)
library(raster)

r.tif <- "./wsf/WSF2015_v1_EPSG4326_PercentSettlementArea_500m.tif"

## this exports complete WSF
gdalwarp("./wsf/WSF2015_v1_EPSG4326_PercentSettlementArea_500m.tif","./wsf/wsfnew_all.tif",tr=c(0.004166667, 0.004166667), te=c(-180, -90,180, 90), verbose = TRUE, overwrite = TRUE, r="near", progress='text',options = c("BIGTIFF=YES", "COMPRESSION=LZW"))
