# Second test dataset for sample allocation from AllocSN

This dataset is is a test dataset containing a population of 2000
companies . Variables include turnover for three periods and whether
they were sampled or not.

## Usage

``` r
testData2
```

## Format

An object of class `data.frame` with 2000 rows and 11 columns.

## Value

One dataset containing 11 variables and 2000 rows:

- dufNr:

  company number

- nace5:

  industry group (5 digits)

- nace3:

  industry group (3 digits)

- antAnsatt:

  number of employees

- storGrp:

  group for size of company based on number of employees

- y1:

  turnover in the first period

- y2:

  turnover in the second period

- y3:

  turnover in the third period

- utv1:

  binary variable for whether or not the company was in the sample for
  the first period

- utv2:

  binary variable for whether or not the company was in the sample for
  the second period

- utv3:

  binary variable for whether or not the company was in the sample for
  the third period
