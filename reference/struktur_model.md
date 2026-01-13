# Run a struktur model

Estimates total and uncertainty for a rate, homogeneous or regression
model within strata.

## Usage

``` r
struktur_model(
  data,
  sample_data = NULL,
  id,
  x,
  y,
  strata,
  exclude = NULL,
  method = "rate"
)
```

## Arguments

- data:

  Population data frame

- sample_data:

  Sample data frame

- id:

  Name of identification variable as a string. Should be same in
  sample_data and data dataframes.

- x:

  Name of the explanatory variable.

- y:

  Name of the statistic variable.

- strata:

  Name of the strata variable.

- exclude:

  Vector of id numbers to exclude from the model. This observations will
  be included in the total with their observed values.

- method:

  Model methods to use. Default is 'rate' for a rate model. Also
  'homogen' and 'reg' for regression model will be available soon.

## Value

Data frame for whole population with mass-imputation values. Other
variables, beta estimates are also included
