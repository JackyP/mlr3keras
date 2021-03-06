% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LearnerRegrKeras.R
\name{LearnerRegrKeras}
\alias{LearnerRegrKeras}
\alias{mlr_learners_regr.keras}
\title{Keras Neural Network with custom architecture (Regression)}
\format{\code{\link[R6:R6Class]{R6::R6Class()}} inheriting from \link[mlr3:LearnerRegr]{mlr3::LearnerRegr}.}
\description{
Neural Network using Keras and Tensorflow.
This learner allows for supplying a custom architecture.
Calls \link[keras:fit]{keras::fit} from package \CRANpkg{keras}.

Parameters:\cr
Most of the parameters can be obtained from the \code{keras} documentation.
Some exceptions are documented here.
\itemize{
\item \code{model}: A compiled keras model.
\item \code{class_weight}: needs to be a named list of class-weights
for the different classes numbered from 0 to c-1 (for c classes).\preformatted{Example:
wts = c(0.5, 1)
setNames(as.list(wts), seq_len(length(wts)) - 1)
}
\item \code{callbacks}: A list of keras callbacks.
See \code{?callbacks}.
}
}
\section{Construction}{
\preformatted{LearnerRegrKeras$new()
mlr3::mlr_learners$get("regr.keras")
mlr3::lrn("regr.keras")
}
}

\section{Learner Methods}{


Keras Learners offer several methods for easy access to the
stored models.
\itemize{
\item \code{.$plot()}\cr
Plots the history, i.e. the train-validation loss during training.
\item \code{.$save(file_path)}\cr
Dumps the model to a provided file_path in 'h5' format.
\item \code{.$load_model_from_file(file_path)}\cr
Loads a model saved using \code{saved} back into the learner.
The model needs to be saved separately when the learner is serialized.
In this case, the learner can be restored from this function.
Currently not implemented for 'TabNet'.
}
}

\examples{
 # Define a model
 library(keras)
 model = keras_model_sequential() \%>\%
 layer_dense(units = 12L, input_shape = 10L, activation = "relu") \%>\%
 layer_dense(units = 12L, activation = "relu") \%>\%
 layer_dense(units = 1L, activation = "linear") \%>\%
   compile(optimizer = optimizer_sgd(),
     loss = "mean_squared_error",
     metrics = "mean_squared_error")
 # Create the learner
 learner = LearnerRegrKeras$new()
 learner$param_set$values$model = model
 learner$train(mlr3::mlr_tasks$get("mtcars"))
}
\seealso{
\link[mlr3misc:Dictionary]{Dictionary} of \link[mlr3:Learner]{Learners}: \link[mlr3:mlr_learners]{mlr3::mlr_learners}
}
