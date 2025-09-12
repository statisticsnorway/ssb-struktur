#' Merge lonely strata
#' 
#' Merge lonely strata that are being neither surprise nor full-count within blocks.
#'
#' @param data Population data frame
#' @param sample_data Sample data frame
#' @param id Name of identification variable as a string. Should be same in sample_data and data dataframes.
#' @param x Name of the explanatory variable.
#' @param y Name of the statistic variable.
#' @param strata Name of the strata variable(s).
#' @param exclude Vector of id numbers to exclude from the model. This observations will be included 
#' in the total with their observed values.
#' @param block Name of variable(s) for using for blocks within which strata merge may take place.
#' @param group Name of variable(s) for using for groups.
#'
#' @return Data frame for whole population with estimation strata obtained from strata merge, 
#' and an indicator for merge (1 if merge took place, 0 otherwise).
#' @export
merge_lonely_strata <- function(data, sample_data = NULL, id, x, y, strata, exclude = NULL, 
                         block = NULL, group = NULL) 
{
  if (!y %in% c(names(data), names(sample_data))) {
    stop(paste0("The variable ", y, " could not be found in the data sets."))
  }

  # Add strata variable(s) to sample data if not found
  strata_tmp <- strata[!strata %in% names(sample_data)]
  if (!is.null(sample_data) & length(strata_tmp)>0) {
    m <- match(data[, id], sample_data[, id])
    sample_data[strata_tmp] <- data[!is.na(m), strata_tmp] 
  }
  
  # Add block variable(s) to sample data if not found
  block_tmp <- block[!block %in% names(sample_data)]
  if (!is.null(sample_data) & !is.null(block) & length(block_tmp>0)) {
    m <- match(data[, id], sample_data[, id])
    sample_data[block_tmp] <- data[!is.na(m), block_tmp] 
  }
  
  # Add group variable(s) to sample data if not found
  group_tmp <- group[!group %in% names(sample_data)]
  if (!is.null(sample_data) & !is.null(group) & length(group_tmp>0)) {
    m <- match(data[, id], sample_data[, id])
    sample_data[group_tmp] <- data[!is.na(m), group_tmp] 
  }
  
  # Set up sample data frame if no data is given
  if (is.null(sample_data)) {
    sample_data <- data[!is.na(data[, y]), ]
    message(paste0("No sample data was given so using data with non-na values of ", 
                   y, " as the sample."))
  }
  
  # Set up data as data frames (not tibble)
  sample_data <- as.data.frame(sample_data)
  data <- as.data.frame(data)
  
  

  if (any(is.na(sample_data[, x]))) {
    cond <- is.na(sample_data[, x])
    m <- match(sample_data[cond, id], data[, id])
    message(paste0("There were ", length(m[!is.na(m)]), " observations in the sample without values for ", 
                   x, " that were replaced by values from the population dataset"))
    sample_data[cond, x] <- data[m, x]
    if (any(is.na(m))) {
      print(paste0("There were ", sum(is.na(m)), " observations in the sample that were missing values for ", 
                   x, " and were removed from the model"))
    }
    sample_data <- sample_data[!is.na(sample_data[, x]), 
    ]
  }
  
  if (any(is.na(data[, x]))) {
    cond <- is.na(data[, x])
    m <- match(data[cond, id], sample_data[, id])
    if (any(is.na(m))) {
      stop(paste0("There was ", length(m[is.na(m)]), " observations in the population data without values for ", 
                  x, ". These need to be imputed or removed before modelling."))
    }
    message(paste0("There were ", length(m[!is.na(m)]), " observations in the population data without values for", 
                   x, " that were replaced by values from the sample dataset"))
    data[cond, x] <- sample_data[m, x]
  }
  
  
  if (any(is.na(sample_data[, y]))) {
    ynum <- sum(is.na(sample_data[, y]))
    message(paste0("There were ", ynum, " observations that were missing values for ", 
                   y, ". These were removed from the sample data"))
    sample_data <- sample_data[!is.na(sample_data[, y]), 
    ]
  }
  
  
  # Variables to be removed from population data at the end
  remove_vrblist <- y
  
  
  if (length(strata) > 1) {
    data[, ".strata"] <- apply(data[, strata], 1, paste, 
                               collapse = "_")
    sample_data[, ".strata"] <- apply(sample_data[, strata], 
                                      1, paste, collapse = "_")
    strata <- ".strata"
    remove_vrblist <- c(remove_vrblist, ".strata")
  }
  
  strata_levels <- unique(data[, strata])
  strata_levels_utvalg <- unique(sample_data[, strata])
  if (!all(strata_levels %in% strata_levels_utvalg)) {
    stop("Not all strata were the same in the population file and sample file.")
  }
  
  
  # Add y into population file
  m <- match(data[, id], sample_data[, id])
  data[, y] <- sample_data[m, y]


  
  
  # Add in block variable
  if(length(block) > 1) {
    sample_data[, ".block"] <- apply(sample_data[, block], 
                                   1, paste, collapse = "_")
    block <- ".block"
  }
  

  # Add in group variable
  if(length(group) > 1) {
    sample_data[, ".group"] <- apply(sample_data[, group], 
                                   1, paste, collapse = "_")
    group <- ".group"
  }
  
  

  m <- table(sample_data[, strata]) == 1
  if (any(m)) {
    strata1 <- table(sample_data[, strata])[m]
  } else strata1 <- NULL
  

  
  
  # Check whether strata with only 1 observation are surprise strata
  if(length(strata1) > 0) {
    st_surprise <- NULL
    if (!is.null(exclude)) {
      m <- match(exclude, data[, id])
      sel <- names(strata1) %in% unique(data[m, ".strata"])
      if(any(sel)) {
        st_surprise <- names(strata1)[sel]
        message(paste("The following strata were surprise strata with only 1 observation in the sample: ", 
                      paste(names(strata1)[sel], collapse = ","), 
                      ". No need for strata merge since their variance will be set to 0"))
        if(sum(sel) < length(strata1)) {
          strata1 <- strata1[!sel]
        } else strata1 <- NULL
      }
    }
  }

  
  # Check whether non-surprise strata with only 1 observation are full count strata 
  if(length(strata1) > 0) {
    sel <- NULL
    for(i in 1:length(strata1)) {
      sel <- c(sel, nrow(data[data[, strata] == names(strata1)[i] & is.na(data[,y]), ]) == 0)
    }
    st_fc <- NULL
    if(any(sel)){
      st_fc <- names(strata1)[sel]
      message(paste("The following strata are full count strata with only 1 observation in the sample: ",
                    paste(names(strata1)[sel], collapse = ","),
                    ". No need for strata merge since their variance will be set to 0."))
      if(sum(sel) < length(strata1)) {
        strata1 <- strata1[!sel]
      } else strata1 <- NULL
    }
  }

  
  if(length(strata1) == 0) {
    message("There were no lonely strata in the sample that were neither surprise nor full count.\nThus, strata merge did not take place.")
    return(message(paste0("Use the design strata for the variable ", y, " in the next steps of the estimation functions as the value of the strata parameter.")))
  }
    
  if(length(strata1) > 0) {
    # Exclude observations in surprise or full count strata from the sample
    if(length(st_surprise) > 0 | length(st_fc) > 0) {
      sel <- sample_data[, strata] %in% c(st_surprise, st_fc)
      sample_exclude <- sample_data[sel, ]
      tmp_sdata <- sample_data[!sel, ]
    } else tmp_sdata <- sample_data
    
    strata_n <- length(unique(tmp_sdata[, strata]))

    
    # Check whether blocks cut across strata
    if(length(block) > 0) {
      tmp_sdata[, block] <- factor(tmp_sdata[, block])
      st_block_n <- nrow(unique(tmp_sdata[, c(strata, block)]))
      if(st_block_n > strata_n) {
        stop("One or more block variables cut across strata. Set block variables in a way that strata are the most detailed levels within each block.")
      }
      formula_block <- formula(paste("~", block, sep = " "))
    } else formula_block <- NULL
    
    
    message(paste("The following strata, being neither surprise nor full count, had only 1 observation in the sample: ", 
                  paste(names(strata1), collapse = ","), ". Strata merge was attempted."))
    
    
    # Add population mean of x to the sample
    Xbar <- stats::ave(data[, x], data[, strata])
    m <- match(tmp_sdata[, id], data[, id])
    tmp_sdata["Xbar"] <- Xbar[m]
    
    # Add fake weight variable (w0) to sample file
    tmp_sdata["w0"] <- 1
    
    # Set parameters
    tmp_sdata[, strata] <- factor(tmp_sdata[, strata])
    formula_id <- formula(paste("~", "id", sep = " "))
    formula_st <- formula(paste("~", strata, sep = " "))
    
    
    
    # Set sampling design
    des <- ReGenesees::e.svydesign(data = tmp_sdata, ids = formula_id, strata = formula_st, weights= ~w0)
    
    # Collapse lonely strata
    des.clps <- ReGenesees::collapse.strata(des, block.vars = formula_block, sim.score = ~Xbar)
    
    # Get mapping between strata and estimation strata
    colname_superst <- paste(strata, "collapsed", sep = ".")
    st_mapping <- clps.strata.status$clps.table[, c(strata, colname_superst)]
    st_mapping["est_strata"] <- ave(st_mapping[, strata], st_mapping[, colname_superst], FUN = function(x) paste(x, collapse = "_"))
    
    
    # Add estimation strata to the sample
    sample_data <- merge(sample_data, st_mapping[, c(strata, "est_strata")], by = strata, all.x = TRUE)
    sel <- is.na(sample_data[, "est_strata"])
    sample_data[sel, "est_strata"] <- sample_data[sel, strata]
    strata_n <- length(unique(sample_data[, "est_strata"]))
    
  
    # Check whether groups cut across strata or artificial superstrata (i.e. estimation strata)
    if(is.null(group)) {
      warning("Consider providing non-NULL groups to check the suitability of group variables given estimation strata.")
      sample_data["group"] <- 1
      group <- "group"
    }
    st_group_n <- nrow(unique(sample_data[, c("est_strata", group)]))
    if(st_group_n > strata_n) {
      warning("One or more group variables cut across estimation strata. Set group variables in a way that estimation strata are the most detailed levels within each group.")
    } 
    
    
    # Add est_strata to the population file
    data <- merge(data, st_mapping[, c(strata, "est_strata")], by = strata, all.x = TRUE)
    sel <- is.na(data[, "est_strata"])
    data[sel, "est_strata"] <- data[sel, strata]
    
    # Add indicator for collapse strata
    data["merged"] <- 0
    sel <- data[, strata] == data$est_strata
    data$merged[!sel] <- 1
    
    # Remove variables in remove_vrblist from the population file
    data <- data[, names(data)[!(names(data) %in% remove_vrblist)]]

    
    message(paste0("The variable est_strata should be used for the variable ", y, " in the next steps of the estimation functions as the value of the strata parameter."))
  }

  return(data)
}
