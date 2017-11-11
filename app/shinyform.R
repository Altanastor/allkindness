library(shiny)

#' @export
STORAGE_TYPES <- list(
  FLATFILE = "flatfile",
  SQLITE = "sqlite",
  MYSQL = "mysql",
  MONGO = "mongo",
  GOOGLE_SHEETS = "gsheets",
  DROPBOX = "dropbox",
  AMAZON_S3 = "s3"
)

labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

appCSS <- "
.shinyforms-ui .mandatory_star { color: #db4437; font-size: 20px; line-height: 0; }
.shinyforms-ui .sf-questions { margin-bottom: 30px; }
.shinyforms-ui .sf-question { margin-top: 25px; font-size: 16px; }
.shinyforms-ui .question-hint { font-size: 14px; color: #737373; font-weight: normal; }
.shinyforms-ui .action-button.btn { font-size: 16px; margin-right: 10px; }
.shinyforms-ui .thankyou_msg { margin-top: 10px; }
.shinyforms-ui .showhide { margin-top: 10px; display: inline-block; }
.shinyforms-ui .sf_submit_msg { font-weight: bold; }
.shinyforms-ui .sf_error { margin-top: 15px; color: red; }
.shinyforms-ui .answers { margin-top: 25px; }
.shinyforms-ui .pw-box { margin-top: -20px; }
.shinyforms-ui .created-by { font-size: 12px; font-style: italic; color: #777; margin: 25px auto 10px;}
"

saveData <- function(data, storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    saveDataFlatfile(data, storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    saveDataGsheets(data, storage)
  }
}

loadData <- function(storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    loadDataFlatfile(storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    #loadDataGsheets(storage)
  }
}


saveDataFlatfile <- function(data, storage) {
  fileName <- paste0(
    paste(
      format(Sys.time(), "%Y%m%d-%H%M%OS"),
      digest::digest(data, algo = "md5"),
      sep = "_"
    ),
    ".csv"
  )
  
  resultsDir <- storage$path
  
  # write out the results
  write.csv(x = data, file = file.path(resultsDir, fileName),
            row.names = FALSE, quote = TRUE)
}


loadDataFlatfile <- function(storage) {
  resultsDir <- storage$path
  files <- list.files(file.path(resultsDir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- do.call(rbind, data)
  
  data
}

saveDataGsheets <- function(data, storage) {
  gs_add_row(gs_key(storage$key), input = data)
}
loadDataGsheets <- function() {
  gs_read_csv(gs_key(storage$key))
}

questionUI <- function(question, mandatory, ns) {
  label <- question$title
  if (mandatory) {
    label <- labelMandatory(label)
  }
  
  if (question$type == "text") {
    input <- textInput(ns(question$id), NULL, "")
  } else if (question$type == "numeric") {
    input <- numericInput(ns(question$id), NULL, 0)
  } else if (question$type == "checkbox") {
    input <- checkboxInput(ns(question$id), label, FALSE)
  } else if (question$type == "checkboxGroup") {
    input <- checkboxGroupInput(ns(question$id), 
                                label = label,
                                choices = question$choises,
                                selected = question$selected)
  } else if (question$type == "radioButtons") {
    input <- radioButtons(ns(question$id), 
                          label = label,
                          choices = question$choises,
                          selected = question$selected)
  } else if (question$type == "select") {
    input <- selectInput(ns(question$id), 
                         label = label,
                         choices = question$choises,
                         selected = question$selected)
  }
  
  div(
    class = "sf-question",
    if (!question$type %in% c("checkbox", "checkboxGroup", "select")) {
      tags$label(
        `for` = ns(question$id),
        class = "sf-input-label",
        label,
        if (!is.null(question$hint)) {
          div(class = "question-hint", question$hint)
        }
      )
    },
    input
  )
}

navigationUI <- basicPage(
  br(),
  actionButton("prevBtn", "< Previous"),
  actionButton("nextBtn", "Next >")
)

NUM_PAGES <- 0

#' @export
formUI <- function(formInfo) {
  
  ns <- NS(formInfo$id)
  
  questions <- formInfo$questions
  submitText <- formInfo$submitText
  
  fieldsMandatory <- Filter(function(x) { !is.null(x$mandatory) && x$mandatory }, questions)
  fieldsMandatory <- unlist(lapply(fieldsMandatory, function(x) { x$id }))
  
  titleElement <- NULL
  if (!is.null(formInfo$name)) {
    titleElement <- column(tags$h2(formInfo$name), offset = 1, width = 10, align = "center")
    # titleElement <- tags$h2(formInfo$name)
  }
  
  responseText <- "Thank you, your response was submitted successfully."
  if (!is.null(formInfo$responseText)) {
    responseText <- formInfo$responseText
  }
  
  # Multiple pages
  
  if (formInfo$multiplePages) {
    NUM_PAGES <<- length(questions)
  }
  
  
  div(
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    class = "shinyforms-ui",
    align = "center",
    div(
      id = ns("form"),
      titleElement,
    
      div(
        id = ns("form"),
        class = "sf-questions",
        if (formInfo$multiplePages) {
          basicPage(
            shinyjs::hidden(
              lapply(seq(NUM_PAGES), function(i) {
                mandatory <- questions[[i]]$id %in% fieldsMandatory
                print(paste0("create step", i))
                div(
                  class = "page",
                  align = "left",
                  id = ns(paste0("step", i)),
                  # "Question", i,
                  questionUI(questions[[i]], mandatory, ns)
                )
                })
            ),
            div(
              br(),
              actionButton(ns("prevBtn"), "< Previous"),
              actionButton(ns("nextBtn"), "Next >"),
              br()
            )
          )
        } else {
          lapply(questions, function(question) {
            mandatory <- question$id %in% fieldsMandatory
            questionUI(question, mandatory, ns)
            })
        }
      ),

      actionButton(ns("submit"), submitText, class = "btn-primary"),
      if (!is.null(formInfo$reset) && formInfo$reset) {
        actionButton(ns("reset"), "Reset")
      },
      
      shinyjs::hidden(
        span(id = ns("submit_msg"),
             class = "sf_submit_msg",
             "Submitting..."),
        div(class = "sf_error", id = ns("error"),
            div(tags$b(icon("exclamation-circle"), "Error: "),
                span(id = ns("error_msg")))
        )
      )
    ),
    shinyjs::hidden(
      div(
        id = ns("thankyou_msg"),
        class = "thankyou_msg",
        strong(responseText), br(),
        actionLink(ns("submit_another"), "Submit another response")
      )
    ),
    shinyjs::hidden(
      actionLink(ns("showhide"),
                 class = "showhide",
                 "Show responses")
    ),
    
    shinyjs::hidden(div(
      id = ns("answers"),
      class = "answers",
      div(
        class = "pw-box", id = ns("pw-box"),
        inlineInput(
          passwordInput(ns("adminpw"), NULL, placeholder = "Password")
        ),
        actionButton(ns("submitPw"), "Log in")
      ),
      shinyjs::hidden(div(id = ns("showAnswers"),
          downloadButton(ns("downloadBtn"), "Download responses"),
          DT::dataTableOutput(ns("responsesTable"))
      ))
    )),
    
    div(class = "created-by",
        "Created with",
        a(href = "https://github.com/daattali/shinyforms", "shinyforms")
    )
  )
}

#' @export
formServer <- function(formInfo, submitAction = NULL) {
  callModule(formServerHelper, formInfo$id, formInfo, submitAction)
}

formServerHelper <- function(input, output, session, formInfo, submitAction) {
  
  
  if (grepl("\\s", formInfo$id)) {
    stop("Form id cannot have any spaces", call. = FALSE)
  }
  
  if (formInfo$storage$type == STORAGE_TYPES$FLATFILE) {
    if (!dir.exists(formInfo$storage$path)) {
      dir.create(formInfo$storage$path, showWarnings = FALSE)
    }
  }
  
  questions <- formInfo$questions
  
  fieldsMandatory <- Filter(function(x) {!is.null(x$mandatory) && x$mandatory }, questions)
  fieldsMandatory <- unlist(lapply(fieldsMandatory, function(x) { x$id }))
  fieldsAll <- unlist(lapply(questions, function(x) { x$id }))
  
  ## Multiple pages
  if (formInfo$multiplePages) {
    print("multiple pages mode")
  }
  
  rv <- reactiveValues(page = 1)
  
  observe({
    toggleState(id = "prevBtn", condition = rv$page > 1)
    toggleState(id = "nextBtn", condition = rv$page < NUM_PAGES)
    shinyjs::hide(selector = ".page")
    print(sprintf("show step%s", rv$page))
    shinyjs::show(sprintf("step%s", rv$page))
  })
  
  navPage <- function(direction) {
    rv$page <- rv$page + direction
  }
  
  observeEvent(input$prevBtn, {
    print("prev")
    navPage(-1)
  })
  observeEvent(input$nextBtn, {
    print("next")
    navPage(1)
  })
  

  
  observe({
    mandatoryFilled <-
      vapply(fieldsMandatory,
             function(x) {
               !is.null(input[[x]]) && input[[x]] != ""
             },
             logical(1))
    mandatoryFilled <- all(mandatoryFilled)
    
    shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
  })
  
  observeEvent(input$reset, {
    shinyjs::reset("form")
    shinyjs::hide("error")
  })
  
  # When the Submit button is clicked, submit the response
  observeEvent(input$submit, {

    # User-experience stuff
    shinyjs::disable("submit")
    shinyjs::show("submit_msg")
    shinyjs::hide("error")
    on.exit({
      shinyjs::enable("submit")
      shinyjs::hide("submit_msg")
    })

    if (!is.null(formInfo$validations)) {
      errors <- unlist(lapply(
        formInfo$validations, function(validation) {
          if (!eval(parse(text = validation$condition))) {
            return(validation$message)
          } else {
            return()
          }
        }
      ))
      if (length(errors) > 0) {
        shinyjs::show(id = "error", anim = TRUE, animType = "fade")
        if (length(errors) == 1) {
          shinyjs::html("error_msg", errors[1])  
        } else {
          errors <- c("", errors)
          shinyjs::html("error_msg", paste(errors, collapse = "<br>&bull; "))
        }
        return()
      }
    }
    
    # Save the data (show an error message in case of error)
    tryCatch({
      saveData(formData(), formInfo$storage)
      shinyjs::reset("form")
      shinyjs::hide("form")
      shinyjs::show("thankyou_msg")
      if (!is.null(submitAction)) {
        print("Do submitAction")
        submitAction(formData())
      }
    },
    error = function(err) {
      shinyjs::logjs(err)
      shinyjs::html("error_msg", err$message)
      shinyjs::show(id = "error", anim = TRUE, animType = "fade")
    })
  })
  
  if (!is.null(formInfo$multiple) && !formInfo$multiple) {
    submitMultiple <- FALSE
    shinyjs::hide("submit_another")
  } else {
    submitMultiple <- TRUE
  }
  observeEvent(input$submit_another, {
    if (!submitMultiple) {
      return()
    }
    shinyjs::show("form")
    shinyjs::hide("thankyou_msg")
  })
  
  # Gather all the form inputs (and add timestamp)
  formData <- reactive({
    data <- sapply(fieldsAll, function(id) {
      print(paste(id, input[[id]]))
      paste(input[[id]], collapse = ";")
    })
    data <- c(data, timestamp = as.integer(Sys.time()))
    data <- t(data)
    data
  }) 
  
  output$responsesTable <- DT::renderDataTable({
    if (!values$adminVerified) {
      return(matrix(0))
    }
    
    DT::datatable(
      loadData(formInfo$storage),
      rownames = FALSE,
      options = list(searching = FALSE, lengthChange = FALSE, scrollX = TRUE)
    )
  })
  
  values <- reactiveValues(admin = FALSE, adminVerified = FALSE)
  observe({
    search <- parseQueryString(session$clientData$url_search)
    if ("admin" %in% names(search) && !is.null(formInfo$password)) {
      values$admin <- TRUE
      shinyjs::show("showhide")
    }
  })
  
  observeEvent(input$showhide, {
    shinyjs::toggle("answers")
  })

  observeEvent(input$submitPw, {
    if (input$adminpw == formInfo$password) {
      values$adminVerified <- TRUE
      shinyjs::show("showAnswers")
      shinyjs::hide("pw-box")
    }
  })

  # Allow admins to download responses
  output$downloadBtn <- downloadHandler(
    filename = function() {
      sprintf("%s_%s.csv", formInfo$id, format(Sys.time(), "%Y%m%d-%H%M%OS"))
    },
    content = function(file) {
      write.csv(loadData(formInfo$storage), file, row.names = FALSE)
    }
  )
}

createFormInfo <- function(id, questions, storage, name, multiple = TRUE,
                           password) {
  # as.yaml
}

#' @export
createFormApp <- function(formInfo) {
  
}

inlineInput <- function(tag) {
  stopifnot(inherits(tag, "shiny.tag"))
  tagAppendAttributes(tag, style = "display: inline-block;")
}