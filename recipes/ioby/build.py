import sys
import re
sys.path.insert(0, "..")
import pandas as pd
import numpy as np

def clean_city(s):
    return s.upper().replace('NEWYORK', 'NEW YORK')

# Read input spreadsheets, ignoring header information
df_il4 = pd.read_excel('input/il4.xlsx', usecols='D:R', skiprows=range(17), skipfooter=6)
df_ideas = pd.read_excel('input/ideas.xlsx', usecols='B:O', skiprows=range(14), skipfooter=6)

# Save raw data to csvs
df_il4.to_csv('input/il4_raw.csv', index=False)
df_ideas.to_csv('input/ideas_raw.csv', index=False)

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

# Check that input data has necessary columns
df_il4.columns = [i.lower().replace(" ", "_") for i in df_il4.columns]
for col in cols_il4:
    assert col in df_il4.columns

df_ideas.columns = [i.lower().replace(" ", "_") for i in df_ideas.columns]
for col in cols_ideas:
    assert col in df_ideas.columns

# Filter to NYC only
czb = pd.read_csv("../_data/city_zip_boro.csv", dtype=str, engine="c")
df_il4 = df_il4.loc[df_il4.project_zip.isin(czb.zipcode.tolist()), :]

df_ideas['project_city'] = df_ideas['project_city'].map(clean_city)
df_ideas['contact_city'] = df_ideas['contact_city'].map(clean_city)

df_ideas = df_ideas.loc[df_ideas.project_city.isin(czb.zipcode.tolist())|
                        df_ideas.contact_city.isin(czb.zipcode.tolist()), :]

# Merge tables
df = df_ideas[cols_ideas].merge(df_il4[cols_il4], how='outer', on=['campaign_name', 'campaign_description'])
df['campaign_description'] = df['campaign_description'].map(lambda x: re.sub(r"\([^)]*\)\|", "" '', x))

df.to_csv('input/raw.csv', index=False)
df.to_csv(sys.stdout, sep='|', index=False) 