# Poverty Mapping

## Download Data

1. WSF: data found in this publication - https://www.nature.com/articles/s41597-020-00580-5
2. VIIRS: https://eogdata.mines.edu/download_dnb_composites.html
3. Naural Earth data: Countries - https://www.naturalearthdata.com/downloads/50m-cultural-vectors/ (Admin 0 - Countries), Graticules - https://www.naturalearthdata.com/downloads/110m-physical-vectors/ and Populated Places (simple) https://www.naturalearthdata.com/downloads/10m-cultural-vectors/
4. Indicators:	https://data.worldbank.org/indicator
5. DHS: https://dhsprogram.com/data/ and process/harmonize: https://github.com/mcooper/DHSwealth


## Run the following scripts in order:

Place the following scripts into a single folder, and create subdirectories for the respective datasets downloaded above. Then run the following scripts in the order they appear below:

`viirs_import.R` – this produces VIIRS vrt and tif by compressing file size, setting lit pixels to nodata, and unlit pixels to 1

`wsf_import.R` - produces a WSF vrt and tif, set to same resolution as VIIRS, based on averaging the original high-res wsf pixels (the creation of the new global tif currently is slow - working to improve speed)

`cntry_rasterize.R` – rasterize sovereign state polygons needed for zonal statistics

`extract_zonal.R` - creates country level darkness statistics – exports csv file (this script runs slowly)

`continent_stats.R` – produces table of continent stats on unlit footprints

`figure1_globe.R` - plots global %unlit per country on a global map and bar graph

`figure2_stats.R` – creates scatterplots of unlit vs world and FAO indicators, exports merged datasets for validation

`figure2_stats_confidence.R` - computes an estimate, test statitic, significance test, and confidence interval 

`figure3_maps.R` – plot maps of lit/unlit building footprints for 4 select countries

`global_tifs.R` - produce global total WSF and unlit WSF tifs by area for figure 4

`import_dhs.R` – import DHS data coming from harmonization: https://github.com/mcooper/DHSwealth

`explore_dhs.R` – reformat and visualize data

`figure4_dhs.R` – country level DHS boxplots, also exports dataset for validation statistics - change continent between Africa, Asia and North America to produce respective graphs and tables which are used as input to 'figure4_val.Rmd'

`figure4_val.Rmd` - country level validation of DHS and unlit settlements

