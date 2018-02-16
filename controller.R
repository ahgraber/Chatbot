### Control function
controller <- function() {
  # to run, input into console:
  # source("dummy.R")
  # data <- dummy()
  
#-- Initialize ------------------------------------------------------------------------------------
  # Package manager & housekeeper
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    # load packages used
    pacman::p_load(tidyverse, stringr, tidytext, textclean, textstem)
    require(textclean)
    require(textstem)
  

  
  # load custom functions  
    if(!exists("read_in.R", mode="function")) source("read_in.R")
    if(!exists("text_clean.R", mode="function")) source("text_clean.R")
    if(!exists("first_clean.R", mode="function")) source("first_clean.R")
   # if(!exists("chatbot.R", mode="function")) source("chatbot.R")
    if(!exists("check_cat.R", mode="function")) source("check_cat.R")
    if(!exists("predictResponse.R", mode="function")) source("predictResponse.R")

    # import revised stop word list
    custom_spwords <- read_in(filename="stopwords.csv", subfolder="", infolder=F)
    
    
#-- Sequence---------------------------------------------------------------------------------------

  # Take in Query / Initiate chatbot loop
  # Ensure models are active in environment
  # Predict & print response
  # (?) Improve models - nice to have
    
  # notice that this is single-query:single-response format! flexibility for multiline entry / 
  # multi-topic response - nice to have

#-- Start up dataset ------------------------------------------------------------------------------

  data <- read_in(filename="Datathon.csv", infolder=F)    
  intention <- data %>%
    select(Intent,Response)

#-- Take in Query ---------------------------------------------------------------------------------

  # query <- "hi"
  # query <- readline(":: > ")
#----
  # q <- c(query, "?", "")
  # data <- rbind(data, q)
  # 
  # # save location of query
  # l <- length(data$Question)
  # 
  # cleanData <- first_clean(data)
  # # intention is called "IntentCat"
  # 
  # 
  # cleanQuery <- cleanData[cleanData$ID==l,]
  # cleanQuery$ID <- NULL
  # cleanData$ID <- NULL
  # cleanData <- cleanData[-l,]
# ---

  # storage for all queries in conversation
  # conversation <- NULL
  # response <- NULL
  #-- Activate chatbot? ---------------------------------------------------------------------------
  # while ( TRUE ) {
    query <- readline(":: > ")

    if (query == "exit") {
      break
    }
    else {
      q <- c(query, "?", "")
      data <- rbind(data, q)
    
      # save location of query
      l <- length(data$Question)
    
      cleanData <- first_clean(data)
      # intention is called "IntentCat"
    
    
      cleanQuery <- cleanData[cleanData$ID==l,]
      cleanQuery$ID <- NULL
      cleanData$ID <- NULL
      cleanData <- cleanData[-l,]
      
      response <- NULL
      prediction <- NULL
      prediction <- predictResponse(cleanData, cleanQuery)
      response <- intention[check_cat(prediction, intention$Intent), "Response"]
      
      ### for SVMS
      # prediction <- predictResponse(cleanData, cleanQuery)
      # prediction <- cbind(prediction, rownames(prediction))
      # colnames(prediction) <- c("p", "Intent")
      # prediction <- sort(prediction$p)
      # 
      # response <- intention[check_cat(prediction, intention$Intent), "Response"]
      # print(response)
      #if (is.na(response)) {
      #  print("Please visit SEI website for further information")
      #} else {
        print(as.character(response))
      #}

    } # end else

    # query <- readline(":: > ")
      
    # if (prediction == "unknown") {
    #   print("Please visit SEI website for further information")
    #   query <- readline("...> ") 
    # } else {
    #   print(as.character(response))
    #   response = NULL
    #   query <- readline(":: > ")
    # }
  
  # } # end while
} # end function

