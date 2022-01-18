# ----------------------------------
# continent_stats.R 
# produce table of unlit stats by continent
# IIASA 24/03/2020
# ----------------------------------

library(raster)

# load unlit csv per country
unlit <- read.csv("globalunlitwsf.csv")
unlit <- na.omit(unlit)

# load country and continent borders
natearth <- shapefile('./countries/ne_50m_admin_0_sovereignty.shp')
index <- natearth$CONTINENT != "Seven seas (open ocean)"
natearth <- natearth[index,]
cont.df <- as.data.frame(natearth)
cont.df <- cont.df[,c(9,60)]
names(cont.df) <- c("Country","continent")

# merge data
new <- merge(unlit,cont.df,by="Country")

# summarize area by continent and round
new2 <- aggregate(cbind(Total_WSF = new$Total_WSF, Unlit_WSF = new$Unlit_WSF, Urb = new$wsfurb, Urbunlit = new$unlitwsfurb, Rur = new$wsfrur, Rurunlit = new$unlitwsfrur), by=list(Continent = new$continent), FUN=sum)
new2$Percent_Unlit <- round(new2$Unlit_WSF / new2$Total_WSF * 100)
new2$Percent_Unlit_Urb <- round(new2$Urbunlit / new2$Urb * 100)
new2$Percent_Unlit_Rur <- round(new2$Rurunlit / new2$Rur * 100)
new2$Total_WSF<- round(new2$Total_WSF)
new2$Unlit_WSF<- round(new2$Unlit_WSF)

# global percent unlit settlements
globalunlit <- sum(new2$Unlit_WSF) / sum(new2$Total_WSF) * 100

# print to screen
print(globalunlit)
print(new2)

# export data
write.csv(new2,file = "continents.csv")
write.csv(globalunlit, file = "globalunlit.csv")
