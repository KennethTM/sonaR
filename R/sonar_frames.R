#' Function to extract raw sonar data
#'
#' Extract raw data from sonar recordings using a data.frame containing header data read from the same log same.
#' Returns raster with rawdata.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param sonar_header data.frame. Output data frame from sonar_header function containing header data
#' @param frametype String. Type of frame to be extracted, one of "Primary", "Secondary", "Downscan", "LeftSidescan", "RightSidescan", "Sidescan"
#' @param return_df Boolean. Return list of header data.frames with a list column containing each frame
#' @return sonaR_frames or sonaR_header if return_df = TRUE
#' @export

sonar_frames <- function(path, sonar_header, frametype, return_df = FALSE){
  
  format <- attr(sonar_header, "format")
  headersize <- ifelse(format == "2", 144, 168)
  good_types <- c("Primary", "Secondary", "Downscan", "LeftSidescan", "RightSidescan", "Sidescan")

  if(!file.exists(path)){
    
    stop("The file: ", path, " does not exist")
    
  }else if(!(format %in% c("2", "3")) & !inherits(sonar_header, "sonaR_header")){
    
    stop("The file: ", path, " is not an '.sl3' or '.sl2' and/or is not of type 'sonaR_header'")
    
  }else if(!(frametype %in% good_types)){
    
    stop("Invalid frametype: ", frametype, ". Must be one of ", paste0(good_types, collapse = ", "))
      
  }else{
    
    df_sub <- sonar_header[sonar_header$SurveyTypeLabel == frametype, ]

    if(nrow(df_sub) == 0){
      
      stop("No records of frametype: ", frametype, " in data.frame")
      
    }
    
    raw <- .sonar_read_raw(path)
    
    df_sub$Frame <- mapply(function(init, end){as.integer(raw[(init+headersize):(init+headersize+end-1)])},
                           df_sub$PositionOfFirstByte, 
                           df_sub$OriginalLengthOfEchoData,
                           SIMPLIFY = FALSE)
    
    x <- rle(df_sub$MaxRange)$lengths
    df_sub$FrameId <- rep(seq_along(x), times=x)
    
    df_sub_list <- split(df_sub, df_sub$FrameId)
    
    if(return_df){
      
      return(df_sub_list)
      
    }
    
    frame_matrix_list <- lapply(df_sub_list, function(df){return(.create_frame_matrix(df$Frame, c(df$MinRange[1], df$MaxRange[1])))})
    
    class(frame_matrix_list) <- c(class(frame_matrix_list), "sonaR_frames")
    
    return(frame_matrix_list)

    }
  
}
