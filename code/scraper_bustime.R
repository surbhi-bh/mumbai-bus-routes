
library(rvest)
library(stringr)
#devtools::install_github("cvarrichio/rowr")
library(rowr)

# Get routes data
routedata <- read.csv("../data/allbusroutes.csv", header = TRUE,
                      stringsAsFactor = FALSE)

# All urls
urls <- routedata$route_address

#########################
## Get bus timetable   ##
#########################

allTimes <- list()

for(y in 1:length(urls)){
    addr <- read_html(urls[y])
    elements <- html_text(html_nodes(addr,'li'))
    time  <- elements[grepl("^Timings", elements)]
    time <- gsub(".* : ", "", time)

    TimeFromStart <- time[1]
    TimeFromDestination <- time[2]

    TimeFromStart <- unlist(strsplit(TimeFromStart, ","))
    TimeFromStart <- gsub(" ", "", TimeFromStart)

    TimeFromDestination <- unlist(strsplit(TimeFromDestination, ","))
    TimeFromDestination <- gsub(" ", "", TimeFromDestination)

    bustime <- cbind.fill(TimeFromStart, TimeFromDestination, fill = NA)

    colnames(bustime) <- c("TimeFromStart", "TimeFromDestination")
    colnames(bustime) <- paste0(routedata$routeno[y], "_", colnames(bustime))    
    allTimes[[y]] <- bustime
}

timetable <- allTimes[[1]]
 
for(i in 2:length(allTimes)){
    timetable <- cbind.fill(timetable, allTimes[[i]],
                       fill = NA)
}

names(timetable) <- sapply(str_remove_all(names(timetable),"X"),"[")

# write.csv(timetable, "../data/bus_timings.csv", row.names = FALSE)

########################################################################
