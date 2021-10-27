
#' Rate model
#' Estimates and diagnostics for estimating a total from a rate model
#'
#' @param pop population data frame
#' @param sample sample data frame
#' @param id name of identification variable as a string. Should be same in sample and pop dataframes.
#' @param x name of the explanatory variable
#' @param y name of the statistic vaiable
#' @param stratum name of the stratum variable
#' @param groups not implemented yet
#' @param robust not implemented yet
#' @param exclude not implemented yet
#' @param impute not implemented yet
#'
#' @return
#' @export
#'
#' @examples
rate_model <- function(
  pop,
  sample,
  id,
  x,
  y,
  stratum,
  groups = NULL,  #grupper for å estimere
  robust = FALSE, #robust estimation of CV
  exclude = NULL, #observasjoner til å ekskudere
  impute = FALSE  #om en masseimputertfil skal produseres
  ){
  sample <- as.data.frame(sample)
  pop <- as.data.frame(pop)

  # Check all in sample have y values
  sample <- sample[!is.na(sample[, y]),]
  #sample[, y][is.na(sample[, y])] <- 0

  # create formula
  form <- as.formula(paste(y, "~", x, "-1"))

  # create weights
  vekt <- 1/sample[, x]

  # allow zeros in the explanatory variabel (??)
  tab <- table(vekt == Inf)
  if (length(tab) > 1){
    message("Some observation have zero as their explanatory variable and were adjusted (1/(x+1)) to allow a real weight input")
    vekt[vekt == Inf] <- 1/(sample[,x_var]+1)
  }

  strata_levels <- unique(pop[, stratum])
  strata_levels_utvalg <- unique(sample[, stratum])
  if (!all(strata_levels %in% strata_levels_utvalg)) {
    stop(" Not all strata were the same in the population file and sampel file.")
  }

  # for testing
  #st <- strata_levels[1]
  strata_n <- length(strata_levels)
  T_h <- data.frame(stratum = vector(mode = "character", length = strata_n),
                    N_pop = vector(mode = "numeric", length = strata_n),
                    X_pop = vector(mode = "numeric", length = strata_n),
                    N_utv = vector(mode = "numeric", length = strata_n),
                    X_utv = vector(mode = "numeric", length = strata_n),
                    T_est = vector(mode = "numeric", length = strata_n),
                    LB = vector(mode = "numeric", length = strata_n),
                    UB = vector(mode = "numeric", length = strata_n),
                    CV = vector(mode = "numeric", length = strata_n)
  )

  Dffits <- data.frame(id = NA, stratum = NA, x = NA, y = NA, N_utv = NA, G = NA)

  for(i in 1:strata_n){
    st <- strata_levels[i]

    pop_tmp <- pop[pop[, stratum] == st, ]
    s_tmp <- sample[sample[, stratum] == st, ]
    vekt_tmp <- vekt[sample[, stratum] == st]

    # Add in sums and stratum to output data frames
    T_h$stratum[i] <- st
    T_h$N_pop[i] <- nrow(pop_tmp)
    T_h$X_pop[i] <- sum(pop_tmp[, x])
    T_h$N_utv[i] <- nrow(s_tmp)
    T_h$X_utv[i] <- sum(s_tmp[, x])

    # Add in sums to Dffits data frame
    Dffits_tmp <- data.frame(id = s_tmp[, id], stratum = s_tmp[, stratum],
                             x = s_tmp[, stratum], y = s_tmp[, stratum],
                             N_utv = nrow(s_tmp))

    # Fit model
    mod_tmp <- lm(form, data = s_tmp, weights = vekt_tmp)

    # Get estimate for totallen
    X_h <- sum(pop_tmp[, x])
    T_h$T_est[i] <- X_h * mod_tmp$coefficients

    # Get estimate for variance (default CV2 in notat)
    var_tmp <- robust_var(pop_tmp, s_tmp, id=id, x=x,
                           ei = mod_tmp$residuals,
                           model_type = "rate",
                           var_type = "cv2")
    # Try normal variance
    var_alt <- var_norm(pop_tmp, s_tmp, x=x,
                          sigma = sigma(mod_tmp))

    # Add estimates to results table
    T_h$LB[i] <- T_h$T_est[i] - 1.96 * sqrt(var_tmp)
    T_h$UB[i] <- T_h$T_est[i] + 1.96 * sqrt(var_tmp)
    T_h$CV[i] <- sqrt(var_tmp)/T_h$T_est[i] * 100
    T_h$CV_vanlig[i] <- sqrt(var_alt)/T_h$T_est[i] * 100

    # calculate G/DFFITS values
    diagnostics <- model_diag(pop_tmp, s_tmp, x, y, hatvalues(mod_tmp))
    Dffits_tmp$G <- diagnostics$G
    Dffits <- rbind(Dffits, Dffits_tmp)
  }
  list(T_h = T_h[order(T_h$stratum), ], Dffits = Dffits[-1, ][order(-Dffits$G),])
}


#' Calculate variance for a rate model
#'
#' @param pop population sata frame
#' @param sample sample sata frame
#' @param x
#' @param sigma
#' @param model_type
#' @param var_type
#'
#' @return
#'
#' @examples
var_norm <- function(pop,            # populasjon
                     sample,         # utvalg
                     x,              # forklaringsvariabel
                     sigma,          # estimate of sigma from model
                     model_type = "rate",
                     var_type = "normal"){

  Xs <- sum(sample[, x])
  X <- sum(pop[, x])
  X^2 * ((X-Xs))/X * (sigma ^2) /Xs
}


#' Robust variance using CV2 method
#'
#' @param pop
#' @param sample
#' @param id
#' @param x
#' @param ei
#' @param model_type
#' @param var_type
#'
#' @return
#'
#' @examples
robust_var <- function(pop,            # populasjon
                    sample,         # utvalg
                    id,             # identifisering variable
                    x,              # forklaringsvariabel
                    ei,             # resuduals
                    model_type = "rate",
                    var_type = "cv2"){
  # Calculate a_i
  Xr <- sum(pop[!(pop[, id] %in% sample[, id]), x])
  Xs <- sum(sample[, x])
  ai <- Xr/Xs

  # Calculate leverage (h_i)
  hi <- sample[, x]/Xs

  # Calculate di
  di <- ei^2 /(1-hi)

  # Calculate two variance components
  V_T_est <- sum(ai^2 * di)
  V_T <- sum(di) * Xr/Xs

  # Return sum of variance
  V_T_est + V_T

}

#' Create model diagnostics
#'
#' @param pop
#' @param samp
#' @param x
#' @param y
#' @param h_i
#'
#' @return
#'
#' @examples
model_diag <- function(pop, samp, x, y, h_i){

  # create formula here - struggled to pass in. perhaps change tocollect from mod
  form <- as.formula(paste(y, "~", x, "-1"))

  # get weights and full model
  vekt <- 1/samp[, x]
  mod <- lm(formula = form, data=samp, weights = vekt)

  # calculate leave-one-out predictions - faster way to do this?
  y_j <- vector(mode="numeric", length=nrow(samp))
  for (j in 1:nrow(samp)){
    tmp_mod <- lm(formula = form, data = as.data.frame(samp[-j, ]),
                  weights = as.vector(vekt[-j]))
    y_j[j] <- samp[j, x] * tmp_mod$coefficients
  }

  # get h_i
  h_i <- hatvalues(mod)

  # calculate r_i
  r_i <- (y_j - samp[, y]) / sd(y_j - samp[, y])

  # calculate G
  G <-  r_i * sqrt(h_i / (1 - h_i))

  # return lists
  list(H = h_i, R = r_i, G=G)
}

