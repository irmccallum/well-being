# -----------------------------------
# global_area.R
# create area tif for figure 2
# IIASA, 01/02/2021
# -----------------------------------

library(raster)

# load VIIRS
unlit <- raster("./viirs/unlit/viirsall/VIIRSunlit.tif")

# create area and write
area(unlit,filename = "./dhs/area.tif",na.rm=FALSE, overwrite = T, progress = "text")
