#### QUESTIONS ####

## To be put inside app.R
## eval(parse("questions.R", encoding="UTF-8"))

# TODO export from file
questions <- list(

  list(id = "what",
       type = "checkboxGroup",
       title = "How do you feel what you want and could help?",
       choises = c("give money" = 1, 
                   "volunteer" = 2,
                   "donate blood" = 3,
                   "give away stuff" = 4)),
  
  list(id = "whom",
       type = "checkboxGroup",
       title = "Whom would you like to help today?",
       choises = c("children" = 1,
                   "nature" = 2, 
                   "person in need" = 3,
                   "animals" = 4)),
  
  list(id = "city",
       type = "select",
       title = "What is your city?",
       choises = c("Nearby" = "0;0",
                   "Kohtla-Järve" = "59.397290;27.280175", 
                   "Narva" = "59.379966;28.178786",
                   "Paide" = "58.886617;25.568794", 
                   "Pärnu" = "58.385046;24.497170", 
                   "Tallinn" = "59.427220;24.727166", 
                   "Tartu" = "58.378144;26.726410", 
                   "Valga" = "57.774392;26.030749", 
                   "Vilkla" = "58.889624;23.601369", 
                   "Viljandi" = "58.363667;25.592988",
                   "Rakvere" = "59.346645;26.365357",
                   "Võru" = "57.845929;26.998098",
                   "Harjumaa" = "59.431945;24.929545",
                   "Põltsamaa" = "58.654516;25.976567",
                   "Juuru" = "59.060903;24.950251",
                   "Kuressaare" = "58.254039;22.484677",
                   "Estonia" = "58.699479;25.783734"),
       selected = "Nearby")
  
)

formInfo <- list(
  id = "basicinfo",
  questions = questions,
  storage = list(
    # Right now, only flat file storage is supported
    type = STORAGE_TYPES$FLATFILE,
    # The path where responses are stored
    path = "responses"
  ),
  submitText = "Recommend me",
  multiple = F,
  multiplePages = T
)

