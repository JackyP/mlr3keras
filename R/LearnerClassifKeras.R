#' @title Keras Neural Network with custom architecture (Classification)
#'
#' @usage NULL
#' @aliases mlr_learners_classif.keras
#' @format [R6::R6Class()] inheriting from [mlr3::LearnerClassif].
#'
#' @section Construction:
#' ```
#' LearnerClassifKeras$new()
#' mlr3::mlr_learners$get("classif.keras")
#' mlr3::lrn("classif.keras")
#' ```
#'
#' @description
#' Neural Network using Keras and Tensorflow.
#' This learner allows for supplying a custom architecture.
#' Calls [keras::fit] from package \CRANpkg{keras}.
#'
#' Parameters:\cr
#' Most of the parameters can be obtained from the `keras` documentation.
#' Some exceptions are documented here.
#' * `model`: A compiled keras model.
#' * `class_weight`: needs to be a named list of class-weights
#'   for the different classes numbered from 0 to c-1 (for c classes).
#'   ```
#'   Example:
#'   wts = c(0.5, 1)
#'   setNames(as.list(wts), seq_len(length(wts)) - 1)
#'   ```
#' * `callbacks`: A list of keras callbacks.
#'   See `?callbacks`.
#'
#' @template learner_methods
#' @template seealso_learner
#' @templateVar learner_name classif.keras
#' @examples
#'  # Define a model
#'  library(keras)
#'  model = keras_model_sequential() %>%
#'  layer_dense(units = 12L, input_shape = 4L, activation = "relu") %>%
#'  layer_dense(units = 12L, activation = "relu") %>%
#'  layer_dense(units = 3L, activation = "softmax") %>%
#'    compile(optimizer = optimizer_sgd(),
#'      loss = "categorical_crossentropy",
#'      metrics = "accuracy")
#'  # Create the learner
#'  learner = LearnerClassifKeras$new()
#'  learner$param_set$values$model = model
#'  learner$train(mlr3::mlr_tasks$get("iris"))
#' @export
LearnerClassifKeras = R6::R6Class("LearnerClassifKeras", inherit = LearnerClassif,
  public = list(
    architecture = NULL,
    initialize = function(
        id = "classif.keras",
        predict_types = c("response", "prob"),
        feature_types = c("integer", "numeric"),
        properties = c("twoclass", "multiclass"),
        packages = "keras",
        man = "mlr3keras::mlr_learners_classif.keras",
        architecture = KerasArchitectureCustomModel$new()
      ) {
      self$architecture = assert_class(architecture, "KerasArchitecture")
      ps = ParamSet$new(list(
        ParamInt$new("epochs", default = 100L, lower = 0L, tags = "train"),
        ParamUty$new("model", tags = c("train")),
        ParamUty$new("class_weight", default = list(), tags = "train"),
        ParamDbl$new("validation_split", lower = 0, upper = 1, default = 1/3, tags = "train"),
        ParamInt$new("batch_size", default = 128L, lower = 1L, tags = c("train", "predict")),
        ParamUty$new("callbacks", default = list(), tags = "train"),
        ParamLgl$new("low_memory", default=FALSE, tags = c("train")),
        ParamInt$new("verbose", lower = 0L, upper = 1L, tags = c("train", "predict"))
      ))
      ps$values = list(epochs = 100L, callbacks = list(), validation_split = 1/3, batch_size = 128L, low_memory = FALSE)

      super$initialize(
        id = assert_character(id, len = 1),
        param_set = ParamSetCollection$new(list(ps, self$architecture$param_set)),
        predict_types = assert_character(predict_types),
        feature_types = assert_character(feature_types),
        properties = assert_character(properties),
        packages = assert_character(packages),
        man = assert_character(man)
      )

      # Set y_transform
      self$architecture$set_transform("y",
        function(target, pars, model_loss) {
          y = to_categorical(as.integer(target) - 1)
          if (model_loss == "binary_crossentropy") y = y[, 1, drop = FALSE]
          return(y)
        }
      )
    },

    train_internal = function(task) {
      pars = self$param_set$get_values(tags = "train")

      model = self$architecture$get_model(task, pars)
      # Custom transformation depending on the model.
      # Could be generalized at some point.
      features = task$data(cols = task$feature_names)
      target = task$data(cols = task$target_names)[[task$target_names]]

      if(!pars$low_memory) {
        x = self$architecture$transforms$x(features, pars)
        y = self$architecture$transforms$y(target, pars, model$loss)

        history = invoke(keras::fit,
          object = model,
          x = x,
          y = y,
          epochs = as.integer(pars$epochs),
          class_weight = pars$class_weight,
          batch_size = pars$batch_size,
          validation_split = pars$validation_split,
          verbose = pars$verbose,
          callbacks = pars$callbacks)

      } else {
        # Validation split
        rho = rsmp("holdout", ratio = 1 - pars$validation_split)
        rho$instantiate(task)

        train_gen = make_data_generator(
          task = task,
          batch_size = pars$batch_size,
          filter_ids = rho$train_set(1),
          x_transform = function(x) {self$architecture$transforms$x(x, pars)},
          y_transform = function(y) {self$architecture$transforms$y(y, pars, model$loss)}
        )

        valid_gen = make_data_generator(
          task = task,
          batch_size = pars$batch_size,
          filter_ids = rho$test_set(1),
          x_transform = function(x) {self$architecture$transforms$x(x, pars)},
          y_transform = function(y) {self$architecture$transforms$y(y, pars, model$loss)}
        )

        # Number of steps
        train_steps = ceiling(length(rho$train_set(1)) / pars$batch_size)
        valid_steps = ceiling(length(rho$test_set(1)) / pars$batch_size)

        # Train with generator
        if(pars$validation_split > 0) {
          history = invoke(keras::fit_generator,
                           object = model,
                           generator = train_gen,
                           epochs = as.integer(pars$epochs),
                           class_weight = pars$class_weight,
                           steps_per_epoch = train_steps,
                           validation_data = valid_gen,
                           validation_steps = valid_steps,
                           verbose = pars$verbose,
                           callbacks = pars$callbacks)
        } else {
          history = invoke(keras::fit_generator,
                           object = model,
                           generator = train_gen,
                           epochs = as.integer(pars$epochs),
                           class_weight = pars$class_weight,
                           steps_per_epoch = train_steps,
                           verbose = pars$verbose,
                           callbacks = pars$callbacks)
        }
      }
      return(list(model = model, history = history, class_names = task$class_names))
    },

    predict_internal = function(task) {
      pars = self$param_set$get_values(tags = "predict")

      features = task$data(cols = task$feature_names)
      newdata = self$architecture$transforms$x(features, pars)
      pars = pars[intersect(names(pars), self$keras_predict_pars)]
      response = prob = NULL

      if (inherits(self$model$model, "keras.engine.sequential.Sequential")) {
        if (self$predict_type == "response") {
          response = invoke(keras::predict_classes, self$model$model, x = newdata, .args = pars)
          response = drop(factor(self$model$class_names[response + 1]))
        } else if (self$predict_type == "prob") {
          p = invoke(keras::predict_proba, self$model$model, x = newdata, .args = pars)
          if (ncol(p) == 1L) {
            if (task$class_names[1] != task$positive) p = cbind(1 - p, p)
            else p = cbind(p, 1 - p)
          }
        }
      } else {
        p = invoke(self$model$model$predict, x = newdata, .args = pars)
          if (ncol(p) == 1L) {
            if (task$class_names[1] != task$positive) p = cbind(1 - p, p)
            else p = cbind(p, 1 - p)
          }
        if (self$predict_type == "response") {
          response = factor(self$model$class_names[apply(p, 1, which.max)])
        }
      }
      if (self$predict_type == "prob") {
        prob = p
        colnames(prob) = task$class_names
      }
      PredictionClassif$new(task = task, prob = prob, response = response)

    },
    save = function(filepath) {
      assert_path_for_output(filepath)
      if (is.null(self$model)) stop("Model must be trained before saving")
      keras::save_model_hdf5(self$model$model, filepath)
    },
    load_model_from_file = function(filepath) {
      assert_file_exists(filepath)
      self$state$model$model = keras::load_model_hdf5(filepath)
    },
    plot = function() {
      if (is.null(self$model)) stop("Model must be trained before saving")
      plot(self$model$history)
    },
    keras_predict_pars = c("batch_size", "verbose")
  )
)
