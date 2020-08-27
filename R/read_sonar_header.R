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
    stop("The file ", path, " does not exist")
  }else{
    
    filesize <- file.size(path)
    
    df <- read_slx(path, filesize, display_progress)
    
    format <- attr(df, "format")
    
    #Convert units and coordinates
    #https://wiki.openstreetmap.org/wiki/SL2
    
    #Convert feet to meter
    df[, c("MinRange", "MaxRange", "WaterDepth", "GNSS.Altitude")] <- df[, c("MinRange", "MaxRange", "WaterDepth", "GNSS.Altitude")] / 3.2808399
    
    #Convert knobs to m/s
    df[, c("WaterSpeed", "GNSS.Speed")] <-  df[, c("WaterSpeed", "GNSS.Speed")] / 3.2808399
    
    #Convert coordinates from Lowrance projection (+proj=merc +a=6356752.3142 +b=6356752.3142) to wgs84 lat/lon (epsg: 4326)
    POLAR_EARTH_RADIUS <- 6356752.3142
    
    df$lon <- df$XLowrance / POLAR_EARTH_RADIUS * (180/pi)
    df$lat <- ((2*atan(exp(df$YLowrance / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
    
    #Translate SurveyType
    df$SurveyTypeLabel <- ifelse(df$SurveyType == 0, "Primary",
                                 ifelse(df$SurveyType == 1, "Secondary",
                                        ifelse(df$SurveyType == 2, "DSI (Downscan)",
                                               ifelse(df$SurveyType == 3, "Left (Sidescan)",
                                                      ifelse(df$SurveyType == 4, "Right (Sidescan)",
                                                             ifelse(df$SurveyType == 5, "Composite (Sidescan)", "Unknown"))))))
    
    return(df)
    }
  }