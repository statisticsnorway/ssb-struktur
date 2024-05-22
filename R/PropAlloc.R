

#' Title
#'
#' @param N 
#' @param X 
#' @param totn 
#' @param take_all 
#' @param take_none 
#' @param min_n 
#' @param max_n 
#' @param max_it 
#'
#' @return
#' @export
#'
#' @examples

PropAlloc <- function(N, X, totn, take_all = NULL, take_none = NULL, min_n = NULL, max_n = NULL, max_it = 1000) {
  
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
  
  m <- data.frame(n = n, N = N, X = X)
  m$take_all <- take_all  
  m$take_none <- take_none
  m$min_n <- min_n  
  m$max_n <- max_n
  m$n_adjusted <- n_adjusted
  m$LB <- LB
  m$UB <- UB
  m$it_number <- it
  
  if(totn != sum(n) & max_it < 100)
    warning(paste("The algorithm failed to achieve the desired sample size of", totn, "units. The algorithm returned a sample of", sum(n), "units.\n  A larger value of max_it may help.\n  n_adjusted is an adjusted version of the allocation n, which has exactly sample size", totn))
  else if(totn != sum(n))
    warning(paste("The algorithm failed to achieve the desired sample size of", totn, "units. The algorithm returned a sample of", sum(n), "units.\n  n_adjusted is an adjusted version of the allocation n, which has exactly sample size", totn))
  
  m
}





#' Title
#'
#' @param x 
#' @param digits 
#'
#' @return
#' @export
#'
#' @examples

round2 = function(x, digits = 0) {
  posneg <- sign(x)
  z <- abs(x) * (10^digits)
  z <- z + 0.5 
  z <- trunc(z)
  z <- z / (10^digits)
  z <- posneg * z
  z
}


