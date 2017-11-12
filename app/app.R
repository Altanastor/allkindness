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


# Define UI for application that draws a histogram
ui <- div(
  # Geolocation script
  tags$script('
              $(document).ready(function () {
              navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }
              
              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("lng", coords.longitude);
              }, 1100)
              }
              });'),
  
  dashboardPage(
    skin = "green",
    # theme = "bootstrap.min.css",
    dashboardHeader(
      titleWidth = 550,
      title = "All kindness"
    ),
    dashboardSidebar(
      width = 550,
      uiOutput("resultUI")
    ),
    dashboardBody(
      leafletOutput("map", height = "87vh")
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




server <- function(input, output) {
  
  
  eval(parse("popup.R", encoding="UTF-8"))
  eval(parse("order.R", encoding="UTF-8"))
  eval(parse("table_render.R", encoding="UTF-8"))


  submit_action <- function(ranking_data) {
    print("submit action")
    ranking_data <- data.frame(ranking_data, stringsAsFactors = F)
    ranking_data$lat <- lat_r()
    ranking_data$lng <- lng_r()
    
    print(ranking_data)
    
    rankingRV$args <- ranking_data
    rankingRV$data <- rank(rankingRV$data, ranking_data)
    removeModal()
  }
  
  formServer(formInfo, submit_action)
  
}

# Run the application 
shinyApp(ui = ui, server = server)

