# Getting and Cleaning Data Course Project
# The current script do the following actions:
#       1.- Merges the training and the test sets to create one data set.
#       2.- Extracts only the measurements on the mean and standard deviation for each measurement.
#       3.- Uses descriptive activity names to name the activities in the data set
#       4.- Appropriately labels the data set with descriptive variable names.
#       5.- From the data set in step 4, creates a second, independent tidy data set with the average 
#           of each variable for each activity and each subject.
# OS: Windows 10


# Load  packages
library(dplyr)
library(data.table)
library(tidyr)

#
if(!file.exists("./data")){dir.create("./data")} # Create a folder to save the data.
if(!file.exists("./data/Datafile.zip")){
        Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" # File URL given by Coursera Assignment
        download.file(Url,destfile="./data/Datafile.zip") #download file
        unzip(zipfile = "./data/Datafile.zip",exdir="./data")
}

# Read training files
subjectTrain<-tbl_df(read.table("./data/UCI HAR Dataset/train/subject_train.txt"))
xTrain<-tbl_df(read.table("./data/UCI HAR Dataset/train/X_train.txt")) 
yTrain<-tbl_df(read.table("./data/UCI HAR Dataset/train/Y_train.txt"))

# Read test files
subjectTest<-tbl_df(read.table("./data/UCI HAR Dataset/test/subject_test.txt"))
xTest<-tbl_df(read.table("./data/UCI HAR Dataset/test/X_test.txt"))
yTest<-tbl_df(read.table("./data/UCI HAR Dataset/test/Y_test.txt"))

# Read Data features
features <- tbl_df(read.table("./data/UCI HAR Dataset/features.txt"))  # Names of the inputs

# Read Activity Labels
activity_labels <- tbl_df(read.table("./data/UCI HAR Dataset/activity_labels.txt")) # Name of the activyty

# Merge the training and test Data
subjectData<-rbind(subjectTrain,subjectTest) # Subject frome which Data has been obtained (1:30)
colnames(subjectData)<-"Subject"
xData<-rbind(xTrain,xTest)                   # Input data (accelerations, rotations,...) 
colnames(xData)<-features$V2                 
xData<-xData[,grep("mean\\(\\)|std\\(\\)",features$V2)] # get only the columns with mean & std
yData<-rbind(yTrain,yTest)                   # Activity 1:6 corresponding to Walking, .. laying
colnames(yData)<-"Activity"

# Combine all data in one data.frame
allData<-cbind(subjectData,yData,xData)      # All data (subject, activity and inputs)
# Replace activity numbers by activity labels and factor by Activity and Subject
allData$Activity <- factor(allData$Activity, levels = activity_labels$V1, labels = activity_labels$V2)
allData$Subject<-as.factor(allData$Subject)

# Generate table with mean by Activity and Subject
DataMean<-aggregate(. ~Subject + Activity, allData, mean)
# Create Descriptive names
names(DataMean)<-gsub("^t","time",names(DataMean))
names(DataMean)<-gsub("^f","frequency",names(DataMean))
names(DataMean)<-gsub("Acc","Accelerometer",names(DataMean))
names(DataMean)<-gsub("Gyro","Gyroscope",names(DataMean))
names(DataMean)<-gsub("BodyBody","Body",names(DataMean))
names(DataMean)<-gsub("Mag","Magnitude",names(DataMean))

# Write Data Mean
write.table(DataMean,"tidyData.txt",row.name=FALSE)