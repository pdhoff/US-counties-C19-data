## -- Load data

#### -- County death counts
CCdata<-readRDS(url("https://github.com/pdhoff/US-counties-C19-data/blob/master/UScountiesC19Deaths.rds?raw=true")) 

#### -- US counties information 
USCdata<-readRDS(url("https://github.com/pdhoff/US-counties-data/blob/master/UScounties.rds?raw=true"))


## -- State specific death rates

#### -- County totals 
ctotal<-apply(CCdata,1,sum)

#### -- State totals and rate
stotal<-tapply(ctotal,USCdata$state,sum)
spop<-tapply(USCdata$pop,USCdata$state,sum) 
srate<-stotal/spop 
  
plot(sort(srate*10000),type="n",xaxt="n",xlab="",ylab="death rate x 10000")
text(rank(srate*10000),srate*10000,names(srate),srt=45,cex=.6) 

## -- rates versus population density 
plot( log(USCdata$population/USCdata$area), asin(sqrt(ctotal/USCdata$population )))


## -- Map 
crate<-ctotal/USCdata$population 
plot(USCdata$longitude,USCdata$latitude, cex=sqrt(crate/max(crate)),
     xlab="longitude",ylab="latitude")

#### -- Lower 48 
plot(USCdata$longitude,USCdata$latitude, cex=sqrt(crate/max(crate)),
     xlim=c(-125,-65),ylim=c(23,50), xlab="longitude",ylab="latitude")



