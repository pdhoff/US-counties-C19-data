US COVID-19 summary statistics
================
Peter Hoff
07 July, 2020

Get data:

``` r
source("https://raw.githubusercontent.com/pdhoff/US-counties-C19-data/master/USC19data.r")

C19data<-pullC19data()
```

Data for Durham County, NC:

``` r
dnc<-C19data["37063",,] 
tail(dnc) 
```

    ##            deaths cases
    ## 2020-07-01      0    78
    ## 2020-07-02      2    78
    ## 2020-07-03      2   110
    ## 2020-07-04      1    52
    ## 2020-07-05      1    47
    ## 2020-07-06      0    68

Get weekly totals for each state:

``` r
Y<-weekify(stateify(C19data)) 
dim(Y) 
```

    ## [1] 51 23  2

Deaths per cases plot for some states I’ve lived in:

``` r
phstates<-c("MI","NY","IN","WI","WA","NC") 

matplot( t(Y[phstates,,1]/Y[phstates,,2]), 
         type="l",lty=1,lwd=2,ylab="deaths per case",xlab="week")

legend(0,.15,lwd=2,col=1:length(phstates),legend=phstates,bty="n") 
```

![](demo1_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->
