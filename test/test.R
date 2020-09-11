library(sonaR)


# test_file <- system.file("exdat", "example.sl2", package="arabia")
# test_head <- sonar_header(test_file)
# test_frame <- sonar_frames(test_file, test_head, "Secondary")
# plot(test_frame)

#Test .sl2 file
test_sl2 <- paste0(getwd(), "/test/Sonar_2020-08-15_18.17.15.sl2")

sl2_head <- sonar_header(test_sl2)
saveRDS(sl2_head, paste0(getwd(), "/test/sl2_head.rds"))
sl2_head <- readRDS(paste0(getwd(), "/test/sl2_head.rds"))
sl2_head_sub <- sl2_head[113000:117000,]

plot(sl2_head_sub$Longitude, sl2_head_sub$Latitude)

sl2_frame_Primary <- sonar_frames(test_sl2, sl2_head_sub, "Primary")
sl2_frame_Sidescan <- sonar_frames(test_sl2, sl2_head_sub, "Sidescan")

plot(sl2_frame_Primary)
plot(sl2_frame_Sidescan)

sl2_frame_Sidescan_geo <- sonar_sidescan_geo(test_sl2, sl2_head_sub)
plot(sl2_frame_Sidescan_geo[[1]])

sl2_frame_Primary_intens_at_depth <- sonar_intens_at_depth(test_sl2, sl2_head_sub, "Primary", window_size = 0)

library(tidyverse)
sl2_frame_Primary_intens_at_depth %>% 
  ggplot(aes(Longitude, Latitude, col = IntensityAtDepth))+
  geom_point()+
  theme_bw()

#Test .sl3 file
test_sl3 <- paste0(getwd(), "/test/Bromme 01.sl3")

sl3_head <- sonar_header(test_sl3)
saveRDS(sl3_head, paste0(getwd(), "/test/sl3_head.rds"))
sl3_head <- readRDS(paste0(getwd(), "/test/sl3_head.rds"))
sl3_head_sub <- sl3_head[25000:30000,]

plot(sl3_head_sub$Longitude, sl3_head_sub$Latitude)

sl3_frame_Primary <- sonar_frames(test_sl3, sl3_head_sub, "Primary")
sl3_frame_Downscan <- sonar_frames(test_sl3, sl3_head_sub, "Downscan")
sl3_frame_Sidescan <- sonar_frames(test_sl3, sl3_head_sub, "Sidescan")

plot(sl3_frame_Primary)
plot(sl3_frame_Downscan)
plot(sl3_frame_Sidescan)

sl3_frame_Sidescan_geo <- sonar_sidescan_geo(test_sl3, sl3_head_sub)
plot(sl3_frame_Sidescan_geo[[1]])

sl3_frame_Primary_intens_at_depth <- sonar_intens_at_depth(test_sl3, sl3_head_sub, "Sidescan", window_size = 0)

sl3_frame_Primary_intens_at_depth %>% 
  ggplot(aes(Longitude, Latitude, col = IntensityAtDepth))+
  geom_point()+
  theme_bw()
