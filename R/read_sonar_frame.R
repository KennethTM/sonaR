#' Function to read raw sonar data
#'
#' Read raw data from sonar recordings using a data.frame containing header data.
#' Returns raster with rawdata.
#'
#' @md
#' @param path String. Path to '.sl3' or '.sl2' binary file
#' @param df data.frame. Output from read_sonar function
#' @param frametype String. Type of frame to be extracted, one of "Primary", "Secondary", "DSI (Downscan)", "Left (Sidescan)", "Right (Sidescan)", "Composite (Sidescan)"
#' @param georeference Boolean. Attempts to georeference sonar data using coordinates in header. Only possible for Sidescan data.
#' @return RasterLayer
#' @export

read_sonar_frame <- function(path, df, frametype, georeference = FALSE){
  
  format <- attr(df, "format")
  headersize <- ifelse(format == "2", 144, 168)

  if(!file.exists(path)){
    
    stop("The file ", path, " does not exist")
    
  }else if(!(format %in% c("2", "3"))){
    
    stop("The file ", path, " is not an '.sl3' or '.sl2' (missing attribute)")
    
  }else if(!(frametype %in% c("Primary", "Secondary", "DSI (Downscan)", "Left (Sidescan)", "Right (Sidescan)", "Composite (Sidescan)"))){
    
    stop("Invalid frametype:", frametype, ' . Must be one of "Primary", "Secondary", "DSI (Downscan)", "Left (Sidescan)", "Right (Sidescan)", "Composite (Sidescan)"')
      
    }else{
    
    df_sub <- df[df$SurveyTypeLabel == frametype, ]
    echo_length <- df_sub$OriginalLengthOfEchoData[1]
    
    if(nrow(df_sub) == 0){
      stop("No records of frametype: ", frametype, " in data.frame")
    }
      
    f <- file(path, "rb")
    raw <- readBin(f, "raw", n = file.size(path), endian="little")
    close(f)
    
    raw_list <- lapply(df_sub$PositionOfFirstByte, function(x){as.integer(raw[(x+headersize):(x+headersize+echo_length-1)])})
    
    mat <- do.call(cbind, raw_list)
    
    mat_raster <- raster::raster(mat, xmn=0, xmx=ncol(mat), ymn=0, ymx=nrow(mat))
    
    }
  
  if(georeference & frametype %in% c("Left (Sidescan)", "Right (Sidescan)", "Composite (Sidescan)")){
    
    POLAR_EARTH_RADIUS <- 6356752.3142
    
    df_sub$lon_r <- (df_sub$XLowrance - abs(df_sub$MinRange) * cos(df_sub$GNSS.Heading))/ POLAR_EARTH_RADIUS * (180/pi)
    df_sub$lon_l <- (df_sub$XLowrance + abs(df_sub$MaxRange) * cos(df_sub$GNSS.Heading))/ POLAR_EARTH_RADIUS * (180/pi)
    df_sub$lat_r <- ((2*atan(exp((df_sub$YLowrance - abs(df_sub$MinRange) * sin(df_sub$GNSS.Heading)) / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
    df_sub$lat_l <- ((2*atan(exp((df_sub$YLowrance + abs(df_sub$MaxRange) * sin(df_sub$GNSS.Heading)) / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
    
    df_sub$FrameNumber <- seq(1, nrow(df_sub), 1)
    
    mid <- cbind(df_sub$FrameNumber, 1400, df_sub$lon, df_sub$lat)
    right <- cbind(df_sub$FrameNumber, 2800, df_sub$lon_r, df_sub$lat_r)
    left <- cbind(df_sub$FrameNumber, 0, df_sub$lon_l, df_sub$lat_l)
    
    gcp <- rbind(mid[seq(1, nrow(mid), 25),],
                 right[seq(1, nrow(right), 25),],
                 left[seq(1, nrow(left), 25),])
    
    temp_rast <- file.path(tempdir(), "mat_raster.tif")
    temp_rast_gcp <- file.path(tempdir(), "mat_raster_gcp.tif")
    temp_rast_gcp_warp <- file.path(tempdir(), "mat_raster_gcp_warp.tif")
    
    raster::writeRaster(mat_raster, temp_rast, format = "GTiff", overwrite=TRUE)

    gdalUtils::gdal_translate(src_dataset = temp_rast, 
                              dst_dataset = temp_rast_gcp,
                              gcp = gcp, overwrite=TRUE)
    
    gdalUtils::gdalwarp(srcfile = temp_rast_gcp, dstfile = temp_rast_gcp_warp,
                        #tps = TRUE,
                        order = 2,
                        s_srs = "EPSG:4326", t_srs = "EPSG:4326",
                        ot = "Byte", dstnodata = 0, co = "COMPRESS=LZW",
                        r = "bilinear",
                        overwrite=TRUE)
    
    return(raster::raster(temp_rast_gcp_warp))
    
  }else{
    
    return(mat_raster)
    
  }
  
}
