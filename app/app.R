#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(leaflet)
library(shinydashboard)
library(readr)

# Requirements (uncomment this for the first launch)
# eval(parse("requirements.R", encoding="UTF-8"))

# Shiny forms
eval(parse("shinyform.R", encoding="UTF-8"))

# Popup questionnaire
eval(parse("questions.R", encoding="UTF-8"))



server <- function(input, output) {
  
  
  eval(parse("popup.R", encoding="UTF-8"))
  # eval(parse("mainUI.R", encoding="UTF-8"))
  eval(parse("order.R", encoding="UTF-8"))
  eval(parse("table_render.R", encoding="UTF-8"))
  
  # output$mobileRV <- reactive(
  #   if(is.null(input$mobile)) {
  #     F
  #   } else {
  #     input$mobile
  #   })
  # 
  # output$sidebarWidthRV <- reactive(
  #   if (mobileRV()) {
  #     "100vw"
  #   } else {
  #     "40vw"
  #   }
  # )
  


  submit_action <- function(ranking_data) {
    print("submit action")
    ranking_data <- data.frame(ranking_data, stringsAsFactors = F)
    if (ranking_data$city == "0;0") {
      ranking_data$lat <- lat_r()
      ranking_data$lng <- lng_r()  
    } else {
      coord <- unlist(strsplit(ranking_data$city[1], split = ";"))
      print(coord)
      lat <- as.numeric(coord[1])
      lng <- as.numeric(coord[2])
      
      ranking_data$lat <- lat
      ranking_data$lng <- lng  
    }
    # ranking_data$lat <- lat_r()
    # ranking_data$lng <- lng_r()
    
    print(ranking_data)
    
    rankingRV$args <- ranking_data
    rankingRV$data <- rank(rankingRV$data, ranking_data)
    removeModal()
  }
  
  formServer(formInfo, submit_action)
  
}



# Define UI for application that draws a histogram
ui <- basicPage(
  # Geolocation script
  tags$script('
              $(document).ready(function () {
              navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }
              
              function is_mobile(){
              return typeof window.orientation !== "undefined"
              }
              
              function mobileVar() {
              if is_mobile() {
              console.log("is mobile");
              Shiny.onInputChange("mobile", true);
              } else {
              console.log("is not mobile");
              Shiny.onInputChange("mobile", false);
              }
              }
              
              
              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("lng", coords.longitude);
              }, 
              1100)
              }
              
              mobileVar()
              
              });'
            ),
  
  div(
    dashboardPage(
      skin = "green",
      # theme = "bootstrap.min.css",
      dashboardHeader(
        # titleWidth = input$mobile,
        titleWidth = "40vw",
        title = "All kindness"
      ),
      dashboardSidebar(
        # width = input$mobile,
        width = "40vw",
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
  )
  )





# Run the application 
shinyApp(ui = ui, server = server)

