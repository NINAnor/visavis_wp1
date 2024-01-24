###### global file visAvis WP1 visualization app

#library(bioRad)
library(tidyverse)
library(ggplot2)
library(viridis)
library(plotly)
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(shinycssloaders)
library(sf)
library(leaflet)
library(mapview)
library(lubridate)
library(leaflet.minicharts)
library(circular)
library(ggpubr)
#library(nngeo)

# Loading and installing packages if not already installed


##12 radars,  10min and 10 altitudes:
vp <- readRDS("data/vp_table.rds")

##12radars, 10min alti integrated (1 alti per 10min)
int_prof<-readRDS("data/vpts_table_vertically_integrated.rds")

vp$datetime <- as.POSIXct(vp$datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
vp$date<-as.character(as.Date(vp$datetime))
int_prof$date<-as.character(as.Date(int_prof$datetime))

#dates for ui selection
dates<-as.Date(unique(vp$date))

# Radar static data (including closest NOAA met stat)
radars<-readRDS("data/radar_info.rds")
radars<-st_as_sf(radars, coords = c("longitude","latitude"),crs=4326)
colnames(radars)<-c("radar","params","rad_elev","beamwidth","rad_name","met_usaf","met_wban","met_station",
                         "met_ctry","st","call","met_elev","begin","end","code","geometry","met_rad_dist")



# vp <- separate(data = vp, col = datetime, into  = c('Date', 'Time'), sep = ' ')
radar_names<-radars%>%distinct(rad_name)
info_rad<-radars%>%select(radar,rad_name)

#meteo hourly
met_h<-readRDS("data/meteo_h_2022_NOR.rds")
met_h<-st_as_sf(met_h, coords = c("longitude","latitude"),crs=4326)

#meteo daily
met_d<-readRDS("data/meteo_d_2022_NOR.rds")
met_d<-st_as_sf(met_d, coords = c("lng","lat"),crs=4326)


##just for dev
# input=NULL
# input$slid_day<-dates[1]
