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

usethis::use_data(pop_data)

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

usethis::use_data(sample_data)

#### pop_data2 ####
pop_data2 <- pop_data
pop_data2$job_vacancies <- NA
pop_data2$sick_days <- NA

m <- match(sample_data$id, pop_data2$id)
pop_data2$job_vacancies[m] <- sample_data$job_vacancies
pop_data2$sick_days[m] <- sample_data$sick_days

usethis::use_data(pop_data2)

#### data for checking 1 obs problem ####
load("data/pop_data.RData")
load("data/sample_data.RData")

# Case with one in sample and several in the population
new_sample <- data.frame(id = 10001, employees = 50, employees_m = 20, employees_f = 30, 
            turnover = 10000, size = "mid", industry = "G", job_vacancies = 5, 
           sick_days = 56, sick_days_f = 20, sick_days_m = 36)

new_pop <- data.frame(id=10001:10005, 
                      employees = c(50, 79, 63, 30, 50), 
                      employees_m = c(20, 39, 33, 20, 20),
                      employees_f = c(30, 40, 30, 10, 30),
                      turnover= c(10000, 15000, 9000, 13000,12000),
                      size = rep("mid", 5), 
                      industry = rep("G", 5))

sample_data_1obs <- rbind(sample_data, new_sample)
usethis::use_data(sample_data_1obs)

pop_data_1obs <- rbind(pop_data, new_pop)
usethis::use_data(pop_data_1obs)

#### Data for checking fulltelling ####
load("data/pop_data.RData")
load("data/sample_data.RData")

# Select only big in 'B'
m <- sample_data$industry != "B" | (sample_data$size == "big")
sample_data_fulltelling <- sample_data[m, ]

# Keep only those in "B" that are in the sample
m <- pop_data$id %in% sample_data_fulltelling$id | pop_data$industry != "B"
pop_data_fulltelling <- pop_data[m, ]

# Save
usethis::use_data(sample_data_fulltelling)
usethis::use_data(pop_data_fulltelling)
