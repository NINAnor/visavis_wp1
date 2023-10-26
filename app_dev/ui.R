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
          collapsed = FALSE,
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
    fluidRow(
      br(),
      h4("choose the radar station of interest"),
      br(),
      selectInput("radar_stat",
                  "choose your radar station",
                  radar_names,
                  selected = NULL,
                  multiple = FALSE)
    ),
    fluidRow(
      box(title = "Daily migration patterns",
                 solidHeader = TRUE,
                 collapsible = TRUE,
                 collappsed = TRUE,
                 width = 12,
          selectInput(
            "dates",
            "choose day",
            choices = dates_rad
            # min = min(dates_rad),
            # max = max(dates_rad),
            # format = "yyyy-mm-dd",
            # startview = "month",
            # weekstart = 0,
            # language = "en",
            # width = NULL,
            # autoclose = TRUE,
            # datesdisabled = NULL,
            # daysofweekdisabled = NULL
          ),
          actionButton("conf1", "plot"),
          fluidRow(
            column(8,
                 plotlyOutput("density_time"),
                 br(),
                 plotlyOutput("heat_1")
                 ),
            column(4,
                 h5("2D migration pattern around radar?"),
                 leafletOutput("radar_sel"))
          )
          )),
    fluidRow(
      box(
        title = "Weekly migration patterns",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12)),
    
    fluidRow(
      box(
        title = "Monthly migration patterns",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12)
    )
  )
)
