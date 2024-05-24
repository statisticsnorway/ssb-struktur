#' Proportional allocation
#' 
#' An algorithm that allocates the total sample proportionally between strata (proportional to an x-variable 
#' or to the number of units). The algorithm takes into account any min/max per stratum and take-all/take-none strata
#' 
#' @param N The population size within each strata (a vector of integers)
#' @param X The X-total, per stratum, to which the allocation should be proportional (a vector of numbers in the range [0, Inf)).
#'          If a stratum has X=0, that stratum will not be allocated samples unless the stratum has min_n>0 or take_all=1.
#'          If X = N, the allocation becomes proportional to the number of units
#' @param totn The total desired sample size (an integer)
#' @param take_all Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum is a take-all stratum
#' @param take_none Optional. A vector of 0’s and 1’s, where 1 indicates that the stratum is a take-none stratum
#' @param min_n Optional. The minimum number to be allocated per stratum. Integer, either a single value or a vector. NA's and 0 are allowed.
#'              Strata with take_none=1 override min_n.
#'              If min_n>max_n (and take_all/take_none = 0), min_n is overridden by max_n
#' @param max_n Optional. The maximum number to be allocated per stratum. Integer, either a single value or a vector. NA's are allowed.
#'              Strata with take_all=1 override max_n
#' @param max_it The maximum number of iterations for the algorithm (default 1000). An integer (it's advisable to choose a large value)
#'
#' @return A data frame with the variables (in addition to the input):
#' \item{n}{Allocated sample size} 
#' \item{n_adjusted}{If the algorithm managed to give exact totn, then n_adjusted=n, otherwise n_adjusted is an adjusted version of n so that sum(n_adjusted)=totn}
#' \item{LU}{Lower bounds for n, based on the input}
#' \item{BU}{Upper bounds for n, based on the input}
#' \item{it_number}{Number of completed iterations in the algorithm}
#' 
#' @export
#'
#' @examples
#' 
#'   N <- c(55, 610, 2900, 25, 1850)  # N in each strata
#'   X <- c(85000, 100000, 250000, 5000, 200000)  # X in each strata
#'   
#' # Total sample size of 500, allocated proportionally to X
#'   prop_alloc(N = N, X = X, totn = 500)
#'   
#' # Total sample size of 500, allocated proportionally to the number of units (N)
#'   prop_alloc(N = N, X = N, totn = 500)
#'   
#' # Example with minimum and maximum number to be allocated per stratum
#'   max_n <- c(40, 200, 300, NA, 300)
#'   prop_alloc(N = N, X = X, totn = 500, min_n = 5, max_n = max_n)
#'   
#' # Example with take-all stratum and maximum number to be allocated per stratum
#'   take_all <- c(0, 0, 0, 1, 0)
#'   prop_alloc(N = N, X = X, totn = 500, max_n = 200, take_all = take_all)
#'   
#' # Example where the algorithm does not give exactly the desired total sample size
#'   N <- c(58, 610, 2900, 15, 1850)
#'   X <- c(88000, 100000, 250000, 50000, 200000)
#'   prop_alloc(N = N, X = X, totn = 200)
#' 
prop_alloc <- function(N, X, totn, take_all = NULL, take_none = NULL, min_n = NULL, max_n = NULL, max_it = 1000) {
  
  CheckInput(N, type = "integer", min = 1, okSeveral = TRUE) 
  CheckInput(X, type = "numeric", min = 0, okSeveral = TRUE) 
  if(sum(is.infinite(X))) stop("X: Inf is not allowed")
  if(length(X) != length(N)) stop("N and X are not of the same length")
  CheckInput(totn, type = "integer", min = 1)
  
  CheckInput(take_all, type = "integer", alt = c(0, 1), okDuplicates = TRUE, okSeveral = TRUE, okNULL = TRUE)
  if(is.null(take_all)) take_all2 <- rep(0, times = length(N))
  else take_all2 <- take_all
  if(length(take_all2) != length(N)) stop("take_all is not of the same length as N")
  
  CheckInput(take_none, type = "integer", alt = c(0, 1), okDuplicates = TRUE, okSeveral = TRUE, okNULL = TRUE)
  if(is.null(take_none)) take_none2 <- rep(0, times = length(N))
  else take_none2 <- take_none
  if(length(take_none2) != length(N)) stop("take_none is not of the same length as N")
  if(max(take_all2 + take_none2) > 1) stop("Inconsistency between take_all and take_none (at least one stratum has take_all = 1 and take_none = 1)")
  
  CheckInput(min_n, type = "integer", min = 0, okNA = TRUE, okSeveral = TRUE, okNULL = TRUE)
  if(is.null(min_n)) min_n2 <- rep(0, length(N))
  else if(length(min_n) == 1) min_n2 <- rep(min_n, length(N))
  else min_n2 <- min_n
  min_n2[is.na(min_n2)] <- 0
  if(length(min_n2) != length(N)) stop("min_n should have length 1 or the same length as N")
  
  CheckInput(max_n, type = "integer", min = 1, okNA = TRUE, okSeveral = TRUE, okNULL = TRUE)
  if(is.null(max_n)) max_n2 <- N
  else if(length(max_n) == 1) max_n2 <- rep(max_n, length(N))
  else max_n2 <- max_n
  max_n2 <- ifelse(is.na(max_n2), N, max_n2) 
  if(length(max_n2) != length(N)) stop("max_n should have length 1 or the same length as N")
  
  CheckInput(max_it, type = "integer", min = 1)
  
  # Boundaries for the allocation
  UB <- ifelse(X == 0, pmin(min_n2, max_n2, N), pmin(max_n2, N))
  LB <- pmin(min_n2, UB)
  
  # take_all/take_none = 1 overrules other input
  LB <- ifelse(take_all2 == 1, N, LB)  
  UB <- ifelse(take_all2 == 1, N, UB)  
  LB <- ifelse(take_none2 == 1, 0, LB)  
  UB <- ifelse(take_none2 == 1, 0, UB)
  
  if(sum(UB) == 0) stop("Your input gives n=0 for all strata")
  if(totn < sum(LB) | totn > sum(UB)) stop(paste("totn is too small/large. According to your input, totn should lie in the interval", max(1, sum(LB)), "-", sum(UB)))
  
  k <- NA
  min_k <- NA
  max_k <- NA
  n_min_k <- NA
  n_max_k <- NA
  n3 <- NULL
  
  if(totn == sum(LB)) {
    finished <- 1
    n <- LB
  }
  else if(totn == sum(UB)) {
    finished <- 1
    n <- UB
  }
  else {
    k <- totn / sum(X)   # at this stage sum(X) > 0
    n0 <- k * X
    n1 <- round2(n0, digits = 0)
    n2 <- pmax(n1, LB)
    n3 <- pmin(n2, UB)
    if(sum(n3) == totn) {
      finished = 1
      n <- n3
    }
    else if(sum(n3) > totn) {
      finished <- 0
      max_k <- k
      n_max_k <- sum(n3)
    }
    else {
      finished <- 0
      min_k <- k
      n_min_k <- sum(n3)
    }
  }
  
  it <- 0
  itdat <- data.frame(it = it, finished = finished, k = k, n_k = ifelse(is.null(n3), NA, sum(n3)), min_k = min_k, max_k = max_k, n_min_k = n_min_k, n_max_k = n_max_k)
  
  while(finished == 0 & it < max_it) {
    it <- it + 1
    if(sum(n3) > totn) k <- ifelse(is.na(min_k), 0.5*max_k, mean(c(min_k, max_k)))
    else k <- ifelse(is.na(max_k), 2*min_k, mean(c(min_k, max_k)))
    n0 <- k * X
    n1 <- round2(n0, digits = 0)
    n2 <- pmax(n1, LB)
    n3 <- pmin(n2, UB)
    if(sum(n3) == totn) {
      finished = 1
      n <- n3
      min_k <- NA
      max_k <- NA
      n_min_k <- NA
      n_max_k <- NA
    }
    else if(sum(n3) > totn) {
      finished <- 0
      max_k <- k
      n_max_k <- sum(n3)
    }
    else {
      finished <- 0
      min_k <- k
      n_min_k <- sum(n3)
    }
    
    itdat[nrow(itdat) + 1, ] <- c(it, finished, k, sum(n3), min_k, max_k, n_min_k, n_max_k)
  }
  
  # If the algorithm has not given exact totn, then the closest allocation is chosen
  if(finished == 0) {  
    if(is.na(min_k)) k <- max_k
    else if(is.na(max_k)) k <- min_k
    else if(abs(n_max_k - totn) < abs(n_min_k - totn)) k <- max_k
    else k <- min_k
    n0 <- k * X
    n1 <- round2(n0, digits = 0)
    n2 <- pmax(n1, LB)
    n3 <- pmin(n2, UB)
    n <- n3
  }
  
  # n_adjusted is an adjustment of n that gives exactly totn (if n gives exactly totn, then n_adjusted = n)
  n_adjusted <- n
  while(sum(n_adjusted) > totn) {
    number <- sum(n_adjusted) - totn
    ind <- n_adjusted - LB
    for(j in 1:length(N)) {
      if(ind[j] > 0 & number > 0) {
        n_adjusted[j] <- n_adjusted[j] - 1
        number <- number - 1
      }
    }
  }
  while(sum(n_adjusted) < totn) {
    number <- totn - sum(n_adjusted)
    ind <- UB - n_adjusted
    for(j in 1:length(N)) {
      if(ind[j] > 0 & number > 0) {
        n_adjusted[j] <- n_adjusted[j] + 1
        number <- number - 1
      }
    }
  }
  
  m <- data.frame(n = n, n_adjusted = n_adjusted, LB = LB, UB = UB, N = N, X = X)
  m$take_all <- take_all
  m$take_none <- take_none
  m$min_n <- min_n
  m$max_n <- max_n
  m$it_number <- it
  
  if(totn != sum(n) & max_it < 100)
    warning(paste("The algorithm failed to achieve the desired sample size of", totn, "units. The algorithm returned a sample of", sum(n), "units.\n  A larger value of max_it may help.\n  n_adjusted is an adjusted version of the allocation n, which has exactly sample size", totn))
  else if(totn != sum(n))
    warning(paste("The algorithm failed to achieve the desired sample size of", totn, "units. The algorithm returned a sample of", sum(n), "units.\n  n_adjusted is an adjusted version of the allocation n, which has exactly sample size", totn))
  
  m
}






#' Rounding
#' 
#' Rounds according to the "round up" rule: When a number is halfway between two others, it is rounded toward the nearest number that is away from zero.
#' Rounding to a negative number of digits means rounding to a power of ten, so for example round(x, digits = -2) rounds to the nearest hundred.
#'
#' @param x A vector of numbers to be rounded
#' @param digits An integer indicating the number of decimal places (default 0). Negative values are allowed (see 'Description')
#'
#' @return The rounded numbers
#'
round2 = function(x, digits = 0) {
  posneg <- sign(x)
  z <- abs(x) * (10^digits)
  z <- z + 0.5 
  z <- trunc(z)
  z <- z / (10^digits)
  z <- posneg * z
  z
}


