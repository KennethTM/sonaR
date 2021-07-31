#' Function to extract raw sonar data as images/matrix
#'
#' Extracts raw sonar data from 'sonar' object and returns list of matrices that can be plotted.
#' New matrix is created for each time the range (MinRange and MaxRange attached to matrices as attribute) of the recorded sonar data changes.
#'
#' @md
#' @param 'sonar' object
#' @param channel Target channel which should be converted to matrix
#' @param normalize_sidescan Boolean. Normalize sidescan data using the mean intensity for each angle.
#' @return list of matrices with range attribute
#' @export sonar_image
#' @export
sonar_image <- function(sonar, channel, normalize_sidescan = FALSE){
  good_types <- c("Primary", "Secondary", "Downscan", "Sidescan")
  
  if(!inherits(sonar, "sonar")){
    stop("Object must of type 'sonar'.")
  }
  
  if(!(channel %in% good_types)){
    stop("Invalid type: ", channel, ". Must be one of ", paste0(good_types, collapse = ", "))
  }
  
  sonar_sub <- sonar[sonar$SurveyTypeLabel == channel, ]
  
  if(nrow(sonar_sub) == 0){
    stop("No records of type: ", channel, " in data.")
  }
  
  sonar_sub$FrameId <- .add_frameid(sonar_sub)
  
  sonar_sub_list <- split(sonar_sub, sonar_sub$FrameId)
  
  frame_matrix_list <- lapply(sonar_sub_list, function(df){return(.create_frame_matrix(df$Frame, c(df$MinRange[1], df$MaxRange[1])))})
  
  if(all(normalize_sidescan, channel == "Sidescan")){
    frame_matrix_list <- lapply(frame_matrix_list, .norm_sidescan)
  }
  
  return(frame_matrix_list)
  
}

#' Function to plot sonar data
#'
#' Plots output from sonar_image function. One plot for each matrix is created.
#'
#' @md
#' @param list List of matrices returned from sonar_image function
#' @return Plot of all images
#' @export sonar_show_image
#' @export
sonar_show_image <- function(mat_list){
  
  rotate <- function(x){t(apply(x, 2, rev))}
  
  lapply(mat_list, function(frame){
    sonar_range <- round(attr(frame, "range"), 0)
    
    image(rotate(frame), useRaster = TRUE, axes = FALSE, ylab = "Depth (m)", xlab = "Frame number")
    axis(1, at=seq(0, 1, length.out = 6), labels = round(seq(1, ncol(frame), length.out = 6), 0))
    axis(2, at=seq(0, 1, length.out = 6), labels = rev(seq(sonar_range[1], sonar_range[2], length.out = 6)))
    box()
  })
  
}

#' Function to extract raw sonar data at waterdepth
#'
#' Extracts and returns a new column with the raw sonar intensity at the reported waterdepth
#' Optionally, a window size can be given to smooth the result.
#'
#' @md
#' @param 'sonar' object
#' @param channel Target channel for which intensity at depth should be extracted
#' @param window_size Default = 0. 
#' @return 'sonar' object with column 'IntensityAtDepth' added
#' @export sonar_depth_intensity
#' @export
sonar_depth_intensity <- function(sonar, channel, window_size = 0){
  good_types <- c("Primary", "Secondary", "Downscan")
  
  if(!inherits(sonar, "sonar")){
    stop("Object must of type 'sonar'.")
  }
  
  if(!(channel %in% good_types)){
    stop("Invalid type: ", channel, ". Must be one of ", paste0(good_types, collapse = ", "))
  }
    
    sonar_sub <- sonar[sonar$SurveyTypeLabel == channel, ]
    
  if(nrow(sonar_sub) == 0){
    stop("No records of type: ", channel, " in data.")
  }
    
    intesity_index <- as.integer((sonar_sub$OriginalLengthOfEchoData / sonar_sub$MaxRange) * sonar_sub$WaterDepth)
    
    sonar_sub$IntensityAtDepth <- mapply(function(ind, frame){
      if(ind == 0){
        return(NA)
      }else if(window_size == 0){
        return(frame[ind])
      }else{
        return(mean(frame[(ind-window_size):(ind+window_size)]))
      }
    }, 
    intesity_index,
    sonar_sub$Frame,
    SIMPLIFY = TRUE)
    
    return(sonar_sub)
    
  }
  
#' Function to georeference sidescan data extracted from sonar
#'
#' Creates georeferenced version of raw sidescan sonar data from XYZ points using raster::rasterize.
#' Returns output Raster object with sidescan data.
#'
#' @md
#' @param 'sonar' object
#' @param res Target resolution for grid in degrees. 
#' @param fun Default = max. Function passed to rasterize.
#' @return Raster object
#' @export sonar_sidescan_geo
#' @export
sonar_sidescan_geo <- function(sonar, res = 0.000005, normalize_sidescan = FALSE, slant_range = FALSE, fun = max, return_df = FALSE){

  if(!inherits(sonar, "sonar")){
    stop("Object must of type 'sonar'.")
  }
  
  sonar_sub <- sonar[sonar$SurveyTypeLabel == "Sidescan", ]
  
  if(nrow(sonar_sub) == 0){
    stop("No records of type: Sidescan in data.")
  }
  
  frame_length <- length(sonar_sub$Frame[[1]])
  
  if(slant_range){
    dist <- mapply(function(min, max, depth){
      ground_dist <- seq(min, max, length.out = frame_length)
      slant_dist <- sqrt(abs(ground_dist)^2+depth^2)*sign(ground_dist)
      return(slant_dist)
    },
    sonar_sub$MinRange,
    sonar_sub$MaxRange,
    sonar_sub$WaterDepth,
    SIMPLIFY = FALSE)
  }else{
    dist <- mapply(function(min, max){
      seq(min, max, length.out = frame_length)
    },
    sonar_sub$MinRange,
    sonar_sub$MaxRange,
    SIMPLIFY = FALSE)
  }
  
  pix_lon <- mapply(function(x_coord, pix, heading){
    .x_to_lon(x_coord + pix * cos(heading))
    #(x_coord + pix * cos(heading))
  },
  sonar_sub$XLowrance,
  dist,
  sonar_sub$GNSSHeading, 
  SIMPLIFY = FALSE)
  
  pix_lat <- mapply(function(y_coord, pix, heading){
    .y_to_lat(y_coord + pix * sin(heading))
    #(y_coord + pix * sin(heading))
  },
  sonar_sub$YLowrance,
  dist,
  sonar_sub$GNSSHeading, 
  SIMPLIFY = FALSE)
  
  x <- unlist(pix_lon)
  y <- unlist(pix_lat)
  
  rast_template <- raster::raster(xmn = min(x), xmx = max(x), ymn = min(y), ymx = max(y),
                                  crs = "+proj=longlat +datum=WGS84 +no_defs",
                                  res = res)
  
  z <- unlist(sonar_sub$Frame)
  
  if(normalize_sidescan){
    z_mat <- matrix(z, nrow=frame_length)
    z_mat <- .norm_sidescan(z_mat)
    z <- as.vector(z_mat)
  }
  
  if(return_df){
    return(data.frame(x=x, y=y, z=z))
  }else{
    rast_sidescan <- raster::rasterize(cbind(x, y), rast_template, fun = fun, field = z)
    
    return(rast_sidescan)
  }
  
}
