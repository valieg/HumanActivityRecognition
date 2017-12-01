### Introduction

This document describes the variables, the data and the works performed to clean up the data for the peer-graded assignment for "Getting and Cleaning Data Course".

### 1. The rough data directory structure

Downloading the data from the given URL([https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)) we'll get the "UCI HAR Dataset.zip" file. Unpacking this file we get the following files(and directories structure):
>
├── UCI HAR Dataset
│   ├── test
│   │   ├── Inertial Signals
│   │   │   ├── body_acc_x_test.txt
│   │   │   ├── body_acc_y_test.txt
│   │   │   ├── body_acc_z_test.txt
│   │   │   ├── body_gyro_x_test.txt
│   │   │   ├── body_gyro_y_test.txt
│   │   │   ├── body_gyro_z_test.txt
│   │   │   ├── total_acc_x_test.txt
│   │   │   ├── total_acc_y_test.txt
│   │   │   └── total_acc_z_test.txt
│   │   ├── subject_test.txt
│   │   ├── X_test.txt
│   │   └── y_test.txt
│   ├── train
│   │   ├── Inertial Signals
│   │   │   ├── body_acc_x_train.txt
│   │   │   ├── body_acc_y_train.txt
│   │   │   ├── body_acc_z_train.txt
│   │   │   ├── body_gyro_x_train.txt
│   │   │   ├── body_gyro_y_train.txt
│   │   │   ├── body_gyro_z_train.txt
│   │   │   ├── total_acc_x_train.txt
│   │   │   ├── total_acc_y_train.txt
│   │   │   └── total_acc_z_train.txt
│   │   ├── subject_train.txt
│   │   ├── X_train.txt
│   │   └── y_train.txt
│   ├── activity_labels.txt
│   ├── features_info.txt
│   ├── features.txt
│   └── README.txt

Notice the similarity between "/test/..." and "/train/..." files and directories structures. This helped us to write a more "compact" code.

### 2. The 'UCI HAR Dataset' directory files

  1. "activity_labels.txt"

  2. "features_info.txt"

  3. "features.txt"

  4. "README.txt"

Let's talk about each one of them.

#### 2.1 The 'activity_labels.txt' file

A simple, six rows file containing the code number and activity name. It's about the recorded activities.
The file content is loaded and the activity names are transformed to lower case(using tolower() function). This way we get the "activityLabel" data.frame. This is used build the right, tidy "main index".

#### 2.2 The 'features_info.txt' file

This is a description file(sort of README) regarding the features. We learn from this file how the features were split (x, y and z axis), how are they are post processed(derived in time, FFT,...) and the meaning of them(mean, standard deviation, median absolute deviation,...).

#### 2.3 The 'features.txt' file

Similar with 'activity_labels.txt' file, having two columns. The first is a numerical index and the the second is the feature name.
The file have 561 rows.
The features names are, a little bit, too fancy.
The file content is loaded and some labels are renamed(getting a more tidy name). Let's be more specific.
Using the **"^(?!.*(Jerk|Mag)).*(mean()|std()).*$"** regular expression we select the variables labels related to the mean and the standard deviation. The "setTidyFeatureLabel()" function, described in the README.md files, takes care of the renaming.
This way we get the "featureLabel" data.frame. This is also used build the right, tidy "main index".

#### 2.4 The 'README.txt' file

This is the ESSENCE of this experiment data. Without reading this file it's very hard to understand the data from the "UCI HAR Dataset.zip".

### 3. The 'UCI HAR Dataset/test' and 'UCI HAR Dataset/train' directories files

  1. "subject_test.txt" and "subject_train.txt"

  2. "X_test.txt" and "X_train.txt"

  3. "y_test.txt" and "y_train.txt"

Let's talk about each one of them.

#### 3.1 The 'subject_test.txt' and "subject_train.txt" files

A simple file with one column representing the subject id for each observation. Used to build the "main index"(see the paragraph 4. The 'Main index').

#### 3.1 The 'X_test.txt' and "X_train.txt" files

This is the "features" file. Basically it's a 'fixed length columns' file. Each value have a 'mantissa and exponent'
representation. Each row correspond to an observation.
The number of rows is identical with the number of rows of "subject_test,train.txt" file!
The values to the finally files ("projectDataAll.csv" and "projectDataTidy.csv") are saved as 'floating point' ones.

#### 3.1 The 'y_test.txt' files

A simple file with one column representing the activity id for each observation. Used to build the "main index"(see the paragraph 4. The 'Main index').
In the main index we convert the numerical values to names, using the values from "activityLabel" data.frame("activity_labels.txt" file).

### 4. The 'Main index'

This is the 'KEY' for every data binding we're doing in this project! The subjects, the activities and the features are linked together consistently(for both 'test' and 'train' data sets).

Let's see how we build it. The process is the same for both 'test' and 'train' data sets. After reading the "subject_test.txt" and "y_test.txt" files we're binding them, obtaining the following data.frame:
>
| subject_id | activity_id |
|:----------:|:-----------:|
|     2      |      5      |
|     2      |      5      |
|    ...     |     ...     |
	
For the subject_id column we cannot do anything. From the README.txt file we know that we have 30 subjects(id from 1 to 30) and that is all. But for the activity_id column we have more work to do. After reading the "activity_labels.txt" and making it "tidy" we'll make our "main index" tidy too. So:
>
| subject_id | activity_id |                 | subject_id | activity_id |
|:----------:|:-----------:|:---------------:|:----------:|:-----------:|
|     2      |      5      |  using mutate() |     2      |  standing   |
|     2      |      5      |---------------->|     2      |  standing   |
|    ...     |     ...     |    function     |    ...     |     ...     |

This is the "main index", used everywhere in this project.

### 5. The 'UCI HAR Dataset/test/Inertial Signals' and 'UCI HAR Dataset/train/Inertial Signals' directories files

  1. "total_acc_x_train.txt", "total_acc_y_train.txt" and "total_acc_z_train.txt"

  2. "body_acc_x_train.txt", "body_acc_y_train.txt" and "body_acc_z_train.txt"

  3. "body_gyro_x_train.txt", "body_gyro_y_train.txt" and "body_gyro_z_train.txt"

#### 5.1 The "total_acc_x_train.txt", "total_acc_y_train.txt" and "total_acc_z_train.txt" files

The files is containing the total body acceleration(from the accelerometer), measured in meter/second^2, splited for x, y, z axis.
There are 128 columns, each of them representing the "value" for a time window(see the original README.txt file). The file have a 'fixed length columns' structure, each value having a 'mantissa and exponent' representation. Each row correspond to an observation.
The values to the finally files ("total_acc_x,y,z.csv") are saved as 'floating point' ones.

#### 5.2 The "body_acc_x_train.txt", "body_acc_y_train.txt" and "body_acc_z_train.txt" files

The files is containing the body acceleration(obtained by subtracting the gravity), measured in meter/second^2, splited for x, y, z axis. There are 128 columns, each of them representing the "value" for a time window(see the original README.txt file). The file have a 'fixed length columns' structure, each value having a 'mantissa and exponent' representation. Each row correspond to an observation.
The values to the finally files ("body_acc_x,y,z.csv") are saved as 'floating point' ones.

#### 5.3 The "body_gyro_x_train.txt", "body_gyro_y_train.txt" and "body_gyro_z_train.txt" files

The files is containing the body angular velocity(from the gyroscope), measured in radian/second, splited for x, y, z axis.
There are 128 columns, each of them representing the "value" for a time window(see the original README.txt file). The file have a 'fixed length columns' structure, each value having a 'mantissa and exponent' representation. Each row correspond to an observation.
The values to the finally files ("body_gyro_x,y,z.csv") are saved as 'floating point' ones.

### 6. The TIDY data directory structure

We merged the "test" and "train" data sets keeping the right links(subjects, activities, observation values).
The new 'root' directory for the data sets is called "data". The sensor signals data are kept into "SensorSignals"
sub-directory.

The data directory is:
>
├── data
│   ├── SensorSignals
│   │   ├── body_acc_x.csv
│   │   ├── body_acc_y.csv
│   │   ├── body_acc_z.csv
│   │   ├── body_gyro_x.csv
│   │   ├── body_gyro_y.csv
│   │   ├── body_gyro_z.csv
│   │   ├── total_acc_x.csv
│   │   ├── total_acc_y.csv
│   │   └── total_acc_z.csv
│   ├── projectDataAll.csv
│   ├── projectDataAll.zip
│   ├── projectDataGroupedTidy.csv
│   └── projectDataTidy.csv
├── CodeBook.md
├── getRoughDataClass.R
├── getSensorSignals.R
├── helpers.R
├── README.md
└── run_analysis.R

#### 6.0 How we get the TIDY data sets?

For all files we used the same process:

  1. Bind the values to the main index, separately for the "test" and "train" data sets.
>
| subject_id | activity_id |           | features, values |
|:----------:|:-----------:|:---------:|:----------------:|
|     2      |  standing   |  column   | 1 3 3 4 5...     |
|     2      |  standing   |---------->| 5 6 4 3 4...     |
|    ...     |     ...     |  binding  |    ...           |

  2. Merge the corresponding data sets(by row binding).

