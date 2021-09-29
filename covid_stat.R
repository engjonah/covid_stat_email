#! /usr/bin/Rscript
setwd("/home/pi/Documents/covid_email")

library(readr)
library(dplyr)
library(ggplot2)
library(zoo)

download.file('https://health.data.ny.gov/resource/xdss-u53e.csv?county=Albany', 'albany.csv', "curl", quiet=FALSE)
albany <- read_csv("albany.csv")
#View(albany)

#Sys.Date() #Today
#Sys.Date()-1 #Yesterday
#Sys.Date()-7 #1 week ago

albany_filtered <- albany %>% 
  select(test_date, county, new_positives, cumulative_number_of_positives, total_number_of_tests, cumulative_number_of_tests) %>% 
  filter(test_date >= as.POSIXct(Sys.Date()-14))

albany_filtered <- subset(albany_filtered, select = -c(county, cumulative_number_of_positives, cumulative_number_of_tests))
albany_filtered$percent <- albany_filtered$new_positives/albany_filtered$total_number_of_tests*100
albany_filtered$testaverage <- rollmean(albany_filtered$new_positives, 7, align='right', fill = NA)
albany_filtered$percentaverage <- rollmean(albany_filtered$percent, 7, align='right', fill = NA)

#View(albany_filtered)

ggplot(albany_filtered, aes(x=test_date, y=new_positives)) + geom_point() + 
  labs(title="COVID-19 Cases", subtitle="Albany County, New York", 
       y="Cases", x="Date", caption="Line Represents 7-Day Rolling Average\nMade by Jonah Eng") + 
  geom_line(aes(y=testaverage)) + 
  xlim(c(as.POSIXct(Sys.Date()-7), as.POSIXct(Sys.Date()-1))) + 
  geom_line(aes(y=percentaverage/.05), color="aquamarine4") +
  scale_y_continuous(sec.axis = sec_axis(~.*.05, name="Percent Positivity")) + 
  theme(axis.title.y.right = element_text(color = "aquamarine4"),
        axis.text.y.right = element_text(color = "aquamarine4"))#+ 
  #scale_x_datetime(breaks = albany_filtered$test_date)

ggsave(
  'plot.png',
  plot = last_plot(),
  device = png(filename = "plot.png",
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
                                                                                 
