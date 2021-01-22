library(sonaR)

#Test .sl2 file
test_sl2 <- paste0(getwd(), "/test/Sonar_2020-08-15_18.17.15.sl2")
#sl2 <- sonar_read(test_sl2)
# sl2_sub <- sl2[20000:30000,]
# saveRDS(sl2_sub, paste0(getwd(), "/test/sl2.rds"))
sl_sub <- readRDS(paste0(getwd(), "/test/sl2.rds"))

#Test .sl3 file
test_sl3 <- paste0(getwd(), "/test/Bromme 01.sl3")
#sl3 <- sonar_read(test_sl3)
# sl3_sub <- sl3[10000:30000,]
# saveRDS(sl3_sub, paste0(getwd(), "/test/sl3.rds"))
sl_sub <- readRDS(paste0(getwd(), "/test/sl3.rds"))

#Test package functionality
sl_sub
class(sl_sub)
sl_sub[1:5]
class(sl_sub[1:5])
sl_sub[1:10,]
class(sl_sub[1:10,])

plot(sl_sub)

sl_primary <- sonar_image(sl_sub, channel = "Primary")
sl_secondary <- sonar_image(sl_sub, channel = "Secondary")
sl_downscan <- sonar_image(sl_sub, channel = "Downscan")
sl_sidescan <- sonar_image(sl_sub, channel = "Sidescan")
sl_sidescan_norm <- sonar_image(sl_sub, channel = "Sidescan", normalize_sidescan = TRUE)

sonar_show_image(sl_primary)
sonar_show_image(sl_secondary)
sonar_show_image(sl_downscan)
sonar_show_image(sl_sidescan)
sonar_show_image(sl_sidescan_norm)

sl_geo <- sonar_sidescan_geo(sl_sub, res = 5e-06, normalize_sidescan = TRUE, fun = mean)
plot(sl_geo, col = rev(grey.colors(10)))
plot(sl_sub$Longitude, sl_sub$Latitude)

sl_intens <- sonar_depth_intensity(sl_sub, channel = "Primary", window_size = 0)

library(mapview)
mapview(sl_geo)


#Experimental code for iamge processing
# library(OpenImageR)
# 
# res_delate <- delationErosion(sl_sidescan_norm[[1]], Filter = c(9,9), method = 'delation')
# res_erode <- delationErosion(sl_sidescan_norm[[1]], Filter = c(9,9), method = 'erosion')
# res_gam <- gamma_correction(sl_sidescan_norm[[1]], 0.5)
# 
# image(sl_sidescan_norm[[1]], useRaster=TRUE)
# image(res_delate, useRaster=TRUE)
# image(res_erode, useRaster=TRUE)
# image(res_gam, useRaster=TRUE)






#Experimental code for file reading
# #extract subfile for experiements
# f <- file(test_sl2, "rb")
# raw <- readBin(f, "raw", n = file.size(test_sl2), endian="little")
# close(f)
# 
# header <- raw[1:8]
# filesize <- file.size(test_sl2)
# est_recs <- filesize/2000
# 
# meta_list <- vector("list", est_recs)
# frame_list <- vector("list", est_recs)
# 
# offset <- 8
# index <- 1
# 
# while (offset < length(raw)){
#   meta <- raw[(1+offset):(offset+144)]
#   PositionOfFirstByte <- readBin(meta[1:4], "int", size = 4)
#   OriginalLengthOfEchoData <- readBin(meta[35:36], "int", size=2, endian="little", signed=FALSE)
#   
#   meta_list[[index]] <- meta
#   frame_list[[index]] <- as.integer(raw[(PositionOfFirstByte+1+144):(PositionOfFirstByte+144+OriginalLengthOfEchoData)])
#   
#   index <- index + 1
#   offset <- (PositionOfFirstByte+144+OriginalLengthOfEchoData)
#   
#   if((index %% 10000) == 0){print(index)}
# }
# 
# meta_mat <- matrix(unlist(meta_list), nrow = 144)
# 
# PositionOfFirstByte_vec <- readBin(meta_mat[1:4,], what = "integer", size = 4, n=10)
# 
# raw_sub <- raw[1:10000000]
# test_sl2_sub <- paste0(getwd(), "/test/Sonar_2020-08-15_18.17.15_sub.sl2")
# fw <- file(test_sl2_sub, "wb")
# writeBin(raw_sub, fw, endian="little", useBytes = FALSE)
# close(fw)
