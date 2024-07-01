# mark_the_largest testing
#source('R/mark_the_largest.R')

test_that('Marks correct units (method 1, not stratification)', {
  x <- c(NA, 0, -99, 0, seq(10, 100, length.out = 15), 0)
  data <- data.frame(id = 1:20, x = x)
  res <- mark_the_largest(data = data, idVar = 'id', xVar = 'x', method = 1, par_method1 = 30)
  correct <- c(rep(1, times = 3), rep(0, times = 20-3)) 
  
  expect_equal(res$large1, correct)
  expect_equal(res$large, correct)
})

test_that('Marks correct units (method 1, with stratification)', {
  x <- c(NA, 0, -99, 0, seq(10, 100, length.out = 15), 0)
  data <- data.frame(id = 1:20, x = x, strata = c(rep('A', times = 12), rep('B', times= 8)))
  res <- mark_the_largest(data = data, idVar = 'id', xVar = 'x', strataVar = 'strata', method = 1, par_method1 = c(20, 50))
  correct <- c(rep(1, times = 1), rep(0, times = 12-1), rep(1, times = 4), rep(0, times = 8-4))
  
  expect_equal(res$large1, correct)
  expect_equal(res$large, correct)
})

test_that('Marks correct units (method 3, with stratification and min_x_method3and4)', {
  x <- c(0, seq(100, 10000, length.out = 10), NA, 0, -99, NA, 0, seq(10, 100, length.out = 20), 0, -99, 0, 0)
  data <- data.frame(id = 1:40, x = x, strata = rep(c('A', 'B'), times = 20))
  res <- mark_the_largest(data = data, idVar = 'id', xVar = 'x', strataVar = 'strata', method = 3, 
                          par_method3 = 10, min_x_method3and4 = c(100, 5000))
  correct <- c(rep(1, times = 5), rep(0, times = 20-5), rep(1, times = 2), rep(0, times = 20-2))
  
  expect_equal(res$large3, correct)
  expect_equal(res$large, correct)
})

test_that('Correct result when several methods are run at the same time', {
  x <- c(seq(100, 500, length.out = 6), NA, 0, 0, -999, -99, seq(1000, 500, length.out = 6), NA, 0, 0)
  data <- data.frame(id = 1:20, x = x)
  res <- mark_the_largest(data = data, idVar = 'id', xVar = 'x', method = c(2, 4), par_method2 = 500, par_method4 = 100)
  correct2 <- c(rep(1, times = 5), rep(0, times = 20-5)) 
  correct4 <- c(rep(1, times = 18), rep(0, times = 20-18)) 
  correct <- ifelse(rowSums(cbind(correct2, correct4)) > 0, 1, 0)
  
  expect_equal(res$large2, correct2)
  expect_equal(res$large4, correct4)
  expect_equal(res$large, correct)
})



