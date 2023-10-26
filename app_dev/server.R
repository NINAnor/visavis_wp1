## server
function(input, output, session) {
  
  ## render the basics
  output$radar_overview<-renderLeaflet(
    mapview(radars)@map
  )
  
  ## render the dates based on the radar station (to not have NA`s)
  dates_rad<-observeEvent(input$radar_stat,{
    dates_rad<-vp%>%filter(radar == input$radar_stat)%>%select(date)%>%distinct()
    
  })
  
  ## simple density graph y and daytime on x
  observeEvent(input$conf1,{
    # req(dates_rad)
    p1_dat_mean<-vp%>%filter(radar == input$radar_stat & date %in% input$dates)%>%select(height,dens,datetime)
    
    output$density_time<-renderPlotly(
        plot_ly(p1_dat_mean%>%group_by(datetime)%>%summarise(mean_dens = mean(dens, na.rm=T)), type = 'scatter', mode = 'lines')%>%
          add_trace(x = ~datetime, y = ~mean_dens, name = 'GOOG')  
    )
    
    output$heat_1<-renderPlotly(
      plot_ly(y=p1_dat_mean$height, x=p1_dat_mean$datetime, z = p1_dat_mean$dens, type = "heatmap") %>%
        layout(margin = list(l=120))
      
      
    )
    
    output$radar_sel<-renderLeaflet(
      mapview(radars%>%filter(radar == input$radar_stat))@map
    )

    
  })
  
}