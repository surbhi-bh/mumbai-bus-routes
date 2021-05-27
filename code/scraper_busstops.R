
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
## Get a list of stops ##
#########################

allStops <- list()

for(y in 1:length(urls)){
    addr <- read_html(urls[y])
    elements <- html_text(html_nodes(addr,'li'))
    stops  <- elements[grepl("^Stop", elements)]
    stops <- gsub(".* : ", "", stops)
    stops <- data.frame(stops)
    colnames(stops) <- routedata$routeno[y]
    allStops[[y]] <- stops
}

stoplist <- allStops[[1]]
 
for(i in 2:length(allStops)){
    stoplist <- cbind.fill(stoplist, allStops[[i]],
                       fill = NA)
}

names(stoplist) <- sapply(str_remove_all(names(stoplist),"X"),"[")
colnames(stoplist) <- gsub("\\.", "-", colnames(stoplist))
colnames(stoplist) <- gsub("\\--", "-", colnames(stoplist))

# write.csv(stoplist, "../data/allstops.csv", row.names = FALSE)

########################################################################
