#### POPUP MODAL QUESTIONNAIRE
# post_page <- basicPage(
#   fluidRow(
#   column(tags$h4("Thank you"), 
#          tags$br(),
#          actionButton("recommend_btn", "Recommend"),
#          offset = 3, width = 6, align = "center")
#   )
# )

# pre_page <- basicPage(
#   fluidRow(
#     column(tags$h4("We'd like you to answer several questions in order to recommend the best charity program"),
#            offset = 3, width = 6, align = "center")
#   ),
#   tags$br(),
#   tags$br(),
#   tags$br(),
#   tags$br()
#   
# )

# Login UI
modal_questionnaire <- function(failed = FALSE) {
  modalDialog(
    title = titlePanel(column(tags$h1("Whom would you like to help today?"), offset = 1, width = 10, align = "center")),
    fluidPage(
      fluidRow(
        column(width = 12,
               formUI(formInfo))
      )
    ),
    # multiStepPage(
    #   "multistep_questionnaire",
    #   stepPage(NULL, basicPage(formUI(formInfo))),
    #   # stepPage("Step 3 description", "This is the third page "),
    #   prePage = pre_page,
    #   postPage = post_page,
    #   title = NULL, topButtons = F, bottomButtons = T
    # ),

    # footer = modalButton("Skip"),
    footer = NULL,
    size = "s",
    easyClose = T
  )
}

output$questionnaire_ui <- renderUI({
  tags$head(tags$style(HTML('.modal-dialog {width: 80%;}')))
  showModal(modal_questionnaire())
})

observeEvent(input$recommend_btn, {
  removeModal()
})