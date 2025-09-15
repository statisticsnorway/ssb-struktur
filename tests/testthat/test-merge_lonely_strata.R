# merge_lonely_strata testing
# source("R/merge_lonely_strata.R")


test_that("merge_lonely_strata stops if the variable y not found in the data sets", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_error(merge_lonely_strata(pop_data_1obs[, ], sample_data_1obs,
                                   x = "employees", y = "income",
                                   id = "id",
                                   strata = "industry"))
})


test_that("merge_lonely_strata stops when not all strata are the same in the population and sample files", {
  data(pop_data)
  data(sample_data)
  pop_data$industry[2] <- "H"
  expect_error(merge_lonely_strata(pop_data, sample_data,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = "industry"))
})


test_that("merge_lonely_strata stops when blocks cut across strata", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_error(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = "industry", block = "size"))
})


test_that("merge_lonely_strata returns warning when group parameter is null", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_warning(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", group = NULL))
})


test_that("merge_lonely_strata returns warning when groups cut across strata or superstrata", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_warning(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", group = "size"))
})


test_that("merge_lonely_strata returns message when superstrata are created", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  pop_data_1obs$land <- 1
  expect_message(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", group = "land"))
})


test_that("merge_lonely_strata returns message when there are surprise strata with only 1 observation in the sample", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  pop_data_1obs$land <- 1
  expect_message(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", exclude = "10001", group = "land"))
})


test_that("merge_lonely_strata returns message when there are full count strata with only 1 observation in the sample", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  pop_data_1obs$land <- 1
  sel <- pop_data_1obs$industry %in% "G"
  pop_data_1obs <- pop_data_1obs[1:(nrow(pop_data_1obs) - sum(sel) + 1), ]
  expect_message(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", group = "land"))
})


test_that("merge_lonely_strata returns message when there are no lonely strata in the sample", {
  data(pop_data)
  data(sample_data)
  pop_data$land <- 1
  expect_message(merge_lonely_strata(pop_data, sample_data,
                                     x = "employees", y = "job_vacancies",
                                     id = "id",
                                     strata = "industry", group = "land"))
})


test_that("merge_lonely_strata returns message and null output when there are no lonely strata in the sample", {
  data(pop_data)
  data(sample_data)
  pop_data$land <- 1
  expect_message(
    test_results <- merge_lonely_strata(pop_data, sample_data,
                                        x = "employees", y = "job_vacancies",
                                        id = "id",
                                        strata = "industry", group = "land")
  )
  expect_equal(length(test_results), 0)
})



test_that("merge_lonely_strata stops when some blocks contain just a single stratum", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_error(merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = c("size","industry"), 
                                   block = "industry"))
})


test_that("merge_lonely_strata returns correct output when there are lonely strata in the sample", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  pop_data_1obs$land <- 1
  expect_message(suppressWarnings(
    test_results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                        x = "employees", y = "job_vacancies",
                                        id = "id",
                                        strata = "industry", group = "land")
  ))
  expect_equal(nrow(test_results), nrow(pop_data_1obs))
  sel <- names(test_results) %in% names(pop_data_1obs)
  expect_equal(sum(sel), ncol(pop_data_1obs))
  expect_equal(sum(!sel), 2)
  expect_equal("est_strata" %in% names(test_results)[!sel], TRUE)
  expect_equal("merged" %in% names(test_results)[!sel], TRUE)
  expect_equal(sum(test_results$industry != test_results$est_strata), sum(test_results$merged))
})



test_that("merge_lonely_strata handles more than one strata variable", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  suppressWarnings(suppressMessages(
    test_results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                        x = "employees", y = "job_vacancies",
                                        id = "id",
                                        strata = c("size","industry"), group = "size")
  ))
  expect_equal(nrow(test_results), nrow(pop_data_1obs))
  sel <- names(test_results) %in% names(pop_data_1obs)
  expect_equal(sum(sel), ncol(pop_data_1obs))
  expect_equal(sum(!sel), 2)
  expect_equal("est_strata" %in% names(test_results)[!sel], TRUE)
  expect_equal("merged" %in% names(test_results)[!sel], TRUE)
  test_results[, ".strata"] <- apply(test_results[, c("size","industry")], 1, paste, collapse = "_")
  expect_equal(sum(test_results$.strata != test_results$est_strata), sum(test_results$merged))
})


test_that("merge_lonely_strata handles more than one strata or group variables", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  pop_data_1obs$land <- 1
  suppressWarnings(suppressMessages(
    test_results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs,
                                        x = "employees", y = "job_vacancies",
                                        id = "id",
                                        strata = c("size","industry"), block = "size", group = c("land","size"))
  ))
  expect_equal(nrow(test_results), nrow(pop_data_1obs))
  sel <- names(test_results) %in% names(pop_data_1obs)
  expect_equal(sum(sel), ncol(pop_data_1obs))
  expect_equal(sum(!sel), 2)
  expect_equal("est_strata" %in% names(test_results)[!sel], TRUE)
  expect_equal("merged" %in% names(test_results)[!sel], TRUE)
  test_results[, ".strata"] <- apply(test_results[, c("size","industry")], 1, paste, collapse = "_")
  expect_equal(sum(test_results$.strata != test_results$est_strata), sum(test_results$merged))
})
