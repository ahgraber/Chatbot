chatbot <- function () {
    if(!exists("read_in.R", mode="function")) source("read_in.R")
    if(!exists("text_clean.R", mode="function")) source("text_clean.R")
    if(!exists("first_clean.R", mode="function")) source("first_clean.R")
   # if(!exists("chatbot.R", mode="function")) source("chatbot.R")
    if(!exists("check_cat.R", mode="function")) source("check_cat.R")
    if(!exists("predictResponse.R", mode="function")) source("predictResponse.R")
  
    query <- readline(":: > ")

    q <- c(query, "?", "")
    data <- rbind(data, q)
  
    # save location of query
    l <- length(data$Question)
  
    cleanData <- first_clean(data)
    # intention is called "IntentCat"
  
    return(cleanData)
    
    # cleanQuery <- cleanData[cleanData$ID==l,]
    # cleanQuery$ID <- NULL
    # cleanData$ID <- NULL
    # cleanData <- cleanData[-l,]
  
    
}