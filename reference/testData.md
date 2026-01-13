# Test dataset for sample allocation from AllocSN

This dataset is is a test dataset containing a small population of 100
companies. Variables include turnover for three periods and whethere
they were sampled or not.

## Usage

``` r
testData
```

## Format

An object of class `data.frame` with 100 rows and 13 columns.

## Value

One dataset containing 100 rows and 11 variables:

- dufNr:

  company number

- nace5:

  industry group (5 digits)

- nace3:

  industry group (3 digits)

- antAnsatt:

  number of employees in the first period

- antAnsatt2:

  number of employees in the second period

- storGrp:

  group for size of company based on number of employees in the first
  period

- storGrp2:

  group for size of company based on number of employees in the second
  period

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
