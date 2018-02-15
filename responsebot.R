### Function to run the chatbot!
responsebot <- function (cleanQuery, models) {

#-- Package manager & housekeeper -----------------------------------------------------------------

  # load packages used
    if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    pacman::p_load(tidyverse, stringr, tidytext, textclean, textstem)
  
  # load custom functions  
    if(!exists("read_in.R", mode="function")) source("read_in.R")
    if(!exists("predict_response.R", mode="function")) source("predict_response.R")

#-- Goals -----------------------------------------------------------------------------------------

  # Get Classification
  # Respond appropriately
  
#-- Predicting Response ---------------------------------------------------------------------------
  
  # Get prediction for response
  prediction <- predictResponse(cleanQuery, models)
  
  
#-- Response engine -------------------------------------------------------------------------------
  ### all print commands go here
    
  # do we have good prediction to return a canned response or do we need more info?
  if (prediction == 1) {
     print()  # canned response for topic 1
  } else if (prediction == 2) {
    # ...
  } # ...
  else {
    # what do we do if we need more info?
    prediction <- "unknown"
    print("...")
    
  }
  
  response <- list(cleanQuery, prediction)
  names(response) <- c("cleanQuery", "prediction")
  return(response)
  
#--------------------------------------------------------------------------------------------------

} # end function


  