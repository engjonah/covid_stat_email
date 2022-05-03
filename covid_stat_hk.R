#! /usr/bin/Rscript
setwd("/home/pi/Documents/covid_email")
#setwd("/Volumes/pishare/Documents/covid_email")
library(readr)
library(dplyr)
library(ggplot2)
library(zoo)

download.file('https://www.chp.gov.hk/files/misc/latest_situation_of_reported_cases_covid_19_eng.csv', 'hk_data.csv', "curl", quiet=FALSE)
data <- read_csv("hk_data.csv")

#Sys.Date() #Today
#Sys.Date()-1 #Yesterday
#Sys.Date()-7 #1 week ago

data$date <- strptime(data$`As of date`, format = "%d/%m/%Y")
data$date <- as.POSIXct(data$date)
#data$total <- data$`Number of cases tested positive for SARS-CoV-2 virus by nucleic acid tests` + data$`Number of cases tested positive for SARS-CoV-2 virus by rapid antigen tests`
data$total <- rowSums(data[,c("Number of cases tested positive for SARS-CoV-2 virus by nucleic acid tests", "Number of cases tested positive for SARS-CoV-2 virus by rapid antigen tests")], na.rm=TRUE)
data_filtered <- data%>%
  select(date, `total`) %>%
  filter(date >= as.POSIXct(Sys.Date()-15)) 

data_filtered$new_cases <- data_filtered$`total`-lag(data_filtered$`total`)

#state_filtered$percent <- state_filtered$new_positives/state_filtered$total_number_of_tests*100
data_filtered$testaverage <- rollmean(data_filtered$new_cases, 7, align='right', fill = NA)
#state_filtered$percentaverage <- rollmean(state_filtered$percent, 7, align='right', fill = NA)



ggplot(data_filtered, aes(x=date, y=new_cases)) + geom_point() +
  labs(title="COVID-19 Cases", subtitle="Hong Kong",
       y="Cases", x="Date", caption="Line Represents 7-Day Rolling Average\nMade by Jonah Eng") +
  geom_line(aes(y=testaverage)) +
  xlim(c(as.POSIXct(Sys.Date()-6), as.POSIXct(Sys.Date()+.5)))
  #geom_line(aes(y=percentaverage/.0005), color="aquamarine4") +
  #scale_y_continuous(sec.axis = sec_axis(~.*.0005, name="Percent Positivity")) +
  #theme(axis.title.y.right = element_text(color = "aquamarine4"),
  #      axis.text.y.right = element_text(color = "aquamarine4"))



ggsave(
  'hk_plot.png',
  plot = last_plot(),
  device = png(filename = "hk_plot.png",
               width = 480, height = 240, units = "px", pointsize = 12,
               bg = "white"),
  path = NULL,
  scale = 1,
  width = NA,
  height = NA,
  units = c("in", "cm", "mm", "px"),
  dpi = 300,
  limitsize = TRUE,
  bg = NULL,
)
                                                                                 
