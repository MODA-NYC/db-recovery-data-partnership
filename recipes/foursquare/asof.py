import requests
from bs4 import BeautifulSoup
import pandas as pd
import sys

site_url = 'https://visitdata.org/data-noncommercial'
html_doc = requests.get(site_url).content
soup = BeautifulSoup(html_doc, 'html.parser')
asof = soup.find_all('h2')[0].string[-12:-1]
print(asof, file=sys.stdout)