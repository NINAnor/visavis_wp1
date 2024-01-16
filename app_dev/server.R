## server
function(input, output, session) {
  
  ## render the basic information for the radars:
  output$radar_overview<-renderLeaflet(
    mapview(radars)@map
  )
  

  vp_day<-eventReactive(input$slid_day,{
    vp_day<-vp%>%filter(as.Date(date) == input$slid_day)
  })
  
  # create static part of map
  output$rad_dens <- renderLeaflet({
    leaflet() %>% addProviderTiles("CartoDB.Positron")   
  })
  
  # handle the update of the static map with reactive part
  observeEvent(input$slid_day,{
    in_map1<-int_prof%>%filter(as.Date(date) == input$slid_day)%>%
      select(mtr,vid,date,datetime,radar,dd,ff,mean_height)%>%filter(!is.na(dd))%>%group_by(radar,date)%>%summarise(mtr = mean(mtr, na.rm=T),
                                                                                                                    dd = mean.circular(circular(dd, units = "degrees", rotation =  "clock")),
                                                                                                                    ff = mean(ff, na.rm = T),
                                                                                                                    vid = mean(vid,na.rm = T),
                                                                                                                    mean_height = mean(mean_height,na.rm=T))%>%ungroup()%>%
      left_join(radars, by = "radar")%>%st_as_sf()%>% 
      mutate(direction_radians = dd * (pi / 180), 
             dd = round(dd, 2),
             lng_end = st_coordinates(geometry)[,1] + sin(direction_radians),
             lat_end = st_coordinates(geometry)[,2] + cos(direction_radians))
    
    
    mypal <- colorNumeric("Blues",   domain = 0:max(in_map1$mean_height)+1)
    
    met_sel<-meteo_info%>%filter(as.Date(day) == input$slid_day)%>% 
      mutate(direction_radians = mean_wd * (pi / 180), 
             mean_wd = round(mean_wd, 2),
             lng_end = st_coordinates(geometry)[,1] + sin(direction_radians),
             lat_end = st_coordinates(geometry)[,2] + cos(direction_radians))
    
    # update map
    leafletProxy("rad_dens") %>%
      clearMarkers() %>%
      clearFlows()%>%
      addCircleMarkers(data = in_map1, 
                       ~st_coordinates(in_map1$geometry)[,1], ~st_coordinates(in_map1$geometry)[,2], 
                       layerId = ~unique(radar), stroke = F)%>%
      addFlows(lng0 = st_coordinates(in_map1$geometry)[,1], 
               lat0 = st_coordinates(in_map1$geometry)[,2],
               lng1 = in_map1$lng_end, 
               lat1 = in_map1$lat_end, 
               dir = in_map1$direction_radians, 
               color =  mypal(in_map1$mean_height),
               maxThickness= in_map1$mean_height / max(in_map1$mean_height)*3,
               popup = popupArgs(showTitle = TRUE,
                                 supLabels  = c("NR","Radar station","Mean flight height","MTR","Ground speed [m/s]"),
                                 supValues = in_map1[c(11,7,3,5)]%>%st_drop_geometry(),
                                 digits = 0
               ))%>%
      addFlows(
        lng0 = st_coordinates(met_sel$geometry)[,1], 
        lat0 = st_coordinates(met_sel$geometry)[,2],
        lng1 = met_sel$lng_end, 
        lat1 = met_sel$lat_end, 
        dir = met_sel$direction_radians,
        maxThickness = 3
      )
  })
  
  
  
  
 #click on the arrow and see the daily details 
  ggplot_data <- reactive({
    req(vp_day)
    req(input$rad_dens_marker_click$id)
    site <- input$rad_dens_marker_click$id
    ggplot_data<-vp_day()%>%filter(radar == site)%>%select(height,dens,date,datetime)
  })
  
  output$day_rad <- renderPlot({
    req(ggplot_data)
    ggplot(ggplot_data(), aes(datetime, height, fill= dens)) + 
      geom_tile()
  }) 
  


  

  
}
