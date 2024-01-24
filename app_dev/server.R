## server
function(input, output, session) {
  
  ## render the basic map and information for the radars:
  output$radar_overview<-renderLeaflet(
    mapview(radars)@map
  )
  

  # vp_day<-eventReactive(input$slid_day,{
  #   vp_day<-vp%>%filter(as.Date(date) == input$slid_day)
  # })
  
  int_prof_day<-eventReactive(input$slid_day,{
    int_prof_day<-int_prof%>%filter(as.Date(date) == input$slid_day)
  })
  
  met_day_sel<-eventReactive(input$slid_day,{
    met_day_sel<-met_d%>%filter(as.Date(day) == input$slid_day)
  })
  
  
  # create static part of the proxy map
  output$rad_dens <- renderLeaflet({
    leaflet() %>% addProviderTiles("CartoDB.Positron") %>%  
      setView(lng = 10,
              lat = 64,
              zoom = 5)
  })
  
  # handle the update of the static map with reactive part
  observeEvent(input$slid_day,{
    req(int_prof_day)
    req(met_day_sel)


    int_prof_day<-int_prof_day()
    met_day_sel<-met_day_sel()
    
    ## aggregate for day
    migration_day<-int_prof_day%>%
      select(mtr,vid,date,datetime,radar,dd,ff,mean_height)%>%
      filter(!is.na(dd))%>%
      group_by(radar,date)%>%summarise(mtr = mean(mtr, na.rm=T),
                                       dd = mean.circular(circular(dd, units = "degrees", rotation =  "clock")),
                                       ff = mean(ff, na.rm = T),
                                       vid = mean(vid,na.rm = T),
                                       mean_height = mean(mean_height,na.rm=T))%>%
      ungroup()%>%
      left_join(info_rad, by = "radar")%>%st_as_sf()%>% 
      mutate(direction_radians = dd * (pi / 180), 
             dd = round(dd, 2),
             lng_end = st_coordinates(geometry)[,1] + sin(direction_radians),
             lat_end = st_coordinates(geometry)[,2] + cos(direction_radians))
    
    
    #mypal <- colorNumeric("Blues",   domain = 0:max(migration_day$mean_height)+1)
    
    met_day_sel<-met_day_sel%>% 
      mutate(direction_radians = mean_wd * (pi / 180), 
             mean_wd = round(mean_wd, 2),
             lng_end = st_coordinates(geometry)[,1] + sin(direction_radians),
             lat_end = st_coordinates(geometry)[,2] + cos(direction_radians))
    
    ## diff between wind and birds direction
    #dir_diff<-st_join(migration_day,met_day_sel,join = st_nn,k=1, maxdist = 200000, progress = FALSE)%>%mutate(diff_dir = dd - mean_wd)
    
    # update map
    leafletProxy("rad_dens") %>%
      clearMarkers() %>%
      clearFlows()%>%
      addCircleMarkers(data = migration_day, 
                       ~st_coordinates(migration_day$geometry)[,1], ~st_coordinates(migration_day$geometry)[,2], 
                       layerId = ~unique(radar), stroke = T, color = "orange")%>%
      addFlows(lng0 = st_coordinates(migration_day$geometry)[,1], 
               lat0 = st_coordinates(migration_day$geometry)[,2],
               lng1 = migration_day$lng_end, 
               lat1 = migration_day$lat_end, 
               dir = migration_day$direction_radians, 
               color =  "orange",
               maxThickness= 2,
               popup = popupArgs(showTitle = TRUE,
                                 supLabels  = c("NR","Radar station","Mean flight height","MTR","Ground speed [m/s]"),
                                 supValues = migration_day[c(11,7,3,5)]%>%st_drop_geometry(),
                                 digits = 0
               ))%>%
      addCircleMarkers(data = met_day_sel,
                       ~st_coordinates(met_day_sel$geometry)[,1], ~st_coordinates(met_day_sel$geometry)[,2], 
                        stroke = F, color = "blue")%>%
      addFlows(
        lng0 = st_coordinates(met_day_sel$geometry)[,1], 
        lat0 = st_coordinates(met_day_sel$geometry)[,2],
        lng1 = met_day_sel$lng_end, 
        lat1 = met_day_sel$lat_end, 
        dir = met_day_sel$direction_radians,
        color = "blue",
        popup = popupArgs(labels = "Mean wind direction & speed"),
        maxThickness = 2
      )
  })
  
  
  
  
 #click on the arrow and see the daily details 
  migration_dens_rad_day <- reactive({
    req(input$rad_dens_marker_click$id)
    req(int_prof_day)
    site <- input$rad_dens_marker_click$id
    migration_param_rad_day<-int_prof_day()%>%filter(radar == site)%>%select(datetime,mean_height,ff,dd)
    
    migration_dens_rad_day<-vp%>%filter(as.Date(date) == input$slid_day & radar == site)%>%
                            select(height,dens,date,datetime)%>%
                              left_join(
                                        migration_param_rad_day,
                                        by="datetime",
                                        multiple = "first")
    
    })
  
  # migration_param_rad_day<-reactive({
  #   req(input$rad_dens_marker_click$id)
  #   req(int_prof_day)
  #   site <- input$rad_dens_marker_click$id
  # 
  #   colnames(migration_param_rad_day)<-c("datetime","height")
  # })

  output$day_rad <- renderPlot({
    req(migration_dens_rad_day)

    heat<-ggplot(migration_dens_rad_day(), aes(datetime, height, fill= dens)) +
      geom_tile()
    # + 
    #   geom_line(aes(datetime, mean_height),color = "red")
    
    spoke<-  ggplot(migration_dens_rad_day(), aes(datetime, mean_height)) +
      geom_point() +
      geom_spoke(aes(angle = dd, radius = ff*200))

    ggarrange(heat, spoke, nrow = 2, label.x = "datetime", align = "v")
      
      
  })
  
  



  

  
}
