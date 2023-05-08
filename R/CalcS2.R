# R Kode for generic calculation of sigma sq. within strata for level, difference and ratio statistics
# Author: Susie Jentoft
# Last edited: August 2015

# TO DO LIST:
# add in option that y is only in sample for diff/ratio
# add in theta values when Y calc is done
# add in differing p values per strata
# add in changing x values per period



#' Calculation of sigma squared
#' 
#' Calculation of sigma squared using either residual or simple variance for
#' level, difference or ratio statistics. The function includes options for
#' averaging over several periods.
#' 
#' @aliases CalcS2 LevelVariance KonVariance
#' @param data The dataset
#' @param yVar The variable name for the interest variable (y). Eg "turnover"
#' @param xVar The name of the activity variable which relates to the interest
#' variable. Eg "numberOfEmployees"
#' @param strataVar The variable used for stratification
#' @param sampleVar The variable used to identify which companies were included
#' in the sample. This is used in cases where the interest variable (y
#' variable) are not available for the population. When a variable is
#' specified here, y-values from the sample only are used to calculate s2.
#' Default is NULL
#' @param residVariance Whether to calculate residual or other variance.
#' Default is residual.
#' @param baseVar Variable which provides values as a fixed base for difference
#' and ratio statistics. If this is missing, then a moving base is used as the
#' previous period.
#' @param estimateType The type of statistic being calculated. Choose beteen
#' "level" for a standard level statistic, "diff" for a difference statistic,
#' or "ratio" = ratio statistic. If not provided, the function defaults to a
#' level statistic.
#' @param meanType In the case of several periods of data, meanType specifies
#' how they should be averaged. Default "var" calculated sigma sq and takes the
#' average. "y" takes the average of the y values first and then calculates
#' sigma sq.
#' @param p Specifies how much overlap there is between periods for a
#' difference or ratio statistic. Default is p = 1 which indicates full overlap
#' between periods.
#' @param printPlot Indicates whether or not to print boxplots of the residual
#' values (ei or ai) to identify outliers. One plot is made for each period or
#' each difference/ratio period. Default is FALSE.
#' @return \item{s2}{sigma squred values for each strata group} \item{N}{number
#' of observations used in the calculations.} \item{n}{If a sample variable is
#' specified, n is also returned}
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
#' # Resdiual variance for one period
#'   CalcS2(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   estimateType = "level")
#' 
#' # Simple variance for one period
#'   CalcS2(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   estimateType = "level", residVariance = FALSE)
#' 
#' # Residual variance for three periods
#'   CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "antAnsatt", strataVar = "strata1", 
#'   estimateType = "level") 
#' 
#' # Include a sample variable
#'   CalcS2(data = testData, yVar = "y1", xVar = "antAnsatt", strataVar = "strata1", 
#'   sampleVar = "utv1", estimateType = "level")
#'   
#' # Difference example - fixed base
#'   CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
#'   residVariance = TRUE, baseVar = "y1", estimateType = "diff")
#'   
#' # Difference example - changing base (just leave out baseVar)
#'   CalcS2(data = testData, yVar = c("y1", "y2", "y3"), xVar = "storGrp", strataVar = "strata1", 
#'   residVariance = TRUE, estimateType = "diff")
#' 
#' #Ratio example showing boxplots - fixed base
#'   CalcS2(data = testData, yVar = c("y1", "y2","y3"),  xVar = "antAnsatt", strataVar = "strata1",
#'   baseVar="y1", estimateType = "ratio", printPlot = TRUE)
#' 
#' 
CalcS2 <- function (data, yVar, xVar = NULL, strataVar, sampleVar = NULL, 
                    residVariance = TRUE, baseVar = NULL, estimateType = list("level", 
                                                                              "diff", "ratio"), 
                    meanType = c("y", "var"), p = 1, printPlot = FALSE) 
{
  if (missing(estimateType)) {
    estimateType <- "level"
  }
  if (!(estimateType %in% c("level", "diff", "ratio"))) {
    stop("the estimate name is not in the list. Please ensure it is either: 'level', 'diff', or 'ratio'")
  }
  if (missing(meanType)) {
    meanType <- "var"
  }
  if (!(meanType %in% c("y", "var"))) {
    stop("the mean type is not recognised. Please ensure it is either: 'y' or 'var'")
  }
  if (is.null(yVar) | any(!is.element(yVar, names(data)))) {
    stop("y variabel mangler eller er ikke i datasett")
  }
  if (estimateType %in% c("ratio", "diff") & is.null(baseVar)) {
    warning("The ", estimateType, " method was chosen but no base variable was specifyied. The previous period will be used as a moving base ", 
            call. = FALSE)
  }
  baseFast <- ifelse(is.null(baseVar), FALSE, TRUE)
  if (estimateType %in% c("ratio", "diff") & residVariance == 
        FALSE) {
    stop("Residual variance must be used for diff/ratio statistics")
  }
  if (estimateType %in% c("ratio", "diff") & is.vector(data[, 
                                                            yVar])) {
    stop("at least two y variables must be specified for a ratio/diff statistic")
  }
  if(!missing(sampleVar)){ # new 
    if(any(is.na(data[data[, sampleVar] == 1 , yVar]))){
      stop("NAs have been detected in the y-variable. Please remove these observations before proceeding")
    } 
    if (length(sampleVar) > 1){ # new
      stop("several time periods using a sample variable is not currently programmed")
    } 
  }
  if (estimateType == "level") {
    if (is.vector(data[, yVar])) {
      y <- as.vector(data[, yVar])
    }
    else {
      if (meanType == "y") {
        y <- apply(data[, yVar], 1, FUN = mean)
      }
      else {
        if (meanType == "var") {
          y <- data[, yVar]
        }
      }
    }
  }else {
    y <- data[, yVar]
    if (baseFast == TRUE) {
      if (!baseVar %in% names(y)) {
        y <- cbind(data[, baseVar], y)
      }
    }
  }
  if (residVariance) {
    if (is.null(xVar) | !is.element(xVar, names(data))) {
      stop("x variable is missing or is not in the given dataset")
    }
    x <- as.vector(as.double(data[, xVar]))
  }
  if (residVariance) {
    z <- x
    z[x == 0 | is.na(x)] <- 1
  }
  else if (!residVariance & is.vector(y)) {
    z <- array(1, length(y))
  }
  else if (!residVariance & !is.vector(y)) {
    z <- array(1, nrow(y))
  }
  strataGrp <- sort(unique(data[, strataVar]))
  selectStr <- match(data[, strataVar], strataGrp)
  if (is.null(sampleVar)) {
    u <- rep(1, nrow(data))
  }
  else {
    u <- data[, sampleVar]
  }
  if (is.vector(y)) {
    s2 <- array(NA, length(strataGrp))
    if (printPlot) {
      ei <- NULL
    }
    for (i in 1:length(strataGrp)) {
      s2[i] <- LevelVariance(y = y[selectStr == i & u == 
                                     1], z = z[selectStr == i & u == 1])
      if (printPlot) {
        ei <- rbind(ei, cbind(LevelVariance(y = y[selectStr == 
                                                    i & u == 1], z = z[selectStr == i & u == 1], 
                                            eReturn = TRUE), strataGrp[i]))
      }
    }
    if (printPlot) {
      graphics::par(las = 2)
      graphics::boxplot(as.double(ei[, 1]) ~ ei[, 2], main = paste("Plot of ei values for ", 
                                                         yVar, sep = ""))
    }
  }
  else if (estimateType == "level" & meanType == "var") {
    s2 <- array(NA, c(length(strataGrp), length(yVar)))
    for (j in 1:ncol(y)) {
      if (printPlot) {
        ei <- NULL
      }
      for (i in 1:length(strataGrp)) {
        s2[i, j] <- LevelVariance(y = y[selectStr == 
                                          i & u == 1, j], z = z[selectStr == i & u == 
                                                                  1])
        if (printPlot) {
          ei <- rbind(ei, cbind(LevelVariance(y = y[selectStr == 
                                                      i & u == 1, j], z = z[selectStr == i & u == 
                                                                              1], eReturn = TRUE), strataGrp[i]))
        }
      }
      if (printPlot) {
        graphics::par(las = 2)
        graphics::boxplot(as.double(ei[, 1]) ~ ei[, 2], main = paste("Plot of ei values for ", 
                                                           yVar[j], sep = ""))
      }
    }
    s2 <- apply(s2, 1, FUN = mean)
  }
  if (estimateType %in% c("diff", "ratio")) {
    if (baseFast == TRUE) {
      yp <- y[, yVar != baseVar]
      yb <- y[, baseVar] %*% t(rep(1, ncol(yp)))
    }
    else {
      yp <- y[, -1]
      yb <- y[, -ncol(y)]
    }
    if (estimateType == "diff") {
      theta <- 1
    }
    else {
      theta <- 1
    }
    s2 <- array(NA, c(length(strataGrp), ncol(yp)))
    for (j in 1:ncol(yp)) {
      if (printPlot) {
        ai <- NULL
      }
      for (i in 1:length(strataGrp)) {
        s2[i, j] <- KonVariance(y1 = yb[selectStr == 
                                          i, j], y2 = yp[selectStr == i, j], z = z[selectStr == 
                                                                                     i], p = p, theta = theta)
        if (printPlot) {
          ai <- rbind(ai, cbind(KonVariance(y1 = yb[selectStr == 
                                                      i, j], y2 = yp[selectStr == i, j], z = z[selectStr == 
                                                                                                 i], p = p, theta = theta, aReturn = TRUE), 
                                strataGrp[i]))
        }
      }
      if (printPlot) {
        graphics::par(las = 2)
        tegn <- ifelse(estimateType == "diff", " - ", 
                       " / ")
        baseName <- ifelse(baseFast == TRUE, baseVar, 
                           colnames(yb)[j])
        plottitle <- paste("Plot of ai values for ", 
                           colnames(yp)[j], tegn, baseName, sep = "")
        graphics::boxplot(as.double(ai[, 1]) ~ ai[, 2], main = plottitle)
      }
    }
    s2 <- rowMeans(s2, na.rm = TRUE)
  }
  s2[is.na(s2)] <- 0
  problemS2 <- strataGrp[s2 == 0]
  if (length(problemS2) > 0) {
    warning(paste("The following strata had an s2 that was unable to be calculated or was calculated as 0: ", 
                  problemS2, "\n", sep = ""), call. = FALSE)
  }
  N <- table(data[, strataVar])
  names(N) <- names(s2) <- strataGrp
  if (is.null(sampleVar)) {
    return(list(s2 = s2, N = N))
  }
  else {
    n <- table(data[data[, sampleVar] == 1, strataVar]) #includes NA
    n <- n[match(names(s2), names(n))]
    n[is.na(n)] <- 0
    names(n) <- strataGrp
    return(list(s2 = s2, N = N, n = n))
  }
}


LevelVariance <- function (y, z, eReturn = FALSE) 
{
  z <- z[!is.na(y)] #new
  y <- y[!is.na(y)] #new
  n <- length(z) #moved
  b <- sum(y)/sum(z)
  e <- y - b * z
  if (eReturn) {
    return(e)
  }
  if (!eReturn) {
    return(sum((e - mean(e))^2)/(n - 1))
  }
}


# Function for calculating sigma sq - diff/ratio - fixed z at the moment
KonVariance <- function(y1, y2, z, p = 1, theta = 1, aReturn = FALSE) {
  n <- length(z)
  e1 <- y1 - (sum(y1)/sum(z)) * z
  e2 <- y2 - (sum(y2)/sum(z)) * z
  r1 <- e1 - mean(e1)
  r2 <- e2 - mean(e2)
  a <- theta ^ 2 * r1 ^ 2 + r2 ^ 2 - 2 * theta * p * r1 * r2
  if (aReturn) { return(a) }
  if (!aReturn) { return(sum(a ^ 2 / (n - 1))) }
} 

