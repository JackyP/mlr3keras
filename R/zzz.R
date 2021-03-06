#' @import data.table
#' @import keras
#' @import paradox
#' @import mlr3misc
#' @import checkmate
#' @importFrom R6 R6Class
#' @importFrom mlr3 mlr_learners LearnerClassif LearnerRegr assert_task assert_learner
#' @importFrom stats setNames
#' @description
#' A package that connects mlr3 to keras.
"_PACKAGE"

register_mlr3 = function() { #nocov start
  x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  x$add("classif.kerasff", LearnerClassifKerasFF)
  x$add("classif.keras", LearnerClassifKeras)
  x$add("regr.kerasff", LearnerRegrKerasFF)
  x$add("regr.keras", LearnerRegrKeras)
  x$add("classif.tabnet", LearnerClassifTabNet)
  x$add("regr.tabnet", LearnerRegrTabNet)
}

.onLoad = function(libname, pkgname) {
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(), action = "append")
}

.onUnload = function(libpath) {
  event = packageEvent("mlr3", "onLoad")
  hooks = getHook(event)
  pkgname = vapply(hooks, function(x) environment(x)$pkgname, NA_character_)
  setHook(event, hooks[pkgname != "mlr3keras"], action = "replace")
}

# silence R CMD check for callbacks:
utils::globalVariables("model") # nocov end
