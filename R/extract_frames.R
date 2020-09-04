#' Function to extract raw sonar data
#'
#' Extract raw data from sonar recordings using a data.frame containing header data read from the same log same.
#' Returns raster with rawdata.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param df data.frame. Output data frame from read_sonar function containing header data
#' @param frametype String. Type of frame to be extracted, one of "Primary", "Secondary", "Downscan", "LeftSidescan", "RightSidescan", "Sidescan"
#' @param georeference Boolean. Attempts to georeference sonar data using coordinates in header. Only possible for Sidescan data.
#' @return RasterLayer
#' @export

extract_frames <- function(path, df, frametype, georeference = FALSE){
  
  format <- attr(df, "format")
  sonaR_type <- attr(df, "sonaR")
  headersize <- ifelse(format == "2", 144, 168)
  good_types <- c("Primary", "Secondary", "Downscan", "LeftSidescan", "RightSidescan", "Sidescan")

  if(!file.exists(path)){
    
    stop("The file: ", path, " does not exist")
    
  }else if(!(format %in% c("2", "3")) & sonaR_type != "header"){
    
    stop("The file: ", path, " is not an '.sl3' or '.sl2' and/or is not of type 'header'")
    
  }else if(!(frametype %in% good_types)){
    
    stop("Invalid frametype:", frametype, " . Must be one of ", good_types)
      
  }else{
    
    df_sub <- df[df$SurveyTypeLabel == frametype, ]

    if(nrow(df_sub) == 0){
      
      stop("No records of frametype: ", frametype, " in data.frame")
      
    }
    
    f <- file(path, "rb")
    raw <- readBin(f, "raw", n = file.size(path), endian="little")
    close(f)
    
    df_sub$Frame <- mapply(function(init, end){as.integer(raw[(init+headersize):(init+headersize+end-1)])},
                           df_sub$PositionOfFirstByte, 
                           df_sub$OriginalLengthOfEchoData,
                           SIMPLIFY = FALSE)
    
    x <- rle(df_sub$MaxRange)$lengths
    df_sub$FrameId <- rep(seq_along(x), times=x)
    
    df_sub_list <- split(df_sub, df_sub$FrameId)
    
    frame_matrix_list <- lapply(df_sub_list, function(df){return(.create_frame_matrix(df$Frame, c(df$MinRange[1], df$MaxRange[1])))})
    
    class(frame_matrix_list) <- c("SonaR_frame_list", class(frame_matrix_list))
    
    return(frame_matrix_list)

    }

  # if(georeference & frametype %in% c("Left (Sidescan)", "Right (Sidescan)", "Composite (Sidescan)")){
  #   
  #   POLAR_EARTH_RADIUS <- 6356752.3142
  #   
  #   df_sub$lon_r <- (df_sub$XLowrance - abs(df_sub$MinRange) * cos(df_sub$GNSS.Heading))/ POLAR_EARTH_RADIUS * (180/pi)
  #   df_sub$lon_l <- (df_sub$XLowrance + abs(df_sub$MaxRange) * cos(df_sub$GNSS.Heading))/ POLAR_EARTH_RADIUS * (180/pi)
  #   df_sub$lat_r <- ((2*atan(exp((df_sub$YLowrance - abs(df_sub$MinRange) * sin(df_sub$GNSS.Heading)) / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
  #   df_sub$lat_l <- ((2*atan(exp((df_sub$YLowrance + abs(df_sub$MaxRange) * sin(df_sub$GNSS.Heading)) / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
  #   
  #   df_sub$FrameNumber <- seq(1, nrow(df_sub), 1)
  #   
  #   mid <- cbind(df_sub$FrameNumber, 1400, df_sub$lon, df_sub$lat)
  #   right <- cbind(df_sub$FrameNumber, 2800, df_sub$lon_r, df_sub$lat_r)
  #   left <- cbind(df_sub$FrameNumber, 0, df_sub$lon_l, df_sub$lat_l)
  #   
  #   gcp <- rbind(mid[seq(1, nrow(mid), 25),],
  #                right[seq(1, nrow(right), 25),],
  #                left[seq(1, nrow(left), 25),])
  #   
  #   temp_rast <- file.path(tempdir(), "mat_raster.tif")
  #   temp_rast_gcp <- file.path(tempdir(), "mat_raster_gcp.tif")
  #   temp_rast_gcp_warp <- file.path(tempdir(), "mat_raster_gcp_warp.tif")
  #   
  #   raster::writeRaster(mat_raster, temp_rast, format = "GTiff", overwrite=TRUE)
  # 
  #   gdalUtils::gdal_translate(src_dataset = temp_rast, 
  #                             dst_dataset = temp_rast_gcp,
  #                             gcp = gcp, overwrite=TRUE)
  #   
  #   gdalUtils::gdalwarp(srcfile = temp_rast_gcp, dstfile = temp_rast_gcp_warp,
  #                       #tps = TRUE,
  #                       order = 2,
  #                       s_srs = "EPSG:4326", t_srs = "EPSG:4326",
  #                       ot = "Byte", dstnodata = 0, co = "COMPRESS=LZW",
  #                       r = "bilinear",
  #                       overwrite=TRUE)
  #   
  #   return(raster::raster(temp_rast_gcp_warp))
  #   
  # }else{
  #   
  #   return(mat_raster)
  #   
  # }
  
}
