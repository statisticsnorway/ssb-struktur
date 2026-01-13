# Rounding

Rounds according to the "round up" rule: When a number is halfway
between two others, it is rounded toward the nearest number that is away
from zero. Rounding to a negative number of digits means rounding to a
power of ten, so for example round(x, digits = -2) rounds to the nearest
hundred.

## Usage

``` r
round2(x, digits = 0)
```

## Arguments

- x:

  A vector of numbers to be rounded

- digits:

  An integer indicating the number of decimal places (default 0).
  Negative values are allowed (see 'Description')

## Value

The rounded numbers
