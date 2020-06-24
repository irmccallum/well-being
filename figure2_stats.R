# ----------------------------------
# figure2_stats.R
# plot global indicators
# IIASA 23/06/2020
# ----------------------------------

library(ggplot2)
library(plyr)
library(ggrepel)
library(ggpubr)
library(raster)
library(ggthemes)
library(viridis)
library(scales)
library(ggsci)

# logit function for axis
logit <- function(x){log(x/(1-x))}
expit <- function(x){100/(1+exp(-(x)))}

# load unlit csv per Country
unlit <- read.csv("globalunlitwsf.csv")
levels(unlit$Country)[levels(unlit$Country)=="United States of America"] <- "United States"

# load gdp percap
gdp <- read.csv("./stats/gdp.csv",strip.white = TRUE,skip=4)
gdp <- gdp[,c(1,60)]
names(gdp) <- c("Country","gdp")

# load urban %
urb <- read.csv("./stats/urban.csv",strip.white = TRUE,skip=4)
urb <- urb[,c(1,60)]
names(urb) <- c("Country","urban")

# load electricity consumption
ec <- read.csv("./stats/electric_consumption.csv",strip.white = TRUE,skip=4)
ec$avg <- rowMeans(ec[58:62], na.rm=TRUE)
ec <- ec[,c(1,65)]
names(ec) <- c("Country","ec")

# load roads
r <- read.csv("./stats/landportal-FAO-21015-6121.csv",sep=";")
r <- r[r$time > 1989,]
r <- r[,c(3,6)]
r <- aggregate(r[, 2], list(r$Country.name), mean)
names(r) <- c("Country","r")
levels(r$Country)[levels(r$Country)=="United States of America"] <- "United States"

# load countries
natearth <- shapefile('./countries/ne_50m_admin_0_countries.shp')
index <- natearth$ADMIN != "Antarctica" & natearth$ADMIN != "Greenland"
natearth <- natearth[index,]

# extract population
pop.df <- as.data.frame(natearth)
pop.df <- pop.df[,c(9,36,60)]
names(pop.df) <- c("Country","population","Continent")
pop.df$population <- as.numeric(pop.df$population)
pop.df$Continent[pop.df$Continent == 'Seven seas (open ocean)'] <- NA
pop.df$Country[pop.df$Country == 'United States of America'] <- 'United States'
pop.df$Continent <- as.factor(pop.df$Continent)

# create a custom color scale
library(RColorBrewer)
myColors <- pal_lancet("lanonc")(6)
names(myColors) <- levels(pop.df$Continent)
colScale <- scale_colour_manual(name = "Continent",values = myColors)

# merge data and Continents
ec <- merge(unlit,ec,by="Country",sort=FALSE)
ec <- merge(ec,pop.df,by="Country",sort=FALSE) %>%
  na.omit()
ec <- ec[ec$Unlit_WSFpc > 0.5,]
ec <- ec[ec$Continent != "Oceania",]

r <- merge(unlit,r,by="Country",sort=FALSE)
r <- merge(r,pop.df,by="Country",sort=FALSE)
r <- r[r$Unlit_WSFpc > 0.5,]

gdp <- merge(unlit,gdp,by="Country",sort=FALSE)
gdp <- merge(gdp,pop.df,by="Country",sort=FALSE)
gdp <- gdp[gdp$Unlit_WSFpc > 0.5,]

urb <- merge(unlit,urb,by="Country",sort=FALSE)
urb <- merge(urb,pop.df,by="Country",sort=FALSE)
urb <- urb[urb$Unlit_WSFpc > 0.5,]

alldata <- merge(gdp,ec[,c("Country","ec")],by="Country",all.x=TRUE)
alldata <- merge(alldata,r[,c("Country","r")],by="Country",all.x=TRUE)
alldata <- merge(alldata,urb[,c("Country","urban")],by="Country",all.x=TRUE)

# writes data out for validation
write.csv(alldata,file="alldata.csv")

# ----------------------------------
#gdp plot

# logit transform for probs, log transform for GDP
gdp$logitWSFpc <- log(gdp$Unlit_WSFpc/100/(1-gdp$Unlit_WSFpc/100)); gdp$logitWSFpc[gdp$Unlit_WSFpc==0] <- log(0.01/.99)
gdp <- na.omit(gdp)

gp <- ggplot(gdp, aes(x=gdp, y=logitWSFpc,label=Country)) +
  geom_smooth(aes(gdp,logitWSFpc,colour=Continent,alpha=0.4), method=lm, se=FALSE) +
  geom_point(aes(color=Continent,alpha=0.4,size=population)) + 
  colScale+
  guides(alpha=FALSE)+
  geom_text_repel(color = "black", cex=3, min.segment.length = 0,
                  data = dplyr::filter(gdp, population > 200000000 | Country %in% "Nigeria" )) +
  
  labs(size = "Population (m)",
       x="GDP (int$ per capita)",
       y="Unlit settlements (%)",
       color="Continent") +
  theme(legend.position = 'none')+
  scale_size(range = c(1, 20),
             limits = c(0,5000000000),
             breaks = 1000000 * c(250, 500, 750, 1000, 1250),
             labels = c("250", "500", "750", "1000", "1250"), 
             guide = "none") +
  guides(size=guide_legend(override.aes=list(colour="grey"))) +
  scale_y_continuous(breaks=logit(c(.005,.01,.05,.5,.75)),labels=c(0.5,1,5,50,75),limits = c(logit(.005),logit(.75)))+
   scale_x_log10(labels = comma) +
  theme_classic(base_family = "Avenir")+
  theme(legend.position = "none",
        axis.line = element_line(color = "grey85"),
        axis.ticks = element_line(color = "grey85"))

# ----------------------------------
# electricty consumption plot
# logit transform for probs, log transform for GDP
ec$logitWSFpc <- log(ec$Unlit_WSFpc/100/(1-ec$Unlit_WSFpc/100)); ec$logitWSFpc[ec$Unlit_WSFpc==0] <- log(0.01/.99)

ecp <- ggplot(ec, aes(x=ec, y=logitWSFpc,label=Country,size=population)) +
  geom_smooth(aes(ec,logitWSFpc,colour=Continent), method=lm, se=FALSE) +
  geom_point(aes(color=Continent,alpha=0.5)) + 
  colScale+
  guides(alpha=FALSE)+
  geom_text_repel(color = "black", cex=3, min.segment.length = 0,
                  data = dplyr::filter(ec, population > 200000000 | Country %in% "Nigeria" )) +
  
    labs(size = "Population (M)",
       x="Electricity consumption (kWh per capita)",
       y="",
       color="Continent") +
  scale_size(range = c(1, 20),
             limits = c(0,5000000000),
             breaks = 1000000 * c(250, 500, 750, 1000, 1250),
             labels = c("250", "500", "750", "1000", "1250"), 
             guide = "none") +
  guides(size=guide_legend(override.aes=list(colour="grey"))) +
  theme_classic(base_family = "Avenir")+
  scale_x_log10(labels = comma)+
   scale_y_continuous(breaks=logit(c(.005,.01,.05,.5,.75)),labels=c(0.5,1,5,50,75),limits = c(logit(.005),logit(.75)))+
  theme(legend.position = "none",
        axis.line = element_line(color = "grey85"),
        axis.ticks = element_line(color = "grey85"))

# ----------------------------------
# roads plot
# logit transform for probs, log transform for GDP
r$logitWSFpc <- log(r$Unlit_WSFpc/100/(1-r$Unlit_WSFpc/100)); r$logitWSFpc[r$Unlit_WSFpc==0] <- log(0.01/.99)
r$logitr <- log(r$r/100/(1-r$r/100)); r$logitr[r$r==0] <- log(0.01/.99)
r$logitr[r$r==100] <- log(0.99/.01)

rp <- ggplot(r, aes(x=r, y=logitWSFpc,label=Country,size=population)) +
  geom_smooth(aes(r,logitWSFpc,colour=Continent), method=lm, se=FALSE) +
  geom_point(aes(color=Continent,alpha=0.5)) + 
  colScale+
  guides(alpha=FALSE)+
  geom_text_repel(color = "black", cex=3, min.segment.length = 0,
                  data = dplyr::filter(r, population > 200000000 | Country %in% "Nigeria" )) +
  
  labs(size = "Population (mil)",
       x="Paved roads (%)",
       y="Unlit settlements (%)",
       color="Continent") +
  scale_size(range = c(1, 20),
             limits = c(0,5000000000),
             breaks = 1000000 * c(250, 500, 750, 1000, 1250),
             labels = c("250", "500", "750", "1000", "1250"), 
             guide = "none") +
  guides(size=guide_legend(override.aes=list(colour="grey"))) +
  scale_y_continuous(breaks=logit(c(.005,.01,.05,.5,.75)),labels=c(0.5,1,5,50,75),limits = c(logit(.005),logit(.75)))+
  scale_x_log10()+
  theme_classic()+
  theme(legend.position = "none",
        axis.line = element_line(color = "grey85"),
        axis.ticks = element_line(color = "grey85"))

# ----------------------------------
# urban plot
# logit transform for probs, log transform for GDP
urb$logitWSFpc <- log(urb$Unlit_WSFpc/100/(1-urb$Unlit_WSFpc/100)); urb$logitWSFpc[urb$Unlit_WSFpc==0] <- log(0.01/.99)
urb$logitu <- log(urb$urban/100/(1-urb$urban/100)); urb$logitu[urb$urban==0] <- log(0.01/.99)
urb$logitu[urb$urban==100] <- log(0.99/.01)

u <- ggplot(urb, aes(x=urban, y=logitWSFpc,label=Country,size=population)) +
  geom_smooth(aes(urban,logitWSFpc,colour=Continent), method=lm, se=FALSE) +
  geom_point(aes(color=Continent,alpha=0.5)) + 
  colScale+
  guides(alpha=FALSE)+
  geom_text_repel(color = "black", cex=3, min.segment.length = 0,
                  data = dplyr::filter(urb, population > 200000000 | Country %in% "Nigeria" )) +
  
  labs(size = "Population (mil)",
       x="Urban population (%)",
       y="",
       color="Continent") +
  scale_size(range = c(1, 20),
             limits = c(0,5000000000),
             breaks = 1000000 * c(250, 500, 750, 1000, 1250),
             labels = c("250", "500", "750", "1000", "1250"), 
             guide = "none") +
  guides(size=guide_legend()) +
  scale_y_continuous(breaks=logit(c(.005,.01,.05,.5,.75)),labels=c(0.5,1,5,50,75),limits = c(logit(.005),logit(.75)))+
  scale_x_log10(labels = comma)+
  
  theme_classic()+
  theme(legend.position = "none",
        axis.line = element_line(color = "grey85"),
        axis.ticks = element_line(color = "grey85")+
          theme(legend.key = element_blank()) 
  )

# final plot
g <- ggarrange(gp,ecp,rp,u,common.legend = TRUE,legend = "bottom",labels = c("a","b","c","d")) 
ggsave(paste0("figure2_stats.png"),g,  width=10, height=7.5, dpi=300)
