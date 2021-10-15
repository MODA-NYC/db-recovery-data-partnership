import os
import requests
from bs4 import BeautifulSoup
import sys
from sqlalchemy import create_engine
from sys import argv

def main():
    #supposedly asof is needed for workflow and github actions?
    zipcode_or_county = argv[0]
    RDP_DATA = os.getenv("RDP_DATA", "RDP_DATA environment variable does not exist")
    engine = create_engine(RDP_DATA)
    # To simplify credential management we will identify the latest version 
    # name by heading to the data website: https://visitdata.org/data-noncommercial
    # version info (asof) is listed e.g. "Raw data files for data version 20200726-v0:"
    # version info will be used to pull raw data e.g. 
    # https://data.visitdata.org/processed/vendor/foursquare/asof/20200726-v0/NewYork_StatenIsland.csv

    #visitdata.org is no longer a functional Site!

    loaded=pd.read_sql(sql='''
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'foursquare_{}'
        AND table_name not in ('main', 'latest')
    '''.format(zipcode_or_county), con=engine)
    loaded_dates=loaded.table_name.to_list()
    VERSION = max(loaded_dates)
    '''
    site_url = 'https://visitdata.org/data-noncommercial'
    html_doc = requests.get(site_url).content
    soup = BeautifulSoup(html_doc, 'html.parser')
    asof = soup.find_all('h2')[0].string[-12:-1]
    '''
    asof = VERSION
    print(asof, file=sys.stdout)
    #raise(Exception("stopping here"))

if __name__ == '__main__':
    main()