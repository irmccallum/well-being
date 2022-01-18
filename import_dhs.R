# -----------------------------------
# import_dhs.R
# import harmonized dhs figure 2
# IIASA 28/03/2020
# -----------------------------------

# load
dhs <- read.csv("./dhs/wealth_export_efree_quintiles.csv",stringsAsFactors=T)

# extract country code
dhs$country <- substr(dhs$code,start = 1,stop = 2)

# keep only required items
#dhsnew <- dhs[,c(10:12,16:18,20:21)]


# wealth quintiles
levels(dhs$wealth_factor_harmonized_all_q5) <- c("Average","Poorer","Poorest","Richer","Richest")
levels(dhs$wealth_factor_harmonized_efree1_q5) <- c("Average","Poorer","Poorest","Richer","Richest")
levels(dhs$wealth_factor_harmonized_efree2_q5) <- c("Average","Poorer","Poorest","Richer","Richest")

# write out csv
write.csv(dhs, "./dhs/dhs_harm_mw.csv")
