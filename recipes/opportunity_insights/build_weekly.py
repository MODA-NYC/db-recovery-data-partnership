import sys
import pandas as pd

region = pd.read_csv('../_data/countyfips_region.csv', dtype=str)
region_dict = dict(zip(region.county_fip, region.county_name))

# Read daily data tables from GitHub
df1 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Zearn%20-%20County%20-%20Weekly.csv",
    dtype=str,
    na_values='.'
)

df2 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/UI%20Claims%20-%20County%20-%20Weekly.csv",
    dtype=str,
    na_values='.'
)

counties = region_dict.keys()
df1 = df1[df1.countyfips.isin(counties)]
df2 = df2[df2.countyfips.isin(counties)]
merged = pd.merge(df1, df2,  how='outer', on=["countyfips","year","month","day_endofweek"])

# Add county names
merged['county']= merged['countyfips'].map(region_dict)

merged.to_csv('input/weekly_raw.csv', index=False)
merged.to_csv(sys.stdout, index=False)