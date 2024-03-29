#' create S3 method for class \code{grouped_df}
#'
#' Given an S3 method for class \code{data.frame}, create an S3 method
#' for class \code{grouped_df} for the same generic function.
#'
#' This is a utility function for writing packages.
#' Functions that modify data frames by replacing or adding columns may fail
#' on grouped data frames so the class will require a dedicated method.
#' This is a generalized constructor of such methods.
#'
#' In all cases the original call to \code{foo} is captured with \code{match.call}
#' and reconstructed into a call to the \code{data.frame} method.
#' Grouping variables are isolated as a list, and the first argument of \code{foo},
#' which must be named \code{x}, is split into a list with \code{split}, using the
#' list of grouping variables as splitting factors. Empty levels are dropped.
#' The list is then passed to \code{lapply}, with the call to the \code{data.frame} method
#' as \code{FUN}. The result is reconstituted into a single \code{data.frame} with
#' \code{unsplit}, again dropping empty levels.
#'
#' @section How to use:
#' When creating an .R file for generic \code{foo} and its S3 methods,
#' simply add another entry where \code{foo.grouped_df} is defined as the result of
#' \code{data.frame__to__grouped_df} acting on \code{foo.data.frame}.
#'
#' Copy the following \code{roxygen} tag before the function definition
#' to have it show up nicely in the documentation file:
#'
#' \code{@describeIn foo see \\code{\\link[metamethods]{data.frame__to__grouped_df}}}
#'
#' @param fun a function; this must be an S3 method for class \code{data.frame};
#'            also, its first argument must be named \code{x}
#'
#' @return a function: a method for class \code{grouped_df} (from package \code{dplyr})
#'
#' @export
#'
data.frame__to__grouped_df <- function(fun) {

  if (!is.function(fun)) stop('"fun" must be a function')
  FORMALS <- formals(fun)
  if (names(FORMALS)[1] != 'x') stop('the first argument of the function must be named "x", see package metamethods')
  BODY <- quote(
    {
      # capture call
      original_call <- as.list(match.call())
      # isolate name of generic
      generic <- sub('.grouped_df', '', deparse(original_call[[1]]), fixed = TRUE)
      # drop function and first argument to isolate additional arguments
      original_arguments <- original_call[-(1:2)]
      # get data frame method
      new_method <- utils::getS3method(f = generic, class = 'data.frame', optional = FALSE)
      # save attributes of x
      xats <- attributes(x)
      # obtain a list of factors from grouping variables
      group_vars <- setdiff(names(attr(x, 'groups')), '.rows')
      f_list <- as.list(x[group_vars])
      # convert x to normal data frame and split
      X <- data.frame(x)
      Xs <- split(X, f = f_list, drop = TRUE)
      # construct call to lapply
      new_call <-
        as.call(
          append(list(quote(lapply), X = quote(Xs), FUN = new_method),
                 original_arguments))
      # run operation
      yl <- eval(new_call)
      # # convert resulting by object to list and then to data frame
      Y <- unsplit(yl, f = f_list, drop = TRUE)
      # update column names within the attribute list
      xats$names <- names(Y)
      # restore attributes
      attributes(Y) <- xats
      return(Y)
    })

  FUN <- as.function(append(FORMALS, BODY))
  return(FUN)
}
