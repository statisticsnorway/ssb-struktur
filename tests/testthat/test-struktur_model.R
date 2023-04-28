#struktur_model testing
#source("R/struktur_model.R")

test_that("struktur_model returns message for missing y values", {
  data(pop_data)
  data(sample_data)
  expect_message(struktur_model(pop_data[, ], sample_data,
                                x = "employees", y = "job_vacancies",
                                id = "id",
                                strata = "industry"))
  })


test_that("struktur_model stops when x values are missing", {
  data(pop_data)
  data(sample_data)
  pop_data$employees[2] <- NA
  expect_error(struktur_model(pop_data, sample_data,
                                  x = "employees", y = "job_vacancies",
                                  id = "id",
                                  strata = "industry"))
  })


test_that("struktur_model returns correct output size and beta estimate", {
  data(pop_data)
  data(sample_data)
  suppressMessages(
    test_results <- struktur_model(pop_data, sample_data,
                                 x = "employees", y = "job_vacancies",
                                 id = "id",
                                 strata = "industry")
  )
  expect_equal(nrow(test_results), nrow(pop_data[, ]))
  expect_equal(as.numeric(test_results$job_vacancies_beta[1]), 0.145902357)
})


test_that("struktur_model handles strata with 1 observation", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  expect_warning(suppressMessages(
    test_results <- struktur_model(pop_data_1obs, sample_data_1obs,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = "industry")
  ))
  
  expect_equal(nrow(test_results), nrow(pop_data_1obs[, ]))
  expect_equal(as.numeric(test_results$job_vacancies_beta[10002]), 0.1)
  expect_equal(as.numeric(test_results$job_vacancies_imp[10002]), 7.9)
})


test_that("get_strata and get_strata_results handles strata with 1 observation", {
  data(pop_data_1obs)
  data(sample_data_1obs)
  suppressWarnings(suppressMessages(
    test_results <- struktur_model(pop_data_1obs, sample_data_1obs,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = "industry")
  ))
  res_table <- get_strata_results(test_results)
  expect_equal(as.numeric(res_table$job_vacancies_var[6]), 0)
  
  # Check with grouping
  test_results$land <- 1
  res_table2 <- get_results(test_results, group = "land")
  expect_equal(nrow(res_table2) , 1)
  expect_equal(as.numeric(res_table2$job_vacancies_var), 	8318798.5)
})


test_that("struktur_model and get_results handles full count strata", {
  data(pop_data_fulltelling)
  data(sample_data_fulltelling)
  expect_message(
    test_results <- struktur_model(pop_data_fulltelling, sample_data_fulltelling,
                                   x = "employees", y = "job_vacancies",
                                   id = "id",
                                   strata = "industry")
    )
  expect_message( 
    res_table <- get_strata_results(test_results) 
    )
  expect_equal(as.numeric(res_table$job_vacancies_var[1]), 0)
  
  # Check with grouping
  test_results$land <- 1
  expect_message(res_table2 <- get_results(test_results, group = "land"))
  expect_equal(nrow(res_table2) , 1)
  expect_equal(as.numeric(res_table2$job_vacancies_var), 	6841364.1)
})
