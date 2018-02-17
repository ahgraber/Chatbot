### Drexel Datathon - First Clean
first_clean <- function (data) {
  
#-- Package manager & housekeeper -----------------------------------------------------------------

  # load packages used
    if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    pacman::p_load(tidyverse, stringr, tidytext, textclean, textstem)
  
  # load custom functions  
    if(!exists("read_in.R", mode="function")) source("read_in.R")
    if(!exists("text_clean.R", mode="function")) source("text_clean.R")

#--------------------------------------------------------------------------------------------------

# Goals:
  # Take in training data; pre-classified questions and canned responses
  # Clean (same process as model for || inputs)
  # create appropriate data structure for models


#--------------------------------------------------------------------------------------------------
### Import model data

  # categories should be factors
  data$Intent <- as.factor(data$Intent)
  # should we include numeric values?

  # add identifier column
  id <- rownames(data)
  data <- cbind(data,id)

  # ensure everything has correct column name
  colnames(data) <- c("Text", "Intent", "Response", "ID")
  # save link between intent and ID
  intention <- data %>%
    select(Intent, ID)

#--------------------------------------------------------------------------------------------------
### Cleaning
  # Stopwords
  # Lemmas/Stems
  # Typos, Synonyms
  
  library(tidytext)
  library(textclean)
  library(textstem)

  source("read_in.R") 
  source("text_clean.R")

  # Cleaning
  clean <- text_clean(data$Text)
  
  # Lemmas
  clean <- lemmatize_strings(clean, dictionary = lexicon::hash_lemmas)
  
  # for Synonyms, either force replacement or build dictionary to lookup for unknown values
      # force replacement is probably easier
      # want to replace before tokenizing
    # use to find and replace common typos:
    # "\b" finds boundaries between words
  thesaurus <- read_in(filename="synonyms.csv", subfolder="", infolder=F)
    find <- thesaurus$Find
    replace <- thesaurus$Replace
  # replace synonyms with single term
  temp <- stringi::stri_replace_all_regex(clean, find, replace, 
                                          vectorize_all=F, case_insensitive=T)
  # add row IDs back to cleaned data
  clean <- as_data_frame(text_clean(temp)) %>%
    cbind(data$ID)
  colnames(clean) <- c("Text","ID")
  rm(temp)  

  # tokenize
  tokens <- clean %>%
    unnest_tokens(token, Text) %>%
    filter(!is.na(token))

  # Stopword management - create after looking at theorized queries
  # import revised stop word list
  custom_spwords <- read_in(filename="stopwords.csv", subfolder="", infolder=F)
  # remove stop words (edit stop words as necessary)
  tokens <- tokens %>%
    filter(!token %in% custom_spwords$word)
  
  # Recombine
  cleanData <- aggregate(data = tokens, token ~ ID, paste, collapse = " ")
  cleanData <- cbind(cleanData, data$Intent)
  colnames(cleanData) <- c("ID","Text","Intent")
  
#--------------------------------------------------------------------------------------------------
### Tidy & Widen data
  
  unigrams <- cleanData %>%
    unnest_tokens(token, Text)
  
  bigrams <- cleanData %>%
    unnest_tokens(token, Text, token = "ngrams", n = 2)
  
  # put unigrams and bigrams into single data structure
  tidyData <- rbind(unigrams, bigrams) %>%
    group_by(ID, token) %>%
    summarize(n = n()) %>%
    ungroup()
  
  # transition from tall to wide data
  wideData <- tidyData %>%
    group_by(ID) %>%
    # summarize(Quantity2 = ifelse(sum(Quantity) <= 0, 0, 1)) %>%
    spread(key = token, value = n, fill = 0, drop=F) %>%
    ungroup()              
  
  wideData <- right_join(wideData, intention, by = "ID")
  names(wideData)[names(wideData) == 'Intent'] <- 'IntentCat'

#--------------------------------------------------------------------------------------------------

  return(wideData)

}
