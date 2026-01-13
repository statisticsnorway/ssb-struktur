# Robust variance estimation Internal function for robust estimation of variance

Robust variance estimation Internal function for robust estimation of
variance

## Usage

``` r
robust_var(x_pop, x_utv, ei, hi, method = "rate")
```

## Arguments

- x_pop:

  Total sum of x variable in the population

- x_utv:

  Total sum of x variable in the sample

- ei:

  Residuals

- hi:

  Hat values

- method:

  Method to use in calculation. Default set to 'rate'

## Value

Robust variance estimates
