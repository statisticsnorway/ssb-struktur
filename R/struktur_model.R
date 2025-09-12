#' Run a struktur model
#' 
#' Estimates total and uncertainty for a rate, homogeneous or regression model within strata.
#'
#' @param data Population data frame
#' @param sample_data Sample data frame
#' @param id Name of identification variable as a string. Should be same in sample_data and data dataframes.
#' @param x Name of the explanatory variable.
#' @param y Name of the statistic variable.
#' @param strata Name of the strata variable.
#' @param exclude Vector of id numbers to exclude from the model. This observations will be included 
#' in the total with their observed values.
#' @param method Model methods to use. Default is 'rate' for a rate model. Also 'homogen' and 'reg'
#' for regression model will be available soon. 
#'
#' @return Data frame for whole population with mass-imputation values.
#' Other variables, beta estimates are also included
#' @export
struktur_model <- function(
  data,
  sample_data = NULL,
  id,
  x,
  y,
  strata,
  exclude = NULL,
  method = "rate"){
  
  # Check y is in the data sets
  if (!y %in% c(names(data), names(sample_data))){
    stop(paste0("The variable ", y, " could not be found in the data sets." ))
  }
  
  # Add strata variable(s) to sample data if not found
  strata_tmp <- strata[!strata %in% names(sample_data)]
  if (!is.null(sample_data) & length(strata_tmp)>0) {
    m <- match(data[, id], sample_data[, id])
    sample_data[strata_tmp] <- data[!is.na(m), strata_tmp] 
  }
  
  # need to set up sample data frame if no data is given - TO DO LATER: set up for multiple y's
  if (is.null(sample_data)){
    sample_data <- data[!is.na(data[, y]), ]
    message(paste0("No sample data was given so using data with non-na values of ", y, " as the sample."))
  }
  
  # set up data as data frames (not tibble)
  sample_data <- as.data.frame(sample_data)
  data <- as.data.frame(data)
  
  # Check for a valid method
  if (!method %in% c("rate", "regression", "homogen")){
    stop("The method should be one of: 'rate', 'regression' or 'homogen'")
  }
  
  # Temporary stop in methods that are not written yet
  if (method != "rate"){
    stop("Only rate models are currently programmed. Please contact the Methods department as SSB if you want an alternative model.")
  }
  
  # Check all in sample and population have x values
  if (any(is.na(sample_data[, x]))){
    cond <- is.na(sample_data[, x])
    m <- match(sample_data[cond, id], data[, id])
    message(paste0("There were ", length(m[!is.na(m)]),
                   " observations in the sample without values for ",
                   x, " that were replace by values from the population dataset"))
    sample_data[cond, x] <- data[m, x]
    if (any(is.na(m))){
      print(paste0("There were ", sum(is.na(m)),
                   " observations in the sample that were missing values for ", x,
                   " and were removed from the model"))
    }
    sample_data <- sample_data[!is.na(sample_data[, x]),]
  }
  
  if (any(is.na(data[, x]))){
    cond <- is.na(data[, x])
    m <- match(data[cond, id], sample_data[, id])
    if (any(is.na(m))){
      stop(paste0("There was ", length(m[is.na(m)]),
                  " observations in the population data without values for ", x,
                  ". These need to be imputed or removed before modelling."))
    }
    message(paste0("There were ", length(m[!is.na(m)]),
                   " observations in the population data without values for",
                   x, " that were replace by values from the sample dataset"))
    data[cond, x] <- sample_data[m, x]
    
  }
  
  # Check all in sample_data have y values. TO DO LATER: adjust for multiple y's.
  if(any(is.na(sample_data[, y]))){
    ynum <- sum(is.na(sample_data[, y]))
    message(paste0("There were ", ynum,
                   " observations that were missing values for ", y,
                   ". These were removed from the model"))
    
    sample_data <- sample_data[!is.na(sample_data[, y]),]
  }
  
  # create formula and weights
  form <- stats::as.formula(paste(y, "~", x, "-1"))
  vekt <- 1/sample_data[, x]
  
  # Adjust to allow zeros in the explanatory variable (otherwise weight is inf)
  tab <- table(vekt == Inf)
  if (length(tab) > 1){
    message("Some observation have zero as their explanatory variable and were adjusted (1/(x+1)) to allow a real weight input")
    vekt[vekt == Inf] <- 1/(sample_data[, x]+1)
  }
  
  # Add in strata variable
  if (length(strata) > 1){
    data[, ".strata"] <- apply(data[, strata ], 1, paste, collapse = "_")
    sample_data[, ".strata"] <- apply(sample_data[, strata ], 1, paste, collapse = "_")
    strata <- ".strata"
  } 
  
  # Check strata levels are the same in pop file and sample files
  strata_levels <- unique(data[, strata])
  strata_levels_utvalg <- unique(sample_data[, strata])
  if (!all(strata_levels %in% strata_levels_utvalg)) {
    stop("Not all strata were the same in the population file and sample file.")
  }
  strata_n <- length(strata_levels)
  
  # Check if any strata have only 1 obs
  m <- table(sample_data[, strata]) == 1
  if (any(m)) {
    strata1 <- table(sample_data[, strata])[m]
    warning(paste("The following strata have only 1 observation in the sample: ", 
                  paste(names(strata1), collapse = ","), 
                  ". These strata have 0 as their variance. Consider merging strata!"))
  } else strata1 <- NULL
  
  
  # Set up variable names - TO DO LATER: add in for each y (create loop)
  y_N <- paste(y, "pop", sep = "_")
  y_n <- paste(y, "utv", sep = "_")
  y_beta <- paste(y, "beta", sep = "_")
  y_beta_ex <- paste(y, "beta", "ex", sep = "_")
  y_rstud <- paste(y, "rstud", sep = "_")
  y_hat <- paste(y, "hat", sep = "_")
  y_G <- paste(y, "G", sep = "_")
  y_imp <- paste(y, "imp", sep = "_")
  y_flag <- paste(y, "flag", sep = "_")
  x_pop <- paste(x, "pop", sep = "_")
  x_utv <- paste(x, "utv", sep = "_")
  
  # TO DO LATER: Add sample x into population file (?) - all same in our test file
  
  # Add y into population file
  m <- match(data[, id], sample_data[, id])
  data[, y] <- sample_data[m, y]
  data[ ,"s_flag"] <- ifelse(is.na(m), 0, 1)
  
  # Create .strata and surprise strata
  data[, ".strata"] <- data[, strata]
  sample_data[, ".strata"] <- sample_data[, strata]
  
  if (!is.null(exclude)){
    m <- match(exclude, data[, id])
    data[m, ".strata"] <- "surprise_strata"
    strata_levels <- c(strata_levels, "surprise_strata")
    strata_n <- strata_n + 1
    m2 <- match(exclude, sample_data[, id])
    sample_data[m2, ".strata"] <- "surprise_strata"
  } 
  
  # Add sums to population file
  m_strat <- match(data[, ".strata"], sample_data[, ".strata"])
  data[x_pop] <- stats::ave(data[, x], data[, ".strata"], FUN = sum)
  data[x_utv] <- stats::ave(sample_data[, x], sample_data[, ".strata"], FUN = sum)[m_strat]
  data[y_N] <- stats::ave(data[, y], data[, ".strata"], FUN = length)
  data[y_n] <- stats::ave(sample_data[, y], sample_data[, ".strata"], FUN = length)[m_strat]
  
  # Set up variables
  data[, y_beta] <- NA
  data[, y_beta_ex] <- NA
  data[, y_rstud] <- NA
  data[, y_hat] <- NA
  data[, y_G] <- NA
  data[, y_imp] <- NA
  data[, y_flag] <- "pred"
  
  # Run through estimation within each strata
  for(i in 1:strata_n){
    st <- strata_levels[i]
    m_tmp <- data[, ".strata"] == st
    
    # create temporary data for specific stratum
    s_tmp <- sample_data[sample_data[, ".strata"] == st, ]
    
    # add columns if surprise stratum
    if (st == "surprise_strata"){
      data[m_tmp, y_imp] <- data[m_tmp, y]
      data[m_tmp, y_flag] <- "ex"
    } else {
      
      # create temporary data and weights for specific stratum
      s_tmp <- sample_data[sample_data[, strata] == st, ]
      
      # remove excluded observations
      s_ex <- s_tmp[s_tmp[, id] %in% exclude, ]
      s_tmp <- s_tmp[!s_tmp[, id] %in% exclude, ]
      
      # Create weights and fit model
      if (method == "rate"){
        vekt_tmp <- vekt[sample_data[, ".strata"] == st] #####
        mod_tmp <- stats::lm(form, data = s_tmp, weights = vekt_tmp)
      }
      
      # Add beta est back to data
      data[m_tmp, y_beta] <- mod_tmp$coefficients
      
      # Individual hat, rstud and G values
      m_id <- match(s_tmp[, id], data[, id])
      data[m_id, y_rstud] <- stats::rstudent(mod_tmp)
      data[m_id, y_hat] <- stats::hatvalues(mod_tmp)
      data[m_id, y_G] <- stats::dffits(mod_tmp)
      
      # Individual leave one out coefficients - change for 1 obs
      if (length(strata1) == 0){
      
        beta_ex <- NULL
        for (j in 1:nrow(s_tmp)){
          mod_ex <- stats::lm(form, data = s_tmp[-j, ], weights = vekt_tmp[-j])
          beta_ex <- c(beta_ex, mod_ex$coefficients)
        }
      } else {
        beta_ex <- mod_tmp$coefficients
      }
      # add in variables for all
      data[m_tmp, y_imp] <- data[m_tmp, x] * data[m_tmp, y_beta]
      
      # add in sample variables
      data[m_id, y_beta_ex] <- beta_ex 
      data[m_id, y_flag] <- "mod"
      data[m_id, y_imp] <- data[m_id, y]
      
    }
  }
  
  # label id and strata variable for later identification
  var_labels = c(strata="Stratification variable", id="Identification variable")
  Hmisc::label(data) = as.list(var_labels[match(names(data), c(strata, id))])
  
  return(data)
}


#' Get strata results
#' Get a table for results in each stratum for a rate model
#'
#' @param data Population data frame with additional variables from rate_model output
#' @param x Name of the explanatory variable
#' @param y Name of the statistic variable
#'
#' @return Table with strata results
#'
get_strata_results <- function(data, x=NULL, y=NULL){
  strata <- get_var(data, "strata")
  if (is.null(x)) x <- get_var(data, "x")
  if (is.null(y)) y <- get_var(data, "y")
  
  strata_levels <- unique(data[, strata])
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
  x_pop <- paste(x, "pop", sep = "_")
  x_utv <- paste(x, "utv", sep = "_")
  
  # set up results table
  results_tab <- NULL
  
  for(i in 1:strata_n){
    # Set up sample and population
    st <- strata_levels[i]
    pop_tmp <- data[data[, strata] == st & is.na(data[, y]), ]
    s_tmp <- data[data[, strata] == st & !is.na(data[, y]), ]
    
    # check if fulltelling
    if(nrow(pop_tmp) == 0){
      T_h <- s_tmp[1, c(strata, x_pop, x_utv, y_pop, y_utv)]
      T_h[, c(y_est, y_ub, y_lb)] <- sum(s_tmp[, y])
      T_h[,c(y_var, y_cv1, y_cv2, y_cv3)] <- 0
      message("Some strata are full count strata. Their variance is set to 0.")
      
    # Check if single obs strata
    } else if(nrow(s_tmp) == 1) {
      T_h <- s_tmp[1, c(strata, x_pop, x_utv, y_pop, y_utv)]
      T_h[, c(y_est, y_ub, y_lb)] <- s_tmp[1, y_beta] * s_tmp[1, x_pop]
      T_h[,c(y_var, y_cv1, y_cv2, y_cv3)] <- 0
      
    # Rest
    } else {
      
      # Get residuals
      resids <- s_tmp[, y] - (s_tmp[, x] * s_tmp[, y_beta])
      
      # get estimate for stratum
      T_h <- s_tmp[1, c(strata, x_pop, x_utv, y_pop, y_utv)]
      T_h[, y_est] <- s_tmp[1, y_beta] * s_tmp[1, x_pop]
      
      # get varians for stratum and add in
      var_tmp <- robust_var(s_tmp[1, x_pop], s_tmp[1, x_utv],
                            resids, s_tmp[, y_hat])
      T_h[, y_var] <- var_tmp$V2
      T_h[, y_ub] <- T_h[, y_est] + 1.96 * sqrt(var_tmp$V2)
      T_h[, y_lb] <- T_h[, y_est] - 1.96 * sqrt(var_tmp$V2)
      
      # Add in CV
      T_h[, y_cv1] <- sqrt(var_tmp$V1)/T_h[, y_est] * 100
      T_h[, y_cv2] <- sqrt(var_tmp$V2)/T_h[, y_est] * 100
      T_h[, y_cv3] <- sqrt(var_tmp$V3)/T_h[, y_est] * 100
    }
    
    # Combine with other results
    results_tab <- rbind(results_tab, T_h)
  }
  results_tab <- results_tab[order(results_tab[, strata]), ]
  if ("surprise_strata" %in% results_tab[, strata]){
    m <- match("surprise_strata", results_tab[, strata])
    results_tab <- rbind(results_tab[order(results_tab[-m, strata]), ],
                         results_tab[m, ])
  }
  row.names(results_tab) <- NULL
  results_tab
}


#### Get estimates for strata/group ####
#' Get estimates
#' Get estimates for groups (or strata) from rate model output
#'
#' @param data Population data frame with additional variables from rate_model output
#' @param x Name of the explanatory variable.
#' @param y Name of the statistic variable to estimate.
#' @param group Name of variable(s) for using for groups.
#'
#' @return Table with strata or group results
#' @export
#'
get_results <- function(data, x=NULL, y=NULL, group=NULL){
  strata <- get_var(data, "strata")
  if (is.null(x)) x <- get_var(data, "x")
  if (is.null(y)) y <- get_var(data, "y")
  if (is.null(group)) group <- strata
  
  # create sample
  sample_data <- data[!is.na(data[, y]), ]
  
  # Get strata results
  resultene <- get_strata_results(data, x, y)
  is_surprise <- "surprise_strata" %in% resultene[, strata]
  
  if (length(group) == 1 & (group[1] == strata | group[1] == ".strata")) {
    return(resultene)
  }
  
  # Check whether group variables cut across strata
  if(length(group) > 1) {
    sample_data[, ".group"] <- apply(sample_data[, group], 
                                     1, paste, collapse = "_")
  } else sample_data[, ".group"] <- sample_data[, group]
  strata_n <- length(unique(sample_data[, strata]))
  st_group_n <- nrow(unique(sample_data[, c(strata, ".group")]))
  if(st_group_n > strata_n) {
    stop("One or more group variables cut across strata. Set group variables in a way that strata are the most detailed levels within each group.")
  }
  
  

  # set up variable names - prep for multiple y's
  y_est <- paste(y, "est", sep="_")
  y_var <- paste(y, "var", sep="_")
  y_ub <- paste(y, "UB", sep="_")
  y_lb <- paste(y, "LB", sep="_")
  y_cv2 <- paste(y, "CV2", sep="_")
  y_cv1 <- paste(y, "CV1", sep="_")
  y_cv3 <- paste(y, "CV3", sep="_")
  y_var1 <- paste(y, "var1", sep="_")
  y_var3 <- paste(y, "var3", sep="_")
  

  # Add the other two robust variances
  resultene[, y_var1] <- (resultene[, y_cv1] * resultene[, y_est] / 100)^2
  resultene[, y_var3] <- (resultene[, y_cv3] * resultene[, y_est] / 100)^2
  
    
  # Set up group data frame
  group_dt <- NULL
  
  # Loop through groups
  for (g in 1:length(group)){
    
    # add group name to dataframe
    grp_tmp <- unique(sample_data[, group[g]])
    
    # Create vector for group for strata in T_h dataset
    if (is_surprise){
      group_convert <- unique(sample_data[, c(strata, group[g])]) 
      
      #exclude surprise strata first
      m_surprise <- match("surprise_strata", resultene[, strata])
      if(!is.na(m_surprise)){
        resultene <- resultene[-m_surprise, ]
      }
      m_strat <- match(resultene[, strata], group_convert[, strata]) 
    } else {
      group_convert <- unique(sample_data[, c(strata, group[g])])
      m_strat <- match(resultene[, strata], group_convert[, strata])
    }
    Th_grp <- group_convert[m_strat, group[g]]
    
    # Sum variance and totals in each group
    for (s in 1:length(grp_tmp)){
      # set up data
      dt_tmp <- data.frame(group_name = group[g], group = grp_tmp[s])
      
      # Get group estimate, variance and cv
      dt_tmp[, y_est] <- sum(resultene[, y_est][grp_tmp[s] == Th_grp])
      y_V1_tmp <- sum(resultene[, y_var1][grp_tmp[s] == Th_grp])
      y_V3_tmp <- sum(resultene[, y_var3][grp_tmp[s] == Th_grp])
      dt_tmp[, y_var] <- sum(resultene[, y_var][grp_tmp[s] == Th_grp])
      dt_tmp[, y_ub] <- dt_tmp[, y_est] + 1.96 * sqrt(dt_tmp[, y_var])
      dt_tmp[, y_lb] <- dt_tmp[, y_est] - 1.96 * sqrt(dt_tmp[, y_var])
      dt_tmp[, y_cv1] <- sqrt(y_V1_tmp)/dt_tmp[, y_est] * 100 
      dt_tmp[, y_cv2] <- sqrt(dt_tmp[, y_var])/dt_tmp[, y_est] * 100
      dt_tmp[, y_cv3] <- sqrt(y_V3_tmp)/dt_tmp[, y_est] * 100 
      
      # Combine with other groups
      group_dt <- rbind(group_dt, dt_tmp)
    }
    if (is_surprise){
      surprise_obs <- sample_data[sample_data[, strata] == "surprise_strata", ]
      for (u in 1:nrow(surprise_obs)){
        # find right group to add to
        m <- match(surprise_obs[u, strata], group_convert[, 1])
        Th_sur_group <- match(group_convert[m, group[g]], group_dt[, "group"])
        
        # add in total and adjust cv
        y_V1_tmp <- (group_dt[Th_sur_group, y_cv1] * group_dt[Th_sur_group, y_est] / 100)^2
        y_V3_tmp <- (group_dt[Th_sur_group, y_cv3] * group_dt[Th_sur_group, y_est] / 100)^2
        group_dt[Th_sur_group, y_est] <- group_dt[Th_sur_group, y_est] + surprise_obs[u, y]
        group_dt[Th_sur_group, y_cv1] <- sqrt(y_V1_tmp)/group_dt[Th_sur_group, y_est] * 100
        group_dt[Th_sur_group, y_cv2] <- sqrt(group_dt[Th_sur_group, y_var])/group_dt[Th_sur_group, y_est] * 100
        group_dt[Th_sur_group, y_cv3] <- sqrt(y_V3_tmp)/group_dt[Th_sur_group, y_est] * 100
      }
    }
  }
  group_dt
}


#### Robust variance ####
#' Robust variance estimation
#' Internal function for robust estimation of variance
#'
#' @param x_pop Total sum of x variable in the population
#' @param x_utv Total sum of x variable in the sample
#' @param ei Residuals
#' @param hi Hat values
#' @param method Method to use in calculation. Default set to 'rate'
#'
#' @return Robust variance estimates
robust_var <- function(x_pop,           # populasjon
                       x_utv,           # utvalg
                       ei,
                       hi,
                       method = "rate"){
  if (method != "rate"){
    stop("Only rate model robust estimation is implemented. Contact Methods for help.")
  }
  
  # Calculate a_i - x's are the same in pop and sample files given
  Xr <- x_pop - x_utv
  ai <- Xr/x_utv
  
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


#' Get extreme values
#' Get extreme values in the sample dataset
#'
#' @param data Population data frame with additional variables from rate_model output
#' @param id Name of identification variable as a string. Should be same in sample and data dataframes.
#' @param x Name of the explanatory variable
#' @param y Name of the statistic variable
#' @param na_rm Logical for whether to remove NA values. Default = TRUE.
#'
#' @return A data frame is return containing observations that have values that may be seen as outlier/extreme values
#' @export
get_extremes <- function(data, id=NULL, x=NULL, y=NULL, na_rm = TRUE){
  strata <- get_var(data, "strata")
  if (is.null(id)) id <- get_var(data, "id")
  if (is.null(x)) x <- get_var(data, "x")
  if (is.null(y)) y <- get_var(data, "y")
  
  # create sample
  sample_data <- data[!is.na(data[, y]), ]
  sample_data <- sample_data[sample_data[, strata] != "surprise_strata", ]
  
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
  x_pop <- paste(x, "pop", sep = "_")
  x_utv <- paste(x, "utv", sep = "_")
  
  # Add boundary values
  sample_data[, y_gbound] <- 2 * sqrt(1/sample_data[, y_utv])
  sample_data[, y_rbound] <- 2
  
  # Add in estimate for strata with and without obs
  sample_data[, y_est] <- sample_data[, y_beta] * sample_data[, x_pop]
  sample_data[, y_est_ex] <- sample_data[, y_beta_ex] * sample_data[, x_pop]
  
  
  # Select observations
  condr <- abs(sample_data[y_r]) > sample_data[y_rbound]
  condg <- abs(sample_data[y_g]) > sample_data[y_gbound]
  if(na_rm){
    condr[is.na(condr)] <- FALSE
    condg[is.na(condg)] <- FALSE
  } else {
    condr[is.na(condr)] <- TRUE
    condg[is.na(condg)] <- TRUE
  }
  
  sample_data <- sample_data[condr | condg, ]
  
  # select variables
  sample_data <- sample_data[, c(id, strata, x, y, y_utv, y_est, y_est_ex,
                                 y_g, y_r, y_gbound, y_rbound)]
  
  # Order
  sample_data <- sample_data[order(-sample_data[, y_g]), ]
  row.names(sample_data) <- NULL
  
  sample_data
}


#' Plot CVs
#' Plot comparison of the different robust estimations of the CVs
#'
#' @param data Data which is the output from get_results() function
#' @param y Name of the statistic variable
#'
#' @return Plot of cv comparisons
#' @export
plot_cv <- function(data, y){
  strata <- get_var(data, "strata")
  if (is.null(x)) x <- get_var(data, "x")
  if (is.null(y)) y <- get_var(data, "est")[1] # just plot first one for time being
  
  #variables
  CV1 <- paste(y, "CV1", sep = "_")
  CV2 <- paste(y, "CV2", sep = "_")
  CV3 <- paste(y, "CV3", sep = "_")
  
  if (!CV1 %in% names(data)){
    stop("CV calculations were not found in dataset. Please run main function 'struktur_model' first and then the function get_results.")
  }
  
  # Data needs to be in long format for ggplot
  data_long <- rbind(data, data, data)
  data_long <- data_long[, -match(c(CV1, CV2, CV3), names(data_long))]
  cv_all <- utils::stack(list(cv1 = as.vector(data[, CV1]), 
                       cv2 = as.vector(data[, CV2]), 
                       cv3 = as.vector(data[, CV3])))
  data_long$CV_type <- cv_all$ind
  data_long$CV <- cv_all$values
  
  # plot
  ggplot2::ggplot(data_long, ggplot2::aes_string(strata, "CV", fill = "CV_type")) +
    ggplot2::geom_bar(stat = "identity", position='dodge') +
    ggplot2::scale_x_discrete(guide = ggplot2::guide_axis(angle = 90)) +
    ggplot2::ylab("CV value (%)")
  
}


#' Plot extreme values
#' Plot comparison of the different extreme values using G-values or estimate comparisons.
#'
#' @param data Data frame output from get_extreme() function
#' @param id Name of identification variable as a string.
#' @param y Name of the statistic variable.
#' @param size The number of outlier units to show. Default is 10.
#' @param type The type of plot to show. 'G' output a plot of the G values compared to the boundary, type 'estimate' gives a comparison in strata estimates with and without the observation.
#' @param ylim The upper limit to show in the plot.
#'
#' @return Plot showing either comparison of estimates with and 
#' without observation point or comparison of G values.
#' @export
plot_extreme <- function(data, id = NULL, y = NULL, size = 10, type = "G", ylim = NULL) {
  if (!type %in% c("G", "estimate")) {
    stop("Type must be 'G' or 'estimate'")
  }
  
  if (is.null(id)) id <- get_var(data, "id")
  if (is.null(y)) y <- get_var(data, "y")
  .ID <- .estimate <- .exclude <- NULL
  
  extr <- data[1:size, ]
  extr$.ID <- factor(extr[, id], levels = extr[, id])
  y_g <- paste(y, "G", sep = "_")
  y_gg <- paste(y, "G_grense", sep = "_")
  
  # open new plot window if running RStudio
  if (Sys.getenv("RSTUDIO") == "1"){
    options(repr.plot.width = 12, repr.plot.height = 8)
    grDevices::dev.new(height = 8, width = 12)
  }
  
  if (type == "G") {
    if (is.null(ylim)) {
      ylim <- max(data[, y_g], na.rm = T)
    }
    
    p <- ggplot2::ggplot(extr, ggplot2::aes(x=.ID)) +
      ggplot2::geom_col(ggplot2::aes_string(y=y_g)) +
      ggplot2::geom_segment(ggplot2::aes_string(x = (1:size) -0.5, xend = (1:size) + 0.5,
                              y = y_gg, yend = y_gg,
                              color = "'red'")) +
      ggplot2::xlab(id) +
      ggplot2::ylab("G value") +
      ggplot2::scale_color_manual(labels = "G boundary", values =  "red") +
      ggplot2::coord_cartesian(ylim = c(0, ylim)) +
      ggplot2::theme(legend.title = ggplot2::element_blank()) +
      ggplot2::scale_x_discrete(guide = ggplot2::guide_axis(angle = 90))
    
  } else if (type == "estimate") {
    y_est <- paste(y, "est", sep = "_")
    y_est_ex <- paste(y, "est_ex", sep = "_")
    
    # Data needs to be in long format
    
    include_all <- utils::stack(list(include = as.vector(extr[, y_est]), 
                              exclude = as.vector(extr[, y_est_ex])))
    extr_long <- rbind(extr, extr)
    extr_long$.estimate <- include_all$values
    extr_long$.exclude <- include_all$ind
    #p <- extr %>%
    #  gather(exclude, estimate, eval(y_est):eval(y_est_ex))# %>%
    p <- ggplot2::ggplot(extr_long, ggplot2::aes(.ID, .estimate, fill = .exclude)) +
      ggplot2::geom_bar(stat = "identity", position='dodge') +
      ggplot2::scale_fill_discrete(name = "Include/exclude observation",
                          labels = c("include", "exclude")) +
      ggplot2::ylab("strata estimate") + 
      ggplot2::xlab(id)
  }
  p
}

#' Get variable names
#' @param data Data frame to find variables in
#' @param var Variable to find. Can be 'x', 'y', 'id' or 'strata'
#' 
#' @return variable name
get_var <- function(data, var){
  if (var == "y"){
    i <- endsWith(names(data), '_rstud')
    return(gsub('_rstud', '', names(data)[i]))
  } 
  if (var == "x"){
    .y <- get_var(data, "y")
    i <- grepl('_utv', names(data), fixed = T)
    .all <- gsub('_utv', '', names(data)[i])
    return(.all[!.all %in% .y])
  }
  if (var == "est"){
    i <- grepl('_est', names(data), fixed = T)
    return(gsub('_est', '', names(data)[i]))
  }
  
  if (var == "id") label.name <- "Identification variable"
  if (var == "strata") label.name <- "Stratification variable"
  i <- match(label.name, Hmisc::label(data))
  
  return(names(data)[i])
  
}
