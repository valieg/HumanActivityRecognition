##
## A group of functions dedicated to handle the rough files from "/test/Inertial Signals"
## and "/train/Inertial Signals" directories.
##
#' Do a column binding of "X_abc.txt" from the "abc" directory to the main index.
#' For the current rough data set "abc" is "test" or "train".
#'
#' @param dataRootDirectory 
#' @param dataSubDirectory 
#' @param signalType 
#' @param partialDataSet 
#' @param indexFrame 
#'
#' @return
#'
bindSensorSignals <- function(dataRootDirectory = "UCI HAR Dataset",
                              dataSubDirectory = "Inertial Signals",
                              signalType = "body_acc",
                              partialDataSet = "train",
                              indexFrame = data.frame()) {
    
    result <- list()
    ##
    ## Set the right file pattern(for each of x, y, z directions)
    ##
    if("body_acc" == signalType) {
        #    body_acc_x_train.txt
        sensorSignalFile_XYZ_Pattern <- "%sbody_acc_%s_%s.txt"
    } else if("body_gyro" == signalType) {
        #    body_gyro_x_train.txt
        sensorSignalFile_XYZ_Pattern <- "%sbody_gyro_%s_%s.txt"
    } else if("total_acc" == signalType) {
        #    total_acc_x_train.txt
        sensorSignalFile_XYZ_Pattern <- "%stotal_acc_%s_%s.txt"
    } else {
        message("Wrong signal type: ", signalType, ".")
        return(FALSE)
    }

    # Let's build the files path:
    stuffPath = file.path(dataRootDirectory, partialDataSet, dataSubDirectory, "", fsep = .Platform$file.sep)
    
    ## Let's get the sutff.
    axis = c("x", "y", "z")
    
    for (axisLetter in axis) {
        
        sensorSignalFile <- sprintf(sensorSignalFile_XYZ_Pattern, stuffPath, axisLetter, partialDataSet)
        
        if(FALSE == file.exists(sensorSignalFile)){
            # Log the error
            message("The sensor signal file ", sensorSignalFile, " does NOT exist.")
            return(FALSE)
        }
        ## Load and bind the data.
        
        data <- read.fwf(file = sensorSignalFile, widths = c(-1, rep(c(16), times = 128)),
                         header = FALSE, colClasses = c("numeric"), blank.lines.skip = TRUE,
                         strip.white = TRUE, stringsAsFactors = FALSE)
        
        ## Before binding, check if the data are compatible.
        
        if(nrow(data) != nrow(indexFrame)){
            # Log the error
            message("The index data.frame and ", sensorSignalFile, " are NOT compatible(different number of rows).")
            return(FALSE)
        }
        
        ## Do the binding.
        
        result[[axisLetter]] = cbind(indexFrame, data)
        
    }

    return(result)
}
