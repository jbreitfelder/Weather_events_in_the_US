############################################
## To use this script :
##   1. Save it in your working directory
##   2. Run : source("analysis.R")
## ...The code can take a bit long to run...
############################################

library(R.utils)
library(dplyr)
library(reshape2)
library(ggplot2)

############ DATA PROCESSING ############ 

#------------------------------------------------------
# Downloading, unzipping and reading the data
url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!file.exists("repdata-data-StormData.bz2")) {
        download.file(url, destfile="repdata-data-StormData.bz2", method="curl")
        bunzip2("repdata-data-StormData.bz2", "StormData.csv",  skip=TRUE)}
## Storm data documentation : 
## "https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf"
## Load the data will likely take a few seconds. Be patient!
Storm_data_original <- read.csv("StormData.csv", na.strings=c("", "NA"))

#------------------------------------------------------
## Let's keep only data of interest and rename variables with clearer names
Storm_data <- select(Storm_data_original, BGN_DATE, STATE, EVTYPE, FATALITIES:CROPDMGEXP)
Storm_data <- mutate(Storm_data, all_health=FATALITIES+INJURIES,
                     CROPDMGEXP=as.character(CROPDMGEXP), PROPDMGEXP=as.character(PROPDMGEXP))

## We will change the date format to keep only the year and plot later a time series
time_data <- colsplit(Storm_data$BGN_DATE, " ", c("date", "time"))
time_data <- colsplit(time_data$date, "/", c("month", "day", "year"))
Storm_data <- mutate(Storm_data, BGN_DATE=time_data$year)

## To get tidy data we need to clean the crop/prop damage variables
## We only keep the following conversion symbols :
mult <- c("k", "K", "m", "M", "B", "h", "H", NA)
new_mult = c(1e3, 1e3, 1e6, 1e6, 1e9, 1e2, 1e2, 1)
Storm_data <- filter(Storm_data, CROPDMGEXP %in% mult, PROPDMGEXP %in% mult)
## We have filtered only 0.3% of the data. 

Storm_data$CROPDMGEXP[is.na(Storm_data$CROPDMGEXP)] <- 1
Storm_data$PROPDMGEXP[is.na(Storm_data$PROPDMGEXP)] <- 1
for (i in 1:length(mult)) {
        Storm_data$CROPDMGEXP[Storm_data$CROPDMGEXP==mult[i]] <- new_mult[i]
        Storm_data$PROPDMGEXP[Storm_data$PROPDMGEXP==mult[i]] <- new_mult[i]}

Storm_data <- mutate(Storm_data, CROPDMG=CROPDMG*as.numeric(CROPDMGEXP), 
                     PROPDMG=PROPDMG*as.numeric(PROPDMGEXP), eco=CROPDMG+PROPDMG)
Storm_data <- select(Storm_data, -CROPDMGEXP, -PROPDMGEXP)
names(Storm_data) <- c("year", "state", "event_type", "fatalities", "injuries", 
                       "property_damage", "crop_damage", "all_health", "all_eco")


############ RESULTS ON HEALTH ############ 
#------------------------------------------------------
# Calculating the total cost for each event
new_table <- group_by(Storm_data, event_type)
new_table <- summarize(new_table, fatalities=sum(fatalities), 
                       injuries=sum(injuries), all=sum(all_health))

#------------------------------------------------------
# Finding the 10 worst events : highest number of victims (fatalities + injuries)
all_table <- arrange(select(new_table, event_type, all), desc(all))
worst_events <- head(all_table, n=10)$event_type

#------------------------------------------------------
# Turning the 3 variables related to damages into one single 3-levels factor :
new_table <- melt(new_table, id.vars="event_type")
names(new_table) <- c("event_type", "category", "number")

#------------------------------------------------------
# Grouping all events that are not among the 10 worst ones in a category "OTHER"
cond <- new_table$event_type %in% worst_events
new_table <- mutate(new_table, 
                    event_type=ifelse(cond, as.character(event_type), "OTHER"))

# Summing all victims in each category :
new_table <- group_by(new_table, event_type, category)
new_table <- summarize(new_table, number=sum(number)) 

#------------------------------------------------------
# Plotting the results :) 
plot <- ggplot(new_table, aes(x=reorder(event_type, -number), y=number, fill=category)) + 
        geom_bar(stat="identity", position="dodge") +
        facet_grid(category~.) + theme(axis.text.x=element_text(angle=90)) +
        xlab("Type of weather event") + ylab("Number of victims") +
        ggtitle("Relation between weather events and health damage") +
        scale_y_sqrt()

#------------------------------------------------------
# For the 10 worst catastrophs, which state is the most touched?
new_table <- filter(Storm_data, event_type %in% worst_events)
new_table <- group_by(new_table, state, event_type)
new_table <- summarize(new_table, all_health=sum(all_health))
new_table <- group_by(new_table, event_type)
new_table <- summarize(new_table, state=state[which.max(all_health)])


############ RESULTS ON ECONOMY ############ 
#------------------------------------------------------
# Calculating the total damage for each event
new_table <- group_by(Storm_data, event_type)
new_table <- summarize(new_table, crop=sum(crop_damage), 
                       property=sum(property_damage), all=sum(all_eco))

#------------------------------------------------------
# Finding the 10 worst events : highest number of victims (injuries + fatalities)
all_table <- arrange(select(new_table, event_type, all), desc(all))
worst_events <- head(all_table, n=10)$event_type

#------------------------------------------------------
# Turning the 3 variables related to damages into one single 3-levels factor :
new_table <- melt(new_table, id.vars="event_type")
names(new_table) <- c("event_type", "category", "number")

#------------------------------------------------------
# Grouping all events that are not in the worst ones in a category "OTHER"
cond <- new_table$event_type %in% worst_events
new_table <- mutate(new_table, 
                    event_type=ifelse(cond, as.character(event_type), "OTHER"))

#------------------------------------------------------
# Summing all victims in the category OTHER
new_table <- group_by(new_table, event_type, category)
new_table <- summarize(new_table, number=sum(number)) 
new_table <- arrange(new_table, category, desc(number))

#------------------------------------------------------
# Plotting the results :) 
plot <- ggplot(new_table, aes(x=reorder(event_type, -number), y=number/1e9, fill=category)) + 
        geom_bar(stat="identity", position="dodge") +
        facet_grid(category~.) + theme(axis.text.x=element_text(angle=90)) +
        xlab("Type of weather event") + ylab("Total cost (Billions of Dollars)") +
        ggtitle("Relation between weather events and economic damage") +
        scale_y_sqrt()

#------------------------------------------------------
# For the 10 worst catastrophs, which state is the most touched?
new_table <- filter(Storm_data, event_type %in% worst_events)
new_table <- group_by(new_table, state, event_type)
new_table <- summarize(new_table, all_eco=sum(all_eco))
new_table <- group_by(new_table, event_type)
new_table <- summarize(new_table, state=state[which.max(all_eco)])

#------------------------------------------------------
# Annual evolution of the number of events
new_table <- filter(Storm_data, event_type %in% worst_events, year %in% 1970:2015)
new_table <- group_by(new_table, year, event_type)
new_table <- summarize(new_table, all=length(event_type))

plot <- ggplot(new_table, aes(x=year, y=all)) + 
        geom_point(aes(color=event_type), alpha=0.3) +
        geom_smooth(aes(color=event_type), se=FALSE, fullrange=FALSE, method="lm") +
        ylab("Annual number of events") + xlab("Year") +
        theme(axis.text.x=element_text(angle=90)) +
        scale_y_sqrt()