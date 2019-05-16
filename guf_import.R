# ----------------------------------
# GUF - reduce file size, build vrt
# IIASA Sep,2018
# ----------------------------------

library(gdalUtils)
library(rgdal)
library(raster)

# Set workdir ---------------------- 
setwd("P:/geobene2/Spatial_data/global/GUF-DenS/GUF28_v2/GUF28_v2") 

# Get tif files --------------------
file_list <- list.files(pattern = '*.tif$') 

# Simplify GUF ---------------------
for (i in 1:length(file_list)) {
  r <- raster(file_list[i])
  r[r > 0] <- 100
  file.out <- paste("F:/guf_int1u/guf_",i,".tif",sep="")
  writeRaster(r,filename=file.out,overwrite=TRUE,progress="text",datatype="INT1U", options=c("COMPRESS=LZW"),NAflag=0)
}

# Build vrt ------------------------
setwd("F:/guf_int1u")
gdalbuildvrt(gdalfile='guf_*.tif',output.vrt = "guf.vrt",overwrite = TRUE, verbose = TRUE,resolution = "highest")
