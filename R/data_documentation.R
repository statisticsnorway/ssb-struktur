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
