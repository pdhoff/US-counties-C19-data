This code reformats the New York Times COVID dataset, available at [https://github.com/nytimes/covid-19-data]. Specifically, this code creates county-specific weekly time-series of new cases and new deaths. 

Notes:

1. I have disaggregated the New York City data based on the relative populations of the five boroughs. 
2. I would not take the `case` data too seriously. The number of cases is a nondecreasing function of the number of tests, and reasons for and rates of testing may vary greatly by county. 


