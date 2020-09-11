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

sonar_sidescan_geo <- function(path, sonar_header){
  
  frame_list <- sonar_frames(path = path, sonar_header = sonar_header, frametype = "Sidescan", return_df = TRUE)
  
  frame_list_add_geo <- lapply(frame_list, .add_geo)
  
  raster_list <- lapply(frame_list_add_geo, .geo_ref)
  
  return(raster_list)
  
}
  
  

  
