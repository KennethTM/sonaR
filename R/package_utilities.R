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

.sonar_read_raw <- function(path){
  f <- file(path, "rb")
  raw <- readBin(f, "raw", n = file.size(path), endian="little")
  close(f)
  
  return(raw)
}

.new_sonar <- function(x){
  stopifnot(is.data.frame(x))
  
  class(x) <- c("sonar", "data.frame")
  
  return(x)
}

.metadata_corr <- function(df){
  
  #Convert feet to meter
  df[, c("MinRange", "MaxRange", "WaterDepth", "GNSSAltitude")] <- df[, c("MinRange", "MaxRange", "WaterDepth", "GNSSAltitude")] / 3.2808399
  
  #Convert knobs to m/s
  df[, c("WaterSpeed", "GNSSSpeed")] <-  df[, c("WaterSpeed", "GNSSSpeed")] / 1.94385
  
  #Translate SurveyType to labels
  df$SurveyTypeLabel <- .add_SurveyTypeLabel(df$SurveyType)
  
  return(df)
}

.add_frameid <- function(df){
  x <- rle(df$MaxRange)$lengths
  return(rep(seq_along(x), times=x))
}

.create_frame_matrix <- function(raw_list, sonar_range){

  frame_matrix <- do.call(cbind, raw_list)

  attr(frame_matrix, "range") <- sonar_range

  return(frame_matrix)
}

.norm_sidescan <- function(mat){
  rowmean <- rowMeans(mat)
  mat_norm <- mat/rowmean
  return(mat_norm)
}