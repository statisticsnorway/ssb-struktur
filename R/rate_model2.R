#' Rate model
#' Estimates and diagnostics for estimating a total from a rate model
#'
#' @param data Population data frame
#' @param sample Sample data frame
#' @param id Name of identification variable as a string. Should be same in sample and data dataframes.
#' @param x Name of the explanatory variable
#' @param y Name of the statistic vaiable
#' @param stratum Name of the stratum variable
#'
#' @return
#' @export
#'
#' @examples
rate_model <- function(
  data,
  sample,
  id,
  x,
  y,
  stratum
  ){
  sample <- as.data.frame(sample)
  data <- as.data.frame(data)

  # Check all in population have x values
  if (any(is.na(sample[, x]))){
    stop(paste0("Some observations in the population were missing values for ",
                x,
                ". Please impute or remove these first"))
  }

  # Check all in sample have y values
  if(any(is.na(sample[, y]))){
    print(paste0("Some observations in the sample were missing values for ",
                 y,
                 ". These were removed from the model"))
  }
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

  # check stratum levels are the same in pop file and sample file
  strata_levels <- unique(data[, stratum])
  strata_levels_utvalg <- unique(sample[, stratum])
  if (!all(strata_levels %in% strata_levels_utvalg)) {
    stop("Not all strata were the same in the population file and sample file.")
  }
  strata_n <- length(strata_levels)
<<<<<<< HEAD
=======
  T_h <- data.frame(stratum = rep(NA, strata_n),
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
>>>>>>> 7b0ede2afb54db1d5080c3a768175b6bce9ecac5

  # Set up variable names - TO DO LATER: add in for each y
  y_N <- paste(y, "pop", sep = "_")
  y_n <- paste(y, "utv", sep = "_")
  y_beta <- paste(y, "beta", sep = "_")
  y_beta_ex <- paste(y, "beta", "ex", sep = "_")
  y_rstud <- paste(y, "rstud", sep = "_")
  y_hat <- paste(y, "hat", sep = "_")
  y_G <- paste(y, "G", sep = "_")
  y_imp <- paste(y, "imp", sep = "_")

  # Add sample x into population file (?) - all same in our file

  # Add y into population file
  m <- match(data[, id], sample[, id])
  data[, y] <- sample[m, y]

  # Add sums in to population file
  m_strat <- match(data[, stratum], sample[, stratum])
  data["X_pop"] <- ave(data[, x], data[, stratum], FUN = sum)
  data["X_utv"] <- ave(sample[, x], sample[, stratum], FUN = sum)[m_strat]
  data[y_N] <- ave(data[, y], data[, stratum], FUN = length)
  data[y_n] <- ave(sample[, y], sample[, stratum], FUN = length)[m_strat]

  # Set up variables
  data[, y_beta] <- NA
  data[, y_beta_ex] <- NA
  data[, y_rstud] <- NA
  data[, y_hat] <- NA
  data[, y_G] <- NA

  # Run through estimation within each stratum
  for(i in 1:strata_n){
    st <- strata_levels[i]

    # create temporary data and weights for specific stratum
    s_tmp <- sample[sample[, stratum] == st, ]
    vekt_tmp <- vekt[sample[, stratum] == st]

    # Fit model
    mod_tmp <- lm(form, data = s_tmp, weights = vekt_tmp)

    # Add beta est back to data
    m_tmp <- data[, stratum] == st
    data[m_tmp, y_beta] <- mod_tmp$coefficients

    # Individual hat, rstud and G values
    m_id <- match(s_tmp[, id], data[, id])
    data[m_id, y_rstud] <- rstudent(mod_tmp)
    data[m_id, y_hat] <- hatvalues(mod_tmp)
    data[m_id, y_G] <- dffits(mod_tmp)

    # Individual leave one out coefficients
    beta_ex <- NULL
    for (j in 1:nrow(s_tmp)){
      mod_ex <- lm(form, data = s_tmp[-j, ], weights = vekt_tmp[-j])
      beta_ex <- c(beta_ex, mod_ex$coefficients)
    }
    data[m_id, y_beta_ex] <- beta_ex

  }
  data[, y_imp] <- data[, x] * data[, y_beta]

  return(data)
}

#' Get formatted results
#' Get a table for results in each stratum for a rate model
#'
#' @param data Population data frame with additional variables from rate_model output
#' @param x Name of the explanatory variable
#' @param y Name of the statistic vaiable
#' @param stratum Name of the stratum variable
#'
#' @return
#' @export
#'
#' @examples
get_results <- function(data, x, y, stratum){

  strata_levels <- unique(data[, stratum])
  strata_n <- length(strata_levels)

  # set up names for y variable (preparation for multiple y)
  y_imp <- paste(y, "imp", sep = "_")
  y_pop <- paste(y, "pop", sep = "_")
  y_utv <- paste(y, "utv", sep = "_")
  y_beta <- paste(y, "beta", sep = "_")
  y_est <- paste(y, "est", sep = "_")
  y_var <- paste(y, "var", sep = "_")
  y_lb <- paste(y, "LB", sep = "_")
  y_ub <- paste(y, "UB", sep = "_")
  y_cv1 <- paste(y, "CV1", sep = "_")
  y_cv2 <- paste(y, "CV2", sep = "_")
  y_cv3 <- paste(y, "CV3", sep = "_")
  y_hat <- paste(y, "hat", sep = "_")

  # set up results table
  results_tab <- NULL

  for(i in 1:strata_n){
    # Set up sample and population
    st <- strata_levels[i]
    pop_tmp <- data[data[, stratum] == st & is.na(data[, y]), ]
    s_tmp <- data[data[, stratum] == st & !is.na(data[, y]), ]

    # Get residuals
    resids <- s_tmp[, y] - s_tmp[, y_imp]

    # get estimate for stratum
    T_h <- s_tmp[1, c(stratum, "X_pop", "X_utv", y_pop, y_utv)]
    T_h[, y_est] <- s_tmp[1, y_beta] * s_tmp[1, "X_pop"]

    # get varians for stratum and add in
    var_tmp <- robust_var(s_tmp[1, "X_pop"], s_tmp[1, "X_utv"],
                          resids, s_tmp[, y_hat])
    T_h[, y_var] <- var_tmp$V2
    T_h[, y_ub] <- T_h[, y_est] + 1.96 * sqrt(var_tmp$V2)
    T_h[, y_lb] <- T_h[, y_est] - 1.96 * sqrt(var_tmp$V2)

    # Add in CV
    T_h[, y_cv1] <- sqrt(var_tmp$V1)/T_h[, y_est] * 100
    T_h[, y_cv2] <- sqrt(var_tmp$V2)/T_h[, y_est] * 100
    T_h[, y_cv3] <- sqrt(var_tmp$V3)/T_h[, y_est] * 100

    # Combine with other results
    results_tab <- rbind(results_tab, T_h)
  }
  results_tab
}


#### Get groups ####
#' Get group estimates
#' Get estimates for group from rate model output
#'
#' @param data population data frame with additional variables from rate_model output
#' @param x name of the explanatory variable
#' @param y name of the statistic vaiable
#' @param stratum name of the stratum variable
#' @param groups name of variable(s) for using for groups
#'
#' @return
#' @export
#'
#' @examples
get_groups <- function(data, x, y, stratum, groups){
  # create sample
  sample <- data[!is.na(data[, y]), ]

  # Get strata results
  resultene <- get_results(data, x, y, stratum)

  # set up variable names - prep for multiple y's
  y_est <- paste(y, "est", sep="_")
  y_var <- paste(y, "var", sep="_")
  y_cv <- paste(y, "cv", sep="_")

  # Set up group data frame
  group_dt <- NULL

  # Loop through groups
  for (g in 1:length(groups)){

    # add group name to dataframe
    grp_tmp <- unique(sample[, groups[g]])

    # Create vector for group for strata in T_h dataset
    group_convert <- unique(sample[, c(stratum, groups[g])])
    m_strat <- match(resultene[, stratum], group_convert[, stratum])
    Th_grp <- group_convert[m_strat, groups[g]]

    # Sum variance and totals in each group
    for (s in 1:length(grp_tmp)){
      # set up data
      dt_tmp <- data.frame(group_navn = groups[g], group = grp_tmp[s])

      # Get group estimate, variance and cv
      dt_tmp[, y_est] <- sum(resultene[, y_est][grp_tmp[s] == Th_grp])
      dt_tmp[, y_var] <- sum(resultene[, y_var][grp_tmp[s] == Th_grp])
      dt_tmp[, y_cv] <- sqrt(dt_tmp[, y_var])/dt_tmp[, y_est] * 100

      # Combine with other groups
      group_dt <- rbind(group_dt, dt_tmp)
    }
  }
  group_dt
}

#gp_dt <- get_groups(data, x, y, stratum, groups)

#### Robust variance ####
#' Robust variance estimation
#' Internal function for robust estimation of variance
#'
#' @param Xpop Total sum of x variable in the population
#' @param X_utv Total sum of x variable in the sample
#' @param ei Residuals
#' @param hi Hat values
#'
#' @return
#'
robust_var <- function(X_pop,           # populasjon
                         X_utv,         # utvalg
                         ei,
                         hi){

  # Calculate a_i - x's are the same in pop and sample files given
  Xr <- X_pop - X_utv
  ai <- Xr/X_utv

  # Calculate di variations
  di_1 <- ei^2
  di_2 <- ei^2 /(1-hi)
  di_3 <- ei^2 /((1-hi)^2)

  # Calculate variances as sum of the two components
  V1 <- sum(ai^2 * di_1) + sum(di_1) * ai
  V2 <- sum(ai^2 * di_2) + sum(di_2) * ai
  V3 <- sum(ai^2 * di_3) + sum(di_3) * ai

  list(V1=V1, V2=V2, V3=V3)
  }

#### get extreme values ####
#' Get extreme values
#' Get extreme values in the sample dataset
#'
#' @param data Population data frame with additional variables from rate_model output
#' @param id Name of identification variable as a string. Should be same in sample and data dataframes.
#' @param x Name of the explanatory variable
#' @param y Name of the statistic variable
#' @param stratum Name of the stratum variable
#'
#' @return
#' @export
#'
#' @examples
get_extreme <- function(data, id, x, y, stratum){
  # create sample
  sample <- data[!is.na(data[, y]), ]

  # Set variable names
  y_g <- paste(y, "G", sep = "_")
  y_r <- paste(y, "rstud", sep = "_")
  y_gbound <- paste(y, "G_grense", sep = "_")
  y_rbound <- paste(y, "rstud_grense", sep = "_")
  y_utv <- paste(y, "utv", sep = "_")
  y_est <- paste(y, "est", sep = "_")
  y_est_ex <- paste(y, "est_ex", sep = "_")
  y_beta <- paste(y, "beta", sep = "_")
  y_beta_ex <- paste(y, "beta_ex", sep = "_")

  # Add boundary values
  sample[, y_gbound] <- 2 * sqrt(1/sample[, y_utv])
  sample[, y_rbound] <- 2

  # Add in estimate for strata with and without obs
  sample[, y_est] <- sample[, y_beta] * sample[, "X_pop"]
  sample[, y_est_ex] <- sample[, y_beta_ex] * sample[, "X_pop"]


  # Select observations
  condr <- abs(sample[y_r]) > sample[y_rbound]
  condg <- abs(sample[y_g]) > sample[y_gbound]
  sample <- sample[condr | condg, ]

  # select variables
  sample <- sample[, c(id, stratum, x, y, y_utv, y_est, y_est_ex,
                       y_g, y_r, y_gbound, y_rbound)]

  # Order
  sample <- sample[order(-sample[, y_g]), ]

  sample
}
#extreme <- get_extreme(data, id, x, y, stratum)

#' Plot CVs
#' Plot comparison of the different robust estimations of the CVs
#'
#' @param results output from get_results() function
#' @param y name of the statistic vaiable
#'
#' @return
#' @export
#'
#' @examples
plot_cv <- function(results, y){
  #variables
  CV1 <- paste(y, "CV1", sep = "_")
  CV3 <- paste(y, "CV3", sep = "_")

  # plot
  resultene %>%
    gather(CV, value, eval(CV1):eval(CV3)) %>%
    ggplot(aes(stratum, value, fill = CV)) +
    geom_bar(stat = "identity", position='dodge')

}
#plot_cv(resultene, y)

#' Plot extreme values
#' Plot comparison of the different extreme values using G-values or estimate comparisons.
#'
#' @param data Data frame output from get_extreme() function
#' @param id Name of identification variable as a string. Should be same in sample and data dataframes.
#' @param y Name of the statistic variable
#' @param num The number of outlier units to show. Default is 10.
#' @param type The type of plot to show. 'G' output a plot of the G values compared to the boundary, type 'estimate' gives a comparison in stratum estimates with and without the observation
#'
#' @return
#' @export
#'
#' @examples
plot_extreme <- function(data, id, y, num = 10, type = "G"){
  if (!type %in% c("G", "estimate")){
    stop("Type must be 'G' or 'estimate'")
  }

  extr <- data[1:num, ]
  extr$.ID <- factor(extr[, id], levels = extr[, id])
  y_g <- paste(y, "G", sep = "_")
  y_gg <- paste(y, "G_grense", sep = "_")

  # set plot window
  options(repr.plot.width=12, repr.plot.height=8)
  dev.new(height = 8, width = 12)

  if(type == "G"){
    p <- extr %>%
      ggplot(aes(x=.ID)) +
      geom_col(aes_string(y=y_g)) +
      geom_segment(aes_string(x = (1:num) -0.5, xend = (1:num) + 0.5,
                              y = y_gg, yend = y_gg,
                              color = "'red'")) +
      xlab("ID") +
      ylab("G value") +
      scale_color_manual(labels = "G boundary", values =  "red") +
      theme(legend.title=element_blank())

  } else if(type == "estimate"){
    p <- extr %>%
      gather(exclude, estimate, eval(y_est):eval(y_est_ex)) %>%
      ggplot(aes(.ID, estimate, fill = exclude)) +
      geom_bar(stat = "identity", position='dodge') +
      scale_fill_discrete(name = "Include/exclude observation",
                          labels = c("exclude", "include"))
  }
  p
}
#plot_extreme(extreme, id, y)

