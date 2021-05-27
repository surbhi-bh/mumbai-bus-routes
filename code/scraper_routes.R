

library(rvest)
library(stringr)

###########################
## Get bus route numbers ##
###########################
web_address <- 'https://www.mumbai77.com/bus-routes/#Search-Bus-No'
webpage_code <- read_html(web_address)

routeno <- html_nodes(webpage_code,'#myRegular')
routeno <- html_text(routeno)

routeno <- gsub("[\\[\\]]", "", regmatches(routeno,
                                gregexpr("\\[.*?\\]",
                                         routeno))[[1]])
routeno <- gsub(" ", "-", routeno)
routeno <- gsub("[[]", "", routeno)
routeno <- gsub("[]]", "", routeno)
routeno <- tolower(routeno)
routeno <- gsub("^-", "", routeno)
routeno <- gsub("-$", "", routeno)

######################
## Get all the urls ##
######################

routeno <- ifelse(routeno == "348-ltd-bus2", "348-bus2",
           ifelse(routeno == "swr-1", "swr-1-bus-163",
                  routeno))

routeno_bus <- paste0("bus-no-", routeno)
           
route_address <- do.call(rbind, lapply(unique(routeno_bus), function(t){
    each <- paste0('https://www.mumbai77.com/bus-routes/', t)
}))

#############################
## Get all the route names ##
#############################

routename <- do.call(rbind,lapply(unique(route_address), function(g){
    webpg <- read_html(g)
    name <- html_text(html_nodes(webpg,'#Map'))
}))
    
routename <- as.data.frame(routename)

###########################
## Get all route details ##
###########################

deets <- do.call(rbind,lapply(unique(route_address), function(g){
    webpg <- read_html(g)
    basics <- html_text(html_nodes(webpg,'li'))
    basics <- basics[-c(1:4)]
    basics <- basics[1:9]    
    colns <- unlist(str_split(basics, " : "))
    cheads <- colns[seq(1,18, 2)]
    ccols <- colns[seq(2,18, 2)]
}))

deets <- data.frame(deets)

###############
## Clean ups ##
###############
colnames(deets) <- c("Starting",
                     "Destination",
                     "TotalStops",
                     "TravelTime",
                     "Distance",
                     "FirstBusFromStartingPoint",
                     "LastBusFromStartingPoint",
                     "FirstBusFromDestination",
                     "LastBusFromDestination")

deets <- data.frame(lapply(deets, as.character), stringsAsFactors=FALSE)
deets <- data.frame(apply(deets, 2, function(x) str_sub(x, end=-2)))

deets$LastBusFromDestination <- ifelse(deets$Starting == deets$Destination,  NA, deets$LastBusFromDestination)

deets$LastBusFromDestination <- ifelse(nchar(deets$LastBusFromDestination) > 5& nchar(deets$LastBusFromDestination) < 18,  NA, deets$LastBusFromDestination)

deets$LastBusFromDestination <- ifelse(deets$LastBusFromDestination == "Dena Bank Kandival",  NA, deets$LastBusFromDestination)

deets$FirstBusFromDestination <- ifelse(deets$Starting == deets$Destination,  NA, deets$FirstBusFromDestination)

deets$FirstBusFromDestination <- ifelse(nchar(deets$FirstBusFromDestination) > 18,  NA, deets$FirstBusFromDestination)

################################
## Combine into one dataframe ##
################################

allData <- data.frame(routeno, routename, route_address, deets)
colnames(allData)[2] <- "route_name"
write.csv(allData, "../data/allbusroutes.csv", row.names = FALSE)

########################################################################
