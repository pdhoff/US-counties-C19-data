This code reformats the [New York Times COVID dataset](https://github.com/nytimes/covid-19-data). Specifically, this code creates county-specific weekly time-series of new cases and new deaths. 

The files created by this code include the following:

1. An `.rds` file for a three-dimensional array, where the three dimensions represent counties, weeks and count type (cases or deaths). You can identify the levels of each of these three factors using the `dimnames` command in R. 

2. A `.csv` file giving weekly case counts by county. 

3. A `.csv` file giving weekly death counts by county. 


Notes:

*  I have disaggregated the New York City data based on the relative populations of the five boroughs. 
* I would not take the `case` data too seriously. The number of cases is a nondecreasing function of the number of tests, and reasons for and rates of testing may vary greatly by county. 


