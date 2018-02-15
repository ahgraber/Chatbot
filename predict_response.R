### Function to predict response categories
predict_response <- function (cleanQuery, models) {
  
#--------------------------------------------------------------------------------------------------

  # Package manager & housekeeper
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    # load packages used
    pacman::p_load(tidyverse, stringr, tidytext, textclean, textstem)
  
  # load custom functions  
    if(!exists("read_in.R", mode="function")) source("read_in.R")

#-- Goals -----------------------------------------------------------------------------------------

  # Classify cleanQuery
  # Determine whether we have a canned response or more info
  # Return (correct!) response
    
#-- Classify cleanQuery ---------------------------------------------------------------------------
  
  # unpack individual models from list
    model1 <- models[1]
    model2 <- models[2]
    # ...
    
  # use models to predict category of cleanQuery
    
#-- Thresholds ------------------------------------------------------------------------------------
  
  ### do we have sufficient prediction or do we need more info?
    
#--------------------------------------------------------------------------------------------------
  
  ### return prediction
    # should either be numeric category identifier or one-word category name (either works)
    return(prediction)
    
#--------------------------------------------------------------------------------------------------
    
} # end function