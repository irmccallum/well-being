# Poverty Mapping


## Steps to produce publication:

1. Download WSF - https://urban-tep.eu/#!
- (contact DLR for actual data)
2. Download VIIRS - https://eogdata.mines.edu/download_dnb_composites.html
3. Download Natural Earth Countries - https://www.naturalearthdata.com/
4. Download Indicators - 	https://data.worldbank.org/indicator
- 			https://landportal.org/book/indicator/fao-21015-6121
5. Download DHS - https://dhsprogram.com/data/


## Run the following scripts in order:

viirs_import.R – this produces VIIRS vrt by compressing file size, setting lit pixels to nodata, and unlit pixels to 1, producing global vrt.

wsf_import.R  = produces a WSF vrt, then a tif with gdal, set to same resolution as VIIRS, based on averaging the original high-res wsf pixels

unlit_rasters.R – produces tif file of wsf area per 500m pixel, and unlit wsf area per 500m pixel

cntry_rasterize.R – rasterize country polygon needed for zonal statistics with gdal

extract_zonal.R - creates country level darkness statistics – exports csv file

continent_stats.R – produces table of continent stats on unlit footprints

figure1_globe.R - plots global %unlit per country on a global map.

Figure2_stats.R – creates scatterplots of unlit vs world and FAO indicators,…
-	Exports csv file of merged datasets for validation

Figure2_validation.R - 

Figure3_country.R – plot lit/unlit building footprints for 4 select countries

DHS preprocessing – see scripts from Matt Cooper

import_dhs.R – import DHS data coming from harmonization

explore_dhs.R – reformat and visualize data

figure4_dhs.R – country level DHS boxplots
-	Also exports dataset for validation statistics
Figure4_eda_rev - 

