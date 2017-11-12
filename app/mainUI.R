mobileRV <- reactive(
  if(is.null(input$mobile)) {
    F
  } else {
    input$mobile
  })

sidebarWidthRV <- reactive(
  if (mobileRV()) {
    "100vw"
  } else {
    "40vw"
  }
)

output$mainUI <- renderUI({
    div(
      dashboardPage(
      skin = "green",
      # theme = "bootstrap.min.css",
      dashboardHeader(
        titleWidth = sidebarWidthRV(),
        title = "All kindness"
      ),
      dashboardSidebar(
        width = sidebarWidthRV(),
        uiOutput("resultUI")
      ),
      dashboardBody(
        leafletOutput("map", height = "90vh")
      )
      
      # theme = "bootstrap.min.css",
      # Application title
      # headerPanel("All kindness"),
      # 
      # # Sidebar with a slider input for number of bins 
      # sidebarLayout(
      #    sidebarPanel(
      #      uiOutput("resultUI"),
      #      width = 6
      #    ),
      #    
      #    # Show a plot of the generated distribution
      #    mainPanel(
      #      # tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
      #      leafletOutput("map", height = "800px"),
      #      width = 6
      #    )
      #  )
    ),
    uiOutput('questionnaire_ui'),
    tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'custom_style.css'))
  )}
)