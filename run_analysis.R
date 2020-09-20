packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(getwd(), "dataFiles.zip"))
unzip("dataFiles.zip")

##labels + features
activity <- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(getwd(), "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresW <- grep("(mean|std)\\(\\)", features[, featureNames])
meas <- features[featuresW, featureNames]
meas <- gsub('[()]', '', meas)

##datasets
train <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, featuresW, with = FALSE]
data.table::setnames(train, colnames(train), meas)
trainActivities <- fread(file.path(getwd(), "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

##test datasets
test <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, featuresW, with = FALSE]
data.table::setnames(test, colnames(test), meas)
testActivities <- fread(file.path(getwd(), "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets
all <- rbind(train, test)

# Convert classLabels to activityName basically. More explicit. 
all[["Activity"]] <- factor(all[, Activity]
                                 , levels = activity[["classLabels"]]
                                 , labels = activity[["activityName"]])

all[["SubjectNum"]] <- as.factor(all[, SubjectNum])
all <- reshape2::melt(data = all, id = c("SubjectNum", "Activity"))
all <- reshape2::dcast(data = all, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = all, file = "tidyData.txt", quote = FALSE)