from datetime import datetime
import time
import os
import csv
import json
from dateutil.parser import parse
import argparse

from selenium import webdriver
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from seleniumrequests import Firefox

parser = argparse.ArgumentParser(description='Type racer hystory fetcher')
parser.add_argument('--USERNAME', help='Username. Mandatory.')
parser.add_argument('--OUTPUT_PATH', help='Location to download results to')
parser.add_argument('--GECKODRIVER_PATH', help='Location of geckodriver.exe; see readme for details')

args = parser.parse_args()

URL = 'https://data.typeracer.com/pit/race_history'
COLUMN_COUNT = 6

def raise_exception(e, message):
  print('*****************')
  print('The script has encountered an error while %s.' % message)
  print('Please try again in a few minutes.')
  print('If the problem persists, please contact support.')
  print('Below you\'ll find debug information.')
  print('*****************')
  raise e


## Setup
if not args.USERNAME or args.USERNAME == '':
  print('username argument mandatory')
  exit()

URL = URL + '?user={}'.format(args.USERNAME)

try:
  if args.OUTPUT_PATH:
    dld_path = args.OUTPUT_PATH
  else:
    dld_path = os.path.join(os.getcwd(), 'downloads')
    # new_dld_dir = str(datetime.now())[:-7].replace(':', '_') # for windows compat
    # dld_path = os.path.join(dld_path, new_dld_dir)

  temp_path = os.path.join(dld_path, 'temp')
  try:
    os.makedirs(temp_path)
  except:
    # if folder exists, no problem
    pass
except Exception as e:
  raise_exception(e, 'setting up the environment')

try:
  geckodriver = 'geckodriver'
  if (args.GECKODRIVER_PATH):
    geckodriver = os.path.join(args.GECKODRIVER_PATH, geckodriver)
  options = Options()
  options.add_argument("--headless")
  options.add_argument("--window-size=1920,1080")
  profile = webdriver.FirefoxProfile()
  profile.set_preference("browser.download.folderList", 2)
  profile.set_preference("browser.download.manager.showWhenStarting", False)
  profile.set_preference("browser.download.dir", temp_path)
  profile.set_preference("browser.helperApps.neverAsk.saveToDisk", \
    "application/vnd.ms-excel,application/pdf,application/x-pdf")
  profile.set_preference("browser.download.forbid_open_with", True)
  profile.set_preference("pdfjs.enabledCache.state", False)
  profile.set_preference("pdfjs.disabled", True)
  profile.set_preference("browser.download.panel.shown", False)
  profile.set_preference("browser.helperApps.alwaysAsk.force", False)
  profile.set_preference("browser.download.manager.showWhenStarting", False)
  driver = Firefox(firefox_profile=profile, options=options, \
      executable_path=geckodriver)
except Exception as e:
  raise_exception(e, 'starting Firefox')


#find user's match history
driver.get(URL)
elem = None

try:
  elem = driver.find_element_by_xpath("//div[@class='themeContent']/p")
except:
  # not found is good
  pass

assert elem == None


# get match history

print('Show 100 races on page')
cnt_on_page = Select(driver.find_element_by_xpath("//select[@name='n']"))
cnt_on_page.select_by_value('100')
search = driver.find_element_by_xpath("//form/input[@value='Search']")
search.click()

history = []
page_cnt = 0
print('Started gathering match history')

while True:
  #get elements on current page
  elements = driver.find_elements_by_xpath("//table[@class='scoresTable']/tbody/tr")

  page_cnt += 1
  for index, row in enumerate(elements[1:]):
    columns = row.find_elements(By.TAG_NAME, 'td')
    row = [column.text for column in columns[:-1]]
    row[-1] = row[-1].replace(',', '')
    history.append(row)
    print("Page {} {}%\r".format(page_cnt, index + 1), end='')

  try:
    next_page = driver.find_element(By.PARTIAL_LINK_TEXT, 'load older results')
    next_page.click()
    print()
  except:
    print()
    print('End of history reached')
    break


# write csv

header_keys = [
  'Race #',
  'Speed',
  'Accuracy',
  'Points',
  'Place',
  'Date',
]

print('Writing data to csv')
try:
  csv_file = open(os.path.join(dld_path, args.USERNAME.lower() + '_history.csv'), 'w')
  writer = csv.writer(csv_file)
  writer.writerow([k for k in header_keys])
  for index, row in enumerate(history[::-1]):
    print('Writing row {} from {}\r'.format(index + 1, len(history)), end='')
    writer.writerow(row)
  csv_file.close()
except Exception as e:
  raise_exception(e, 'writing the CSV file')

print()
print('Done')

driver.close()
