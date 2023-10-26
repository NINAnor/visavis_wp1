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
    
    in_day<-vp%>%filter(as.Date(date) == input$slid_day)%>%select(height,dens,date,datetime,radar)
      
    in_graph1<-in_day%>%group_by(radar,datetime)%>%summarise(mean_dens = mean(dens, na.rm=T))%>%ungroup()
    in_map1<-in_day%>%group_by(radar)%>%summarise(mean_dens = mean(dens, na.rm=T))%>%ungroup() %>% left_join(radars, by = "radar")%>%st_as_sf()
    

    output$density_time<-renderPlotly(
        plot_ly(in_graph1,
                x = ~datetime, y = ~mean_dens,
                name = ~radar, type = "scatter",  mode="lines")
        
    )
    ## create a map with the circles as mean daily density
    output$rad_dens<-renderLeaflet(
      leaflet(in_map1) %>% addTiles() %>%
        addCircles( weight = 1,
                   radius = ~mean_dens * 100000, popup = ~radar
        )
    )

  })
  
  ## weekly graphs 1h 
  
}