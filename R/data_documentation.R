#' Population test data
#'
#' Test population data for using in struktuR package (synthetic data).
#'
#' @format A data frame with 10000 rows and 7 variables:
#' \describe{
#'   \item{id}{identification variable}
#'   \item{employees}{number of employees}
#'   \item{employees_f}{number of female employees}
#'   \item{employees_m}{number of male employees}
#'   \item{turnover}{amount of turnover of the company in NOK}
#'   \item{size}{category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry}{the activity group for which the business works in}
#' }
#' @docType data
"pop_data"


#' Sample test data
#'
#' Test sample data for using in struktuR package. It includes synthetic
#' data with 1000 rows, each row being a company that was selected to the survey.
#'
#' @format A data frame with 1000 rows and variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{Number of female employees}
#'   \item{employees_m}{Number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, big)}
#'   \item{industry}{The activity group for which the business works in}
#'   \item{job_vacancies}{The number of job vacancies in the company.}
#'   \item{sick_days}{The number of sick leave days recorded for the company.}
#'   \item{sick_days_f}{The number of sick leave days recorded for female employees for the company.}
#'   \item{sick_days_m}{The number of sick leave days recorded for male employees for the company.}
#' }
#' @docType data
"sample_data"


#' Alternative population test data
#'
#' Test population data for using in struktuR package (synthetic data). This alternative version
#' includes two statistic variables for 1000 companies in the survey (although 5 non-response).
#'
#' @format A data frame with 10000 rows and 9 variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{number of female employees}
#'   \item{employees_m}{number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry}{The activity group for which the business works in.}
#'   \item{job_vacancies}{The number of job vacancies in the company for those that responded to the survey.}
#'   \item{sick_days}{The number of sick leave days recorded for the company for those that responded to the survey.}
#' }
#' @docType data
"pop_data2"


#' Population test data with a 1 observation stratum
#'
#' Test population data for using in struktuR package (synthetic data). 
#'
#' @format A data frame with 10005 rows and 7 variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{number of female employees}
#'   \item{employees_m}{number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry}{The activity group for which the business works in.}
#' }
#' @docType data
"pop_data_1obs"


#' Sample test data (1 obs strata)
#'
#' Test sample data for using in struktuR package. Contains a stratum with 1 observation for testing 
#'
#' @format A data frame with 1001 rows and variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{Number of female employees}
#'   \item{employees_m}{Number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, big)}
#'   \item{industry}{The activity group for which the business works in}
#'   \item{job_vacancies}{The number of job vacancies in the company.}
#'   \item{sick_days}{The number of sick leave days recorded for the company.}
#'   \item{sick_days_f}{The number of sick leave days recorded for female employees for the company.}
#'   \item{sick_days_m}{The number of sick leave days recorded for male employees for the company.}
#' }
#' @docType data
"sample_data_1obs"


#' Population test data with full count stratum
#'
#' Test population data for using in struktuR package (synthetic data). Stratum "B" is a full count strata.
#'
#' @format A data frame with 8065 rows and 7 variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{number of female employees}
#'   \item{employees_m}{number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry}{The activity group for which the business works in.}
#' }
#' @docType data
"pop_data_fulltelling"


#' Sample test data with full count stratum 
#'
#' Test sample data for using in struktuR package. It includes synthetic
#' data with 870 rows, each row being a company that was selected to the survey.
#'
#' @format A data frame with 870 rows and variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{employees_f}{Number of female employees}
#'   \item{employees_m}{Number of male employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, big)}
#'   \item{industry}{The activity group for which the business works in}
#'   \item{job_vacancies}{The number of job vacancies in the company.}
#'   \item{sick_days}{The number of sick leave days recorded for the company.}
#'   \item{sick_days_f}{The number of sick leave days recorded for female employees for the company.}
#'   \item{sick_days_m}{The number of sick leave days recorded for male employees for the company.}
#' }
#' @docType data
"sample_data_fulltelling"



#' Test dataset for sample allocation from AllocSN
#' 
#' This dataset is is a test dataset containing a small population of 100
#' companies. Variables include turnover for three periods and whethere they
#' were sampled or not.
#' 
#' @name testData
#' @docType data
#' @return One dataset containing 100 rows and 11 variables:
#' \item{dufNr}{company number} 
#' \item{nace5}{industry group (5 digits)}
#' \item{nace3}{industry group (3 digits)} 
#' \item{antAnsatt}{number of employees in the first period} 
#' \item{antAnsatt2}{number of employees in the second period} 
#' \item{storGrp}{group for size of company based on number of employees in the first period} 
#' \item{storGrp2}{group for size of company based on number of employees in the second period} 
#' \item{y1}{turnover in the first period} 
#' \item{y2}{turnover in the second period} 
#' \item{y3}{turnover in the third period} 
#' \item{utv1}{binary variable for whether or not the company was in the sample for the first period} 
#' \item{utv2}{binary variable for whether or not the company was in the sample for the second period}
#' \item{utv3}{binary variable for whether or not the company was in the sample for the third period}
#' @keywords datasets
"testData"



#' Second test dataset for sample allocation from AllocSN
#' 
#' This dataset is is a test dataset containing a population of 2000 companies
#' . Variables include turnover for three periods and whether they were sampled
#' or not.
#' 
#' @name testData2
#' @docType data
#' @return One dataset containing 11 variables and 2000 rows:
#' \item{dufNr}{company number} 
#' \item{nace5}{industry group (5 digits)}
#' \item{nace3}{industry group (3 digits)} 
#' \item{antAnsatt}{number of employees} 
#' \item{storGrp}{group for size of company based on number of employees}
#' \item{y1}{turnover in the first period} 
#' \item{y2}{turnover in the second period} 
#' \item{y3}{turnover in the third period} 
#' \item{utv1}{binary variable for whether or not the company was in the sample for the first period} 
#' \item{utv2}{binary variable for whether or not the company was in the sample for the second period} 
#' \item{utv3}{binary variable for whether or not the company was in the sample for the third period}
#' @keywords datasets
"testData2"
