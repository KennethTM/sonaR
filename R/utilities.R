#Utility functions for internal use in package

#Convert coordinates from Lowrance projection (+proj=merc +a=6356752.3142 +b=6356752.3142) to wgs84 lat/lon (epsg: 4326)
.x_to_lon <- function(x){
  POLAR_EARTH_RADIUS <- 6356752.3142
  lon <- x / POLAR_EARTH_RADIUS * (180/pi)
  return(lon)
}

.y_to_lat <- function(y){
  POLAR_EARTH_RADIUS <- 6356752.3142
  lat <-  ((2*atan(exp(y / POLAR_EARTH_RADIUS))) - (pi/2)) * (180/pi)
  return(lat)
}

.add_SurveyTypeLabel <- Vectorize(function(SurveyType){
  if(SurveyType==0){
    label = "Primary"
  }
  else if(SurveyType==1){
    label = "Secondary"
  }
  else if(SurveyType==2){
    label = "Downscan"
  }
  else if(SurveyType==3){
    label = "LeftSidescan"
  }
  else if(SurveyType==4){
    label = "RightSidescan"
  }
  else if(SurveyType==5){
    label = "Sidescan"
  }
  else{
    label = "Unknown"
  }
  
  return(label)
})

.create_frame_matrix <- function(raw_list, sonar_range){
  
  frame_matrix <- do.call(cbind, raw_list)
  
  attr(frame_matrix, "range") <- sonar_range

  return(frame_matrix)
}

.add_geo <- function(df){
  df$LongitudeRight <- .x_to_lon(df$XLowrance - abs(df$MinRange) * cos(df$GNSSHeading))
  df$LongitudeLeft <- .x_to_lon(df$XLowrance + abs(df$MaxRange) * cos(df$GNSSHeading))
  df$LatitudeRight <- .y_to_lat(df$YLowrance - abs(df$MinRange) * sin(df$GNSSHeading)) 
  df$LatitudeLeft <- .y_to_lat(df$YLowrance + abs(df$MaxRange) * sin(df$GNSSHeading))
  
  df$FrameNumber <- seq(1, nrow(df), 1)
  
  return(df)
}

.geo_ref <- function(df, sidescan_width = 2800, gcp_interval = 25){
  mid <- cbind(df$FrameNumber, sidescan_width/2, df$Longitude, df$Latitude)
  right <- cbind(df$FrameNumber, sidescan_width, df$LongitudeRight, df$LatitudeRight)
  left <- cbind(df$FrameNumber, 0, df$LongitudeLeft, df$LatitudeLeft)
  
  gcp <- rbind(mid[seq(1, nrow(mid), gcp_interval),],
               right[seq(1, nrow(right), gcp_interval),],
               left[seq(1, nrow(left), gcp_interval),])
  
  tmp_rast <- file.path(tempdir(), "tmp_raster.tif")
  tmp_rast_gcp <- file.path(tempdir(), "tmp_raster_gcp.tif")
  tmp_rast_gcp_warp <- file.path(tempdir(), "tmp_raster_gcp_warp.tif")
  
  frame_matrix <- .create_frame_matrix(df$Frame, c(df$MinRange[1], df$MaxRange[1]))
  
  frame_raster <- raster::raster(frame_matrix, xmn=0, xmx=ncol(frame_matrix), ymn=0, ymx=nrow(frame_matrix))
  
  raster::writeRaster(frame_raster, tmp_rast, format = "GTiff", overwrite=TRUE)
  
  gdalUtils::gdal_translate(src_dataset = tmp_rast,
                            dst_dataset = tmp_rast_gcp,
                            gcp = gcp,
                            overwrite=TRUE)
  
  gdalUtils::gdalwarp(srcfile = tmp_rast_gcp,
                      dstfile = tmp_rast_gcp_warp,
                      #tps = TRUE,
                      order = 2,
                      s_srs = "EPSG:4326", 
                      t_srs = "EPSG:4326",
                      ot = "Byte", 
                      dstnodata = 0, 
                      co = "COMPRESS=LZW",
                      r = "near",
                      overwrite=TRUE)
  
  return(raster::raster(tmp_rast_gcp_warp))
}

.sonar_read_raw <- function(path){
  f <- file(path, "rb")
  raw <- readBin(f, "raw", n = file.size(path), endian="little")
  close(f)
  
  return(raw)
}
