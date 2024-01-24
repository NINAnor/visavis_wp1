# this skript loads norwegian meteo ground station from NOAA, selects the closest to VISAVIS radars

#install.packages("rnoaa")
library(worldmet)
library(nngeo)
library(dplyr)
library(sf)
library(rnoaa)
library(circular)

## visavis radar stations
proj_path<-"P:/312202_visavis/WP1_visualizations"
#read in the 12 wp1 radars
radars<-readRDS(paste0(proj_path,"/R/data/radar_info.rds"))
radars<-st_as_sf(radars, coords = c("longitude","latitude"),crs=4326)

## Norwegian NOAA met stations
met_stat<-getMeta(country = "NO")
met_stat<-st_as_sf(met_stat,coords = c("longitude","latitude"),crs=4326)
### closest met_stat to radar within 200km
nn = st_nn(radars, met_stat, k = 1, maxdist = 200000, progress = FALSE)

#enrich radar with closest met_stat
rad_inf_new<-st_join(radars, met_stat, join = st_nn, k = 1, maxdist = 200000, progress = FALSE)
n = st_nn(radars, met_stat, k = 1, returnDist = TRUE, progress = FALSE)
dists = sapply(n[[2]], "[", 1)
rad_inf_new$dist_to_stat = dists
saveRDS(rad_inf_new,paste0(proj_path,"/R/data/radar_info.rds"))


#hourly data for meteo stations
meteo_full<-importNOAA(code = rad_inf_new$code, year = 2022)%>%
  mutate(day = as.Date(date))%>%
  filter(!is.na(wd))

meteo_full<-meteo_full%>%left_join(rad_inf_new,by="code")%>%select(day, code, station.x, atmos_pres,wd,ws,air_temp, longitude, latitude, radar, location_name)



saveRDS(meteo_full,paste0(proj_path,"/R/data/meteo_h_2022_NOR.rds"))



meteo_day<-meteo_full%>%
  group_by(day,station.x,code)%>%summarise(mean_ws = mean(ws,na.rm=T),
                                         mean_wd = mean.circular(circular(wd, units = "degrees", rotation =  "clock")),
                                         mean_tmp = mean(air_temp,na.rm=T),
                                         mean_pres = mean(atmos_pres,na.rm=T),
                                         lng = mean(longitude),
                                         lat = mean(latitude))


## VISAVIS radar to meteo stations:
meteo_day<-meteo_day%>%left_join(rad_inf_new,by="code")%>%select(day, code, station.x, mean_pres,mean_wd,mean_pres,mean_tmp, lng, lat, radar, location_name)

saveRDS(meteo_day,paste0(proj_path,"/R/data/meteo_d_2022_NOR.rds"))


