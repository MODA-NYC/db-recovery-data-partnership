import os
import copy
import pandas as pd
from pathlib import Path




def reduce_csv(csv_name):
    df = pd.read_csv(csv_name, delimiter='|')
    zipcodes = pd.read_csv(Path.cwd() / 'zipcode.csv')
    max_date = df['txn_date'].max()
    min_date = df['txn_date'].min()
    print("f{min_date} to {max_date}")
    df = df.rename({'txn_amt':'txn_amt_index', 'txn_cnt':'txn_cnt_index', 'acct_cnt':'acct_cnt_index', 'avg_ticket':'avg_ticket_index', 'avg_freq':'avg_freq_index', 'avg_spend_amt':'avg_spend_amt_index'}, axis='columns')
    df = df.merge(zipcodes[['borough', 'borocode', 'zip']], how='inner', left_on='Zip_code', right_on='zip')
    df = df.drop(columns='zip')
    df.to_csv(f"mastercard_{min_date}_to_{max_date}.csv" )
    return df

