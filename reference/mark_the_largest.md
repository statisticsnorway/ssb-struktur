# Mark units that have a large x

A function that marks the units that have the largest x-value in a data
set. Can mark the largest ones so that they cover a specified percentage
of total x (method 1), can mark values that are greater than a specified
threshold (method 2), can mark the n largest values (method 3) and can
mark the largest so a specified percent of all units are marked (method
4).

## Usage

``` r
mark_the_largest(
  data,
  idVar,
  strataVar = NULL,
  xVar,
  zVar = NULL,
  method = 1,
  par_method1 = NULL,
  par_method2 = NULL,
  par_method3 = NULL,
  par_method4 = NULL,
  max_n_method1and2 = NULL,
  min_x_method3and4 = NULL
)
```

## Arguments

- data:

  Input data set of class data.frame

- idVar:

  Name of identification variable. Should not have NA's, and should not
  have duplicates

- strataVar:

  Optional. Name of stratification variable. Should not have NA's. If
  strataVar is given, the marking is performed within each stratum

- xVar:

  Name of x-variable. Should be numeric. +/-Inf is not allowed. NA's are
  allowed (would never be marked)

- zVar:

  Optional. Name of an extra sorting variable. Should be numeric. Only
  relevant for the sorting of equal x-values, in which case the x's are
  ranked according to decreasing z-value. NA's and +/-Inf are allowed.
  (NA is rated as less than -Inf)

- method:

  The methods to be used (default is 1). Can choose between method 1, 2,
  3 and 4 (see ‘Details’), and can use multiple methods simultaneously.
  The methods are specified using a vector

- par_method1:

  Percentage for method 1 (default 25). Numeric value within the range
  \[0, 100\] (a single number or a vector with a length equal to the
  number of strata). If 0, no values are marked. If 100, all x \> 0 are
  marked (assuming max_n_method1and2 is not used)

- par_method2:

  Threshold value for method 2. Numeric value \>= 0 (a single number or
  a vector with a length equal to the number of strata). If 0, all x \>
  0 are marked (assuming max_n_method1and2 is not used)

- par_method3:

  Number for method 3 (default 5). Integer 0, 1, 2, ... (a single number
  or a vector with a length equal to the number of strata). If 0, no
  values are marked

- par_method4:

  Percentage for method 4 (default 5). Numeric value within the range
  \[0, 100\] (a single number or a vector with a length equal to the
  number of strata). If 0, no values are marked. If 100, all x != NA are
  marked (assuming min_x_method3and4 is not used)

- max_n_method1and2:

  Optional. Applies to method 1 and 2. Maximum number of markings that
  can be made. Integer 0, 1, 2, ...(a single number or a vector with a
  length equal to the number of strata)

- min_x_method3and4:

  Optional. Applies to method 3 and 4. Minimum threshold for x (only x
  \> min_x_method3and4 can be marked). Numeric (a single number or a
  vector with a length equal to the number of strata)

## Value

The output is a data frame. For each method used, a binary variable is
created that shows which units are marked (the variables are named
large1, large2, large3, and large4 for methods 1, 2, 3 and 4
respectively). Additionally, there is a variable that shows which units
are marked for at least one method (the variable is named large).

## Details

If strataVar is given, the marking is performed within each stratum.
Parameters given as a single number then apply to each stratum. If a
parameter is given as a vector, the length should equal to the number of
strata, and the order of the elements should correspond to the order
obtained when the input data is sorted by strataVar using order():
data\[order(data\[ , strataVar\]) , \]  
  
Method 1: Marks the largest x-values so that they (at least) cover a
specified percentage of the total x-value (x \< 0 are not included in
the total x-value). Only x \> 0 can be marked with this method. If
strataVar is used, this is done per stratum, and the total x-value
applies to the stratum. If max_n_method1and2 is used, it is not
guaranteed that the specified percentage will be achieved.  
  
Method 2: Marks x-values that are greater than a specified threshold (x
\> threshold). Only x \> 0 can be marked with this method. If
max_n_method1and2 is used, it's not guaranteed that all x \> threshold
will be marked.  
  
Method 3: Marks the n largest x-values. x = NA will never be marked with
this method. If strataVar is used, it's the n largest per stratum that
are marked. If min_x_method3and4 is used, it's not guaranteed that the
specified number will be marked.  
  
Method 4: Marks the largest x-values so that p percent of all units are
marked (units with x = NA are not counted in the percentage
calculation). x = NA will never be marked with this method. If strataVar
is used, the p percent largest units per stratum are marked. If
min_x_method3and4 is used, it's not guaranteed that the specified
percentage will be achieved.  
  
To ensure the same result regardless of the sorting of the input data
set, the function sorts the input data set first by idVar before further
sorting and marking is done.

## Examples

``` r
# Test dataset
set.seed(956)
testData <- data.frame(id = 1:30, x = rnorm(n = 30, mean = 1000, sd = 500),
                       strata = c(rep('A', 12), rep('B', 18)))
testData$x[sample(1:30, size = 2)] <- NA

# Example with method 1, 2 and 3
mark_the_largest(data = testData, idVar = 'id', xVar = 'x', method = c(1, 2, 3), 
                 par_method1 = 15, par_method2 = 5000, par_method3 = 5)
#>    id          x par_method1 par_method2 par_method3 large1 large2 large3 large
#> 1  28 1755.82152          15        5000           5      1      0      1     1
#> 2   3 1719.23612          15        5000           5      1      0      1     1
#> 3   1 1688.47966          15        5000           5      1      0      1     1
#> 4  24 1553.10406          15        5000           5      0      0      1     1
#> 5  17 1395.47290          15        5000           5      0      0      1     1
#> 6   4 1348.71579          15        5000           5      0      0      0     0
#> 7  30 1268.94547          15        5000           5      0      0      0     0
#> 8   5 1266.01136          15        5000           5      0      0      0     0
#> 9  14 1174.49728          15        5000           5      0      0      0     0
#> 10 13 1150.16903          15        5000           5      0      0      0     0
#> 11 23 1137.08342          15        5000           5      0      0      0     0
#> 12 12 1081.14497          15        5000           5      0      0      0     0
#> 13 22 1038.01792          15        5000           5      0      0      0     0
#> 14  2  984.35659          15        5000           5      0      0      0     0
#> 15 16  959.67966          15        5000           5      0      0      0     0
#> 16 29  914.75150          15        5000           5      0      0      0     0
#> 17 19  788.83780          15        5000           5      0      0      0     0
#> 18 11  700.85778          15        5000           5      0      0      0     0
#> 19 25  610.86377          15        5000           5      0      0      0     0
#> 20 10  601.84912          15        5000           5      0      0      0     0
#> 21 20  534.26997          15        5000           5      0      0      0     0
#> 22  8  476.92625          15        5000           5      0      0      0     0
#> 23  9  451.53607          15        5000           5      0      0      0     0
#> 24  7  422.98241          15        5000           5      0      0      0     0
#> 25  6  305.84389          15        5000           5      0      0      0     0
#> 26 18  113.40098          15        5000           5      0      0      0     0
#> 27 21  -44.53893          15        5000           5      0      0      0     0
#> 28 26  -80.36282          15        5000           5      0      0      0     0
#> 29 15         NA          15        5000           5      0      0      0     0
#> 30 27         NA          15        5000           5      0      0      0     0

# Example with stratification
mark_the_largest(data = testData, idVar = 'id', strataVar = 'strata', xVar = 'x', 
                 method = c(1, 4), par_method1 = c(20, 30), par_method4 = 25)
#>    id          x strata par_method1 par_method4 large1 large4 large
#> 1   3 1719.23612      A          20          25      1      1     1
#> 2   1 1688.47966      A          20          25      1      1     1
#> 3   4 1348.71579      A          20          25      0      1     1
#> 4   5 1266.01136      A          20          25      0      0     0
#> 5  12 1081.14497      A          20          25      0      0     0
#> 6   2  984.35659      A          20          25      0      0     0
#> 7  11  700.85778      A          20          25      0      0     0
#> 8  10  601.84912      A          20          25      0      0     0
#> 9   8  476.92625      A          20          25      0      0     0
#> 10  9  451.53607      A          20          25      0      0     0
#> 11  7  422.98241      A          20          25      0      0     0
#> 12  6  305.84389      A          20          25      0      0     0
#> 13 28 1755.82152      B          30          25      1      1     1
#> 14 24 1553.10406      B          30          25      1      1     1
#> 15 17 1395.47290      B          30          25      1      1     1
#> 16 30 1268.94547      B          30          25      0      1     1
#> 17 14 1174.49728      B          30          25      0      0     0
#> 18 13 1150.16903      B          30          25      0      0     0
#> 19 23 1137.08342      B          30          25      0      0     0
#> 20 22 1038.01792      B          30          25      0      0     0
#> 21 16  959.67966      B          30          25      0      0     0
#> 22 29  914.75150      B          30          25      0      0     0
#> 23 19  788.83780      B          30          25      0      0     0
#> 24 25  610.86377      B          30          25      0      0     0
#> 25 20  534.26997      B          30          25      0      0     0
#> 26 18  113.40098      B          30          25      0      0     0
#> 27 21  -44.53893      B          30          25      0      0     0
#> 28 26  -80.36282      B          30          25      0      0     0
#> 29 15         NA      B          30          25      0      0     0
#> 30 27         NA      B          30          25      0      0     0
```
