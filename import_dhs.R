# -----------------------------------
# import_dhs.R
# import harmonized dhs figure 4
# IIASA 28/03/2020
# -----------------------------------

# load
dhs <- read.csv("./dhs/hh_wealth_harmonized - MW-7-2.csv")

# extract country code
dhs$country <- substr(dhs$code,start = 1,stop = 2)

# keep only required items
dhsnew <- dhs[,c(10:12,17:18,20:21)]

# write out csv
write.csv(dhsnew, "./dhs/dhs_harm_mw.csv")
