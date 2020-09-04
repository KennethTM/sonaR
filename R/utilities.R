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
  
  class(frame_matrix) <- c("SonaR_frame", class(frame_matrix))
  attr(frame_matrix, "range") <- sonar_range

  return(frame_matrix)
}

plot.SonaR_frame_list <- function(frame_list){
  rotate <- function(x){t(apply(x, 2, rev))}
  
  lapply(frame_list, function(frame){
    sonar_range <- round(attr(frame, "range"), 0)
    
    image(rotate(frame), useRaster = TRUE, axes = FALSE, ylab = "Depth (m)", xlab = "Frame number")
    axis(1, at=seq(0, 1, length.out = 6), labels = round(seq(1, ncol(frame), length.out = 6), 0))
    axis(2, at=seq(0, 1, length.out = 6), labels = rev(seq(sonar_range[1], sonar_range[2], length.out = 6)))
  })
}
