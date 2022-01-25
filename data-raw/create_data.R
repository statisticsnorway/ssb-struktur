# Code to create syntheic data for saving in the package
# Used in examples, vignette and testing

#### pop_data ####
set.seed(2021)
pop_data <- data.frame(id = 1:10000,
                  employees = abs(round(rnorm(10000, mean = 20, sd = 100)))
            )
pop_data$employees[pop_data$employees == 0] <- 2
rand <- runif(10000)
pop_data$employees_f <- pop_data$employees - round(rand * pop_data$employees)
pop_data$employees_m <- pop_data$employees - pop_data$employees_f

pop_data$turnover <- abs(pop_data$employees * rnorm(10000, mean = 1000, sd = 1000))
pop_data$size <- "small"
pop_data$size[pop_data$employees > 10] <- "mid"
pop_data$size[pop_data$employees > 100] <- "big"
pop_data$industry <- rep(c("B", "C", "D", "E", "F"), each = 2000)

# create some problems for testing
pop_data[1, c("employees", "employees_f", "employees_m")] <- 0
#pop_data[2, c("employees", "employees_f", "employees_m")] <- NA

save(pop_data, version=2, file = "data/pop_data.RData")

#### sample_data ####
s <- sample(1:10000, size = 1000)
sample_data <- pop_data[s, ]

# Change employees number slightly for testing
sample_data$employees <- abs(round(sample_data$employees + rnorm(1000, sd = 20)))
sample_data$employees[sample_data$employees == 0] <- 2

# Add in job_vacancies
sample_data$job_vacancies <- round(sample_data$employees * runif(1000, max = 0.3))
sample_data$sick_days <- round(sample_data$employees * runif(1000, max = 5))
rand2 <- runif(1000)
sample_data$sick_days_f <- sample_data$sick_days - round(rand2 * sample_data$sick_days)
sample_data$sick_days_m <- sample_data$sick_days - sample_data$sick_days_f


# Add some NA values for testing
sample_data$job_vacancies[1:10] <- NA
sample_data$sick_days[5:15] <- NA

sample_data <- sample_data[order(sample_data$id), ]
row.names(sample_data) <- NULL

save(sample_data, version = 2, file = "data/sample_data.RData")


#### pop_data2 ####
pop_data2 <- pop_data
pop_data2$job_vacancies <- NA
pop_data2$sick_days <- NA

m <- match(sample_data$id, pop_data2$id)
pop_data2$job_vacancies[m] <- sample_data$job_vacancies
pop_data2$sick_days[m] <- sample_data$sick_days

save(pop_data2, version = 2, file = "data/pop_data2.RData")

