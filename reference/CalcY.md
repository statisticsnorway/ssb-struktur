# Calculation of the estimate for the interest variable

Calculation of the estimates for the interest variable (Y) using either
a rate model (with an x variable) or simple expansion. Includes options
for calculation of level, ratio and difference statistics.

## Usage

``` r
CalcY(
  data,
  yVar,
  xVar = NULL,
  strataVar,
  sampleVar = NULL,
  estimateType = list("level", "diff", "ratio"),
  residVariance = TRUE
)
```

## Arguments

- data:

  The dataset

- yVar:

  The variable name for the interest variable (y). Eg "turnover"

- xVar:

  The name of the activity variable which relates to the interest
  variable. This is only required for estimation with a rate model. Eg
  "numberOfEmployees"

- strataVar:

  The variable used for stratification

- sampleVar:

  The variable used to identify which companies were included in the
  sample. This is used in cases where the interest variable (y variable)
  are not avaialable for the population. When a variable is specified
  here, y-values from the sample only are used to calculate s2. Default
  is NULL

- estimateType:

  The type of estimate to do. Default is set to 'level' but option for
  'diff' for a difference statistis and 'ratio' for a ratio statistic.

- residVariance:

  Whether to calculate the total based on a rate model (residVariance =
  TRUE) or not (residVariance = FALSE). This option is only available
  for level statistic calculation at the moment.

## Value

The estimates for y are returned as a vector of length equal to the
number of strata (identified in strataVar), or a dataset if several
periods are given with each column giving the estimates in each strata.

## Examples

``` r
  
# Call test dataset
  data(testData)
  
# Create stratification variable
  testData$strata1 <- paste(testData$nace3, testData$storGrp, sep="")

# Examples for level statistic
  CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
  estimateType = "level")
#>      estimate1
#> 8631     18273
#> 8632     18483
#> 8641    452226
#> 8642    630815
#> 8643    332132
#> 8731    168888
#> 8732    144185
#> 8733    165342
#> 8751    393272
#> 8752    302287
#> 8753    389940
#> 8821    224158
#> 8822    132936
#> 8823    156684
  
  CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
  estimateType = "level", residVariance = FALSE)
#>      estimate1
#> 8631     18273
#> 8632     18483
#> 8641    452226
#> 8642    630815
#> 8643    332132
#> 8731    168888
#> 8732    144185
#> 8733    165342
#> 8751    393272
#> 8752    302287
#> 8753    389940
#> 8821    224158
#> 8822    132936
#> 8823    156684
  
  CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
  sampleVar = "utv1", estimateType = "level")
#>      estimate1
#> 8631       NaN
#> 8632       NaN
#> 8641  490540.2
#> 8642  826904.2
#> 8643  209698.6
#> 8731       NaN
#> 8732  146652.5
#> 8733       NaN
#> 8751  401266.1
#> 8752  262754.0
#> 8753  274310.8
#> 8821  335517.1
#> 8822       NaN
#> 8823  166785.7
  
  CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
  sampleVar = "utv1", estimateType = "level", residVariance = FALSE)
#>      estimate1
#> 8631       NaN
#> 8632       NaN
#> 8641  607144.0
#> 8642  720298.7
#> 8643  207035.0
#> 8731       NaN
#> 8732  149181.0
#> 8733       NaN
#> 8751  388195.5
#> 8752  258957.0
#> 8753  280046.7
#> 8821  240637.2
#> 8822       NaN
#> 8823  161200.0

# Example for difference statistic
  CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
  baseVar = "y1", estimateType = "diff")
#> Warning: The following strata had an s2 that was unable to be calculated or was calculated as 0: 8631
#> The following strata had an s2 that was unable to be calculated or was calculated as 0: 8632
#> $s2
#>      8631      8632      8641      8642      8643      8731      8732      8733 
#>         0         0  26462914 100115476  37001939  27401585  74699134 148460252 
#>      8751      8752      8753      8821      8822      8823 
#>  81995071  77418240  43186923  14280010 175348271 146028180 
#> 
#> $N
#> 8631 8632 8641 8642 8643 8731 8732 8733 8751 8752 8753 8821 8822 8823 
#>    1    1   12   16   10    5    6    4   11    9   10    7    3    5 
#> 

# Example for ratio statistic
  CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
  baseVar = "y1", estimateType = "ratio")
#> Warning: The following strata had an s2 that was unable to be calculated or was calculated as 0: 8631
#> The following strata had an s2 that was unable to be calculated or was calculated as 0: 8632
#> $s2
#>      8631      8632      8641      8642      8643      8731      8732      8733 
#>         0         0  26462914 100115476  37001939  27401585  74699134 148460252 
#>      8751      8752      8753      8821      8822      8823 
#>  81995071  77418240  43186923  14280010 175348271 146028180 
#> 
#> $N
#> 8631 8632 8641 8642 8643 8731 8732 8733 8751 8752 8753 8821 8822 8823 
#>    1    1   12   16   10    5    6    4   11    9   10    7    3    5 
#> 
```
