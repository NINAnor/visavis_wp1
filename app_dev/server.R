## server
function(input, output, session) {
  
  ## simple density graph y and daytime on x
  observeEvent(input$disp_graph,{
    p1_dat_mean<-vp%>%filter(radar == input$radar_stat & date == as.Date(input$dates))%>%select(height,dens,datetime)
    
    output$density_time<-renderPlotly(
        plot_ly(p1_dat_mean%>%group_by(datetime)%>%summarise(mean_dens = mean(dens, na.rm=T)), type = 'scatter', mode = 'lines')%>%
          add_trace(x = ~datetime, y = ~mean_dens, name = 'GOOG')  
    )
    
    output$heat_1<-renderPlotly(
      plot_ly(y=p1_dat_mean$height, x=p1_dat_mean$datetime, z = p1_dat_mean$dens, type = "heatmap") %>%
        layout(margin = list(l=120))
      
      
    )

    
  })
  
}