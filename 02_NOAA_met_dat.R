install.packages("rnoaa")
library(worldmet)
library(nngeo)
library(dplyr)
library(sf)
library(rnoaa)
library(circular)

## visavis radar stations
proj_path<-"P:/312202_visavis/WP1_visualizations"
radars<-readRDS(paste0(proj_path,"/R/data/radar_info.rds"))
radars<-st_as_sf(radars, coords = c("longitude","latitude"),crs=4326)

## nearest meteostat to radar
a<-getMeta(country = "NO")
a<-st_as_sf(a,coords = c("longitude","latitude"),crs=4326)

nn = st_nn(radars, a, k = 1, maxdist = 200000, progress = FALSE)

rad_inf_new<-st_join(radars, a, join = st_nn, k = 1, maxdist = 200000, progress = FALSE)
n = st_nn(radars, a, k = 1, returnDist = TRUE, progress = FALSE)
dists = sapply(n[[2]], "[", 1)
rad_inf_new$dist_to_stat = dists


test_day<-importNOAA(code = rad_inf_new$code, year = 2022)%>%mutate(day = as.Date(date))%>%filter(!is.na(wd))%>%group_by(day,station,code)%>%summarise(mean_ws = mean(ws,na.rm=T),
                                                                                                                                                       mean_wd = mean.circular(circular(wd, units = "degrees", rotation =  "clock")),
                                                                                                                                                       mean_tmp = mean(air_temp,na.rm=T),
                                                                                                                                                       mean_pres = mean(atmos_pres,na.rm=T),
                                                                                                                                                       lng = mean(longitude),
                                                                                                                                                       lat = mean(latitude))


## VISAVIS radar to meteo stations:
test_day<-test_day%>%left_join(rad_inf_new,by="code")%>%select(day, code, station.x, mean_pres,mean_wd,mean_pres,mean_tmp, lng, lat, radar, location_name)

saveRDS(test_day,paste0(proj_path,"/R/data/meteo_info.rds"))


