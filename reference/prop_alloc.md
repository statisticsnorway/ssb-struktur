# Proportional allocation

An algorithm that allocates the total sample proportionally between
strata (proportional to an x-variable or to the number of units). The
algorithm takes into account any min/max per stratum and
take-all/take-none strata

## Usage

``` r
prop_alloc(
  N,
  X,
  totn,
  take_all = NULL,
  take_none = NULL,
  min_n = NULL,
  max_n = NULL,
  max_it = 1000
)
```

## Arguments

- N:

  The population size within each strata (a vector of integers)

- X:

  The X-total, per stratum, to which the allocation should be
  proportional (a vector of numbers in the range \[0, Inf)). If a
  stratum has X=0, that stratum will not be allocated samples unless the
  stratum has min_n\>0 or take_all=1. If X = N, the allocation becomes
  proportional to the number of units

- totn:

  The total desired sample size (an integer)

- take_all:

  Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum
  is a take-all stratum

- take_none:

  Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum
  is a take-none stratum

- min_n:

  Optional. Minimum sample size in each stratum. This can be a single
  integer used in all strata or a vector of integers (one for each
  stratum). NA's and 0 are allowed. Strata with take_none=1 override
  min_n. If min_n\>max_n (and take_all/take_none = 0), min_n is
  overridden by max_n

- max_n:

  Optional. Maximum sample size in each stratum. This can be a single
  integer used in all strata or a vector of integers (one for each
  stratum). NA's are allowed. Strata with take_all=1 override max_n

- max_it:

  The maximum number of iterations for the algorithm (default 1000). An
  integer (it's advisable to choose a large value)

## Value

A data frame with the variables (in addition to the input):

- n:

  Allocated sample size

- n_adjusted:

  If the algorithm managed to give exact totn, then n_adjusted=n,
  otherwise n_adjusted is an adjusted version of n so that
  sum(n_adjusted)=totn

- LU:

  Lower bounds for n, based on the input

- BU:

  Upper bounds for n, based on the input

- it_number:

  Number of completed iterations in the algorithm

## Details

It is not guaranteed that the algorithm will achieve the desired sample
size totn exactly, even with numerous iterations. In such cases, a
warning is given. However, the adjusted version of n, n_adjusted, always
gives the desired sample size.  
The allocated sample size n is independent of how the strata are ordered
in the input (i.e., a specific stratum receives the same sample size
regardless of how the input are sorted). However, n_adjusted may vary
with the sorting of the input (except when the algorithm achieve the
desired sample size totn exactly, because then n_adjusted=n).

The algorithm:  
First, calculate a value k by dividing totn by the sum of the elements
in X (k=totn/sum(X)). Then, calculate n by multiplying k with X
(n=k\*X). The elements in n are then rounded to the nearest integer and
adjusted for any constraints such as min_n/max_n or take_all/take_none.
If sum(n)=totn, the allocation is complete. If the sum of n does not
equal totn, an iterative algorithm starts: First, k is adjusted, either
by decreasing it if the sum(n)\>totn or increasing it if sum(n)\<totn.
Then n=k\*X, rounded to the nearest integer and adjusted for any
constraints. This iteration is done until sum(n)=totn or the maximum
number of iterations is reached.

## Examples

``` r
  N <- c(55, 610, 2900, 25, 1850)  # N in each strata
  X <- c(85000, 100000, 250000, 5000, 200000)  # X in each strata
  
# Total sample size of 500, allocated proportionally to X
  prop_alloc(N = N, X = X, totn = 500)
#>     n n_adjusted LB   UB    N      X it_number
#> 1  55         55  0   55   55  85000        12
#> 2  80         80  0  610  610 100000        12
#> 3 201        201  0 2900 2900 250000        12
#> 4   4          4  0   25   25   5000        12
#> 5 160        160  0 1850 1850 200000        12
  
# Total sample size of 500, allocated proportionally to the number of units (N)
  prop_alloc(N = N, X = N, totn = 500)
#>     n n_adjusted LB   UB    N    X it_number
#> 1   5          5  0   55   55   55         0
#> 2  56         56  0  610  610  610         0
#> 3 267        267  0 2900 2900 2900         0
#> 4   2          2  0   25   25   25         0
#> 5 170        170  0 1850 1850 1850         0
  
# Example with minimum and maximum number to be allocated per stratum
  max_n <- c(40, 200, 300, NA, 300)
  prop_alloc(N = N, X = X, totn = 500, min_n = 5, max_n = max_n)
#>     n n_adjusted LB  UB    N      X min_n max_n it_number
#> 1  40         40  5  40   55  85000     5    40         9
#> 2  83         83  5 200  610 100000     5   200         9
#> 3 207        207  5 300 2900 250000     5   300         9
#> 4   5          5  5  25   25   5000     5    NA         9
#> 5 165        165  5 300 1850 200000     5   300         9
  
# Example with take-all stratum and maximum number to be allocated per stratum
  take_all <- c(0, 0, 0, 1, 0)
  prop_alloc(N = N, X = X, totn = 500, max_n = 200, take_all = take_all)
#>     n n_adjusted LB  UB    N      X take_all max_n it_number
#> 1  55         55  0  55   55  85000        0   200         7
#> 2  76         76  0 200  610 100000        0   200         7
#> 3 191        191  0 200 2900 250000        0   200         7
#> 4  25         25 25  25   25   5000        1   200         7
#> 5 153        153  0 200 1850 200000        0   200         7
  
# Example where the algorithm does not give exactly the desired total sample size
  N <- c(58, 610, 2900, 15, 1850)
  X <- c(88000, 100000, 250000, 50000, 200000)
  prop_alloc(N = N, X = X, totn = 200)
#> Warning: The algorithm failed to achieve the desired sample size of 200 units. The algorithm returned a sample of 199 units.
#>   n_adjusted is an adjusted version of the allocation n, which has exactly sample size 200
#>    n n_adjusted LB   UB    N      X it_number
#> 1 26         27  0   58   58  88000      1000
#> 2 29         29  0  610  610 100000      1000
#> 3 72         72  0 2900 2900 250000      1000
#> 4 14         14  0   15   15  50000      1000
#> 5 58         58  0 1850 1850 200000      1000
```
