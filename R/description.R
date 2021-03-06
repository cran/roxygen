#' @include roxygen.R
#' @include list.R
#' @include string.R
#' @include functional.R
roxygen()

#' Parse lines of text corresponding to a package DESCRIPTION file.
#' @param description the lines of tex
#' @return A list of values indexed by field
parse.description.text <- function(description) {
  fields <- new.env(parent=emptyenv())
  current.field <- NULL
  FIELD <- '^[^:[:space:]]*'
  SEPARATOR <- ':'

  contains.field <- function(line)
    length(grep(paste(FIELD, SEPARATOR, sep=''), line)) > 0

  field <- function(line)
    substr.regexpr(FIELD, line)
  
  rest <- function(line)
    substr(line, nchar(field(line)) + 2, nchar(line))

  continue <- function(description) {
    if (!is.nil(description)) {
      line <- car(description)
      if (contains.field(line)) {
        field <- field(line)
        rest <- rest(line)
        fields[[field]] <- trim(rest)
        current.field <<- field
      } else {
        fields[[current.field]] <-
          paste(fields[[current.field]],
                trim(line))
      }
      continue(cdr(description))
    }
  }
  continue(description)
  ## Reverse the fields, since they come out of the environment in
  ## cons-order.
  rev(as.list(fields))
}

#' Convenience function to call
#' \code{\link{parse.description.text}}
#' with the given \file{DESCRIPTION} file.
#' @param description.file the \file{DESCRIPTION} file to be parsed
#' @return \code{NULL}
parse.description.file <- function(description.file)
  parse.description.text(readLines(description.file))

#' Print the field-value pair to a given file or standard out.
#' @param field the field to be printed
#' @param value the value to be printed
#' @param file the file whither to print (a blank string being
#' standard out)
#' @return \code{NULL}
cat.description <- function(field, value, file='')
  cat(strwrap(sprintf('%s: %s', field, value),
              exdent=4),
      sep='\n',
      file=file,
      append=TRUE)

#' Description parser that does nothing
#' @param field the field to be parsed
#' @param value the value to be parsed
#' @return \code{NULL}
noop.description <- function(field, value) NULL

#' Make a parser to parse \file{DESCRIPTION} files.
#'
#' Contains the member functions \code{register.parser},
#' taking a field and parser; and \code{parse}, taking the
#' parsed fields from \code{\link{parse.description.file}}
#' or similar.
#'
#' @param parse.default the default parser receiving
#' a field and value
#' @param pre.parse a function receiving the parsed fields
#' before individual parsing
#' @param post.parse a function receiving the parsed fields
#' after individual parsing
#' @return \code{NULL}
make.description.parser <- function(parse.default=cat.description,
                                    pre.parse=noop.description,
                                    post.parse=noop.description) {
  parser <- new.env(parent=emptyenv())
  parsers <- new.env(parent=emptyenv())
  parser$register.parser <- function(field, parser)
    parsers[[field]] <- parser
  parser$register.parsers <- function(registrate, ...)
    for (field in c(...))
      parser$register.parser(field, registrate)
  parser$parse <- function(parsed.fields) {
    field.values <- function(parsed.fields)
      zip.list(names(parsed.fields),
               parsed.fields)
    if (!is.null(pre.parse)) pre.parse(parsed.fields)
    for (field.value in field.values(parsed.fields)) {
      field <- car(field.value)
      value <- cadr(field.value)
      parser <- parsers[[field]]
      if (is.null(parser))
        parse.default(field, value)
      else
        parser(field, value)
    }
    if (!is.null(post.parse)) post.parse(parsed.fields)
  }
  parser
}

#' Gather a \file{DESCRIPTION}'s dependencies from the
#' \code{Package}, \code{Depends}, \code{Imports}, \code{Suggests},
#' and \code{Enhances} fields.
#' @param description.file the \file{DESCRIPTION} to parse
#' @return A list of dependencies
#' @TODO Test this!
description.dependencies <- function(description.file) {
  dependencies <- NULL
  split.dependencies <- function(parsed.fields)
    Map(Curry(substr.regexpr, pattern='[^[:space:](]*'),
        trim(car(strsplit(dependencies, split=',', fixed=TRUE))))
  parser <- make.description.parser(noop.description,
                                    post.parse=split.dependencies)
  augment.dependencies <- function(field, value)
    dependencies <<- paste(value, dependencies, sep=',')
  
  parser$register.parsers(augment.dependencies,
                          'Package',
                          'Depends',
                          'Imports',
                          'Suggests',
                          'Enhances')
  parser$parse(parse.description.file(description.file))
}
