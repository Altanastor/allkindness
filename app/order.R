rank <- function(df, input=NULL) {
  if (is.null(input)) {
    return(df)
  }
  print(nrow(df))
  # save info about user into dataframe
  what <- as.numeric(unlist(strsplit(input$what[1], ";")))
  whom <- as.numeric(unlist(strsplit(input$whom[1], ";")))
  long <- as.numeric(input$lng[1])
  lat <- as.numeric(input$lat[1])
  
  user <-  as.data.frame(matrix(0, nrow = 1, ncol = 8))
  names(user)[1:8] <- c('money','volunteer','blood','stuff','children','nature','in_need','animals')
  user[1, c(what)] <- TRUE
  user[1, c(whom+4)] <- TRUE
  
  # make copy of dataframe
  sorted_df <- df
  
  # convert to t/f
  start <- which(colnames(sorted_df)=='money')
  end <- which(colnames(sorted_df)=='animals')
  sorted_df[, start:end] = sorted_df[, start:end] > 0
  columns <- sorted_df[, c(start:end)]
  
  # product of user and project info
  columns_product <- t(apply(columns, 1, function(x) x[] & user[]))
  sorted_df[, c(start:end)] <- columns_product
  
  # sum over vectors to get score
  sorted_df$what_score <- sorted_df$money + sorted_df$volunteer + sorted_df$blood + sorted_df$stuff
  sorted_df$whom_score <- sorted_df$children + sorted_df$nature + sorted_df$in_need + sorted_df$animals
  
  sorted_df$what_score <- ifelse(sorted_df$what_score > 0, 1, 0)
  sorted_df$whom_score <- ifelse(sorted_df$whom_score > 0, 0.7, 0)
  
  # calculation Euclidean distance
  sorted_df$dist <- sqrt((sorted_df$coordinates_lat-lat)^2+(sorted_df$coordinates_lng-long)^2)
  
  # get final score
  sorted_df$result <- sorted_df$what_score + sorted_df$whom_score
  
  # order df by score
  sorted_df <- sorted_df[order(-sorted_df$result, sorted_df$dist),] 
  
  print("df sorted")
  return(sorted_df)
}