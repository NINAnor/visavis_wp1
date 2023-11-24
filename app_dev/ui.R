## ui

dashboardPage(
  header =  dashboardHeader(title = "VisAvis visualizations"),
  sidebar = dashboardSidebar(minified = F, disable = T),
  body = dashboardBody(
    fluidRow(
      box(title = "Study description",
          h5("Here can we integrate a description of the study aims, goals, methods..."),
          status = "primary",
          solidHeader = TRUE,
          collapsible = TRUE,
          collapsed = TRUE,
          width = 12),
      box(title = "Radar station details",
          h5("Here we could integrate a map with some details of the radar stations that have been used"),
          leafletOutput("radar_overview"),
          status = "primary",
          solidHeader = TRUE,
          collapsible = TRUE,
          collapsed = TRUE,
          width = 12)
    ),
    # fluidRow(
    #   br(),
    #   h4("choose the radar station of interest"),
    #   br(),

    # ),
    fluidRow(
      box(title = "Hourly migration patterns all stations",
                 solidHeader = TRUE,
                 collapsible = TRUE,
                 collappsed = FALSE,
                 width = 12,
          sliderInput(
            "slid_day",
            "choose day",
            min = min(dates),
            max = max(dates),
            value = mean(dates)
          ),
          # actionButton("conf1", "plot"),
          fluidRow(
            # column(8,
            plotlyOutput("density_time"),
            leafletOutput("rad_dens"),
                 # plotlyOutput("heat_1")
                 # ),
            # column(4,
            #      h5("2D migration pattern around radar?"),
            #      leafletOutput("radar_sel"))
          )
          )),
    fluidRow(
      box(
        title = "10-min migration single day height distribution",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        collapsed = TRUE,
        width = 12,
        selectInput("radar_stat",
                    "choose your radar station 1",
                    radar_names,
                    selected = NULL,
                    multiple = FALSE),
        dateInput(
          "in_day",
          "select date",
          value = mean(dates),
          min = min(dates),
          max = max(dates),
          format = "yyyy-mm-dd"
        ),
        actionButton("conf1","plot"),
        plotlyOutput("day_rad")
        
        )),
    
    # fluidRow(
    #   box(
    #     title = "Monthly migration patterns",
    #     status = "primary",
    #     solidHeader = TRUE,
    #     collapsible = TRUE,
    #     width = 12)
    # )
  )
)
