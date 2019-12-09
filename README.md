# mlr3keras
An extension for `mlr3` to enable using various `keras` models as learners.

[![Build Status](https://travis-ci.org/mlr-org/mlr3keras.svg?branch=master)](https://travis-ci.org/mlr-org/mlr3keras)[![Build status](https://ci.appveyor.com/api/projects/status/m2tuhgdxo8is0nv0?svg=true)](https://ci.appveyor.com/project/mlr-org/mlr3keras)
<!--
[![CRAN](https://www.r-pkg.org/badges/version/mlr3)](https://cran.r-project.org/package=mlr3keras)
[![codecov](https://codecov.io/gh/mlr-org/mlr3/branch/master/graph/badge.svg)](https://codecov.io/gh/mlr-org/mlr3)
-->

## Status

`mlr3keras` is in very early stages of development, and currently only partially under development.

 Comments, discussion and issues/bug reports and PR's are **highly** appreciated.

 If you want to **contribute**, please propose / discuss adding functionality in an issue in order to avoid unneccessary or duplicate work.

## Usage

`mlr3keras` currently exposes three `Learners` for regression and classification respectively.

* (Regr|Classif)Keras:   A generic wrapper that allows to supply a custom keras architecture as
                         a hyperparameter.
* (Regr|Classif)KerasFF: A fully-connected feed-forward Neural Network.
* (Regr|Classif)TabNet: An implementation of `TabNet` (c.f. Sercan, A. and Pfister, T. (2019): TabNet).

Learners can be used for `training` and `prediction` as follows:

```{r, message=FALSE}
  lrn = LearnerClassifKerasFF$new()
  lrn$param_set$values$epochs = 50
  lrn$param_set$values$layer_units = 12
  lrn$train(mlr_tasks$get("iris"))
  lrn$predict(mlr_tasks$get("iris"))
```

## Design

This package's purpose for now is to understand the design-decisions required to make `keras` \ `tensorflow` work
with `mlr3` **and** flexible enough for users.

Several design decisions are not made yet, so input is highly appreciated.


## Installation

```r
remotes::install_github("mlr-org/mlr3keras")
```

## Resources

* [Reference Manual](https://mlr3.mlr-org.com/reference/)
* [Extension packages](https://github.com/mlr-org/mlr3/wiki/Extension-Packages).
* We started to write a [book](https://mlr3book.mlr-org.com/), but it is still very unfinished.
* [useR2019 talks](https://github.com/mlr-org/mlr-outreach/tree/master/2019_useR)
