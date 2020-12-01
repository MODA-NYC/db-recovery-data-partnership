import pandas as pd
from datetime import date, timedelta
import os
import sys

def get_mondays():
    startdate='2019-01-15'
    mondays = pd.date_range(
        start=startdate, 
        end=date.today(), 
        freq='W-MON').strftime('%Y-%m-%d').tolist()
    mondays.append(startdate)
    return mondays

BASE_URL='https://streeteasy-market-data-download.s3.amazonaws.com'
URL_STREET_EASY=os.environ['URL_STREET_EASY']
URL=f'{BASE_URL}/{URL_STREET_EASY}'

mondays = get_mondays()

def get_dataframe(monday):
    url=f'{URL}/nta-metrics-{monday}.csv'
    url_new=f'{URL}/v2/nta-metrics-{monday}.csv'
    try:
        df=pd.read_csv(url_new)
    except: 
        try:
            df=pd.read_csv(url)
        except:
            df=pd.DataFrame()
    return df

dfs=[]
for monday in mondays:
    dfs.append(get_dataframe(monday))

df = pd.concat(dfs)
field_lookup = {
    'NTA Name':'ntaname', 
    'NTA Code':'ntacode', 
    'No. of New Sale Listings':'s_newlist', 
    'Pct Hike (Sales)':'s_pct_inc',
    'Pct Cut (Sales)':'s_pct_dec',
    'No. of Pending Sale Listings':'s_pendlist',
    'No. of Sale Listings': 's_list', 
    'Median Weeks on Market (Sales)':'s_wksonmkt',
    'No. of New Rental Listings':'r_newlist', 
    'Pct Hike (Rentals)':'r_pct_inc', 
    'Pct Cut (Rentals)':'r_pct_dec',
    'No. of Pending Rental Listings':'r_pendlist', 
    'No. of Rental Listings': 'r_list',
    'Pct Furnished (Rentals)': 'r_pct_furn', 
    'Pct Short Term (Rentals)': 'r_pct_shot',
    'Pct with Concessions (Rentals)': 'r_pct_con',
    'Median Weeks on Market (Rentals)':'r_wksonmkt',
    'No. of bedrooms':'numrooms',
    'Week Start Date':'week_start'
}

df.rename(columns=field_lookup).to_csv(
    sys.stdout, index=False, columns=list(field_lookup.values())
)