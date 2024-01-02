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

# Loading and installing packages if not already installed

proj_path<-"P:/312202_visavis/WP1_visualizations"
vp <- readRDS(paste0(proj_path,"/R/data/vp_table.rds"))
vp$datetime <- as.POSIXct(vp$datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
vp$date<-as.character(as.Date(vp$datetime))

dates<-as.Date(unique(vp$date))

radars<-readRDS(paste0(proj_path,"/R/data/radar_info.rds"))
radars<-st_as_sf(radars, coords = c("longitude","latitude"),crs=4326)


# vp <- separate(data = vp, col = datetime, into  = c('Date', 'Time'), sep = ' ')
radar_names<-vp%>%distinct(radar)

