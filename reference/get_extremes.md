# Get extreme values Get extreme values in the sample dataset

Get extreme values Get extreme values in the sample dataset

## Usage

``` r
get_extremes(data, id = NULL, x = NULL, y = NULL, na_rm = TRUE)
```

## Arguments

- data:

  Population data frame with additional variables from rate_model output

- id:

  Name of identification variable as a string. Should be same in sample
  and data dataframes.

- x:

  Name of the explanatory variable

- y:

  Name of the statistic variable

- na_rm:

  Logical for whether to remove NA values. Default = TRUE.

## Value

A data frame is return containing observations that have values that may
be seen as outlier/extreme values
