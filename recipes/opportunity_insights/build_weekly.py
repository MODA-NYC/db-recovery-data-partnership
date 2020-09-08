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

# Filter to NYC and set FIPS code as index
dfs = [df1, df2]
counties = region_dict.keys()
dfs = [df[df.countyfips.isin(counties)].set_index(["countyfips","year","month","day_endofweek"], drop=True) for df in dfs]

# Concatenate tables and reset index
merged = pd.concat(dfs, axis=1, join='outer', copy=False)
merged.reset_index(drop=False, inplace=True)

# Add county names
merged['county']= merged['countyfips'].map(region_dict)

merged.to_csv('input/weekly_raw.csv', index=False)
merged.to_csv(sys.stdout, index=False)