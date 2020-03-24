# ----------------------------------
# continent_stats - produce table of 
# unlit stats by continent
# IIASA 24/032018
# ----------------------------------

library(raster)

# load unlit csv per country
unlit <- read.csv("globalunlitwsf.csv")

# load country and continent borders
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$CONTINENT != "Seven seas (open ocean)"
natearth <- natearth[index,]
pop.df <- as.data.frame(natearth)
pop.df <- pop.df[,c(9,60)]
names(pop.df) <- c("ADMIN","continent")

# merge data
new <- merge(unlit,pop.df,by="ADMIN")

# summarize area by continent and round
new2 <- aggregate(cbind(Total_WSF = new$wsf, Unlit_WSF = new$unlitwsf), by=list(Continent=new$continent), FUN=sum)
new2$Percent_Unlit <- round(new2$Unlit_WSF / new2$Total_WSF * 100)
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
