# ----------------------------------
# viiRS_import - reduce size, build vrt
# IIASA Sep,2018
# ----------------------------------

library(gdalUtils)
library(rgdal)
library(raster)

# Download VIIRS -------------------
# https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html

# Set paths ------------------------
file.in <- "P:/geobene2/Spatial_data/global/VIIRS/2015/vcm-ntl"

# Get tif files --------------------
file_list <- list.files(path = file.in, pattern = "*.tif$") 

# Write raster ---------------------
for (i in 1: length(file_list)) {
  r <- raster(file_list[i])
  r <- reclassify(r, c(-Inf, 0, 1, 0, Inf, 0))
  file.out <- paste0(file.in,"/dark/NLInt", i, ".tif", sep="")
  writeRaster(r, filename=file.out, overwrite=TRUE, progress="text", datatype="INT1U", options=c("COMPRESS=LZW"), NAflag=0)
}

gdalbuildvrt(gdalfile=paste0(file.in,"/dark/*.tif"), output.vrt = paste0(file.in,"/dark/VIIRSdark.vrt"), overwrite=TRUE, verbose = TRUE, te = c(-180, -90, 180, 90), tr = c(0.004166667, 0.004166667))
