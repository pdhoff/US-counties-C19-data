## Create weekly time series for each county in the US.



## Source: https://github.com/nytimes/covid-19-data
c19data<-read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv",colClasses=rep(c("character","integer"),c(4,2)) )



## Unglom the NYC data 
nycdata<-c19data[ c19data$county=="New York City",]   
c19data<-c19data[ c19data$county!="New York City",] 




## NYC boroughs 
bnyc<-c("Kings County","Queens County","New York County","Bronx County","Richmond County") 
fnyc<-c("36047","36081","36061","36005","36085") 
pnyc<-c(2559903,2253858,1628706,1418207,476143)  
wnyc<-pnyc/sum(pnyc) 

for(i in 1:length(wnyc)){  
 
  tmp<-data.frame(date=nycdata$date,county=bnyc[i],state="New York",
                  fips=fnyc[i],
                  cases=round(nycdata$cases*wnyc[i]),
                  deaths=round(nycdata$deaths*wnyc[i]) ) 

  c19data<-rbind(c19data,tmp) 
}

## Check
nycdata2<-c19data[ is.element(c19data$county,bnyc),] 
sum( tapply(nycdata2$cases,nycdata2$county,max)  )
sum( tapply(nycdata2$deaths,nycdata2$county,max)  )
apply(nycdata[,c("cases","deaths")],2,max) 



## Days and weeks 
dates<-sort(unique(c19data$date))
days<-1:(7*(length(dates)%/%7)) 
weeks<-1+(days-1)%/%7
ndays<-length(days) 



## Weekly data for each county
fips<-sort(unique(c19data$fips))
fips<-fips[nchar(fips)==5] 



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



## County case and death data 
CCD<-array(0,dim=c(max(weeks),2,length(fips))) 
for(i in seq_along(fips)){

  cdata<-c19data[ c19data$fips==fips[i],,drop=FALSE]     
  cdata<-cdata[ match(cdata[,"date"],dates)<=max(days) ,,drop=FALSE]

  if(nrow(cdata)>0){  

    ## convert cumulative totals to daily counts 
    Y<-matrix(apply(cdata[,c("cases","deaths")],2,cdf2pdf), 
         nrow=nrow(cdata),ncol=2) 

    ## convert daily counts to weekly counts
    w<-weeks[ match(cdata[,"date"], dates) ]
    wcases<-tapply(Y[,1],w,sum) 
    wdeaths<-tapply(Y[,2],w,sum) 
    CCD[as.numeric(names(wcases)),1,i]<-wcases
    CCD[as.numeric(names(wdeaths)),2,i]<-wdeaths
  }
}



## Check  
for(i in seq_along(fips)){

  cdata<-c19data[ c19data$fips==fips[i],,drop=FALSE]
  cdata<-cdata[ match(cdata[,"date"],dates)<=max(days),,drop=FALSE] 
  cdsum<-cdata[nrow(cdata),c("cases","deaths")]   
  if(nrow(cdsum)==0){ cdsum<-c(0,0) }  
 
  if(!all(cdsum==apply(CCD[,,i],2,sum))){
     cat(i,"\n") 
  }
}



## Attach dimension names 
dimnames(CCD)[[1]]<-dates[ seq(1,max(days),by=7)+6 ] 
dimnames(CCD)[[2]]<-c("cases","deaths") 
dimnames(CCD)[[3]]<-fips 
CCD<-aperm(CCD,c(3,1,2)) 



## Add in zeros for counties not in dataset (assumption!)  
#USCdata<-readRDS("UScounties.rds")  
USCdata<-readRDS(url("https://github.com/pdhoff/US-counties-data/blob/master/UScounties.rds?raw=true"))

all(is.element(dimnames(CCD)[[1]],USCdata$fips) )

zeroFIPS<-USCdata$fips[ !is.element(USCdata$fips,dimnames(CCD)[[1]]) ] 

nNYT<-dim(CCD)[1] 
nTOT<-nNYT + length(zeroFIPS) 

CCDALL<-array(0,dim=c(nTOT,dim(CCD)[2],dim(CCD)[3] ) )
CCDALL[1:nNYT,,]<-CCD
dimnames(CCDALL)[[1]]<-c(dimnames(CCD)[[1]],as.character(zeroFIPS)) 
dimnames(CCDALL)[[2]]<-dimnames(CCD)[[2]]
dimnames(CCDALL)[[3]]<-dimnames(CCD)[[3]] 

CCDALL<-CCDALL[ order(as.character(dimnames(CCDALL)[[1]]))  ,,]



saveRDS(CCDALL,file="UScountiesC19.rds")

fips<-dimnames(CCDALL)[[1]] 

Ccases<-as.data.frame(CCDALL[,,1] ) 
Ccases<-cbind(fips,Ccases)

Cdeaths<-as.data.frame(CCDALL[,,2] ) 
Cdeaths<-cbind(fips,Cdeaths)


write.csv(Ccases,file="UScountiesC19Cases.csv",row.names=FALSE) 
write.csv(Cdeaths,file="UScountiesC19Deaths.csv",row.names=FALSE)



