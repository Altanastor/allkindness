rank <- function(df, ranking_data=NULL) {
  if (is.null(ranking_data)) {
    return(df)
  }
  print(nrow(df))
  # save info about user into dataframe
  print("c0")
  # print(strsplit(ranking_data$what, ";"))
  # print(unlist(strsplit(ranking_data$what, ";")))
  # print(as.numeric(unlist(strsplit(ranking_data$what, ";"))))
  what <- as.numeric(unlist(strsplit(unlist(ranking_data$what), ";")))
  # print("c1")
  whom <- as.numeric(unlist(strsplit(ranking_data$whom[1], ";")))
  # print("c1")
  user <-  as.data.frame(matrix(0, nrow = 1, ncol = 8))
  # print("c1")
  names(user)[1:8] <- c('money','volunteer','blood','stuff','children','nature','in_need','animals')
  # print("c1")
  user[1, c(what)] <- TRUE
  # print("c1")
  user[1, c(whom+4)] <- TRUE
  # print("c1")
  
  # make copy of dataframe
  sorted_df <- df
  # print("c1")
  
  # convert to t/f
  start <- which(colnames(sorted_df)=='money')
  end <- which(colnames(sorted_df)=='animals')
  sorted_df[, start:end] = sorted_df[, start:end] > 0
  columns <- sorted_df[, c(start:end)]
  # print("c2")
  
  # product of user and project info
  columns_product <- t(apply(columns, 1, function(x) x[] & user[]))
  sorted_df[, c(start:end)] <- columns_product
  # print("c3")
  
  # sum over vectors to get score
  sorted_df$what_score <- sorted_df$money + sorted_df$volunteer + sorted_df$blood + sorted_df$stuff
  sorted_df$whom_score <- sorted_df$children + sorted_df$nature + sorted_df$in_need + sorted_df$animals
  # print("c4")
  
  sorted_df$what_score <- ifelse(sorted_df$what_score > 0, 1, 0)
  sorted_df$whom_score <- ifelse(sorted_df$whom_score > 0, 0.7, 0)
  
  # print("c5")
  # get final score
  sorted_df$result <- sorted_df$what_score + sorted_df$whom_score
  
  # order df by score
  sorted_df <- sorted_df[order(-sorted_df$result),] 
  
  print("df sorted")
  return(sorted_df)
}