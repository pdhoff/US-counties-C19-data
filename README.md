US COVID-19 data
================
Peter Hoff
05 July, 2020

### Summary

The file `USC19data.r` provides a few functions to download and wrangle
the [USA
Facts](https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/)
COVID datasets. Specifically, the code can be used to quickly download
and create county- and state-specific time-series of daily and weekly
counts of incident deaths and cases.

The functions provided in [USC19data.r](USC19data.r) include

  - `pullC19data` : downloads the data, converts to incident cases, and
    generates a county x day x type array;
  - `stateify` : aggregates event counts across counties within states
    (basically, `tapply` within states);
  - `weekify` : aggregates event counts across days within weeks
    (basically, `tapply` within weeks);  
  - `fips2state` : converts a state or county FIPS codes (two- or
    five-character strings) to state abbreviations;  
  - `state2fips` : the inverse of `fips2state`
  - `cdf2pdf` : monotonizes and then differences a vector.

Comments:

  - Some of the cumulative sums in the databases are non-monotonic. The
    `pullC19data` first monotonizes them, then takes differences to get
    daily event counts (incident events), using the `cdf2pdf` function.

  - The USA Facts database includes an entry for “New York City
    Unallocated/Probable”. I have given this a FIPS code of 36000 (36 is
    the FIPS code of New York State). Similarly, data from the Grand
    Princess Cruise Ship is allocated to California, and given the FIPS
    code 06000 (06 is the FIPS code of California).

  - I’ve put together some related county-level data that might be
    useful for analyzing these COVID data, available at
    <https://github.com/pdhoff/US-counties-data>. These other data
    include county-level information on population, latitude and
    longitude, geographic area, demographics, etc.

### How to use

Load in the functions and see what they are:

``` r
source("USC19data.r")

objects()
```

    ## [1] "cdf2pdf"     "fips2state"  "pullC19data" "state2fips"  "stateify"   
    ## [6] "weekify"

Pull in daily data for each county:

``` r
Y<-pullC19data()

dim(Y) 
```

    ## [1] 3195  164    2

``` r
dimnames(Y)[[1]][1:5] 
```

    ## [1] "01000" "01001" "01003" "01005" "01007"

``` r
dimnames(Y)[[2]][1:5] 
```

    ## [1] "2020-01-22" "2020-01-23" "2020-01-24" "2020-01-25" "2020-01-26"

``` r
dimnames(Y)[[3]]
```

    ## [1] "deaths" "cases"

Save data for posterity:

``` r
saveRDS(Y,file="USC19data.rds") 
```

Now aggregate by state:

``` r
X<-stateify(Y) 

dim(X) 
```

    ## [1]  51 164   2

``` r
dimnames(X)[[1]][1:5] 
```

    ## [1] "AL" "AK" "AZ" "AR" "CA"

``` r
dimnames(X)[[2]][1:5]
```

    ## [1] "2020-01-22" "2020-01-23" "2020-01-24" "2020-01-25" "2020-01-26"

``` r
dimnames(X)[[3]]
```

    ## [1] "deaths" "cases"

Aggregate by week:

``` r
WY<-weekify(Y) 

dim(WY) 
```

    ## [1] 3195   22    2

``` r
dimnames(WY)[[1]][1:5]
```

    ## [1] "01000" "01001" "01003" "01005" "01007"

``` r
dimnames(WY)[[2]][1:5]
```

    ## [1] "2020-01-26" "2020-02-02" "2020-02-09" "2020-02-16" "2020-02-23"

``` r
dimnames(WY)[[3]]
```

    ## [1] "deaths" "cases"

We should have weekify(stateify(Y)) = stateify(weekify(Y)):

``` r
all( stateify(WY) == weekify(X) )
```

    ## [1] TRUE

### Some demonstrations

  - [Simple summaries and plots](demo1.md)
  - [Incorporating geographic and other county and state
    information](demo2.md)
  - [Weekly death and case rates for US and states](demo3.md)
