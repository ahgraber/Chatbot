dummy <- function() {
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
    
  # import revised stop word list
  #custom_spwords <- read_in(filename="custom_spwords.csv", subfolder="reference/Lists", infolder=T)

#--------------------------------------------------------------------------------------------------
    
  data <- NULL
  query <- readline("::")
  
  while (query != "exit") {
  
    # see fixTypos --> create custom dictionary for synonym mgmt if necessary (SEI's --> SEI is)
    clean <- text_clean(query)
    clean <- as_data_frame(lemmatize_strings(clean, dictionary = lexicon::hash_lemmas)) #\
  
    # tokenize
    tokens <- clean %>%
      unnest_tokens(token, value) %>%
      filter(!is.na(token))
  
    ### Stopword management - see wordListMgmt.R
    ### Synonyms
  

    # remove stop words (edit stop words as necessary)
    # tokens <- tokens %>%
      # filter(!token %in% custom_spwords$word)
    
    ### Recombine
    cleanQuery <- paste(unlist(c(tokens, use.names=F)), collapse=" ")
    
    data <- rbind(data, cleanQuery)
    
    # print fake response
    print("Our response goes here")
    
    # loop
    query <- readline("::")
  }
  
  return(data)

}