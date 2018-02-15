### quick script to read a csv from a provided location / subfolder
read_in <- function(filename, infolder=FALSE, subfolder="") {
  
  # Package manager
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
  pacman::p_load(tidyverse)
  
  # Pass in file name, folder (optional), and whether to search for a folder for the file (optional)
  
  if (infolder) {
    # if the file is in a subfolder, create the folder path
    dataPath <- paste(getwd(),subfolder,sep="/") 
    
  } else {
    # othewise file is in the current working directory
    dataPath <- getwd()    
    
  }
  
  df <- read_csv(file.path(dataPath,filename))
  return(df)
}


