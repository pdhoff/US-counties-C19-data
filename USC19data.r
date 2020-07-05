cdf2pdf<-function(s){ 
  ## Monotonize and convert to incident events
  y<-s
  if(length(s)>1){
    ## first monotonize the cumulative sum since it must be nondecreasing   
    y<-round(isoreg(y)$yf)
    y<-diff(c(0,y))
    names(y)<-names(s)
  }
y
}


pullC19data<-function()
{ 

  # Download USA Facts C19 data
  # Convert to incident cases
  # Put in array form and supply appropriate dimension names 

  usfDeaths<-read.csv(url("https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_deaths_usafacts.csv"))  

  usfCases<-read.csv(url("https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv")) 

  ## 2020-06-30: county names are inconsistent, but FIPS ok
  dregions<-usfDeaths[,c(1,3,4)]  
  cregions<-usfCases[,c(1,3,4)] 
  if(!all(dregions==cregions)){ cat("Warning: inconsistent region","\n") }

  Deaths<-as.matrix(usfDeaths[,-(1:4)])
  Cases<-as.matrix(usfCases[,-(1:4)])

  ## 2020-07-02: extra column in cases database 
  ccolnames<-intersect( colnames(Deaths),colnames(Cases) )
  Deaths<-Deaths[,match(ccolnames,colnames(Deaths))] 
  Cases<-Cases[,match(ccolnames,colnames(Cases))] 
  

  DCcumulative<-array(dim=c(dim(Deaths),2)) 
  DCcumulative[,,1]<-Deaths 
  DCcumulative[,,2]<-Cases   
  DCincident<-aperm(apply(DCcumulative,c(1,3),cdf2pdf),c(2,1,3))

  ##  fix FIPS 
  fips<-dregions$countyFIPS 
  fips[nchar(fips)<4]<-paste0(dregions$stateFIPS[nchar(fips)<4],c("000")) 
  fips[nchar(fips)==4]<-paste0("0",fips[nchar(fips)==4]) 

  dimnames(DCincident)[[1]]<-fips
  dimnames(DCincident)[[3]]<-c("deaths","cases")  
  dimnames(DCincident)[[2]]<-as.character(lubridate::mdy(substring(colnames(Deaths),2)))

  DCincident    
}

fips2state<-function(fips)
{ 
  fips<-as.numeric(substr(fips,1,2))

  sFIPS<-c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56) 

  sNAMES<-c('AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
 
   sNAMES[ match( substr(fips,1,2), sFIPS ) ] 
}



state2fips<-function(state)
{ 
  
  sFIPS<-c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)
  
  sNAMES<-c('AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
   
   sFIPS[ match( state, sNAMES ) ]
}





stateify<-function(Y,UStotal=FALSE){ 
  # tapply sum within states  
  # add US totals at the bottom if requested 
  stateFIPS<-substr(dimnames(Y)[[1]],1,2) 
  X<-apply(Y,c(2,3),function(x){ tapply(x,stateFIPS,sum) })
  dimnames(X)[[1]]<-fips2state(dimnames(X)[[1]])  

  if(UStotal)
  { 
    ust<-apply(X,c(2,3),sum)
    tmp<-array(dim=dim(X)+c(1,0,0))
    tmp[1:dim(X)[1],,]<-X
    tmp[dim(X)[1]+1,,]<-ust
    dimnames(tmp)[[1]]<-c(dimnames(X)[[1]],"US")
    dimnames(tmp)[[2]]<-dimnames(X)[[2]]
    dimnames(tmp)[[3]]<-dimnames(X)[[3]]
    X<-tmp 
  }

  X
}


weekify<-function(Y){ 
  # tapply sum within epiweeks   

  dates<-dimnames(Y)[[2]]  
  days<-weekdays(lubridate::ymd(dates)) 
  firstSun<-min(which(days=="Sunday")) 
  lastSat<-max(which(days=="Saturday")) 

  YT<-Y[,firstSun:lastSat,] 
  datesT<-dates[firstSun:lastSat] 

  weeks<- (1:ncol(YT) -1 ) %/%7 + 1 
  W<-aperm(apply(YT,c(1,3),function(x){ tapply(x,weeks,sum) } ) ,c(2,1,3) )
  dimnames(W)[[2]]<-as.character(datesT[seq(1,length(datesT),by=7)]  )

  W
} 


