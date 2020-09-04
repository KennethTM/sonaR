library(sonaR)

#Test .sl2 file
test_sl2 <- paste0(getwd(), "/test/Sonar_2020-08-15_18.17.15.sl2")

sl2_head <- read_sonar_header(test_sl2)
#saveRDS(sl2_head, paste0(getwd(), "/test/sl2_head.rds"))
sl2_head <- readRDS(paste0(getwd(), "/test/sl2_head.rds"))
sl2_head_sub <- sl2_head[100000:120000,]

plot(sl2_head_sub$lon, sl2_head_sub$lat)
sl2_frame_Primary <- extract_frames(test_sl2, sl2_head_sub, "Primary")
sl2_frame_Secondary <- extract_frames(test_sl2, sl2_head_sub, "Secondary")
sl2_frame_Sidescan <- read_sonar_frame(test_sl2, sl2_head_sub, "Composite (Sidescan)")

plot(sl2_frame_Primary)
plot(sl2_frame_Secondary)
plot(sl2_frame_Sidescan)

sl2_frame_Sidescan_geo <- read_sonar_frame(test_sl2, sl2_head_sub, "Composite (Sidescan)", georeference = TRUE)

plot(sl2_frame_Sidescan_geo)

#Test .sl3 file
test_sl3 <- paste0(getwd(), "/test/Bromme 01.sl3")

sl3_head <- read_sonar_header(test_sl3)
saveRDS(sl3_head, paste0(getwd(), "/test/sl3_head.rds"))
sl3_head <- readRDS(paste0(getwd(), "/test/sl3_head.rds"))
sl3_head_sub <- sl3_head[100000:200000,]

plot(sl3_head_sub$lon, sl3_head_sub$lat)

sl3_frame_Primary <- read_sonar_frame(test_sl3, sl3_head_sub, "Primary")
sl3_frame_Downscan <- read_sonar_frame(test_sl3, sl3_head_sub, "DSI (Downscan)")
sl3_frame_Sidescan <- read_sonar_frame(test_sl3, sl3_head_sub, "Composite (Sidescan)")

plot(sl3_frame_Primary)
plot(sl3_frame_Downscan)
plot(sl3_frame_Sidescan)

sl3_frame_Sidescan_geo <- read_sonar_frame(test_sl3, sl3_head_sub, "Composite (Sidescan)", georeference = TRUE)

plot(sl3_frame_Sidescan_geo)

#KML(sl3_frame_Sidescan_geo, paste0(getwd(), "/test/test_sl3.kml"), col = heat.colors(10), overwrite = TRUE)

# #Split to equal parts
# n <- 10
# nr <- nrow(df)
# split(df, rep(1:ceiling(nr/n), each=n, length.out=nr))



