#' Read data stored in sonar files.
#' 
#' Function to read recorded data from sonar files. 
#' Only '.sl2' and '.sl3' formats by Lowrance are currently supported.
#' Data are stored as a header containing metadata for each recording (e.g. coordinates, water tempereature, speed etc.) followed by a frame containing the raw sonar 'ping' data.
#' All data is returned in one object of type 'sonar' which in essence is a data.frame, where each row represents a recording with frame data stored in a list-column.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param display_progress Boolean. Display progress bar?
#' @param read_frames Boolean. Read metadata and frames.
#' @return Object of class sonar.
#' @export

sonar_read <- function(path, display_progress = TRUE, read_frames = TRUE){
  
  if(!file.exists(path)){
    
    stop("The file: ", path, " does not exist")
    
  }else{
    
    filesize <- file.size(path)
    
    df <- read_slx(path, filesize, display_progress)

    names(df) <- gsub(".", "", names(df), fixed = TRUE)

    df$Longitude <- .x_to_lon(df$XLowrance)
    df$Latitude <- .y_to_lat(df$YLowrance)
    
    df <- .metadata_corr(df)
  
    vars_to_keep <- c("SurveyTypeLabel", "Latitude", "Longitude", "XLowrance", "YLowrance", "OriginalLengthOfEchoData", "MinRange",  "MaxRange", "WaterDepth", "WaterTemperature", "GNSSAltitude", "GNSSSpeed", "GNSSHeading")
    
    if(read_frames){
      
      #Add frame data as list-column
      raw <- .sonar_read_raw(path)
      
      #Get format
      format <- attr(df, "format")
      headersize <- ifelse(format == "2", 144, 168)
      
      df$Frame <- mapply(
        function(init, end){
          as.integer(raw[(init+headersize+1):(init+headersize+end)]) #(init+headersize+end-1) ??
        },
        df$PositionOfFirstByte,
        df$OriginalLengthOfEchoData,
        SIMPLIFY = FALSE)
      
      vars_to_keep <- c(vars_to_keep, "Frame")
      }
    
    df <- df[,vars_to_keep]
    
    #Return object of class sonar
    return(.new_sonar(df))
    
    }
}
