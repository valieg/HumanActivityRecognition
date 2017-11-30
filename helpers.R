##
## A bunch of handy functions.
##
#' Load a list of libraries, checking if the attachment to the calling script
#' is successful.
#'
#' @param librariesList
#'
#' @return
#'
loadLibraries <- function(librariesList){
    
    result <- TRUE
    
    for (lib in librariesList) {
        if(FALSE == library(lib, character.only = TRUE, logical.return = TRUE)){
            result <- lib
            break()
        }
    }
    
    return(result)
}

#' Do a column binding of "subject_abc.txt" and "y_abc.txt" files from
#' the "abc" directory.
#' For the current rough data set "abc" is "test" or "train".
#'
#' @param partialDataSet
#' @param dataRootDirectory
#'
#' @return
#'
getMainIndex <- function(dataRootDirectory = "UCI HAR Dataset", partialDataSet = "train") {
    
    result <- FALSE
    
    subjectFilePattern <- "%ssubject_%s.txt"
    activityFilePattern <- "%sy_%s.txt"
    
    # Let's build the files path:
    stuffPath = file.path(dataRootDirectory, partialDataSet, "", fsep = .Platform$file.sep)
    
    subjectFile <- sprintf(subjectFilePattern, stuffPath, partialDataSet)
    activityFile <- sprintf(activityFilePattern, stuffPath, partialDataSet)
    
    if(FALSE == file.exists(subjectFile)){
        # Log the error
        message("The file ", subjectFile, " does NOT exist.")
        return(result)
    }
    
    if(FALSE == file.exists(activityFile)){
        # Log the error
        message("The file ", activityFile, " does NOT exist.")
        return(result)
    }
    ## Load and bind the data.
    
    result <- read.table(file = subjectFile, header = FALSE, sep = "",
                         col.names = "subject_id",
                         colClasses = c("integer"), blank.lines.skip = TRUE)
    
    data <- read.table(file = activityFile, header = FALSE, sep = "",
                       col.names = "activity_id",
                       colClasses = c("integer"), blank.lines.skip = TRUE)
    
    ## Before binding, check if the data are compatible.
    
    if(nrow(result) != nrow(data)){
        # Log the error
        message("The ", subjectFile, " and ", activityFile, " are NOT compatible(different number of rows).")
        return(FALSE)
    }
    
    ## Do the binding.
    
    result <- cbind(result, data)
    
    return(result)
}
#' Do a column binding of "X_abc.txt" from the "abc" directory to the main index.
#' For the current rough data set "abc" is "test" or "train".
#'
#' @param dataRootDirectory 
#' @param partialDataSet 
#' @param indexFrame 
#'
#' @return
#'
bindFeature <- function(dataRootDirectory = "UCI HAR Dataset", partialDataSet = "train",
                        indexFrame = data.frame()) {
    
    result <- FALSE

    featureFilePattern <- "%sX_%s.txt"
    
    # Let's build the files path:
    stuffPath = file.path(dataRootDirectory, partialDataSet, "", fsep = .Platform$file.sep)
    
    featureFile <- sprintf(featureFilePattern, stuffPath, partialDataSet)
    
    if(FALSE == file.exists(featureFile)){
        # Log the error
        message("The file ", featureFile, " does NOT exist.")
        return(result)
    }
    ## Load and bind the data.
    
    result <- read.fwf(file = featureFile, widths = c(-1, rep(c(16), times = 561)),
                       header = FALSE, colClasses = c("numeric"), blank.lines.skip = TRUE,
                       strip.white = TRUE, stringsAsFactors = FALSE)

    ## Before binding, check if the data are compatible.
    
    if(nrow(result) != nrow(indexFrame)){
        # Log the error
        message("The index data.frame and ", featureFile, " are NOT compatible(different number of rows).")
        return(FALSE)
    }
    
    ## Do the binding.
    
    result <- cbind(indexFrame, result)
    
    return(result)
}
#'
#' Load and prepare the "activities labels" data.
#'
#' @param dataRootDirectory 
#'
#' @return
#'
getActivityLabel <- function(dataRootDirectory = "UCI HAR Dataset") {
    
    result <- FALSE
    
    activityFileName <- "activity_labels.txt"
    
    # Let's build the files path:
    stuffPath = file.path(dataRootDirectory, "", fsep = .Platform$file.sep)
    
    activityLabelFile <- paste(stuffPath, activityFileName, sep = "")
    
    if(FALSE == file.exists(activityLabelFile)){
        # Log the error
        message("The file ", activityLabelFile, " does NOT exist.")
        return(result)
    }
    ## Load the data.
    
    result <- read.table(file = activityLabelFile, header = FALSE, sep = " ",
                         col.names = c("activity_id", "activity_label"),
                         colClasses = c("integer", "character"), blank.lines.skip = TRUE)

    return(result)
}
#'
#' Load and prepare the "features labels" data.
#'
#' @param dataRootDirectory 
#'
#' @return
#'
getFeatureLabel <- function(dataRootDirectory = "UCI HAR Dataset") {
    
    result <- FALSE
    
    featureFileName <- "features.txt"
    
    # Let's build the files path:
    stuffPath = file.path(dataRootDirectory, "", fsep = .Platform$file.sep)
    
    featureLabelFile <- paste(stuffPath, featureFileName, sep = "")
    
    if(FALSE == file.exists(featureLabelFile)){
        # Log the error
        message("The file ", featureLabelFile, " does NOT exist.")
        return(result)
    }
    ## Load the data.
    
    result <- read.table(file = featureLabelFile, header = FALSE, sep = " ",
                         col.names = c("feature_id", "feature_label"),
                         colClasses = c("integer", "character"), blank.lines.skip = TRUE)
    
    return(result)
}
#'
#' Rename the labels "of interest"(see the assignment).
#'
#' @param featureLabel 
#' @param newFeatureName 
#'
#' @return
#'
setTidyFeatureLabel <- function(featureLabel = data.frame(), newFeatureName = c()) {
    ##
    ## The following regular expression will do the right filtering:
    ##                                 ^(?!.*(Jerk|Mag)).*(mean()|std()).*$
    ##
    oldFeatureName <- featureLabel$feature_label[which(grepl("^(?!.*(Jerk|Mag)).*(mean\\(\\)|std\\(\\)).*$",
                                                             featureLabel$feature_label, perl = TRUE))]

    newFeatureName <- c("t_body_acc_mean_x", "t_body_acc_mean_y", "t_body_acc_mean_z",
                        "t_body_acc_std_x", "t_body_acc_std_y", "t_body_acc_std_z",
                        "t_gravity_acc_mean_x", "t_gravity_acc_mean_y", "t_gravity_acc_mean_z",
                        "t_gravity_acc_std_x", "t_gravity_acc_std_y", "t_gravity_acc_std_z",
                        "t_body_gyro_mean_x", "t_body_gyro_mean_y", "t_body_gyro_mean_z",
                        "t_body_gyro_std_x", "t_body_gyro_std_y", "t_body_gyro_std_z",
                        "f_body_acc_mean_x", "f_body_acc_mean_y", "f_body_acc_mean_z",
                        "f_body_acc_std_x", "f_body_acc_std_y", "f_body_acc_std_z",
                        "f_body_gyro_mean_x", "f_body_gyro_mean_y", "f_body_gyro_mean_z",
                        "f_body_gyro_std_x", "f_body_gyro_std_y", "f_body_gyro_std_z")
    ##
    ## Set the new, tidy, names for the features.
    ##
    for (idx in oldFeatureName) {

        featureLabel$feature_label[which(featureLabel$feature_label == idx)] <- newFeatureName[which(oldFeatureName == idx)]

    }

    featureLabel$feature_label <<- featureLabel$feature_label
    newFeatureName <<- newFeatureName
}
