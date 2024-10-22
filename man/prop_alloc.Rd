% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prop_alloc.R
\name{prop_alloc}
\alias{prop_alloc}
\title{Proportional allocation}
\usage{
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
}
\arguments{
\item{N}{The population size within each strata (a vector of integers)}

\item{X}{The X-total, per stratum, to which the allocation should be proportional (a vector of numbers in the range [0, Inf)).
If a stratum has X=0, that stratum will not be allocated samples unless the stratum has min_n>0 or take_all=1.
If X = N, the allocation becomes proportional to the number of units}

\item{totn}{The total desired sample size (an integer)}

\item{take_all}{Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum is a take-all stratum}

\item{take_none}{Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum is a take-none stratum}

\item{min_n}{Optional. Minimum sample size in each stratum. This can be a single integer used in all strata or a vector of 
integers (one for each stratum). NA's and 0 are allowed.
Strata with take_none=1 override min_n.
If min_n>max_n (and take_all/take_none = 0), min_n is overridden by max_n}

\item{max_n}{Optional. Maximum sample size in each stratum. This can be a single integer used in all strata or a vector of 
integers (one for each stratum). NA's are allowed.
Strata with take_all=1 override max_n}

\item{max_it}{The maximum number of iterations for the algorithm (default 1000). An integer (it's advisable to choose a 
large value)}
}
\value{
A data frame with the variables (in addition to the input):
\item{n}{Allocated sample size} 
\item{n_adjusted}{If the algorithm managed to give exact totn, then n_adjusted=n, otherwise n_adjusted is an adjusted version of n so that sum(n_adjusted)=totn}
\item{LU}{Lower bounds for n, based on the input}
\item{BU}{Upper bounds for n, based on the input}
\item{it_number}{Number of completed iterations in the algorithm}
}
\description{
An algorithm that allocates the total sample proportionally between strata (proportional to an x-variable 
or to the number of units). The algorithm takes into account any min/max per stratum and take-all/take-none strata
}
\details{
It is not guaranteed that the algorithm will achieve the desired sample size totn exactly, even with numerous iterations. In 
such cases, a warning is given. However, the adjusted version of n, n_adjusted, always gives the desired sample size. \cr
The allocated sample size n is independent of how the strata are ordered in the input (i.e., a specific stratum receives the 
same sample size regardless of how the input are sorted). However, n_adjusted may vary with the sorting of the input (except 
when the algorithm achieve the desired sample size totn exactly, because then n_adjusted=n).

The algorithm: \cr
First, calculate a value k by dividing totn by the sum of the elements in X (k=totn/sum(X)). Then, calculate n by multiplying 
k with X (n=k*X). The elements in n are then rounded to the nearest integer and adjusted for any constraints such as 
min_n/max_n or take_all/take_none. If sum(n)=totn, the allocation is complete. If the sum of n does not equal totn, an 
iterative algorithm starts: First, k is adjusted, either by decreasing it if the sum(n)>totn or increasing it if sum(n)<totn. 
Then n=k*X, rounded to the nearest integer and adjusted for any constraints. This iteration is done until sum(n)=totn or the 
maximum number of iterations is reached.
}
\examples{

  N <- c(55, 610, 2900, 25, 1850)  # N in each strata
  X <- c(85000, 100000, 250000, 5000, 200000)  # X in each strata
  
# Total sample size of 500, allocated proportionally to X
  prop_alloc(N = N, X = X, totn = 500)
  
# Total sample size of 500, allocated proportionally to the number of units (N)
  prop_alloc(N = N, X = N, totn = 500)
  
# Example with minimum and maximum number to be allocated per stratum
  max_n <- c(40, 200, 300, NA, 300)
  prop_alloc(N = N, X = X, totn = 500, min_n = 5, max_n = max_n)
  
# Example with take-all stratum and maximum number to be allocated per stratum
  take_all <- c(0, 0, 0, 1, 0)
  prop_alloc(N = N, X = X, totn = 500, max_n = 200, take_all = take_all)
  
# Example where the algorithm does not give exactly the desired total sample size
  N <- c(58, 610, 2900, 15, 1850)
  X <- c(88000, 100000, 250000, 50000, 200000)
  prop_alloc(N = N, X = X, totn = 200)

}
