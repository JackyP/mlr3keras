#' @section Learner Methods:
#'
#' Keras Learners offer several methods for easy access to the
#' stored models.
#'
#' * `.$plot()`\cr
#'   Plots the history, i.e. the train-validation loss during training.
#' * `.$save(file_path)`\cr
#'   Dumps the model to a provided file_path in 'h5' format.
#' * `.$load_model_from_file(file_path)`\cr
#'   Loads a model saved using `saved` back into the learner.
#'   The model needs to be saved separately when the learner is serialized.
#'   In this case, the learner can be restored from this function.
#'   Currently not implemented for 'TabNet'.
