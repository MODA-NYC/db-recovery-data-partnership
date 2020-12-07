
import os
import sys
import pandas as pd
from datetime import datetime, timedelta
import urllib.error

#Get  date.
yesterday = datetime.now() -  timedelta(days=1)
date_string = yesterday.strftime("%Y-%m")
previous_month = datetime.now() - timedelta(days=30)
previous_month_string = previous_month.strftime("%Y-%m")

# Dowload source data from s3
url_sales_index = "https://streeteasy-market-data-download.s3.amazonaws.com/nta/v2/price_indices-{}.csv".format(date_string)
url_sales_index_previous = "https://streeteasy-market-data-download.s3.amazonaws.com/nta/v2/price_indices-{}.csv".format(previous_month_string)
#test_sales_index="http://streeteasy-market-data-download.s3.amazonaws.com/nta/v2/price_indices-2020-09.csv"

try:
    sales_index = pd.read_csv(
        #url_sales_index, dtype=str, index_col="MONTH"
        url_sales_index, dtype=str
    )
except urllib.error.HTTPError as exception:
    sales_index = pd.read_csv(
        #url_sales_index_previous, dtype=str, index_col="MONTH"
        url_sales_index_previous, dtype=str
    )

#process the dataframe

#helper functions
def rename_borough(s):
    if (s == 'Manhattan'):
        return 'MN'
    elif (s == 'Bronx'):
        return 'BX'
    elif (s == 'Brooklyn'):
        return 'BK'
    elif (s == 'Queens'):
        return 'QN'
    elif (s == 'Staten Island'):
        return 'SI'
    elif (s == 'NYC'):
        return 'NYC'
    else:
        raise Exception('{} does not match known boroughs'.format(s))

def number_borough(b):
    if (b == 'MN'):
        return 1
    elif (b == 'BX'):
        return 2
    elif (b == 'BK'):
        return 3
    elif (b == 'QN'):
        return 4
    elif (b == 'SI'):
        return '5'
    elif (b == 'NYC'):
        return 0
    else:
        raise Exception('{} does not match known borrough abbreviations.'.format(b))


df = sales_index

#filter-out borough-wide matches
#comment-out this is done in SQL
#df = df[df['BOROUGH'].ne(df['NAME'])]
#renaming
df['BOROUGH'] = df['BOROUGH'].apply(lambda x : rename_borough(x))
df['borocode'] = df['BOROUGH'].apply(lambda x: number_borough(x))

#Separate out rentals and rename it
df_rental = df.loc[df['TYPE']=='rentals']
df_rental = df_rental[['MONTH', 'BOROUGH', "borocode", "NAME", "index"]]
df_rental = df_rental.rename(columns={'index': 'rental_index', 'BOROUGH':'borough', 'NAME': 'submarket', 'MONTH':'year_month'})
df_rental = df_rental.copy()

#separate out the sales column
df_sales = df.loc[df['TYPE'] == 'sales']
df_sales = df_sales[['MONTH', 'BOROUGH', 'borocode', 'NAME', 'index']]
df_sales = df_sales.rename(columns={'index': 'sales_index', 'BOROUGH':'borough', 'NAME': 'submarket', 'MONTH':'year_month'})
df_sales = df_sales.copy()

#join rentals and sales columns
df = df_rental.merge(df_sales[['year_month', 'borocode', 'sales_index']], how='outer', on=['year_month', 'borocode'])
df = df[['year_month', 'borough', 'borocode', 'submarket', 'sales_index', 'rental_index']]

#pass to Postgresql
df.to_csv(
    sys.stdout, index=False, columns=['year_month', 'borough', 'borocode', 'submarket', 'sales_index', 'rental_index']
)



