# Poverty Mapping

UPON PUBLICATION OF THIS WORK ALL SCRIPTS WILL BE UPDATED.

## Download Data

1. WSF: data found in this publication - https://www.nature.com/articles/s41597-020-00580-5
2. VIIRS: https://eogdata.mines.edu/download_dnb_composites.html
3. Naural Earth data: Countries - https://www.naturalearthdata.com/downloads/50m-cultural-vectors/ (Admin 0 - Countries), Graticules - https://www.naturalearthdata.com/downloads/110m-physical-vectors/ and Populated Places (simple) https://www.naturalearthdata.com/downloads/10m-cultural-vectors/
4. Indicators:	https://data.worldbank.org/indicator
5. DHS: https://dhsprogram.com/data/ and process/harmonize: https://github.com/mcooper/DHSwealth


## Run the following scripts in order:

Place the following scripts into a single folder, and create subdirectories for the respective datasets downloaded above. Then run the following scripts in the order they appear below:

`viirs_import.R` – this produces VIIRS vrt and tif by compressing file size, setting lit pixels to nodata, and unlit pixels to value of 1

`wsf_import.R` - produces a reprojected tif, set to same resolution as VIIRS, using the WSF 500 m percentage layer

`global_area.R` - produces a global area raster, set to same resolution as VIIRS, in km2 units

`cntry_rasterize.R` – rasterize sovereign state polygons needed for zonal statistics

`extract_zonal.R` - creates country level darkness statistics – exports csv file

`continent_stats.R` – produces table of continent stats on unlit footprints

`figure1_globe.R` - plots global %unlit per country on a global map and bar graphs (urban and rural)

`global_tifs.R` - produce global total WSF and unlit WSF tifs by area for figure2

`import_dhs.R` – import DHS data coming from harmonization: https://github.com/mcooper/DHSwealth

`explore_dhs.R` – reformat and visualize data

`figure2_dhs.R` – country level DHS boxplots, also exports dataset for validation statistics - change continent between Africa, Asia, South and North America to produce respective graphs and tables which are used as input to 'figure2_val.Rmd'

`figure2_val.Rmd` - country level validation of DHS and unlit settlements

`figure3_maps.R` – plot maps of wealth classes for 4 select countries and export all maps as tiff files

`figure4a/b/c.R` – plots a,b,c, wealth index, SHDI and income


## SI Scripts

`figureXXX_stats_SI.R` – creates scatterplots of unlit vs World Bank and FAO indicators, exports merged datasets for validation

`figureXXX_stats_confidence_SI.R` - computes an estimate, test statitic, significance test, and confidence interval 

