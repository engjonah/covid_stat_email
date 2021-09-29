import urllib.request
import csv
from datetime import datetime, timedelta
from pytz import timezone
import yagmail
import subprocess

def email(date,msg):
  address = 'username@email.com'
  password = 'password'
  yag = yagmail.SMTP(address, password)
  yag.send(
    to=['subscriber_email@email.com'],
    bcc=[],
    subject = "Covid Stats for Albany County for " + date,
    contents=[msg,yagmail.inline("/home/pi/Documents/covid_email/plot.png")]
  )

def check_data(date): 
  url = 'https://health.data.ny.gov/resource/xdss-u53e.csv?test_date=' + date + 'T00:00:00.000'
  response = urllib.request.urlopen(url)
  lines = [l.decode('utf-8') for l in response.readlines()]
  cr = csv.reader(lines)
  albany = ""
  for row in cr:
      if row[1] == 'Albany':
        albany = row
        with open('data.csv', 'w') as data:
          writer = csv.writer(data, delimiter=',')
          writer.writerow(row)
  if not albany:
    return False
  else:
    return True 

def main():
  with open('sent', 'r') as send:
    if(send.readline()=='True'):
      sent = True
    else:
      sent = False
  if not sent: 
    now_utc = datetime.now(timezone('UTC'))
    today_est = now_utc.astimezone(timezone('America/New_York'))
    yesterday_est = today_est - timedelta(1)
    yesterday_date = yesterday_est.strftime("%Y-%m-%d")
    if check_data(yesterday_date):
      with open('data.csv', 'r') as data:
        reader = csv.reader(data, delimiter=',')
        for row in reader:
          albany = row
      positivity_rate = int(albany[2])/int(albany[4]) * 100
      positivity_rate = f"{positivity_rate:.2f}%"
      msg = "Covid Stats for Albany County for " + yesterday_date + '\n' + "New Cases Today: " + albany[2]+ '\n' + "Positivity Rate: " + positivity_rate  
      subprocess.call("/home/pi/Documents/covid_email/covid_stat.R")
      email(yesterday_date,msg)
      print ('emailed for ' + yesterday_date)
      with open('sent', 'w') as send_file:
        send_file.write('True')
      with open('publish_log.log', 'a') as log:
        log.write("\n" + yesterday_date + ' ' + str(datetime.now(timezone('America/New_York')).strftime("%Y-%m-%d %H:%M")))
    else:
      print (str(datetime.now(timezone('America/New_York')).strftime("%Y-%m-%d %H:%M")) + ' Data not available for ' + yesterday_date + ' yet.')
  else: 
    #print (str(datetime.now(timezone('America/New_York')).strftime("%Y-%m-%d %H:%M")) + ' already emailed')
    print('already emailed')
if __name__ == "__main__":
  main()
