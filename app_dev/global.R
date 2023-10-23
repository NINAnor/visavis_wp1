###### global file visAvis WP1 visualization app

##


library(bioRad)
library(tidyverse)
library(ggplot2)
library(viridis)
library(plotly)
library(shiny)
library(shinydashboard)

# Loading and installing packages if not already installed

proj_path<-"P:/312202_visavis/WP1_visualizations"
vp <- readRDS(paste0(proj_path,"/R/data/vp_table.rds"))
vp$datetime <- as.POSIXct(vp$datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
vp$date<-as.Date(vp$datetime)
# vp <- separate(data = vp, col = datetime, into  = c('Date', 'Time'), sep = ' ')
radars<-vp%>%distinct(radar)
dates<-unique(vp$date)


# Extracting data component of vp file
# vp_nohgb_data <- vp_nohgb[["data"]]
# # see ?summary.vp for a description of the variables in the vp
# 
# # Plotting bird density in single vertical profile
# ggplot(vp_nohgb_data, aes(x = dens, y = height)) + 
#   geom_point(size = 1) + geom_path() + theme_bw() +
#   ylab("Metres above sea level") + xlab("Animals pr km^3") + ggtitle("nohgb")



