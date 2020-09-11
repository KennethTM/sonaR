#' Function to plot a sonaR_frames object 
#'
#' Returns image plot with range on y-axis
#'
#' @md
#' @param frame_list sonaR_frames. A sonaR_frames object, which is a list of matrixes containing sonar data
#' @return plot
#' @export
plot.sonaR_frames <- function(frame_list){
  
  if(!inherits(frame_list, "sonaR_frames")){
    
    stop("The input is not of type 'sonaR_frames'")
    
  }
  
  rotate <- function(x){t(apply(x, 2, rev))}
  
  lapply(frame_list, function(frame){
    sonar_range <- round(attr(frame, "range"), 0)
    
    image(rotate(frame), useRaster = TRUE, axes = FALSE, ylab = "Depth (m)", xlab = "Frame number")
    axis(1, at=seq(0, 1, length.out = 6), labels = round(seq(1, ncol(frame), length.out = 6), 0))
    axis(2, at=seq(0, 1, length.out = 6), labels = rev(seq(sonar_range[1], sonar_range[2], length.out = 6)))
    box()
  })
}
