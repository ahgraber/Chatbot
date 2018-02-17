### Drexel Datathon - Control function
controller <- function() {
  # to run, input into console:
  # source("controller.R")
  # controller()
  
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
    if(!exists("predict_response.R", mode="function")) source("predict_response.R")
    if(!exists("find_response.R", mode="function")) source("find_response.R")
    
    # import revised stop word list
    custom_spwords <- read_in(filename="stopwords.csv", subfolder="", infolder=F)
    
    
#-- Sequence---------------------------------------------------------------------------------------

  # Take in Query / Initiate chatbot loop
  # Ensure models are active in environment
  # Predict & print response
  # (?) Improve models - nice to have
    
  # notice that this is single-query:single-response format! flexibility for multiline entry / 
  # multi-topic response - nice to have

#-- Activate chatbot ----------------------------------------------------------------------------
# while ( TRUE ) {
  query <- readline(":: > ")

  if (query == "exit") {
    break
  } else {
    
    # read data
    data <- read_in(filename="Datathon.csv", infolder=F)    
    
    # save intention/response map
    intention <- data %>%
      select(Intent,Response)

    # add query to raw data
    q <- c(query, "?", "")
    data <- rbind(data, q)
  
    # save location of query
    queryIndex <- length(data$Question)
    
    # clean and restructure data
    cleanData <- first_clean(data)
    # intention is called "IntentCat"
  
    # separate query from new data strucutre
    cleanQuery <- cleanData[cleanData$ID==queryIndex,]
    cleanQuery$ID <- NULL
    cleanData$ID <- NULL
    cleanData <- cleanData[-queryIndex,]
    
    # generate intent prediction
    prediction <- predict_response(cleanData, cleanQuery)
    
    # look up correct response for provided intent
    response <- intention[find_response(prediction, intention$Intent), "Response"]
    
    ### if using SVM
    # prediction <- predict_response(cleanData, cleanQuery)
    # prediction <- cbind(prediction, rownames(prediction))
    # colnames(prediction) <- c("p", "Intent")
    # prediction <- sort(prediction$p)
    # 
    # response <- intention[find_response(prediction, intention$Intent), "Response"]
    # print(response)
    
    ## code to print predicted response or generic reply (if our prediction is poor)
    # if (is.na(response)) {
    #   print("Please visit SEI website for further information")
    # } else {
      print(as.character(response))
    # } # end else

  } # end else

  ## begin looping
  # query <- readline(":: > ")

# } # end while
} # end function

