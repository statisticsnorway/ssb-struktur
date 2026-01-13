# Optimal allocation of sample sizes

This function finds an optimal allocation by filling up strata one unit
at a time. This approach works when the variance function of n decreases
smoothly (The derivative should be strictly increasing).

## Usage

``` r
FSmatrix(s2, N, ...)

FStotnAlloc(s2, N, totn, ...)

FSvarAlloc(s2, N, varLimits, group, ...)

FScvAlloc(s2, N, totY, cvLimits, group, ...)

FScvAlloc2(s2, N, totYgroup, cvLimits, group, ...)

FSvarLimits(totY, cvLimits, group, ...)

FStotVar(s2, N, min_n, group, ...)

FStotCV(s2, N, totY, min_n, group, ...)

FillStrata(
  s2,
  N,
  totVar = function(s2, n, N) {
s2 * N * (N - n)/n
 },
  nullcorrection = 1e+20,
  totn = min(sum(max_n_exact), 20000),
  min_n = NULL,
  use_n = NULL,
  corrSumVar = FALSE,
  dotprint = totn > 1000,
  varLimits = NULL,
  group = rep("All", length(s2)),
  intern = FALSE,
  max_n = N,
  totY = NULL,
  cvLimits = NULL,
  totYgroup = NULL,
  groupNames = NULL,
  returnGroupN = FALSE,
  returnGroupn = FALSE,
  returnTable = FALSE,
  returnTotYgroup = FALSE,
  returnVarLimits = FALSE,
  returnMulti = FALSE,
  returnMatrix = FALSE,
  totnGroup = NULL,
  min_nGroup = NULL
)
```

## Arguments

- s2:

  An estimate for the variance within each strata. For example s2 =
  c(35, 3, 2, 30, 7)

- N:

  The population size within each strata. For example N = c(100, 100,
  500, 50, 150)

- ...:

  Additional arguments to be passed to the function.

- totn:

  The total desired sample size

- varLimits:

  The desired maximum variance for each group. Note: When varLimits is
  given, a different output value is returned - the sample size that
  fulfills the required group variance for totVar. If varLimits = Inf,
  the output is the group sum of totVar with "n = min_n".

- group:

  A vector or dummy matrix giving the groups to be used with varLimits

- totY:

  Estimate of total Y in each stratum.

- cvLimits:

  The desired maximum CV for each group. This can be a single value or a
  vector of values.

- totYgroup:

  Estimate of total Y in each group. Alternative instead of totY.

- min_n:

  A minimum sample size in each stratum. This can be a single number
  used in all strata or a vector of numbers (one for each stratum).

- totVar:

  The function for calculating the total variance from s2, n (sample
  size) and N as inputs. The function should be able to handle vectors
  as inputs and give a vector as an output.

- nullcorrection:

  Variance at n=0 is set to nullcorrection times variance at n=1. A
  large value is needed by the algorithm (not Inf).

- use_n:

  Matrix with the same number of columns as there are strata. Each
  column should contain the desired sample size choices (will accept
  missing values)

- corrSumVar:

  Logical value giving if the corrected variance should be used. Default
  is FALSE.

- dotprint:

  Condition to invoke printing of "———#——–...." during calculations.
  Default is set for when totn \> 1000.

- intern:

  Logical value giving if the function is being used internally within
  this or another function or not. Default is set to FALSE.

- max_n:

  A maximum sample size in each stratum. This can be a single number
  used in all strata or a vector of numbers (one for each stratum).

- groupNames:

  Alternative instead of finding group names from other input.

- returnGroupN:

  Logical on whether to return the population group size.

- returnGroupn:

  Logical on whether to return the sample group size.

- returnTable:

  Logical on whether to return the table

- returnTotYgroup:

  Logical on whether to return the total Y values

- returnVarLimits:

  Logical on whether to return the Y limits

- returnMulti:

  Logical on whether to return the multi

- returnMatrix:

  Logical on whether to return the matrix

- totnGroup:

  Maximal total sample size within group (override cvLimits)

- min_nGroup:

  Minimal total sample size within group (override cvLimits)

## Value

The output from **FSmatrix** (FillStrata with returnMatrix=TRUE) is a
two-dimensional list.

- Column:Strata:

  Output values according to each strata.

- Column:Group:

  Output values according to each group as specified by input.

- Column:All:

  Output by treating all strata as a single group.

- Row:n:

  Allocated sample size

- Row:N:

  Population size

- Row:totVar:

  Total variance

- Row:totY:

  Total Y

- Row:cv:

  CV (%)

- Row:varLimits:

  As input (only Group)

- Row:cvLimits:

  As input or computed from varLimits (only Group)

The output from **FillStrata** is a list with two elements when
varLimits or cvLimits is not used.

- filledstrata:

  Strata is filled sequentially according to this vector.

- sumVar:

  Total variance for all values of total n.

When returnTable=TRUE and when varLimits or cvLimits is used
(FStotnAlloc, FSvarAlloc, FScvAlloc, FScvAlloc2) the output is the
allocated sample size in each strata.

Other elements of the FSmatrix-output can be obtained by setting other
return-parameters to TRUE or by using varLimits=Inf or cvLimits=Inf.

## Examples

``` r
# Examples with 5 strata based on FSmatrix
  s2    = c(35, 3, 2, 30, 7)         # Variance estimate
  N     = c(100, 100, 500, 50, 150)  # N in each strata
  names(N) = paste("st",1:5,sep="")  # Strata-names
  totY  = c(8800,900,5500,400,300)   # Totals in each strata
  g     = c("grA","grA","grB","grB","grB") # Two groups
 
# Total sample size of 200 chosen in advance
  m = FSmatrix(s2=s2,N=N,totn=200,group=g)
  # Three ways of getting allocated n in each strata
  m[,1]$n
#> st1 st2 st3 st4 st5 
#>  55  16  66  26  37 
  m[1,]$Strata
#> st1 st2 st3 st4 st5 
#>  55  16  66  26  37 
  m[[1,1]]
#> st1 st2 st3 st4 st5 
#>  55  16  66  26  37 
  
# Alloc from varLimits
  vL = c(5000,10000)   # variance limits for groups 
  m = FSmatrix(s2=s2,N=N,varLimits=vL,group=g)
  m[[1,1]] # Allocated n in each strata
#> st1 st2 st3 st4 st5 
#>  52  15  72  28  41 
  m[3,] # Total variance in strata, group (less than limits) and all.
#> $Strata
#>      st1      st2      st3      st4      st5 
#> 3230.769 1700.000 5944.444 1178.571 2791.463 
#> 
#> $Group
#>      grA      grB 
#> 4930.769 9914.479 
#> 
#> $All
#>      all 
#> 14845.25 
#> 
  
#  Calculate CV from totY in strata from known allocation (20%)
  m = FSmatrix(s2=s2,N=N,totY=totY,max_n=round(N/5),group=g)
  m[5,] # CV in strata, group and all.
#> $Strata
#>       st1       st2       st3       st4       st5 
#>  1.344564  3.849002  1.149919 19.364917 21.602469 
#> 
#> $Group
#>      grA      grB 
#> 1.271013 1.921996 
#> 
#> $All
#>      all 
#> 1.078392 
#> 
```
