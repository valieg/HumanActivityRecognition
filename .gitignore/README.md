### Introduction

This is the peer-graded assignment for "Getting and Cleaning Data Course".
the rough data has been taken from:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The full description of the original project idea and how the data has been collected is
available here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

A brief description of the received signals processing is provided too.

### Project script files

There are four R script files:

  1. run_analysis.R

  2. getRoughDataClass.R

  3. helpers.R

  4. getSensorSignals.R

We'll explain each of them in the following paragraphs.

### 1. run_analysis.R

This is the main file for the project. The entire process flow, from downloading the zip
file to saving the tidy data sets to proper files is managed here.

Basically you'll notice the following:

  - load the necessary scripts

  - load the necessary packages

  - download an unpack the rough data

  - load and prepare two "data.frame" sets ("activityLabel" and "featureLabel") for future
    indexing(please read the "4. The Main index" paragraph from the CodeBook.md) and joining purposes.

  - load and index(by column binding) the "test" data set

  - load and index(by column binding) the "train" data set

  - merge(by row binding) the "test" and "train" data sets
    in order to get the "featureAll" data set

  - rename some labels of "featureAll" data set

  - save the "featureAll" data set to "data/projectDataAll.csv" file

  - subset the measurements on the mean and standard deviation, using
    the same data frame("featureAll") in order to keep the memory usage
    as lower as possible

  - save the new "featureAll" data set to "data/projectDataTidy.csv" file

  - for the 5th part of the assignment, make a new data set(from the previous "featureAll"),
    by properly grouping and summarizing

  - save the "grouped" data set to "data/projectDataGroupedTidy.csv" file

  - the sensor signals data sets get the same process(index the "test" and "train" data sets,
    merge them)

  - save the sensor signals data sets to proper files("data/body_acc_x,y,x.csv", data/total_acc_x,y,z.csv
    and "data/body_gyro_x,y,z.csv")

### 2. getRoughDataClass.R

In this file we declare the "GetRoughData" class. The methods(and properties) of are pretty classic and the
source is documented.

  - roughFileName() - get the "zip" file name from the provided URL(using "fileUrl" class property)

  - roughFileDownload(fileUrl) - download the file from the provided URL

  - roughFileDoesExist(fileName) - check if the file("fileName") has been already downloaded(in order to
    avoid the download at each running of the main script)

  - roughFileUnPack(fileName, packType) - unpack the downloaded file; the method is "extensible" for other
    types of compression(tar, gzip,...)

### 3. helpers.R

Here we have a collection of handy functions:

  - loadLibraries(librariesList) - idea - load the necessary libraries in one place, at the beginning of the
                                          main flow("run_analysis.R"). This way we avoid the "spreading" of
                                          library() statements all along the scripts and make sure that the
                                          libraries we need are already installed.

  - getMainIndex(dataRootDirectory, partialDataSet) - for both "test" and "train" data sets load the
    "subject_%s.txt" and "y_%s.txt" files, bind them(column binding) and give the corespondent "main index"
    (more details in CodeBook.md)

  - bindFeature(dataRootDirectory, partialDataSet, indexFrame) - for both "test" and "train" data sets load the
    "X_%s.txt" file and bind the content to the corespondent "main index"

  - getActivityLabel(dataRootDirectory) - load the "activity_labels.txt" file and build the "activityLabel" data.frame

  - getFeatureLabel(dataRootDirectory) - load the "features.txt" file and build the "featureLabel" data.frame

  - setTidyFeatureLabel(featureLabel, newFeatureName) - set "tidy" names for a couple of labels of "featureLabel"
    data.frame. The "featureLabel" data set have 561 labels, but we'll set new, tidy, names for the ones related
    to the mean and standard deviation only.

### 4. getSensorSignals.R

In this file we've a function dedicated to handle the rough files from "/test/Inertial Signals" and
"/train/Inertial Signals" directories.

  - bindSensorSignals(dataRootDirectory, dataSubDirectory, signalType, partialDataSet, indexFrame) - for both "test"
    and "train" data sets load the "body_acc_x,y,z_%s.txt", "total_acc_x,y,z_%s.txt" and "body_gyro_x,y,z_%s.txt" files,
    separately, and bind theirs content to the correspondent "main index"

