## ui

dashboardPage(
  dashboardHeader(title = "VisAvis WP1"),
  dashboardSidebar(
    selectInput("radar_stat",
                "choose your radar station",
                radars,
                selected = NULL,
                multiple = FALSE),
    dateInput(
      "dates",
      "choose day",
      value = dates,
      min = min(dates),
      max = max(dates),
      format = "yyyy-mm-dd",
      startview = "month",
      weekstart = 0,
      language = "en",
      width = NULL,
      autoclose = TRUE,
      datesdisabled = NULL,
      daysofweekdisabled = NULL
    ),
    actionButton("disp_graph","display graph")
  ),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      plotlyOutput("density_time")
      # box(
      #   plotOutput("plot1", height = 250)
      #   ),
      
      # box(
      #   title = "Controls",
      #   sliderInput("slider", "Number of observations:", 1, 100, 50)
      # )
    ),
    fluidRow(
      plotlyOutput("heat_1")
    )
  )
)