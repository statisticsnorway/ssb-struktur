library(MASS)
#' Rate model
#' Estimates and diagnostics for estimating a total from a rate model
#'
#' @param pop population data frame
#' @param sample sample data frame
#' @param id name of identification variable as a string. Should be same in sample and pop dataframes.
#' @param x name of the explanatory variable
#' @param y name of the statistic vaiable
#' @param stratum name of the stratum variable
#' @param groups name of variable(s) for using for groups
#' @param robust logic for if robust variance estimation should be used
#' @param cal_dffits logic for if dffits should be calculated and returned.
#' @param impute whether to produce and return an mass imputed population file. Not implemented yet
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
  robust = TRUE,  #robust estimation of CV
  calc_dffits = TRUE,  #whether to calculate dffits values
  impute = FALSE  #om en masseimputertfil skal produseres
  ){

  sample <- as.data.frame(sample)
  pop <- as.data.frame(pop)

  # Check all in sample have y values
  sample <- sample[!is.na(sample[, y]),]

  # create formula
  form <- as.formula(paste(y, "~", x, "-1"))

  # create weights
  vekt <- 1/sample[, x]

  # allow zeros in the explanatory variabel (??)
  tab <- table(vekt == Inf)
  if (length(tab) > 1){
    message("Some observation have zero as their explanatory variable and were adjusted (1/(x+1)) to allow a real weight input")
    vekt[vekt == Inf] <- 1/(sample[, x_var]+1)
  }

  strata_levels <- unique(pop[, stratum])
  strata_levels_utvalg <- unique(sample[, stratum])
  if (!all(strata_levels %in% strata_levels_utvalg)) {
    stop("Not all strata were the same in the population file and sample file.")
  }

  # Set up empty dataframes
  strata_n <- length(strata_levels)
  T_h <- data.frame(stratum = vector(mode = "character", length = strata_n),
                    N_pop = vector(mode = "numeric", length = strata_n),
                    X_pop = vector(mode = "numeric", length = strata_n),
                    N_utv = vector(mode = "numeric", length = strata_n),
                    X_utv = vector(mode = "numeric", length = strata_n),
                    T_est = vector(mode = "numeric", length = strata_n),
                    VAR = vector(mode = "numeric", length = strata_n),
                    LB = vector(mode = "numeric", length = strata_n),
                    UB = vector(mode = "numeric", length = strata_n),
                    CV1 = vector(mode = "numeric", length = strata_n),
                    CV2 = vector(mode = "numeric", length = strata_n),
                    CV3 = vector(mode = "numeric", length = strata_n)
  )

  # Set up Dffits data frame
  if (calc_dffits){
    Dffits <- data.frame(id = NA, stratum = NA, x = NA, y = NA, N_utv = NA,
                         R = NA, G = NA, R_grense = NA, G_grense = NA,
                         y_est_with = NA, y_est_without = NA)
  }


  # Run through estimation within each stratum
  for(i in 1:strata_n){
    st <- strata_levels[i]

    # create temporary data and weights for specific stratum
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
    if (calc_dffits){
    Dffits_tmp <- data.frame(id = s_tmp[, id], stratum = s_tmp[, stratum],
                             x = s_tmp[, x], y = s_tmp[, y],
                             N_utv = nrow(s_tmp))
    }

    # Fit model
    mod_tmp <- lm(form, data = s_tmp, weights = vekt_tmp)

    # Get estimate for totallen
    X_h <- sum(pop_tmp[, x])
    T_h$T_est[i] <- X_h * mod_tmp$coefficients

    # Calculate robust etimates of variance
    var_tmp <- robust_var(pop_tmp, s_tmp, id=id, x=x,
                            mod = mod_tmp,
                            model_type = "rate",
                            var_type = "cv2")

    # Create upper and lower boundaries
    T_h$VAR[i] <- var_tmp$V2
    T_h$LB[i] <- T_h$T_est[i] - 1.96 * sqrt(var_tmp$V2)
    T_h$UB[i] <- T_h$T_est[i] + 1.96 * sqrt(var_tmp$V2)

    # Add in robust coefficient of variations (CV)
    T_h$CV2[i] <- sqrt(var_tmp$V2)/T_h$T_est[i] * 100
    T_h$CV1[i] <- sqrt(var_tmp$V1)/T_h$T_est[i] * 100
    T_h$CV3[i] <- sqrt(var_tmp$V3)/T_h$T_est[i] * 100

    if (calc_dffits){
    # calculate and add G/DFFITS values
    diagnostics <- model_diag(mod_tmp)
    Dffits_tmp$R <- diagnostics$R
    Dffits_tmp$G <- diagnostics$G

    # Add in extreme value boundaries
    Dffits_tmp$R_grense <- 2
    Dffits_tmp$G_grense <- 2 * sqrt(1/nrow(s_tmp))

    #Select extreme values to show
    cond <- abs(Dffits_tmp$R) > Dffits_tmp$R_grense | abs(Dffits_tmp$G) > Dffits_tmp$G_grense
    cond[is.na(cond)] <- TRUE # Include observations with NA values for R and G
    Dffits_tmp <- Dffits_tmp[cond, ]
    if (nrow(Dffits_tmp) == 0) { break }

    # Add in estimate with and without extreme value
    Dffits_tmp$y_est_with <- T_h$T_est[i]

    for (j in 1:nrow(Dffits_tmp)){
      mm <- match(Dffits_tmp[j, id], s_tmp[, id])
      mod_ex <- lm(form, data = s_tmp[-mm, ], weights = vekt_tmp[-mm])
      Dffits_tmp$y_est_without[j] <- X_h * mod_ex$coefficients
    }

    # Add together
    Dffits <- rbind(Dffits, Dffits_tmp)
    }
  }

  # Add in group totals and CV estimates
  if (!is.null(groups)){
    group_dt <- data.frame(group_navn = NA, group = NA, T_est = NA, Var_est = NA, CV2 = NA)
    for (g in 1:length(groups)){

      # add group name to dataframe
      grp_tmp <- unique(sample[, groups[g]])

      # Create vector for group for strata in T_h dataset
      group_convert <- unique(sample[, c(stratum, groups[g])])
      m_strat <- match(T_h[, stratum], group_convert[, stratum])
      Th_grp <- group_convert[m_strat, groups[g]]

      # Sum variance and totals in each group
      for (s in 1:length(grp_tmp)){

        T_est <- sum(T_h$T_est[grp_tmp[s] == Th_grp])
        Var_est <- sum(T_h$VAR[grp_tmp[s] == Th_grp])
        CV2 <- sqrt(Var_est)/T_est * 100
        dt_tmp <- data.frame(group_navn = groups[g], group = grp_tmp[s],
                             T_est=T_est, Var_est=Var_est, CV2=CV2)

        group_dt <- rbind(group_dt,dt_tmp)
      }
    }
  }
  if (calc_dffits){
    Dffits <- Dffits[-1, ]
    Dffits <- Dffits[order(Dffits$G, decreasing = T),]
    row.names(Dffits) <- NULL
  }

  # return list with everything
  if (calc_dffits){
    return(list(T_h = T_h[order(T_h$stratum), ],
         Dffits = Dffits,
         Grp = group_dt[-1, ])
    )
  } else {
    return(list(T_h = T_h[order(T_h$stratum), ],
                Grp = group_dt[-1, ]))
  }


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
                     y,
                     sigma,          # estimate of sigma from model
                     model_type = "rate",
                     var_type = "normal"){
  # filter out those without ei - test only
  sample_tmp <- sample[!is.na(sample[, y]), ]


  #Xs <- sum(sample[, x])
  Xs <- sum(sample_tmp[, x])

  X <- sum(pop[, x])
  X^2 * ((X-Xs))/X * (sigma ^2) /Xs
}


#' Robust variance using CV2 method
#'
#' @param pop
#' @param sample
#' @param id
#' @param x
#' @param mod
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
                    mod,             # residuals
                    model_type = "rate",
                    var_type = "cv2"){

  # residuals
  ei <- mod$residuals

  # Calculate a_i - x's are the same in pop and sample files given
  Xs <- sum(sample[, x])
  Xr <- sum(pop[, x]) - Xs
  ai <- Xr/Xs

  # Calculate leverage (h_i)
  hi <-  hatvalues(mod)

  # Calculate di variations
  di_1 <- ei^2
  di_2 <- ei^2 /(1-hi)
  di_3 <- ei^2 /((1-hi)^2)

  # Calculate variances as sum of the two components
  V1 <- sum(ai^2 * di_1) + sum(di_1) * Xr/Xs
  V2 <- sum(ai^2 * di_2) + sum(di_2) * Xr/Xs
  V3 <- sum(ai^2 * di_3) + sum(di_3) * Xr/Xs

  list(V1=V1, V2=V2, V3=V3)

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
model_diag_old <- function(pop, samp, x, y, h_i){

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

#' Title
#'
#' @param mod
#'
#' @return
#' @export
#'
#' @examples
model_diag <- function(mod){
  r_i <- rstudent(mod)
  h_i <- hatvalues(mod)
  G <- dffits(mod)
  list(H = h_i, R = r_i, G = G)
}

