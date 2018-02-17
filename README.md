# Chatbot
Chatbot for Drexel Datathon 2018

# Challenge:
Create a chatbot engine that will correctly respond to user input (greetings, queries, farewells). Some (limited) training data will be provided, as will canned responses for standard FAQs.

# Process:
1. Aggregate training data (see: first_clean.R)
    * Manually expand training set
    * Add greeting/farewell data
    * Classify inputs
2. Process training data (see: predict_response.R)
    * Clean, lemma/stem, tokens;n-grams
    * Compute proximity matrix for all tokens
3. Model (see: predict_response.R)
    * Pick a type of model/classifier to build off proximity matrix
    * Create one model per topic
4. Query (see: controller.R)
5. Predict (see: controller.R, predict_response.R)
    * Using models, classify new inputs
    * Select appropriate category or flag to query user for more information
6. Respond appropriately (see: controller.R)
7. Repeat 4:7 until "exit"
  
  
# To use:
1. Download and unzip the entire folder.
2. Set your working directory to the above folder (hint: setwd(</your/path/here>))
3. Type *source("controller.R")
4. Type controller()
5. Enter your query!
6. Repeat 4 and 5.