### Drexel Datathon - First Clean

#-- Package manager & housekeeper -----------------------------------------------------------------

### Install packages

## Uncomment and run the first time to ensure all packages are installed:
  # install.packages("tidyverse")
  # install.packages("stringr")
  # install.packages("textclean")
  # install.packages("tidytext")
  # install.packages("textstem")
  # install.packages("widyr")
  # install.packages("irlba")
  # install.packages("broom")


#--------------------------------------------------------------------------------------------------

# Goals:
  # Take in training data; pre-classified questions and canned responses
  # Clean (same process as model for || inputs)
  # create appropriate data structure for models


#--------------------------------------------------------------------------------------------------
### Import model data
  
  source("read_in.R")  
  # read_in( "filename", infolder=F, <if T> subfolder= "subfolder" )

  # Import data
  data <- read_in(filename="Datathon.csv", infolder=F)

  # categories should be factors
  data$Intent <- as.factor(data$Intent)
  # should we include numeric values?
  
  # add identifier column
  id <- rownames(data)
  data <- cbind(data,id)
  
  colnames(data) <- c("Text", "Intent", "Response", "ID")
  # or
    # Combine question & response text(?) for better prediction(?)
    # we could also insert the category as every other word to tighten associations between keywords and category
  # data$Text <- paste(data$Question," ",data$Response)

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
  
  # Typos and Synonyms
    # see fixTypos --> create custom dictionary for synonym mgmt if necessary (SEI's --> SEI is)
    
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
### Tidy data
  
  unigrams <- cleanData %>%
    unnest_tokens(token, Text)
  
  bigrams <- cleanData %>%
    unnest_tokens(token, Text, token = "ngrams", n = 2)
  
  tidy <- rbind(unigrams, bigrams) 
  
  matrix <- cast_sparse(tidy, ID, token)

                    
                    
