#### FUNCTION TO PULL DATA FROM CDEC STATIONS
#### RYAN PEEK, 2013, 
#### CENTER FOR WATERSHED SCIENCES UC DAVIS
#### MODIFIED 2016, VICELAB, UC MERCED

get.CDEC<-function(station,duration,sensor,start,end){
  # Function to pull CDEC data
  ### Station is 3 letter abbreviation
  ### Duration is E=event, D=Daily
  ### sensor is number
  ### format start and end as "YYYY/MM/DD"
  
  # List of Real-Time Stations: http://cdec.water.ca.gov/misc/realStations.html
  # List of Daily Stations: http://cdec.water.ca.gov/misc/dailyStations.html 
  # List of sensors:  http://cdec.water.ca.gov/misc/senslist.html
  
  # SENSORS MOST COMMONLY USED
  ### 1  stage 
  ### 2  rain accum
  ### 3  snow water content
  ### 4  air temp 
  ### 6  reservoir elevation
  ### 16 precip tippingbucket 
  ### 20 flow cfs 
  ### 25 water temp 
  ### 45 ppt incremental
  
  ## EXAMPLE URL:  
  # http://cdec.water.ca.gov/cgi-progs/queryCSV?station_id=OXB&dur_code=E&sensor_num=20&start_date=2011/10/01&end_date=2012/09/30
  
  data <- read.table(paste("http://cdec.water.ca.gov/cgi-progs/queryCSV?station_id=", station,"&dur_code=",duration,"&sensor_num=", sensor,"&start_date=", start, "&end_date=",end, "&data_wish=View+CSV+Data", sep=""),
                     header=T, sep=",",quote="'", skip=1, na.strings="m",colClasses = c("character", "character", "numeric"))
  names(data)[1] <- "date"
  names(data)[3]<- "data"
  data$date<-as.Date(data$date,"%Y%m%d")
  
  ## format date and time
  names(data) <- c("date","time", paste("sensor_",sensor,sep=""))
  data$date<-strptime(data$date,format="%Y-%m-%d") # convert to datetime
  data$time<-as.character(data$time)
  data$datetime<-paste(data$date," ",data$time,sep="") # create a datetime column by pasting them together
  data$datetime<-as.POSIXct(strptime(data$datetime,format="%Y-%m-%d %H%M")) # convert to datetime from whatever format
  
  summary(data)
  str(data)
  
  #   ## ask if user wants to change the directory for save purposes    
  #   cat("\n","Use current directory? Y or N","\n\n") # prompt 
  #   y<-scan(what="character",n=1)
  #   ifelse(y=="N",setwd(choose.dir()),getwd())
  
  ## Change dates to a format that is appropriate for filenames
  start <- as.character(strptime(start,format="%Y/%m/%d"))
  end <- as.character(strptime(end,format="%Y/%m/%d"))
  
  ## ask if user wants to save to csv or use in dataframe
  cat("\n","Write file to csv? Y or N","\n\n") # prompt 
  z<-scan(what="character",n=1)
  if(z=="Y"){write.csv(data, file=paste(station,"_sensor-",sensor,"_",start,"_to_",end,".csv",sep=""),row.names=FALSE)
    print(paste("file downloaded and saved here: ",getwd(),sep="")) # show message
  } else{
    cat("No csv written...output to dataframe only\n")}
  assign("cdec.dat",data,envir = .GlobalEnv) # print to workspace
  cat("All Finished! Available in current dataframe...\n")
}