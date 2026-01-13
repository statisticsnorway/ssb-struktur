# Merge lonely strata

Merge lonely strata that are being neither surprise nor full-count
within blocks.

## Usage

``` r
merge_lonely_strata(
  data,
  sample_data = NULL,
  id,
  x,
  y,
  strata,
  exclude = NULL,
  block = NULL,
  group = NULL
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

  Name of the strata variable(s).

- exclude:

  Vector of id numbers to exclude from the model. This observations will
  be included in the total with their observed values.

- block:

  Name of variable(s) for using for blocks within which strata merge may
  take place.

- group:

  Name of variable(s) for using for groups.

## Value

Data frame for whole population with estimation strata obtained from
strata merge, and an indicator for merge (1 if merge took place, 0
otherwise).
