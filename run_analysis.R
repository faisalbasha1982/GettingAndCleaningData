#############

## Project to do:

## 1. Merge the training and the test sets to create one data set.
## 2. Extract only the measurements on the mean and standard deviation for each measurement. 
## 3. Use descriptive activity names to name the activities in the data set
## 4. Appropriately label the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Getting and Data Cleaning Course Project
## Faisal Bin Basha
## run_analysis.R

#############



if(!file.exists("./data"))(dir.create("./data"))
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")


# Clean up workspace
unzip(zipfile="./data/Dataset.zip",exdir="./data")

pathData <- file.path("./data","UCI HAR Dataset")
files <- list.files(pathData,recursive=TRUE)
files


library(reshape2)

#load activity labels + features
activityLabels <- read.table("data/UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("data/UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Extract only the data on mean and standard deviation
featuresRequired <- grep(".*mean.*|.*std.*",features[,2])
featuresRequired.names <- features[featuresRequired,2]
featuresRequired.names = gsub('-mean','Mean',featuresRequired.names)
featuresRequired.names = gsub('-std','Std',featuresRequired.names)
featuresRequired.names <- gsub('[-()]','',featuresRequired.names)


# Loading the datasets
train <- read.table("data/UCI HAR Dataset/train/X_train.txt")[featuresRequired]
trainActivities <- read.table("data/UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("data/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects,trainActivities,train)

test <- read.table("data/UCI HAR Dataset/test/X_test.txt")[featuresRequired]
testActivities <- read.table("data/UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects,testActivities,test)

#merge datasets and add labels
mergedData <- rbind(train,test)
colnames(mergedData) <- c("subject","activity",featuresRequired.names)

# turn activities and add labels
mergedData$activity <- factor(mergedData$activity,levels = activityLabels[,1],labels = activityLabels[,2])
mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData,id=c("subject","activity"))
mergedData.mean <- dcast(mergedData.melted,subject + activity ~ variable,mean)

write.table(mergedData.mean,"tidy.txt",row.names=FALSE,quote=FALSE)
