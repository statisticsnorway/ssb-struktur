# prop_alloc testing
#source('R/prop_alloc.R')

test_that('Returns correct allocation (1)', {
  N <- c(15, 40, 80, 300, 600)
  X <- c(1000, 70000, 250000, 400000, 500000)
  totn = 100
  res <- prop_alloc(N = N, X = X, totn = totn)
  correct <- c(0, 6, 20, 33, 41)
  
  expect_equal(res$n, correct)
  expect_equal(res$n_adjusted, correct)
})

test_that('Returns correct allocation (2)', {
  N <- c(15, 40, 80, 300, 600)
  X <- c(0, 70000, 250000, 400000, 500000)
  totn = 100
  res <- prop_alloc(N = N, X = X, totn = totn, min_n = 2)
  correct <- c(2, 6, 20, 32, 40)
  
  expect_equal(res$n, correct)
  expect_equal(res$n_adjusted, correct)
})

test_that('Handles situation with only one stratum', {
  totn <- 75
  res <- prop_alloc(N = 1000, X = 5000000, totn = totn, max_n = 500)
  
  expect_equal(res$n, totn)
  expect_equal(res$n_adjusted, totn)
})

test_that('The allocation adds up correctly', {
  N <- c(300, 20, 40, 600, 80, 90)
  X <- c(400000, 1000, 70000, 500000, 250000, 250000)
  take_all <- c(0, 1, 0, 0, 0, 0)
  totn = 250
  res <- prop_alloc(N = N, X = X, totn = totn, take_all = take_all)
  
  expect_equal(sum(res$n), totn)
  expect_equal(sum(res$n_adjusted), totn)
})

test_that('When the algorithm does not achieve the desired sample size: n_adjusted adds up correctly', {
  N <- c(300, 40, 600, 80, 90)
  X <- c(400000, 7000, 500000, 250000, 250000)
  totn = 200
  res <- suppressWarnings(prop_alloc(N = N, X = X, totn = totn))
  
  expect_false(sum(res$n) == totn)
  expect_equal(sum(res$n_adjusted), totn)
})

test_that('When the algorithm does not achieve the desired sample size: returns warning', {
  N <- c(300, 40, 600, 80, 90)
  X <- c(400000, 7000, 500000, 250000, 250000)
  totn = 200
  
  expect_warning(prop_alloc(N = N, X = X, totn = totn))
})

test_that('Stops when it is a conflict between take_all and take_none', {
  N <- c(15, 40, 80, 100, 300)
  X <- c(1000, 7000, 20000, 2500, 40000)
  take_all = c(1, 0, 0, 0, 0)
  take_non = c(1, 0, 1, 0, 0)
  totn = 100
  
  expect_error(prop_alloc(N = N, X = X, totn = totn, take_all = take_all, take_none = take_non))
})

test_that('Take-none strata get sample size 0', {
  N <- c(40, 80, 100, 300)
  X <- c(7000, 20000, 2500, 40000)
  take_non = c(0, 1, 0, 0)
  totn = 100
  res <- prop_alloc(N = N, X = X, totn = totn, take_none = take_non)
  
  expect_true(res$n[2] == 0)
})

test_that('Take-all strata get sample size equal to population size', {
  N <- c(40, 80, 100, 300)
  X <- c(7000, 20000, 2500, 40000)
  take_all = c(0, 1, 0, 0)
  totn = 100
  res <- prop_alloc(N = N, X = X, totn = totn, take_all = take_all)
  
  expect_true(res$n[2] == N[2])
})

test_that('The assigned n per stratum is less or equal to the upper boundary of the stratum', {
  N <- c(40, 80, 100, 300)
  X <- c(7000, 20000, 2500, 40000)
  take_none = c(1, 0, 0, 0)
  totn = 200
  res <- prop_alloc(N = N, X = X, totn = totn, take_none = take_none, min = 10)
  
  expect_true(sum(res$n <= res$UB) == 4)
})

test_that('The assigned n per stratum is greater or equal to the lower boundary of the stratum', {
  N <- c(40, 80, 100, 300)
  X <- c(7000, 20000, 2500, 40000)
  min = c(5, 10, 20, 20)
  totn = 200
  res <- prop_alloc(N = N, X = X, totn = totn, min = min)
  
  expect_true(sum(res$n >= res$LB) == 4)
})

test_that('Stops when totn is too large', {
  N <- c(15, 30, 80, 100)
  X <- c(1000, 2000, 7000, 6000)
  totn = 150
  
  expect_error(prop_alloc(N = N, X = X, totn = totn, max_n = 50))
})

test_that('Stops when totn is too small', {
  N <- c(15, 30, 80, 100)
  X <- c(1000, 2000, 7000, 6000)
  totn = 100
  
  expect_error(prop_alloc(N = N, X = X, totn = totn, min_n = 40))
})








