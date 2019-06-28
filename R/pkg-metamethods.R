#' metamethods: Generalized converters for S3 methods.
#'
#' This package automatically creates S3 methods. Well, not so much creates as modifies.
#' Given a method for one class, it will generate an appropriate method for another.
#' This is meant to smoothline writing packages.
#'
#' @section \code{data.frame} to \code{grouped_df}:
#' \code{dplyr}'s class \code{grouped_df} is an efficient and conveneint way
#' to run operations on sections of data frames. Running \code{mutate} on
#' a \code{grouped_df} will calculate on subsets of a column. However,
#' calling a function that operates ona data frame rather than a vector
#' is somewhat difficult without a deeper understanding of the class.
#' This is easily bypassed by creating a separate S3 method for \code{grouped_df}.
#'
#' @author Aleksander Chlebowski, Warsaw, 28 May 2019
#'
#' @docType package
#' @name metamethods
NULL
