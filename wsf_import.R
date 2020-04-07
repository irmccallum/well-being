# ----------------------------------
# wsf_import.R
# produce average vrt and tif
# IIASA 24/03/2020
# ----------------------------------

library(gdalUtils)
library(rgdal)
library(raster)

# build vrt
gdalbuildvrt(gdalfile = "./wsf/*.tif", output.vrt = "./wsf/wsfavg.vrt", verbose = TRUE, overwrite = TRUE, r = "average", tr=c(0.004166667, 0.004166667), te=c(-180, -90,180, 90), srcnodata = 'None')

# write tif - this runs overnight
gdal_translate("./wsf/wsfavg.vrt", "./wsf/wsfall/wsfall.tif", verbose = T, options = c("BIGTIFF=YES", "COMPRESSION=LZW"))
