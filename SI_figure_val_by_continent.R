#---
#title: "SI_figure_val_by_continent.Rmd"
#author: "Elena Moltchanova"
#modified by: "IIASA"
#date: "11 September 2019"
#modified on: "06 April 2021"
#output:
#  pdf_document: default
#  html_document: default
#---

# Loading the data
#```{r}
rm(list=ls())
datall <- read.csv("./dhs/figure2data_rev_all.csv")
datall$factor <- factor(datall$factor_ef1,levels=c('Poorer','Average','Richer'),ordered=T)

uncert <- data.frame()


for (c in 1:length(unique(datall$Continent))){
  dat2 <- datall[datall$Continent == unique(datall$Continent)[c],]
  
  
for (r in 1:length(unique(datall$urban_rural))){

  
dat <- dat2[dat2$urban_rural == unique(dat2$urban_rural)[r],]


# Naive Bayes

#Using Naive Bayes to classify the observations based on the Bayes' formula:

#$$
#Pr(Class C|x) = \frac{Pr(x|\textrm{Class C})Pr(\textrm{Class C})}{\sum_c Pr(x|\textrm{Class c})Pr(\textrm{Class c})}
#$$
#We need probabilities for classes, which can be obtained from the data. And $Pr(x|c)$ which is usually obtained by discretising $X$ and evaluating contingency table from the data. A small correction is added to all counts to avoid division by 0.
##
#```{r}
dat$pcunlit.disc <- cut(dat$pcunlit,c(-.01,seq(10,90,10),100.1))
pr.c <- table(dat$factor)
tt <- table(dat$factor,dat$pcunlit.disc)
pr.x.given.c <- (tt+.1)/apply(tt+.1,1,sum)
pr.x.and.c <- (tt+.1)/sum(tt+.1)
pr.c.given.x <- t(pr.x.and.c)/apply(pr.x.and.c,2,sum)
#```

#We can use the last table to choose the most likely class for each x (i.e. % unlit)
#```{r}
best.class <- colnames(pr.c.given.x)[apply(pr.c.given.x,1,which.max)]
#```
#. . . and apply this to the data

#```{r}
dat$est <- factor(best.class[as.numeric(dat$pcunlit.disc)],levels=levels(dat$factor))
(tt1 <- table(dat$factor,dat$est))
#```

#```{r}
round(sum(diag(tt1))/sum(tt1),3)*100
#```

#To get category specific accuracies:

#```{r}
(acc.class.spec <- round(diag(tt1)/apply(tt1,1,sum),3)*100)
#```

#The accuracy should be evaluated based on cross validation. Since this is a large
#data set, let's do 10-fold xv.

# Accuracy based on cross-validation
#```{r}
xv <- function(DAT,dd=10){
ind <- sample(1:10,size=dim(DAT)[1],replace=T)
tt1 <- array(0,dim=c(3,3))
DAT$pcunlit.disc <- cut(DAT$pcunlit,c(-.01,seq(dd,100-dd,dd),100.1))
for(j in 1:10){
dat.tmp <- DAT[ind!=j,]
# evaluating conditional probabilities from the training data
pr.c <- table(dat.tmp$factor)
tt <- table(dat.tmp$factor,dat.tmp$pcunlit.disc)
pr.x.given.c <- (tt+.1)/apply(tt+.1,1,sum)
pr.x.and.c <- (tt+.1)/sum(tt+.1)
pr.c.given.x <- t(pr.x.and.c)/apply(pr.x.and.c,2,sum)
best.class <- colnames(pr.c.given.x)[apply(pr.c.given.x,1,which.max)]
2
# using the above information on the testing data
est <- factor(best.class[as.numeric(DAT$pcunlit.disc[ind==j])],levels=levels(dat.tmp$factor))
(tt1 <- tt1+table(DAT$factor[ind==j],est))
}
return(tt1)
}
#```

#country-wise (note, will take a while for the very small dd!)
#```{r}
country.list <- levels(as.factor(dat$country))
fullcountry.list <- levels(as.factor(dat$CountryName))
fullcountry.list <- fullcountry.list[fullcountry.list != "All countries"]
acc.class.spec.country <- array(dim=c(length(country.list),3))
acc.overall.country <- numeric(length(country.list))
for(j in 1:length(country.list)){#print(j)
tt1 <- xv(DAT=dat[dat$country==country.list[j],],dd=.01)
acc.overall.country[j] <- round(sum(diag(tt1))/sum(tt1),3)*100
acc.class.spec.country[j,] <-round(diag(tt1)/apply(tt1,1,sum),3)*100
}
tt1 <- xv(DAT=dat[],dd=.01)
acc.overall.country <- c(acc.overall.country,round(sum(diag(tt1))/sum(tt1),3)*100)
#acc.class.spec.country <- rbind(acc.class.spec.country,round(diag(tt1)/apply(tt1,1,sum),3)*100)
#```

# The resulting accuracies
#```{r}
acc.all <- cbind(acc.class.spec.country,acc.overall.country)
colnames(acc.all) <- c(levels(dat$factor),'Overall')
#rownames(acc.all) <- c(country.list)#, 'All')
#rownames(acc.all) <- c(fullcountry.list)#, 'All')
print(acc.all)
newacc <- as.data.frame(acc.all)
meanp <- round(mean(newacc$Poorer,na.rm = TRUE),1)
meana <- round(mean(newacc$Average, na.rm = TRUE),1)
meanr <- round(mean(newacc$Richer,na.rm = TRUE),1)
meano <- round(mean(newacc$Overall),1)
avg <- c(meanp,meana,meanr,meano)
final <- rbind(newacc,avg)
rownames(final) <- c(fullcountry.list, 'All')
write.csv(final,paste0(unique(dat$Continent)[1],"cont_val.csv"))
#(final)

#(unique(dat$urban_rural))
#(meano)
row <- cbind(unique(dat$Continent),unique(dat$urban_rural),meano)
uncert <- rbind(uncert, row)


}
}
#uncert$Continent <- unique(dat$Continent)
names(uncert) <- c("Continent","Type","Accuracy")
(uncert)


