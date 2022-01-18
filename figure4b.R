# ----------------------------------
# figure4b.R
# SHDI vs wealth index
# IIASA 22/11/2021
# ----------------------------------

library(raster)
library(ggplot2)
library(ggpubr)


rm(list=ls())

s <- shapefile("GDL Shapefiles V4.shp")
#s <- na.omit(s)
#s <- s[s$country != NA,]
s <- s[!is.na(s$country),]

s <- s[s$country == "Nigeria",]

iiasa.df <- read.csv("../figs/Nigeria.csv")
poor <- iiasa.df[iiasa.df$best.class == "Poorer",]; poor$best.class.n <- 1
avg <- iiasa.df[iiasa.df$best.class == "Average",]; avg$best.class.n <- 2
rich <- iiasa.df[iiasa.df$best.class == "Richer",]; rich$best.class.n <- 3
iiasa.df <- rbind(poor,avg,rich)

sp <- iiasa.df[,c(2:3,7)]

coordinates(sp) <- ~x+y
crs(sp) <- "+proj=robin"
newproj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 " # longlat
sp <- spTransform(sp, CRS(newproj))

hdi <- extract(s,sp, df=TRUE)

#yeh.v <- extract(yeh.r,sp, df = TRUE)
all <- cbind(iiasa.df,hdi)
#iiasa.v <- extract(iiasa.r,s, fun=mean, na.rm = TRUE, df = TRUE)


new <- over( s , sp , fn = median) 


final <- cbind(as.data.frame(s),new)
final$new <- as.factor(final$best.class.n)
levels(final$new) <- c("Poorer", "Average", "Richer")
plot(final$new, final$shdi, ylab = "SHDI")

p <- ggplot(final, aes(x=new, y=shdi)) + 
  xlab("") + ylab("SHDI")+
  geom_boxplot(notch=FALSE,outlier.shape = NA)+
  theme_bw()+
  geom_jitter(position=position_jitter(0.2), pch = 21)+
  theme(text = element_text(size=9))
p


# save plots
g <- ggarrange(p,nrow=1,ncol=1,labels=c("b"))
g
ggsave(paste0("../figs/shdi.png"),  width=2, height=2, dpi=300)


