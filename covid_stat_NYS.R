#! /usr/bin/Rscript
setwd("/home/pi/Documents/covid_email")

library(readr)
library(dplyr)
library(ggplot2)
library(zoo)

download.file('https://health.data.ny.gov/resource/xdss-u53e.csv?county=STATEWIDE', 'data.csv', "curl", quiet=FALSE)
state <- read_csv("data.csv")

#Sys.Date() #Today
#Sys.Date()-1 #Yesterday
#Sys.Date()-7 #1 week ago

state_filtered <- state %>% 
  #group_by(test_date) %>%
  filter(test_date >= as.POSIXct(Sys.Date()-14)) %>%
  select(test_date, county, new_positives, total_number_of_tests) #%>% 
  #summarise(
    #new_positives = sum(new_positives), 
   # total_number_of_tests = sum(total_number_of_tests)
  #)

state_filtered$percent <- state_filtered$new_positives/state_filtered$total_number_of_tests*100
state_filtered$testaverage <- rollmean(state_filtered$new_positives, 7, align='left', fill = NA)
state_filtered$percentaverage <- rollmean(state_filtered$percent, 7, align='left', fill = NA)



ggplot(state_filtered, aes(x=test_date, y=new_positives)) + geom_point() +
  labs(title="COVID-19 Cases", subtitle="New York State",
       y="Cases", x="Date", caption="Line Represents 7-Day Rolling Average\nMade by Jonah Eng") +
  geom_line(aes(y=testaverage)) +
  xlim(c(as.POSIXct(Sys.Date()-7), as.POSIXct(Sys.Date()-1))) +
  ylim(c(NA, max(state_filtered$testaverage,state_filtered$new_positives[7:14], na.rm = TRUE))) + 
  geom_line(aes(y=percentaverage/((state_filtered$percentaverage[1]+state_filtered$percentaverage[7])/2/((state_filtered$testaverage[7]+state_filtered$testaverage[1])/2))), color="aquamarine4") +
  scale_y_continuous(sec.axis = sec_axis(~.*((state_filtered$percentaverage[1]+state_filtered$percentaverage[7])/2/((state_filtered$testaverage[7]+state_filtered$testaverage[1])/2)), name="Percent Positivity")) +
  theme(axis.title.y.right = element_text(color = "aquamarine4"),
        axis.text.y.right = element_text(color = "aquamarine4"))

ggsave(
  'NYS_plot.png',
  plot = last_plot(),
  device = png(filename = "NYS_plot.png",
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
                                                                                 
