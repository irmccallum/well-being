# ----------------------------------
# cntry_rasterize.R 
# rasterize country vectors to common resolution
# IIASA 24/03/2020
# ----------------------------------

library(raster)
library(gdalUtils)

# load countries and clean
natearth <- shapefile("./countries/ne_50m_admin_0_countries.shp")
index <- natearth$ADMIN != "Antarctica" & natearth$ADMIN != "Greenland"
natearth <- natearth[index,]
natearth$id <- 1:length(natearth)
shapefile(natearth,filename="./countries/countries.shp",overwrite=TRUE)

# rasterize polygons
gdal_rasterize("./countries/countries.shp","./countries/cntry_r.tif",a="id",l="countries", a_nodata=0, verbose = TRUE,te=c(-180, -90,180, 90),tr=c(0.004166667, 0.004166667))
