###### global file visAvis WP1 visualization app

library(bioRad)
library(tidyverse)
library(ggplot2)
library(viridis)
library(plotly)
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(sf)
library(leaflet)
library(mapview)
library(lubridate)
library(dygraphs)
library(leaflet.minicharts)
library(circular)

# Loading and installing packages if not already installed

proj_path<-"P:/312202_visavis/WP1_visualizations"
## 10min and 10 altitudes:
vp <- readRDS(paste0(proj_path,"/R/data/vp_table.rds"))

## 5min alti integrated (1 alti per 5min)
int_prof<-readRDS(paste0(proj_path,"/R/data/vpts_table_vertically_integrated.rds"))

vp$datetime <- as.POSIXct(vp$datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
vp$date<-as.character(as.Date(vp$datetime))
int_prof$date<-as.character(as.Date(int_prof$datetime))

dates<-as.Date(unique(vp$date))

# Radar static data
radars<-readRDS(paste0(proj_path,"/R/data/radar_info.rds"))
radars<-st_as_sf(radars, coords = c("longitude","latitude"),crs=4326)


# vp <- separate(data = vp, col = datetime, into  = c('Date', 'Time'), sep = ' ')
radar_names<-radars%>%distinct(location_name)

#meteo info
meteo_info<-readRDS(paste0(proj_path,"/R/data/meteo_info.rds"))
meteo_info<-st_as_sf(meteo_info, coords = c("lng","lat"),crs=4326)

