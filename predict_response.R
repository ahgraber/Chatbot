### Drexel Datathon - predictResponse
predict_response <- function(data, query) {

#-- Package manager & housekeeper -----------------------------------------------------------------
  
  if(!"pacman" %in% installed.packages()[,"Package"]) install.packages("pacman")
    pacman::p_load(e1071, naivebayes, class)

#-- Initialize models -----------------------------------------------------------------------------
    
  ### k-nearest neighbors 
  model_knn <- function(data, instance, cl, n_n) {
    res <- NULL
    classes <- unique(cl)
    
    # classifications assigned numbers
    cl_new <- rep(0,length(cl))
    for (j in 1:length(cl)) {
      cl_new[j] <- which(classes==cl[j])
    }
    
    # run 100 random projections
    #for (i in 1:100) {
      #r <- RPGenerate(p = ncol(data),d = 8, method = "Gaussian", B2 = 1)
      #data_proj <- data%*%r
      #instance_proj <- instance%*%r
      #res <- rbind(res,knn(train = data, test = instance, cl = cl_new, k = n_n))
    #}
    # pick the most common class for the new instance and the % of the time it was chosen
    #uniq <- unique(res)
    #mode <- uniq[which.max(tabulate(match(res, uniq)))]
    #ratio <- sum(res==mode)/length(res)  

    #return(cbind(as.character(classes[mode]),as.numeric(ratio)))
    
    # without random projections
    return(as.character(classes[knn(train = data, test = instance, cl = cl_new, k = n_n)]))
  }
    
  ### logistic regression
  model_regression <- function(data, instance, cl) {
    # run logistic regression on each classification
    res <- NULL
    classes <- unique(cl)
    for (k in 1:length(classes)) {
      cl_new <- as.numeric(cl==classes[k])
      #data_new <- as_data_frame(data)
      data$classes <- cl_new
      z <- glm(formula = classes ~ ., family = "binomial", data = data)
      pr <- predict(z, instance, type = "response")
      res <- rbind(res,cbind(as.character(classes[k]),as.numeric(pr)))
    }
    res <- res[order(res[,2], decreasing = TRUE),]
    return(res[1:3,])
  }

  ### support vector machine
  model_svm <- function(data, instance, cl) {
    res <- NULL
    s <- svm(x = data, y = cl, probability = TRUE)
    s2 <- predict(s, instance, probability = TRUE)
    sprob <- t(attr(s2, "probabilities"))
    #res <- sprob[order(sprob[1]), decreasing = TRUE]
    return(sprob)
  }
  
  ### naive bayes
  model_nb <- function(data, instance, cl) {
    res <- NULL
    classes <- unique(cl)
    for (k in 1:length(classes)) {
      cl_new <- as.numeric(cl==classes[k])
      data$classes <- cl_new
      nb <- naive_bayes(x = data, y = cl_new)
      nb2 <- predict(nb, instance, type = "prob")
      res <- rbind(res,nb2)
    }
    res <- res[order(res[,2], decreasing = TRUE),]
    return(res[1:3,])
  }
  
  #reassign variables
  b <- as.factor(data$IntentCat)
  data$IntentCat <- NULL
  query$IntentCat <- NULL
  #data <- as.matrix(data)
  
#-- Call models from above functions --------------------------------------------------------------
  ### uncomment each model to use
  
  ### logistic regression
  # reg <- model_regression(data = data, instance = query, cl = b)
  # return(reg[1,1])
  
  ### K nearest neighbors
  kn <- model_knn(data = data, instance = query, cl = b,  n_n = 5)
  return(kn)
  
  ### SVM
  # sv <- model_svm(data = data, instance = query, cl = b)
  # return(sv)
  
  ### naive bayes (note, currently not returning)
  # nb1 <- model_nb(data = data, instance = query, cl = b)
  # return()
}

