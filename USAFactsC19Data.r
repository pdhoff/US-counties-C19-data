fnames<-c("https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_deaths_usafacts.csv","https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv") 

vtype<-c("Deaths","Cases") 

for(k in 1:2){ 


## read in data remove state level data
#dat<-read.csv("covid_deaths_usafacts.csv")  
dat<-read.csv(url(fnames[k]))  
dat<-dat[ dat$countyFIPS!="0",] 

## convert to data matrix 
cdeaths<-as.matrix(dat[,-(1:4)]  )
fips<-as.character(dat$countyFIPS)
fips[nchar(fips)==4]<-paste0("0",fips[nchar(fips)==4] ) 
rownames(cdeaths)<-fips


## convert to daily counts

## Cumulative sum to daily count 
cdf2pdf<-function(s){

  y<-s
  if(length(s)>1){
    ## first monotonize the cumulative sum since it most be nondecreasing   
    for(i in (length(s)-1):1){ s[i]<-min(s[i],s[i+1]) }
    y<-diff(c(0,s))
    names(y)<-names(s)
  }
  y
}

cdeaths<-t(apply(cdeaths,1,cdf2pdf) )


## Conform to county list 
USCdata<-readRDS(url("https://github.com/pdhoff/US-counties-data/blob/master/UScounties.rds?raw=true"))
cdeaths<-cdeaths[ is.element( rownames(cdeaths), USCdata$fips ) ,]  
fips<-rownames(cdeaths) 



## Convert to weeks 
dates<-sort(unique(colnames(cdeaths)))
days<-1:(7*(length(dates)%/%7))
weeks<-1+(days-1)%/%7
ndays<-length(days)
mxweeks<-max(weeks) 
weeks<-c(weeks,rep(mxweeks+1,ncol(cdeaths)-ndays))

CCD<-NULL
for(w in 1:mxweeks){ CCD<-cbind(CCD,apply(cdeaths[,weeks==w],1,sum))  }
 
rownames(CCD)<-fips 
colnames(CCD)<-substring(dates[ seq(1,max(days),by=7)+6 ],2) 



saveRDS(CCD,file=paste0("UScountiesC19",vtype[k],"USAF.rds")) 

Cdeaths<-as.data.frame(CCD) 
Cdeaths<-cbind(fips,Cdeaths) 
write.csv(Cdeaths,file=paste0("UScountiesC19",vtype[k],"USAF.csv"),row.names=FALSE)

}
