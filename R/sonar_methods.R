#' Method for plotting 'sonar' objects
#'
#' Returns a plot of the path using Longitude and Latitude
#'
#' @md
#' @param 'sonar' object
#' @return plot
#' @export plot.sonar
#' @export
plot.sonar <- function(x, n = 200){
  
  x_sub <- x[sample(nrow(x), n), ]
  
  plot(x_sub$Longitude, x_sub$Latitude, type = "b", xlab = "Longitude", ylab = "Latitude")

}

#' Method to subset 'sonar' objects
#'
#' Returns subset of 'sonar' object (data.frame)
#'
#' @md
#' @param i,j row and column indices
#' @return 'sonar' object
#' @export `[.sonar`
#' @export
`[.sonar` <- function(x, i, j, drop = FALSE) {
  .new_sonar(NextMethod())
}

#' Method to print 'sonar' objects
#'
#' Print 'sonar' object and report some statistics.
#'
#' @md
#' @param 'sonar' object
#' @return NULL
#' @export print.sonar
#' @export
print.sonar <- function(x){
  cat(paste0("'sonar' object containing ", nrow(x), " records."), "\n")
  cat("Data from channels:", paste0(sort(unique(x$SurveyTypeLabel)), collapse = ", "), "\n") #add count of types? table paste
  class(x) <- "data.frame"
  print(x[1:5,!(names(x) == "Frame")], row.names=FALSE)
}


