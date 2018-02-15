### Control function

#--------------------------------------------------------------------------------------------------

  # Package manager & housekeeper
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    # load packages used
    pacman::p_load(tidyverse, stringr, tidytext, textclean, textstem)
    require(textclean)
  
  # load custom functions  
    if(!exists("read_in.R", mode="function")) source("read_in.R")
    if(!exists("text_clean.R", mode="function")) source("text_clean.R")
    if(!exists("chatbot.R", mode="function")) source("chatbot.R")

    # import revised stop word list
    custom_spwords <- read_in(filename="custom_spwords.csv", subfolder="reference/Lists", infolder=T)
    
#-- Sequence---------------------------------------------------------------------------------------

  # Take in Query / Initiate chatbot loop
  # Ensure models are active in environment
  # Predict & print response
  # (?) Improve models - nice to have
    
  # notice that this is single-query:single-response format! flexibility for multiline entry / 
  # multi-topic response - nice to have

#-- Take in Query ---------------------------------------------------------------------------------

  query <- readline(":: > ")
  # or
  # query <- scan()
  
  # storage for all queries in conversation
  conversation <- NULL

  #-- Activate chatbot? ---------------------------------------------------------------------------

  while (query != "exit") {
    # save the entirety of the raw conversation
    conversation <- rbind(conversation, query) # do we want query or response["cleanQuery"]?
    
  #---- Cleaning the query ------------------------------------------------------------------------
    ### use parallel methods to how we prepared our model data!
    # Lemmas/Stems
    # Stopwords
    # Typos, Synonyms
  
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
    tokens <- tokens %>%
      filter(!token %in% custom_spwords$word)
    
    ### Recombine
    cleanQuery <- paste(unlist(c(tokens, use.names=F)), collapse=" ")
  
  #-- Activate models -----------------------------------------------------------------------------
    # run models code    
    #...
    #...
    
    models <- list() # aggregate list of models by name

  #-- Figure out a response -----------------------------------------------------------------------
    
    # save predicted response 
    response <- responsebot(cleanQuery, models)


  #-- Add query data to update models -------------------------------------------------------------
    
    # add response["cleanQuery"] to models
    cleanQuery <- response["cleanQuery"]
    prediction <- response["prediction"]
    newRow <- cbind(cleanQuery, prediction)
    cleanData <- rbind(cleanData, newRow)
    

  
  #-- Loop ----------------------------------------------------------------------------------------
  
    if (prediction = "unknown") {
      query <- readline("...> ") 
    } else {
      query <- readline(":: > ")
    }
    
  } # end while