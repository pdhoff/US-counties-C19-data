This code reformats the [USA Facts](https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/) COVID datasets. 
Specifically, this code creates county-specific weekly time-series of new cases and new deaths. 

The files created by this code include weekly case and death counts by US county (indexed by FIPS code) in `.rds` and `.csv` formats. 
I've put together some related county-level data that might be useful for analyzing these COVID data, available at (https://github.com/pdhoff/US-counties-data). These other data include county-level information on population, latitude and longitude, geographic area, demographics, etc. 


Notes:

* I do not take the `case` data too seriously. The number of cases is a nondecreasing function of the number of tests, and reasons for and rates of testing may vary greatly by county. 


