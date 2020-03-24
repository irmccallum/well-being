# ----------------------------------
# wsf_import - build vrt
# produces 500m average wsf
# IIASA 24/03/2020
# ----------------------------------

# download wsf data ----------------
# see Readme

library(gdalUtils)
library(rgdal)
library(raster)

# build vrt
gdalbuildvrt(gdalfile = "./wsf/*.tif", output.vrt = "./wsf/wsfavg.vrt", verbose = TRUE, overwrite = TRUE, r = "average", tr=c(0.004166667, 0.004166667), te=c(-180, -90,180, 90), srcnodata = 'None')
