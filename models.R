### Drexel Datathon - Models
#--------------------------------------------------------------------------------------------------
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

  # install.packages("openNLP")
  # install.packages("SnowballC")
  # install.packages("lsa")
  # devtools::install_github("bmschmidt/wordVectors") # see: https://github.com/bmschmidt/wordVectors

  # install.packages("quanteda")
  # install.packages("ggraph")
  # install.packages("topicmodels")
  # install.packages("zoo")

#--------------------------------------------------------------------------------------------------

# Goals:
  # Take in training data; pre-classified questions and canned responses
  # Clean (same process as model for || inputs)
  # Build classification engines (SVM, logistic regression, clustering)
    # likely need one model per category
  # Save classification models


#--------------------------------------------------------------------------------------------------
### Import model data
  
  source("read_in.R")  
  # readin( "filename", infolder=F, <if T> subfolder= "subfolder" )

  # Import data
  data <- readin(filename="Demo Inputs.csv", infolder=F)

  # categories should be factors
  data$Category <- as.factor(data$Category)

  # Combine question & response text(?) for better prediction(?)
    # we could also insert the category as every other word to tighten associations between keywords and category
  data$Text <- paste(data$Question," ",data$Response)

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
  clean <- as_data_frame(lemmatize_strings(clean, dictionary = lexicon::hash_lemmas)) %>%
    cbind(data$Category) %>%
    magrittr::set_colnames(c("Text","Category"))
  
  # Typos and Synonyms
  # see fixTypos --> create custom dictionary for synonym mgmt if necessary (SEI's --> SEI is)

  # tokenize
  tokens <- clean %>%
    unnest_tokens(token, Text) %>%
    filter(!is.na(token))

  # Stopword management - see wordListMgmt.R
  # import revised stop word list
  custom_spwords <- readin(filename="custom_spwords.csv", subfolder="reference/Lists", infolder=T)
  # remove stop words (edit stop words as necessary)
  tokens <- tokens %>%
    filter(!token %in% custom_spwords$word)
  
  # Recombine
  cleanData <- aggregate(data = tokens, token ~ Category, paste, collapse = " ")

#--------------------------------------------------------------------------------------------------
### Tokens & NGrams
  # ref: https://opendatascience.com/blog/word-vectors-with-tidy-data-principles/?_hsenc=p2ANqtz-9GWzoN-EyEr34OEDwsb4HeMZG67cm7VaatpjlxVAHVHPbgqhXExtNV5Gu6SryM0rNpAfuNH-B1ZCWUmwRjoFdoE5RQHA&_hsmi=60230911

  library(tidytext)

# First, let’s calculate the unigram probabilities, how often we see each word in this corpus
  unigramProbs <- cleanData %>%
      unnest_tokens(word, Text) %>%
      count(word, sort = TRUE) %>%
      mutate(p = n / sum(n))
  
  unigramProbs


# Next, we need to calculate the skipgram probabilities, how often we find each word near each other
# word. We do this by defining a fixed-size moving window that centers around each word. Do we see
# word1 and word2together within this window? I take the approach here of using unnest_tokens() once
# with token = "ngrams" to find all the windows I need, then using unnest_tokens() again to tidy
# these n-grams. After that, I can use pairwise_count() from the widyr package to count up
# cooccuring pairs within each n-gram/sliding window.
#
# I’m not sure what the ideal value for window size is here for the skipgrams. This value determines
# the sliding window that we move through the text, counting up bigrams that we find within the
# window. When this window is bigger, the process of counting skipgrams takes longer, obviously. I
# experimented a bit and windows of 8 words seem to work pretty well. Probably more work needed
# here! I’d be happy to be pointed to more resources on this topic.
  library(widyr)
  
  tidySkipgrams <- cleanData %>%
      unnest_tokens(ngram, Text, token = "ngrams", n = 8) %>%
      mutate(ngramID = row_number()) %>% 
      unite(skipgramID, ngramID) %>%
      unnest_tokens(word, ngram)
  
  tidySkipgrams
  
  skipgramProbs <- tidySkipgrams %>%
      pairwise_count(word, skipgramID, diag = TRUE, sort = TRUE) %>%
      mutate(p = n / sum(n))

# We now know how often words occur on their own, and how often words occur together with other
# words. We can calculate which words occurred together more often than expected based on how often
# they occurred on their own. When this number is high (greater than 1), the two words are
# associated with each other, likely to occur together. When this number is low (less than 1), the
# two words are not associated with each other, unlikely to occur together.
  normalizedProb <- skipgramProbs %>%
      filter(n > 20) %>%
      rename(word1 = item1, word2 = item2) %>%
      left_join(unigramProbs %>%
                    select(word1 = word, p1 = p),
                by = "word1") %>%
      left_join(unigramProbs %>%
                    select(word2 = word, p2 = p),
                by = "word2") %>%
      mutate(pTogether = p / p1 / p2)
  
  # what are words most associated with "facebook"?
  normalizedProb %>% 
      filter(word1 == "intern") %>%
      arrange(desc(-pTogether))
  
  
  # cast to sparse matrix
  pmiMatrix <- normalizedProb %>%
      mutate(pmi = log10(pTogether)) %>%
      cast_sparse(word1, word2, pmi)

# We want to get information out of this giant matrix in a more useful form, so it’s time for
# singular value decomposition. Since we have a sparse matrix, we don’t want to use base R’s svd
# function, which casts the input to a plain old matrix (not sparse) first thing. Instead we will
# use the fast SVD algorithm for sparse matrices in the irlba package.
  library(irlba)
  
  pmiSVD <- irlba(pmiMatrix, 10, maxit = 1e3)
    # The number 256 here means that we are finding 256-dimensional vectors for the words. This is
    # another thing that I am not sure exactly what the best number is, but it will be easy to
    # experiment with. 

# Once we have the singular value decomposition, we can get out the word vectors! Let’s set some row
# names, using our input, so we can find out what is what.
  wordVectors <- pmiSVD$u
  rownames(wordVectors) <- rownames(pmiMatrix)


# Now we can search our matrix of word vectors to find synonyms. I want to get back to a tidy data
# structure at this point, so I’ll write a new little function for tidying.
  library(broom)
  
  search_synonyms <- function(wordVectors, selectedVector) {
      
      similarities <- wordVectors %*% selectedVector %>%
          tidy() %>%
          as_tibble() %>%
          rename(token = .rownames,
                 similarity = unrowname.x.)
      
      similarities %>%
          arrange(-similarity)    
  }
  
  intern <- search_synonyms(wordVectors, wordVectors["interns",])
  intern
  
  
#--------------------------------------------------------------------------------------------------
### Build models
  
  # do we want to:
    # build classification engines? (need 1 per topic)
      # logistic vs. SVM
    # use an unsupervised classifier?
      # kmeans/medians; k-nearest-neighbor?
    # use some sort of NLP topic modeler (LDA, CRA, topicmodels)
    # keyword predictor? (combine keyword with others?)
  

