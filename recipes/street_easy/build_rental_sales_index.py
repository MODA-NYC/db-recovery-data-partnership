import os
import sys
import pandas as pd

url_rent_index='https://streeteasy-market-data-download.s3.amazonaws.com/chart/v2/data/sub/ddp-rentIndex.csv'
url_sales_index='https://streeteasy-market-data-download.s3.amazonaws.com/chart/v2/data/sub/ddp-priceIndex.csv'

rent_index=pd.read_csv(url_rent_index, dtype=str)
sales_index=pd.read_csv(url_sales_index, dtype=str)

df=rent_index.merge(sales_index[['areaName', 'fullDate', 'priceIndex']], on=['areaName', 'fullDate'])
df.to_csv(sys.stdout, index=False)