install.packages("worldmet")
library(worldmet)
library(nngeo)

## nearest meteostat to radar
a<-getMeta(country = "NO")
a<-st_as_sf(a,coords = c("longitude","latitude"),crs=4326)
radar_info<-st_as_sf(radar_info, coords = c("longitude","latitude"),crs=4326)

nn = st_nn(radar_info, a, k = 1, maxdist = 200000, progress = FALSE)

rad_inf_new<-st_join(radar_info, a, join = st_nn, k = 1, maxdist = 200000, progress = FALSE)
n = st_nn(radar_info, a, k = 1, returnDist = TRUE, progress = FALSE)
dists = sapply(n[[2]], "[", 1)
rad_inf_new$dist_to_stat = dists

test<-importNOAA(code = "011070-99999", year = 2022)
