# Tornadoes and floods : the most harmful and expensive disasters in the US
# Author : Joanne Breitfelder

## What you can find in this repository 

* analysis.R : The R script used to clean and analyse de weather data
* Readme.md : The present Readme file
* Storm_data_analysis_cache : A folder containing cached objects
* Storm_data_analysis_files : A folder containing all the figures
* Storm_data_analysis.html : the report of the study, as a html file
* Storm_data_analysis.pdf : the report of the study, as a pdf file
* Storm_data_analysis.Rmd : the R markdown report

The data are not stored in the repository but will be automatically loaded if you run the script. Be careful, it is quite a heavy dataset (about 560MB).

## What to do with this repository ?

If you just want to read the report of the study, you can look at "Storm_data_analysis.pdf" or "Storm_data_analysis.html".
If you want to run the whole analysis by yourself, you can either run "analysis.R", which is the main data analysis script, or refer to the "Storm_data_analysis.Rmd" file, which gives the original script as well as some explanations and results.
Don't forget to set "Weather_events_in_the_US as your working directory".

## Introduction

The present project was realised in the framework of the specialisation in Data Science provided by the Johns Hopkins University on Coursera. The whole R Markdown report of the study has been [published on RPubs](https://rpubs.com/Jijou/127572).

This work aims at studiyng the impact of severe weather events on public health and economy in the US. To find what events are the most harmful and have the greatest economic consequences, we will explore the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database ([More information here](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf)). This database tracks characteristics of major storms and weather events in the United States, including when and where they occur, as well as estimates of any fatalities, injuries, and property damage. We will first process the database to make it smaller and clearer (in particular, we will remove non-relevant data, and slightly transform some variables). We will then analyse the data and answer the question, firstly in terms of public health, and secondly in terms of economic consequences. 

## The different steps of the data processing 

* Loading useful R packages 
* Downloading, unzipping and reading the data
* Selecting the relevant variables 
* Cleaning the crop and property damage variables
* Renaming the variables

## Results 

We can see that the most harmful climatic events in the US are **tornadoes** (both in terms of injuries and fatalities), followed by **excessive heat**. **Texas** is particularly affected by weather disasters, as it shows the highest number of victims for **flash and slow floods**, **tornadoes** and **thunderstorm winds** (i.e. 4 of the 10 most harmful disasters experienced by the whole country). The most expensive extreme weather events in the US (integrated over the past ~60 years) are **floods** and **hurricanes** (in terms of property damage). These disasters can damage buildings and bigger structures such as bridges, roadways or electric installations. In terms of crop damage (a very important economic issue in the US), the worst events are **droughts** and **floods** (both regular and river floods). They events can indeed have a devastator impact on the cultures. The data also reveal that almost all the events occur more and more frequently. It is very clear in particular for **hails**, **flash floods**, **floods** and **droughts**. We therefore have to adapt an economic strategy that takes into account this tendency. 
