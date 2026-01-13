# Merge lonely strata

### Introduction

The `merge_lonely_strata` is one of the R functions in the `struktuR` R
package, which is documented
[here](https://statisticsnorway.github.io/ssb-struktur/articles/struktur-vignette.html)
(English). Lonely strata are defined to be non take-all strata with only
one observation in sample data. Variance estimation would not be
possible within such strata, which is a common problem, particularly in
business surveys, where many strata, some of which may be quite small,
are often used.

The main purpose of this function is to:

- Create estimation strata (or artificial *superstrata*) by merging
  lonely strata.

This function uses the `collapse.strata` function from the `ReGenesees`
package. The idea is to merge lonely strata by using population means of
an auxiliary variable, denoted by $x$, as a similarity measure. A lonely
stratum is merged to another lonely stratum or a larger stratum which is
the most similar to that lonely stratum in terms of the population mean
of the $x$-variable. If strata with only one observation are take-all
strata, then these strata are ignored in strata merging since
corresponding variances are set to zero for such strata in the
`struktuR` as well as in the Python version
[Statstruk](https://statisticsnorway.github.io/ssb-statstruk/guide_ratio.html),
and SAS-application Struktur ([Using
SAS-Struktur](https://www.ssb.no/a/publikasjoner/pdf/notat_200730/notat_200730.pdf),
Norsk).

This function should only be used for sample surveys with (stratified)
single-stage sampling design where simple random sampling is used within
each stratum to select sampling units.

Strata merge may not always be successful due to the reasons described
in the following section of this document.

### Package installation

For internal Statistic Norway users, the package is already installed on
many of the production servers and this step may be skipped. For other
users the package can be installed from github using the `devtools`
function `install_github`. This step only needs to be run one time.

``` r
devtools::install_github("statisticsnorway/ssb-struktur")
```

To access and use the functions in the package we need to run `library`
each time we start a new R session.

``` r
library(struktuR)
```

### Data requirements

We need data on both the *sample* and *population*. The following
variables should be included:

**Population data set**:

- ID variable (`id`) which is consistent in both the population and
  sample data sets.
- An explanatory variable when using regression and rate models (`x`).
  This is a variable which the statistic variable is correlated with.
- A strata variable (`strata`) which divides the population into groups
  which are similar to each other. This is the smallest grouping
  variable and which separate models will be run on.
- Domain variables (or publication groups: `group`) for producing
  statistical totals for. These should be able to be created by joining
  strata groups together.
- Blocking variables (`block`) that are used to constrain strata merge,
  in a way that estimation strata can only be created within blocks.
  This parameter may contain one or more blocking variables.

**Sample data set**:

- ID variable (`id`)
- The explanatory variable when using regression and rate models, but
  can be missing (`x`)
- The statistic variable(s) we are interested in estimating (`y`)

**Example data**

There are two synthetic data sets in the `struktuR` package that contain
lonely strata: pop_data_1obs, sample_data_1obs. `pop_data_1obs`
represents a population data set with 10005 rows, each one representing
a company. We will use the variable `employees`, which refers to the
number of employees in the company, or `turnover`, as the $x$-variable.
Variables `size` and `industry` will be used to specify the values of
the `strata`, `block`, and/or `group` parameters of the function.

``` r
head(pop_data_1obs)
```

|  id | employees | employees_f | employees_m |  turnover | size  | industry |
|----:|----------:|------------:|------------:|----------:|:------|:---------|
|   1 |         0 |           0 |           0 |  15396.54 | small | B        |
|   2 |        75 |          15 |          60 |  78814.71 | mid   | B        |
|   3 |        55 |          42 |          13 |  97128.26 | mid   | B        |
|   4 |        56 |          32 |          24 |  60414.60 | mid   | B        |
|   5 |       110 |          13 |          97 | 237306.65 | big   | B        |
|   6 |       172 |          50 |         122 | 473721.22 | big   | B        |

The data set `sample_data_1obs` contains 1001 rows representing a sample
of companies. In addition to the variables in the population data set,
we do have some variables among which `job_vacancies` will be used as
the $y$-variable, representing the number of job positions advertised
for the year.

``` r
head(sample_data_1obs)
```

|  id | employees | employees_f | employees_m |   turnover | size  | industry | job_vacancies | sick_days | sick_days_f | sick_days_m |
|----:|----------:|------------:|------------:|-----------:|:------|:---------|--------------:|----------:|------------:|------------:|
|   5 |       132 |          13 |          97 | 237306.653 | big   | B        |             1 |       515 |         278 |         237 |
|   9 |        28 |          11 |          10 |  63848.919 | mid   | B        |             8 |       134 |         127 |           7 |
|  12 |        35 |           6 |           1 |  11462.578 | small | B        |             3 |        21 |          17 |           4 |
|  14 |       155 |           1 |         170 |   7934.057 | big   | B        |            16 |       632 |         540 |          92 |
|  25 |       167 |          81 |          61 | 408964.032 | big   | B        |             9 |       337 |         200 |         137 |
|  55 |       124 |          31 |          45 | 118718.363 | mid   | B        |             7 |       525 |         151 |         374 |

Let’s see which strata are lonely strata by running the following code.

``` r
table(sample_data_1obs$industry)
```

As it can be noticed, the industry group G has only one observation in
the sample data set.

| Var1 | Freq |
|:-----|-----:|
| B    |  195 |
| C    |  197 |
| D    |  193 |
| E    |  219 |
| F    |  196 |
| G    |    1 |

The same stratum has five observations in the population data set.
Hence, it is, in fact, a lonely stratum that we can handle by using the
`merge_lonely_strata` function.

``` r
pop_data_1obs[pop_data_1obs$industry=="G", ]
```

|       |    id | employees | employees_f | employees_m | turnover | size | industry |
|:------|------:|----------:|------------:|------------:|---------:|:-----|:---------|
| 10001 | 10001 |        50 |          30 |          20 |    10000 | mid  | G        |
| 10002 | 10002 |        79 |          40 |          39 |    15000 | mid  | G        |
| 10003 | 10003 |        63 |          30 |          33 |     9000 | mid  | G        |
| 10004 | 10004 |        30 |          10 |          20 |    13000 | mid  | G        |
| 10005 | 10005 |        50 |          30 |          20 |    12000 | mid  | G        |

### Parameter specifications

The default values of the parameters `block` and `group` are set to
`NULL`. However, it is highly recommended to provide these variables.
When specifying blocking variable(s), one must pay attention to that
design strata are the most detailed groups within each block. In other
words, each block must be either a design stratum or a group of design
strata. Otherwise, the function would provide an error message. It is
also recommended that blocks are set in a way that the sampling
fractions do not vary a lot within each block. If possible, one may
consider grouping design strata with similar sampling fractions to
reduce bias that may arise merging strata with different fractions. Bias
may occur due to assuming equal weights for all units within each
estimation stratum.

Specification of the the publication domains (`group`) is also important
to check the suitability of domain variables given (estimation) strata.
Because, one may have issues in the estimation process with
`struktur_model` later on if one or more domain variables cut across
strata or estimation strata.

An additional parameter `exclude` in the function, allows one to include
a list of IDs to exclude from the modelling in the estimation stage.
This can be useful if there are some extreme values which will heavily
influence the results but are most likely correct values. If a singleton
stratum includes an ID that is specified to be excluded, then that
stratum is not considered as lonely stratum since its corresponding
variance is set to zero in the estimation with the `struktuR` package
and the Pyhton version of it.

### Usage of the function

At first, we will demonstrate how the function `merge_lonely_strata`
works. Population and sample datasets, one auxiliary variable
($x$-variable), one statistic variable ($y$-variable), an id variable
and strata variable(s) must all be provided. Then, some examples
regarding the effect of blocking variable(s) will be given. Finally, we
will some examples regarding the use of publication domain variables.
Note that blocking and group variables are optional but it would be good
to specify them for the reasons explained above.

**Example 1**

In this example, we shall use industry groups as the stratification
variable and the number of employees as the $x$-variable. Here, we will
not specify any blocking constraint, neither group variable(s).

``` r
results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs, 
                          x = "employees", 
                          y = "job_vacancies", 
                          id = "id",
                          strata = "industry")
```

    # 
    # # All lonely strata (1) successfully collapsed!
    # Warning in merge_lonely_strata(pop_data_1obs, sample_data_1obs, x =
    # "employees", : Consider providing non-NULL groups to check the suitability of
    # group variables given estimation strata.

| industry |  id | employees | employees_f | employees_m |  turnover | size  | est_strata | merged |
|:---------|----:|----------:|------------:|------------:|----------:|:------|:-----------|-------:|
| B        |   1 |         0 |           0 |           0 |  15396.54 | small | B          |      0 |
| B        |   2 |        75 |          15 |          60 |  78814.71 | mid   | B          |      0 |
| B        |   3 |        55 |          42 |          13 |  97128.26 | mid   | B          |      0 |
| B        |   4 |        56 |          32 |          24 |  60414.60 | mid   | B          |      0 |
| B        |   5 |       110 |          13 |          97 | 237306.65 | big   | B          |      0 |
| B        |   6 |       172 |          50 |         122 | 473721.22 | big   | B          |      0 |

The output of the function is a population dataset with additional
columns:

- `est_strata` refers to the estimation strata which can be design
  strata or superstrata that are formed newly.
- `merged` is an indicator variable taking value 1 if merge took place
  or value 0 otherwise.

Value of each newly created superstratum is formed by binding values of
the two strata that are merged with underscore as shown in the result
table below. In this example, the lonely stratum “G” is merged to
stratum “D”, so the new estimation strata has a value of “D_G”.

``` r
head(results[results$merged==1, ])
```

    # 
    # # All lonely strata (1) successfully collapsed!
    # Warning in merge_lonely_strata(pop_data_1obs, sample_data_1obs, x =
    # "employees", : Consider providing non-NULL groups to check the suitability of
    # group variables given estimation strata.

|      | industry |   id | employees | employees_f | employees_m |  turnover | size | est_strata | merged |
|:-----|:---------|-----:|----------:|------------:|------------:|----------:|:-----|:-----------|-------:|
| 4001 | D        | 4543 |       129 |         108 |          21 |  93900.10 | big  | D_G        |      1 |
| 4002 | D        | 4535 |        82 |          17 |          65 | 107087.07 | mid  | D_G        |      1 |
| 4003 | D        | 4536 |       240 |         144 |          96 | 357626.36 | big  | D_G        |      1 |
| 4004 | D        | 4537 |        53 |          13 |          40 |  62149.90 | mid  | D_G        |      1 |
| 4005 | D        | 4538 |        13 |          11 |           2 |  22390.25 | mid  | D_G        |      1 |
| 4006 | D        | 4539 |        53 |          34 |          19 |  20276.47 | mid  | D_G        |      1 |

**Example 2**

In the examples below, we shall use both size and industry groups as the
stratification variables and turnover as the $x$-variable. In this
example, We will examine strata merge without blocking variable(s).

``` r
results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs, 
                          x = "turnover", 
                          y = "job_vacancies", 
                          id = "id",
                          strata = c("size", "industry"))
```

As it can seen from the Table in the previous section, the company in
the lonely stratum “G” is a medium-size company, so its size group is
“mid”. With strata merge, stratum “mid_G” is merged to stratum
“small_D”. When we do not specify a blocking variable, it is possible to
have such merging. If sampling fractions differ quite much among small-
and medium size groups, then this may bring about a bias problem as
mentioned previously. To reduce bias, one may put a blocking constraint
when forming superstrata. This is demonstrated below.

``` r
head(results[results$merged==1, ])
```

    # 
    # # All lonely strata (1) successfully collapsed!
    # Warning in merge_lonely_strata(pop_data_1obs, sample_data_1obs, x = "turnover",
    # : Consider providing non-NULL groups to check the suitability of group
    # variables given estimation strata.

|      |    id | employees | employees_f | employees_m |   turnover | size  | industry | est_strata    | merged |
|:-----|------:|----------:|------------:|------------:|-----------:|:------|:---------|:--------------|-------:|
| 9176 | 10001 |        50 |          30 |          20 | 10000.0000 | mid   | G        | small_D_mid_G |      1 |
| 9177 | 10002 |        79 |          40 |          39 | 15000.0000 | mid   | G        | small_D_mid_G |      1 |
| 9178 | 10003 |        63 |          30 |          33 |  9000.0000 | mid   | G        | small_D_mid_G |      1 |
| 9179 | 10004 |        30 |          10 |          20 | 13000.0000 | mid   | G        | small_D_mid_G |      1 |
| 9180 | 10005 |        50 |          30 |          20 | 12000.0000 | mid   | G        | small_D_mid_G |      1 |
| 9499 |  4906 |         8 |           7 |           1 |   301.7372 | small | D        | small_D_mid_G |      1 |

**Example 3**

In this example, we shall put a blocking constraint as such that strata
merge will only take place within blocks, which means that strata from
different blocks cannot be merged even they are similar to each other in
terms of the population mean of the $x$-variable (turnover here).

To avoid merging strata from different size groups, we may use size
groups as the value of the `block` parameter as follows:

``` r
results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs, 
                          x = "turnover", 
                          y = "job_vacancies", 
                          id = "id",
                          strata = c("size", "industry"),
                          block = "size")
```

Since we avoid strata merge across blocks, the lonely stratum “mid_G” is
now merged to stratum “mid_C” instead of “small_D”. The new super strata
is called “mid_C_mid_G” as seen below.

``` r
head(results[results$merged==1, ])
```

    # 
    # # All lonely strata (1) successfully collapsed!
    # Warning in merge_lonely_strata(pop_data_1obs, sample_data_1obs, x = "turnover",
    # : Consider providing non-NULL groups to check the suitability of group
    # variables given estimation strata.

|      |   id | employees | employees_f | employees_m |   turnover | size | industry | est_strata  | merged |
|:-----|-----:|----------:|------------:|------------:|-----------:|:-----|:---------|:------------|-------:|
| 4425 | 3465 |        61 |           4 |          57 |  74122.764 | mid  | C        | mid_C_mid_G |      1 |
| 4426 | 3862 |        56 |          41 |          15 | 114993.527 | mid  | C        | mid_C_mid_G |      1 |
| 4427 | 2018 |        18 |           2 |          16 |   5720.938 | mid  | C        | mid_C_mid_G |      1 |
| 4428 | 3903 |        85 |          41 |          44 |  92782.059 | mid  | C        | mid_C_mid_G |      1 |
| 4429 | 3942 |        14 |           1 |          13 |  17956.721 | mid  | C        | mid_C_mid_G |      1 |
| 4430 | 2042 |        85 |          41 |          44 |  26477.678 | mid  | C        | mid_C_mid_G |      1 |

**Example 4**

In this example, we demonstrate how to specify the grouping variable. At
first, we will use an inappropriate group variable, and then we will fix
this by creating a suitable one depending on which design strata are
merged.

Suppose that we wish to produce statistics at country level and by
industry groups. If so, we need put a variable corresponding to country
and industry groups as the value of the `group` parameter.

``` r
pop_data_1obs$country <- 1
results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs, 
                          x = "turnover", 
                          y = "job_vacancies", 
                          id = "id",
                          strata = c("size", "industry"),
                          block = "size",
                          group = c("country", "industry"))
```

The code above will produce a warning message since one or more group
variables(s) cut across strata or super strata (estimation strata). This
is due to the fact that two industry groups, that is, “C” and “G” are
merged, and so the publication domain needs to be minimum at estimation
strata level. In other words, design strata or super strata need to be
the most detailed groups within each publication domain.

    # There were 10 observations that were missing values for job_vacancies. These were removed from the sample data
    # The following strata, being neither surprise nor full count, had only 1 observation in the sample:  mid_G . Strata merge was attempted.
    # 
    # # All lonely strata (1) successfully collapsed!
    # Warning in merge_lonely_strata(pop_data_1obs, sample_data_1obs, x = "turnover",
    # : One or more group variables cut across estimation strata. Set group variables
    # in a way that estimation strata are the most detailed levels within each group.
    # The variable est_strata should be used for the variable job_vacancies in the next steps of the estimation functions as the value of the strata parameter.

The function would still produce an output data. However, this will be
an issue when newly created estimation strata are used as the
stratification variable with an inappropriate publication domain
variable in the `struktuR` R package. One can use the output of the
function `merge_lonely_strata` as a diagnostic to decide suitable
publication domains given strata or estimation strata.

To remedy the issue in this example, we will simply create a new domain
variable by merging two design strata as follows.

``` r
pop_data_1obs$domain <- pop_data_1obs$industry
pop_data_1obs$domain[pop_data_1obs$industry %in% c("C", "G")] <- "C_G"
results <- merge_lonely_strata(pop_data_1obs, sample_data_1obs, 
                          x = "turnover", 
                          y = "job_vacancies", 
                          id = "id",
                          strata = c("size", "industry"),
                          block = "size",
                          group = c("country", "domain"))
```

### Restrictions

- The use of this function will require some expert judgement when it
  comes to the specification of the `block` and `group` parameters.
  There may be some back and forwards. Users are advised to modify their
  choices depending on whether strata merge was successful and if so,
  which strata were merged.

- This function can only be used for a single statistic variable
  ($y$-variable). As a result of this, one may obtain different strata
  merge for different $y$-variables, and so publication domains per
  variable may differ as well. This is because of the fact that the
  identification of lonely strata is done based on the number of
  observations within strata with non-null $y$-values. If missing
  patterns by strata vary a lot from variable to variable, then a lonely
  stratum for one $y$-variable may not be a lonely stratum for another
  statistic variable.
