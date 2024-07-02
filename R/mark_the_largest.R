#' Mark units that have a large x
#' 
#' A function that marks the units that have the largest x-value in a data set.
#' Can mark the largest ones so that they cover a specified percentage of total x (method 1), can mark 
#' values that are greater than a specified threshold (method 2), can mark the n largest values (method 3) 
#' and can mark the largest so a specified percent of all units are marked (method 4).
#' 
#' @param data Input data set of class data.frame
#' @param idVar Name of identification variable. Should not have NA's, and should not have duplicates
#' @param strataVar Optional. Name of stratification variable. Should not have NA's. If strataVar is given, 
#'                  the marking is performed within each stratum
#' @param xVar Name of x-variable. Should be numeric. +/-Inf is not allowed. NA's are allowed (would never 
#'             be marked)
#' @param yVar Optional. Name of an extra sorting variable. Should be numeric. Only relevant for the 
#'             sorting of equal x-values, in which case the x's are ranked according to decreasing y-value. 
#'             NA's and +/-Inf are allowed. (NA is rated as less than -Inf)
#' @param method The methods to be used (default is 1). Can choose between method 1, 2, 3 and 4 (see ‘Details’), 
#'               and can use multiple methods simultaneously. The methods are specified using a vector
#' @param par_method1 Percentage for method 1 (default 25). Numeric value within the range [0, 100] (a single 
#'                    number or a vector with a length equal to the number of strata). If 0, no values are 
#'                    marked. If 100, all x > 0 are marked (assuming max_n_method1and2 is not used)
#' @param par_method2 Threshold value for method 2. Numeric value >= 0 (a single number or a vector with a 
#'                    length equal to the number of strata). If 0, all x > 0 are marked (assuming 
#'                    max_n_method1and2 is not used)
#' @param par_method3 Number for method 3 (default 5). Integer 0, 1, 2, ... (a single number or a vector with a 
#'                    length equal to the number of strata). If 0, no values are marked
#' @param par_method4 Percentage for method 4 (default 5). Numeric value within the range [0, 100] (a single 
#'                    number or a vector with a length equal to the number of strata). If 0, no values are 
#'                    marked. If 100, all x != NA are marked (assuming min_x_method3and4 is not used)
#' @param max_n_method1and2 Optional. Applies to method 1 and 2. Maximum number of markings that can be made.  
#'                          Integer 0, 1, 2, ...(a single number or a vector with a length equal to the 
#'                          number of strata)
#' @param min_x_method3and4 Optional. Applies to method 3 and 4. Minimum threshold for x (only x > min_x_method3and4 
#'                          can be marked). Numeric (a single number or a vector with a length equal to the 
#'                          number of strata)
#' 
#' @details
#' If strataVar is given, the marking is performed within each stratum. Parameters given as a single number then apply to 
#' each stratum. If a parameter is given as a vector, the length should equal to the number of strata, and the order of 
#' the elements should correspond to the order obtained when the input data is sorted by strataVar using order(): 
#' data[order(data[ , strataVar]) , ] \cr \cr
#' Method 1: Marks the largest x-values so that they (at least) cover a specified percentage of the total x-value (x < 0 are not included in the total x-value). 
#'           Only x > 0 can be marked with this method.
#'           If strataVar is used, this is done per stratum, and the total x-value applies to the stratum.
#'           If max_n_method1and2 is used, it is not guaranteed that the specified percentage will be achieved. \cr \cr
#' Method 2: Marks x-values that are greater than a specified threshold (x > threshold).
#'           Only x > 0 can be marked with this method.
#'           If max_n_method1and2 is used, it's not guaranteed that all x > threshold will be marked. \cr \cr
#' Method 3: Marks the n largest x-values. 
#'           x = NA will never be marked with this method. 
#'           If strataVar is used, it's the n largest per stratum that are marked. 
#'           If min_x_method3and4 is used, it's not guaranteed that the specified number will be marked. \cr \cr
#' Method 4: Marks the largest x-values so that p percent of all units are marked (units with x = NA are not counted in the percentage calculation). 
#'           x = NA will never be marked with this method. 
#'           If strataVar is used, the p percent largest units per stratum are marked.
#'           If min_x_method3and4 is used, it's not guaranteed that the specified percentage will be achieved. \cr \cr
#' To ensure the same result regardless of the sorting of the input data set, the function sorts the input data set 
#' first by idVar before further sorting and marking is done.
#' 
#' @return
#' The output is a data frame. For each method used, a binary variable is created that shows which units are 
#' marked (the variables are named large1, large2, large3, and large4 for methods 1, 2, 3 and 4 respectively). 
#' Additionally, there is a variable that shows which units are marked for at least one method (the variable is named large).
#' 
#' @export
#'
#' @examples
#' # Test dataset
#' set.seed(956)
#' testData <- data.frame(id = 1:30, x = rnorm(n = 30, mean = 1000, sd = 500),
#'                        strata = c(rep('A', 12), rep('B', 18)))
#' testData$x[sample(1:30, size = 2)] <- NA
#' 
#' # Example with method 1, 2 and 3
#' mark_the_largest(data = testData, idVar = 'id', xVar = 'x', method = c(1, 2, 3), 
#'                  par_method1 = 15, par_method2 = 5000, par_method3 = 5)
#' 
#' # Example with stratification
#' mark_the_largest(data = testData, idVar = 'id', strataVar = 'strata', xVar = 'x', 
#'                  method = c(1, 4), par_method1 = c(20, 30), par_method4 = 25)
#' 
mark_the_largest <- function(data, idVar, strataVar = NULL, xVar, yVar = NULL, method = 1, par_method1 = NULL, 
                             par_method2 = NULL, par_method3 = NULL, par_method4 = NULL, 
                             max_n_method1and2 = NULL, min_x_method3and4 = NULL) {
  
  if(!is.data.frame(data)) stop("The input data set should be a data.frame")
  SSBtools::CheckInput(idVar, type = "varName", data = data)
  SSBtools::CheckInput(strataVar, type = "varName", data = data, okNULL = TRUE)
  SSBtools::CheckInput(xVar, type = "varName", data = data)
  SSBtools::CheckInput(yVar, type = "varName", data = data, okNULL = TRUE)
  SSBtools::CheckInput(method, type = "integer", okSeveral = TRUE, alt = c(1, 2, 3, 4), okDuplicates = TRUE)
  SSBtools::CheckInput(par_method1, type = "numeric", min = 0, max = 100, okSeveral = TRUE, okNULL = TRUE)
  SSBtools::CheckInput(par_method2, type = "numeric", min = 0, okSeveral = TRUE, okNULL = TRUE)
  SSBtools::CheckInput(par_method3, type = "integer", min = 0, okSeveral = TRUE, okNULL = TRUE)
  SSBtools::CheckInput(par_method4, type = "numeric", min = 0, max = 100, okSeveral = TRUE, okNULL = TRUE)
  SSBtools::CheckInput(max_n_method1and2, type = "integer", min = 0, okSeveral = TRUE, okNULL = TRUE)
  SSBtools::CheckInput(min_x_method3and4, type = "numeric", okSeveral = TRUE, okNULL = TRUE)
  
  dat <- data[, c(idVar, xVar)]
  names(dat) <- c("id", "x")
  if(!is.null(yVar)) dat$y <- data[, yVar]
  else dat$y <- 1
  if(!is.null(strataVar)) dat$strata <- data[, strataVar]
  else dat$strata <- 1
  
  if(sum(is.infinite(dat$x)) > 0) stop("xVar: should not have +/- Inf")
  if(sum(is.na(dat$id)) > 0) stop("idVar: should not have NA's")
  if(sum(duplicated(dat$id)) > 0) stop("idVar: should not have duplicates")
  if(sum(is.na(dat$strata)) > 0) stop("strataVar: should not have NA's")
  
  dat <- dat[order(dat$id), ] # to ensure the same result regardless of the sorting of the input data set
  
  dat <- dat[order(dat$strata, -dat$x, -dat$y), ]
  stratalist <- unique(dat$strata) 
  dat$numb <- stats::ave(rep(1, times = nrow(dat)), dat$strata, FUN = cumsum)
  dat$z <- ifelse(is.na(dat$x) | dat$x < 0, 0, dat$x) 
  
  if(1 %in% method) {
    if(is.null(par_method1)) par_method1 <- 25
    if(length(par_method1) == 1) par_method1 <- rep(par_method1, length(stratalist))
    if(length(par_method1) != length(stratalist)) stop("par_method1: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$par_method1 <- par_method1[match(dat$strata, stratalist)]
  }
  
  if(2 %in% method) {
    if(is.null(par_method2)) stop("When method 2 is used, par_method2 must be specified")
    if(length(par_method2) == 1) par_method2 <- rep(par_method2, length(stratalist))
    if(length(par_method2) != length(stratalist)) stop("par_method2: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$par_method2 <- par_method2[match(dat$strata, stratalist)]
  }
  
  if(3 %in% method) {
    if(is.null(par_method3)) par_method3 <- 5
    if(length(par_method3) == 1) par_method3 <- rep(par_method3, length(stratalist))
    if(length(par_method3) != length(stratalist)) stop("par_method3: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$par_method3 <- par_method3[match(dat$strata, stratalist)]
  }
  
  if(4 %in% method) {
    if(is.null(par_method4)) par_method4 <- 5
    if(length(par_method4) == 1) par_method4 <- rep(par_method4, length(stratalist))
    if(length(par_method4) != length(stratalist)) stop("par_method4: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$par_method4 <- par_method4[match(dat$strata, stratalist)]
  }
  
  har_ikke_oppgitt_max_n <- is.null(max_n_method1and2)
  if(1 %in% method | 2 %in% method) {
    if(is.null(max_n_method1and2)) max_n_method1and2 <- Inf
    if(length(max_n_method1and2) == 1) max_n_method1and2 <- rep(max_n_method1and2, length(stratalist))
    if(length(max_n_method1and2) != length(stratalist)) stop("max_n_method1and2: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$max_n_method1and2 <- max_n_method1and2[match(dat$strata, stratalist)]
    available1and2 <- ifelse((dat$z > 0) & (dat$numb <= dat$max_n_method1and2), 1, 0)
  }
  
  har_ikke_oppgitt_min_x <- is.null(min_x_method3and4)
  if(3 %in% method | 4 %in% method) {
    if(is.null(min_x_method3and4)) min_x_method3and4 <- -Inf 
    if(length(min_x_method3and4) == 1) min_x_method3and4 <- rep(min_x_method3and4, length(stratalist))
    if(length(min_x_method3and4) != length(stratalist)) stop("min_x_method3and4: Wrong number of elements (must be either a number, or a vector with length equal to the number of strata)")
    dat$min_x_method3and4 <- min_x_method3and4[match(dat$strata, stratalist)]
    available3and4 <- ifelse((!is.na(dat$x)) & (dat$x > dat$min_x_method3and4), 1, 0)
  }
  
  if(1 %in% method) {
    cumz <- stats::ave(dat$z, dat$strata, FUN = cumsum)
    sumz <- stats::ave(dat$z, dat$strata, FUN = sum)
    cumzperc <- (cumz / sumz) * 100  # if sumz = 0 then cumzperc = NaN, and available1and2=0 because z=0
    help <- stats::ave(cumzperc, dat$strata, FUN = displace) # help = c(0, cumzperc[1:n-1])
    dat$large1 <- ifelse((cumzperc <= dat$par_method1 | help < dat$par_method1) & (available1and2 == 1), 1, 0)
  }
  
  if(2 %in% method) {
    dat$large2 <- ifelse(dat$z > dat$par_method2 & available1and2 == 1, 1, 0)
  }
  
  if(3 %in% method) {
    dat$large3 <- ifelse(dat$numb <= dat$par_method3 & available3and4 == 1, 1, 0)
  }
  
  if(4 %in% method) {
    NikkeNA <- stats::ave(dat$x, dat$strata, FUN = function(x){sum(!is.na(x))})
    n_method4 <- ceiling((dat$par_method4/100) * NikkeNA)
    dat$large4 <- ifelse((dat$numb <= n_method4) & (available3and4 == 1), 1, 0)
  }
  
  if(1 %in% method) large1 <- dat$large1
  else large1 <- rep(0, length(nrow(dat)))
  if(2 %in% method) large2 <- dat$large2
  else large2 <- rep(0, length(nrow(dat)))
  if(3 %in% method) large3 <- dat$large3
  else large3 <- rep(0, length(nrow(dat)))
  if(4 %in% method) large4 <- dat$large4
  else large4 <- rep(0, length(nrow(dat)))
  
  dat$large <- ifelse(large1 == 1 | large2 == 1 | large3 == 1 | large4 == 1, 1, 0)
  
  row.names(dat) <- NULL
  dat <- dat[, -c(5, 6)]  # removes numb og z
  if(har_ikke_oppgitt_max_n) dat$max_n_method1and2 <- NULL
  if(har_ikke_oppgitt_min_x) dat$min_x_method3and4 <- NULL
  if(is.null(yVar)) dat$y <- NULL
  if(is.null(strataVar)) dat$strata <- NULL
  
  if(!(1 %in% method) & !is.null(par_method1)) cat("par_method1: This parameter is not used (it is only used by method 1)", "\n") 
  if(!(2 %in% method) & !is.null(par_method2)) cat("par_method2: This parameter is not used (it is only used by method 2)", "\n")
  if(!(1 %in% method) & !(2 %in% method) &  !is.null(max_n_method1and2)) cat("max_n_method1and2: This parameter is not used (it is only used by method 1 and 2)", "\n") 
  if(!(3 %in% method) & !is.null(par_method3)) cat("par_method3: This parameter is not used (it is only used by method 3)", "\n") 
  if(!(4 %in% method) & !is.null(par_method4)) cat("par_method4: This parameter is not used (it is only used by method 4)", "\n") 
  if(!(3 %in% method) & !(4 %in% method) &  !is.null(min_x_method3and4)) cat("min_x_method3and4: This parameter is not used (it is only used by method 3 and 4)", "\n") 
  
  dat
}





#' A function that shifts the elements in a vector one step to the right, the last element disappears 
#' while x_1 is inserted as the first element
#' 
#' @param x A vector of numbers (NA's are allowed)
#' @param x_1 A single number (NA are allowed)
#'
#' @return A vector
#' @keywords internal
#' 
displace <- function(x, x_1 = 0) {
  n <- length(x)
  y <- c(x_1, x[1:n-1])
  y
}









