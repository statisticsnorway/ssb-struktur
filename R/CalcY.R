# Code for calculation of estimates for y or ratio/difference within strata
# Author: Susie Jentoft
# last Edited:  August 2015
# Changed to only allow single time period calculation - baseVar argument dropped from first version



#' Calculation of the estimate for the interest variable
#' 
#' Calculation of the estimates for the interest variable (Y) using either a
#' rate model (with an x variable) or simple expansion. Includes options for
#' calculation of level, ratio and difference statistics.
#' 
#' 
#' @param data The dataset
#' @param yVar The variable name for the interest variable (y). Eg "turnover"
#' @param xVar The name of the activity variable which relates to the interest
#' variable. This is only required for estimation with a rate model. Eg
#' "numberOfEmployees"
#' @param strataVar The variable used for stratification
#' @param sampleVar The variable used to identify which companies were included
#' in the sample. This is used in cases where the interest variable (y
#' variable) are not avaialable for the population. When a variable is
#' specified here, y-values from the sample only are used to calculate s2.
#' Default is NULL
#' @param estimateType The type of estimate to do. Default is set to 'level'
#' but option for 'diff' for a difference statistis and 'ratio' for a ratio
#' statistic.
#' @param residVariance Whether to calculate the total based on a rate model
#' (residVariance = TRUE) or not (residVariance = FALSE). This option is only
#' available for level statistic calculation at the moment.
#' @return The estimates for y are returned as a vector of length equal to the
#' number of strata (identified in strataVar), or a dataset if several periods
#' are given with each column giving the estimates in each strata.
#' @keywords survey
#' 
#' @export
#' 
#' @examples
#'   
#' # Call test dataset
#'   data(testData)
#'   
#' # Create stratification variable
#'   testData$strata1 <- paste(testData$nace3, testData$storGrp, sep="")
#' 
#' # Examples for level statistic
#'   CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   estimateType = "level")
#'   
#'   CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   estimateType = "level", residVariance = FALSE)
#'   
#'   CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   sampleVar = "utv1", estimateType = "level")
#'   
#'   CalcY(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   sampleVar = "utv1", estimateType = "level", residVariance = FALSE)
#' 
#' # Example for difference statistic
#'   CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
#'   baseVar = "y1", estimateType = "diff")
#' 
#' # Example for ratio statistic
#'   CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
#'   baseVar = "y1", estimateType = "ratio")
#' 
CalcY <- function (data, yVar, xVar = NULL, strataVar, sampleVar = NULL, 
                   estimateType = list("level", "diff", "ratio"), 
                   residVariance = TRUE) 
{
  if (missing(estimateType)) {
    estimateType <- "level"
    warning("No estimate type was specified so is being treated as a level statistic. Alternately please specify estimateType as 'level', 'diff', or 'ratio'", 
            call. = FALSE)
  }
  
  # yVar setup and checks
  if (is.null(yVar) | any(!is.element(yVar, names(data)))) stop("y variable is missing or is not in the dataset", call. = FALSE)
  if (length(yVar) != 1 & estimateType == "level") stop("yVar should only be one variable", call. = FALSE)
  if (estimateType != "level" & length(yVar) != 2) stop("yVar must include two variables for difference and ratio estimates", call. = FALSE)
  y <- as.matrix(data[, yVar])
  
  # xVar sertup and checks
  if (length(xVar) > 1) stop("xVar must currently only be one variable", call. = FALSE) 
  if (residVariance) {
    if (is.null(xVar) | any(!is.element(xVar, names(data)))) stop("x variable is missing or is not in the dataset", call. = FALSE)
    z <- matrix(data[, xVar])
    z[z == 0 | is.na(z)] <- 1
  } else {
    z <- matrix(1, c(nrow(y), length(yVar)))
  }
  
  # stratification and sample variable setup
  strataGrp <- sort(unique(data[, strataVar]))
  selectStr <- match(data[, strataVar], strataGrp)
  if (is.null(sampleVar)) {
    u <- rep(1, nrow(data))
  }
  else {
    u <- data[, sampleVar]
  }
  
  # level calculations
  if (estimateType == "level") {
    yEst <- array(NA, c(length(strataGrp), 1))
    for (i in 1:length(strataGrp)) {
      yy <- y[selectStr == i & u == 1, ]
      zz <- as.double(z[selectStr == i & u == 1, ]) #new with u == 1
      b <- sum(yy[!is.na(yy)])/sum(zz[!is.na(yy)])
      yEst[i, ] <- sum(b * as.double(z[selectStr == i, ])) # new with z not zz
    }
  }
  
  # diff and ratio calculations
  if (estimateType != "level") {
    yEst <- array(NA, c(length(strataGrp), length(yVar) - 
                          1))
    for (j in 1:(length(yVar) - 1)) {
      for (i in 1:length(strataGrp)) {
        yy <- y[selectStr == i & u == 1, j]
        zz <- as.double(z[selectStr == i & u == 1, j]) #new
        b <- sum(yy)/sum(zz)
        yy2 <- y[selectStr == i & u == 1, j + 1]
        zz2 <- as.double(z[selectStr == i & u == 1, j + 1]) #new
        b2 <- sum(yy2)/sum(zz2)
        if (estimateType == "diff") {
          yEst[i, j] <- sum(b2 * zz2) - sum(b * zz) #check these for sample
        }
        if (estimateType == "ratio") {
          yEst[i, j] <- sum(b2 * zz2)/sum(b * zz) #check these for sample
        }
      }
    }
  }
  
  #tidy up and return
  rownames(yEst) <- strataGrp
  colnames(yEst) <- paste("estimate", 1:ncol(yEst), sep = "")
  return(yEst)
}
  
