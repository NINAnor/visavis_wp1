## server
function(input, output, session) {
  
  ## render the basics
  output$radar_overview<-renderLeaflet(
    mapview(radars)@map
  )
  
  ## render the dates based on the radar station (to not have NA`s)
  # dates_rad<-observeEvent(input$radar_stat,{
  #   dates_rad<-vp%>%filter(radar == input$radar_stat)%>%select(date)%>%distinct()
  #   
  # })
  
  ## daily graphs 10min res
  observeEvent(input$slid_day,{
    
    # rads<-highlight_key(radar)
    
    in_day<-vp%>%filter(as.Date(date) == input$slid_day)%>%select(height,dens,date,datetime,radar,dd,ff)
      
    in_graph1<-in_day%>%group_by(radar,hour(datetime))%>%summarise(mean_dens = mean(dens, na.rm=T),
                                                                   dd = mean(dd, na.rm = T),
                                                                   ff = mean(ff, na.rm = T))%>%ungroup()
    colnames(in_graph1)<-c("radar","hour","mean_dens","dd","ff")
    
    in_map1<-in_graph1%>%group_by(radar)%>%
        summarise(mean_dens = mean(mean_dens, na.rm=T),
                  dd = mean(dd, na.rm = T),
                  ff = mean(ff, na.rm = T))%>%
        left_join(radars, by = "radar")%>%st_as_sf()%>% 
      mutate(direction_radians = dd * (pi / 180), 
             dd = round(dd, 2),
             lng_end = st_coordinates(geometry)[,1] + sin(direction_radians),
             lat_end = st_coordinates(geometry)[,2] + cos(direction_radians))
    

    # output$density_time<-renderPlotly(
    #     plot_ly(in_graph1,
    #             x = ~hour, y = ~mean_dens,
    #             name = ~radar, type = "scatter",  mode="lines")
    # 
    # )
    

    ## create a map with the circles as mean daily density
    output$rad_dens<-renderLeaflet(
      leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addCircleMarkers(data = in_map1, ~st_coordinates(in_map1$geometry)[,1], ~st_coordinates(in_map1$geometry)[,2], layerId = ~unique(radar), popup = ~unique(radar))%>%
        addFlows(lng0 = st_coordinates(in_map1$geometry)[,1], 
                 lat0 = st_coordinates(in_map1$geometry)[,2],
                 lng1 = in_map1$lng_end, 
                 lat1 = in_map1$lat_end, 
                 dir = in_map1$direction_radians, maxThickness= 0.85)
    )
    
    


  })
  
  
  ggplot_data <- reactive({
    site <- input$rad_dens_marker_click$id
    print(site)
    ggplot_data<-vp%>%filter(as.Date(date) == input$slid_day & radar == site)%>%select(height,dens,date,datetime)
  })
  
  output$day_rad <- renderPlot({
    req(ggplot_data)
    ggplot(ggplot_data(), aes(datetime, height, fill= dens)) + 
      geom_tile()
  }) 
  


  

  
}
