#' Function to extract raw sidescan data and perform georeferencing using points in header
#'
#' Extract raw data from sonar recordings using a data.frame containing header data read from the same log same.
#' Returns raster with rawdata.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param sonar_header data.frame. Output data frame from sonar_header function containing header data
#' @return list containing RasterLayer objects
#' @export

sonar_intens_at_depth <- function(path, sonar_header, frametype, window_size = 0){
  
  format <- attr(sonar_header, "format")
  headersize <- ifelse(format == "2", 144, 168)
  good_types <- c("Primary", "Secondary", "Downscan")
  
  if(!(frametype %in% good_types)){
    
    stop("Invalid frametype: ", frametype, ". Must be one of ", paste0(good_types, collapse = ", "))
    
  }else{
    
    df_sub <- sonar_header[sonar_header$SurveyTypeLabel == frametype, ]
    
    if(nrow(df_sub) == 0){
      
      stop("No records of frametype: ", frametype, " in data.frame")
      
    }
  }
  
  raw <- .sonar_read_raw(path)
  
  df_sub$Frame <- mapply(function(init, end){as.integer(raw[(init+headersize):(init+headersize+end-1)])},
                         df_sub$PositionOfFirstByte, 
                         df_sub$OriginalLengthOfEchoData,
                         SIMPLIFY = FALSE)
  
  intesity_index <- as.integer((df_sub$OriginalLengthOfEchoData / df_sub$MaxRange) * df_sub$WaterDepth)
  
  df_sub$IntensityAtDepth <- mapply(function(ind, frame){
    if(ind == 0){
      return(NA)
    }else if(window_size == 0){
      return(frame[ind])
    }else{
      return(mean(frame[(ind-window_size):(ind+window_size)]))
    }
    }, 
    intesity_index,
    df_sub$Frame,
    SIMPLIFY = TRUE)
  
  return(df_sub)
  
}




