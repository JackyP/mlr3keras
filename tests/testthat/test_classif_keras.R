context("keras classif custom model")

test_that("autotest binary", {

  model = keras_model_sequential() %>%
  layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
  layer_dense(units = 12L, activation = "relu") %>%
  layer_dense(units = 2L, activation = "softmax") %>%
    compile(optimizer = optimizer_sgd(),
      loss = "categorical_crossentropy",
      metrics = c("accuracy"))
  learner = LearnerClassifKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$epochs = 2L
  expect_learner(learner)

  skip_on_os("solaris")
  result = run_autotest(learner, exclude = "(feat_single|sanity|multiclass)")
  expect_true(result, info = result$error)
  k_clear_session()
})

test_that("autotest low memory generator binary", {

  model = keras_model_sequential() %>%
    layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
    layer_dense(units = 12L, activation = "relu") %>%
    layer_dense(units = 2L, activation = "softmax") %>%
    compile(optimizer = optimizer_sgd(),
            loss = "categorical_crossentropy",
            metrics = c("accuracy"))
  learner = LearnerClassifKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$low_memory=TRUE
  learner$param_set$values$epochs = 2L
  expect_learner(learner)

  skip_on_os("solaris")
  result = run_autotest(learner, exclude = "(feat_single|sanity|multiclass)")
  expect_true(result, info = result$error)
  k_clear_session()
})


test_that("autotest low memory zero validation_split", {

  model = keras_model_sequential() %>%
    layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
    layer_dense(units = 12L, activation = "relu") %>%
    layer_dense(units = 2L, activation = "softmax") %>%
    compile(optimizer = optimizer_sgd(),
            loss = "categorical_crossentropy",
            metrics = c("accuracy"))
  learner = LearnerClassifKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$low_memory=TRUE
  learner$param_set$values$validation_split=0
  learner$param_set$values$epochs = 2L
  expect_learner(learner)

  skip_on_os("solaris")
  result = run_autotest(learner, exclude = "(feat_single|sanity|multiclass)")
  expect_true(result, info = result$error)
  k_clear_session()
})


test_that("autotest multiclass", {

  model = keras_model_sequential() %>%
  layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
  layer_dense(units = 12L, activation = "relu") %>%
  layer_dense(units = 3L, activation = "softmax") %>%
    compile(optimizer = optimizer_sgd(),
      loss = "categorical_crossentropy",
      metrics = c("accuracy"))
  learner = LearnerClassifKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$epochs = 2L
  expect_learner(learner)

  skip_on_os("solaris")
  result = run_autotest(learner, exclude = "(feat_single|sanity|binary)")
  expect_true(result, info = result$error)
  k_clear_session()
})

test_that("can fit with binary_crossentropy", {
  skip_on_os("solaris")
  skip_if_not(require("mlr3pipelines"))

  po_imp = PipeOpImputeMedian$new()
  lrn = lrn("classif.keras", predict_type = "prob")
  po_lrn = PipeOpLearner$new(lrn)
  model = keras_model_sequential() %>%
  layer_dense(units = 12L, input_shape = 8L, activation = "relu") %>%
  layer_dense(units = 12L, activation = "relu") %>%
  layer_dense(units = 1L, activation = "sigmoid") %>%
    compile(optimizer = optimizer_adam(3*10^-4),
      loss = "binary_crossentropy",
      metrics = "accuracy")
  po_lrn$param_set$values$model = model
  po_lrn$param_set$values$epochs = 10L
  pipe = po_imp %>>% po_lrn
  pipe$train(mlr_tasks$get("pima"))

  expect_list(pipe$state)
  expect_list(pipe$pipeops$classif.keras$state$model)
  prd = pipe$predict(mlr_tasks$get("pima"))
  expect_class(prd[[1]], "PredictionClassif")

  pipe$pipeops$classif.keras$learner$predict_type = "prob"
  prd2 = pipe$predict(mlr_tasks$get("pima"))
  expect_class(prd2[[1]], "PredictionClassif")
  expect_matrix(prd2[[1]]$prob, nrows = 768L, ncols = 2L)
  expect_true(all(prd[[1]]$response == prd2[[1]]$response))
})

test_that("Learner methods", {
  # Only checked for classif, as this is
  # equivalent between learners.
  fp = tempfile(fileext = ".h5")
  lrn = lrn("classif.kerasff", predict_type = "prob", epochs = 3L)
  expect_error(lrn$plot())
  expect_error(lrn$save(fp))
  lrn$train(mlr_tasks$get("iris"))

  # Saving to h5
  lrn$save(fp)
  expect_file_exists(fp)
  unlink(fp)

  # Plotting
  p = lrn$plot()
  expect_class(p, "ggplot")
  k_clear_session()
})

# test_that("Custom optimizer methods", {
#   require("reticulate")
#   skip_if_not(reticulate::py_module_available("keras_radam"))
#   kr = import("keras_radam")
#   radam = kr$training$RAdamOptimizer()
#   sgd = optimizer_sgd()
#   lrn = lrn("classif.kerasff", predict_type = "prob", epochs = 3L, optimizer = radam)
#   lrn$train(mlr_tasks$get("iris"))
# })
