## Data file locations 
fnames<-c("https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_deaths_usafacts.csv","https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv") 

## Data are cumulative counts, and the series can be nonmonotonic
## because of data revisions. This function monotonizes a time series of 
## cumulative counts, and then differences to get daily count. 
cdf2pdf<-function(s){
  y<-s
  if(length(s)>1){
    ## first monotonize the cumulative sum since it must be nondecreasing   
    y<-round(isoreg(y)$yf)
    y<-diff(c(0,y))
    names(y)<-names(s)
  }
y
}


## Two outcome variable types 
vtype<-c("Deaths","Cases") 

for(k in 1:2){ 

  ## Read in data, remove state level data
  dat<-read.csv(url(fnames[k]))  
  dat<-dat[ dat$countyFIPS!="0",] 

  ## Convert to data matrix 
  ccounts<-as.matrix(dat[,-(1:4)]  )
  fips<-as.character(dat$countyFIPS)
  fips[nchar(fips)==4]<-paste0("0",fips[nchar(fips)==4] ) 
  rownames(ccounts)<-fips
  ccounts<-t(apply(ccounts,1,cdf2pdf) )

  ## Compare to US counties in my county database 
  USCdata<-readRDS(url("https://github.com/pdhoff/US-counties-data/blob/master/UScounties.rds?raw=true")) 

  notCounty<-which( !is.element( rownames(ccounts), USCdata$fips )  ) 
  dat[ notCounty,1:4]  
  
## Missing from county database 
#    countyFIPS                        County.Name State stateFIPS X1.22.20
#96         2270           Wade Hampton Census Area    AK         2        0
#193        6000         Grand Princess Cruise Ship    CA         6        0
#562       15005                     Kalawao County    HI        15        0
#1863          1 New York City Unallocated/Probable    NY        36        0

  idx<-which(dat$County.Name=="New York City Unallocated/Probable") 
  rownames(ccounts)[idx]<-"36000"  
  fips<-rownames(ccounts) 

  ## Convert to weeks 
  dates<-sort(unique(colnames(ccounts)))
  days<-1:(7*(length(dates)%/%7))
  weeks<-1+(days-1)%/%7
  ndays<-length(days)
  mxweeks<-max(weeks) 
  weeks<-c(weeks,rep(mxweeks+1,ncol(ccounts)-ndays))
  weeks<-mxweeks+1-rev(weeks)

  ## Construct weekly count matrix 
  CCD<-NULL
  for(w in 1:mxweeks){ CCD<-cbind(CCD,apply(ccounts[,weeks==w],1,sum))  }
  rownames(CCD)<-fips 
  colnames(CCD)<-substring(dates[ seq(1,max(days),by=7)+6 ],2) 

  saveRDS(CCD,file=paste0("UScountiesC19",vtype[k],".rds")) 

  CCD<-as.data.frame(CCD) 
  CCD<-cbind(fips,CCD) 
  write.csv(CCD,file=paste0("UScountiesC19",vtype[k],".csv"),row.names=FALSE)

}
