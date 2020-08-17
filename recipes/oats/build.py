import os
import sys
import pandas as pd

# Read input data and lookups, ignoring header information
df = pd.read_excel('input/raw.xlsx', skiprows=[1])
df.to_csv('input/raw.csv')

city_zips = pd.read_csv('../_data/city_zip_boro.csv')
region_zips = pd.read_csv('../_data/region_zips.csv')

# Check columns
cols = {
        "recordeddate":"date",
        "q6":"zip",
        "q7":"found_oats",
        "q13":"tech_goal",
        "q14":"main_issue",
        "q15":"computer",
        "q16":"internet",
        "q17":"email_wkly",
        "q18":"email_moly",
        "q19":"social_act",
        "q20":"shop_bank",
        "q21":"divices",
        "q22":"non_eng",
        "q23":"job_search",
        "q24":"volunteer",
        "q25":"interests",
        "q26a":"age",
        "q27":"gender",
        "q28":"hhld_size",
        "q29":"highest_ed",
        "q30":"race",
        "q31":"disability",
        "q32":"hhld_inc",
        "q32":"net_worth"
}

# Check that all expected columns exist in input data
df.columns = [i.lower().replace(" ", "_") for i in df.columns]
for col in cols.keys():
    try:
        assert col in df.columns
    except AssertionError as error:
        print(f'{col} is missing')

# Rename columns using cols dictionary
df.rename(columns=cols, inplace=True)

# Create location flag, overwriting by each smaller region
df['location'] = 'Nation'
df.loc[df.zip.isin(region_zips.ZIP.tolist()), 'location'] = 'Region'
df.loc[df.zip.isin(city_zips.zipcode.tolist()), 'location'] = 'NYC'


df.to_csv(sys.stdout, sep='|', index=False)