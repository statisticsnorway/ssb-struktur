# Changelog

## struktuR 0.2.0

- Added merge_lonely_strata function for merging strata with one
  observation.
- Added vignette for merging lonely strata.
- Extra controls in several functions to ensure fitting is run before
  other functions.
- Added stop check for variance calculation when domains cut across
  strata.
- Added additional robust estimation output for methods 1 and 3 for CV
  and variance.

## struktuR 0.1.7

- Small changes in code structuring, licensing and publishing of the
  github pages.

## struktuR 0.1.6

- Added functions from AllocSN to allocate a sample in an optimal way
  based on a rate estimator. Functions include CalcY, CalcS2, and
  FillStrata.
- Changes related to fulfilling SSBs public github requirements.
- Changed to MIT license
- Added github actions for building pkgdown site from gh-pages branch

## struktuR 0.1.5

- New code for handling cases with one observation in a strata. A
  warning is given but program will still run and estimates given.
- Testdata and unittests added for 1 observation strata and full count
  strata
- Small formatting issues fixed and included package name in imported
  function in code.
