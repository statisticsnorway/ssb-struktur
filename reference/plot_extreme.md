# Plot extreme values Plot comparison of the different extreme values using G-values or estimate comparisons.

Plot extreme values Plot comparison of the different extreme values
using G-values or estimate comparisons.

## Usage

``` r
plot_extreme(data, id = NULL, y = NULL, size = 10, type = "G", ylim = NULL)
```

## Arguments

- data:

  Data frame output from get_extreme() function

- id:

  Name of identification variable as a string.

- y:

  Name of the statistic variable.

- size:

  The number of outlier units to show. Default is 10.

- type:

  The type of plot to show. 'G' output a plot of the G values compared
  to the boundary, type 'estimate' gives a comparison in strata
  estimates with and without the observation.

- ylim:

  The upper limit to show in the plot.

## Value

Plot showing either comparison of estimates with and without observation
point or comparison of G values.
