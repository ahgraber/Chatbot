### Functions and transformation for initial clean

#--------------------------------------------------------------------------------------------------
text_clean <- function(chr) {

  # Package manager
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
  pacman::p_load(tidyverse, textclean)
  require(textclean)
  
#--------------------------------------------------------------------------------------------------
  ### Aggregate list of cleaning functions 
    # Note: Keeping at a relatively granular level so we can control exactly what we're cleaning
  
  # Function to remove leading and trailing whitespace
  trim <- function(x) gsub("^\\s+|\\s+$", "", x)
  
  # Replace carriage returns with space 
    # use caution, this can break format and collapse all rows into single row
  nonewlines <- function(x) gsub("[\r\n]", " ", x)
  
  # Replaces commas, periods, exclamations with space
  nocommas <- function(x) gsub("[,]", " ", x)
  nopunct <- function(x) gsub("[,.!]", " ", x)
  
  # Replaces dashes with a space
  nodashes <- function(x) gsub("[-]", " ", x)
  
  # Replaces ' and " with a space
  noapostrophe <- function(x) gsub("[']", " ", x)
  noquotes <- function(x) gsub('["]', " ", x)
  
  # Remove []{}()
  nobrackets <- function(x) gsub("\\[|\\]|\\{|\\}|\\(|\\)", "", x)
  
  # Replaces other punctionation @#$%^&* with a space
  nospecialchar <- function(x) gsub("[@#$%^&*]", " ", x)
  
  # Remove unicode other/symbol (i.e., emoji)
  nosymbol <- function(x) gsub('\\p{So}|\\p{Cn}', '', x, perl = TRUE)
  
  # Remove multiple spaces in strings
  nomultispace <- function(x) gsub("\\s+", " ", x)
  
  # Convert all upper case to lower case
  # use 'tolower(x)'
  
  #--------------------------------------------------------------------------------------------------

  
  chr1 <- tolower(chr) %>%
    trim() %>%
    nonewlines() %>%
    nocommas() %>%
    nodashes() %>%
    nomultispace()

  # textclean functions
  chr2 <- chr1 %>%
    replace_contraction() %>%
    replace_non_ascii() %>%
    replace_symbol() %>%
    replace_emoticon() %>%
    replace_ordinal() 
    # replace_number() %>%

    # number, ordinal, (non-ascii?) may cause problems
    
  chr3 <- chr2 %>%
    noquotes() %>%
    nobrackets() %>%
    nospecialchar() %>%
    nomultispace()

    # check text post-clean - NOTE: TIME INTENSIVE, USE WITH SMALL DATA
    # check_text(cleaned3)
    
    return(chr3)
}

