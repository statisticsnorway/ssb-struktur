# Alternative population test data

Test population data for using in struktuR package (synthetic data).
This alternative version includes two statistic variables for 1000
companies in the survey (although 5 non-response).

## Usage

``` r
pop_data2
```

## Format

A data frame with 10000 rows and 9 variables:

- id:

  Identification variable

- employees:

  Number of employees

- employees_f:

  number of female employees

- employees_m:

  number of male employees

- turnover:

  Amount of turnover of the company (in 000 NOK)

- size:

  Category size of the company in terms of turnover (small, mid, large)

- industry:

  The activity group for which the business works in.

- job_vacancies:

  The number of job vacancies in the company for those that responded to
  the survey.

- sick_days:

  The number of sick leave days recorded for the company for those that
  responded to the survey.
