import os
import sys
import datetime
import pandas as pd


BASE_URL='https://streeteasy-market-data-download.s3.amazonaws.com'
URL_STREET_EASY=os.environ['URL_STREET_EASY']
URL=f'{BASE_URL}/{URL_STREET_EASY}'

# Calculate last month
this_month = datetime.date.today().replace(day=1)
last_month = this_month - datetime.timedelta(days=1)
VERSION = last_month.strftime("%Y-%m")

try:
    url = f"{URL}/price_indices-{VERSION}.csv"
    all_rows = pd.read_csv(url, dtype=str)
except:
    last_month = last_month.replace(day=1)
    PREV_VERSION = (last_month.replace(month=last_month.month-1)).strftime("%Y-%m")

    # Data for {VERSION} is not available yet, trying {PREV_VERSION}
    url = f"{URL}/price_indices-{PREV_VERSION}.csv"
    all_rows = pd.read_csv(url, dtype=str)

r = all_rows[all_rows['TYPE']=='rentals'].rename(columns={"index": "rental_index"})
s = all_rows[all_rows['TYPE']=='sales'].rename(columns={"index": "sales_index"})

df = r.merge(s, on=['MONTH', 'BOROUGH', 'NAME'], how="outer")
df.to_csv(sys.stdout, index=False, columns=['MONTH','BOROUGH','NAME','rental_index','sales_index'])