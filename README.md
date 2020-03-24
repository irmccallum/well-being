# Poverty Mapping

## Steps to produce publication:

1. Download WSF - https://urban-tep.eu/#! (contact DLR for actual data)
2. Download VIIRS - https://eogdata.mines.edu/download_dnb_composites.html
3. Download Countries - https://www.naturalearthdata.com/downloads/50m-cultural-vectors/ (50m scale, countries level 0) and Graticules - https://www.naturalearthdata.com/downloads/110m-physical-vectors/
4. Download Indicators -	https://data.worldbank.org/indicator and	https://landportal.org/book/indicator/fao-21015-6121 (this data no longer available - contact us if required)
5. Download DHS - https://dhsprogram.com/data/ and process/harmonize: https://github.com/mcooper/DHSwealth


## Run the following scripts in order:

Place the following scripts into a single folder, and create subdirectories titled viirs, wsf, countries, graticules and stats. Then run the following scripts:

<addr> viirs_import.R <addr> – this produces VIIRS vrt by compressing file size, setting lit pixels to nodata, and unlit pixels to 1

wsf_import.R - produces a WSF vrt, set to same resolution as VIIRS, based on averaging the original high-res wsf pixels

cntry_rasterize.R – rasterize country polygon needed for zonal statistics

extract_zonal.R - creates country level darkness statistics – exports csv file

continent_stats.R – produces table of continent stats on unlit footprints

figure1_globe.R - plots global %unlit per country on a global map and bar graph

Figure2_stats.R – creates scatterplots of unlit vs world and FAO indicators, exports merged datasets for validation

Figure2_validation.R - 

Figure3_country.R – plot lit/unlit building footprints for 4 select countries

DHS preprocessing – see scripts from Matt Cooper

import_dhs.R – import DHS data coming from harmonization

explore_dhs.R – reformat and visualize data

figure4_dhs.R – country level DHS boxplots, also exports dataset for validation statistics

Figure4_eda_rev

