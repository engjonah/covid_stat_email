# covid_stat_email
Sends out an email with the day's covid stats and a plot for ease of viewing trends. Uses data provided by the NYS Department of Health which updates its data set daily for up to date information. Currently Albany County is used, but can be adopted to fit any other county in NY. 

Usage: 
In Main.py, replace placeholders with sender email/password and recipients. Set up crontab script or similar to run main.py every once in a while and reset.py at midnight. 
