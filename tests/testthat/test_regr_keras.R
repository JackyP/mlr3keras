context("keras regression custom model")

test_that("autotest regression custom model", {
  model = keras_model_sequential() %>%
  layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
  layer_dense(units = 12L, activation = "relu") %>%
  layer_dense(units = 1L, activation = "linear") %>%
    compile(optimizer = optimizer_adam(lr = 10e-3),
      loss = "mean_squared_error",
      metrics = "mean_squared_logarithmic_error")
  learner = LearnerRegrKeras$new()
  learner$param_set$values = list(model = model)
  learner$param_set$values$epochs = 3L
  expect_learner(learner)

  result = run_autotest(learner, exclude = "(feat_single|sanity)")
  expect_true(result, info = result$error)
  k_clear_session()
})

test_that("autotest low memory generator", {
  model = keras_model_sequential() %>%
    layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
    layer_dense(units = 12L, activation = "relu") %>%
    layer_dense(units = 1L, activation = "linear") %>%
    compile(optimizer = optimizer_adam(lr = 10e-3),
            loss = "mean_squared_error",
            metrics = "mean_squared_logarithmic_error")
  learner = LearnerRegrKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$low_memory=TRUE
  learner$param_set$values$epochs = 3L
  expect_learner(learner)
  
  result = run_autotest(learner, exclude = "(feat_single|sanity)")
  expect_true(result, info = result$error)
  k_clear_session()
})

test_that("autotest low memory zero validation_split", {
  model = keras_model_sequential() %>%
    layer_dense(units = 12L, input_shape = 2L, activation = "relu") %>%
    layer_dense(units = 12L, activation = "relu") %>%
    layer_dense(units = 1L, activation = "linear") %>%
    compile(optimizer = optimizer_adam(lr = 10e-3),
            loss = "mean_squared_error",
            metrics = "mean_squared_logarithmic_error")
  learner = LearnerRegrKeras$new()
  learner$param_set$values$model = model
  learner$param_set$values$low_memory=TRUE
  learner$param_set$values$validation_split=0  
  learner$param_set$values$epochs = 3L
  expect_learner(learner)
  
  result = run_autotest(learner, exclude = "(feat_single|sanity)")
  expect_true(result, info = result$error)
  k_clear_session()
})

context("keras regression feed forward model")

test_that("autotest feed forward", {
  learner = LearnerRegrKerasFF$new()
  learner$param_set$values$epochs = 3L
  expect_learner(learner)
  result = run_autotest(learner, exclude = "(feat_single|sanity)")
  expect_true(result, info = result$error)
  k_clear_session()
})