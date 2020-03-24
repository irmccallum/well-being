# ----------------------------------
# viirs_import - reduce size, build vrt
# creates a 500m raster of unlit pixels
# IIASA 24/03/2020
# ----------------------------------

library(gdalUtils)
library(rgdal)
library(raster)

# download VIIRS -------------------
# see Readme

# get tif files --------------------
file_list <- list.files(path = "./viirs", pattern = "*.tif$",full.names = TRUE) 

# Write raster ---------------------
for (i in 1: length(file_list)) {
  r <- raster(file_list[i])
  r <- reclassify(r, c(-Inf, 0, 1, 0, Inf, 0))
  file.out <- paste0("./viirs/unlit/NLInt", i, ".tif", sep="")
  writeRaster(r, filename=file.out, overwrite=TRUE, progress="text", datatype="INT1U", options=c("COMPRESS=LZW"), NAflag=0)
}

# write vrt -----------------------
gdalbuildvrt(gdalfile=paste0("./viirs/unlit/*.tif"), output.vrt = paste0("./viirs/unlit/VIIRSunlit.vrt"), overwrite=TRUE, verbose = TRUE, te = c(-180, -90, 180, 90), tr = c(0.004166667, 0.004166667))
