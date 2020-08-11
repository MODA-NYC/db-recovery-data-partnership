import sys
import re
sys.path.insert(0, "..")
import pandas as pd
import numpy as np

def clean_city(s):
    if str(s).upper() == 'NAN':
        return np.nan
    else:
        return str(s).upper().replace('NEWYORK', 'NEW YORK')

# Read input spreadsheets, ignoring header information
df_il4 = pd.read_excel('input/il4.xlsx', usecols='D:R', skiprows=range(17), skipfooter=6)
df_ideas = pd.read_excel('input/ideas.xlsx', usecols='B:O', skiprows=range(14), skipfooter=6)
df_donations = pd.read_excel('input/donations.xlsx', usecols='B:L', skiprows=range(13), skipfooter=7)

# Save raw data to csvs
df_il4.to_csv('input/il4_raw.csv', index=False)
df_ideas.to_csv('input/ideas_raw.csv', index=False)
df_donations.to_csv('input/donations_raw.csv', index=False)

cols_il4 = [
    "campaign_name",
    "campaign_description",
    "project_zip",
    "expected_revenue_in_campaign",
    "total_project_donations",
    "project_posted",
    "funding_deadline",
    "days_since_last_donation"
]

cols_ideas = [
    "campaign_name",
    "campaign_description",
    "campaign_status",
    "contact_city",
    "project_city"
]

cols_donations =  [
    "amount",
    "close_date",
    "project",
    "project_city"
]

# Check that input data has necessary columns
df_il4.columns = [i.lower().replace(" ", "_") for i in df_il4.columns]
for col in cols_il4:
    assert col in df_il4.columns

df_ideas.columns = [i.lower().replace(" ", "_") for i in df_ideas.columns]
for col in cols_ideas:
    assert col in df_ideas.columns

df_donations.columns = [i.lower().replace(" ", "_") for i in df_donations.columns]
for col in cols_donations:
    assert col in df_donations.columns


# Filter to NYC only
czb = pd.read_csv("../_data/city_zip_boro.csv", dtype=str, engine="c")
df_il4 = df_il4.loc[df_il4.project_zip.isin(czb.zipcode.tolist()), :]

df_ideas['project_city'] = df_ideas['project_city'].apply(clean_city)
df_ideas['contact_city'] = df_ideas['contact_city'].apply(clean_city)
df_ideas = df_ideas.loc[df_ideas.project_city.isin(czb.city.tolist())|
                        df_ideas.contact_city.isin(czb.city.tolist()), :]

df_donations['project_city'] = df_donations['project_city'].apply(clean_city)
df_donations = df_donations.loc[df_donations.project_city.isin(czb.city.tolist()), :]
df_donations = df_donations.loc[df_donations.type == 'Project Donation', :]

# Merge tables
df = df_ideas[cols_ideas].merge(df_il4[cols_il4], how='outer', on=['campaign_name', 'campaign_description'])
df['campaign_description'] = df['campaign_description'].map(lambda x: re.sub(r"\([^)]*\)\|", "" '', x))
df = df.merge(df_donations[cols_donations], how='outer', left_on='campaign_name', right_on='project')

df.to_csv('input/raw.csv', index=False)
df.to_csv(sys.stdout, sep='|', index=False) 