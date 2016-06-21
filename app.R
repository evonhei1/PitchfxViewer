library(shiny)
library(ggplot2)
options(stringsAsFactors=F)

dataset <- read.csv('./Data/dataset.csv')
pitch_name <- read.csv('./Data/pitch_name.csv')

pitcher_id <- unique(dataset$pitcher_id)
pitcher_name <- sapply(pitcher_id,FUN=function(id) return(unique(dataset[dataset$pitcher_id==id,'pitcher_name'])[1]))

pitcher_choices <- pitcher_id
names(pitcher_choices) <- pitcher_name
pitcher_choices <- pitcher_choices[order(names(pitcher_choices))]

batter_id <- unique(dataset$batter_id)
batter_name <- sapply(batter_id,FUN=function(id) return(unique(dataset[dataset$batter_id==id,'batter_name'])[1]))

batter_choices <- batter_id
names(batter_choices) <- batter_name
batter_choices <- batter_choices[order(names(batter_choices))]

pitch_choices <- as.character(c('All',pitch_name$pitch_type))
names(pitch_choices) <- c('All',pitch_name$pitch_name)

event_types <- unique(dataset$event_type)
names(event_types) <- event_types

runApp('.')