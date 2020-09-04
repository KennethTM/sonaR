#' Function to read data stored in recorded sonar files.
#' 
#' Read data from sonar. Only '.sl2' and '.sl3' formats by Lowrance are currently supported.
#' Data are stored as a header followed by a frame containing the raw sonar data. 
#' The function returns a data.frame where each row represents a header.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param display_progress Boolean. Display progress bar?
#' @return data.frame
#' @export

read_sonar_header <- function(path, display_progress = TRUE){
  
  if(!file.exists(path)){
    stop("The file: ", path, " does not exist")
  }else{
    
    filesize <- file.size(path)
    
    df <- read_slx(path, filesize, display_progress)
    
    names(df) <- gsub(".", "", names(df), fixed = TRUE)
    
    #Convert feet to meter
    df[, c("MinRange", "MaxRange", "WaterDepth", "GNSSAltitude")] <- df[, c("MinRange", "MaxRange", "WaterDepth", "GNSSAltitude")] / 3.2808399
    
    #Convert knobs to m/s
    df[, c("WaterSpeed", "GNSSSpeed")] <-  df[, c("WaterSpeed", "GNSSSpeed")] / 1.94385
    
    df$Longitude <- .x_to_lon(df$XLowrance)
    df$Latitude <- .y_to_lat(df$YLowrance)
    
    #Translate SurveyType
    df$SurveyTypeLabel <- .add_SurveyTypeLabel(df$SurveyType)
    
    attr(df, "sonaR") <- "header"
    
    return(df)
    }
  }