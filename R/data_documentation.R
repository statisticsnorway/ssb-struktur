#' Population test data
#'
#' Test population data for using in struktuR package (synthetic data).
#'
#' @format A data frame with 10000 rows and 5 variables:
#' \describe{
#'   \item{id}{identification variable}
#'   \item{employees}{number of employees}
#'   \item{turnover}{amount of turnover of the company in NOK}
#'   \item{size}{category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry_group}{the activity group for which the business works in}
#' }
#' @docType data
"pop_data"


#' Sample test data
#'
#' Test sample data for using in struktuR package. It includes synthetic
#' data with 1000 rows, each row being a company that was selected to the survey.
#'
#' @format A data frame with 1000 rows and  variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, big)}
#'   \item{industry_group}{The activity group for which the business works in}
#'   \item{job_vacancies}{The number of job vacancies in the company.}
#'   \item{sick_days}{The number of sick leave days recorded for the company.}
#' }
"sample_data"


#' Alternative population test data
#'
#' Test population data for using in struktuR package (synthetic data). This alternative version
#' includes two statistic variables for 1000 companies in the survey (although 5 non-response).
#'
#' @format A data frame with 10000 rows and 5 variables:
#' \describe{
#'   \item{id}{Identification variable}
#'   \item{employees}{Number of employees}
#'   \item{turnover}{Amount of turnover of the company (in 000 NOK)}
#'   \item{size}{Category size of the company in terms of turnover (small, mid, large)}
#'   \item{industry_group}{The activity group for which the business works in.}
#'   \item{job_vacancies}{The number of job vacancies in the company for those that responded to the survey.}
#'   \item{sick_days}{The number of sick leave days recorded for the company for those that responded to the survey.}
#' }
#' @docType data
"pop_data2"
