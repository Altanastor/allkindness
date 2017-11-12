

organisations <- read_csv("data/organisations.csv")



locationRV <- reactiveValues(
  lat = 58.378296,
  lng = 26.714533
)

focusLocationRV <- reactiveValues(
  lat = 58.378296,
  lng = 26.714533,
  name = ""
)

lat_r <- reactive(
  if(is.null(input$lat)) {
    58.378296
  } else {
    as.numeric(input$lat)
  })

lng_r <- reactive(
  if(is.null(input$lng)) {
    26.714533
  } else {
    as.numeric(input$lng)
  })

rankingRV <- reactiveValues(
  args = NULL,
  data = organisations
)

MAX_ON_PAGE <- 4
NUM_ROWS <- nrow(organisations)
print(NUM_ROWS)

resultsRV <- reactiveValues(position = 1)

slicedData <- reactive({
  rankingRV$data[c(resultsRV$position:(resultsRV$position + MAX_ON_PAGE)), ]
})

titleIcons <- function(categories){
  categories
}

fixLink <- function(link) {
  if (substr(link, 1, 4) != "http") {
    paste0("http://", link)
  } else {
    link
  }
}

getResultBox <- function(data, i) {
  id <- paste0("resultbox", i)
  
  b <- div(
            # Make the whole box clickable
            HTML(sprintf('<div id="%s" class="action-button shiny-bound-input" >', id)),
            
            # Box itself
            shinydashboard::tabBox(
            side = "left",
            width = "100%",
            title = tags$h3(data["name"]),

        
            tabPanel(shiny::icon("home"),
                     fluidPage(
                       fluidRow(
                         column(3, a(href=fixLink(data["website"]), target="_blank", img(src=data["Logo"], width = "100%"))),
                         column(9, span(data["description"], style = "overflow-y:scroll; max-height: 150px; color: black"))
                       )
                     )
                   ),
        
            tabPanel(shiny::icon("info-circle"),
                     fluidPage(
                       span(data["facebook"], style = "color: blue;"),
                       tags$br(),
                       span(data["Inforegister"], style = "color: blue;")
                       )
                    )
        

          ), 
          # Closing div
          HTML("</div>")
  )

  
  # Observe box clicks
  observeEvent(input[[id]], {
    print(id)
    focusLocationRV$lat <- data$coordinates_lat
    focusLocationRV$lng <- data$coordinates_lng
    focusLocationRV$name <- data$name
  })
  
  b
}


output$resultUI <- renderUI({
  fullResult <- tagList()
  
  # TODO rewrite as apply()
  # children <- apply(slicedData(), 1, function(row) {
  #   getResultBox(row)
  # })
  
  # print("***")
  # print(typeof(children))
  # 
  # tagAppendChildren(fullResult, list = children)
  # 
  nms <- unique(slicedData()$name)
  # counter <- 0
  # while(length(nms) != MAX_ON_PAGE - counter) {
  #   MAX_ON_PAGE <<- MAX_ON_PAGE + 1
  #   counter <<- counter + 1
  #   nms <<- unique(slicedData()$name)
  # }
  # counter <- 0
  # MAX_ON_PAGE <- 4
  
  for (i in seq(length(nms))) {
    coord <- which(slicedData()$name == nms[i])
    b <- getResultBox(slicedData()[coord, ], i)
    fullResult <- tagAppendChild(fullResult, b)
    fullResult <- tagAppendChild(fullResult, tags$br())
  }
  
  fluidPage(
    fluidRow(tags$br()),
    fluidRow(
      style = "overflow-y:scroll; max-height: 87vh",
      column(width = 12,
             fullResult
      )
    ),
    fluidRow(tags$br()),
    fluidRow(
      column(width = 6,
             actionButton("prevResults_btn", " < Previous", width = "80%")),
      column(width = 6,
             actionButton("nextResults_btn", "Next > ", width = "80%"))
    )
  )
  
})


output$map <- renderLeaflet({
  leaflet(data = slicedData()) %>%
    addTiles() %>%  # Add default OpenStreetMap map tiles
    addAwesomeMarkers(lat = ~coordinates_lat, 
                      lng = ~coordinates_lng, 
                      popup = ~name, 
                      icon = awesomeIcons("ios-close", markerColor = "blue")) %>% 
    setView(lng = focusLocationRV$lng, lat = focusLocationRV$lat, zoom = 15) %>% 
    addAwesomeMarkers(lat = focusLocationRV$lat, 
                      lng = focusLocationRV$lng, 
                      popup = focusLocationRV$name,
                      icon = awesomeIcons("ios-close", markerColor = "green")) %>% 
    addAwesomeMarkers(lat = lat_r(), 
                      lng = lng_r(), 
                      popup = "You are here",
                      icon = awesomeIcons(markerColor = "red")) 
  
})

observe({
  toggleState(id = "prevResults_btn", condition = resultsRV$position > 1)
  toggleState(id = "nextResults_btn", condition = resultsRV$position + MAX_ON_PAGE < NUM_ROWS)
})

observeEvent(input$prevResults_btn, {
  print(paste("prev", resultsRV$position))
  if (resultsRV$position > MAX_ON_PAGE) {
    resultsRV$position <- resultsRV$position - MAX_ON_PAGE
  }
})


observeEvent(input$nextResults_btn, {
  print(paste("next", resultsRV$position))
  if (resultsRV$position < NUM_ROWS) {
    resultsRV$position <- resultsRV$position + MAX_ON_PAGE
  }
})

