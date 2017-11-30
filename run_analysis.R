##
## This is the main file of the project. It is intended to manage the following tasks:
##
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with
##    the average of each variable for each activity and each subject.
##
roughDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
newDataSetDirectory <- "data"
newSensorSignalsDirectory <- file.path(newDataSetDirectory, "SensorSignals", "", fsep = .Platform$file.sep)

source(file = "helpers.R")
source(file = "getRoughDataClass.R")
source(file = "getSensorSignals.R")
##
## Load external libraries
##
weNeed <- c("tools", "dplyr", "data.table")

tmpLoadResult <- loadLibraries(weNeed)

if(TRUE == tmpLoadResult){
    # It's okay! Do nothing here!
    rm(tmpLoadResult)
} else {
    # Upps, we've a problem loading the necessary external libraries!
    stop(paste("The ", tmpLoadResult, " library cannot be loaded."))
}

## Create the rough data object
oRoughData <- GetRoughData$new(fileUrl = roughDataUrl)

## Set the rough data file name
oRoughData$roughFileName()

## Check if the file does exist in the working directory.
oRoughData$roughFileDoesExist(oRoughData$fileName)
if(TRUE == oRoughData$fileDoesExist) {
    # The file does exist. Do nothing here!
} else {
    # We have to download the rough data file!
    oRoughData$roughFileDownload(roughDataUrl)
    # Recheck if the file does exist in the working directory.
    oRoughData$roughFileDoesExist(oRoughData$fileName)
    if(FALSE == oRoughData$fileDoesExist) {
        # Something went wrong downloading the rough data file!
        stop("Something went wrong trying to download the rough data from ", roughDataUrl)
    }
}
##
## Check for the rough data directory.
## Observation: This part of code is not "enough generic"; we already know that
##              the data is wrapped by "UCI HAR Dataset" directory.
roughDataDirectory <- file_path_sans_ext(oRoughData$fileName)

if(TRUE == file.exists(roughDataDirectory)){
    # Don't unpack but keep fingers crossed for the rough data files!
} else {
    # We have to unpack the rough data file.
    oRoughData$roughFileUnPack(oRoughData$fileName)
    # Recheck if the unpack was successful.
    if(FALSE == file.exists(roughDataDirectory)) {
        # Something went wrong unpacking the rough data file!
        stop("Something went wrong trying to unpack the rough data file")
    }
}
##
## From here we'll work with the data in a pretty classic way.
##
## Let's take care about some labels!
##
## Activity names! We'll work on the "activity_labels.txt" file

activityLabel <- getActivityLabel("UCI HAR Dataset")
if("logical" == typeof(activityLabel) && FALSE == activityLabel) {
    stop("Something went wrong geting data from ", activityLabel, " file")
}

activityLabel <- mutate(activityLabel, activity_label = tolower(trimws(activity_label)))

## Feature names! We'll work on the "features.txt" file

featureLabel <- getFeatureLabel("UCI HAR Dataset")
if("logical" == typeof(featureLabel) && FALSE == featureLabel) {
    stop("Something went wrong geting data from ", featureLabel, " file")
}

featureLabel <- mutate(featureLabel, feature_id = paste0("V", feature_id),
                       feature_label = trimws(feature_label))
newFeatureName <- c()
setTidyFeatureLabel(featureLabel, newFeatureName)

##
## Make the new data set directory.
if(TRUE == file.exists(newDataSetDirectory)){
    # Do nothing.
} else {
    dir.create(newDataSetDirectory)
}
##
## Here we already checked out the content of "UCI HAR Dataset" directory.
## We understand the content of "README.txt" file and the structure of
## "UCI HAR Dataset/test" and "UCI HAR Dataset/train" directories.
##

## Build the main index for both "test" and "train" datasets.

mainIndexTest <- getMainIndex("UCI HAR Dataset", "test")
## Make it tidy.
mainIndexTest <- mutate(mainIndexTest, activity_id = activityLabel$activity_label[as.integer(activity_id)])

if("logical" == typeof(mainIndexTest) && FALSE == mainIndexTest) {
    stop("Something went wrong binding the main index for the \"test\" data set")
}

mainIndexTrain <- getMainIndex("UCI HAR Dataset", "train")
## Make it tidy too.
mainIndexTrain <- mutate(mainIndexTrain, activity_id = activityLabel$activity_label[as.integer(activity_id)])

if("logical" == typeof(mainIndexTrain) && FALSE == mainIndexTrain) {
    stop("Something went wrong binding the main index for the \"train\" data set")
}

## Bind the features the the main index for both "test" and "train" datasets.

featureTest <- bindFeature("UCI HAR Dataset", "test", mainIndexTest)

if("logical" == typeof(featureTest) && FALSE == featureTest) {
    stop("Something went wrong binding the features to the main index for the \"test\" data set")
}

featureTrain <- bindFeature("UCI HAR Dataset", "train", mainIndexTrain)

if("logical" == typeof(featureTrain) && FALSE == featureTrain) {
    stop("Something went wrong binding the features to the main index for the \"train\" data set")
}
##
## Here we are, basically, ready to merge the "test" and "train" data files.
##
featureAll <- data.frame()
featureAll <- rbind(featureAll, featureTest)
rm(featureTest)
featureAll <- rbind(featureAll, featureTrain)
rm(featureTrain)
##
## Now, having "featureAll", "activityLabel" and "featureLabel" files,
## we'll merge them into a 'final' file.
##

setnames(featureAll, old = featureLabel$feature_id, new = featureLabel$feature_label)
##
## Save the features into: "data/projectDataAll.csv" file.
##
write.table(featureAll, file = file.path(newDataSetDirectory, "projectDataAll.csv",
                                         fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
##
## Select out the necessary columns only.
##
featureAll <- featureAll[ , c("subject_id", "activity_id", newFeatureName)]
##
## Save the "tidy data" into: "data/projectDataTidy.csv" file.
##
write.table(featureAll, file = file.path(newDataSetDirectory, "projectDataTidy.csv",
                                         fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
##
##===============================================================================
## Here is the solution for the 5th part of the assignment.
##
## We'll group the data from "featureAll" by "activity_id" and "subject_id".
##
featureAll <- group_by(featureAll, activity_id, subject_id) %>% summarise_all(funs(mean))
##
## Save the "tidy data" into: "data/projectDataGroupedTidy.csv" file.
##
write.table(featureAll, file = file.path(newDataSetDirectory, "projectDataGroupedTidy.csv",
                                         fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
##
##===============================================================================
## Let's take care about the sensor signals data.
##
## Body motion component of acceleration(from the sensor acceleration signal).
##
bodyMotionComponentAcceleration <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "body_acc", "test", mainIndexTest)
if("logical" == typeof(bodyMotionComponentAcceleration) && FALSE == bodyMotionComponentAcceleration) {
    stop("Something went wrong binding the \"body motion component of acceleration\" to the main index for the \"test\" data set")
}
bodyMotionComponentAccelerationTmp <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "body_acc", "train", mainIndexTrain)
if("logical" == typeof(bodyMotionComponentAccelerationTmp) && FALSE == bodyMotionComponentAccelerationTmp) {
    stop("Something went wrong binding the \"body motion component of acceleration\" to the main index for the \"train\" data set")
}

bodyMotionComponentAcceleration$x = rbind(bodyMotionComponentAcceleration$x,
                                          bodyMotionComponentAccelerationTmp$x)
bodyMotionComponentAcceleration$y = rbind(bodyMotionComponentAcceleration$y,
                                          bodyMotionComponentAccelerationTmp$y)
bodyMotionComponentAcceleration$z = rbind(bodyMotionComponentAcceleration$z,
                                          bodyMotionComponentAccelerationTmp$z)
rm(bodyMotionComponentAccelerationTmp)
## Make the new directory.
if(TRUE == file.exists(newSensorSignalsDirectory)){
    # Do nothing.
} else {
    dir.create(newSensorSignalsDirectory)
}
##
## Save the "tidy data" into: "data/body_acc_xyx.csv" files.
##
write.table(bodyMotionComponentAcceleration$x, file = file.path(newSensorSignalsDirectory, "body_acc_x.csv",
                                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(bodyMotionComponentAcceleration$y, file = file.path(newSensorSignalsDirectory, "body_acc_y.csv",
                                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(bodyMotionComponentAcceleration$z, file = file.path(newSensorSignalsDirectory, "body_acc_z.csv",
                                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)

rm(bodyMotionComponentAcceleration)
##===============================================================================
##
## Total acceleration(from the sensor acceleration signal).
## Total acceleration = gravitation + body motion acceleration(as vectors!).
##
totalAcceleration <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "total_acc", "test", mainIndexTest)
if("logical" == typeof(totalAcceleration) && FALSE == totalAcceleration) {
    stop("Something went wrong binding the \"total acceleration\" to the main index for the \"test\" data set")
}
totalAccelerationTmp <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "total_acc", "train", mainIndexTrain)
if("logical" == typeof(totalAccelerationTmp) && FALSE == totalAccelerationTmp) {
    stop("Something went wrong binding the \"total acceleration\" to the main index for the \"train\" data set")
}

totalAcceleration$x = rbind(totalAcceleration$x,
                            totalAccelerationTmp$x)
totalAcceleration$y = rbind(totalAcceleration$y,
                            totalAccelerationTmp$y)
totalAcceleration$z = rbind(totalAcceleration$z,
                            totalAccelerationTmp$z)
rm(totalAccelerationTmp)
##
## Save the "tidy data" into: "data/total_acc_xyz.csv" files.
##
write.table(totalAcceleration$x, file = file.path(newSensorSignalsDirectory, "total_acc_x.csv",
                                                  fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(totalAcceleration$y, file = file.path(newSensorSignalsDirectory, "total_acc_y.csv",
                                                  fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(totalAcceleration$z, file = file.path(newSensorSignalsDirectory, "total_acc_z.csv",
                                                  fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)

rm(totalAcceleration)
##===============================================================================
##
## The angular velocity(from the sensor gyroscope signal).
##
angularVelocity <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "body_gyro", "test", mainIndexTest)
if("logical" == typeof(angularVelocity) && FALSE == angularVelocity) {
    stop("Something went wrong binding the \"angular velocity\" to the main index for the \"test\" data set")
}
angularVelocityTmp <- bindSensorSignals("UCI HAR Dataset", "Inertial Signals", "body_gyro", "train", mainIndexTrain)
if("logical" == typeof(angularVelocityTmp) && FALSE == angularVelocityTmp) {
    stop("Something went wrong binding the \"angular velocity\" to the main index for the \"train\" data set")
}

angularVelocity$x = rbind(angularVelocity$x,
                          angularVelocityTmp$x)
angularVelocity$y = rbind(angularVelocity$y,
                          angularVelocityTmp$y)
angularVelocity$z = rbind(angularVelocity$z,
                          angularVelocityTmp$z)
rm(angularVelocityTmp)
##
## Save the "tidy data" into: "data/body_gyro_xyz.csv" files.
##
write.table(angularVelocity$x, file = file.path(newSensorSignalsDirectory, "body_gyro_x.csv",
                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(angularVelocity$y, file = file.path(newSensorSignalsDirectory, "body_gyro_y.csv",
                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
write.table(angularVelocity$z, file = file.path(newSensorSignalsDirectory, "body_gyro_z.csv",
                                                fsep = .Platform$file.sep),
            append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)

rm(angularVelocity, mainIndexTest, mainIndexTrain)

stop('okay')
