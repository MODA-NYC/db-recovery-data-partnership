import os
import requests
from bs4 import BeautifulSoup
import sys

RDP_DATA = os.getenv("RDP_DATA")
# To simplify credential management we will identify the latest version 
# name by heading to the data website: https://visitdata.org/data-noncommercial
# version info (asof) is listed e.g. "Raw data files for data version 20200726-v0:"
# version info will be used to pull raw data e.g. 
# https://data.visitdata.org/processed/vendor/foursquare/asof/20200726-v0/NewYork_StatenIsland.csv

#visitdata.org is no longer a functional Site!
VERSION=os.system(
    f'''
    psql {RDP_DATA} -At -c "
    SELECT MAX(table_name::date) 
    FROM information_schema.tables 
    where table_schema = 'foursquare_zipcode'
    AND table_name !~* 'latest|main|zipcode';"
    '''         
             )
'''
site_url = 'https://visitdata.org/data-noncommercial'
html_doc = requests.get(site_url).content
soup = BeautifulSoup(html_doc, 'html.parser')
asof = soup.find_all('h2')[0].string[-12:-1]
'''
asof = VERSION
print(asof, file=sys.stdout)